#!/bin/bash
# Specific transformation for strings.txt files
#
# The following environment variable needs to be set:
# TRANSFORM_DIR

# 1: Transform  short locale csv back to a long locale csv,
#    as per the csv_locale_map.properties
echo " Short csv name to Long csv name to .txt tranform with $TRANSFORM_DIR/short_2_long.sh"
. $TRANSFORM_DIR/short_2_long.sh

