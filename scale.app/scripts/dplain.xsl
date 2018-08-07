<?xml version="1.0" encoding="UTF-8"?>
<!--
  FindBugs - Find bugs in Java programs
  Copyright (C) 2004,2005 University of Maryland
  Copyright (C) 2005, Chris Nappin
  
  This library is free software; you can redistribute it and/or
  modify it under the terms of the GNU Lesser General Public
  License as published by the Free Software Foundation; either
  version 2.1 of the License, or (at your option) any later version.
  
  This library is distributed in the hope that it will be useful,
  but WITHOUT ANY WARRANTY; without even the implied warranty of
  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
  Lesser General Public License for more details.
  
  You should have received a copy of the GNU Lesser General Public
  License along with this library; if not, write to the Free Software
  Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307  USA
-->
<xsl:stylesheet version="1.0"
	xmlns="http://www.w3.org/1999/xhtml"
	xmlns:xsl="http://www.w3.org/1999/XSL/Transform">

<xsl:output
	method="xml"
	omit-xml-declaration="yes"
	standalone="yes"
         doctype-system="http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd"
         doctype-public="-//W3C//DTD XHTML 1.0 Transitional//EN"
	indent="yes"
	encoding="UTF-8"/>

<xsl:variable name="bugTableHeader">
	<tr class="tableheader">
		<th align="left">Warning</th>
		<th align="left">Priority</th>
		<th align="left">Details</th>
	</tr>
</xsl:variable>

<xsl:template match="/">


	<xsl:variable name="unique-catkey" select="/BugCollection/BugCategory/@category"/>
	
	<xsl:for-each select="$unique-catkey">
		<xsl:sort select="." order="ascending"/>
		<xsl:variable name="catkey" select="."/>
		<xsl:variable name="catdesc" select="/BugCollection/BugCategory[@category=$catkey]/Description"/>

		<xsl:call-template name="generateWarningTable">
			<xsl:with-param name="warningSet" select="/BugCollection/BugInstance[(@category=$catkey) and (not(@last))]"/>
			<xsl:with-param name="sectionTitle"><xsl:value-of select="$catdesc"/> Warnings</xsl:with-param>
			<xsl:with-param name="sectionId">Warnings_<xsl:value-of select="$catkey"/></xsl:with-param>
		</xsl:call-template>
	</xsl:for-each>

</xsl:template>

<xsl:template match="BugInstance[not(@last)]">
	<!-- <xsl:variable name="warningId"><xsl:value-of select="generate-id()"/></xsl:variable> -->
	<p>
	<xsl:text>| </xsl:text>
	<xsl:value-of select="@type"/>
	<xsl:text> | </xsl:text>
	<!--  add source filename and line number(s), if any -->
	<xsl:choose>
	  <!-- Content: (xsl:when+, xsl:otherwise?) -->
	  <xsl:when test="SourceLine">
	    <xsl:value-of select="SourceLine/@sourcepath"/>
	    <xsl:text> | </xsl:text>
	    <xsl:value-of select="SourceLine/@start"/>
	  </xsl:when>
	  <xsl:otherwise>
	    <xsl:text>|</xsl:text>
	  </xsl:otherwise>	    
	</xsl:choose>
	<xsl:text> | </xsl:text>
	<xsl:value-of select="LongMessage"/>
	<xsl:text> | </xsl:text>
	</p>
</xsl:template>


<xsl:template name="generateWarningTable">
	<xsl:param name="warningSet"/>
	<xsl:param name="sectionTitle"/>
	<xsl:param name="sectionId"/>

	<xsl:choose>
	  <xsl:when test="count($warningSet) &gt; 0">
	    <xsl:apply-templates select="$warningSet">
	      <xsl:sort select="@priority"/>
	      <xsl:sort select="@abbrev"/>
	      <xsl:sort select="Class/@classname"/>
	    </xsl:apply-templates>
	  </xsl:when>
	  <xsl:otherwise>
	  </xsl:otherwise>
	</xsl:choose>
</xsl:template>


</xsl:stylesheet>
