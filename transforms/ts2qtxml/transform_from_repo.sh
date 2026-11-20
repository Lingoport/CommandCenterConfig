#!/bin/bash
#
# ts2qtxml : transform_from_repo.sh
#
# Repository format -> LRM format
#
# Qt Linguist .ts files in which every <message> is preceded by a <name>
# holding the string ID, usually one <context> per entry:
#
#   <context>
#     <name>ID_ABOUT</name>
#     <message>
#       <source>About</source>
#       <translation>About</translation>
#     </message>
#   </context>
#
# (several <name>/<message> pairs in one <context> are also accepted)
#
# are written next to the original as .qtxml files without <context>, where
# each <message> sits directly under <TS> and the ID becomes its id attribute
# (Qt's own ID-based message form):
#
#   <TS ...>
#     <message id="ID_ABOUT">
#       <source>About</source>
#       <translation>About</translation>
#     </message>
#   </TS>
#
# The qtxml xmlParser.xml (xmlParsers/qtxml/xmlParser.xml) then reads
# message/@id as TOKEN_KEY and translation as TOKEN_VALUE.
# The conversion is done by ts2qtxml.xsl, in this directory.
#
# Unfinished entries: in target-locale files (<TS language> differs from
# <TS sourcelanguage>), entries whose <translation type="unfinished"> are
# left out of the .qtxml. Localyzer then sees them as missing, like entries
# absent from the file, and sends them for translation. The source-locale
# file is never filtered, so no source string is lost.
#
# Environment variables set by Command Center:
#   CLIENT_SOURCE_DIR  top-level workspace directory for the project
#   TRANSFORM_DIR      this transform's directory
#   PROJECT_TMP_DIR    a temporary directory
#
# Optional environment variables:
#   TS2QTXML_FIND_NAME         find -name pattern for repository files (default: *.ts)
#   TS2QTXML_DROP_UNFINISHED   1 (default) drops unfinished entries from
#                              target-locale files; 0 keeps them
#
# Requires: xmlstarlet
#
# Files ending in .ts that are not Qt TS XML (TypeScript, for instance)
# are skipped. Qt TS files that do not follow the one-<name>-per-<message>
# layout are skipped with a warning, so nothing is half-transformed.

ts2qtxml_from_repo() (
  # Runs in a subshell: the cd and variables do not leak to the caller,
  # whether this script is executed or sourced.

  echo " ------------------------------------------------"
  echo " ts2qtxml: Qt .ts -> .qtxml"
  echo " ------------------------------------------------"

  if ! command -v xmlstarlet >/dev/null 2>&1; then
    echo " ERROR: xmlstarlet is required by the ts2qtxml transform"
    return 1
  fi

  local XSL
  XSL="$(cd "${TRANSFORM_DIR:-$(dirname "${BASH_SOURCE[0]}")}" && pwd)/ts2qtxml.xsl"
  if [ ! -f "${XSL}" ]; then
    echo " ERROR: stylesheet not found: ${XSL}"
    return 1
  fi

  if [ -n "${CLIENT_SOURCE_DIR}" ]; then
    cd "${CLIENT_SOURCE_DIR}" || { echo " ERROR: cannot cd to ${CLIENT_SOURCE_DIR}"; return 1; }
  fi
  echo " Working directory: $(pwd)"

  local TMP_DIR="${PROJECT_TMP_DIR:-/tmp}"
  local INPUT_LIST="${TMP_DIR}/ts2qtxml_input_files.txt"
  local PATTERN="${TS2QTXML_FIND_NAME:-*.ts}"
  local DROP_UNFINISHED="${TS2QTXML_DROP_UNFINISHED:-1}"
  local LANG_ATTR SRC_LANG_ATTR UNFINISHED DROP DROP_NOTE

  find . \( -path ./.git -o -name node_modules \) -prune -o \
       -type f -name "${PATTERN}" -print > "${INPUT_LIST}"

  local TRANSFORMED=0 SKIPPED=0 FAILED=0
  local FILEPATH ROOT BAD_CONTEXTS BAD_ORDER HAS_ID DUPES TARGET TMP_TARGET

  while IFS= read -r FILEPATH; do
    [ -z "${FILEPATH}" ] && continue

    # Only Qt TS XML documents: root element must be <TS>
    ROOT=$(xmlstarlet sel -t -v 'name(/*)' "${FILEPATH}" 2>/dev/null)
    if [ "${ROOT}" != "TS" ]; then
      echo "   skip (not a Qt TS file): ${FILEPATH}"
      SKIPPED=$((SKIPPED + 1))
      continue
    fi

    # Layout checks:
    #  - each <context> has as many <name> as <message> elements
    #  - each <message> has exactly one more preceding <name> than preceding
    #    <message>, i.e. its own <name> comes right before it in order
    #  - no <message> already carries an id (it would be lost on the way back)
    BAD_CONTEXTS=$(xmlstarlet sel -t -v 'count(/TS/context[count(name) != count(message)])' "${FILEPATH}")
    BAD_ORDER=$(xmlstarlet sel -t -v 'count(/TS/context/message[count(preceding-sibling::name) != count(preceding-sibling::message) + 1])' "${FILEPATH}")
    HAS_ID=$(xmlstarlet sel -t -v 'count(/TS/context/message[@id])' "${FILEPATH}")

    if [ "${BAD_CONTEXTS}" != "0" ] || [ "${BAD_ORDER}" != "0" ] || [ "${HAS_ID}" != "0" ]; then
      echo "   WARNING skip (unexpected layout: ${BAD_CONTEXTS} context(s) with name/message count mismatch," \
           "${BAD_ORDER} message(s) not preceded by their name, ${HAS_ID} message(s) already with id): ${FILEPATH}"
      SKIPPED=$((SKIPPED + 1))
      continue
    fi

    DUPES=$(xmlstarlet sel -t -v 'count(/TS/context/name[. = preceding::name])' "${FILEPATH}")
    if [ "${DUPES}" != "0" ]; then
      echo "   WARNING ${DUPES} duplicate ID(s) in ${FILEPATH}; Localyzer will report them as duplicate keys"
    fi

    TARGET="${FILEPATH%.ts}.qtxml"
    TMP_TARGET="${TARGET}.tmp"

    # Unfinished entries are dropped from target-locale files only
    LANG_ATTR=$(xmlstarlet sel -t -v '/TS/@language' "${FILEPATH}")
    SRC_LANG_ATTR=$(xmlstarlet sel -t -v '/TS/@sourcelanguage' "${FILEPATH}")
    UNFINISHED=$(xmlstarlet sel -t -v 'count(/TS/context/message[translation/@type="unfinished"])' "${FILEPATH}")
    DROP=0
    DROP_NOTE=""
    if [ "${UNFINISHED}" != "0" ]; then
      if [ "${DROP_UNFINISHED}" != "1" ]; then
        DROP_NOTE=" (${UNFINISHED} unfinished kept: TS2QTXML_DROP_UNFINISHED=${DROP_UNFINISHED})"
      elif [ -z "${LANG_ATTR}" ] || [ "${LANG_ATTR}" = "${SRC_LANG_ATTR}" ]; then
        DROP_NOTE=" (${UNFINISHED} unfinished kept: source-locale file, language='${LANG_ATTR}')"
        echo "   WARNING ${UNFINISHED} unfinished entr(y/ies) in source-locale file ${FILEPATH}"
      else
        DROP=1
        DROP_NOTE=" (${UNFINISHED} unfinished dropped)"
      fi
    fi

    if xmlstarlet tr "${XSL}" -s drop_unfinished="${DROP}" "${FILEPATH}" > "${TMP_TARGET}"; then
      mv "${TMP_TARGET}" "${TARGET}"
      echo "   ${FILEPATH} -> ${TARGET}${DROP_NOTE}"
      TRANSFORMED=$((TRANSFORMED + 1))
    else
      rm -f "${TMP_TARGET}"
      echo "   ERROR transforming ${FILEPATH}"
      FAILED=$((FAILED + 1))
    fi
  done < "${INPUT_LIST}"

  echo " ts2qtxml: ${TRANSFORMED} transformed, ${SKIPPED} skipped, ${FAILED} failed"
  [ "${FAILED}" -eq 0 ]
)

ts2qtxml_from_repo "$@"
RC=$?
return ${RC} 2>/dev/null || exit ${RC}
