#!/bin/bash

echo "Custom Push Files Incoming variables:"
echo "     CUSTOM_DIR        = ${CUSTOM_DIR}"
echo "     CLIENT_SOURCE_DIR = ${CLIENT_SOURCE_DIR}"
echo "     IMPORT_MESSAGE    = ${IMPORT_MESSAGE}"
echo "     IMPORT_LIST_PATH  = ${IMPORT_LIST_PATH}"

# cd to workspace directory
cd "${CLIENT_SOURCE_DIR}"

# set these
svnUsername="rThan"
svnPassword="noise?.dawn.ch3st.f0rce"


# svn add
IFS=, read -a Array <<< "${IMPORT_LIST_PATH}"
for i in "${Array[@]}"; do
    echo "svn add $i"
    svn add "$i" --force
    echo "svn changelist cc-list $i"
    svn changelist cc-list "$i"
    exitValue=$?
    if [ $exitValue != "0" ];then
        echo "Error: svn changelist failed with status: $exitValue"
    fi
done



# svn commit 
echo "svn commit -m ${IMPORT_MESSAGE} --changelist cc-list --no-auth-cache --non-interactive --username ${svnUsername} --password xxxxx"
svn commit -m "${IMPORT_MESSAGE}" --changelist cc-list --no-auth-cache --non-interactive --username ${svnUsername} --password ${svnPassword} > /dev/null 2>&1
exitValue=$?

echo "svn changelist --remove --recursive --cl cc-list"
svn changelist --remove --recursive --cl cc-list .

if [ $exitValue != "0" ];then
    echo "Error: svn commit failed with status: $exitValue"
    echo "Push Files script FAILED"
    exit 1;
fi

echo "svn status"
svn status

echo "svn info"
svn info

echo "Push Files script completed successfully"


