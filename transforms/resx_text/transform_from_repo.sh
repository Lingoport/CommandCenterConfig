#!/bin/bash
# Transform source (no-locale) .resx files into .en.resx files containing only .Text entries.
# Example: AboutForm.resx -> AboutForm.en.resx

echo " ------------------------------------------------"
echo " Current pwd:"
pwd

# Match files with one dot (e.g. AboutForm.resx) — excludes locale files like AboutForm.de.resx
find . -name "*.resx" -not -name "*.*.*" -type f > "${PROJECT_TMP_DIR}/input_files.txt"

echo "Files to transform:"
cat "${PROJECT_TMP_DIR}/input_files.txt"

while IFS= read -r FILEPATH; do
  FILENAME=$(basename "$FILEPATH")
  DIRNAME=$(dirname "$FILEPATH")
  BASENAME="${FILENAME%.resx}"
  TARGET_PATH="${DIRNAME}/${BASENAME}.en.resx"

  echo "    Transform [$FILEPATH] -> [$TARGET_PATH]"

  {
    printf "<?xml version='1.0' encoding='utf-8'?>\n"
    printf "<root>\n"

    awk '
      /[[:space:]]*<data name="[^"]*\.Text"/ { in_block=1 }
      in_block { print }
      in_block && /[[:space:]]*<\/data>/     { in_block=0 }
    ' "$FILEPATH"

    printf "</root>\n"
  } > "$TARGET_PATH"

done < "${PROJECT_TMP_DIR}/input_files.txt"
