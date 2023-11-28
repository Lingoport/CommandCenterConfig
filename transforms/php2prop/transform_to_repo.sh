#!/bin/bash
# Specific transformation for Vanilla php resource files
#
# The following environment variable needs to be set:
# TRANSFORM_DIR

# 1: Transform properties into .php
echo " .properties to .php  tranform with $TRANSFORM_DIR/properties_to_php.sh"
. $TRANSFORM_DIR/properties_to_php.sh

