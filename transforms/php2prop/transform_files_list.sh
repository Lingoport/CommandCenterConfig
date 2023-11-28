#!/bin/bash
sed -i 's/\.properties/.php/' "$1"
sed -i 's/vanilla_//' "$1"
