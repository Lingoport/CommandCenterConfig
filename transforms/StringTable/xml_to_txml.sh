#!/bin/bash
#
# Special handling for .txml files
#
# Find all the files ending in .xml and move them to .txml
# The following environment variables need to be set:
#   CLIENT_SOURCE_DIR
#

echo  " ------------------------------------------------"
echo  " Find *.xml files "
echo  " ---------------------------"

# Find all the files ending in the 'xml'
XMLFILES="${PROJECT_TMP_DIR}/input_files.txt"

# the locale separator is underscore, _ 
#find . -name "*_*\.xml" -type f > "$XMLFILES"
find . -name "Solver_*\.xml" -type f > "$XMLFILES"
find . -name "Plot_*\.xml" -type f >> "$XMLFILES"
sed '/Portal_messages_..\.xml/d' "$XMLFILES"

echo "Files to transform: "
cat "$XMLFILES"

# For each file to transform, create as many subfiles,
# one per Context and one for strings outside context elements
cat "${XMLFILES}" | while read -r FILEPATH
do
  
  # Only transform files which are <StringTable> type
  if grep -q "<StringTable>" "${FILEPATH}"
  then
    SUFFIX=".xml"
    FILENAME=`basename $FILEPATH`
    DIRNAME=`dirname $FILEPATH`
    ROOTNAME=${FILENAME%$SUFFIX}
    TARGETFILE="${DIRNAME}/${ROOTNAME}.txml"
    echo " Transform [${FILEPATH}] -> [$TARGETFILE]"
    rm "${TARGETFILE}"
    touch "${TARGETFILE}"
  

    cat $FILEPATH | while read -r LINE
    do
      #echo "LINE: $LINE"

    #Context change
    if [[ "$LINE" == *"<Context"* ]]
      then
        NAME1=${LINE#*name=\"}
        CONTEXT=${NAME1%%\"*}
        #NAME1=${LINE%\">*}
        #CONTEXT=${NAME1##*\"}
        echo "Create the ${CONTEXT}_${ROOTNAME}.txml  file using xmlstarlet"
        TARGET_PATH="${DIRNAME}/${CONTEXT}_${ROOTNAME}.txml"
        xmlstarlet sel -t -c "/StringTable/Context[@name='${CONTEXT}']" "${FILEPATH}" > "${TARGET_PATH}"

        sed -i "s/id=\"/id=\"${CONTEXT}/g" "${TARGET_PATH}"
        sed -i 's/\(<Context.*\)/<!-- \1 -->/'   "${TARGET_PATH}"
        sed -i 's/\(<\/Context.*\)/<!-- \1 -->\n/'   "${TARGET_PATH}"

        cat "${TARGET_PATH}" >> "${TARGETFILE}"
        rm "${TARGET_PATH}"
      fi
    #context change, developper not being consistent ...
    if [[ "$LINE" == *"<context"* ]]
      then
        NAME1=${LINE#*name=\"}
        CONTEXT1=${NAME1%%\"*}
        # NAME1=${LINE%\">*}
        #CONTEXT1=${NAME1##*\"}
        echo "Create the ${CONTEXT1}_${ROOTNAME}.txml  file using xmlstarlet"
        TARGET_PATH="${DIRNAME}/${CONTEXT1}_${ROOTNAME}.txml"
        xmlstarlet sel -t -c "/StringTable/context[@name='${CONTEXT1}']" "${FILEPATH}" > "${TARGET_PATH}"

        sed -i "s/id=\"/id=\"${CONTEXT1}/g" "${TARGET_PATH}"
        sed -i 's/\(<context.*\)/<!-- \1 -->/'   "${TARGET_PATH}"
        sed -i 's/\(<\/context.*\)/<!-- \1 -->\n/'   "${TARGET_PATH}"

        cat "${TARGET_PATH}" >> "${TARGETFILE}"
        rm "${TARGET_PATH}"
      fi
    #Portal change
      if [[ "$LINE" == *"<Portal"* ]]
      then
       NAME1=${LINE#*name=\"}
       PORTAL=${NAME1%%\"*}
       # NAME1=${LINE%\">*}
       # PORTAL=${NAME1##*\"}
        echo "Create the ${PORTAL}_${ROOTNAME}.txml  file using xmlstarlet"
        TARGET_PATH="${DIRNAME}/${PORTAL}_${ROOTNAME}.txml"
        xmlstarlet sel -t -c "/StringTable/Portal[@name='${PORTAL}']" "${FILEPATH}" > "${TARGET_PATH}"

        sed -i "s/id=\"/id=\"${PORTAL}/g" "${TARGET_PATH}"
        sed -i 's/\(<Portal.*\)/<!-- \1 -->/'   "${TARGET_PATH}"
        sed -i 's/\(<\/Portal.*\)/<!-- \1 -->\n/'   "${TARGET_PATH}"

        cat "${TARGET_PATH}" >> "${TARGETFILE}"
        rm "${TARGET_PATH}"
      fi
    #portal change, developper not being consistent ...
      if [[ "$LINE" == *"<portal"* ]]
      then
        NAME1=${LINE#*name=\"}
        PORTAL1=${NAME1%%\"*}
       # NAME1=${LINE%\">*}
       # PORTAL1=${NAME1##*\"}
        echo "Create the ${PORTAL1}_${ROOTNAME}.txml  file using xmlstarlet"
        TARGET_PATH="${DIRNAME}/${PORTAL1}_${ROOTNAME}.txml"

        xmlstarlet sel -t -c "/StringTable/portal[@name='${PORTAL1}']" "${FILEPATH}" > "${TARGET_PATH}"
        sed -i "s/id=\"/id=\"${PORTAL1}/g" "${TARGET_PATH}"
        sed -i 's/\(<portal.*\)/<!-- \1 -->/'   "${TARGET_PATH}"
        sed -i 's/\(<\/portal.*\)/<!-- \1 -->\n/'   "${TARGET_PATH}"

        cat "${TARGET_PATH}" >> "${TARGETFILE}"
        rm "${TARGET_PATH}"
      fi
    #ui change
      if [[ "$LINE" == *"<ui"* ]]
      then
        NAME1=${LINE#*name=\"}
        UI=${NAME1%%\"*}
        #NAME1=${LINE%\">*}
        #UI=${NAME1##*\"}
        echo "Create the ${UI}_${ROOTNAME}.txml  file using xmlstarlet"
        TARGET_PATH="${DIRNAME}/${UI}_${ROOTNAME}.txml"
        xmlstarlet sel -t -c "/StringTable/ui[@name='${UI}']" "${FILEPATH}" > "${TARGET_PATH}"

        sed -i "s/id=\"/id=\"${UI}/g" "${TARGET_PATH}"
        sed -i 's/\(<ui.*\)/<!-- \1 -->/'   "${TARGET_PATH}"
        sed -i 's/\(<\/ui.*\)/<!-- \1 -->\n/'   "${TARGET_PATH}"

        cat "${TARGET_PATH}" >> "${TARGETFILE}"
        rm "${TARGET_PATH}"
      fi
    # solver change
      if [[ "$LINE" == *"<solver"* ]]
      then
	echo "SOLVER LINE FOUND! $LINE"
        NAME1=${LINE#*name=\"}
        SOLVER=${NAME1%%\"*}
        echo "Create the ${SOLVER}_${ROOTNAME}.txml  file using xmlstarlet"
        TARGET_PATH="${DIRNAME}/${SOLVER}_${ROOTNAME}.txml"
        xmlstarlet sel -t -c "/StringTable/solver[@name='${SOLVER}']" "${FILEPATH}" > "${TARGET_PATH}"

        sed -i "s/id=\"/id=\"${SOLVER}/g" "${TARGET_PATH}"
        sed -i 's/\(<solver.*\)/<!-- \1 -->/'   "${TARGET_PATH}"
        sed -i 's/\(<\/solver.*\)/<!-- \1 -->\n/'   "${TARGET_PATH}"

        cat "${TARGET_PATH}" >> "${TARGETFILE}"
        #rm "${TARGET_PATH}"
      fi
    #done
    done

    # For the strings outside of any context, only get those using GLOBAL_
    xmlstarlet sel -t -c "/StringTable/string" ${FILEPATH}  | sed "s/string></string>\n</g" >> "${TARGETFILE}"

    sed -i "s/^[[:space:]]*<string/  <string/"        "${TARGETFILE}"
    sed -i '1i<StringTable>'                          "${TARGETFILE}"
    sed -i '$a</StringTable>'                         "${TARGETFILE}"
    sed -i '1i<?xml version="1.0" encoding="UTF-8"?>' "${TARGETFILE}"
  fi
done

