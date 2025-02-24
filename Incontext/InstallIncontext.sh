#!/bin/bash
#
# Install the Incontext Server.
#
# Author: Lili Ji
# Copyright (c) Lingoport 2024

# Function to check if the script can run a command with sudo

if [[ "$(id -u)" != "0" ]]; then
    echo "This script needs to be run with sudo."
    exit 1
fi


echo
echo "Installing the Incontext Servers ..."
echo

#
# read in config file
#
if [[ -e "install.conf" ]]; then
    source install.conf
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
        echo "Exiting Incontext Server Install."
        exit 1;
    elif [[ "$result" == "" ]]
    then
        echo
        echo "Failed to provide the MySQL Root Password."
        echo "Exiting Incontext Server Install."
        exit 1;
    else
        database_root_password=$result
    fi
fi


#
# get docker_username if not set
#
if [ -z "$(echo $docker_username)" ]
then
    echo
    read -rp "Please enter Docker Hub username [Q/q to quit install]: " result
    if [[ "$result" == "Q"  || "$result" == "q" ]]
	then
	    echo
        echo "Exiting Incontext Server Install."
        exit 1;
    elif [[ "$result" == "" ]]
    then
        echo
        echo "Failed to provide a Docker Hub username."
        echo "Exiting Incontext Server Install."
        exit 1;
    else
        docker_username=$result
    fi
fi

#
# get docker_account_token if not set
#
if [ -z "$(echo $docker_account_token)" ]
then
    echo
    read -rp "Please enter Docker Hub account token [Q/q to quit install]: " result
    if [[ "$result" == "Q"  || "$result" == "q" ]]
	then
	    echo
        echo "Exiting Incontextr Server Install."
        exit 1;
    elif [[ "$result" == "" ]]
    then
        echo
        echo "Failed to provide a Docker Hub account token."
        echo "Exiting Incontext Server Install."
        exit 1;
    else
        docker_account_token=$result
    fi
fi


mkdir -p $home_directory/lingoport || true
mkdir -p $home_directory/incontext/config || true
mkdir -p $home_directory/incontext/backup || true
mkdir -p $home_directory/incontext/files || true


cd $home_directory/incontext/config

sudo docker network ls | grep $database_network > /dev/null || sudo docker network create $database_network

in_mysql_id=$(sudo docker run --restart unless-stopped -d  --name incontextDatabase --network-alias mysqlserverincontext --network $database_network -e MYSQL_ROOT_PASSWORD=$database_root_password -e MYSQL_DATABASE=INCONTEXT -v $home_directory/mysql/conf.d:/etc/mysql/conf.d  mysql:8.0 --default-authentication-plugin=mysql_native_password --character-set-server=utf8mb4 --collation-server=utf8mb4_unicode_ci)
sudo echo $in_mysql_id > in_mysql_id.txt

echo $docker_account_token | sudo docker login -u $docker_username --password-stdin

in_container_id=`sudo docker run -dp $serverPort:8080 --restart unless-stopped --network-alias inservernet --network $database_network -v $home_directory/incontext/files:/root/.incontextserver/export  $docker_image:$incontext_image_version`

echo "Incontext starting, container id is  $in_container_id "
sudo echo $in_container_id > in_container_id.txt

sleep 20s
sudo docker exec  $in_container_id bash -c "sed -i 's/mysecretpw/$database_root_password/g' /usr/local/tomcat/lingoport/IncontextServerConfig.groovy"

sudo docker restart  $in_container_id
