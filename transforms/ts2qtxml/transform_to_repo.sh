#!/bin/bash
#
# ts2qtxml : transform_to_repo.sh
#
# LRM format -> repository format
#
# Translated or pseudo-localized .qtxml files (no <context>):
#
#   <TS ...>
#     <message id="ID_ABOUT">
#       <source>About</source>
#       <translation>À propos</translation>
#     </message>
#   </TS>
#
# are written back as Qt .ts files in the source file layout: one <context>
# per entry, with the ID moved back into a <name> before its <message>:
#
#   <!DOCTYPE TS >
#   <TS ...>
#     <context>
#       <name>ID_ABOUT</name>
#       <message>
#         <source>About</source>
#         <translation>À propos</translation>
#       </message>
#     </context>
#   </TS>
#
# and the <TS language="..."> attribute set to the locale found at the end
# of the file name (e.g. strings_fr_FR.qtxml -> language="fr_FR").
# The conversion is done by qtxml2ts.xsl, in this directory.
#
# Environment variables set by Command Center:
#   CLIENT_SOURCE_DIR  top-level workspace directory for the project
#   TRANSFORM_DIR      this transform's directory
#   PROJECT_TMP_DIR    a temporary directory
#   FULL_LIST_PATH     file listing the .qtxml files to transform back
#                      ($1 is used if FULL_LIST_PATH is not set)
#
# Optional environment variables:
#   TS2QTXML_INDENT    indentation of the written .ts files (default: 4,
#                      matching the source files). 0 skips reformatting.
#   TS2QTXML_DOCTYPE   DOCTYPE line written after the XML declaration
#                      (default: '<!DOCTYPE TS >', as in the source files;
#                      empty: no DOCTYPE)
#
# Requires: xmlstarlet

ts2qtxml_to_repo() (
  echo " ------------------------------------------------"
  echo " ts2qtxml: .qtxml -> Qt .ts"
  echo " ------------------------------------------------"

  if ! command -v xmlstarlet >/dev/null 2>&1; then
    echo " ERROR: xmlstarlet is required by the ts2qtxml transform"
    return 1
  fi

  local XSL
  XSL="$(cd "${TRANSFORM_DIR:-$(dirname "${BASH_SOURCE[0]}")}" && pwd)/qtxml2ts.xsl"
  if [ ! -f "${XSL}" ]; then
    echo " ERROR: stylesheet not found: ${XSL}"
    return 1
  fi

  local LIST="${FULL_LIST_PATH:-$1}"
  if [ -z "${LIST}" ] || [ ! -f "${LIST}" ]; then
    echo " ERROR: no file list (FULL_LIST_PATH or \$1): '${LIST}'"
    return 1
  fi

  if [ -n "${CLIENT_SOURCE_DIR}" ]; then
    cd "${CLIENT_SOURCE_DIR}" || { echo " ERROR: cannot cd to ${CLIENT_SOURCE_DIR}"; return 1; }
  fi
  echo " Working directory: $(pwd)"
  echo " Files to transform (${LIST}):"
  cat "${LIST}"
  echo ""

  local INDENT="${TS2QTXML_INDENT:-4}"
  local DOCTYPE="${TS2QTXML_DOCTYPE-<!DOCTYPE TS >}"
  # Locale at the end of the file name: _fr, _fr_FR, -pt-BR, _zh_Hant_TW, _es_419 ...
  local LOCALE_RE='[_.-]([a-z]{2,3}([_-][A-Z][a-z]{3})?([_-]([A-Z]{2}|[0-9]{3}))?)\.qtxml$'

  local TRANSFORMED=0 FAILED=0
  local FILEPATH TARGET TMP_TARGET LOCALE

  while IFS= read -r FILEPATH || [ -n "${FILEPATH}" ]; do
    FILEPATH="${FILEPATH%$'\r'}"
    [ -z "${FILEPATH}" ] && continue
    case "${FILEPATH}" in
      *.qtxml) ;;
      *) echo "   skip (not .qtxml): ${FILEPATH}"; continue ;;
    esac
    if [ ! -f "${FILEPATH}" ]; then
      echo "   ERROR file not found: ${FILEPATH}"
      FAILED=$((FAILED + 1))
      continue
    fi

    TARGET="${FILEPATH%.qtxml}.ts"
    TMP_TARGET="${TARGET}.tmp"

    LOCALE=""
    if [[ "$(basename "${FILEPATH}")" =~ ${LOCALE_RE} ]]; then
      LOCALE="${BASH_REMATCH[1]//-/_}"
    fi

    if [ -z "${LOCALE}" ]; then
      echo "   WARNING no locale found in file name, <TS language> left as is: ${FILEPATH}"
    fi

    # One <context> per <message>, id moved back into <name>
    if xmlstarlet tr "${XSL}" -s language="${LOCALE}" "${FILEPATH}" > "${TMP_TARGET}"; then
      if [ "${INDENT}" != "0" ]; then
        # Re-indent like lupdate, and write empty <source>/<translation>
        # as open/close pairs rather than self-closing tags
        if xmlstarlet fo -s "${INDENT}" "${TMP_TARGET}" \
             | sed -E 's#<(source|translation)( [^>]*)?/>#<\1\2></\1>#g' > "${TMP_TARGET}.fo"; then
          mv "${TMP_TARGET}.fo" "${TMP_TARGET}"
        else
          rm -f "${TMP_TARGET}.fo"
          echo "   WARNING could not reformat, keeping unformatted output: ${TARGET}"
        fi
      fi
      # XSLT 1.0 cannot write a DOCTYPE without a system id: add it here
      if [ -n "${DOCTYPE}" ]; then
        sed -i "1{/^<?xml/a ${DOCTYPE}
}" "${TMP_TARGET}"
      fi
      mv "${TMP_TARGET}" "${TARGET}"
      echo "   ${FILEPATH} -> ${TARGET}${LOCALE:+ (language=${LOCALE})}"
      TRANSFORMED=$((TRANSFORMED + 1))
    else
      rm -f "${TMP_TARGET}"
      echo "   ERROR transforming ${FILEPATH}"
      FAILED=$((FAILED + 1))
    fi
  done < "${LIST}"

  echo " ts2qtxml: ${TRANSFORMED} transformed back, ${FAILED} failed"
  [ "${FAILED}" -eq 0 ]
)

ts2qtxml_to_repo "$@"
RC=$?
return ${RC} 2>/dev/null || exit ${RC}
