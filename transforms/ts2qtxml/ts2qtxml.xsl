<?xml version="1.0" encoding="utf-8"?>
<!--
  ts2qtxml : Qt .ts -> .qtxml   (used by transform_from_repo.sh)

  <TS ...>                                <TS ...>
    <context>                               <message id="ID_ABOUT">
      <name>ID_ABOUT</name>         ==>       <source>About</source>
      <message>                               <translation>About</translation>
        <source>About</source>              </message>
        <translation>About</translation>    ...
      </message>                          </TS>
    </context>
    ...
  </TS>

  The <context> elements are removed: each <message> is placed directly under
  <TS>, with the preceding <name> as its id attribute.

  Parameter:
    drop_unfinished  '1' leaves out messages whose <translation> has
                     type="unfinished" (target-locale files); anything else
                     keeps them (source-locale file).
-->
<xsl:stylesheet version="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform">
  <xsl:output method="xml" encoding="utf-8" indent="yes"/>
  <xsl:strip-space elements="TS context message"/>

  <xsl:param name="drop_unfinished" select="'0'"/>

  <xsl:template match="/TS">
    <TS>
      <xsl:copy-of select="@*"/>
      <xsl:for-each select="context/message">
        <xsl:if test="not($drop_unfinished = '1' and translation/@type = 'unfinished')">
          <message id="{preceding-sibling::name[1]}">
            <xsl:copy-of select="@*"/>
            <xsl:copy-of select="node()"/>
          </message>
        </xsl:if>
      </xsl:for-each>
    </TS>
  </xsl:template>
</xsl:stylesheet>
