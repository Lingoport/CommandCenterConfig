# Default XML Parsers
Some standard XML resource files are parsed without a custom parser, since those schemas are known. 
See: https://wiki.lingoport.com/LRM_XML_Support#OOTB_XML_Parser_Definitions
* resx
* android

# Custom XML Parsers
For other XML resource files, an xmlParser.xml specifies how to parse them.
See: https://wiki.lingoport.com/LRM_XML_Support#Formatting_xml_files

As an example, if resx files were non-standard, a resx xmlParser.xml file is provided in this directory.

# How to set a custom parser
In Command Center as an Administrator, 
* Navigate to Configuration > System Files
* Add an xmlParser.xml file (pick the + to add file, pick the Git URL, etc.)

In Command Center, as an Administrator or a Manager
* In a Localyzer project resource file format configuration, for the custom XML file format, pick custom and set the xmlParser.xml system file set above.
