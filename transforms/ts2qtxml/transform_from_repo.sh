#!/bin/bash
#
# ts2qtxml : transform_from_repo.sh
#
# Repository format -> LRM format
#
# Qt Linguist .ts files in which every <message> is preceded by a <name>
# sibling holding the string ID:
#
#   <context>
#     <name>ID_ABOUT</name>
#     <message>
#       <source>About</source>
#       <translation>About</translation>
#     </message>
#     ...
#
# are written next to the original as .qtxml files where the ID becomes an
# attribute of <message> (Qt's own ID-based message form):
#
#   <context>
#     <message id="ID_ABOUT">
#       <source>About</source>
#       <translation>About</translation>
#     </message>
#
# The qtxml xmlParser.xml (xmlParsers/qtxml/xmlParser.xml) then reads
# message/@id as TOKEN_KEY and translation as TOKEN_VALUE.
#
# Environment variables set by Command Center:
#   CLIENT_SOURCE_DIR  top-level workspace directory for the project
#   TRANSFORM_DIR      this transform's directory
#   PROJECT_TMP_DIR    a temporary directory
#
# Optional environment variable:
#   TS2QTXML_FIND_NAME  find -name pattern for repository files (default: *.ts)
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

  if [ -n "${CLIENT_SOURCE_DIR}" ]; then
    cd "${CLIENT_SOURCE_DIR}" || { echo " ERROR: cannot cd to ${CLIENT_SOURCE_DIR}"; return 1; }
  fi
  echo " Working directory: $(pwd)"

  local TMP_DIR="${PROJECT_TMP_DIR:-/tmp}"
  local INPUT_LIST="${TMP_DIR}/ts2qtxml_input_files.txt"
  local PATTERN="${TS2QTXML_FIND_NAME:-*.ts}"

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

    if xmlstarlet ed \
         -i '/TS/context/message' -t attr -n id -v '' \
         -u '/TS/context/message/@id' -x 'string(../preceding-sibling::name[1])' \
         -d '/TS/context/name' \
         "${FILEPATH}" > "${TMP_TARGET}"; then
      mv "${TMP_TARGET}" "${TARGET}"
      echo "   ${FILEPATH} -> ${TARGET}"
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
