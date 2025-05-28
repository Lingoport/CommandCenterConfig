#!/bin/bash
#
echo "${0}"
#env
echo "TRANSFORM_DIR=${TRANSFORM_DIR}"

if [[ -z "$CLIENT_SOURCE_DIR" ]] ; then
    export CLIENT_SOURCE_DIR="$WORKSPACE"
fi
cd "${CLIENT_SOURCE_DIR}"

#
# 
find . -name "x3-services_x3-purchasing*.json"  > "${PROJECT_TMP_DIR}/input_files.txt"

echo "Files to transform:"
cat "${PROJECT_TMP_DIR}/input_files.txt"

# 
#

cat "${PROJECT_TMP_DIR}/input_files.txt" | while read -r INPUT_FILE
do
  TMP_FILE=$(mktemp)
  BASE=`basename ${INPUT_FILE}`
  DIR=`dirname ${INPUT_FILE}`
  OUTPUT_FILE="${DIR}/tran_${BASE}"
  echo "INPUT_FILE = ${INPUT_FILE}"
  echo "OUTPUT_FILE= ${OUTPUT_FILE}"

  # Use jq to transform the JSON
  jq 'with_entries(
    if (.key | contains("data_types__"))
    then {key: ("_" + .key), value: .value}
    else .
    end
  )' "$INPUT_FILE" > "$TMP_FILE"

  jq 'with_entries(
    if (.key | contains("nodes__"))
    then {key: ("_" + .key), value: .value}
    else .
    end
  )' "$TMP_FILE" > "$OUTPUT_FILE"

  rm "$TMP_FILE"


  sed -i "s/\": null/\": \"\"/" "$OUTPUT_FILE"
done


