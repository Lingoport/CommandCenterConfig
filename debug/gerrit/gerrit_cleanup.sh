#!/bin/bash
echo "--------------------------------------"
echo "Cleanup Gerrit unmerged SHAs files"
echo "--------------------------------------"
echo ""
echo "Incoming variables:"
echo "    PROJECT_ID=${PROJECT_ID}"
echo "    SHA_TO_CLEAN=${SHA_TO_CLEAN}"
echo ""

if [ -z "${PROJECT_ID}" ]; then
    echo "PROJECT_ID is empty"
    echo "To set system variables like PROJECT_ID in Command Center, navigate to Settings > Advanced Settings > System Environment Variables"
    echo "Gerrit cleanup FAILED"
    exit -1
if

if [ -z "${SHA_TO_CLEAN}" ]; then
    echo "PROJECT_ID is empty"
    echo "To set system variables like PROJECT_ID in Command Center, navigate to Settings > Advanced Settings > System Environment Variables"
    echo "Gerrit cleanup FAILED"
    exit -1
if

echo "$ cd /usr/local/tomcat/Lingoport_Data/CommandCenter/system/gerritfiles/project/${PROJECT_ID}"
cd "/usr/local/tomcat/Lingoport_Data/CommandCenter/system/gerritfiles/project/${PROJECT_ID}"

echo "$ rm -f unmergedSHAs_copy.txt"
rm -f unmergedSHAs_copy.txt
if [ "${exitValue}" != "0" ];then
    echo "Error: rm -f unmergedSHAs_copy.txt failed with status: ${exitValue}"
    echo "Gerrit cleanup FAILED"
    exit $exitValue
fi

echo "$ read -r SHA < unmergedSHAs.txt"
while read -r SHA; do
    if [ "${SHA}" -ne "${SHA_TO_CLEAN}" ]; then
        echo "$ echo ${SHA} >> unmergedSHAs_copy.txt"
        echo "${SHA}" >> unmergedSHAs_copy.txt
    fi
done < unmergedSHAs.txt
if [ "${exitValue}" != "0" ];then
    echo "Error: read -r SHA < unmergedSHAs.txt failed with status: ${exitValue}"
    echo "Gerrit cleanup FAILED"
    exit $exitValue
fi

echo "$ mv unmergedSHAs_copy.txt unmergedSHAs.txt"
mv unmergedSHAs_copy.txt unmergedSHAs.txt
if [ "${exitValue}" != "0" ];then
    echo "Error: mv unmergedSHAs_copy.txt unmergedSHAs.txt failed with status: ${exitValue}"
    echo "Gerrit cleanup FAILED"
    exit $exitValue
fi
