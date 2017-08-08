<?xml version="1.0" encoding="utf-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" version="1.0">

        <xsl:param name="page-width" select="297" />
        <xsl:param name="page-height" select="210" />
        
	<xsl:key name="ElementKey" match="//Format/ParamConfig/ElementGroup/Element" use="@name"/>

	<xsl:template match="*">
		<xsl:copy>
			<xsl:copy-of select="@*"/>
			<xsl:apply-templates/>
		</xsl:copy>
	</xsl:template>
	
        <xsl:template match="//Element[@name='table.cell']/smc_properties">
                <xsl:choose>
                    <xsl:when test="(($page-width = '210') and (number($page-width) &gt; number($page-height))) or (($page-height = '210') and number($page-height) &gt; number($page-width))">
                        <smc_properties>
                            <smc_font font-size-unit="pt" line-height-unit="%"/>
                            <smc_border border-style="solid" border-width="1" unit="pt"/>
                            <smc_spacing margin-bottom="0" margin-left="0" margin-right="0" margin-top="0" padding-bottom="1.25" padding-left="0.6" padding-right="0.6" padding-top="2" unit="mm"/>
                            <smc_pagination keep-together.within-page="always"/>
                        </smc_properties>
                    </xsl:when>
                    <xsl:otherwise>
                        <smc_properties>
                            <smc_font font-size-unit="pt" line-height-unit="%"/>
                            <smc_border border-style="solid" border-width="1" unit="pt"/>
                            <smc_spacing margin-bottom="0" margin-left="0" margin-right="0" margin-top="0" padding-bottom="1.25" padding-left="1.9" padding-right="1.9" padding-top="2" unit="mm"/>
                            <smc_pagination keep-together.within-page="always"/>
                        </smc_properties>
                    </xsl:otherwise>
                </xsl:choose>
        </xsl:template>

	<xsl:template match="Element[string-length(@inheritFrom) &gt; 0]">
		<xsl:param name="refElem" select="key('ElementKey', @inheritFrom)"/>
		<xsl:param name="mergeRef" select="true()"/>
		<xsl:copy>
			<xsl:copy-of select="@*"/>
			<xsl:choose>
				<xsl:when test="$mergeRef and $refElem">
					<xsl:variable name="current" select="current()"/>
					<smc_properties>
						<xsl:copy-of select="smc_properties/@*"/>
						<xsl:for-each select="smc_properties/*[name() != 'if']">
							<xsl:copy>
								<xsl:variable name="name" select="name()"/>
								<xsl:copy-of select="$refElem/smc_properties/*[name() = $name]/@*"/>
								<xsl:copy-of select="@*[string-length(.) &gt; 0]"/>
								<xsl:apply-templates/>
							</xsl:copy>
						</xsl:for-each>
						<xsl:for-each select="$refElem/smc_properties/*[name() != 'if']">
							<xsl:variable name="name" select="name()"/>
							<xsl:if test="not($current/smc_properties/*[name() = $name])">
								<xsl:apply-templates select="current()"/>
							</xsl:if>
						</xsl:for-each>
					</smc_properties>
					<xsl:for-each select="$refElem/if/*">
						<xsl:variable name="name" select="name()"/>
						<xsl:variable name="value" select="@value"/>
						<if>
							<xsl:apply-templates select="current()"/>
						</if>
					</xsl:for-each>
					<xsl:apply-templates select="if"/>
				</xsl:when>
				<xsl:otherwise>
					<xsl:apply-templates/>
				</xsl:otherwise>
			</xsl:choose>
		</xsl:copy>
	</xsl:template>

</xsl:stylesheet>
