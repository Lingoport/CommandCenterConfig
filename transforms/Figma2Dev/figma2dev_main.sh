#!/bin/bash
#
# Create the 'keys' resource file under locales/keys/translation.json
#
# The Figma Lingoport plugin interacts with a repository.
# In the repository, the base .json file coming from Figma is located under:
#    locales/en/translation.json
#
# The translations are located under locales/*/translation.json
# The pseudo locale is typically eo, so locales/eo/translation.json
#
# Note: This cannot be overwriting 'eo' as pseudo-loc happens as a separate process
#       and the pseudo-loc would end up winning/overwriting the keys file.
#
# Author: Ryan Than
# Copyright (c) Lingoport 2025

# Top-level directory containing subdirectories with JSON files
TOP_DIRECTORY=$1
# TOP_DIRECTORY="../locales" # For testing
echo -e "TOP_DIRECTORY=${TOP_DIRECTORY}\n"

# Retrieve string generation settings from figma2dev_config.properties
CONFIG_FILE="$TRANSFORM_DIR/figma2dev_config.properties"
# CONFIG_FILE="figma2dev_config.properties" # For testing

# Check that the config file exists, throw error if not found:
if ! [ -f "$CONFIG_FILE" ]; then
    echo "figma2dev_config.properties file could not be located. Please make sure the figma2dev_config.properties file exists in the FigmaKeygen transforms folder."
    exit 1
else
    echo -e "CONFIG_FILE=${CONFIG_FILE}\n"
fi

# Read variables from figma2dev_config.properties file
while IFS='=' read -r key value; do
  if [[ -n "$key" ]]; then
    eval "$key=\"\$value\""
  fi
done < "$CONFIG_FILE"

# If the keylength is empty, throw error:
if [ -z "$keylength" ]; then
    echo "Error: keylength variable in figma2dev_config.properties cannot be empty!" >&2
    exit 1
fi

# If the suffix is "counter" and...
if [ "$suffix" == "counter" ]; then
    # The counter start value is empty, throw error:
    if [ -z "$keyCounterStart" ]; then
        echo "Error: keyCounterStart variable in figma2dev_config.properties cannot be empty!" >&2
        exit 1
    fi

    # The counter start value is not a valid number, throw error:
    if ! [[ $keyCounterStart =~ ^[+-]?[0-9]+([.][0-9]+)?$ ]]; then
        echo "Error: keyCounterStart variable in figma2dev_config.properties must be a valid number greater than zero."
        exit 1
    fi

    # The counter start value is less than zero, throw error:
    if ! [[ $keyCounterStart -ge 0 ]]; then
        echo "Error: keyCounterStart variable in figma2dev_config.properties must be a valid number greater than zero."
        exit 1
    fi
fi

# Save initial counter value for debugging output:
startingCounter=$keyCounterStart

# If the baseResourceFileLocale is empty, throw error:
if [ -z "$baseResourceFile" ]; then
    echo "Error: baseResourceFile variable in figma2dev_config.properties cannot be empty!" >&2
    exit 1
fi

# Check that the base resource file exists, throw error if not (or cannot be found):
if ! [ -f "$TOP_DIRECTORY/$baseResourceFile" ]; then
    echo "Base resource file could not be located at \"$TOP_DIRECTORY/$baseResourceFile\". Please make sure the baseResourceFile variable in figma2dev_config.properties is a valid file that matches the repo structure."
    exit 1
fi

echo "CONFIG FILE VALUES:"
echo "Key Prefix: ${prefix}"
echo "Value Split Length: ${keylength}"
echo "Key Suffix: ${suffix}"
echo "Key Starting Counter Value: ${keyCounterStart}"
echo "Base Resource File: $TOP_DIRECTORY/$baseResourceFile"
echo -e "-----------------------------------\n"

# Associative array to store the keys:
declare -A keysArray

# Array to store mapping data:
mapping_array="[]"

if [ -f "$TOP_DIRECTORY/keys/mapping.json" ]; then
  echo -e "Existing mapping file found at $TOP_DIRECTORY/keys/mapping.json.\n" # Debugging statement
  
  # Extract all elements of the existing JSON array into bash array
  readarray -t existing_mapping_array < <(jq --compact-output '.[]' "$TOP_DIRECTORY/keys/mapping.json")
else
  echo -e "Mapping file does not exist, creating a new one.\n" # Debugging statement
fi
echo -e "-----------------------------------\n"


# Process the base English resource file and generate keys based on figma2dev_config.properties settings
echo -e "Processing Base Resource File: $TOP_DIRECTORY/$baseResourceFile\n"

while IFS= read -r line; do
    # Get key + value from resource file
    key=$(echo "$line" | sed 's/^[^"]*"\([^"]*\)".*/\1/')
    value=$(echo "$line" | sed 's/^[^\"]*\"[^\"]*\":\s*"//; s/\"[^\"]*$//')

    # Skip "{" and "}" characters
    if [[ "$key" == "{" || "$key" == "}" ]]; then
        continue
    fi

    # Check existing mapping array BEFORE GENERATING keys to see if the node already has a generated key
        # If it does, just update the value in the mapper file if needed and use the existing generated key
        # If it doesn't, use the counter value from the figma2dev_config.properties to generate a new key

    if grep -q "${key}" <<< "${existing_mapping_array[@]}"; then
        echo "- Node ID '$key' found in mapping array. A new key does not need to be generated, updating JSON value..." # Debugging statement
        
        for item in "${existing_mapping_array[@]}"; do
            # Get generated key + original value/nodeID from mapping file
            genKey=$(jq --raw-output '.key' <<< "$item")
            originalValue=$(jq --raw-output '.value' <<< "$item")
            originalNodeID=$(jq --raw-output '.nodeID' <<< "$item")
            originalTimestamp=$(jq --raw-output '.lastChanged' <<< "$item")

            if [ "$originalNodeID" == "$key" ]; then
                keysArray[$key]=$genKey # Add existing generated key to array

                # Debugging Statement:
                if [ "$originalValue" == "$value" ]; then
                    # Create a JSON object for mapping (use the same generated key as before) + Append the JSON object to the mapping array
                    json_object=$(jq -n --arg key "$genKey" --arg value "$originalValue" --arg nodeID "$key" --arg timestamp "$originalTimestamp" \ '{key: $key, value: $value, nodeID: $nodeID, lastChanged: $timestamp}')
                    mapping_array=$(jq -n --argjson array "$mapping_array" --argjson object "$json_object" \ '$array + [$object]')
                    echo "   - JSON string value is the same for \"$key\", no need to update." # Debugging statement
                else
                    newTimeStamp=$(date +%s)  # Get current timestamp

                    # Create a JSON object for mapping (use the same generated key as before, but new value + new timestamp) + Append the JSON object to the mapping array
                    json_object=$(jq -n --arg key "$genKey" --arg value "$value" --arg nodeID "$key" --arg timestamp "$newTimeStamp" \ '{key: $key, value: $value, nodeID: $nodeID, lastChanged: $timestamp}')
                    mapping_array=$(jq -n --argjson array "$mapping_array" --argjson object "$json_object" \ '$array + [$object]')
                    echo "   - Updated original value: \"$originalValue\" to \"$value\" for \"$key\"." # Debugging statement
                fi

                echo ""
                break
            fi
        done
    else
        echo "- Node ID '$key' was not found in mapping array, generating new key." # Debugging statement

        cleanedValue=$(echo $value | tr -cd '[:alnum:]._-') # Remove non-alphanumeric characters from value

        generatedKey=${cleanedValue:0:$keylength} # Trim value based on keylength value

        # Append prefix to generated key if it is not empty:
        if [ -n "$prefix" ]; then
            generatedKey="${prefix}_${generatedKey}"
        fi

        # Append suffix to generated key if it is not empty:
        if [ -n "$suffix" ]; then
            if [ "$suffix" == "counter" ]; then
                generatedKey="${generatedKey}_${keyCounterStart}"
                ((keyCounterStart += 1))
            else
                generatedKey="${generatedKey}_${suffix}"
            fi
        fi

        keysArray[$key]=$generatedKey # Add generated key to array
        echo "   - Generated key for node ID $key: \"${keysArray[$key]}\""  # Debugging statement

        timeStamp=$(date +%s) # Get current timestamp

        # Create a JSON object for mapping
        json_object=$(jq -n --arg key "$generatedKey" --arg value "$value" --arg nodeID "$key" --arg timeStamp "$timeStamp" \ '{key: $key, value: $value, nodeID: $nodeID, lastChanged: $timeStamp}')

        # Append the JSON object to the array
        mapping_array=$(jq -n --argjson array "$mapping_array" --argjson object "$json_object" \ '$array + [$object]')

        echo ""
    fi
done < "$TOP_DIRECTORY/$baseResourceFile"

# Replace the keyCounterStart value in the properties file with the new counter value (if changed)
if ([ "$suffix" == "counter" ] && [ $startingCounter != $keyCounterStart ]); then
    sed -i "s/^[#]*\s*keyCounterStart=.*/keyCounterStart=${keyCounterStart}/" $CONFIG_FILE
    echo -e "-----------------------------------\n"
    echo -e "Updated string counter value from \"${startingCounter}\" to \"${keyCounterStart}\".\n"
fi


# Check if keysArray array is populated
# echo "Checking the contents of keysArray array..."  # Debugging statement
# for key in "${!keysArray[@]}"; do
#     echo "Key: $key, Value: ${keysArray[$key]}"  # Debugging statement
# done


echo "-----------------------------------"
echo -e "Generating files...\n"

# Create + move the keys.json file over to the 'keys' directory as "translation.json" (to display keys in Figma file)
echo "{" > keys.json
for key in "${!keysArray[@]}"; do
    value=$(echo "${keysArray[$key]}" | sed "s/'/\\\'/g")
    echo "  \"$key\": \"$value\"," >> keys.json
done
sed -i '$ s/,$//' keys.json  # Remove trailing comma from the last line
echo "}" >> keys.json

mkdir -p "$1/keys"
mv keys.json "$TOP_DIRECTORY/keys/translation.json"
echo -e "Created translation.json for \"keys\" locale, file path: \"$TOP_DIRECTORY/keys/translation.json\"\n"


# Create + move the mapping.json file over to the 'keys' directory
echo "$mapping_array" >> mapping.json
mkdir -p "$1/keys"
mv mapping.json "$TOP_DIRECTORY/keys/mapping.json"
echo -e "Created mapping.json, file path: \"$TOP_DIRECTORY/keys/mapping.json\"\n"


# Create + move the base properties file over to the 'keys' directory
baseLocale=${baseResourceFile%*/translation.json}
echo "$mapping_array" | jq -c '.[]' | while read -r item; do
    # Process each JSON object (item) here
    mappingKey=$(echo "$item" | jq -r '.key')
    mappingValue=$(echo "$item" | jq -r '.value')

    echo "$mappingKey=$mappingValue" >> data.properties
done

mv data.properties "$TOP_DIRECTORY/$baseLocale/messages.properties"
echo -e "Created messages.properties for base locale: $baseLocale, file path: \"$TOP_DIRECTORY/$baseLocale/messages.properties\"\n"


# Create + move properties files for all locales to their corresponding directories
for dir in $TOP_DIRECTORY/*/
do
    dir=${dir%*/} # Remove trailing backslash
    resourceLocale=$(basename "$dir") # Get locale from directory path

    # If the directory is the base locale or the keys locale, skip them
    if echo "$resourceLocale" | grep -q -e "$baseLocale" -e "keys"; then
        continue
    fi

    # If a translation.json file doesn't exist for the locale, skip it
    if ! [ -f $resourceFile ]; then
        echo "A translation.json file could not be found for locale directory: $dir, a corresponding properties file will not be generated."
        continue
    fi

    # echo $dir # Debugging statement
    # echo $resourceLocale # Debugging statement

    resourceFile="$dir/translation.json"
    # echo $resourceFile # Debugging statement

    while IFS= read -r line; do
        # Get key + value from resource file
        key=$(echo "$line" | sed 's/^[^"]*"\([^"]*\)".*/\1/')
        value=$(echo "$line" | sed 's/^[^\"]*\"[^\"]*\":\s*"//; s/\"[^\"]*$//')

        # Skip "{" and "}" characters
        if [[ "$key" == "{" || "$key" == "}" ]]; then
            continue
        fi

        # echo "$key: $value" # Debugging statement

        if [[ -n "${keysArray[$key]+_}" ]]; then
            generatedKey="${keysArray[$key]}"
            # echo "Key '$key' exists, generated key: $generatedKey, resource value: $value" # Debugging statement

            echo "$generatedKey=$value" >> data_$resourceLocale.properties
        fi
    done < "$resourceFile"

    mv data_$resourceLocale.properties "$TOP_DIRECTORY/$resourceLocale/messages.properties"
    echo -e "Created messages.properties for locale: $resourceLocale, file path: \"$TOP_DIRECTORY/$resourceLocale/messages.properties\"\n"
done


# # Create + move the PXML file over to the 'keys' directory
# echo '<?xml version="1.0" encoding="utf-8"?>' > data.pxml
# echo '<resources>' >> data.pxml
# counter=1
# echo "$mapping_array" | jq -c '.[]' | while read -r item; do
#     # Process each JSON object (item) here
#     mappingKey=$(echo "$item" | jq -r '.key')
#     mappingValue=$(echo "$item" | jq -r '.value')

#     { 
#         echo "  <string translate=\"1\" segmentID=\"$counter\" minLength=\"\" maxLength=\"\">"
#         echo '    <lrm_incontext></lrm_incontext>'
#         echo '    <llm_prompt></llm_prompt>'
#         echo "    <SID>$mappingKey</SID>"
#         echo "    <value>$mappingValue</value>"
#         echo '  </string>' 
#     } >> data.pxml

#     (( counter += 1 ))
# done
# echo '</resources>' >> data.pxml

# mkdir -p "$1/keys"
# mv data.pxml "$TOP_DIRECTORY/keys/data.pxml"
# echo -e "Created data.pxml, file path: \"$TOP_DIRECTORY/keys/data.pxml\"\n"
