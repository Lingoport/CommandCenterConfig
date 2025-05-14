#!/bin/bash
# Specific transformation for strings.txt files
#
# The following environment variable needs to be set:
# TRANSFORM_DIR

# 1: Create the keys locale .json file in keys/translation.json
echo " Create the keys locale keys/translation.json with $TRANSFORM_DIR/figma_keygen.sh"
. $TRANSFORM_DIR/figma_keygen.sh "${CLIENT_SOURCE_DIR}/locales"
