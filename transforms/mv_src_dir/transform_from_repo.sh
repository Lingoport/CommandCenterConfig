#!/bin/bash
# Move the source locale repo under a given directory
# where all translations are done.
#
# For example:
#   move locales/en-US/* under translated/en-US/.
#
# On the way back, nothing to do since the translated files
# will be under translated/<locale_code>/
#
echo "${0}"
env
echo "TRANSFORM_DIR=${TRANSFORM_DIR}"

if [[ -z "$CLIENT_SOURCE_DIR" ]] ; then
    export CLIENT_SOURCE_DIR="$WORKSPACE"
fi

(
    cd "$CLIENT_SOURCE_DIR"
    while read -r base_dir ; do
        translated_dir="$(dirname "$base_dir")/LocalizedResources"
        mkdir -p "$translated_dir"
        set -x
#        /bin/rsync -a -v  "$base_dir/" "$translated_dir/"
        echo "Copy ${base_dir} to ${translated_dir}"
        cp -r "$base_dir/"* "$translated_dir/"
        set +x
    done <<< "$(find . -path "*/UnifiedResources/DefaultResources")"
)

