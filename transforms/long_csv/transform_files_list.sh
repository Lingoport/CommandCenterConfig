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


# Function to replace target CSV filename with source CSV filename in the text file
replace_in_text_file() {
  local text_file="$1"

  # Check if the text file exists
  if [ ! -f "$text_file" ]; then
    echo "Text file $text_file does not exist."
    exit 1
  fi

  # Read properties file and perform replacements
  while IFS='=' read -r key value; do
    if [ -n "$key" ] && [ -n "$value" ]; then
      sed -i "s/${value}.csv/${key}.csv/g" "$text_file"
      echo "Replaced ${value}.csv with ${key}.csv in $text_file"
    fi
  done < "$TRANSFORM_DIR/csv_locale_map.properties"
}

# Path to the text file to be updated
text_file="$1"

# Replace occurrences in the text file
replace_in_text_file "$text_file"

