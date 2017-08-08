<?xml version="1.0" encoding="utf-8"?>
<xsl:stylesheet
	xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
	xmlns:fo="http://www.w3.org/1999/XSL/Format"
	version="1.0">


	<xsl:template match="Media.AV">

		<xsl:variable name="URL">

			<xsl:call-template name="getURL">
				<xsl:with-param name="authenticate">true</xsl:with-param>
				<xsl:with-param name="collectionID" select="@collectionID"/>
				<xsl:with-param name="fileID" select="@fileID"/>
			</xsl:call-template>

		</xsl:variable>

		<fo:block>
			<xsl:choose>
				<xsl:when test="string-length(@slideURL) &gt; 0">
					<fo:external-graphic src="url({$imageAssetsPath}/MediaAV.gif)" scaling-method="auto" scaling="uniform" width="0.7cm"></fo:external-graphic>
					<fo:basic-link external-destination="{@slideURL}">
						<xsl:call-template name="addStyle">
							<xsl:with-param name="name">link.xref</xsl:with-param>
						</xsl:call-template>
						<xsl:apply-templates select="@source"/>
					</fo:basic-link>
				</xsl:when>
			</xsl:choose>
			<fo:external-graphic src="url({$imageAssetsPath}/MediaAV.gif)" scaling-method="auto" scaling="uniform" width="0.7cm"></fo:external-graphic>
			<xsl:if test="not($Offline = 'Offline')">
				<fo:basic-link external-destination="{$URL}">
					<xsl:call-template name="addStyle">
						<xsl:with-param name="name">link.xref</xsl:with-param>
					</xsl:call-template>
					<xsl:apply-templates select="@source"/>
				</fo:basic-link>
			</xsl:if>

		</fo:block>

		<xsl:apply-templates/>

	</xsl:template>


</xsl:stylesheet>