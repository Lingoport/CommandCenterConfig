# strings*.txt -> strings*.properties
Simple transform scripts to go from 
* strings.txt, strings-fr.txt, strings-zh-Hant.txt 
to
* strings.properties, strings_fr.properties, strings_zh_Hant.properties

The strings*.txt have a simple format, all lines start in the first column or are empty
In the first column, if it's a pound sign (#), it's a comment, so kept exactly the same
If it's empty, keep the empty line
Otherwise, it's a key,value line, i.e. the , is like a properties =

For example, the strings.txt file to be translated is in the form:
<pre>
# Strings for use in GUI
#################################################
PushIfCommits,Push if commits
CloseButtonText,Close
ApplyButtonText,Apply
CancelButtonText,Cancel
</pre>

And the corresponding strings.properties will be:
<pre>
# Strings for use in GUI
#################################################
PushIfCommits=Push if commits
CloseButtonText=Close
ApplyButtonText=Apply
CancelButtonText=Cancel
</pre>
So both the filename, extension, and  content are transformed into a  standard resource file.
