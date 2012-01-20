<?xml version="1.0" encoding="UTF-8"?>
<!--
<xsl:stylesheet extension-element-prefixes="xdmp" version="2.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:config="http://marklogic.com/appservices/config" xmlns:translate="http://marklogic.com/translate" xmlns:html="http://www.w3.org/1999/xhtml" xmlns:xdmp="http://marklogic.com/xdmp">
  <xsl:import href="../lib/transform-detail.xsl"/>


  <xdmp:import-module href="/lib/config.xqy" namespace="http://marklogic.com/appservices/config"/>


  <xsl:output omit-xml-declaration="yes" indent="yes"/>
  <xsl:template match="html:*"><xsl:copy><xsl:copy-of select="@*"/><xsl:apply-templates/></xsl:copy></xsl:template>
</xsl:stylesheet>
-->
<xsl:stylesheet version="2.0" exclude-result-prefixes="html" xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns="http://www.w3.org/1999/xhtml" xmlns:html="http://www.w3.org/1999/xhtml">
  <xsl:output omit-xml-declaration="yes" indent="yes"/>
  
  
<xsl:template match="html:content-type"><p>Content-Type: <xsl:apply-templates/></p></xsl:template>
<xsl:template match="html:Creation_Date"><p>Creation_Date: <xsl:apply-templates/></p></xsl:template>
<xsl:template match="html:Last_Saved_Date"><p>Last_Saved_Date: <xsl:apply-templates/></p></xsl:template>
<xsl:template match="html:Revision"><p>Revision: <xsl:apply-templates/></p></xsl:template>
<xsl:template match="html:Template"><p>Template: <xsl:apply-templates/></p></xsl:template>
<xsl:template match="html:Typist"><p>Typist: <xsl:apply-templates/></p></xsl:template>
<xsl:template match="html:Last_Author"><p>Last_Author: <xsl:apply-templates/></p></xsl:template>
<xsl:template match="html:Word_Count"><p>Word_Count: <xsl:apply-templates/></p></xsl:template>
<xsl:template match="html:Line_Count"><p>Line_Count: <xsl:apply-templates/></p></xsl:template>
<xsl:template match="html:Paragraphs_Count"><p>Paragraphs_Count: <xsl:apply-templates/></p></xsl:template>
<xsl:template match="html:size"><p>Size (in bytes): <xsl:apply-templates/></p></xsl:template>
<xsl:template match="html:filter-capabilities"/>
<xsl:template match="html:isys"/>

  <xsl:template match="html:*"><xsl:copy><xsl:copy-of select="@*"/><xsl:apply-templates/></xsl:copy></xsl:template>
</xsl:stylesheet>