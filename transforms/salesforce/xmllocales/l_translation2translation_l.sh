#!/bin/bash
#
# 1. Rename files in the form <locale>.translation_meta.xml to translation_meta.<locale>.xml
# 2. Change the comments inside <label> ...</label> to uncomments
#
# Find all the files ending in translation_meta.xml
#
#
find . -name "*.translation-meta.xml" -type f > "${PROJECT_TMP_DIR}/input_files.txt"

cat "${PROJECT_TMP_DIR}/input_files.txt" | while read -r FILEPATH
do
  FILENAME=`basename $FILEPATH`
  DIRNAME=`dirname $FILEPATH`
  SUFFIX=".translation-meta.xml"
  LOCALENAME=${FILENAME%$SUFFIX}
  TARGET_NAME="translation-meta.${LOCALENAME}.xml"
  TARGET_PATH="${DIRNAME}/${TARGET_NAME}"
  echo "    Transform [$FILEPATH] -> [$TARGET_PATH]"

  cp "${FILEPATH}" "${TARGET_PATH}"

  # Remove the comments inside the <label> ...</label>
  sed -i 's/<label><!-- /<label>/'    "${TARGET_PATH}"
  sed -i 's/ --><\/label>/<\/label>/' "${TARGET_PATH}"

done 
