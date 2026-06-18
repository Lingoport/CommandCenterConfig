#!/usr/bin/env bash
#
# show_prepkit_files.sh
#
# Takes GROUP, PROJECT, and KIT, locates the first subdirectory under
#   ~/Lingoport_Data/L10nStreamlining/$GROUP/projects/$PROJECT/prepkits/PREP_KIT_$KIT
# and prints the title (filename) and content of every file in it.
#
# Usage:
#   GROUP=billbkinney PROJECT=Skynet_main KIT=9 ./show_prepkit_files.sh
#   ./show_prepkit_files.sh billbkinney Skynet_main 9
#
# Positional args take precedence over env vars; env vars take precedence
# over the defaults below.

set -euo pipefail

GROUP="${1:-${GROUP:-billbkinney}}"
PROJECT="${2:-${PROJECT:-Skynet_main}}"
KIT="${3:-${KIT:-9}}"

BASE_DIR="${HOME}/Lingoport_Data/L10nStreamlining/${GROUP}/projects/${PROJECT}/prepkits/PREP_KIT_${KIT}"

if [[ ! -d "$BASE_DIR" ]]; then
    echo "Error: directory not found: $BASE_DIR" >&2
    exit 1
fi

# "First directory" = first subdirectory, sorted alphabetically.
TARGET_DIR=$(find "$BASE_DIR" -mindepth 1 -maxdepth 1 -type d | sort | head -n 1)

if [[ -z "$TARGET_DIR" ]]; then
    echo "Error: no subdirectories found under $BASE_DIR" >&2
    exit 1
fi

echo "Using directory: $TARGET_DIR"
echo "========================================"

# Iterate over each file (not subdirectory) in the target directory,
# sorted alphabetically, NUL-delimited so filenames with spaces are safe.
while IFS= read -r -d '' file; do
    title=$(basename "$file")
    echo ""
    echo "Title: $title"
    echo "----------------------------------------"
    cat "$file"
    echo ""
    echo "========================================"
done < <(find "$TARGET_DIR" -mindepth 1 -maxdepth 1 -type f -print0 | sort -z)
