## Example xlf for Command Center
### sample.en-US.xlf
A sample file to illustrate the type of xml file for a project to on-board with Command Center

### xmlParser.xml
This file would be used to parse the sample.en-US.xlf file. 

In Command Center, go to Settings > System Files
Add the xmlParser.xml to the xmlParser set of files, name it something like 'xlfParser'

When on-boarding a project with files like sample.en-US.xlf:
* On-board with custom resource files
* the suffix will be xlf
* the parser will be 'xlfParser' (or the name given in the System Files)
