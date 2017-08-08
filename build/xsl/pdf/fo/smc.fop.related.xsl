<?xml version="1.0" encoding="utf-8"?>
<xsl:stylesheet version="1.0" xmlns:fo="http://www.w3.org/1999/XSL/Format" xmlns:xsl="http://www.w3.org/1999/XSL/Transform">


	<xsl:template match="InfoItem.RelatedLinks">

		<fo:block>
			<xsl:call-template name="addStyle">
				<xsl:with-param name="name">block-level-element</xsl:with-param>
			</xsl:call-template>
			<xsl:call-template name="addStyle">
				<xsl:with-param name="name">related.themes</xsl:with-param>
			</xsl:call-template>
			<xsl:apply-templates select="head" mode="relatedLinks"/>
			<xsl:apply-templates select="*[name() != 'head']" mode="relatedLinks"/>
		</fo:block>

	</xsl:template>

	<xsl:template match="head" mode="relatedLinks">
		<fo:block>
			<xsl:call-template name="addStyle">
				<xsl:with-param name="name">related.themes.head</xsl:with-param>
			</xsl:call-template>
			<xsl:if test="ancestor::InfoItem.Warning">
				<xsl:attribute name="start-indent">0cm</xsl:attribute>
			</xsl:if>
			<xsl:apply-templates/>
		</fo:block>
	</xsl:template>

	<xsl:template match="*" mode="relatedLinks">
		<fo:block>
			<xsl:apply-templates select="current()"/>
		</fo:block>
	</xsl:template>
		
	<xsl:template match="Link.XRef" mode="relatedLinks">
		<xsl:apply-templates select="current()" mode="relatedLinksJustified"/>
	</xsl:template>

	<xsl:template match="Link.XRef" mode="relatedLinksSimple">
		<xsl:param name="defaultLinkFormat"/>
		<fo:block>
			<xsl:choose>
				<xsl:when test="string-length(@RefID) &gt; 0 and not($isPDFXMODE)">
					<fo:basic-link internal-destination="{@RefID}">
						<fo:inline>
							<xsl:call-template name="addStyle">
								<xsl:with-param name="name">related.themes.link</xsl:with-param>
							</xsl:call-template>
							<xsl:apply-templates select="*" mode="getLinkText">
								<xsl:with-param name="base" select="InfoChunk.Link"/>
								<xsl:with-param name="defaultFormat" select="$defaultLinkFormat"/>
							</xsl:apply-templates>
						</fo:inline>
					</fo:basic-link>
				</xsl:when>
				<xsl:otherwise>
					<fo:inline>
						<xsl:call-template name="addStyle">
							<xsl:with-param name="name">related.themes.link</xsl:with-param>
						</xsl:call-template>
						<xsl:apply-templates select="*" mode="getLinkText">
							<xsl:with-param name="base" select="InfoChunk.Link"/>
							<xsl:with-param name="defaultFormat" select="$defaultLinkFormat"/>
						</xsl:apply-templates>
					</fo:inline>
				</xsl:otherwise>
			</xsl:choose>
		</fo:block>
	</xsl:template>

	<xsl:template match="Link.XRef" mode="relatedLinksJustified">

		<xsl:variable name="RefID" select="string(@RefID)"/>

		<xsl:variable name="refInfoMap" select="key('InfoMapKey', $RefID)[1]"/>

		<fo:block>
			<xsl:if test="$refInfoMap">
				<xsl:attribute name="text-align-last">justify</xsl:attribute>
			</xsl:if>
			<xsl:call-template name="addStyle">
				<xsl:with-param name="name">par</xsl:with-param>
			</xsl:call-template>
			<xsl:if test="ancestor::InfoItem.Warning">
				<xsl:attribute name="start-indent">0cm</xsl:attribute>
			</xsl:if>

			<xsl:variable name="enumImageWidth">
				<xsl:call-template name="getTemplateVariableValue">
					<xsl:with-param name="name" select="'ENUM.IMAGE.WIDTH'"/>
					<xsl:with-param name="defaultValue" select="'2.5mm'"/>
				</xsl:call-template>
			</xsl:variable>

			<fo:inline>
				<fo:external-graphic src="url('{$clientImageAssetsPath}/fopassets/icons/related_theme.gif')" width="{$enumImageWidth}"/>
				<xsl:text>  </xsl:text>
			</fo:inline>
			<xsl:choose>
				<xsl:when test="string-length($RefID) &gt; 0 and not($isPDFXMODE)">
					<fo:basic-link internal-destination="{$RefID}">
						<xsl:call-template name="addStyle">
							<xsl:with-param name="name">related.themes.link</xsl:with-param>
						</xsl:call-template>
						<xsl:value-of select="InfoChunk.Link"/>
					</fo:basic-link>
				</xsl:when>
				<xsl:otherwise>
					<fo:inline>
						<xsl:call-template name="addStyle">
							<xsl:with-param name="name">related.themes.link</xsl:with-param>
						</xsl:call-template>
						<xsl:value-of select="InfoChunk.Link"/>
					</fo:inline>
				</xsl:otherwise>
			</xsl:choose>

			<xsl:if test="$refInfoMap">
				<fo:leader leader-pattern="dots"/>
				<xsl:apply-templates select="current()" mode="writePageReferenceNumber">
					<xsl:with-param name="RefID" select="@RefID"/>
				</xsl:apply-templates>
			</xsl:if>
		</fo:block>
	</xsl:template>



</xsl:stylesheet>

