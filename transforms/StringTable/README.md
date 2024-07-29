## Transform StringTable xml files into a set of txml files, one per context ##
### StringTable XML  File Format ###
A StringTable file is made up of a number of "ui" stanzas, each containing a set of key value pairs, as shown in an illustrative example below.

* PortalUI_en.xml:

<pre>
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE StringTable>
<StringTable>
  <ui name="abaquscae" widgetName="portal_abaquscae">
    <string id=".jobs.columns">Jobs</string>
    <string id=".jobsLabel.text">Select jobs to run (one is required)</string>
  </ui>
  <ui name="adamscar" widgetName="portal_adamscar">
    <string id=".analysisnameLabel.text">Analysis name</string>
    <string id=".appnameLabel.text">Application name</string>
    <string id=".custominputLabel.text">Input</string>
    <string id=".customoutput.noneHint">None</string>
  </ui>
  <ui name="adamschassis" widgetName="portal_adamschassis">
    <string id=".appnameLabel.text">Application name</string>
    <string id=".runOptsGrpBox.title">Run Options</string>
  </ui>
</StringTable>
</pre>

### Transform into txml files ###
The structure is flattened so that all strings are at the same level. Each ui stanza is delimited by  corresponding comments. 
Files must be sent full files: sending deltas may incur errors in terms of structure when merging the deltas with the wrong comments around the strings 
The above file would be broken into:
* PortalUI_en.txml
  <pre>
    <?xml version="1.0" encoding="UTF-8"?>
<StringTable>
<!-- <ui name="abaquscae" widgetName="portal_abaquscae"> -->
  <string id="abaquscae.jobs.columns">Jobs</string>
  <string id="abaquscae.jobsLabel.text">Select jobs to run (one is required)</string>
  <!-- </ui> -->
<!-- <ui name="adamscar" widgetName="portal_adamscar"> -->
  <string id="adamscar.analysisnameLabel.text">Analysis name</string>
  <string id="adamscar.appnameLabel.text">Application name</string>
  <string id="adamscar.custominputLabel.text">Input</string>
  <string id="adamscar.customoutput.noneHint">None</string>
  <!-- </ui> -->
<!-- <ui name="adamschassis" widgetName="portal_adamschassis"> -->
  <string id="adamschassis.appnameLabel.text">Application name</string>
  <string id="adamschassis.runOptsGrpBox.title">Run Options</string>
  <!-- </ui> -->

</StringTable>
</pre>

### On-boarding###
Make sure the transform is set when on-boarding and the files are txml files, not xml files. 


