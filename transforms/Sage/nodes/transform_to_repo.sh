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
  echo "   Transform [$FILENAME] -> [$TARGET_NAME]"

  cp "$FILENAME" "$TARGET_NAME"
  sed -i "s/\"_tran-//" "$TARGET_NAME"
done

