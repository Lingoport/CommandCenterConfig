#!/bin/bash

#
# Copies files under ...en/path/*.dita to ... DITA_RESOURCES/path/en/*.dita
#    and files under ...fr/path/*.dita to ... DITA_RESOURCES/path/fr/*.dita
# etc.

# DITA_DIR must have been configured in dita_properties.sh
. dita_properties.sh
DITA_DIR="$CLIENT_SOURCE_DIR/${DITA_DIR}"
echo "DITA_DIR=${DITA_DIR}"

#
# Extract the locales! A bit of work here.
#
LRM_HOME=`ls -dtp /usr/local/tomcat/lingoport/lrm-server-*  | head -1`
echo " LRM_HOME = $LRM_HOME"

#extract the project group and name, only have the PROJECT_TMP_DIR here
PROJECT_DIR=$(dirname $PROJECT_TMP_DIR)
GP_NAME=$(basename $PROJECT_DIR)
GROUP_NAME="${GP_NAME%%.*}"
PROJECT_NAME="${GP_NAME#*.}"
echo "GROUP_NAME= $GROUP_NAME"
echo "PROJECT_NAME= $PROJECT_NAME"

java -jar "${LRM_HOME}/lrm-cli.jar" -gn "${GROUP_NAME}" -pn "${PROJECT_NAME}" -ep
project_definition="/usr/local/tomcat/Lingoport_Data/LRM/${GROUP_NAME}/reports/${PROJECT_NAME}/ProjectDefinition.xml"
ls -l $project_definition

       	
grep "<file-location-pattern>" "$project_definition" > "${PROJECT_TMP_DIR}/file_location_pattern.txt"

# First only the source locale
grep "</default-locale>" "$project_definition" > "${PROJECT_TMP_DIR}/dita_source_locale.txt"
sed -i 's/.*<default-locale>//' "${PROJECT_TMP_DIR}/dita_source_locale.txt"
sed -i 's/<\/default-locale>//' "${PROJECT_TMP_DIR}/dita_source_locale.txt"

# Then the other locales
grep "</default-locale>" "$project_definition" > "${PROJECT_TMP_DIR}/dita_locales.txt"
grep "</locale>" "$project_definition" >>  "${PROJECT_TMP_DIR}/dita_locales.txt"
grep "</pseudo-locale>" "$project_definition" >>  "${PROJECT_TMP_DIR}/dita_locales.txt"

sed -i 's/.*<default-locale>//' "${PROJECT_TMP_DIR}/dita_locales.txt"
sed -i 's/<\/default-locale>//' "${PROJECT_TMP_DIR}/dita_locales.txt"
sed -i 's/.*<locale>//' "${PROJECT_TMP_DIR}/dita_locales.txt"
sed -i 's/.*<pseudo-locale>//' "${PROJECT_TMP_DIR}/dita_locales.txt"
sed -i 's/<\/locale>//' "${PROJECT_TMP_DIR}/dita_locales.txt"
sed -i 's/<\/pseudo-locale>//' "${PROJECT_TMP_DIR}/dita_locales.txt"

# If the file-location-pattern with dashes -> replaces any underscores with dashes (and vice versa)
if  grep  "<file-location-pattern>l-c-v</file-location-pattern>" "${project_definition}" 
then
  sed -i 's/_/-/' "${PROJECT_TMP_DIR}/dita_locales.txt"
  sed -i 's/_/-/' "${PROJECT_TMP_DIR}/dita_source_locale.txt"
else
  sed -i 's/-/_/' "${PROJECT_TMP_DIR}/dita_locales.txt"
  sed -i 's/-/_/' "${PROJECT_TMP_DIR}/dita_source_locale.txt"
fi

ls -l "${PROJECT_TMP_DIR}/dita_locales.txt"
cat "${PROJECT_TMP_DIR}/dita_locales.txt"

ls -l "${PROJECT_TMP_DIR}/dita_source_locale.txt"
cat "${PROJECT_TMP_DIR}/dita_source_locale.txt"

export SOURCE_LANG=`cat "${PROJECT_TMP_DIR}/dita_source_locale.txt"`
echo "SOURCE_LANG=${SOURCE_LANG}"
echo " "
echo "end locale extraction"
echo " ---------------------------------"

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
