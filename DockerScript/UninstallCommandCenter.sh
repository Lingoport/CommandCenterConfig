#!/bin/bash
#
# Install the Command Center Server.
#
# Author: Lili Ji
# Copyright (c) Lingoport 2022

# Check for passwordless sudo access
if ! sudo -n true 2>/dev/null; then
    echo "This script requires passwordless sudo access."
    echo "Please run it as 'sudo ./UninstallCommandCenter.sh' or configure passwordless sudo access."
    exit 1
fi

echo
echo "Uninstalling the Command Center Servers ..."
echo

if [[ -e "install.conf" ]]; then
    source install.conf
    echo "Reading configured information from install.conf file."
fi

mkdir -p $home_directory/commandcenter/backup || true

cd $home_directory/commandcenter/config

oldID=`cat cc_container_id.txt`

sudo docker stop $oldID

sudo docker rm $oldID

db=`cat cc_mysql_id.txt`

sudo docker stop $db

sudo docker rm $db
