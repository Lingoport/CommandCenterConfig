#!/bin/bash
#
# Uninstall the Incontext Server.
#
# Author: Lili Ji
# Copyright (c) Lingoport 2024

if [[ "$(id -u)" != "0" ]]; then
    echo "This script needs to be run with sudo."
    exit 1
fi

echo
echo "Uninstalling the Incontext Servers ..."
echo

# Source the config file if it exists
if [[ -e "install.conf" ]]; then
    source install.conf
    echo "Reading configured information from install.conf file."
fi


# Change to the config directory
cd $home_directory/incontext/config || { echo "Failed to change to config directory"; exit 1; }

# Read the container ID and stop/remove the container
oldID=$(cat in_container_id.txt)
sudo docker stop $oldID && sudo docker rm $oldID || { echo "Failed to stop/remove Docker container $oldID"; exit 1; }

# Read the database container ID and stop/remove the container
db=$(cat in_mysql_id.txt)
sudo docker stop $db && sudo docker rm $db || { echo "Failed to stop/remove Docker database container $db"; exit 1; }

echo "Incontext has been successfully uninstalled."
