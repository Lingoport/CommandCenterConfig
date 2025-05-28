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
find . -name "respack*.json"  > "${PROJECT_TMP_DIR}/input_files.txt"

echo "Files to transform:"
cat "${PROJECT_TMP_DIR}/input_files.txt"

# 
#
mkdir -p TMP

cat "${PROJECT_TMP_DIR}/input_files.txt" | while read -r INPUT_FILE
do
  BASE=`basename ${INPUT_FILE}`
  DIR=`dirname ${INPUT_FILE}`
  OUTPUT_FILE="${DIR}/tran_${BASE}"
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


  #remove all the 'null' values
  sed -i "s/\": null/\": \"\"/" "$OUTPUT_FILE"
done


