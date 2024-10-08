#!/bin/bash
#
# Update the Incontext Server.
#
# Author: Lili Ji
# Copyright (c) Lingoport 2024

# Check if the script is executed with sudo
if [[ "$(id -u)" != "0" ]]; then
    echo "This script needs to be run with sudo."
    exit 1
fi

echo
echo "Updating the Incontext Servers ..."
echo
#
# read in config file
#
if [[ -e "install.conf" ]]; then
    source "install.conf"
    echo "Reading configured information from install.conf file."
fi


cd $home_directory/incontext/config


if [[ -r "in_container_id.txt" ]]; then
    old=$(cat in_container_id.txt)
else
    echo "Error: Unable to read in_container_id.txt. Please check file permissions."
    exit 1
fi

old_db=`cat in_mysql_id.txt`

sudo docker stop $old

cd $home_directory/incontext/config

old_db=`cat in_mysql_id.txt`

current_date=`date -I`
mkdir -p $home_directory/incontext/backup || true
mkdir -p $home_directory/incontext/files || true


# Perform database backup and report success for commandcenter database
backup_file_in="$home_directory/incontext/backup/incontext_backup_$current_date.sql"
docker exec $old_db /usr/bin/mysqldump -u root --password=$database_root_password INCONTEXT > "$backup_file_in" && \
echo "The incontext database has been successfully backed up to $backup_file_in"

echo $docker_account_token | sudo docker login -u $docker_username --password-stdin

in_container_id=`sudo docker run -dp $serverPort:8080 --restart unless-stopped --network-alias inservernet --network $database_network -v $home_directory/incontext/files:/root/.incontextserver/export $docker_image:$incontext_image_version`


echo "Incontext starting, container id is  $in_container_id "
echo $in_container_id > in_container_id.txt

sleep 20s
sudo docker exec  $in_container_id bash -c "sed -i 's/mysecretpw/$database_root_password/g' /usr/local/tomcat/lingoport/IncontextServerConfig.groovy"
sudo docker restart  $in_container_id
