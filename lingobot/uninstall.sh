#!/bin/bash

echo
echo "Uninstalling the Lingobot ..."
echo

if [[ -e "install.conf" ]]; then
    source install.conf
    echo "Reading configured information from install.conf file."
fi


cd $home_directory/lingobot

oldID=`cat lingobot_container_id.txt`

sudo docker stop $oldID

sudo docker rm $oldID
