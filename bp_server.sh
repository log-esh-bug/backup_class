#!/bin/bash
PARENT_DIR=/home/test2/backup_class
source ${PARENT_DIR}/bp_properties.sh

start_backend_helper(){
	fetch_lock ${1}.pid

	local pid_file=${PARENT_DIR}/${1}.pid
	if [ -e ${pid_file} ];then
		local pid=$(cat ${pid_file})
	    if [[ $(ps -p $pid --format comm=) == "${1}.sh" ]];then
			$LOG_SCRIPT "${1} already started!"
			drop_lock ${1}.pid
			return
		fi
	fi
	$LOG_SCRIPT "${1} Started and will happen for every $2!"
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
			$LOG_SCRIPT "${1} Stopped!"
			drop_lock ${1}.pid
			return
		else
			rm ${pid_file}
			$LOG_SCRIPT "${1}.pid file contains corrupted pid!"
		fi
	fi
	drop_lock ${1}.pid
	$LOG_SCRIPT "${1} not started already. First start one!"
}

if [ ! -d $LOCK_DIR ];then
	mkdir $LOCK_DIR
fi

if [ $# -eq 0 ];then
	$LOG_SCRIPT "No options provided!"
	exit
fi

case $1 in
	start_bp)
		start_backend_helper start_bp $BACKUP_SLEEP_TIME
		;;
	stop_bp)
		stop_backend_helper start_bp
		;;
	*)
		$LOG_SCRIPT "Invalid option From Primary Server! $1"
		;;
esac
