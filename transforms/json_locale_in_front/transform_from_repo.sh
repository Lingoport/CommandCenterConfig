#!/bin/bash

# Specify the directory to search for files
directory="src/locales/cspSpecific/bell"

# Change to the specified directory
cd "$directory" || exit

# Find all .json files that match the pattern *_*.json
for old_filename in *_*.json; do
    # Check if the file exists
    if [[ -e "$old_filename" ]]; then
        # Extract the part before the last underscore and the part after the last underscore
        before_last_underscore="${old_filename%_*}"
        after_last_underscore="${old_filename##*_}"
        
        # Form the new filename
        new_filename="${after_last_underscore%.json}_${before_last_underscore}.json"
        
        # Rename the file
        cp "$old_filename" "$new_filename"
        echo "Moved: $old_filename to $new_filename"
    fi
done
