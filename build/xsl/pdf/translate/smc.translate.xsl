<?xml version="1.0" encoding="utf-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" version="1.0">

	<xsl:variable name="Lang">
		<xsl:choose>
			<xsl:when test="string-length(/InfoMap/@Lang) &gt; 0">
				<xsl:value-of select="/InfoMap/@Lang"/>
			</xsl:when>
			<xsl:when test="string-length(/MMFramework.Container/@Lang) &gt; 0">
				<xsl:value-of select="/MMFramework.Container/@Lang"/>
			</xsl:when>
			<!-- for Word -->
			<xsl:otherwise>de</xsl:otherwise>
		</xsl:choose>
	</xsl:variable>

	<xsl:template name="translate">
		<xsl:param name="ID"/>
		<xsl:param name="language" select="ancestor-or-self::*[string-length(@defaultLanguage) &gt; 0 or string-length(@Lang) &gt; 0][1]/@*[(name() = 'defaultLanguage' or name() = 'Lang') and string-length(.) &gt; 0]"/>

		<xsl:variable name="val">
			<xsl:choose>
				<xsl:when test="/*/Strings[@language = $language]/String[@id = $ID]">
					<xsl:value-of select="/*/Strings[@language = $language]/String[@id = $ID]"/>
				</xsl:when>
				<xsl:when test="/*/Strings/String[@id = $ID]">
					<xsl:value-of select="/*/Strings/String[@id = $ID]"/>
				</xsl:when>
				<xsl:otherwise>
					<xsl:for-each select="document('smc.translate.xml')">
						<xsl:value-of select="Translation/Language[@code = $language]/Translate[@ID = $ID][1]"/>
					</xsl:for-each>
				</xsl:otherwise>
			</xsl:choose>
		</xsl:variable>
		<xsl:choose>
			<xsl:when test="string-length($val) = 0">
				<xsl:value-of select="$ID"/>
			</xsl:when>
			<xsl:otherwise>
				<xsl:value-of select="$val"/>
			</xsl:otherwise>
		</xsl:choose>
	</xsl:template>

</xsl:stylesheet>