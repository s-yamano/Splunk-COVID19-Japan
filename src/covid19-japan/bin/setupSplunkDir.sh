#!/bin/sh
# -*- coding:utf-8 -*-

SPLUNK_HOME=${SPLUNK_HOME:-"/opt/splunk"}
APP_NAME=${APP_NAME:-"covid19-japan"}
APP_HOME=${APP_HOME:-"${SPLUNK_HOME}/etc/apps/${APP_NAME}"}

LOCAL_VAR=${LOCAL_VAR:-"/var/local/COVID19/Japan"}

[ -d ${LOCAL_VAR} ] || mkdir -p ${LOCAL_VAR}

if [ ! -d ${APP_HOME} ]
then
	echo "'${APP_HOME}' does not exist."
	exit 255
fi

for dir in ${APP_HOME} ${LOCAL_VAR}
do
	if [ "${LOGNAME}" = "splunk" -o "${LOGNAME}" = "root" ]
	then
		chown -R splunk:splunk $dir
	else
		chgrp -R splunk $dir
	fi

	find $dir \( -type d -exec chmod 03775 {} \; \) -o \( -type f -exec chmod ug+rw,o+r {} \; \)
done
