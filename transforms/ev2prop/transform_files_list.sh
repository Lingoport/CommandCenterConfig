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
echo " Files Modified:  $1"

echo "   >>  filename.properties -> filename.txt"
sed -i 's/\.properties/.txt/' "$1"

echo " "
ls -l "$1"
cat "$1"
echo " --------------------------------------------"

