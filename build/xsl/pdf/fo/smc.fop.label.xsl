<?xml version="1.0" encoding="utf-8"?>
<xsl:stylesheet
	xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
	xmlns:fo="http://www.w3.org/1999/XSL/Format"
	version="1.0">

	<xsl:template match="Label">
		<xsl:variable name="autoNumber">
			<xsl:call-template name="getFormat">
				<xsl:with-param name="name">label</xsl:with-param>
				<xsl:with-param name="attributeName">auto-number</xsl:with-param>
			</xsl:call-template>
		</xsl:variable>
		<xsl:choose>
			<xsl:when test="$autoNumber = 'true'">
				<xsl:apply-templates select="current()" mode="internal"/>
			</xsl:when>
			<xsl:otherwise>
				<xsl:call-template name="addStyle">
					<xsl:with-param name="name">label.inline</xsl:with-param>
				</xsl:call-template>
				<xsl:apply-templates select="current()" mode="writeCharacterizationInfo">
					<xsl:with-param name="bPadding" select="true()"/>
				</xsl:apply-templates>
				<xsl:apply-templates/>
			</xsl:otherwise>
		</xsl:choose>
	</xsl:template>

</xsl:stylesheet>
