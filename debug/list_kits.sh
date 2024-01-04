#!/bin/bash
echo "---------------------------------------------------"
echo "Modify this example Debug script to your needs"
echo "---------------------------------------------------"
echo " "
echo "Sample Debug Script, using system variables:"
echo "  DEBUG_GN : the group name of a project"
echo "  DEBUG_PN : the project name itself"
echo "  DEBUG_MN : the module name"
echo ""
echo "This script lists the content of :"
echo "  The files sent to translation"
echo "  The files received from translation correctly"
echo "  The failed translations"
echo "---------------------------------------------------"
echo " "
echo "  DEBUG_GN=${DEBUG_GN}"
echo "  DEBUG_PN=${DEBUG_PN}"
echo "  DEBUG_MN=${DEBUG_MN}"
echo " "

# Check that at least DEBUG_GN and DEBUG_PN are not empty!
if [ -z "${DEBUG_GN}" ]
then
      echo "\$DEBUG_GN is empty"
      echo "To set system variable like \$DEBUG_GN in Command Center , navigate to Settings > Advanced Settings"
      echo "Exiting"
      exit -1
fi

if [ -z "${DEBUG_PN}" ]
then
      echo "To set system variable like \$DEBUG_PN in Command Center , navigate to Settings > Advanced Settings"
      echo "Exiting"
      exit -1
fi

# If MN is empty, then don't append that to the location of the project directory
if [ -z "${DEBUG_MN}" ]
then
  DEBUG_DIR="/usr/local/tomcat/Lingoport_Data/L10nStreamlining/${DEBUG_GN}/projects/${DEBUG_PN}"
else
  DEBUG_DIR="/usr/local/tomcat/Lingoport_Data/L10nStreamlining/${DEBUG_GN}/projects/${DEBUG_PN}_${DEBUG_MN}"

fi

echo "  DEBUG_DIR=${DEBUG_DIR}"
echo " "

echo " Listing for kits sent to translation:"
echo " -------------------------------------"
ls -l "${DEBUG_DIR}"/prepkits/PREP_KIT*/*/*.*
echo " "

echo " Listing for kits received from translation:"
echo " --------------------------------------------"
ls -l "${DEBUG_DIR}"/importkits/TRANSLATED_KIT*/*/*.*
echo " "

echo " Listing for failing kits from translation:"
echo " -------------------------------------"
ls -l "${DEBUG_DIR}"/failedkits/TRANSLATED_KIT_*/*/*.*
echo " "

echo "---------------------------------------------------"


