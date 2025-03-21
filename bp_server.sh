#!/bin/bash
PARENT_DIR=/home/sas/backup_class

#Log related stuffs
LOG_FILE=/home/sas/backup_class/log

log(){
    echo "$(date +%F' '%T' '%Z) [$(ps -p $PPID --format comm=) $PPID] LOG: $1" >> $LOG_FILE
}


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

start_backend_helper(){
	fetch_lock ${1}.pid

	local pid_file=${PARENT_DIR}/${1}.pid
	if [ -e ${pid_file} ];then
		local pid=$(cat ${pid_file})
	    if [[ $(ps -p $pid --format comm=) == "${1}.sh" ]];then
			log "${1} already started!"
			drop_lock ${1}.pid
			return
		fi
	fi
	log "${1} Started and will happen for every $2!"
	${PARENT_DIR}/${1}.sh ${2}&
	echo "$!" > ${pid_file}
	drop_lock ${1}.pid
}

#usage: stop_backend_helper backend_name
stop_backend_helper(){
	fetch_lock ${1}.pid

	local pid_file=${PARENT_DIR}/${1}.pid
	if [ -e ${pid_file} ];then
		local pid=$(cat ${pid_file}) 
		if [[ $(ps -p $pid --format comm=) == "${1}.sh" ]];then
			kill -9 $pid
			rm ${pid_file}
			log "${1} Stopped!"
			drop_lock ${1}.pid
			return
		else
			rm ${pid_file}
			log "${1}.pid file contains corrupted pid!"
		fi
	fi
	drop_lock ${1}.pid
	log "${1} not started already. First start one!"
}


#################### Main ####################

if [ ! -d $LOCK_DIR ];then
	mkdir $LOCK_DIR
fi

if [ $# -eq 0 ];then
	log "No options provided!"
	exit
fi

case $1 in
	start_bp)
		start_backend_helper start_bp $2
		;;
	stop_bp)
		stop_backend_helper start_bp
		;;
	*)
		log "Invalid option From Primary Server! $1"
		;;
esac
