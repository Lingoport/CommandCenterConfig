#!/bin/bash
echo "To be written. For now, here so that the transform_from_repo can be tested"

# TODO: define the locales, the top level directory under which the en/fr/.. are located, 
# and the DITA_RESOURCES
cd "${CLIENT_SOURCE_DIR}"
DITA_TRANSFORMED_DIR=$(find . -name DITA_RESOURCES)
# Define source and destination directories
DITA_ORIGIN=$(basename "${CLIENT_SOURCE_DIR}")

# Find all DITA and DITAMAP files in the source directory
find "$DITA_TRANSFORMED_DIR" -type f \( -name "*.dita" -o -name "*.ditamap" \) | while IFS= read -r file; do
  # Extract relative path without extension
  fullpath=${file##*DITA_RESOURCES/}

  ditafile=$(basename "$fullpath")
  localepath=$(dirname "$fullpath")
  locale=$(basename "$localepath")
  path=$(dirname "$localepath")

  echo "path=$path"
  echo "locale=$locale"

  # Construct destination path
  dest="$DITA_ORIGIN/$locale/$path"

  # Create any missing directories in the destination path
  mkdir -p "$(dirname "$DITA_ORIGIN")"

  # Copy the file
  #cp "$fullpath" "$dest"

  # Print informative message
  echo "Copied $fullpath to $dest"
done

echo "Dita and Ditamap files copied successfully!"

