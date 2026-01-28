#!/bin/bash

echo "=============================================="
echo "Transform to repository: localeKey"
echo "$FULL_LIST_PATH"
cat "$FULL_LIST_PATH"
echo "=============================================="

# Loop through the list of files from the $FULL_LIST_PATH as those are 
# the only files to move to the directory
while read jsonFile; do

  echo " locale = in $jsonFile"
  DIRONE=`dirname "$FPATH"`
  LOCALENAME=`basename "$DIRONE"`
  sed -i "s/.*\"locale\"\:.*/  \"locale\"\: \"$LOCALENAME\",/ "

done < "$FULL_LIST_PATH"
