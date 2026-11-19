#!/bin/bash
#
# ts2qtxml : transform_files_list.sh
#
# After pseudo-localization, or an import of translated files, AND the
# transform back to the repository format, rewrite the file list so it names
# the repository files rather than the LRM files.
#
# Parameter: $1
#   A file listing other files, e.g. /<path>/pseudo_files.txt, with lines like
#     <path>/strings_fr_FR.qtxml
#   which become
#     <path>/strings_fr_FR.ts

if [ -z "$1" ]; then
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
echo " qtxml to ts :  $1"
echo " for repository formatted files, not LRM ones"
echo "   >>  strings_fr_FR.qtxml -> strings_fr_FR.ts"
sed -i 's/\.qtxml\(\r\?\)$/.ts\1/' "$1"

echo " "
ls -l "$1"
cat "$1"
echo " --------------------------------------------"
