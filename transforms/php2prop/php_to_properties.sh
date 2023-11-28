#!/bin/bash
#
# Special handling for Vanilla's .php files
#
# Find all the files ending in .php under a locale directory, not all php!
#
# The following environment variables need to be set:
#   CLIENT_SOURCE_DIR
#

find . -type d -name locale > "${PROJECT_TMP_DIR}/locale_dirs.txt"
cat "${PROJECT_TMP_DIR}/locale_dirs.txt" | while read -r LOCALE_DIR
do

  echo "LOCALE_DIR = $LOCALE_DIR"

  find "$LOCALE_DIR" -name "*\.php" -type f > "${PROJECT_TMP_DIR}/input_files.txt"
  
  cat "${PROJECT_TMP_DIR}/input_files.txt" | while read -r FILEPATH
  do
    echo "FILEPATH=$FILEPATH"
    FILENAME=`basename "$FILEPATH"`
    DIRNAME=`dirname "$FILEPATH"`
    SUFFIX=".php"
    ROOTNAME=${FILENAME%$SUFFIX}
    TARGET_NAME="vanilla_${ROOTNAME//-/_}.properties"
    TARGET_PATH="${DIRNAME}/${TARGET_NAME}"
    echo "    Transform [$FILENAME] -> [$TARGET_NAME]"
    rm $TARGET_PATH 2> /dev/null
    touch $TARGET_PATH
  
    cat $FILEPATH | while read -r LINE
    do
        # Remove any <php type string from the file
        if [[ "$LINE" == *"<?php"* ]]
        then
          continue
        fi
  
        #echo "--"
        #echo " Length = ${#LINE}"
        if [ ${#LINE} -ge 3 ]
        then
        LINEWITHOUTPREFIX=${LINE#*\"}
        LINEWITHOUTSUFFIX=${LINEWITHOUTPREFIX%\"*}
  
        KEYPART=${LINEWITHOUTPREFIX%"] ="*}
        KEYTMP=${KEYPART%\"*}
        KEYB64=$(echo -ne "$KEYTMP" | base64 -w 0);
        KEY=${KEYB64//=/_}
        
        #echo "KEY=$KEY"
  
        VALUEPART=${LINEWITHOUTPREFIX#*"] = \""}
        VALUE=${VALUEPART%\"*}
        #echo "VALUE=$VALUE"
  
        #If we found no keys, nothing to add to the Android file
          echo "${KEY}=${VALUE}" >> "$TARGET_PATH"
        fi
    done
  
  done
done
