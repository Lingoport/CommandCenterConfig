#!/bin/bash
#
# Special handling for .csv files
#
# Find all the files ending in .csv
#
# The following environment variables need to be set:
#  CLIENT_SOURCE_DIR 
#
echo "DEBUG for Luz:"/usr/local/tomcat/Lingoport_Data/LRM/staging/importkits/xtm/AVO/UnityClient_L10N/TRANSLATED_KIT_8_pt_pt/LID1138403710_strings_pt_pt.properties
echo "Content of /usr/local/tomcat/Lingoport_Data/LRM/staging/importkits/xtm/AVO/UnityClient_L10N/TRANSLATED_KIT_8_pt_pt/LID1138403710_strings_pt_pt.properties"
ls -l /usr/local/tomcat/Lingoport_Data/LRM/staging/importkits/xtm/AVO/UnityClient_L10N/TRANSLATED_KIT_8_pt_pt/LID1138403710_strings_pt_pt.properties
cat /usr/local/tomcat/Lingoport_Data/LRM/staging/importkits/xtm/AVO/UnityClient_L10N/TRANSLATED_KIT_8_pt_pt/LID1138403710_strings_pt_pt.properties
cd "${CLIENT_SOURCE_DIR }"

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

echo "DEBUG for Luz"
echo "Transformed File Name: ${TARGET_PATH}"
echo "Content of File: "
head "${TARGET_PATH}"
wc -l "${TARGET_PATH}"

done 
