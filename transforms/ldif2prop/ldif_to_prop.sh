#!/bin/bash
#
# Special handling for ev .txt files
#
# Find all the files ending in .txt and move them to .properties
# Use the DN: line to create a key for the next line
#
#
SUFFIX="txt"

echo  " ------------------------------------------------"
echo  " Find *.${SUFFIX} files "
echo  " ---------------------------"

# Find all the files ending in the 'yml'
find . -name "*\.txt" -type f > "${PROJECT_TMP_DIR}/input_files.txt"

echo "Files to transform: "
cat "${PROJECT_TMP_DIR}/input_files.txt"

cat "${PROJECT_TMP_DIR}/input_files.txt" | while read -r FILEPATH
do

  TARGET_PATH="${FILEPATH%$SUFFIX}properties"
  echo " Transform [${FILEPATH}] to [$TARGET_PATH]"

  rm $TARGET_PATH 2> /dev/null
  touch $TARGET_PATH

  cat $FILEPATH | while read -r LINE
  do

      # Check if the LINE starts with DN, which is going to be the key
      if [ "${LINE:0:2}" = DN ]
      then

        echo "#${LINE}" >> "$TARGET_PATH"
        DNLINE="${LINE:4}"
        IFS=',' tokens=( $DNLINE )

        CNTOKEN=${tokens[0]}
        OUTOKEN=${tokens[1]}

        if [ -z "${tokens[1]}" ]
        then
          echo "${LINE}" >> $TARGET_PATH
        fi
      else
        if [ "${LINE:0:10}" = plasecName ]
        then
          LINE="${LINE/plasecName: /plasecName:}"
          echo "plasecName_${CNTOKEN/=/_}_${OUTOKEN/=/_}=${LINE#*\:}" >> "$TARGET_PATH"
          #echo "${CNTOKEN/=/_}_${OUTOKEN/=/_}.${LINE/\: /=}" >> "$TARGET_PATH"

        else
          if [ "${LINE:0:18}" = plasecpointRtnname ]
          then
            LINE="${LINE/plasecpointRtnname: /plasecpointRtnname:}"
            echo "plasecpointRtnname_${CNTOKEN/=/_}_${OUTOKEN/=/_}=${LINE#*\:}" >> "$TARGET_PATH"
          else
            echo "" >> "$TARGET_PATH"
          fi

        fi
      fi
  done

IFS=' '

done

