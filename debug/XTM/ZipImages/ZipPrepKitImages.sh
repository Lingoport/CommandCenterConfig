#!/bin/bash
#
# Test for Motorola: Adding XTM context using the SID in the PXML and
# download here the 'png'. Here, I assume PNG files are what XTM expects.
#
# This is to show how associating context could be done with a simple method.
# It finds all the PXML files inside a 'prepkits' directory, the input here.
# for each PXML, it extracts the SID and URL per <string>
# It then gets the PNG (assumed here, more to do, see below)and names it
#   based on the SIDE
# It zips up allt the images, so it's ready to be uploaded to the XTM project
#  (Motorola: upload to the right project using their API)
#
# To run, call it with a prepkits directory with PXML files. For example, if
# project ACM.Test.1.fr was sent, then:
# ./ZipPrepKitImage.h /usr/local/tomcat/Lingoport_Data/L10nStreamlining/ACM/projects/Test/prepkits/1/fr/
#
# Again, this is a zipper to highlight how to create the zip file. It does not interact
# with XTM.
#
# I think we'll add a 'post prep kit' type invocation with at least the following elements:
# GROUP
# PROJECT
# PK (maybe PK_NUMBER)
# LOCALE
# so the directory to look into would then be:
#  /usr/local/tomcat/Lingoport_Data/L10nStreamlining/${GROUP}/projects/${PROJECT}/prepkits/${PK}/${LOCALE}/
#
# More needs to be done, for instance:
# > If the file is an HTML: May want to convert to a PNG (If PNG is what XTM expects)
# > If the file is a .gif -> convert to png
# > Use the project XTM config to call the XTM API and upload the zip file
#
# Olivier Libouban (c) Lingoport 2025

echo "PXML_DIR = $PXML_DIR"
if [ ! -d "$PXML_DIR" ]; then
    echo "${PXML_DIR} Directory does not exist"
    exit 1
fi

# Check for required tools
for tool in xmlstarlet curl zip; do
    if ! command -v "$tool" &> /dev/null; then
        echo "❌ Required tool '$tool' is not installed."
        exit 1
    fi
done

# Temporary working directory
WORK_DIR=$(mktemp -d)
cd "$WORK_DIR" || exit 1

# Find all .pxml files and process them
find "$PXML_DIR" -type f -name "*.pxml" | while read -r pxml_file; do
    echo "🔍 Processing: $pxml_file"

    xmlstarlet sel -t -m "//string" \
        -v "SID" -o "|" -v "lrm_incontext" -n "$pxml_file" |
    while IFS="|" read -r sid url; do
        if [[ -z "$sid" || -z "$url" ]]; then
            continue
        fi

        # Sanitize SID
        clean_sid=$(echo "$sid" | tr -cd '[:alnum:]_-')

        # Change the entity &amp; into &
        clean_url="${url//&amp;/&}"

        # Download image
        echo "📥 Downloading image for SID: $clean_sid and URL $clean_url"
        curl -s -L "$clean_url" -o "${clean_sid}.png"
    done
done

# Create zip
zip -q images.zip *.png

# Move zip back
mv images.zip "$OLDPWD"

# Clean up
cd "$OLDPWD"
rm -r "$WORK_DIR"


echo "✅ Done. Created ${OLDPWD}/images.zip"
ls -l "${OLDPWD}/images.zip"

