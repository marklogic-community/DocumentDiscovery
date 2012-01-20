<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="2.0" exclude-result-prefixes="html config translate xdmp" extension-element-prefixes="xdmp" xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns="http://www.w3.org/1999/xhtml" xmlns:html="http://www.w3.org/1999/xhtml" xmlns:translate="http://marklogic.com/translate" xmlns:config="http://marklogic.com/appservices/config" xmlns:xdmp="http://marklogic.com/xdmp">
  <xsl:param name="config:LABELS"/>
  <xdmp:import-module href="/MarkLogic/appservices/utils/translate.xqy" namespace="http://marklogic.com/translate"/>
  <xsl:template match="/"><xsl:text>[View Item]</xsl:text></xsl:template>
</xsl:stylesheet>