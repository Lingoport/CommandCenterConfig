#!/bin/bash
#

cd "$CLIENT_SOURCE_DIR"

find . -name zh-Hant.lproj > "${PROJECT_TMP_DIR}/zhHant.txt"

while read hantDir; do
  test=`dirname "$hantDir"`
  zhDir="${test}/zh.lproj"
  mkdir -p "${zhDir}"
  cp "${hantDir}"/* "${zhDir}"
  git add "${zhDir}"/*
done < "${PROJECT_TMP_DIR}/zhHant.txt"

git status
git commit -m"Lingoport Sync with zh-Hant and zh" . || true"
echo " - Copied zh-Hant.lproj content to zh.lproj"
git push
git status
echo " END $0"
echo " ----------------------------------------------"

