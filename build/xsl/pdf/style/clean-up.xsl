<?xml version="1.0" encoding="utf-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" version="1.0">

	<xsl:template match="*">
		<xsl:copy>
			<xsl:copy-of select="@*"/>
			<xsl:apply-templates/>
		</xsl:copy>
	</xsl:template>

	<xsl:template match="smc_font | smc_indent | smc_border | smc_spacing | smc_color | smc_pagination | smc_position | smc_layout | smc_columns | smc_hyphenation">
		<xsl:if test="@*[. != '' and name() != 'visible' and name() != 'visibleButton' and name() != 'dummy']">
			<xsl:copy>
				<xsl:copy-of select="@*[. != '' and name() != 'visible' and name() != 'visibleButton' and name() != 'dummy']"/>
				<xsl:apply-templates/>
			</xsl:copy>
		</xsl:if>
	</xsl:template>

	<xsl:template match="Color">
		<xsl:copy>
			<xsl:copy-of select="@*[name() != 'addMe' and name() != 'delButton' and string-length(.) &gt; 0]"/>
			<xsl:apply-templates/>
		</xsl:copy>
	</xsl:template>

	<xsl:template match="if">
		<xsl:if test="*">
			<xsl:copy>
				<xsl:copy-of select="@*"/>
				<xsl:apply-templates/>
			</xsl:copy>
		</xsl:if>
	</xsl:template>

</xsl:stylesheet>
