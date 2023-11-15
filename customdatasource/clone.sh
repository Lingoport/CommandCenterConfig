#!/bin/bash



echo "Custom Clone Incoming variables:"
echo "    CUSTOM_DIR          = ${CUSTOM_DIR}"
echo "    WORKSPACES_DIR      = ${WORKSPACES_DIR}"
echo "    WORKSPACE_NAME      = ${WORKSPACE_NAME}"

# cd to workspaces directory
cd ${WORKSPACES_DIR}

# set these
svnUsername="rThan"
svnPassword="noise?.dawn.ch3st.f0rce"
svnUrl="https://svn.dmba.com/svn/mvc/branches/lingoport_TestConnection_20231107"


# checkout
echo "svn checkout --no-auth-cache --non-interactive --username ${svnUsername} --password xxxxx ${svnUrl} ${WORKSPACE_NAME}"
svn checkout --no-auth-cache --non-interactive --username ${svnUsername} --password ${svnPassword} ${svnUrl} ${WORKSPACE_NAME} > /dev/null 2>&1
exitValue=$?
if [ $exitValue != "0" ];then
    echo "Error: svn checkout failed with status: $exitValue"
    echo "Checkout script FAILED"
    exit $exitValue;
fi
	
echo "svn status"
svn status

echo "svn info"
svn info

echo "Checkout script completed successfully"
exit 0


