#!/bin/bash
#

cd "$CLIENT_SOURCE_DIR"

find . -name zh-Hant.lproj > "${PROJECT_TMP_DIR}/zhHant.txt"

while read hantDir; do
  echo "$hantDir"
  test=`dirname "$hantDir"`
  zhDir="${test}/zh.lproj"
  echo "mkdir -p ${zhDir}"
  echo "cp ${hantDir}/* ${zhDir}"
  echo "git add ${zhDir}/*"
done < "${PROJECT_TMP_DIR}/zhHant.txt"

git status
echo "git commit -m\"Lingoport Sync with zh-Hant and zh\" . || true"
echo "Done with Copying Hant to zh"
echo "git push"
echo "git status"

