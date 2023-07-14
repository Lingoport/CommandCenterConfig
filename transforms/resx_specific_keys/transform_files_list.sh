#!/bin/bash
sed -i -E 's|.resxtextonly|.resx|g' "$1"
