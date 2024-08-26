#!/bin/bash
# Removes comments from non English files.
#
# From the WORKSPACE, find all the non English files
# and each such file, sed the comments out of the file

echo "Find all properties before removing the comments from the target files"
find . -name "*\.properties" -type f > "${PROJECT_TMP_DIR}/properties_files.txt"

echo "Removes all the comments from non English files"
sed -i '/en.properties/d' "${PROJECT_TMP_DIR}/properties_files.txt"
cat "${PROJECT_TMP_DIR}/properties_files.txt"| while read -r FILEPATH
do
 sed -i '/^#/d' $FILEPATH
done

