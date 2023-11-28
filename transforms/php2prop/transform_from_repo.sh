#!/bin/bash
# Specific transformation for Vanilla php resource files
#
# The following environment variable needs to be set:
# TRANSFORM_DIR

# 1: Transform php files into .properties
echo " .php to .properties tranform with $TRANSFORM_DIR/php_to_properties.sh"
. $TRANSFORM_DIR/php_to_properties.sh

