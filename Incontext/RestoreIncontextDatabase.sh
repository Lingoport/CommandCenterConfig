#!/bin/bash
#
# Restore Incontext server Database.
#
# Author: Lili Ji
# Copyright (c) Lingoport 2024

back_date=$1

# Check for help flag or no arguments
if [[ "$1" == "-h" || "$1" == "--help" || -z "$1" ]]; then
    echo "Usage: sudo $0 YYYY-MM-DD"
    echo "Restores the Incontext Server's Database to the state of the specified date."
    exit 0
fi

echo
echo "Restoring the Incontext Database ..."
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
        echo "Exiting"
        exit 1;
    elif [[ "$result" == "" ]]
    then
        echo
        echo "Failed to provide the MySQL Root Password."
        echo "Exiting"
        exit 1;
    else
        database_root_password=$result
    fi
fi

cd $home_directory/incontext/config

old_db=`cat in_mysql_id.txt`

old=`cat in_container_id.txt`

mkdir -p $home_directory/incontext/backup || true

docker exec -i $old_db mysql -u root --password=$database_root_password INCONTEXT < $home_directory/incontext/backup/incontext_backup_$back_date.sql 2>/dev/null

filePath="$home_directory/incontext/config/in_container_id.txt"

# Find the running container ID(s) for images containing "command-center"
containerIDs=$(docker ps --filter "status=running" --format '{{.ID}}\t{{.Image}}' | grep 'incontext' | cut -f1)

if [ -z "$containerIDs" ]; then
    echo "No running containers found with an image containing 'incontext'."
else
    echo "Running container IDs with images containing 'incontext':"
    echo "$containerIDs"
    echo "Restore database successfully"
    # Save the container IDs to the file, overwriting previous content
    echo "$containerIDs" > "$filePath"
fi
