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
  FILENAME=`basename $FILEPATH`
  DIRNAME=`dirname $FILEPATH`
  TARGET_NAME="${FILENAME#tran_}"
  TARGET_PATH="${DIRNAME}/${TARGET_NAME}"
  echo "   Transform [$FILEPATH] -> [$TARGET_PATH]"

  # get the target file ready
  cp "$FILEPATH" "$TARGET_PATH"

  # change the keys to remove the prefix "_tran-" 
  #
  sed -i "s/\"_tran-/\"/" "$TARGET_PATH"

  # also add a couple more spaces at the beginning of each
  # key/value pair to be more like the original file
  sed -i "s/^  \"/    \"/" "$TARGET_PATH"

done

