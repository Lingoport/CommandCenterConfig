#!/bin/bash
# No-op: translated locale files (e.g. AboutForm.de.resx) already match the repository naming convention.

if [ -z "$1" ]; then
  echo "Error: Missing the argument like /<path>/pseudo_files.txt"
  exit 1
fi

if [ ! -f "$1" ]; then
  echo " $1 not found"
  exit 1
fi

echo " resx_text transform_files_list: no filename rewriting needed"
cat "$1"
