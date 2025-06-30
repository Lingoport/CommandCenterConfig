#!/bin/bash
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
echo " Files from translation:  $1"
cat $1
echo " "
echo "   >>  <locale>.lproj -> <locale>"
sed -i 's/\.lproj//' "$1"

echo " "
echo " Files to import:  $1"
cat "$1"
echo " --------------------------------------------"

