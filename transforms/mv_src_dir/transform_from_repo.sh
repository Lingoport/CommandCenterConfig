#!/bin/bash
# Move the source locale repo under a given directory
# where all translations are done.
#
# For example:
#   move locales/en-US/* under translated/en-US/.
#
# On the way back, nothing to do since the translated files
# will be under translated/<locale_code>/
#
echo "${0}"
#env
echo "TRANSFORM_DIR=${TRANSFORM_DIR}"

if [[ -z "$CLIENT_SOURCE_DIR" ]] ; then
    export CLIENT_SOURCE_DIR="$WORKSPACE"
fi
cd "${CLIENT_SOURCE_DIR}"
find . -name "en_US" -type d > "${PROJECT_TMP_DIR}/input_files.txt"

echo "Directories to move:"
cat "${PROJECT_TMP_DIR}/input_files.txt"
# List the location where en_US appears as a directory

cat "${PROJECT_TMP_DIR}/input_files.txt" | while read -r sourceDir
do
  echo "sourceDir = ${sourceDir}"
  translated_dir="$(dirname "$sourceDir")/translations"
  echo "translated_dir = ${translated_dir}"
  mkdir -p "$translated_dir"
  echo "Copy ${sourceDir} to ${translated_dir}"
  cp -r "${sourceDir}" "${translated_dir}/."
  ls "$translated_dir"
done


