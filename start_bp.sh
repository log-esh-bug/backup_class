#!/bin/bash

sleep_time=60
LOG_FILE=/home/sas/backup_class/log

log(){
    echo "$(date +%F' '%T' '%Z) [$(ps -p $PPID --format comm=) $PPID] LOG: $1" >> $LOG_FILE
}

if [ -n "$1" ];then
    sleep_time=$1
    log "Backup sleep time set to $sleep_time"
fi

dobackup_helper(){
        pgbackrest --stanza=class backup
        if [ $? -ne 0 ]; then
                log "Backup failed.Safely Exiting..."
                exit 1
        fi
        log "Backup taken!!!"
}

while true
do
    dobackup_helper
    sleep ${sleep_time}
done
