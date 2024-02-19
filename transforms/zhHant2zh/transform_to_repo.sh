#!/bin/bash
#
# Copies the content of zh-Hant.lproj directories into zh.lproj directories
# If the zh.lproj directory does not exists, creates it before copying
#

echo  " ------------------------------------------------"
echo  " START  $0"
echo  " Current pwd:"
pwd
echo  " ------------------------------------------------"
echo  " ------------------------------------------------"
find . -name zh-Hant.lproj > "${PROJECT_TMP_DIR}/zhHant.txt"

while read hantDir; do
  test=`dirname "$hantDir"`
  zhDir="${test}/zh.lproj"
  mkdir -p "${zhDir}"
  cp "${hantDir}"/* "${zhDir}"
  echo "${hantDir}"
  ls "${hantDir}"
  echo "---"
  echo "${zhDir}"
  ls "${zhDir}"
  echo " -----------------------"
  git add "${zhDir}"/*
done < "${PROJECT_TMP_DIR}/zhHant.txt"

git status
git commit -m"Lingoport Sync zh from zh-Hant " . || true
echo " - Copied zh-Hant.lproj content to zh.lproj"
git push
git status
echo " END $0"
echo  " ------------------------------------------------"
