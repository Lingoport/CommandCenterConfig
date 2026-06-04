#!/bin/bash
# Specific transformation for filename_<Language>.properties files
#
# The following environment variable needs to be set:
# TRANSFORM_DIR

# 1: Transform properties into .txt
echo " .properties to .isl tranform with $TRANSFORM_DIR/locale2back.sh"
. $TRANSFORM_DIR/locale2back.sh
