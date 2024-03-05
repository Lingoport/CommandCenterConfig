#!/bin/bash
#
echo "We are in bug8334.sh script"
echo "     MARY_VAR = ${MARY_VAR}"
echo "     DITA_DIR = ${DITA_DIR}"
env

echo " You should see this change!"
echo "      LINGOPORT_HOME = ${LINGOPORT_HOME}"
java -version
java -jar ${LINGOPORT_HOME}/lrm-server-10.0/lrm-cli.jar -v
java -jar ${LINGOPORT_HOME}/globalyzer-lite-6.8.0_6.0/globalyzer-lite.jar -v
