<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:fo="http://www.w3.org/1999/XSL/Format" version="1.0">

	<xsl:param name="markAttributeChanges"/>

	<xsl:template match="*" mode="setDiffStyle">
		<xsl:choose>
			<xsl:when test="@Changed = 'INSERTED'">
				<xsl:attribute name="background-color">#8efe5d</xsl:attribute>
			</xsl:when>
			<xsl:when test="@Changed = 'DELETED'">
				<xsl:attribute name="background-color">#f35555</xsl:attribute>
			</xsl:when>
			<xsl:when test="(@Changed = 'UPDATED' or (@AttributesChanged = 'UPDATED' and not($markAttributeChanges = 'false')))
					  and not(starts-with(name(), 'Include.'))">
				<xsl:attribute name="background-color">#fdf636</xsl:attribute>
			</xsl:when>
		</xsl:choose>
	</xsl:template>


	<xsl:template match="INSERTED">
		<fo:inline background-color="#8efe5d">
			<xsl:apply-templates/>
		</fo:inline>
	</xsl:template>

	<xsl:template match="DELETED">
		<fo:inline background-color="#f35555">
			<xsl:apply-templates/>
		</fo:inline>
	</xsl:template>

	<xsl:template match="UPDATED">
		<fo:inline background-color="#fdf636">
			<xsl:apply-templates/>
		</fo:inline>
	</xsl:template>

	<xsl:template match="subPar">
		<xsl:apply-templates/>
	</xsl:template>

</xsl:stylesheet>