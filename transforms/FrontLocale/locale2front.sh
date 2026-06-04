#!/bin/bash
#
# Special handling for .txt files. They are formatted like a csv.
#
# Find all the files ending in .txt
#

echo  " ------------------------------------------------"
echo  " Current pwd:"
pwd

echo "Files to transform: " 
cat "${FULL_LIST_PATH}"

cat "${FULL_LIST_PATH}" | while read -r FILEPATH
do
  FILENAME=`basename $FILEPATH`
  DIRNAME=`dirname $FILEPATH`
  SUFFIX=".properties"

  
  # Extract base name (part before last underscore)
  base="${FILENAME%_*}"

  # Extract language and remove extension
  remainder="${FILENAME##*_}"
  language="${remainder%.properties}"

  # Construct output filename
  TARGET_NAME="${language}_${base}.isl"
  TARGET_PATH="${DIRNAME}/${TARGET_NAME}"

  echo "    Transform [$FILEPATH] -> [$TARGET_PATH]"

  rm $TARGET_PATH 2> /dev/null
  cp $FILEPATH $TARGET_PATH

  sed -i 's/^\#\[/\[/' $TARGET_PATH
  sed -i 's/^\#\;/\;/' $TARGET_PATH

done 
