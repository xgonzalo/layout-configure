<?xml version="1.0" encoding="utf-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:fo="http://www.w3.org/1999/XSL/Format" version="1.0">

	<xsl:key name="RetrieveMarker" match="fo:retrieve-marker" use="@retrieve-class-name"/>
	
	<xsl:template match="*">
		<xsl:copy>
			<xsl:copy-of select="@*"/>
			<xsl:apply-templates/>
		</xsl:copy>
	</xsl:template>

	<xsl:template match="fo:static-content">
		<xsl:variable name="masterRef" select="parent::*/@master-reference"/>
		<xsl:variable name="regionName" select="@flow-name"/>
		<xsl:if test="$regionName = 'xsl-footnote-separator' or ancestor::fo:root[1]/fo:layout-master-set/fo:page-sequence-master[../../fo:page-sequence/@master-reference = @master-name and @master-name = $masterRef]/*/fo:conditional-page-master-reference/@master-reference
				= ancestor::fo:root[1]/fo:layout-master-set/fo:simple-page-master[../../fo:page-sequence/@master-reference = @master-name or ../fo:page-sequence-master[../../fo:page-sequence/@master-reference = @master-name]//fo:conditional-page-master-reference/@master-reference = @master-name and *[@region-name = $regionName]]/@master-name
				or
				ancestor::fo:root[1]/fo:layout-master-set/fo:simple-page-master[../../fo:page-sequence/@master-reference = @master-name or ../fo:page-sequence-master[../../fo:page-sequence/@master-reference = @master-name]//fo:conditional-page-master-reference/@master-reference = @master-name and @master-name = $masterRef]/*[@region-name = $regionName]">
			<xsl:copy>
				<xsl:copy-of select="@*"/>
				<xsl:apply-templates/>
			</xsl:copy>
		</xsl:if>
	</xsl:template>

	<xsl:template match="fo:marker">
		<xsl:if test="key('RetrieveMarker', @marker-class-name)">
			<xsl:copy>
				<xsl:copy-of select="@*"/>
				<xsl:apply-templates/>
			</xsl:copy>
		</xsl:if>
	</xsl:template>

	<xsl:template match="fo:page-sequence-master">
		<xsl:if test="../../fo:page-sequence/@master-reference = @master-name">
			<xsl:copy>
				<xsl:copy-of select="@*"/>
				<xsl:apply-templates/>
			</xsl:copy>
		</xsl:if>
	</xsl:template>

	<xsl:template match="fo:simple-page-master">
		<xsl:if test="../../fo:page-sequence/@master-reference = @master-name or ../fo:page-sequence-master[../../fo:page-sequence/@master-reference = @master-name]//fo:conditional-page-master-reference/@master-reference = @master-name">
			<xsl:copy>
				<xsl:copy-of select="@*"/>
				<xsl:apply-templates/>
			</xsl:copy>
		</xsl:if>
	</xsl:template>
	
</xsl:stylesheet>
