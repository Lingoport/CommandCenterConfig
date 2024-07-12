#!/bin/bash

# Check if an input file is provided
if [[ -z "$1" ]]; then
    echo "Usage: $0 <input_file>"
    exit 1
fi

input_file="$1"
output_file="renamed_${input_file}"

# Process each line in the input file
while IFS= read -r file_path; do

    # Check if the file exists
    if [[ -e "$file_path" ]]; then
        # Extract the directory and filename
        directory=$(dirname "$file_path")
        filename=$(basename "$file_path")
        
        # Extract the part before the first underscore
        before_underscore="${filename%%_*}"
        
        # Extract the part after the first underscore and before the .json extension
        after_underscore="${filename#*_}"
        base_name="${after_underscore%.json}"
        
        # Form the new filename
        new_filename="${base_name}_${before_underscore}.json"
        
        # Form the new file path
        new_file_path="$directory/$new_filename"
        
        # Output the new file path
        echo "$new_file_path"
    else
        echo "File not found: $file_path" >&2
    fi
done < "$input_file" > "$output_file"

echo "Renamed file paths saved to $output_file"

mv -f "$output_file" "$input_file"
