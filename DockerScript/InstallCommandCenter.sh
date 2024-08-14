#!/bin/bash
#
# Install the Command Center Server.
#
# Author: Lili Ji
# Copyright (c) Lingoport 2022

# Function to check if the script can run a command with sudo

if [[ "$(id -u)" != "0" ]]; then
    echo "This script needs to be run with sudo."
    exit 1
fi



echo
echo "Installing the Command Center Servers ..."
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

#
# get serverURL if not set
#
if [ -z "$(echo $serverURL)" ]
then
    echo
    read -rp "Please enter server url [Q/q to quit install]: " result
    if [[ "$result" == "Q"  || "$result" == "q" ]]
	then
	    echo
        echo "Exiting Command Center Server Install."
        exit 1;
    elif [[ "$result" == "" ]]
    then
        echo
        echo "Failed to provide a Server URL."
        echo "Exiting Command Center Server Install."
        exit 1;
    else
        serverURL=$result
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
        echo "Exiting Command Center Server Install."
        exit 1;
    elif [[ "$result" == "" ]]
    then
        echo
        echo "Failed to provide a Docker Hub username."
        echo "Exiting Command Center Server Install."
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
        echo "Exiting Command Center Server Install."
        exit 1;
    elif [[ "$result" == "" ]]
    then
        echo
        echo "Failed to provide a Docker Hub account token."
        echo "Exiting Command Center Server Install."
        exit 1;
    else
        docker_account_token=$result
    fi
fi


mkdir -p $home_directory/lingoport || true
mkdir -p $home_directory/commandcenter/config || true
mkdir -p $home_directory/commandcenter/backup || true

cd $home_directory/commandcenter/config

sudo docker network ls | grep $database_network > /dev/null || sudo docker network create $database_network

cc_mysql_id=$(sudo docker run --restart unless-stopped -d --name commandcenterDatabase --network-alias mysqlservercommand --network $database_network -e MYSQL_ROOT_PASSWORD=$database_root_password -e MYSQL_DATABASE=commandcenter -v $home_directory/mysql/conf.d:/etc/mysql/conf.d  mysql:8.0 --character-set-server=utf8mb4 --collation-server=utf8mb4_unicode_ci)
sudo echo $cc_mysql_id > cc_mysql_id.txt

echo $docker_account_token | sudo docker login -u $docker_username --password-stdin

cc_container_id=`sudo docker run -dp $serverPort:8080 --restart unless-stopped --network-alias ccservernet --network $database_network -v /var/run/docker.sock:/var/run/docker.sock -v $home_directory/commandcenter/logs:/usr/local/tomcat/temp -v $home_directory/Lingoport_Data:/usr/local/tomcat/Lingoport_Data -v $home_directory/lingoport:/usr/local/tomcat/lingoport  $docker_image:$command_center_image_version`

echo "Command Center starting, container id is  $cc_container_id "
sudo echo $cc_container_id > cc_container_id.txt

sleep 30s
sudo docker exec  $cc_container_id bash -c "sed -i 's/mysecretpw/$database_root_password/g' /usr/local/tomcat/auto-install.xml"
sudo docker exec  $cc_container_id java -jar /usr/local/tomcat/lib/Lingoport_Resource_Manager_Server-11.0-Installer.jar /usr/local/tomcat/auto-install.xml
sudo docker exec  $cc_container_id git config --global user.email "lpdev@lingoport.com"
sudo docker exec  $cc_container_id git config --global user.name "lpdev"
sudo docker exec  $cc_container_id bash -c "echo 'grails.serverURL = $serverURL' >> /usr/local/tomcat/CommandCenterConfig.groovy"
sudo docker exec  $cc_container_id bash -c "sed -i 's/mysecretpw/$database_root_password/g' /usr/local/tomcat/CommandCenterConfig.groovy"
sudo docker exec  $cc_container_id bash -c "sed -i 's/yourcompany/$company_name/g' /usr/local/tomcat/CommandCenterConfig.groovy"

sleep 20s
sudo docker exec  $cc_container_id cp /usr/local/tomcat/webapps/application.properties /usr/local/tomcat/webapps/command-center/WEB-INF/classes
#sudo docker exec  $cc_container_id cp /usr/local/tomcat/webapps/command-center/WEB-INF/lib/aws-java-sdk-1.12.496.jar /usr/local/tomcat/lingoport/lrm-server-11.0/lib
sudo docker exec $cc_container_id rsync -av --ignore-existing /usr/local/tomcat/webapps/command-center/WEB-INF/lib/*.jar /usr/local/tomcat/lingoport/lrm-server-11.0/lib/

sudo docker restart  $cc_container_id
