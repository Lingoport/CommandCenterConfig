<?xml version="1.0" encoding="utf-8"?>
<!--
  ts2qtxml : .qtxml -> Qt .ts   (used by transform_to_repo.sh)

  <TS ...>                                  <TS ...>
    <message id="ID_ABOUT">                   <context>
      <source>About</source>          ==>       <name>ID_ABOUT</name>
      <translation>概要</translation>            <message>
    </message>                                    <source>About</source>
    ...                                           <translation>概要</translation>
  </TS>                                         </message>
                                              </context>
                                              ...
                                            </TS>

  Each <message> gets its own <context>, with its id moved back into a
  <name> element, as in the source .ts file.

  Parameter:
    language  when not empty, replaces the <TS language="..."> value
-->
<xsl:stylesheet version="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform">
  <xsl:output method="xml" encoding="utf-8" indent="yes"/>
  <xsl:strip-space elements="TS context message"/>

  <xsl:param name="language" select="''"/>

  <xsl:template match="/TS">
    <TS>
      <xsl:copy-of select="@*"/>
      <xsl:if test="$language != ''">
        <xsl:attribute name="language"><xsl:value-of select="$language"/></xsl:attribute>
      </xsl:if>
      <xsl:for-each select="message | context/message">
        <context>
          <name><xsl:value-of select="@id"/></name>
          <message>
            <xsl:copy-of select="@*[name() != 'id']"/>
            <xsl:copy-of select="node()"/>
          </message>
        </context>
      </xsl:for-each>
    </TS>
  </xsl:template>
</xsl:stylesheet>
