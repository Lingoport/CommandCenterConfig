#!/bin/bash
# Specific transformation for strings.txt files
#
# The following environment variable needs to be set:
# TRANSFORM_DIR

# 1: Transform properties into .txt
echo " .properties to .txt tranform with $TRANSFORM_DIR/prop2txt.sh"
. $TRANSFORM_DIR/prop2txt.sh
