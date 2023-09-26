# Purpose

# Usage in Command Center

# Note on moving pre-Command Center transforms to Command Center


## from repo: 
    find . -name "*\.txt" -type f > "${PROJECT_TMP_DIR}/input_files.txt"

no more ~/tmp/input_files.txt as ~ won't work (root stuff /  also multiple projects running with :commandcenter so not overwrite for different projects potentially at the same time : )

## to repo:

No need to look for the files to transform back (no find, etc.), instead use: "${FULL_LIST_PATH}"

so only those files " in ${FULL_LIST_PATH}" will be transformed (cleaner), so the repo does not have modified files outside those that should be.

## Left over files
One important distinction with Jenkins/Dash is that we use git pull (not git clone), so much faster, but we do not want to have left over files from repo which are modified by the transforms (in Jenkins/Dash, the workspace was removed, so that was not an issue).

## Benefits
1. Will be faster in terms of transforms (only those that need it!)
2. Will not do some weird loop: transfrom from -> to -> from -> to ... with different results!!!

So some mods for our existing transforms -> Migration to be done with that in mind (repo/repo, etc.)
