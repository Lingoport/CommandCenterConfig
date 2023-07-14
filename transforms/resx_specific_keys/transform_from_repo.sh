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

  #xmlstarlet ed -d '//data[not(contains(@name, ".Text"))]' "$resxfile" > "${resxfile}textonly"
  xmlstarlet ed -d '//data[(starts-with(@name, ">>")) or (@type)]' "$resxfile" > "${resxfile}textonly"

done
