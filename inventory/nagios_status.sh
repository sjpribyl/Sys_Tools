#!/bin/bash 
for I in `ls /var/www/Inventory/ `
do 
	grep $I /var/www/Inventory/.nagios/* 
	[ $? -ne 0 ] && echo "missing:$I"
done | cut -f 6 -d \/ | sort -n

# vim: ts=4  sw=4 autoindent
