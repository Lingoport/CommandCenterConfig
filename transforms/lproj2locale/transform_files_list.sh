#!/bin/bash
#
# Check if an input file is provided
if [[ -z "$1" ]]; then
    echo "Usage: $0 <input_file>"
    exit 1
fi

input_file="$1"
output_file="${input_file}_renamed"

# Create or clear the output file
> "$output_file"

# For stringsdict files, change the location as per the transform
# back to the lproj type directories. 
# For any other file, keep it as is. 
while IFS= read -r line; do
    if [[ "$line" == *"stringsdict" ]]; then
        # Extract the directory path and the file name
        dir_path=$(dirname "$line")
        file_name=$(basename "$line")


        # Construct the new path
        new_dir_path="${dir_path}.lproj"
        new_line="$new_dir_path/$file_name"

        # Write the new path to the output file
        echo "$new_line" >> "$output_file"
    else
        echo "$line" >> "$output_file"     
    fi
done < "$input_file"

echo "Move to ${input_file}"

mv -f "$output_file" "$input_file"

ls -l "$input_file"
cat "$input_file"
