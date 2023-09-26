#!/bin/bash
# Specific transformation for strings*.txt files
# 
# The following environment variable needs to be set:
# TRANSFORM_DIR

# 1: .txt to .properties
echo " Transform .txt files to .properties with $TRANSFORM_DIR/txt2prop.sh"
. $TRANSFORM_DIR/txt2prop.sh
