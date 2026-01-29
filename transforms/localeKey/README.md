# "locale": "en-US"
This is a simple Transform when a JSON resource file has a key/alue pair for the locale. This is unusual, as the locale is typically 
* on a directory above the file (en-US/messages.json)
* in the file name (locales/messages_en_US.json)
* sometimes as the root { "en=US" : { ...} }

In the files of interest for this transform, the locale is a key/value pair inside the file
* "locale": "en-US",

## File Example:

* en-US/messages.json:

<pre>
{
  "locale": "en-US",
  "translations": {
    "processo301": "Processor Terms and Conditions",
    "cardterm302": "Card Terms and Conditions",
  }
}
</pre>

When translating or pseudo-localizing or instrumenting files, the transform on the way back to the repository will make sure that the locale will match the directory above, so:
* "locale": "eo",  if a  pseudo-localized file is pushed under eo/messages.json
* "locale": "fr-CA", if a French Canadian file is pushed under fr-CA/messages.json
* etc.

