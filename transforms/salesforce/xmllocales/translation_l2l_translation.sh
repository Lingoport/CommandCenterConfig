#!/bin/bash
#
# 1. Rename files in the form translation_meta.<locale>.xml to  <locale>.translation_meta.xml
#
# Find all the files starting in translation_meta
#
#
find . -name "translation-meta.*.xml" -type f > "${PROJECT_TMP_DIR}/input_files.txt"

cat "${PROJECT_TMP_DIR}/input_files.txt" | while read -r FILEPATH
do
  FILENAME=`basename $FILEPATH`
  DIRNAME=`dirname $FILEPATH`
  SUFFIX=".xml"
  ROOTNAME=${FILENAME%$SUFFIX}
  LOCALENAME=${ROOTNAME#*translation-meta.}
  TARGET_NAME="${LOCALENAME}.translation-meta.xml"
  TARGET_PATH="${DIRNAME}/${TARGET_NAME}"
  ## BUT NOT THE en_US FILE!!!
  if [ "$LOCALENAME" == "en_US" ]; then
    echo "    Do not transform back ${FILEPATH}"
  else
    echo "    Transform [$FILEPATH] -> [$TARGET_PATH]"
    cp "${FILEPATH}" "${TARGET_PATH}"
  fi

#  sed -i 's/,,/, ,/' $FILEPATH 
#  cat $FILEPATH | while read -r LINE
#  do
#      IFS=',' tokens=( $LINE )
#
#      if [ -z "${tokens[1]}" ]
#      then
#        echo "${LINE}" >> $TARGET_PATH
#      else
#        KEY=${tokens[0]}
#        VALUE=${LINE#"${KEY},"}
#        echo "${KEY}=${VALUE}" >> $TARGET_PATH
#      fi
#  done
IFS=' '

done 
