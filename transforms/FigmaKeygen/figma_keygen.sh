#!/bin/bash
#
# Create the 'keys' resource file under locales/keys/translation.json
#
# The Figma Lingoport plugin interacts with a repository.
# In the repository, the base .json file coming from Figma is located under:
#    locales/en/translation.json
#
# The translations are located under locales/*/translation.json
# The pseudo locale is typically eo, so locales/eo/translation.json
#
# Note: This cannot be overwriting 'eo' as pseudo-loc happens as a separate process
#       and the pseudo-loc would end up winning/overwriting the keys file.
#
# Author: Ryan Than
# Copyright (c) Lingoport 2025

# Top-level directory containing subdirectories with JSON files
TOP_DIRECTORY=$1
echo "TOP_DIRECTORY=${TOP_DIRECTORY}"

# Associative array to store the keys
declare -A keysArray

# For now, process the base English resource file and use the node IDs as the keys
# TODO: Once unique keys are generated (or context keys), use those instead

echo "Processing file:"
while IFS= read -r line; do
    # key=$(echo "$line" | sed -E 's/(.*)\:.*$/\1/' | sed -e 's/^ *"\(.*\)" *$/\1/')
    key=$(echo "$line" | sed 's/^[^"]*"\([^"]*\)".*/\1/')
    value=$key

    # echo "Key: $key, Value: $value"  # Debugging statement

    if [ "${#value}" -gt "${#keysArray[$key]}" ]; then
        keysArray[$key]=$value
        echo "Updated key value for $key: ${keysArray[$key]}"  # Debugging statement
    fi
done < "$TOP_DIRECTORY/en/translation.json"

# Check if keysArray array is populated
echo "Checking the contents of keysArray array..."  # Debugging statement
for key in "${!keysArray[@]}"; do
    echo "Key: $key, Value: ${keysArray[$key]}"  # Debugging statement
done

# Create the keys.json file
echo "{" > keys.json
for key in "${!keysArray[@]}"; do
    value=$(echo "${keysArray[$key]}" | sed "s/'/\\\'/g")
    echo "  \"$key\": \"$value\"," >> keys.json
done
sed -i '$ s/,$//' keys.json  # Remove trailing comma from the last line
echo "}" >> keys.json

# Move the keys.json file over to the 'keys' directory as "translation.json" (to display keys in Figma file)
mkdir -p "$1/keys"
mv keys.json "$TOP_DIRECTORY/keys/translation.json"

echo "Created translation.json for \"keys\" locale, file path: \"$1/keys/translation.json\""