#!/bin/bash

# Specify the directory to search for files
directory="src/locales/cspSpecific/bell"

# Change to the specified directory
cd "$directory" || exit

# Find all .json files that match the pattern bell_*.json
for old_filename in bell_*.json; do
    # Check if the file exists
    if [[ -e "$old_filename" ]]; then

        # Extract the part before the first underscore and the part after the first underscore
        before_underscore="${old_filename%%_*}"
        
        # Extract the part after the first underscore and before the .json extension
        after_underscore="${old_filename#*_}"
        base_name="${after_underscore%.json}"
        
        # Form the new filename
        new_filename="${base_name}_${before_underscore}.json" 
        # Rename the file
        cp -f "$old_filename" "$new_filename"
        echo "Copied: $old_filename to $new_filename"
    fi
done

