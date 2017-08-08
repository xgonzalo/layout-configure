<?xml version="1.0" encoding="utf-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" version="1.0">

    <xsl:param name="styles" select="'../temp/style_step4.xml'" />

    <xsl:template match="/*">
        <xsl:copy>
            <xsl:copy-of select="@*"/>
            <xsl:copy-of select="node()"/>
            <xsl:copy-of select="(document($styles)//*[name() = 'Format' or name() = 'Strings'])[1]"/>
        </xsl:copy>
    </xsl:template>

</xsl:stylesheet>
