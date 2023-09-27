#!/bin/bash
#
#
# the .properties comment should be the DN : line above the actual k/v pair
#
#
echo  " ------------------------------------------------"
echo  " Current pwd:"
pwd

echo "Files to transform: " 
cat "${FULL_LIST_PATH}"


cat "${FULL_LIST_PATH}" | while read -r FILEPATH
do

  TARGET_PATH="${FILEPATH%$SUFFIX}txt"
  echo " Transform [${FILEPATH}] to [$TARGET_PATH]"

  rm $TARGET_PATH 2> /dev/null
  touch $TARGET_PATH

  cat $FILEPATH | while read -r LINE
  do

      # Check if the LINE starts with #DN.
      # if so, it will become the DN :  line above the value
      if [ "${LINE:0:3}" = \#DN ]
      then
        # Alpha: Add a blank line between DN stanzas.
        # The first line in the file is removed below.
        # to keep this logic cleaner: See Beta
        echo "" >> "$TARGET_PATH"
        echo "${LINE:1}" >> "$TARGET_PATH"
      else
        if [ "${LINE:0:10}" = "plasecName" ]
        then
          echo "plasecName: ${LINE#*=}" >> "$TARGET_PATH"
        else
          if [ "${LINE:0:18}" = "plasecpointRtnname" ]
          then
            echo "plasecpointRtnname: ${LINE#*=}" >> "$TARGET_PATH"
          fi

        fi
      fi
  done

  # Beta: Remove the first blank line (see Alpha above)
  sed -i "1d" "$TARGET_PATH"

  # And add one empty line at the end of the file to be precise
  echo "" >>  "$TARGET_PATH"

IFS=' '

done

