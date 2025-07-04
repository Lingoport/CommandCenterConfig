#!/bin/bash
#
# Copy the files from <locale>.lproj/* to <locale>/
#
echo  " ------------------------------------------------"
echo  " Current pwd:"
pwd
echo  "  Copy the files from <locale>.lproj/translation.strings <locale>/translation.strings"

echo "Files to transform (copy): "
cat "${FULL_LIST_PATH}"

export LPROJ=".lproj"

cat "${FULL_LIST_PATH}" | while read -r FILEPATH
do

  TARGET_PATH="${FILEPATH//$LPROJ/}"
  TARGET_DIR=$(dirname $TARGET_PATH)
  mkdir -p "${TARGET_PATH}"
  echo " Copy [${FILEPATH}] to [$TARGET_PATH]"

  cp "${FILEPATH}" "${TARGET_PATH}"

done

