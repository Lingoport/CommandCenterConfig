## Post Import Scripts ##

### Scripts used for specific actions after an import has happened. ###
At the end of the import process the following variables are set:
* LRM_GROUP
* LRM_PROJECT
* LRM_KIT_VERSION
* LRM_LOCALE
* IMPORT_STATUS = "success" or "failure"

Those variables and other potential items can then be used to execute some post import process. 

For instance, say that during the FTP process a webhook.lingoport file is placedaccording to the following:

If IMPORT_STATUS is  "success" then 'webhook.txt' will be located under:
* /usr/local/tomcat/Lingoport_Data/L10nStreamlining/<LRM_GROUP>/projects/<LRM_PROJECT>/importkits/TRANSLATED_KIT_<LRM_KIT_VERSION>/<LRM_LOCALE>
 otherwise, it will be located under:
* /usr/local/tomcat/Lingoport_Data/L10nStreamlining/<LRM_GROUP>/projects/<LRM_PROJECT>/failedkits/TRANSLATED_KIT_<LRM_KIT_VERSION>/<LRM_LOCALE>

Then the post import process could curl the content of the webhook.lingoport file.
