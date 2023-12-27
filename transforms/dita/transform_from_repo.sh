#!/bin/bash

#
# Copies files under ...en/path/*.dita to ... DITA_RESOURCES/path/en/*.dita
#    and files under ...fr/path/*.dita to ... DITA_RESOURCES/path/fr/*.dita
# etc.

env

# TODO later: GET THE PROJECT's ACTUAL LOCALES FROM lrm -ep
export SOURCE_LANG=en
echo "en" > "${PROJECT_TMP_DIR}/dita_locales.txt"
echo "fr" >> "${PROJECT_TMP_DIR}/dita_locales.txt"
echo "de" >> "${PROJECT_TMP_DIR}/dita_locales.txt"
# end TODO

# TODO later: GET THE DIRECTORY above en
DITA_DIR="$CLIENT_SOURCE_DIR/dita/Spectrum"
echo "DITA_DIR=${DITA_DIR}"

cd "$DITA_DIR"
pwd

# Check if required variable is set
if [[ -z "${SOURCE_LANG}" ]]; then
  echo "Error: Please set the SOURCE_LANG variable to the source directory path."
  exit 1
else
  echo "SOURCE_LANG = ${SOURCE_LANG}"
fi

# Destination directory with target language resources
DEST_DIR="${DITA_DIR}/DITA_RESOURCES"

# Create the destination directory if it doesn't exist
mkdir -p "$DEST_DIR"

# Copy the entire directory structure recursively
rsync -avz "${DITA_DIR}/${SOURCE_LANG}/" "$DEST_DIR/"

echo "Successfully duplicated directory structure from '$SOURCE_LANG' to '$DEST_DIR'."

# Remove all .dita and .ditamap from the DITA_RESOURCES directory
find  "$DEST_DIR/" -name "*.dita" -exec rm {} \;
find  "$DEST_DIR/" -name "*.ditamap" -exec rm {} \;

#--------------------------------------------------------------
# For each locale, copy the files to their respective location

while read locale
do

  # find all the dita/ditamap files for a locale
  if [ -d  "${DITA_DIR}/${locale}" ]
  then
    cd  "${DITA_DIR}/${locale}/"
    find  . -name "*.dita" > "${PROJECT_TMP_DIR}/ditaFileList.txt"
    find  . -name "*.ditamap" >> "${PROJECT_TMP_DIR}/ditaFileList.txt"

    while read file
    do
      # Copy files with specific extensions within current directory
      mkdir -p "$DEST_DIR/$(dirname "$file")/${locale}"
      new_file="$DEST_DIR/$(dirname "$file")/${locale}/$(basename "$file")"
      relative_path="./$(dirname "$file")/${locale}/$(basename "$file")"
      echo " Transform [ ${file} ] -> ${relative_path}"
      cp "$file" "$new_file"

    done < "${PROJECT_TMP_DIR}/ditaFileList.txt"

    echo "Successfully duplicated directory structure and copied specific files:"
    echo "   from '${DITA_DIR}/${locale}' "
    echo "   to   '$DEST_DIR'"
  else
    echo "${DITA_DIR}/${locale} does not exist: not file copy for ${locale}"
  fi
done < "${PROJECT_TMP_DIR}/dita_locales.txt"
