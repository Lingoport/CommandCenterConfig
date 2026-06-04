#!/bin/bash
#
# Special handling for .txt files. They are formatted like a csv.
#
# Find all the files ending in .txt
#
find . -name "*\.isl" -type f > "${PROJECT_TMP_DIR}/input_files.txt"

cat "${PROJECT_TMP_DIR}/input_files.txt" | while read -r FILEPATH
do
  FILENAME=`basename $FILEPATH`
  DIRNAME=`dirname $FILEPATH`
  
  # Extract language (part before first underscore)
  LANGUAGE="${FILENAME%%_*}"

  # Extract root name without language prefix and extension
  SUFFIX=".isl"
  REMAINDER="${FILENAME#*_}"
  ROOTNAME=${REMAINDER%$SUFFIX}

  TARGET_NAME="${ROOTNAME}_${LANGUAGE}.properties"
  TARGET_PATH="${DIRNAME}/${TARGET_NAME}"
  echo "    Transform [$FILEPATH] -> [$TARGET_PATH]"

  rm $TARGET_PATH 2> /dev/null
  cp $FILEPATH $TARGET_PATH

  sed -i 's/^[/#[/' $TARGET_PATH
  sed -i 's/^;/;[/' $TARGET_PATH

done 
