# !/bin/bash
echo  " ------------------------------------------------"
echo  " Current pwd:"
pwd

echo "Files to transform: " 
cat "${FULL_LIST_PATH}"


if [[ -z "$CLIENT_SOURCE_DIR" ]] ; then
    CLIENT_SOURCE_DIR="$WORKSPACE"
fi

cat "${FULL_LIST_PATH}"  | while read -r resxtextonly
do
    mv "$resxtextonly" "${resxtextonly%%textonly}"
done 


