#!/bin/bash
# transforms tran_<file>.json into <file>.json
#
echo  " ------------------------------------------------"
echo  " Current pwd:"
pwd

echo "Files to transform: "
cat "${FULL_LIST_PATH}"

cat "${FULL_LIST_PATH}" | while read -r FILEPATH
do
  TARGET_PATH="${FILEPATH//AAREVIEWZZ/}"
  echo "   Transform [$FILEPATH] -> [$TARGET_PATH]"

  # copy the reviewed file to the source file
  cp "$FILEPATH" "$TARGET_PATH"

done

