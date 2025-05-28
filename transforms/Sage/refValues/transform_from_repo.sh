#!/bin/bash
#
echo "${0}"
#env
echo "TRANSFORM_DIR=${TRANSFORM_DIR}"

if [[ -z "$CLIENT_SOURCE_DIR" ]] ; then
    export CLIENT_SOURCE_DIR="$WORKSPACE"
fi
cd "${CLIENT_SOURCE_DIR}"

# Find the en_US directory locations, but not those under 'translations'
# as they should not be 'recursively' be copied (after each run)
find . -name "respack*.json"  > "${PROJECT_TMP_DIR}/input_files.txt"

echo "Files to transform:"
cat "${PROJECT_TMP_DIR}/input_files.txt"

# List the location where en_US appears as a directory

cat "${PROJECT_TMP_DIR}/input_files.txt" | while read -r INPUT_FILE
do
  OUTPUT_FILE="TRAN_${INPUT_FILE}"
  echo "INPUT_FILE = ${INPUT_FILE}"
  echo "OUTPUT_FILE= ${OUTPUT_FILE}"

  # Use jq to transform the JSON
  jq 'to_entries |
    map({
      key: .key,
      value: (
        .value + {
          refValues: (
            {
              _title: .value.refValues.title,
              _description: .value.refValues.description
            }
          )
        } | del(.refValues.title, .refValues.description)
      )
    }) | from_entries' "$INPUT_FILE" > "$OUTPUT_FILE"

done


