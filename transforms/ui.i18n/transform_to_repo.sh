#!/bin/bash
#
# The following environment variable needs to be set:
# TRANSFORM_DIR
#
# 1: <locale>_resourcemanagement.ui.i18n.json -> resourcemanagement.ui.i18n_<locale>.xml
echo " Transform:  resourcemanagement.ui.i18n_<locale>.json -> <locale>_resourcemanagement.ui.i18n.json"
. $TRANSFORM_DIR/translation_l2l_translation.sh

