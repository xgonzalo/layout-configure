<?xml version="1.0" encoding="utf-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" version="1.0"
				xmlns:smc="http://www.expert-communication.de/smc">

	<xsl:template name="getFormatVariableValue">
		<xsl:param name="name"/>
		<xsl:param name="defaultValue"/>
		<xsl:choose>
			<xsl:when test="/*/Format/ParamConfig/VariableDefinitions/VariableDefinition[@name = $name]">
				<xsl:for-each select="/*/Format/ParamConfig/VariableDefinitions/VariableDefinition[@name = $name]">
					<xsl:choose>
						<xsl:when test="@datatype = 'integer'">
							<xsl:value-of select="@integerValue"/>
						</xsl:when>
						<xsl:when test="@datatype = 'positiveInteger'">
							<xsl:value-of select="@positiveIntegerValue"/>
						</xsl:when>
						<xsl:when test="@datatype = 'float'">
							<xsl:value-of select="concat(@floatValue, @floatUnit)"/>
						</xsl:when>
						<xsl:when test="@datatype = 'paragraphContent'">
							<xsl:copy-of select="ParagraphContent/node()"/>
						</xsl:when>
						<!--<xsl:when test="@datatype = 'color'">
							<xsl:call-template name="writeColorAttributeValue">
								<xsl:with-param name="attrName">colorValue</xsl:with-param>
							</xsl:call-template>
						</xsl:when>-->
						<xsl:when test="string-length(@textValue) &gt; 0">
							<xsl:value-of select="@textValue"/>
						</xsl:when>
						<xsl:otherwise>
							<xsl:value-of select="@default"/>
						</xsl:otherwise>
					</xsl:choose>
				</xsl:for-each>
			</xsl:when>
			<xsl:otherwise>
				<xsl:value-of select="$defaultValue"/>
			</xsl:otherwise>
		</xsl:choose>
	</xsl:template>
</xsl:stylesheet>
