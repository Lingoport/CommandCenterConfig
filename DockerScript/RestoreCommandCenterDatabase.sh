#!/bin/bash
#
# Install the Command Center Server.
#
# Author: Lili Ji
# Copyright (c) Lingoport 2022

back_date=$1

echo
echo "Restoring the Command Center Servers Database ..."
echo

#
# read in config file
#
if [[ -e "install.conf" ]]; then
    source "install.conf"
    echo "Reading configured information from install.conf file."
fi

#
# get database_root_password if not set
#
if [ -z "$(echo $database_root_password)" ]
then
    echo
    read -rp "Please enter the MySQL Root Password you want to create [Q/q to quit install]: " result
    if [[ "$result" == "Q"  || "$result" == "q" ]]
	then
	    echo
        echo "Exiting Command Center Server Install."
        exit 1;
    elif [[ "$result" == "" ]]
    then
        echo
        echo "Failed to provide the MySQL Root Password."
        echo "Exiting Command Center Server Install."
        exit 1;
    else
        database_root_password=$result
    fi
fi


cd $home_directory/commandcenter/config

old_db=`cat cc_mysql_id.txt`

old=`cat cc_container_id.txt`

mkdir -p $home_directory/commandcenter/backup || true

docker exec $old_db /usr/bin/mysqldump -u root --password=$database_root_password commandcenter < $home_directory/commandcenter/backup/commandcenter_backup_$back_date.sql

docker exec $old_db /usr/bin/mysqldump -u root --password=$database_root_password LRM < $home_directory/commandcenter/backup/LRM_backup_$back_date.sql
