# !/bin/bash
#
echo " Transform from Repo"
pwd

echo "CLIENT_SOURCE_DIR=$CLIENT_SOURCE_DIR"

if [[ -z "$CLIENT_SOURCE_DIR" ]] ; then
    CLIENT_SOURCE_DIR="$WORKSPACE"
fi

cd "$CLIENT_SOURCE_DIR"

find . -type f -name "*.resx" > "${PROJECT_TMP_DIR}/input_files.txt"
echo "Files to transform: " 
cat "${PROJECT_TMP_DIR}/input_files.txt"

cat "${PROJECT_TMP_DIR}/input_files.txt" | while read -r resxfile
do
  #xmlstarlet ed -d '//data[(starts-with(@name, ">>")) or (@type)]' "$resxfile" > "${resxfile}textonly"
  xmlstarlet ed -d '//data[(starts-with(@name, ">>")) or (@type) or (@mimetype)] | //metadata' "$resxfile" > "${resxfile}textonly"

  # Remove 16 lines from "Example:" in the textonly file, as they include <data> and </data> as examples
  sed -i '/Example:/,+15d' "${resxfile}textonly"

  # Finally, remove that file if there are not key/value pairs, hopefully identified by no </data>
  grep "<\data>" "${resxfile}textonly"
  if [[ $? -ne 0 ]]; then
    echo "No key/value in ${resxfile}textonly, removing it"
    rm "${resxfile}textonly"
  fi
done
