#!/bin/bash
#
# Special handling for .txt files. They are formatted like a csv.
#
# Find all the files ending in .txt
#
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
