## Transform Qt .ts files with one `<name>` per `<message>` into .qtxml files ##

### Repository file format ###
Qt Linguist `.ts` files where the string ID is held in a `<name>` element placed
right before each `<message>`, all within a `<context>`:

* installer_en_US.ts

<pre>
<?xml version="1.0" encoding="utf-8"?>
<!DOCTYPE TS>
<TS version="2.1" language="en_US" sourcelanguage="en_US">
    <context>
        <name>ID_ABOUT</name>
        <message>
            <source>About</source>
            <translation>About</translation>
        </message>
        <name>ID_ACTIVATE_ONCLOUD_LICENSE</name>
        <message>
            <source>Activate OnCloud license</source>
            <translation>Activate OnCloud license</translation>
        </message>
    </context>
</TS>
</pre>

This layout cannot be described by an xmlParser.xml directly: the key (`<name>`)
and the value (`<translation>`) do not share a parent, and describing the
structure would take 5 elements (the limit is 4).
See https://wiki.lingoport.com/LRM_XML_Support

### Transformed (LRM) file format ###
`transform_from_repo.sh` writes a `.qtxml` file next to each `.ts` file, with
the ID moved onto the `<message>` as an `id` attribute (Qt's own ID-based
message form):

* installer_en_US.qtxml

<pre>
<?xml version="1.0" encoding="utf-8"?>
<!DOCTYPE TS>
<TS version="2.1" language="en_US" sourcelanguage="en_US">
  <context>
    <message id="ID_ABOUT">
      <source>About</source>
      <translation>About</translation>
    </message>
    <message id="ID_ACTIVATE_ONCLOUD_LICENSE">
      <source>Activate OnCloud license</source>
      <translation>Activate OnCloud license</translation>
    </message>
  </context>
</TS>
</pre>

It is parsed with `xmlParsers/qtxml/xmlParser.xml`:

<pre>
<?xml version="1.0" encoding="utf-8"?>
<context>
  <message id="TOKEN_KEY">
    <source></source>
    <translation>TOKEN_VALUE</translation>
  </message>
</context>
</pre>

`transform_to_repo.sh` reverses this for translated and pseudo-localized files:

* the `id` goes back into a `<name>` element right before its `<message>`
* `<TS language="...">` is set from the locale at the end of the file name
  (`installer_fr_FR.qtxml` -> `language="fr_FR"`, `misc_pt-BR.qtxml` -> `language="pt_BR"`)
* `<source>` is left as is (English), as Qt expects
* the file is re-indented with 4 spaces, like `lupdate` output

`transform_files_list.sh` renames `.qtxml` to `.ts` in the file lists.

### Which files are transformed ###
`transform_from_repo.sh` looks at every `*.ts` file under the workspace
(`.git` and `node_modules` excluded) and:

* skips files whose root element is not `<TS>` (TypeScript files, for instance)
* skips, with a warning, Qt TS files that do not follow the
  one-`<name>`-per-`<message>` layout (a standard Qt file with one `<name>` per
  context, for instance) or whose messages already carry an `id`
* warns about duplicate IDs, which Localyzer will report as duplicate keys

To narrow the files, set `TS2QTXML_FIND_NAME` (a `find -name` pattern, default `*.ts`).

### Requirements ###
* `xmlstarlet` on the Command Center server (also used by the StringTable transform)

### Options ###
| Variable | Default | Effect |
|---|---|---|
| `TS2QTXML_FIND_NAME` | `*.ts` | `find -name` pattern for repository files |
| `TS2QTXML_INDENT` | `4` | indentation of the `.ts` files written back; `0` keeps xmlstarlet's output unformatted |

### Known limitations ###
* `<TS>` attributes written on several lines in the original file end up on one line.
* An element placed between a `<name>` and its `<message>` (a `<comment>`, for instance)
  ends up before the `<name>` when transformed back.
* Empty `<source>`/`<translation>` elements are written as open/close pairs
  (`<translation type="unfinished"></translation>`), like `lupdate`.

### On-boarding ###
In Command Center, as an Administrator:
* Enable Maintenance Mode, then in Settings > System Files:
  * add this transform (`transforms/ts2qtxml`)
  * add the parser (`xmlParsers/qtxml/xmlParser.xml`)

In the Localyzer project:
* set the resource file format to custom XML with the `.qtxml` extension, using the qtxml xmlParser.xml
  (not `.ts`: the project works on the transformed files)
* check "Use transform script" and select `ts2qtxml`
* run a pseudo-localization first and check that the `.ts` files pushed back
  keep the English `<source>` and have the right `language` attribute
