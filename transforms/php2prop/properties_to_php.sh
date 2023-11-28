#!/bin/bash
#
# Special handling for Vanilla's .php files
#
# Find all the files ending in .properties 
#
# The following environment variables need to be set:
#   CLIENT_SOURCE_DIR
#

find . -type d -name locale > "${PROJECT_TMP_DIR}/locale_dirs.txt"
cat "${PROJECT_TMP_DIR}/locale_dirs.txt" | while read -r LOCALE_DIR
do

  echo "LOCALE_DIR = $LOCALE_DIR"


#  find . -name "*\.properties" -type f > ~/tmp/input_files.txt
  
  cat "${FULL_LIST_PATH}" | while read -r FILEPATH
  do
    FILENAME=`basename "$FILEPATH"`
    DIRNAME=`dirname "$FILEPATH"`
    SUFFIX=".properties"
    VANILLANAME=${FILENAME%$SUFFIX}
    ROOTNAME=${VANILLANAME#*vanilla_}
    TARGET_NAME="${ROOTNAME//-/_}.php"
    TARGET_PATH="${DIRNAME}/${TARGET_NAME}"
    echo "    Transform [$FILENAME] -> [$TARGET_NAME]"
    rm $TARGET_PATH 2> /dev/null
    touch $TARGET_PATH
    echo "<?php" > $TARGET_PATH
    echo "" >> $TARGET_PATH
  
    cat $FILEPATH | while read -r LINE
    do
        #echo "--"
        #echo " Length = ${#LINE}"
        if [ ${#LINE} -ge 3 ]
        then
          if [[ $LINE = \#* ]]
          then
            continue
          fi
          #echo "LINE=$LINE"
          KEYB64=${LINE%=*}
          KEYTMP=${KEYB64//_/=}
          KEY=$(echo -ne "$KEYTMP" | base64 -d);
          VALUE=${LINE#*=}
  
          #echo "KEY=-$KEY-"
          #echo "VALUE=$VALUE"
  
          #If we found no keys, nothing to add to the Android file
          echo "\$Definition[\"${KEY}\"] = \"${VALUE}\";" >> "$TARGET_PATH"
        fi
    done
    rm "{FILEPATH}"  
  done
done
