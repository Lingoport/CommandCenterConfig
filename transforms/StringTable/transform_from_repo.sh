#!/bin/bash
# Specific transformation for some js files containing html
#
# The following environment variable needs to be set:
# TRANSFORM_DIR

# 1: .xml to .txml
echo " Transform .xml files to .txml with $TRANSFORM_DIR/xml_to_txml.sh"
. $TRANSFORM_DIR/xml_to_txml.sh
