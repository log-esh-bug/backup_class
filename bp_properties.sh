#!/bin/bash

#######################################################
# BACKUP PROPERTIES
#######################################################

#Directories
PARENT_DIR=/home/test2/backup_class
BACKUP_DIR=${PARENT_DIR}/backups
LOCK_DIR=${PARENT_DIR}/locks

#Scripts
LOG_SCRIPT=${PARENT_DIR}/dolog.sh

#Constants
BACKUP_THRESHOLD=5
BACKUP_SLEEP_TIME=2

#About partner
PARTNER_USER_NAME=logesh-tt0826
PARTNER_HOST_NAME=logesh-tt0826
PARTNER_DOBACKUP_SCRIPT_PATH=/home/logesh-tt0826/class/dobackup.sh

#Lock Routines
fetch_lock(){
	while [ -e ${LOCK_DIR}/$(basename $1).lock ];
	do
		sleep 1		
	done
	touch ${LOCK_DIR}/$(basename $1).lock 
}

drop_lock(){
	if [ -e ${LOCK_DIR}/$(basename $1).lock  ];then
		rm ${LOCK_DIR}/$(basename $1).lock 
	fi
}
