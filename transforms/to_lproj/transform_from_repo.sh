#!/bin/bash

# copy locale_staging/en/* to locale_staging/en.lproj/. (fr, es, etc.)
# Make sure not to copy en.lproj to en.lproj.lproj, etc.
echo " Copy locale_staging/<locale>/* to locale_staging/<locale>.lproj/"

# Set the root directory
ROOT_DIR="locale_staging"

# Find language directories (one level deep), excluding *.lproj
find "$ROOT_DIR" -type d -mindepth 1 -maxdepth 1 ! -name "*.lproj" | while read lang_dir; do
    lang_code=$(basename "$lang_dir")
    dest_dir="$(dirname "$lang_dir")/${lang_code}.lproj"

    echo "Copying contents of $lang_dir to $dest_dir"

    mkdir -p "$dest_dir"
    cp -r "$lang_dir"/* "$dest_dir"/
done


