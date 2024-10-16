#!/bin/bash

# Find the FilesToPrep.xml files within the last n days
find /usr/local/tomcat/Lingoport_Data/L10nStreamlining  -mtime -7  -name FilesToPrep.xml > /usr/local/tomcat/Lingoport_Data/tmp/FilesToPrepList.txt

# For each file:
#  1. extract the LRM project name from the path
#  2. extract the relevant data from the FilesToPrep.xml for the line
#  3. add the data in the report



input_file="/usr/local/tomcat/Lingoport_Data/tmp/FilesToPrepList.txt"

# Check if input file exists
if [ ! -f "$input_file" ]; then
    echo "Error: File '$input_file' not found!"
    exit 1
fi

# Base path to match
base_path="/usr/local/tomcat/Lingoport_Data/L10nStreamlining/"

# Process each line of the input file
while IFS= read -r line; do
    # Check if the line is a valid file path (i.e., does not contain invalid characters)
    if [[ -f "$line" ]]; then
        #echo "Processing file: $line"
        #echo " --->"

        # Extract part between "PREP_KIT_" and "/FilesToPrep."
        prep_kit=$(echo "$line" | sed -n "s|.*/PREP_KIT_\([^/]*\)/FilesToPrep.xml|\1|p")


        # Ensure the input file exists
        if [ ! -f "$line" ]; then
            echo "Error: File '$lin' not found."
            exit 1
        fi

        echo "PROJECT NAME, KIT NUMBER, SENT DATE, LOCALE, # FILES, # KEYS, # WORDS"
        # Extract project name
        company_name=$(grep -oP '(?<=companyName=").*?(?=")' "$line")
        project_name=$(grep -oP '(?<=projectName=").*?(?=")' "$line")
        kit_date=$(date -r "$line" "+%Y-%m-%d" )

        #echo "Company Name: $company_name"
        #echo "Project Name: $project_name"
        #echo "Prep Kit:     ${prep_kit}"
        

        # Extract locales and their details
        #echo "Locales:"
        grep -oP '<prep-info[^>]*locale="[^"]*"' "$line" | while read -r locale_line; do
           locale=$(echo "$locale_line" | grep -oP '(?<=locale=").*?(?=")')
           locale_display_name=$(grep -oP "<prep-info[^>]*locale=\"$locale\"[^>]*localeDisplayName=\"[^\"]*\"" "$line" | grep -oP '(?<=localeDisplayName=").*?(?=")')
           nb_files=$(grep -oP "<prep-info[^>]*locale=\"$locale\"[^>]*nbFilesToTranslate=\"[^\"]*\"" "$line" | grep -oP '(?<=nbFilesToTranslate=").*?(?=")')
           nb_keys=$(grep -oP "<prep-info[^>]*locale=\"$locale\"[^>]*nbKeysToTranslate=\"[^\"]*\"" "$line" | grep -oP '(?<=nbKeysToTranslate=").*?(?=")')
           nb_words=$(grep -oP "<prep-info[^>]*locale=\"$locale\"[^>]*nbWordsToTranslate=\"[^\"]*\"" "$line" | grep -oP '(?<=nbWordsToTranslate=").*?(?=")')
    
        #   echo "  Locale: $locale ($locale_display_name)"
        #   echo "    Files to Translate: $nb_files"
        #   echo "    Keys to Translate: $nb_keys"
        #   echo "    Words to Translate: $nb_words"

           echo "${company_name}.${project_name}, ${prep_kit}, ${kit_date}, ${locale}, $nb_files, $nb_keys, $nb_words"
        done

        # Extract file paths
        #echo "Files to translate:"
        #grep -oP '(?<=file=").*?(?=")' "$line" | while read -r file_path; do
        #   echo "  File Path: $file_path"
        #done


    else
        echo "Skipping invalid or non-existing file path: $line"
    fi
done < "$input_file"


