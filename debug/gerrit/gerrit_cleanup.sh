#!/bin/bash
echo "--------------------------------------"
echo "Cleanup Gerrit unmerged SHAs files"
echo "--------------------------------------"
echo ""
echo "Incoming variables:"
echo "    PROJECT_ID=${PROJECT_ID}"
echo "    SHA_TO_CLEAN=${SHA_TO_CLEAN}"
echo ""

echo "$ cd /usr/local/tomcat/Lingoport_Data/CommandCenter/system/gerritfiles/projects/${PROJECT_ID}"
cd "/usr/local/tomcat/Lingoport_Data/CommandCenter/system/gerritfiles/projects/${PROJECT_ID}"

echo "$ rm -f unmergedSHAs_copy.txt"
rm -f unmergedSHAs_copy.txt
exitValue=$?
if [ "${exitValue}" != "0" ];then
    echo "Error: rm -f unmergedSHAs_copy.txt failed with status: ${exitValue}"
    echo "Gerrit cleanup FAILED"
    exit $exitValue
fi

echo "$ pwd"
pwd

echo "$ read -r line < unmergedSHAs.txt"
while read -r line; do
    echo "test"
done < ./unmergedSHAs.txt
exitValue=$?
if [ "${exitValue}" -ne "0" ];then
    echo "Error: read -r line < unmergedSHAs.txt failed with status: ${exitValue}"
    echo "Gerrit cleanup FAILED"
    exit $exitValue
fi

echo "$ mv unmergedSHAs_copy.txt unmergedSHAs.txt"
mv unmergedSHAs_copy.txt unmergedSHAs.txt
exitValue=$?
if [ "${exitValue}" -ne "0" ];then
    echo "Error: mv unmergedSHAs_copy.txt unmergedSHAs.txt failed with status: ${exitValue}"
    echo "Gerrit cleanup FAILED"
    exit $exitValue
fi
