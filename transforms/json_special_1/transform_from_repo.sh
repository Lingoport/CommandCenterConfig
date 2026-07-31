#!/bin/bash
# Specific transformation for the hierarchical en-US.json source file.
#
# Repo format (source of truth):
#     locales/en-US.json   hierarchical / nested JSON, no #reference keys
#     locales/es-XL.json   flat JSON, every key followed by <key>.#reference
#
# LRM OOTB format:
#     locales/en-XL.json   flat JSON, every key followed by <key>.#reference
#
# So this script does, for every en-US.json found in the repo:
#     1. flatten the nested objects into dotted keys
#     2. add the <key>.#reference secondary key right after each string value
#        (for the source file the reference IS the English value)
#     3. write the result next to the original, named en-XL.json
#
# The original en-US.json is left untouched: the LRM file-location-pattern
# is expected to match *-XL.json only, so the repo file is simply ignored.
#
# The following environment variables are set by Command Center:
#   TRANSFORM_DIR      directory holding this script
#   PROJECT_TMP_DIR    temp directory for intermediate files
#   CLIENT_SOURCE_DIR  root of the checked out repository

REPO_SOURCE_NAME="en-US.json"
LRM_SOURCE_NAME="en-XL.json"

echo "=============================================="
echo " Transform from repository: json_special_1"
echo "   $REPO_SOURCE_NAME (nested)  ->  $LRM_SOURCE_NAME (flat + #reference)"
echo "=============================================="

if ! command -v jq > /dev/null 2>&1; then
    echo " Error: jq is required by this transform but was not found."
    exit 1
fi

if [ -n "$CLIENT_SOURCE_DIR" ]; then
    cd "$CLIENT_SOURCE_DIR" || exit 1
fi

INPUT_FILES="${PROJECT_TMP_DIR}/input_files.txt"

# List the repo source files. transform_to_repo.sh reuses this list to clean up
# the en-XL.json files created here, so nothing is left over in the repo.
find . -name "$REPO_SOURCE_NAME" -type f > "$INPUT_FILES"

echo " Files to transform:"
cat "$INPUT_FILES"
echo " ----------------------------------------------"

# Flatten every leaf into a dotted key and duplicate each string value into a
# <key>.#reference entry.
#
# A leaf is a scalar, but also an empty object or an empty array: those carry no
# dotted key of their own and would otherwise be dropped - transform_to_repo.sh
# rewrites en-US.json from this file, so anything dropped here is lost from the
# repository. Array elements are flattened using their index (list.0, list.1).
#
# Keys that already end in .#reference are regenerated rather than nested again,
# so running this transform twice is a no-op.
FLATTEN_JQ='
def leaves($prefix):
    if (type == "object" and length > 0) then
        [ to_entries[] | . as $e | ($e.value | leaves($prefix + [$e.key])) ] | add
    elif (type == "array" and length > 0) then
        [ to_entries[] | . as $e | ($e.value | leaves($prefix + [$e.key | tostring])) ] | add
    else
        [ { key: ($prefix | join(".")), value: . } ]
    end;

if (type == "object" and length == 0) then
    {}
else
    [ leaves([])[]
      | select(.key | endswith(".#reference") | not)
      | .,
        ( select(.value | type == "string")
          | { key: (.key + ".#reference"), value: .value } )
    ]
    | from_entries
end
'

while read -r FILEPATH; do

    [ -z "$FILEPATH" ] && continue

    LRM_FILEPATH="$(dirname "$FILEPATH")/${LRM_SOURCE_NAME}"

    if jq --indent 2 "$FLATTEN_JQ" "$FILEPATH" > "${LRM_FILEPATH}.tmp"; then
        mv -f "${LRM_FILEPATH}.tmp" "$LRM_FILEPATH"
        echo " Created: $LRM_FILEPATH  ($(grep -c '#reference' "$LRM_FILEPATH") reference keys)"
    else
        rm -f "${LRM_FILEPATH}.tmp"
        echo " Error: could not flatten $FILEPATH -- left unchanged"
    fi

done < "$INPUT_FILES"

echo " ----------------------------------------------"
echo " Transform from repository done."
