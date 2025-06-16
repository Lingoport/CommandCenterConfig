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

  # change the "_title" keys into "title" 
  #
  sed -i "s/\"_title\"/\"title\"/" "$TARGET_PATH"

  # change the "_description" keys into "description" 
  #
  sed -i "s/\"_description\"/\"description\"/" "$TARGET_PATH"

done

