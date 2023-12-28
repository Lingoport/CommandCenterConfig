# DITA File Path Transformation Script

## Overview
This Bash script is designed to reorganize DITA file paths in a specific directory structure. 
It reads the original file paths from a file, and then moves the files to their new locations. 

### transform_from_repo.sh
Reorganizes file under 
* DITA_DIR/`<locale>`/<...path...>/<file>.dita[map] 
under a special directory, `DITA_RESOURCES` like the following:
* DITA_DIR/`<DITA_RESOURCES>`/<...path...>/`<locale>`/<file>.dita[map]

### transform_files_list.sh (also does the typical job of transform_to_repo.sh)
Reorganizes file under `<DITA_RESOURCES>`, as in:
* DITA_DIR/`<DITA_RESOURCES>`/<...path...>/`<locale>`/<file>.dita[map]
under a original directories,  like the following:
* DITA_DIR/`<locale>`/<...path...>/<file>.dita[map]

and renames the files in the file list accordingly

## Note
- The `<DITA_RESOURCES>` should never be pushed to the repository, it is a temporary repository only for Localyzer
- Test the script in a non-production environment before running it on important data.
- Ensure that you have the necessary permissions to read and write the files and directories involved.




