package com.lingoport.figma2dev_java;

/*
    Create the 'keys' resource file under locales/keys/translation.json
    
    The Figma Lingoport plugin interacts with a repository.
    In the repository, the base .json file coming from Figma is located under: locales/en/translation.json

    The translations are located under locales/<locale>/translation.json
    The pseudo locale is typically eo, so locales/eo/translation.json

    Note: This cannot be overwriting 'eo' as pseudo-loc happens as a separate process
           and the pseudo-loc would end up winning/overwriting the keys file.

    Author: Ryan Than
    Copyright (c) Lingoport 2025
*/

import java.io.*;
import java.nio.charset.StandardCharsets;
import java.nio.file.*;
import java.util.*;

import org.apache.commons.lang3.StringUtils;

import com.fasterxml.jackson.core.type.TypeReference;
import com.fasterxml.jackson.core.util.DefaultPrettyPrinter;
import com.fasterxml.jackson.databind.ObjectMapper;
import com.fasterxml.jackson.databind.ObjectWriter;
import com.fasterxml.jackson.databind.SerializationFeature;

public class Figma2Dev {
    public static void main(String[] args) throws Exception {
        String topDirectory;
        try {
            topDirectory = args[0];
            // topDirectory = "testing/locales"; // For local testing
        } catch (Exception e) {
            System.err.println("No top directory provided! Please provide the top directory path as the first argument.");
            return;
        }

        File directory = new File(topDirectory);

        if (directory.exists() && directory.isDirectory()) {
            System.out.println("Top Directory: " + topDirectory);
        } else {
            System.out.println("Provided top directory does not exist or is not a directory: " + topDirectory);
            return;
        }

        // Load config file
        String configFile;
        try {
            configFile = args[1];
            // configFile = "testing/config/figma2dev_config.properties"; // For local testing
        } catch (Exception e) {
            System.err.println("No config file path provided! Please provide the path to the figma2dev_config.properties file as the second argument.");
            return;
        }
        
        Properties config = new Properties();
        try (FileInputStream fis = new FileInputStream(configFile)) {
            config.load(fis);
            System.out.println("Loaded config file: " + configFile);
        } catch (Exception e) {
            System.err.println("figma2dev_config.properties file could not be located in the provided directory: " + configFile + ". Please make sure the figma2dev_config.properties file exists.");
            return;
        }

        // Parse properties from config file:
        String prefix = config.getProperty("prefix");
        String keylength = config.getProperty("keylength");
        String suffix = config.getProperty("suffix");
        String keyCounterStart = config.getProperty("keyCounterStart");
        Integer startingCounter = Integer.parseInt(keyCounterStart); // Save initial counter value to check later if it has changed
        String baseResourceFile = topDirectory + "/" + config.getProperty("baseResourceFile");

        // If the keylength is empty, throw error:
        if (StringUtils.isBlank(keylength) || !StringUtils.isNumeric(keylength)) {
            System.err.println("keylength property in figma2dev_config.properties cannot be empty and must be a valid number.");
            return;
        }

        // If the suffix is "counter" and...
        if (suffix == "counter") {
            // If the counter start value is empty or is not a valid number, throw error:
            if (StringUtils.isBlank(keyCounterStart) || !StringUtils.isNumeric(keyCounterStart)) {
                System.err.println("keyCounterStart property in figma2dev_config.properties cannot be empty and must be a valid number when suffix is set to 'counter'.");
                return;
            } 
            // If the counter start value is less than zero, throw error:
            else if (Integer.parseInt(keyCounterStart) < 0) {
                System.err.println("keyCounterStart property in figma2dev_config.properties must be a non-negative number when suffix is set to 'counter'.");
                return;
            }
        }

        // If the baseResourceFileLocale is empty, throw error:
        if (StringUtils.isBlank(baseResourceFile)) {
            System.err.println("baseResourceFile property in figma2dev_config.properties cannot be empty.");
            return;
        }
        
        // Check that the base resource file exists, throw error if not (or cannot be found):
        File baseFile = new File(baseResourceFile);
        if (!baseFile.exists()) {
            System.err.println("Base resource file specified in baseResourceFile property in figma2dev_config.properties cannot be located at: " + baseResourceFile);
            return;
        }

        System.out.println("\nConfig Properties:");
        System.out.println("Key Prefix: " + prefix);
        System.out.println("Value Split Length: " + keylength);
        System.out.println("Key Suffix: " + suffix);
        System.out.println("Key Starting Counter Value: " + keyCounterStart);
        System.out.println("Base Resource File: " + baseResourceFile);
        System.out.println("-----------------------------------\n");

        // Initialize key map to store generated keys:
        Map<String, String> keysMap = new HashMap<>();

        // Initialize Jackson ObjectMapper
        ObjectMapper mapper = new ObjectMapper();
        mapper.enable(SerializationFeature.INDENT_OUTPUT);
        DefaultPrettyPrinter prettyprint = new DefaultPrettyPrinter().withoutSpacesInObjectEntries().withArrayIndenter(new DefaultPrettyPrinter.NopIndenter());
        ObjectWriter objWriter = mapper.writer().with(prettyprint);
        
        // Read or create mapping.json
        String mappingJsonPath = topDirectory + "/keys/mapping.json";
        List<Map<String, Object>> mappingList = new ArrayList<>();
        File mappingFile = new File(mappingJsonPath);
        if (mappingFile.exists()) {
            System.out.println("Found existing mapping.json at " + mappingJsonPath + ". Loading...\n");
            mappingList = mapper.readValue(mappingFile, new TypeReference<List<Map<String, Object>>>() {});
        } else {
            System.out.println("No existing mapping.json found at " + mappingJsonPath + ". A new mapping.json will be created.\n");
        }
        
        // Build a map from nodeID for faster lookup
        Map<String, Map<String, Object>> mappingByNodeId = new HashMap<>();
        for (Map<String, Object> obj : mappingList) {
            mappingByNodeId.put((String) obj.get("nodeID"), obj);
        }

        // Process the base English resource file and generate keys based on figma2dev_config.properties settings
        System.out.println("Processing Base Resource File: " + topDirectory + "/" + baseResourceFile + "\n");
        Date keygen_start_time = new Date();

        Map<String, String> baseTranslation = mapper.readValue(
            new File(baseResourceFile),
            new TypeReference<Map<String, String>>() {}
        );

        System.out.println(baseTranslation.size() + " entries found in base resource file.\n"); // Debugging statement

        long timestamp;
        for (Map.Entry<String, String> entry : baseTranslation.entrySet()) {
            String nodeID = entry.getKey();
            String value = entry.getValue();

            if (nodeID == "{" || nodeID == "}") {
                continue;
            }

            /* Check existing mapping array BEFORE GENERATING keys to see if the node already has a generated key
                - If it does, just update the value in the mapper file if needed and use the existing generated key
                - If it doesn't, use the counter value from the figma2dev_config.properties to generate a new key
            */

            if (mappingByNodeId.containsKey(nodeID)) {
                System.out.println("- Node ID '" + nodeID + "' found in mapping array. A new key does not need to be generated, updating JSON value..."); // Debugging statement

                // Existing mapping found...
                Map<String, Object> existingObj = mappingByNodeId.get(nodeID);

                // Add existing generated key to map
                String existingGenKey = (String) existingObj.get("key");
                keysMap.put(nodeID, existingGenKey);

                // Update value if changed
                String existingValue = (String) existingObj.get("value");
                if (!existingValue.equals(value)) {
                    timestamp = System.currentTimeMillis() / 1000L;

                    existingObj.put("value", value);
                    existingObj.put("lastChanged", timestamp);
                    System.out.println("   - Updated original value: " + existingValue + " to new value: " + value + " for nodeID: " + nodeID + ".\n");
                } else {
                    System.out.println("   - JSON string value is the same for " + nodeID + ", no need to update.\n");
                }
            } else {
                System.out.println("- Node ID '" + nodeID + "' was not found in mapping array, generating new key..."); // Debugging statement

                String cleanedValue = value.replaceAll("[^a-zA-Z0-9]", ""); // Remove all non alphanumeric characters from value

                String generatedKey = "";
                if (cleanedValue.length() >= Integer.parseInt(keylength)) { // Check if string is longer than the specified keylength in config
                    generatedKey = cleanedValue.substring(0, Integer.parseInt(keylength));
                } else {
                    generatedKey = cleanedValue; // If the cleaned value is shorter than the keylength, just use the whole value
                }

                // Append prefix to generated key if it is not empty:
                if (!StringUtils.isBlank(prefix)) {
                    generatedKey = prefix + "_" + generatedKey;
                }

                // Append suffix to generated key if it is not empty:
                if (!StringUtils.isBlank(suffix)) {
                    if (suffix.equals("counter")) {
                        generatedKey = generatedKey + "_" + Integer.parseInt(keyCounterStart);
                        keyCounterStart = String.valueOf(Integer.parseInt(keyCounterStart) + 1); // Increment counter for next key
                    } else {
                        generatedKey = generatedKey + "_" + suffix;
                    }
                }

                timestamp = System.currentTimeMillis() / 1000L;

                Map<String, Object> obj = mappingByNodeId.getOrDefault(nodeID, new LinkedHashMap<>());
                obj.put("key", generatedKey);
                obj.put("value", value);
                obj.put("nodeID", nodeID);
                obj.put("lastChanged", timestamp);
                mappingByNodeId.put(nodeID, obj);

                keysMap.put(nodeID, generatedKey);
                System.out.println("   - Generated Key: " + generatedKey + " for nodeID: " + nodeID + "\n");
            }
        }
        Date keygen_end_time = new Date();
        long keygen_timeDiff = keygen_end_time.getTime() - keygen_start_time.getTime();
        System.out.println("Key generation + value updates took: " + keygen_timeDiff / 1000 + " seconds (" + keygen_timeDiff / (60 * 1000) + " minutes)\n");

        // Replace the keyCounterStart value in the properties file with the new counter value (if changed)
        if (Integer.parseInt(keyCounterStart) != startingCounter) {
            System.out.println("-----------------------------------\n");
            config.setProperty("keyCounterStart", keyCounterStart);
            try (FileOutputStream fos = new FileOutputStream(configFile)) {
                config.store(fos, null);
                System.out.println("Updated keyCounterStart value in figma2dev_config.properties from: " + startingCounter + " to: " + keyCounterStart + "\n");
            } catch (Exception e) {
                System.err.println("Could not update keyCounterStart value in figma2dev_config.properties file, latest value remains at: " + startingCounter + ". Please make sure the file is not read-only.\n");
            }
        }

        System.out.println("-----------------------------------\n");
        System.out.println("Generating files...\n");
        Date filegen_start_time = new Date();

        // Write updated mapping.json
        List<Map<String, Object>> updatedMappingList = new ArrayList<>(mappingByNodeId.values());
        Files.createDirectories(Paths.get(topDirectory + "/keys"));
        objWriter.writeValue(new File(mappingJsonPath), updatedMappingList);
        System.out.println("Created/Updated mapping.json at: " + mappingJsonPath);

        // Create + move the keys.json file over to the 'keys' directory as "translation.json" (to display keys in Figma file)
        File keysTranslationJsonFile = new File(topDirectory + "/keys/translation.json");
        try {
            objWriter.writeValue(keysTranslationJsonFile, keysMap);
            System.out.println("Created translation.json for \"keys\" locale at: " + topDirectory + "/keys/translation.json\n");
        } catch (IOException e) {
            System.err.println("Error creating translation.json for \"keys\" locale at: " + topDirectory + "/keys/translation.json");
            e.printStackTrace();
        }


        // Create base messages.properties
        String baseLocale = config.getProperty("baseResourceFile").split("/")[0];
        String basePropertiesPath = topDirectory + "/" + baseLocale + "/messages.properties";
        try (PrintWriter writer = new PrintWriter(basePropertiesPath, StandardCharsets.UTF_8)) {
            for (Map.Entry<String, String> entry : baseTranslation.entrySet()) {
                if (keysMap.get(entry.getKey()) != null) { // Only write to properties file if the nodeID exists in the keys map
                    writer.println(keysMap.get(entry.getKey()) + "=" + entry.getValue());
                }
            }
        }
        System.out.println("Created messages.properties for base locale: '" + baseLocale + "' at " + basePropertiesPath);


        // Create messages.properties for all other locales
        File[] localeDirs = new File(topDirectory).listFiles(File::isDirectory);
        if (localeDirs != null) {
            for (File dir : localeDirs) {
                String locale = dir.getName(); // Get locale from directory path

                if (locale.equals(baseLocale) || locale.equals("keys")) continue; // If the directory is the base locale or the keys locale, skip them

                File translationFile = new File(dir, "translation.json");

                // If a translation.json file doesn't exist for the locale, skip it
                if (!translationFile.exists()) {
                    System.out.println("A translation.json file could not be found for locale directory: " + locale + ", a corresponding properties file will not be generated.");
                    continue;
                }

                Map<String, String> translation = mapper.readValue(
                        translationFile,
                        new TypeReference<Map<String, String>>() {}
                );

                String propertiesPath = dir.getAbsolutePath() + "/messages.properties";
                try (PrintWriter writer = new PrintWriter(propertiesPath, StandardCharsets.UTF_8)) {
                    for (Map.Entry<String, String> entry : translation.entrySet()) {
                        if (keysMap.get(entry.getKey()) != null) { // Only write to properties file if the nodeID exists in the keys map
                            writer.println(keysMap.get(entry.getKey()) + "=" + entry.getValue());
                        }
                    }
                }
                System.out.println("Created messages.properties for locale: '" + locale + "' at " + propertiesPath);
            }
        }

        Date filegen_end_time = new Date();
        long filegen_timeDiff = filegen_end_time.getTime() - filegen_start_time.getTime();
        System.out.println("\nFile generation took: " + filegen_timeDiff / 1000 + " seconds (" + filegen_timeDiff / (60 * 1000) + " minutes)");
    }
}