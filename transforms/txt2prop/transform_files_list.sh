#!/bin/bash
#
# After the pseudo-loc has been run on OOTB supported files
# or an import from translated files
# AND 
# the files have been transformed back into the Repo supported format
#
# modify the *.txt (pseudo.txt, etc.) to reflect what will be pushed to 
# the repository (not the LRM OOTB supported files!)

# Parameter: $1
# Takes in a file that lists other files. For instance, 
# the pseudo_files.txt may list files like:
# <path>/LRM_Supported_File.format
# here: <path>/strings*.properties
# and instead, you would want those files to be like:
# <path>/REPO_Supported_File.format
# here: <path>/strings*.txt
#
#
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


echo " "
echo " --------------------------------------------"
echo " Files to Modify:  $1"
echo " for repository formatted files, not LRM OOTB ones"

# strings<locale>.properties -> strings<locale>.txt
echo "   >>  strings<locale>.properties to strings<locale>.txt"
sed -i 's/\.properties/.txt/' "$1"
sed -i 's/strings_/strings-/' "$1"
sed -i 's/strings-zh_Hans/strings-zh-Hans/' "$1"
sed -i 's/strings-zh_Hant/strings-zh-Hant/' "$1"
sed -i 's/_/-/g' "$1"

echo " " 
ls -l "$1"
cat "$1"
echo " --------------------------------------------"
