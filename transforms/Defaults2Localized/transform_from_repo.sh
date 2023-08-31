#!/bin/bash


(
    cd "$CLIENT_SOURCE_DIR"
    while read -r base_dir ; do
        translated_dir="$(dirname "$base_dir")/LocalizedResources"
        mkdir -p "$translated_dir"
        set -x
        rsync -a -v  "$base_dir/" "$translated_dir/"
#        cp -r "$base_dir/"* "$translated_dir/"
        set +x
    done <<< "$(find . -path "*/UnifiedResources/DefaultResources")"
)
