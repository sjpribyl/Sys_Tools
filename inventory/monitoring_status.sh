#!/bin/bash 
for I in `ls /var/www/Inventory/ `
do 
	grep $I /var/www/Inventory/.nagios/* 
	if [ $? -ne 0 ]; then 
		grep $I /var/www/Inventory/.check_host/* 
		[ $? -ne 0 ] && echo "missing:$I"
	fi
done | cut -f 6 -d \/ | sort -n > /var/www/Inventory/.reports/monitoring_status.txt


# vim: ts=4  sw=4 autoindent
