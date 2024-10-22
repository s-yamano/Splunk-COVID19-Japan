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

if type flock > /dev/null 2>&1
then
        LOCK_PROGRAM="flock -x -n"
else
        LOCK_PROGRAM="lockf -ks -t 0"
fi

run_script(){
	sheet="$1"
	original_file=$2
	var_dir=$3
	relative_dir=$4
	symlink_path=$5
	lookup_dir=$6
	lookup_file=$7
	lock_file=$8

	cd /var/tmp
	[ -f ${original_file} ] && mv ${original_file} ${original_file}.backup-${NOW}

	${LOCK_PROGRAM} ${lock_file} ${RUN_SCRIPT} -s "$sheet" -f ${original_file}
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
	Aichi
	Chiba
	Kanagawa
	Osaka
	Saitama
	Hokkaido
	Tokyo
	Prefecture Data
	Sum By Day
	Cruise Sum By Day
	Tokyo Counts
	Tokyo Recoveries
	Recovery Stats
	Diamond Princess Patient Data
	Patient Statuses
"

_future_Sheet_Name="
"

TARGET_PREFIX="japan_covid_19_coronavirus_tracker"
VAR_DIR="/var/local/COVID19/Japan"
RELATIVE_DIR="csv_source"
LOOKUP_DIR="${APP_BASE}/lookups"

if [ ! -d ${VAR_DIR}/${RELATIVE_DIR} ]
then
	mkdir -p ${VAR_DIR}/${RELATIVE_DIR}
	chown -R ${LOGNAME}:splunk ${VAR_DIR}
	find ${VAR_DIR} -type d -exec chmod 03775 {} \;
fi

echo "${SheetName}" | while read sheet
do
	[ "$sheet" = "" ] && continue
	postfix=$(echo "$sheet" | sed -e 's/ /_/g')
	ORIGINAL_FILE="${TARGET_PREFIX}-${postfix}-${NOW}.csv"
	SYMLINK_PATH="${VAR_DIR}/${TARGET_PREFIX}-${postfix}.csv"
	LOOKUP_FILE="${postfix}.csv"
	LOCK_FILE=${VAR_DIR}/${RELATIVE_DIR}/${TARGET_PREFIX}-${postfix}.lock
	run_script "$sheet" ${ORIGINAL_FILE} ${VAR_DIR} ${RELATIVE_DIR} ${SYMLINK_PATH} ${LOOKUP_DIR} ${LOOKUP_FILE} ${LOCK_FILE}
done
