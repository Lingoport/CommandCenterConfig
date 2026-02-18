# This transforms the files going into the repo
#!/bin/bash
#!/bin/bash
#
# 1. Rename files in the form resourcemanagement.ui.i18n_<locale>.json to  <locale>_resourcemanagement.ui.i18n.json
#
# Find all the files starting in resourcemanagement.ui.i18n
#
JSONFILES="${PROJECT_TMP_DIR}/input_files.txt"

find . -name "resourcemanagement.ui.i18n_*.json" -type f > "${JSONFILES}"

cat "${JSONFILES}" | while read -r FILEPATH
do
  FILENAME=`basename "$FILEPATH"`
  DIRNAME=`dirname "$FILEPATH"`
  SUFFIX=".json"
  ROOTNAME=${FILENAME%$SUFFIX}
  LOCALENAME=${ROOTNAME#resourcemanagement.ui.i18n_*}
  TARGET_NAME="${LOCALENAME}_resourcemanagement.ui.i18n.json"
  TARGET_PATH="${DIRNAME}/${TARGET_NAME}"
  ## BUT NOT THE en_US FILE!!!
  if [ "$LOCALENAME" == "en" ]; then
    echo "    Do not transform back ${FILEPATH}"
  
  else
    echo "    Transform [$FILEPATH] -> [$TARGET_PATH]"
    cp "${FILEPATH}" "${TARGET_PATH}"
  fi
done

