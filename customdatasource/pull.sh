#!/bin/bash

echo ""
echo "Custom Pull Incoming variables:"
echo "     CUSTOM_DIR         = ${CUSTOM_DIR}"
echo "     CLIENT_SOURCE_DIR  = ${CLIENT_SOURCE_DIR}"

# cd to workspaces directory
cd "${CLIENT_SOURCE_DIR}"

# set these
svnUsername=""
svnPassword=""


echo "svn update --no-auth-cache --non-interactive --username ${svnUsername} --password xxxxx"
svn update --no-auth-cache --non-interactive --username ${svnUsername} --password ${svnPassword} > /dev/null 2>&1
exitValue=$?
if [ $exitValue != "0" ];then
    echo "Error: svn update failed with status: $exitValue"
    echo "Pull script FAILED"
    exit $exitValue;
fi

echo "svn status"
svn status

echo "svn info"
svn info

conflicts=`svn status | grep '^C'`
if [ -z "$conflicts" ]; then 
    echo "Pull script completed successfully"
    exit 0
else  
    echo "Pull script failed due to conflicts "
    exit 1
fi

