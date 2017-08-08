<?xml version="1.0" encoding="utf-8"?>
<xsl:stylesheet version="1.0" xmlns:fo="http://www.w3.org/1999/XSL/Format" xmlns:xsl="http://www.w3.org/1999/XSL/Transform">


	<xsl:template match="euro" mode="symbol">&#x20AC;</xsl:template>
	<xsl:template match="euro" mode="printText">&#x20AC;</xsl:template>

	<xsl:template match="infinity" mode="symbol">&#x221E;</xsl:template>
	<xsl:template match="infinity" mode="printText">&#x221E;</xsl:template>

	<xsl:template match="copyright" mode="symbol">
		<fo:inline font-family="Arial">©</fo:inline>
	</xsl:template>
	<xsl:template match="copyright" mode="printText">©</xsl:template>

	<xsl:template match="right" mode="symbol">
		<fo:inline>
			<xsl:apply-templates select="ancestor::InfoChunk.High" mode="fix-vertical-align"/>
			<xsl:choose>
				<xsl:when test="$isPDFXMODE">
					<xsl:attribute name="font-family">Arial Unicode MS</xsl:attribute>
				</xsl:when>
				<xsl:otherwise>
					<xsl:attribute name="font-family">
						<xsl:apply-templates select="current()" mode="getDefaultFont"/>
					</xsl:attribute>
				</xsl:otherwise>
			</xsl:choose>
			<xsl:text>&#xAE;</xsl:text>
		</fo:inline>
	</xsl:template>
	<xsl:template match="right" mode="printText">&#xAE;</xsl:template>

	<xsl:template match="right" mode="getDefaultFont">Helvetica</xsl:template>

	<xsl:template match="trademark" mode="symbol">
		<fo:inline font-family="Arial Unicode MS" font-weight="normal" font-style="normal">&#x2122;</fo:inline>
	</xsl:template>
	<xsl:template match="trademark" mode="printText">&#x2122;</xsl:template>

	<xsl:template match="diameter" mode="symbol">
		<fo:inline font-family="Arial Unicode MS" font-weight="normal" font-style="normal">&#x2205;</fo:inline>
	</xsl:template>
	<xsl:template match="diameter" mode="printText">&#x2205;</xsl:template>
	
	<xsl:template match="greater-equal" mode="symbol">&#x2265;</xsl:template>
	<xsl:template match="greater-equal" mode="printText">&#x2265;</xsl:template>
	
	<xsl:template match="smaller-equal" mode="symbol">&#x2264;</xsl:template>
	<xsl:template match="smaller-equal" mode="printText">&#x2264;</xsl:template>
	
	<xsl:template match="not-equal" mode="symbol">&#x2260;</xsl:template>
	<xsl:template match="not-equal" mode="printText">&#x2260;</xsl:template>
	
	<xsl:template match="per-mill" mode="symbol">&#x2030;</xsl:template>
	<xsl:template match="per-mill" mode="printText">&#x2030;</xsl:template>
	
	<xsl:template match="rounding" mode="symbol">
		<fo:inline font-family="Arial Unicode MS" font-weight="normal" font-style="normal">&#x223C;</fo:inline>
	</xsl:template>
	<xsl:template match="rounding" mode="printText">&#x223C;</xsl:template>
	
	<xsl:template match="soft-hyphen" mode="symbol">&#x00AD;</xsl:template>
	<xsl:template match="soft-hyphen" mode="printText">&#x00AD;</xsl:template>
	
	<xsl:template match="Delta" mode="symbol">&#x2206;</xsl:template>
	<xsl:template match="Delta" mode="printText">&#x2206;</xsl:template>
	
	<xsl:template match="Omega" mode="symbol">&#x2126;</xsl:template>
	<xsl:template match="Omega" mode="printText">&#x2126;</xsl:template>
	
	<xsl:template match="alpha" mode="symbol">&#x03B1;</xsl:template>
	<xsl:template match="alpha" mode="printText">&#x03B1;</xsl:template>
	
	<xsl:template match="beta" mode="symbol">&#x03B2;</xsl:template>
	<xsl:template match="beta" mode="printText">&#x03B2;</xsl:template>
	
	<xsl:template match="gamma" mode="symbol">&#x03B3;</xsl:template>
	<xsl:template match="gamma" mode="printText">&#x03B3;</xsl:template>
	
	<xsl:template match="delta" mode="symbol">&#x03B4;</xsl:template>
	<xsl:template match="delta" mode="printText">&#x03B4;</xsl:template>
	
	<xsl:template match="epsilon" mode="symbol">&#x03B5;</xsl:template>
	<xsl:template match="epsilon" mode="printText">&#x03B5;</xsl:template>
	
	<xsl:template match="theta" mode="symbol">&#x03B8;</xsl:template>
	<xsl:template match="theta" mode="printText">&#x03B8;</xsl:template>
	
	<xsl:template match="lambda" mode="symbol">&#x03BB;</xsl:template>
	<xsl:template match="lambda" mode="printText">&#x03BB;</xsl:template>
	
	<xsl:template match="mu" mode="symbol">&#xB5;</xsl:template>
	<xsl:template match="mu" mode="printText">&#xB5;</xsl:template>
	
	<xsl:template match="pi" mode="symbol">&#x03C0;</xsl:template>
	<xsl:template match="pi" mode="printText">&#x03C0;</xsl:template>
	
	<xsl:template match="plus-minus" mode="symbol">&#xB1;</xsl:template>
	<xsl:template match="plus-minus" mode="printText">&#xB1;</xsl:template>
	
	<xsl:template match="sqrt" mode="symbol">&#x221A;</xsl:template>
	<xsl:template match="sqrt" mode="printText">&#x221A;</xsl:template>
	
	<xsl:template match="approx" mode="symbol">&#x2248;</xsl:template>
	<xsl:template match="approx" mode="printText">&#x2248;</xsl:template>
	
	<xsl:template match="approx-equal" mode="symbol">
		<fo:inline font-family="Arial Unicode MS" font-weight="normal" font-style="normal">&#x2245;</fo:inline>
	</xsl:template>
	<xsl:template match="approx-equal" mode="printText">&#x2245;</xsl:template>
	
	<xsl:template match="times" mode="symbol">&#xD7;</xsl:template>
	<xsl:template match="times" mode="printText">&#xD7;</xsl:template>
	
	<xsl:template match="arrow-right" mode="symbol">&#x2192;</xsl:template>
	<xsl:template match="arrow-right" mode="printText">&#x2192;</xsl:template>
	
	<xsl:template match="arrow-down" mode="symbol">&#x2193;</xsl:template>
	<xsl:template match="arrow-down" mode="printText">&#x2193;</xsl:template>
	
	<xsl:template match="arrow-left" mode="symbol">&#x2190;</xsl:template>
	<xsl:template match="arrow-left" mode="printText">&#x2190;</xsl:template>
	
	<xsl:template match="arrow-up" mode="symbol">&#x2191;</xsl:template>
	<xsl:template match="arrow-up" mode="printText">&#x2191;</xsl:template>
	
	<xsl:template match="phi" mode="symbol">&#x03C6;</xsl:template>
	<xsl:template match="phi" mode="printText">&#x03C6;</xsl:template>
	
	<xsl:template match="eta" mode="symbol">&#x03B7;</xsl:template>
	<xsl:template match="eta" mode="printText">&#x03B7;</xsl:template>
	
	<xsl:template match="similar" mode="symbol">
		<fo:inline font-family="Arial Unicode MS" font-weight="normal" font-style="normal">&#x223C;</fo:inline>
	</xsl:template>
	<xsl:template match="similar" mode="printText">&#x223C;</xsl:template>
	
	<xsl:template match="rho" mode="symbol">&#x03C1;</xsl:template>
	<xsl:template match="rho" mode="printText">&#x03C1;</xsl:template>
	
	<xsl:template match="tau" mode="symbol">&#x03C4;</xsl:template>
	<xsl:template match="tau" mode="printText">&#x03C4;</xsl:template>
	
	<xsl:template match="whitespace" mode="symbol">&#160;</xsl:template>
	<xsl:template match="hairspace" mode="symbol">&#8202;</xsl:template>
	<xsl:template match="whitespace" mode="printText">&#160;</xsl:template>
	<xsl:template match="hairspace" mode="printText">&#8202;</xsl:template>

	<xsl:template match="left_triangle" mode="printText">&#9668;</xsl:template>
	<xsl:template match="left_triangle" mode="symbol">&#9668;</xsl:template>

	<xsl:template match="right_triangle" mode="printText">&#9658;</xsl:template>
	<xsl:template match="right_triangle" mode="symbol">&#9658;</xsl:template>

</xsl:stylesheet>