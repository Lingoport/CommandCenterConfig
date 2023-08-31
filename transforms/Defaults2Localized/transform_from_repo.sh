#!/bin/bash


(
    cd "$CLIENT_SOURCE_DIR"
    while read -r base_dir ; do
	# Watch out: If base_dir is empty, it would try to
	# rsync from /  (root), i.e. the entire system !
	if [[ ! -z "$base_dir" ]] 
	then
          translated_dir="$(dirname "$base_dir")/LocalizedResources"
          mkdir -p "$translated_dir"
          set -x
          echo "rsync -a -v  ${base_dir} ${translated_dir}"
          #rsync -a -v  "$base_dir/" "$translated_dir/"
          set +x
	fi
    done <<< "$(find . -path "*/UnifiedResources/DefaultResources")"
)
