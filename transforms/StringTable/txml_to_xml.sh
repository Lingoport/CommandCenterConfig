#!/bin/bash
#
# Special handling for .txml files
#
# Find all the files ending in .xml and move them to .txml
# The following environment variables need to be set:
#   FULL_FILE_LIST
#

echo  " ------------------------------------------------"
echo  " Find *.txml files "
echo  " ---------------------------"

# Find all the files ending in the 'xml'
TXMLFILES="$FULL_LIST_PATH"

#find . -name "*\.txml" -type f > "$TXMLFILES"
sed '/Portal_messages_..\.xml/d' "$TXMLFILES"

echo "Files to transform: "
cat "$TXMLFILES"

# For each file to transform, create as many subfiles,
# one per Context and one for strings outside context elements
cat "${TXMLFILES}" | while read -r FILEPATH
do
  SUFFIX=".txml"
  FILENAME=`basename $FILEPATH`
  DIRNAME=`dirname $FILEPATH`
  ROOTNAME=${FILENAME%$SUFFIX}
  TARGETFILE="${DIRNAME}/${ROOTNAME}.xml"
  echo " Transform [${FILEPATH}] -> [$TARGETFILE]"
  rm "${TARGETFILE}" 2> /dev/null
  touch "${TARGETFILE}"

  #Variables for the <string... lines
  LEADING_SPACES="  "
  IDNAME=""


  # Section: last line
  # Watch out for the last line in the txml
  # For instance, with pseudo-loc, </StringTable> is the last
  # line without a carriage return and the read -r does not see it!!!
  # So adding an empty line to be removed from the transformed xml
  # at the very end of processing. Argh.
  echo "" >>  "$FILEPATH"

  cat $FILEPATH | while read -r LINE
  do

  #Context change
  # Print all lines, but those with comments are special and need
  # to be uncommented. The comments from the xml are not kept in
  # the txml so as not to make the txml to xml too complicated.
  if [[ "$LINE" == *"<!--"* ]]
  then
    if [[ "$LINE" == *"<Context"* ||
          "$LINE" == *"<context"* ||
          "$LINE" == *"<Portal"*  ||
          "$LINE" == *"<portal"*  ||
          "$LINE" == *"<solver"*  ||
          "$LINE" == *"<ui"*
       ]]
      then
        #echo "LINE: $LINE"
        STRIP1=${LINE#*<!--}
        STRIP2=${STRIP1%%-->*}
        TRIM1="${STRIP2## }"
        TRIM2="${TRIM1%% }"
        #echo "TRIM2: $TRIM2"
        LEADING_SPACES="    "
        echo "  ${TRIM2}"  >> "$TARGETFILE"

        # For the id's in the context/portal/ui...
        # get the name so it can be removed from the identifier
        NAME1=${LINE#*name=\"}
        IDNAME=${NAME1%%\"*}

      fi
    if [[ "$LINE" == *"</Context"* ||
          "$LINE" == *"</context"* ||
          "$LINE" == *"</Portal"*  ||
          "$LINE" == *"</portal"*  ||
          "$LINE" == *"</solver"*  ||
          "$LINE" == *"</ui"*
       ]]
      then
        # Could all be the same var, just easier to debug if necessary
        STRIP1=${LINE#*<!--}
        STRIP2=${STRIP1%%-->*}
        TRIM1="${STRIP2## }"
        TRIM2="${TRIM1%% }"
        #echo "TRIM2: $TRIM2"
        LEADING_SPACES="  "
        echo "  ${TRIM2}"  >> "$TARGETFILE"

        # At the end of the context/portal/ui...
        # no more removing of the added identifier
        IDNAME=""
      fi


  # if it's not a comment, echo the line in the target file
  # after removing the Context/UI/context/... name from the id
  else
    # Remove the IDNAME from the identifier if IDNAME is set
    if [ -n "$IDNAME" ]
    then
      #echo "IDNAME = $IDNAME"
      #echo "ORIGINAL LINE = ${LINE}"
      RLINE="${LINE/$IDNAME/}"
      #echo "REFACTORED LINE = ${RLINE}"
      echo "${LEADING_SPACES}${RLINE}" >> "$TARGETFILE"
    else
      if [[ "$LINE" == *"<StringTable"* ||
          "$LINE" == *"</StringTable"* ||
          "$LINE" == *"xml version"*
       ]]
      then
        #echo "TARGET FILE: $TARGETFILE"
        echo "SPECIAL LINE >> $LINE"
        echo "${LINE}"  >> "$TARGETFILE"
      else
        echo "${LEADING_SPACES}${LINE}" >> "$TARGETFILE"
      fi

    fi
  fi
  done

  # Finally, add the DOCTYPE right after the xml prolog
  # so on the second line
  sed -i '1a <!DOCTYPE StringTable>' "$TARGETFILE"

  # And remove any line after </StringTable>
  # See the reason above, in section last line
  sed -i '/<\/StringTable>/q' "$TARGETFILE"

done
