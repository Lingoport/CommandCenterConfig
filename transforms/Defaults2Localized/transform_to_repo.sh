#!/bin/bash
# Simple stripping of the LRM Tag 'transformation'
# before pushing the files to the repo
#
# Here for yml, properties, and json
#
# Requires this variable set:
#   CLIENT_SOURCE_DIR
#

cd "${CLIENT_SOURCE_DIR}"
echo  " ------------------------------------------------"
echo  " Find *.yml, *.properties, *.resx, *.json files "
echo  " ---------------------------------------"

# Find all the files ending in the 'yml' 'properties' or 'json'
TAGFILES="${PROJECT_TMP_DIR}/rm_tag_files.txt"

find . -name "*\.yml" -type f > "$TAGFILES"
find . -name "*\.properties" -type f >> "$TAGFILES"
find . -name "*\.json" -type f >> "$TAGFILES"
find . -name "*\.resx" -type f >> "$TAGFILES"

echo " Candidate Files for LRM Tag Removal"
cat "$TAGFILES"

# For each file simply remove a line if FULL-FILE or CHANGES-ONLY
cat "${TAGFILES}" | while read -r FILEPATH
do
  echo " sed rm LRM Tag line in [${FILEPATH}]"

  # If a line has FULL-FILE, remove it
  sed -i '/FULL-FILE/d' "$FILEPATH"

  # If a line has CHANGES-ONLY, remove it
  sed -i '/CHANGES-ONLY/d' "$FILEPATH"

done
echo  " ------------------------------------------------"
echo " "
