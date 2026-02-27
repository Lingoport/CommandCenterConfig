#!/bin/bash
#
# A specific post import script called for Translated
#
# 1. FTP is used as the integration between Command Center and Translated
# 2. Translated adds a file called 'webhook.txt' in the zip file
# 3. At the end of the import process the following variables are set:
#  - LRM_GROUP
#  - LRM_PROJECT
#  - KIT_VERSION
#  - LRM_LOCALE
#  - IMPORT_STATUS = "success" or "failure"
# 4. If IMPORT_STATUS is  "success" then 'webhook.txt' will be located under:
#    -> /usr/local/tomcat/Lingoport_Data/L10nStreamlining/<LRM_GROUP>/projects/<LRM_PROJECT>/importkits/TRANSLATED_KIT_<KIT_VERSION>/<LRM_LOCALE>
#    otherwise, it will be located under:
#   -> /usr/local/tomcat/Lingoport_Data/L10nStreamlining/<LRM_GROUP>/projects/<LRM_PROJECT>/failedkits/TRANSLATED_KIT_<KIT_VERSION>/<LRM_LOCALE>
#
# This script simply will extract the content of the webhook.lingoport file and add ?outcome="OK" or ?outcome="KO" based on IMPORT_STATUS.

echo "============================================================"
echo "   Post Import Script for Translated: Calling the URL"
echo "============================================================"
echo
echo "LRM_GROUP=${LRM_GROUP}"
echo "LRM_PROJECT=${LRM_PROJECT}"
echo "KIT_VERSION=${KIT_VERSION}"
echo "LRM_LOCALE=${LRM_LOCALE}"
echo "IMPORT_STATUS=${IMPORT_STATUS}"

echo "TEST PWD"
pwd

if [ "${IMPORT_STATUS}" = "success" ]
then
  # extract from the importkits directory
  WEBHOOK_FILE="/usr/local/tomcat/Lingoport_Data/L10nStreamlining/${LRM_GROUP}/projects/${LRM_PROJECT}/importkits/TRANSLATED_KIT_${KIT_VERSION}/${LRM_LOCALE}/webhook.lingoport"
  ls -l "${WEBHOOK_FILE}"
  WEBHOOK_URL=`head -1 "${WEBHOOK_FILE}" `
  TRANSLATED_CALLBACK_URL="${WEBHOOK_URL}&outcome=OK"
else
 # If that's possible, extract from failedkits
  WEBHOOK_FILE="/usr/local/tomcat/Lingoport_Data/L10nStreamlining/${LRM_GROUP}/projects/${LRM_PROJECT}/importkits/TRANSLATED_KIT_${KIT_VERSION}/${LRM_LOCALE}/webhook.lingoport"
  ls -l "${WEBHOOK_FILE}"
  WEBHOOK_URL=`head -1 "${WEBHOOK_FILE}" `
  TRANSLATED_CALLBACK_URL="${WEBHOOK_URL}&outcome=KO"
  echo "TRANSLATED_CALLBACK_URL=${TRANSLATED_CALLBACK_URL}"
fi

# curl with the URL. This may or may not even have a valid or existing TRANSLATED_CALLBACK_URL. Let the message show the result
# No handling of errors here. If it fails, it's in the log and that's it
echo "curl this variable: TRANSLATED_CALLBACK_URL=${TRANSLATED_CALLBACK_URL}"
curl "${TRANSLATED_CALLBACK_URL}"

echo
echo "============================================================"
