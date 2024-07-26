#!/bin/bash

echo "==========================="
echo "$FULL_LIST_PATH"
cat "$FULL_LIST_PATH"
echo "==========================="

# Loop through the list of files from the $FULL_LIST_PATH as those are 
# the only files to move to the directory
while read stringsdictFile; do

    # Find the directory name
    candidatePath=$(dirname $stringsdictFile)

    # if the directory is an lproj, skip
    candidateDir=$(basename $candidatePath)

    if [[ "$candidateDir" == *lproj ]]
    then
            continue
    fi

    if [[ "$candidateDir" == "en" ]]
    then
            echo "skip ${candidateDir} : that's an source 'en'. do not copy over en.lproj"
            continue
    fi


    # Define the corresponding .lproj directory
    lprojPath="${candidatePath}.lproj"

    # Check if the .lproj directory exists, if not make it
    if [ ! -d "$lprojPath" ]; then
	mkdir "$lprojPath" 
    fi

    # Loop through all .stringsdict files in the locale directory
    find "$candidatePath" -type f -name '*.stringsdict' | while read -r file; do
        # Copy the file to the .lproj directory
        cp "$file" "$lprojPath"
        echo "Copied $file to $lprojPath"
    done
done < "$FULL_LIST_PATH"
