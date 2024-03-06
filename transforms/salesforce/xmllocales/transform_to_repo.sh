#!/bin/bash
# Specific transformation for strings*.txt files
# 
# The following environment variable needs to be set:
# TRANSFORM_DIR

# 1: <locale>.translation_meta.xml -> translation_meta.<locale>.xml
echo " Transform:  translation_meta.<locale>.xml -> <locale>.translation_meta.xml"
. $TRANSFORM_DIR/translation_l2l_translation.sh
