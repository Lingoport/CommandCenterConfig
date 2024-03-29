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
if [ "${exitValue}" != "0" ]; then
    echo "Error: rm -f unmergedSHAs_copy.txt failed with status: ${exitValue}"
    echo "Gerrit cleanup FAILED"
    exit $exitValue
fi

echo "$ read -r SHA < unmergedSHAs.txt"
while read -r SHA; do
    if [ "${SHA}" != "${SHA_TO_CLEAN}" ]; then
        echo "$ echo ${SHA} >> unmergedSHAs_copy.txt"
        echo "${SHA}" >> unmergedSHAs_copy.txt
    fi
done < ./unmergedSHAs.txt
exitValue=$?
if [ "${exitValue}" != "0" ]; then
    echo "Error: read -r SHA < unmergedSHAs.txt failed with status: ${exitValue}"
    echo "Gerrit cleanup FAILED"
    exit $exitValue
fi

echo "$ rm -f unmergedSHAs.txt"
rm -f unmergedSHAs.txt
exitValue=$?
if [ "${exitValue}" != "0" ]; then
    echo "Error: rm -f unmergedSHAs.txt failed with status: ${exitValue}"
    echo "Gerrit cleanup FAILED"
    exit $exitValue
fi

if [ -f unmergedSHAs_copy.txt ]; then
    echo "$ mv unmergedSHAs_copy.txt unmergedSHAs.txt"
    mv unmergedSHAs_copy.txt unmergedSHAs.txt
    exitValue=$?
    if [ "${exitValue}" != "0" ]; then
        echo "Error: mv unmergedSHAs_copy.txt unmergedSHAs.txt failed with status: ${exitValue}"
        echo "Gerrit cleanup FAILED"
        exit $exitValue
    fi
fi

echo ""
echo "Gerrit cleanup successful"
