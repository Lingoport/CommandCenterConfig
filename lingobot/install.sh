#!/bin/bash
#
# Install the Lingobot.
#
# Author: Lili Ji
# Copyright (c) Lingoport 2023


echo
echo "Installing the Lingobot ..."
echo

#
# read in config file
#
if [[ -e "install.conf" ]]; then
    source install.conf
    echo "Reading configured information from install.conf file."
fi

mkdir -p $home_directory/lingobot || true

echo $docker_account_token | sudo docker login -u $docker_username --password-stdin
#docker run --name lingobot -p 80:3001 -d lingoport/lingobot_dev:1.0

cc_container_id=`sudo docker run -dp $serverPort:3001 -v $home_directory/lingobot:/home/node/app/lingobot  --restart unless-stopped $docker_image:$lingobot_image_version`


echo "Lingobot starting, container id is  $cc_container_id "

sleep 20s

sudo docker exec  $cc_container_id rm /home/node/app/.env
sudo docker cp install.conf $cc_container_id:/home/node/app/.env

sudo docker restart  $cc_container_id

cd $home_directory/lingobot

sudo echo $cc_container_id > lingobot_container_id.txt
