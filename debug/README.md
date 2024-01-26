This directory holds scripts to debug the system. 

To execute a debug script, go to system files in Command Center, add the debug script, and run execute from the edit page.

## list_kits.sh sample ##
The <code>list_kits.sh</code> script is a sample debug script, so actual debug scripts can follow a similar pattern.
It relies on Command Center system environment variables. System environment variables are configured in 
* Settings > Advanced Settings
  
and are passed to .sh scripts.

## gerrit/gerrit_cleanup.sh ##
The `gerrit/gerrit_cleanup.sh` script is intended for use by customers who use the Gerrit data source credential. If there is an SHA in the unmergedSHAs.txt file that is blocking analysis from running successfully, then it must be cleaned out of the list using this debug script. There are two environment variables that are required by this debug script:
* **PROJECT_ID** - the ID of the project that needs to be cleaned.
* **SHA_TO_CLEAN** - the SHA that needs to be cleaned out of the project's unmerged SHAs list.
