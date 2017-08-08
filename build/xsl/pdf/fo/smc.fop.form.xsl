<?xml version="1.0" encoding="utf-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:fo="http://www.w3.org/1999/XSL/Format" version="1.0">

	<xsl:template match="form.multipleChoice">
		<fo:block>
			<xsl:call-template name="addStyle">
				<xsl:with-param name="name">form.multipleChoice</xsl:with-param>
			</xsl:call-template>
			<xsl:apply-templates/>
		</fo:block>
	</xsl:template>

	<xsl:template match="form.query">
		<fo:block>
			<xsl:call-template name="addStyle">
				<xsl:with-param name="name">form.query</xsl:with-param>
			</xsl:call-template>
			<xsl:apply-templates/>
		</fo:block>
	</xsl:template>

	<xsl:template match="form.answer">
		<fo:block>
			<xsl:call-template name="addStyle">
				<xsl:with-param name="name">form.answer</xsl:with-param>
			</xsl:call-template>
			<xsl:apply-templates/>
		</fo:block>
	</xsl:template>

	<xsl:template match="form.answer.explanation"/>

	<xsl:template match="form.textfield">
		<fo:block>
			<xsl:call-template name="addStyle">
				<xsl:with-param name="name">form.textfield</xsl:with-param>
			</xsl:call-template>
			<fo:block>
				<xsl:call-template name="addStyle">
					<xsl:with-param name="name">form.textfield.label</xsl:with-param>
				</xsl:call-template>
				<xsl:value-of select="@Label"/>
			</fo:block>
			<fo:block-container width="200px" height="70px">
				<xsl:if test="string(number(@Width)) != 'NaN'">
					<xsl:attribute name="width">
						<xsl:value-of select="concat(@Width, 'px')"/>
					</xsl:attribute>
				</xsl:if>
				<xsl:if test="string(number(@Height)) != 'NaN'">
					<xsl:attribute name="height">
						<xsl:value-of select="concat(@Height, 'px')"/>
					</xsl:attribute>
				</xsl:if>
				<xsl:call-template name="addStyle">
					<xsl:with-param name="name">form.textfield.value</xsl:with-param>
				</xsl:call-template>
				<fo:block>&#160;</fo:block>
			</fo:block-container>
		</fo:block>
	</xsl:template>

</xsl:stylesheet>