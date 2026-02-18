#!/bin/bash
# The following environment variable needs to be set:
# TRANSFORM_DIR

# 1: <locale>_resourcemanagement.ui.i18n.json -> resourcemanagement.ui.i18n_<locale>.json
echo " Transform: <locale>_resourcemanagement.ui.i18n.json -> resourcemanagement.ui.i18n_<locale>.json"
. $TRANSFORM_DIR/l_translation2translation_l.sh

