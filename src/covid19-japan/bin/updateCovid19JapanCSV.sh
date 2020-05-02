#!/bin/sh
# -*- coding: utf-8 -*-

# for test
#set -x
#SPLUNK_HOME=${HOME}/work/Develop.d/docker-splunk-dev/dirs/opt-001.d/splunk
#VAR_DIR=${HOME}/work/Develop.d/docker-splunk-dev/dirs/var-001.d
#### end of test setting

SPLUNK_HOME=${SPLUNK_HOME:-"/opt/splunk"}
APP_BASE=${APP_BASE:-"${SPLUNK_HOME}/etc/apps/covid19-japan"}

RUN_SCRIPT_NAME=${RUN_SCRIPT:-"GetCovid19Japan.py"}
RUN_SCRIPT=${RUN_SCRIPT:-"${APP_BASE}/bin/${RUN_SCRIPT_NAME}"}

LOGNAME=${LOGNAME:-"$(logname)"}

export TZ="Asia/Tokyo"
NOW=$(date "+%Y%m%d%H%M%S")

run_script(){
	sheet="$1"
	original_file=$2
	var_dir=$3
	relative_dir=$4
	symlink_path=$5
	lookup_dir=$6
	lookup_file=$7

	cd /var/tmp
	[ -f ${original_file} ] && mv ${original_file} ${original_file}.backup-${NOW}

	${RUN_SCRIPT} -s "$sheet" -f ${original_file}
	[ -f ${original_file} ] || return 255

	chown splunk:splunk ${original_file}
	chmod 0664 ${original_file}
	mv ${original_file} ${var_dir}/${relative_dir}/${original_file}
	touch ${var_dir}/${relative_dir}/${original_file}
	rm -f ${symlink_path}
	ln -s ${relative_dir}/${original_file} ${symlink_path}

	[ -e ${lookup_dir}/${lookup_file} -a -h ${lookup_dir}/${lookup_file} ] && return 0
	[ -f ${lookup_dir}/${lookup_file} ] && mv ${lookup_dir}/${lookup_file} ${lookup_dir}/${lookup_file}.backup-${NOW}
	ln -s ${symlink_path} ${lookup_dir}/${lookup_file}
	return 0
}


SheetName="
	Patient Data
	Tokyo
	Osaka
	Aichi
	Kanagawa
	Prefecture Data
	Sum By Day
	Diamond Princess Sum By Day
	Diamond Princess Patient Data
	Tokyo Counts
"

_future_Sheet_Name="
	Chiba
"

TARGET_PREFIX="japan_covid_19_coronavirus_tracker"
VAR_DIR="/var/local/COVID19/Japan"
RELATIVE_DIR="csv_source"
LOOKUP_DIR="${APP_BASE}/lookups"

if [ ! -d ${VAR_DIR}/${RELATIVE_DIR} ]
then
	mkdir -p ${VAR_DIR}/${RELATIVE_DIR}
	chown -R ${LOGNAME}:splunk ${VAR_DIR}
	chmod -R 03775 ${VAR_DIR}
fi

echo "${SheetName}" | while read sheet
do
	[ "$sheet" = "" ] && continue
	postfix=$(echo "$sheet" | sed -e 's/ /_/g')
	ORIGINAL_FILE="${TARGET_PREFIX}-${postfix}-${NOW}.csv"
	SYMLINK_PATH="${VAR_DIR}/${TARGET_PREFIX}-${postfix}.csv"
	LOOKUP_FILE="${postfix}.csv"
	run_script "$sheet" ${ORIGINAL_FILE} ${VAR_DIR} ${RELATIVE_DIR} ${SYMLINK_PATH} ${LOOKUP_DIR} ${LOOKUP_FILE}
done
