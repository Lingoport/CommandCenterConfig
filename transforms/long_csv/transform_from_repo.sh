#!/bin/bash
# Specific transformation for strings*.txt files
#
# The following environment variable needs to be set:
# TRANSFORM_DIR

# 1: PortugueseBR.csv -> pt-BR.csv (any long locale configured in csv_locale_map.properties) to a short locale
echo " Copy Long csv files to Short csv  files with $TRANSFORM_DIR/long_2_short.sh"
. $TRANSFORM_DIR/long_2_short.sh

