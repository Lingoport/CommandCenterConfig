#!/bin/bash
#
# Sample for a post prep kit script
#
# If some outside process needs to be triggered after a prep kit has been sent, 
# this sample could be used to start a new script
#
# Olivier Libouban (c) Lingoport 2025
#

echo "  LRM_GROUP      = ${LRM_GROUP}"
echo "  LRM_PROJECT    = ${LRM_PROJECT}"
echo "  KIT_VERSION    = ${KIT_VERSION}"
echo "  LRM_LOCALE     = ${LRM_LOCALE}"
echo "  PREPKIT_STATUS = ${PREPKIT_STATUS}"


echo " Call external process"
echo " curl \"https://externalsystem.company.io/api/startprocess\" -d '{\"username\":\"API_USER\",\"token\":\"API_TOKEN\", \"project\": \"${LRM_GROUP}.${LRM_PROJECT}\",\"pk\": \"${KIT_VERSION}\"}}'  --header \"Content-Type: application/json"

echo " End of external process call" 
