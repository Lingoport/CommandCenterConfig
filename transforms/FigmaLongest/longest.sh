#!/bin/bash
#
# Create the 'longest' translation under
#   locales/af/translation.json
#            Note: af is hard-coded as the 'longest' locale
#
# The Figma Lingoport plugin interacts with a repository.
# In the repository, the .json file coming from Figma is located under:
#    locales/en/translation.json
#
# The translations are located under 
#   locales/fr/translation.json
#   locales/de/translation.json
#   locales/ja/translation.json
#   etc.
# The pseudo locale is typically eo, so
#   locales/eo/translation.json
#
# The goal of this script is to find the longest value for each key in the translated files
# and overwrite one of the target locales with that longest file.
# 
# This script creates a temporary 'longest.json' which will be copied over to that 
# longest locale.
#
# Note: This cannot be overwriting 'eo' as pseudo-loc happens as a separate process
#       and the pseudo-loc would end up winning/overwriting the longest file.
#
# Author: Olivier Libouban
# Copyright (c) Lingoport 2023

# Top-level directory containing subdirectories with JSON files
TOP_DIRECTORY=$1
echo "TOP_DIRECTORY=${TOP_DIRECTORY}"

# Associative array to store the longest value for each key
declare -A longest_values

# Function to process each JSON file
process_file() {
    local file=$1
    echo "Processing file: $file"  # Debugging statement
    while IFS= read -r line; do
        key=$(echo "$line" | sed -E 's/(.*)\:.*$/\1/' | sed -e 's/^ *"\(.*\)" *$/\1/')
        value=$(echo "$line" | sed -E 's/.*\:(.*)$/\1/' | sed -e 's/^ *"\(.*\)" *,* *$/\1/' -e "s/'/\\\'/g")

        echo "Key: $key, Value: $value"  # Debugging statement

        if [ "${#value}" -gt "${#longest_values[$key]}" ]; then
            longest_values[$key]=$value
            echo "Updated longest value for $key: ${longest_values[$key]}"  # Debugging statement
        fi
    done < <(jq -r 'to_entries|map("\(.key):\(.value)")|.[]' "$file") # Use process substitution
}

# Find and process each JSON file in the subdirectories, excluding "en" and "eo" directories
while IFS= read -r file; do
    process_file "$file"
done < <(find "$TOP_DIRECTORY" -type f -name '*.json' ! -path "$TOP_DIRECTORY/en/*" ! -path "$TOP_DIRECTORY/eo/*") # Use process substitution

# Check if longest_values array is populated
echo "Checking the contents of longest_values array..."  # Debugging statement
for key in "${!longest_values[@]}"; do
    echo "Key: $key, Longest Value: ${longest_values[$key]}"  # Debugging statement
done

# Create the longest.json file with the longest values
echo "{" > longest.json
for key in "${!longest_values[@]}"; do
    value=$(echo "${longest_values[$key]}" | sed "s/'/\\\'/g")
    echo "  \"$key\": \"$value\"," >> longest.json
done
sed -i '$ s/,$//' longest.json  # Remove trailing comma from the last line
echo "}" >> longest.json

echo "Created longest.json with the longest values for each key."

# Move the longest.json file over to the 'af' directory as translation.json
mkdir -p "$1/af"
mv longest.json "$1/af/translation.json"
