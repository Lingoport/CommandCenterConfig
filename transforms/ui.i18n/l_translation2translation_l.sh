# JE This transforms the files coming from the repo!!!!
#!/bin/bash
#
# Special handling for .txml files
#
# Find all the files ending in .json and move them to .txml
# The following environment variables need to be set:
#   CLIENT_SOURCE_DIR
#

echo  " ------------------------------------------------"
echo  " Find *.json files "
echo  " ---------------------------"

# Find all the files ending in the 'xml'
JSONFILES="${PROJECT_TMP_DIR}/input_files.txt"

find . -name "*_resourcemanagement.ui.i18n.json" -type f > "$JSONFILES"

echo "Files to transform: "
cat "$JSONFILES"

# For each file to transform, create as many subfiles,
# one per Context and one for strings outside context elements
cat "${JSONFILES}" | while read -r FILEPATH
do
  FILENAME=`basename "$FILEPATH"`
  DIRNAME=`dirname "$FILEPATH"`
  SUFFIX="_resourcemanagement.ui.i18n.json"
  LOCALENAME=${FILENAME%$SUFFIX}
  TARGET_NAME="resourcemanagement.ui.i18n_${LOCALENAME}.json"
  TARGET_PATH="${DIRNAME}/${TARGET_NAME}"
  echo "    Transform [$FILEPATH] -> [$TARGET_PATH]"

  cp "${FILEPATH}" "${TARGET_PATH}"

  # Remove the comments inside the <label> ...</label>
  sed -i 's/<label><!-- /<label>/'    "${TARGET_PATH}"
  sed -i 's/ --><\/label>/<\/label>/' "${TARGET_PATH}"
done

