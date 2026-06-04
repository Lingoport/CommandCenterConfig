# resx_text transform

This transform is for .NET WinForms `.resx` files where only the visible UI strings (`.Text` properties) need to be translated. A typical `.resx` file contains many non-translatable entries — coordinates, sizes, fonts, tab indices, and designer metadata — alongside the actual text strings. This transform strips everything except `.Text` entries before sending files to Localyzer.

## Repository file naming

The source English file has no locale suffix, and translated files use a two-part extension:

* `AboutForm.resx` — English source (no locale)
* `AboutForm.de.resx` — German translation
* `AboutForm.zh-Hans.resx` — Simplified Chinese translation

## What the transform does

`transform_from_repo.sh` scans for source `.resx` files (files with a single dot in the filename, i.e. no locale suffix) and produces an `.en.resx` file for each one containing only the `<data>` entries whose `name` attribute ends in `.Text`. For example:

```xml
<data name="btOk.Text" xml:space="preserve">
  <value>OK</value>
</data>
<data name="$this.Text" xml:space="preserve">
  <value>About</value>
</data>
```

Non-translatable entries such as `btOk.Location`, `btOk.Size`, and `>>btOk.Name` are excluded.

`transform_to_repo.sh` is a no-op. Translated files (e.g. `AboutForm.de.resx`) come back from Localyzer already in the correct repository format containing only the translated `.Text` entries, so no conversion is needed.

`transform_files_list.sh` is a no-op. The translated locale filenames match the repository naming convention directly.

## On-boarding in Command Center

Set the resource file format to the standard **resx** type. The transform handles filtering — no custom `xmlParser.xml` is needed.
