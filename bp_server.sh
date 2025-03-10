#!/bin/bash

source bp_properties.sh

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

	if [ -e ${1}.pid ];then
		local pid=$(cat ${1}.pid)
	    if [[ $(ps -p $pid --format comm=) == "${1}.sh" ]];then
			echo "${1} already started!"
			drop_lock ${1}.pid
			return
		fi
	fi
	echo "${1} Started and will happen for every $2!"
	${PARENT_DIR}/${1}.sh ${2}&
	echo "$!" > ${1}.pid

	drop_lock ${1}.pid
}

#usage: stop_backend_helper backend_name
stop_backend_helper(){
	fetch_lock ${1}.pid

	if [ -e ${1}.pid ];then
		local pid=$(cat ${1}.pid) 
		if [[ $(ps -p $pid --format comm=) == "${1}.sh" ]];then
			kill -9 $pid
			rm ${1}.pid
			echo "${1} Stopped!"
			drop_lock ${1}.pid
			return
		else
			rm ${1}.pid
			echo "${1}.pid file contains corrupted pid!"
		fi
	fi
	drop_lock ${1}.pid
	echo "${1} not started already. First start one!"
}

if [ ! -d $LOCK_DIR ];then
	mkdir $LOCK_DIR
fi

if [ $# -eq 0 ];then
	$LOG_SCRIPT "No options provided!"
	exit
fi

case $1 in
	st_b_sch)
		start_backend_helper bp_schedular $BACKUP_SLEEP_TIME
		;;
	sp_b_sch)
		stop_backend_helper bp_schedular
		;;
	*)
		$LOG_SCRIPT "Invalid option From Primary Server! $1"
		;;
esac
