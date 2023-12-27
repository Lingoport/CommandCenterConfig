#!/bin/bash
# Special handling for .txt files
# transforms the strings*.properties into strings*.txt
echo  " ------------------------------------------------"
echo  " Current pwd:"
pwd

echo "Files to transform: " 
cat "${FULL_LIST_PATH}"

echo "DEBUG for Luz:"
echo "Content of /usr/local/tomcat/Lingoport_Data/LRM/staging/importkits/xtm/AVO/UnityClient_L10N/TRANSLATED_KIT_8_pt_pt/LID1138403710_strings_pt_pt.properties"
ls -l /usr/local/tomcat/Lingoport_Data/LRM/staging/importkits/xtm/AVO/UnityClient_L10N/TRANSLATED_KIT_8_pt_pt/LID1138403710_strings_pt_pt.properties
cat /usr/local/tomcat/Lingoport_Data/LRM/staging/importkits/xtm/AVO/UnityClient_L10N/TRANSLATED_KIT_8_pt_pt/LID1138403710_strings_pt_pt.properties


cat "${FULL_LIST_PATH}" | while read -r FILEPATH
do
  FILENAME=`basename $FILEPATH`
  DIRNAME=`dirname $FILEPATH`
  SUFFIX=".properties"
  ROOTNAME=${FILENAME%$SUFFIX}
  TARGET_NAME="${ROOTNAME//_/-}.txt"
  TARGET_PATH="${DIRNAME}/${TARGET_NAME}"
  echo "   Transform [$FILENAME] -> [$TARGET_NAME]"

  rm $TARGET_PATH 2> /dev/null
  touch $TARGET_PATH

  cat $FILEPATH | while read -r LINE
  do
      IFS='=' tokens=( $LINE )
      if [ -z "${tokens[1]}" ]
      then
        echo "${LINE}" >> $TARGET_PATH
      else
        KEY=${tokens[0]}
        VALUE=${LINE#"${KEY}="}
        echo "${KEY},${VALUE}" >> $TARGET_PATH
      fi
  done
IFS=' '
done 
