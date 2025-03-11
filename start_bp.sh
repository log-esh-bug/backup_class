#!/bin/bash

PARENT_DIR=/home/test2/backup_class
source ${PARENT_DIR}/bp_properties.sh

start_bp_helper(){
    ssh ${PARTNER_USER_NAME}@${PARTNER_HOST_NAME} "${PARTNER_DOBACKUP_SCRIPT_PATH}"
    $LOG_SCRIPT "Took backup!"
}

MAIN(){
    while ((1))
    do
        backups_found=$(ls ${BACKUP_DIR}| wc -l)
        if(($backups_found >= $BACKUP_THRESHOLD));then

            oldest_backup=$(ls -t $BACKUP_DIR | tail -1)
            rm ${BACKUP_DIR}/${oldest_backup}
        fi
        start_bp_helper

        # echo "sleeping"
        sleep $BACKUP_SLEEP_TIME
    done
}

if [ ! -d "$BACKUP_DIR" ]; then
    if mkdir -p "$BACKUP_DIR"; then
        $LOG_SCRIPT "Backup directory created successfully at ${BACKUP_DIR}!"
    else
        $LOG_SCRIPT "Unable to create backup folder at ${BACKUP_DIR}!Exiting...."
        exit
    fi
fi

if [ -n "$1" ]; then
    $LOG_SCRIPT "$(basename $0) says Backup sleep time is set to $1"
    BACKUP_SLEEP_TIME=$1
fi

MAIN