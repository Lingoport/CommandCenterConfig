#!/bin/bash
# Remove any LRM tag from 'incoming' files
#

echo "The following files are about to be added to the repository"
echo "This script removes any LRM tag from those files"
cat "$1"

cat "$1" | while read -r FILEPATH
do
  echo " sed rm LRM Tag line in [${FILEPATH}]"

  # If a line has FULL-FILE, remove it
  sed -i '/FULL-FILE/d' "$FILEPATH"

  # If a line has CHANGES-ONLY, remove it
  sed -i '/CHANGES-ONLY/d' "$FILEPATH"

done
echo  " ------------------------------------------------"
echo " "
