#!/bin/bash
#
# Install the Command Center Server.
#
# Author: Lili Ji
# Copyright (c) Lingoport 2022

# Check if the script is executed with sudo
if [[ "$(id -u)" != "0" ]]; then
    echo "This script needs to be run with sudo."
    echo "Please run it as 'sudo ./UpdateCommandCenter.sh'."
    exit 1
fi

echo
echo "Updating the Command Center Servers ..."
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

cd $home_directory/commandcenter/config


# Check if cc_container_id.txt file exists and is readable
if [[ -r "cc_container_id.txt" ]]; then
    old=$(cat cc_container_id.txt)
else
    echo "Error: Unable to read cc_container_id.txt. Please check file permissions."
    exit 1
fi

old_db=`cat cc_mysql_id.txt`

echo "Stopping old container: $old"

sudo docker stop $old
max_wait=30
elapsed=0
interval=5

while sudo docker ps -q --filter "id=$old" | grep -q .; do
    if [[ $elapsed -ge $max_wait ]]; then
        echo "Error: Container $old did not stop within $max_wait seconds."
        exit 1
    fi
    echo "Waiting for container $old to stop..."
    sleep $interval
    ((elapsed += interval))
done

echo "Container $old stopped successfully."

cd $home_directory/commandcenter/config

old_db=`cat cc_mysql_id.txt`

current_date=`date -I`

# Perform database backup and report success for commandcenter database
backup_file_cc="$home_directory/commandcenter/backup/commandcenter_backup_$current_date.sql"
docker exec $old_db /usr/bin/mysqldump -u root --password=$database_root_password commandcenter > "$backup_file_cc" && \
echo "The commandcenter database has been successfully backed up to $backup_file_cc"

# Perform database backup and report success for LRM database
backup_file_lrm="$home_directory/commandcenter/backup/LRM_backup_$current_date.sql"
docker exec $old_db /usr/bin/mysqldump -u root --password=$database_root_password LRM > "$backup_file_lrm" && \
echo "The LRM database has been successfully backed up to $backup_file_lrm"

echo $docker_account_token | sudo docker login -u $docker_username --password-stdin

cc_container_id=`sudo docker run -dp $serverPort:8080 --restart unless-stopped --network-alias ccservernet --network $database_network -v /var/run/docker.sock:/var/run/docker.sock -v $home_directory/commandcenter/logs:/usr/local/tomcat/temp -v $home_directory/Lingoport_Data:/usr/local/tomcat/Lingoport_Data -v $home_directory/lingoport:/usr/local/tomcat/lingoport  $docker_image:$command_center_image_version`


echo "Command Center starting, container id is  $cc_container_id "
echo $cc_container_id > cc_container_id.txt

sleep 20s

sudo docker exec --user root $cc_container_id chown -R tomcatuser:tomcatgroup /usr/local/tomcat/lingoport
sudo docker exec --user root $cc_container_id chown -R tomcatuser:tomcatgroup /usr/local/tomcat/Lingoport_Data
sudo docker exec --user root $cc_container_id chown -R tomcatuser:tomcatgroup /usr/local/tomcat/temp
sudo docker exec --user root $cc_container_id chown -R tomcatuser:tomcatgroup /usr/local/tomcat/logs
sudo docker exec --user root $cc_container_id mkdir -p /usr/local/tomcat/lingoport/lrm-server-12.0

sudo docker exec --user root $cc_container_id bash -c "sed -i 's/mysecretpw/$database_root_password/g' /usr/local/tomcat/auto-update.xml"
sudo docker exec --user root $cc_container_id java -jar /usr/local/tomcat/lib/Lingoport_Resource_Manager_Server-12.0-Installer.jar /usr/local/tomcat/auto-update.xml
sudo docker exec --user root $cc_container_id chown -R tomcatuser:tomcatgroup /usr/local/tomcat/lingoport/lrm-server-12.0
sudo docker exec  $cc_container_id git config --global user.email "lpdev@lingoport.com"
sudo docker exec  $cc_container_id git config --global user.name "lpdev"
sudo docker exec  $cc_container_id bash -c "echo 'grails.serverURL = $serverURL' >> /usr/local/tomcat/CommandCenterConfig.groovy"
sudo docker exec  $cc_container_id bash -c "sed -i 's/mysecretpw/$database_root_password/g' /usr/local/tomcat/CommandCenterConfig.groovy"
sudo docker exec  $cc_container_id bash -c "sed -i 's/yourcompany/$company_name/g' /usr/local/tomcat/CommandCenterConfig.groovy"
sudo docker exec --user root $cc_container_id /usr/local/tomcat/scripts/updatelite.sh


sleep 120s
sudo docker exec  $cc_container_id cp /usr/local/tomcat/webapps/application.properties /usr/local/tomcat/webapps/command-center/WEB-INF/classes
sudo docker exec $cc_container_id bash -c '[ -f /usr/local/tomcat/lingoport/lrm-server-12.0/lib/lc-public-api-sdk-24.0.5Lingoport.jar ] && cp /usr/local/tomcat/lingoport/lrm-server-12.0/lib/lc-public-api-sdk-24.0.5Lingoport.jar /usr/local/tomcat/webapps/command-center/WEB-INF/lib'
sudo docker exec $cc_container_id sh -c "cp -r /usr/local/tomcat/commandcenter/config/* /usr/local/tomcat/lingoport/lrm-server-12.0/lib"
sudo docker exec --user root $cc_container_id rm -f /usr/local/tomcat/lingoport/lrm-server-12.0/lib/aws-java-sdk-1.12.496.jar

sudo docker restart  $cc_container_id
