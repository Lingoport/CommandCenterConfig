#!/bin/bash
# Specific transformation for Siemens StringTable xml files
#
# The following environment variable needs to be set:
# TRANSFORM_DIR
echo " .txml to .xml tranform with $TRANSFORM_DIR/txml_to_xml.sh"
. "$TRANSFORM_DIR/txml_to_xml.sh"
