# Nested en-US.json -> flat en-XL.json with a #reference secondary key

The repository holds its English source as a **nested** JSON file, while every
translated file is **flat** with dotted keys and carries a `#reference`
secondary key holding the English source string:

* `locales/en-US.json` (repository source, nested)

<pre>
{
  "common": {
    "retention": {
      "manualHold": "Manual hold",
      "standardTime": "Standard {{time}}"
    }
  }
}
</pre>

* `locales/es-XL.json` (repository target, flat + `#reference`)

<pre>
{
  "common.retention.manualHold": "Retención manual",
  "common.retention.manualHold.#reference": "Manual hold",
  "common.retention.standardTime": "Estándar {{time}}",
  "common.retention.standardTime.#reference": "Standard {{time}}"
}
</pre>

LRM cannot have one project where the source and the targets use two different
layouts, so this transform presents the source in the target layout:

* `locales/en-XL.json` (LRM OOTB source, flat + `#reference`)

<pre>
{
  "common.retention.manualHold": "Manual hold",
  "common.retention.manualHold.#reference": "Manual hold",
  "common.retention.standardTime": "Standard {{time}}",
  "common.retention.standardTime.#reference": "Standard {{time}}"
}
</pre>

For the source file the reference *is* the English value, so the two entries are
identical. Every other locale keeps the English text in `#reference` while the
main key holds the translation.

## The three scripts

| Script | Does |
|---|---|
| `transform_from_repo.sh` | For every `en-US.json` in the repository, writes a sibling `en-XL.json`: nested objects flattened to dotted keys, plus a `<key>.#reference` entry after each string. The list of source files is kept in `${PROJECT_TMP_DIR}/input_files.txt`. |
| `transform_to_repo.sh` | For every `en-XL.json` in `${FULL_LIST_PATH}`, rebuilds the nested `en-US.json` and drops the `#reference` entries, then deletes the `en-XL.json`. Target files are already in the repository layout and are left alone. Any `en-XL.json` from `input_files.txt` that was not in `${FULL_LIST_PATH}` is removed, so the transform leaves nothing behind. |
| `transform_files_list.sh` | Rewrites `<path>/en-XL.json` to `<path>/en-US.json` in the file list it is given. Target file names are unchanged. |

## Configuration in Command Center

* The Localyzer project **file location pattern** must match `*-XL.json` only.
  That is the reason for the `en-US` -> `en-XL` rename: it gives source and
  targets one uniform pattern and keeps the nested `en-US.json` out of the scan.
* The JSON resource file format must declare `#reference` as the **secondary
  key**, so that it is treated as context for the translators rather than as a
  string to translate.
* `jq` must be available on the Command Center host. Both scripts stop with an
  error if it is not.

## Notes and limits

* Running `transform_from_repo.sh` twice is a no-op: keys already ending in
  `.#reference` are regenerated, not nested a second time.
* Non-string leaves (numbers, booleans, `null`) and empty objects or arrays are
  carried through untouched and get no `#reference` entry. They round-trip to
  the exact same JSON.
* Arrays are flattened with their index (`list.0`, `list.1`) and rebuilt on the
  way back. The one ambiguity of the dotted notation: an object whose keys
  really are `"0"`, `"1"`, ... comes back as an array.
* A key that contains a literal `.` cannot be distinguished from a nesting
  level and will come back split into two levels.
