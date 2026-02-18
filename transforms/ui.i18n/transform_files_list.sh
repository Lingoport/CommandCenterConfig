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

#  resourcemanagement.ui.i18n_<LOCALE>.json -> <LOCALE>_resourcemanagement.ui.i18n.json
echo "   >>   <FILENAME>.ui.i18n_<LOCALE>.json -> <LOCALE>_<FILENAME>.ui.i18n.json"

temp_file=$(mktemp)
touch "$temp_file"

#!/bin/bash

# Read each line from stdin or a file
while IFS= read -r file; do
    # Extract the basename (filename only)
    filename=$(basename "$file")

    # Extract the dirname 
    dirname=$(dirname "$file")

    # Extract locale and the rest of the filename
    locale=$(echo "$filename" | grep -oP '(?<=ui\.i18n_).*(?=\.json)')
    rest=$(echo "$filename" | sed "s/\(.*\)\.ui\.i18n_${locale}\.json/\1/")

    # Construct the new filename
    new_file="${dirname}/${locale}_${rest}.ui.i18n.json"

    # Output the new file with path 
    echo "$new_file" >> "$temp_file"
done < "$1"

mv "$temp_file" "$1"


" -> Modified input file"
ls -l "$1"
cat "$1"
echo " --------------------------------------------"

