#!/bin/bash
#
# After the pseudo-loc has been run on OOTB supported files
# or an import from translated files
# AND
# the files have been transformed back into the Repo supported format
#
# --->  resourcemanagement.ui.i18n_<LOCALE>.json -> <LOCALE>_resourcemanagement.ui.i18n.json
# rename to the repository convetion (not the LRM OOTB supported files!)

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
cat $1
echo " --------------------------------------------"
echo " for repository formatted files, not LRM OOTB ones"

# trim the lines in the file
#tr -d "[:blank:]" <  "$1" > "${1}.tmp"
#mv "${1}.tmp" "$1"

#  resourcemanagement.ui.i18n_<LOCALE>.json -> <LOCALE>_resourcemanagement.ui.i18n.json
echo "   >>   resourcemanagement.ui.i18n_<LOCALE>.json -> <LOCALE>_resourcemanagement.ui.i18n.json"
#sed -i 's/\.json//' "$1"
#sed -i 's/resourcemanagement\.ui\.i18n_//' "$1"

# At this point, only the locale is left! so add back .translation-meta.json after.
#sed -i 's/$/_resourcemanagement\.ui\.i18n.json/' "$1"

echo "" > "$1"
#echo " "
echo " Is $1 empty?"
ls -l "$1"
#ls -l "$1"
#cat "$1"
echo " --------------------------------------------"

