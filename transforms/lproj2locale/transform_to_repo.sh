#!/bin/bash

# Loop through all directories that do not end with .lproj and are not named "en"
find .  -name '*.stringsdict' | while read -r stringsdictFile; do

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

    # Check if the .lproj directory exists, if not skip to the next locale directory
    if [ ! -d "$lprojPath" ]; then
        echo "Directory $lprojPath does not exist, skipping $candidatePath"
        continue
    fi

    # Loop through all .stringsdict files in the locale directory
    find "$candidatePath" -type f -name '*.stringsdict' | while read -r file; do
        # Copy the file to the .lproj directory
        cp "$file" "$lprojPath"
        echo "Copied $file to $lprojPath"
    done
done
