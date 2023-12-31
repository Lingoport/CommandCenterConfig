#!/bin/bash

echo " ------------------------------------------------------------------------------------"
echo "$0 does both the transform_files_list.sh job and does the transform_to_repo.sh job"
echo " by copying the files as found in the list of files to import, transformed here"
echo " ------------------------------------------------------------------------------------"
# Check if there is a file parameter
#
if [ -z "$1" ]
  then
    echo "Error: Missing the argument like /<path>/pseudo_files.txt"
    exit 1
fi

if [ -f "$1" ]; then
    echo " File to rewrite: $1"
else
    echo " $1 not found"
    exit 1
fi

echo " --------------------------------------------"
echo " File / to modify list :  $1"

newfile="${PROJECT_TMP_DIR}/tmp_list.txt"
rm "$newfile"
touch "$newfile"

echo " --------------------------------------" 
echo "Before list transform"
cat "$1"
while IFS= read -r line
do
  if [ "$line" != "" ]
  then
    ditafile=$(basename "$line")
    localepath=$(dirname "$line")
    locale=$(basename "$localepath")
    path=$(dirname "$localepath")

    # replace DITA_RESOURCES with $locale
    origin_path=${path/DITA_RESOURCES/$locale}

    # add the file name
    dest="${origin_path}/${ditafile}"

    # make the directory if necessary and copy the file
    mkdir -p "${origin_path}"
    cp "${line}" "${dest}"

    # Print informative message
    echo "$dest" >> "$newfile"
  fi

done < "$1"

mv "$newfile" "$1"
echo " --------------------------------------" 
echo "After list transform"
cat "$1"
echo " --------------------------------------" 



