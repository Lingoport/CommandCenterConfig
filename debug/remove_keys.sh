#!/bin/bash
#
# This script finds a string in en.json, looks up the corresponding key, and remove the key/value in 
# all the other .json files (but not en.json)
#
# The script checks if a string parameter is provided.
# It uses jq to find the key corresponding to the provided string in en.json by checking if the value contains the search string.
# If the key is found, it loops through all .json files except en.json.
# For each file, it removes the key using jq and updates the file.

# BEWARE ==========
# However, this has issues with json block (hierarchies of key/value pairs). So for the specific case with PPG, 
# the email block first needs to be removed from the en.json file. So best to do that in a temp directory
# and then copy the translated files (not the en.json file) on the actual workspace before git commit/add/push
#

# Ensure a string parameter is provided
if [ -z "$1" ]; then
  echo "Usage: $0 <string>"
  exit 1
fi

search_string="$1"

# Extract all keys from en.json that contain the search string in their value
keys=$(jq -r --arg search_string "$search_string" 'to_entries | map(select(.value | contains($search_string))) | .[].key' en.json)

# Check if any keys were found
if [ -z "$keys" ]; then
  echo "No keys found with value containing '$search_string' in en.json"
  exit 1
fi

echo "Keys found: $keys"

# Loop through all json files except en.json and remove the keys
for key in $keys; do
  for file in *.json; do
    if [ "$file" != "en.json" ]; then
      jq "del(.\"$key\")" "$file" > "tmp.json" && mv "tmp.json" "$file"
      echo "Removed key '$key' from $file"
    fi
  done
done

echo "Done."

