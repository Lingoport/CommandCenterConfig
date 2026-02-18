# This transforms the files going into the repo
#!/bin/bash
#!/bin/bash
#
# 1. Rename files in the form resourcemanagement.ui.i18n_<locale>.json to  <locale>_resourcemanagement.ui.i18n.json
#
# Find all the files starting in resourcemanagement.ui.i18n
#
#
echo "=============================================="
echo "Transform to repository: ui.i18n"
echo "$FULL_LIST_PATH"
cat "$FULL_LIST_PATH"
echo "=============================================="

cat "${FULL_LIST_PATH}" | while read -r FILEPATH
do
  FILENAME=`basename "$FILEPATH"`
  DIRNAME=`dirname "$FILEPATH"`

  # Extract locale and the rest of the filename
  LOCALE=$(echo "$FILENAME" | grep -oP '(?<=ui\.i18n_).*(?=\.json)')
  REST=$(echo "$FILENAME" | sed "s/\(.*\)\.ui\.i18n_${LOCALE}\.json/\1/")

  # Construct the new filename
  TARGET_NAME="${LOCALE}_${REST}.ui.i18n.json"
  TARGET_PATH="${DIRNAME}/${TARGET_NAME}"
  ## BUT NOT THE en FILE!!!
  if [ "$LOCALE" == "en" ]; then
    echo "    Do not transform back ${FILEPATH}"
  
  else
    echo "    Transform [$FILEPATH] -> [$TARGET_PATH]"
    cp "${FILEPATH}" "${TARGET_PATH}"
  fi
done

