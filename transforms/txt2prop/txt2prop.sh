#!/bin/bash
#
# Special handling for .csv files
#
# Find all the files ending in .csv
#
# The following environment variables need to be set:
#  CLIENT_SOURCE_DIR 
#

echo " " 
echo "Current Location" 
pwd
# First remove any previously transformed file: they are in the form 
#  strings_*.properties
echo " " 
echo "Removing strings_*.properties:"
find . -name "strings_*.properties"
find . -name "strings_*.properties" -exec rm {} \;

# Now let's transform from .txt to .properties
find . -name "string*\.txt" -type f > "${PROJECT_TMP_DIR}/input_files.txt"

cat "${PROJECT_TMP_DIR}/input_files.txt" | while read -r FILEPATH
do
  FILENAME=`basename $FILEPATH`
  DIRNAME=`dirname $FILEPATH`
  SUFFIX=".txt"
  ROOTNAME=${FILENAME%$SUFFIX}
  TARGET_NAME="${ROOTNAME//-/_}.properties"
  TARGET_PATH="${DIRNAME}/${TARGET_NAME}"
  echo "    Transform [$FILENAME] -> [$TARGET_NAME]"

  rm $TARGET_PATH 2> /dev/null
  touch $TARGET_PATH

  sed -i 's/,,/, ,/' $FILEPATH 
  cat $FILEPATH | while read -r LINE
  do
      IFS=',' tokens=( $LINE )

      if [ -z "${tokens[1]}" ]
      then
        echo "${LINE}" >> $TARGET_PATH
      else
        KEY=${tokens[0]}
        VALUE=${LINE#"${KEY},"}
        echo "${KEY}=${VALUE}" >> $TARGET_PATH
      fi
  done
IFS=' '

done 
echo " "
