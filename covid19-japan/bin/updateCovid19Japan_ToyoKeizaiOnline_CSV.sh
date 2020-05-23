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

BASE_URL="https://raw.githubusercontent.com/kaz-ogiwara/covid19/master/data"

if type flock > /dev/null 2>&1
then
        LOCK_PROGRAM="flock -x -n"
else
        LOCK_PROGRAM="lockf -ks -t 0"
fi

MODRECORD_FILE="toyo_keizai_online-modtime.csv"

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
	# Backup if the file exists
	[ -f ${original_file} ] && mv ${original_file} ${original_file}.backup-${NOW}

	# Run Script/Command with file lock for the exclusive execution
	${LOCK_PROGRAM} ${lock_file} ${RUN_SCRIPT} -q -T 60 -O ${original_file} ${BASE_URL}/$target.csv
	# exit when the original file doesn't exest
	[ -f ${original_file} ] || return 255
	# add a new line to the end of the file, just in case
	echo "" >> ${original_file}

	# compare the previous file and the new file if updates required or not
	if cmp ${symlink_path} ${original_file} > /dev/null
	then
		touch ${lock_file}
		rm -f ${original_file}
		return 1
	fi

	# set permissions
	chown ${LOGNAME}:splunk ${original_file}
	chmod 0664 ${original_file}
	# move a temp file to destination
	mv ${original_file} ${var_dir}/${relative_dir}/${original_file}
	# update mod time
	touch ${var_dir}/${relative_dir}/${original_file}

	# re-link symbolic file to the new file
	rm -f ${symlink_path}
	ln -s ${relative_dir}/${original_file} ${symlink_path}

	if [ "${lookup_file}" != "" ]
	then
		# Recording ModTime
		if [ ! -f ${lookup_dir}/${MODRECORD_FILE} ]
		then
			# Prepare a header
			echo '"modtime","filename"' > ${lookup_dir}/${MODRECORD_FILE}
		fi

		# Record ModTime to the CSV file with filename
		echo "\"$(date '+%FT%T%z')\",\"${lookup_file}\"" >> ${lookup_dir}/${MODRECORD_FILE}

		# Update Lookup file
		[ -e ${lookup_dir}/${lookup_file} -a -h ${lookup_dir}/${lookup_file} ] && return 0
		[ -f ${lookup_dir}/${lookup_file} ] && mv ${lookup_dir}/${lookup_file} ${lookup_dir}/${lookup_file}.backup-${NOW}
		ln -s ${symlink_path} ${lookup_dir}/${lookup_file}
	fi
	return 0
}


Target_Name="
	summary
	prefectures
	demography
"

_future_Target_Name="
"

TARGET_PREFIX="toyo_keizai_online"
VAR_DIR="/var/local/COVID19/Japan"
RELATIVE_DIR="toyo_keizai_online_csv_source"
LOOKUP_DIR="${APP_BASE}/lookups"

if [ ! -d ${VAR_DIR}/${RELATIVE_DIR} ]
then
	mkdir -p ${VAR_DIR}/${RELATIVE_DIR}
	chown -R ${LOGNAME}:splunk ${VAR_DIR}
	find ${VAR_DIR} -type d -exec chmod 03775 {} \;
fi

echo "${Target_Name}" | while read target
do
	[ "$target" = "" ] && continue
	postfix=$(echo "$target" | sed -e 's/ /_/g')
	ORIGINAL_FILE="${TARGET_PREFIX}-${postfix}-${NOW}.csv"
	SYMLINK_PATH="${VAR_DIR}/${TARGET_PREFIX}-${postfix}.csv"
	LOOKUP_FILE="${TARGET_PREFIX}-${postfix}.csv"
	LOCK_FILE=${VAR_DIR}/${RELATIVE_DIR}/${TARGET_PREFIX}-${postfix}.lock
	run_script "$target" ${ORIGINAL_FILE} ${VAR_DIR} ${RELATIVE_DIR} ${SYMLINK_PATH} ${LOOKUP_DIR} ${LOOKUP_FILE} ${LOCK_FILE}
done
