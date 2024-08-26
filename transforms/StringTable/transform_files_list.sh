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
# here: <path>/filename.ja.txml

# and instead, you would want those files to be like:
# <path>/REPO_Supported_File.format
# here: <path>/filename.ja.xml
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
echo " txml to xml :  $1"
echo " for repository formatted files, not LRM OOTB ones"
echo "   >>  filename_ja.txml -> filename_ja.xml"
sed -i 's/\.txml/.xml/' "$1"

echo " "
ls -l "$1"
cat "$1"
echo " --------------------------------------------"
