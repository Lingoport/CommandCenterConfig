#!/bin/bash
# Specific transformation for strings.txt files
#
# The following environment variable needs to be set:
# TRANSFORM_DIR

# 1: Create the longest value .json file in af/translation.json
echo " Create the longest value Figma af/translation.json with $TRANSFORM_DIR/longest.sh"
. $TRANSFORM_DIR/longest.sh "${CLIENT_SOURCE_DIR}/locales"
