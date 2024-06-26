#!/bin/bash
#
# Back up the Incontext Servers Database
#
# Author: Lili Ji
# Copyright (c) Lingoport 2022

echo
echo "Backing up the Incontext Servers Database ..."
echo

# Read in config file
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
        echo "Exiting Incontext back up"
        exit 1;
    elif [[ "$result" == "" ]]
    then
        echo
        echo "Failed to provide the MySQL Root Password."
        echo "Exiting Incontext Server backup."
        exit 1;
    else
        database_root_password=$result
    fi
fi


cd $home_directory/incontext/config || { echo "Failed to change directory"; exit 1; }

old_db=$(cat in_mysql_id.txt)
old=$(cat in_container_id.txt)
current_date=$(date -I)

mkdir -p $home_directory/incontext/backup || { echo "Failed to create backup directory"; exit 1; }

# Function to perform backup
backup_database() {
    local db_name=$1
    local backup_file="$home_directory/incontext/backup/${db_name}_backup_$current_date.sql"

    docker exec $old_db /usr/bin/mysqldump -u root --password=$database_root_password "$db_name" > "$backup_file" && {
        echo "The database $db_name has been successfully backed up to $backup_file"
    } || {
        echo "Backup failed for $db_name"
        return 1
    }
}

# Perform backups
backup_database "INCONTEXT"
