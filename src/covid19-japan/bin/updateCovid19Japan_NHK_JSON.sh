#!/bin/sh
# -*- coding: utf-8 -*-

# for test
#set -x
#SPLUNK_HOME=${HOME}/work/Develop.d/docker-splunk-dev/dirs/opt-001.d/splunk
#VAR_DIR=${HOME}/work/Develop.d/docker-splunk-dev/dirs/var-001.d
#### end of test setting

SPLUNK_HOME=${SPLUNK_HOME:-"/opt/splunk"}
APP_BASE=${APP_BASE:-"${SPLUNK_HOME}/etc/apps/covid19-japan"}

RUN_SCRIPT_NAME=${RUN_SCRIPT:-"wget"}
RUN_SCRIPT=${RUN_SCRIPT:-"${RUN_SCRIPT_NAME}"}

LOGNAME=${LOGNAME:-"$(logname)"}

export TZ="Asia/Tokyo"
NOW=$(date "+%Y%m%d%H%M%S")

NHK_URL="https://www3.nhk.or.jp/news/special/coronavirus/data"

run_script(){
	target="$1"
	original_file=$2
	var_dir=$3
	relative_dir=$4
	symlink_path=$5
	lookup_dir=$6
	lookup_file=$7
	lock_file=$8

	cd /var/tmp
	[ -f ${original_file} ] && mv ${original_file} ${original_file}.backup-${NOW}

	flock -n ${lock_file} ${RUN_SCRIPT} -q -T 60 -O ${original_file} ${NHK_URL}/$target.json
	[ -f ${original_file} ] || return 255
	echo "" >> ${original_file}

	if cmp ${symlink_path} ${original_file} > /dev/null
	then
		touch ${lock_file}
		rm -f ${original_file}
		return 1
	fi

	chown ${LOGNAME}:splunk ${original_file}
	chmod 0664 ${original_file}
	mv ${original_file} ${var_dir}/${relative_dir}/${original_file}
	touch ${var_dir}/${relative_dir}/${original_file}
	rm -f ${symlink_path}
	ln -s ${relative_dir}/${original_file} ${symlink_path}

	if [ "${lookup_file}" != "" ]
	then
		[ -e ${lookup_dir}/${lookup_file} -a -h ${lookup_dir}/${lookup_file} ] && return 0
		[ -f ${lookup_dir}/${lookup_file} ] && mv ${lookup_dir}/${lookup_file} ${lookup_dir}/${lookup_file}.backup-${NOW}
		ln -s ${symlink_path} ${lookup_dir}/${lookup_file}
	fi
	return 0
}


TargetName="
	47patients-data
	47newpatients-data
"

_future_TargetName="
"

TARGET_PREFIX="NHK"
VAR_DIR="/var/local/COVID19/Japan"
RELATIVE_DIR="NHK"
LOOKUP_DIR="${APP_BASE}/lookups"

if [ ! -d ${VAR_DIR}/${RELATIVE_DIR} ]
then
	mkdir -p ${VAR_DIR}/${RELATIVE_DIR}
	chown -R ${LOGNAME}:splunk ${VAR_DIR}/${RELATIVE_DIR}
	chmod -R 03775 ${VAR_DIR}
fi


echo "${TargetName}" | while read target
do
	[ "$target" = "" ] && continue
	postfix=$(echo "$target" | sed -e 's/ /_/g')
	ORIGINAL_FILE="${TARGET_PREFIX}-${postfix}-${NOW}.json"
	SYMLINK_PATH="${VAR_DIR}/${TARGET_PREFIX}-${postfix}.json"
	LOOKUP_FILE=""
	LOCK_FILE=${VAR_DIR}/${RELATIVE_DIR}/${TARGET_PREFIX}-${postfix}.lock
	run_script "$target" ${ORIGINAL_FILE} ${VAR_DIR} ${RELATIVE_DIR} ${SYMLINK_PATH} ${LOOKUP_DIR} "${LOOKUP_FILE}" ${LOCK_FILE}
done
