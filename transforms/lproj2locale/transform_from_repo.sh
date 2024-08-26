#!/bin/bash

# Find all .lproj directories in the directory structure
find . -type d -name '*.lproj' | while read -r lproj_dir; do
    # cut off .lproj, you get a directory with a locale at the same level
    localeDir="${lproj_dir%.lproj}"

    # Check if the locale directory exists, if not create it
    if [ ! -d "$localeDir" ]; then
        mkdir "$localeDir"
    fi

    # make sure that directory is clean, no stragglers from previous runs
    rm "${localeDir}"/* 2> /dev/null

    # Loop through all files ending in .stringsdict within the .lproj directory
    find "$lproj_dir" -type f -name '*.stringsdict' | while read -r file; do

        # Copy the file to the locale directory
        cp "$file" "$localeDir"
        echo "Copied $file to $localeDir"
    done
done

