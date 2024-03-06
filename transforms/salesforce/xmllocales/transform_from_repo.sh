#!/bin/bash
# Specific transformation for strings*.txt files
# 
# The following environment variable needs to be set:
# TRANSFORM_DIR

# 1: <locale>.translation_meta.xml -> translation_meta.<locale>.xml
echo " Transform: <locale>.translation_meta.xml -> translation_meta.<locale>.xml"
. $TRANSFORM_DIR/l_translation2translation_l.sh
