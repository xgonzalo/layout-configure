<?xml version="1.0" encoding="utf-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" version="1.0">

	<xsl:variable name="formatRoot" select="(/*/Format)[1]"/>

	<xsl:key name="RefElementKey" match="/*/Format/StyleRefs/StyleRef/Format/ParamConfig/ElementGroup/Element" use="@name"/>
	<xsl:key name="RefAssetKey" match="/*/Format/StyleRefs/StyleRef/Format/ParamConfig/AssetGroup/Asset[string-length(url/RefControl/@webdavID) &gt; 0]" use="@name"/>
	<xsl:key name="RefColorProfileKey" match="/*/Format/StyleRefs/StyleRef/Format/ParamConfig/ColorDefinition/ColorProfiles/ColorProfile" use="@name"/>

	
	
	<xsl:template match="/">
		<xsl:choose>
			<xsl:when test="not($formatRoot/StyleRefs/StyleRef[string-length(RefControl/@webdavID) &gt; 0])">
				<!-- just copy because there is nothing to merge -->
				<xsl:copy-of select="/*"/>
			</xsl:when>
			<xsl:otherwise>
				<xsl:apply-templates/>
			</xsl:otherwise>
		</xsl:choose>
	</xsl:template>

	<xsl:template match="*">
		<xsl:copy>
			<xsl:copy-of select="@*"/>
			<xsl:apply-templates/>
		</xsl:copy>
	</xsl:template>

	<xsl:template match="*" mode="copy">
		<xsl:copy>
			<xsl:copy-of select="@*"/>
			<xsl:apply-templates mode="copy"/>
		</xsl:copy>
	</xsl:template>

	<xsl:template match="ElementGroup">
		<xsl:copy>
			<xsl:copy-of select="@*"/>
			<xsl:variable name="current" select="current()"/>
			<xsl:apply-templates/>
			<xsl:apply-templates select="$formatRoot/StyleRefs/StyleRef/Format/ParamConfig/ElementGroup/Element[not($current/Element/@name = @name)]" mode="copy"/>
		</xsl:copy>
	</xsl:template>

	<xsl:template match="Element">
		<xsl:param name="refElem" select="key('RefElementKey', @name)"/>
		<xsl:param name="mergeRef" select="true()"/>
		<xsl:copy>
			<xsl:copy-of select="@*"/>
			<xsl:if test="string-length(@inheritFrom) = 0">
				<xsl:copy-of select="$refElem/@inheritFrom"/>
			</xsl:if>
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
								<xsl:apply-templates select="current()" mode="copy"/>
							</xsl:if>
						</xsl:for-each>
					</smc_properties>
					<xsl:for-each select="if">
						<xsl:copy>
							<xsl:copy-of select="@*"/>
							<xsl:for-each select="*">
								<xsl:variable name="name" select="name()"/>
								<xsl:variable name="value" select="@value"/>
								<xsl:copy>
									<xsl:copy-of select="@*"/>
									<xsl:choose>
										<xsl:when test="$refElem/if/*[name() = $name and @value = $value]">
											<xsl:apply-templates select="Element">
												<xsl:with-param name="refElem" select="$refElem/if/*[name() = $name and @value = $value]/Element"/>
											</xsl:apply-templates>
										</xsl:when>
										<xsl:otherwise>
											<xsl:apply-templates select="Element">
												<xsl:with-param name="mergeRef" select="false()"/>
											</xsl:apply-templates>
										</xsl:otherwise>
									</xsl:choose>
								</xsl:copy>
							</xsl:for-each>
						</xsl:copy>
					</xsl:for-each>
					<xsl:for-each select="$refElem/if/*">
						<xsl:variable name="name" select="name()"/>
						<xsl:variable name="value" select="@value"/>
						<xsl:if test="not($current/if/*[name() = $name and @value = $value])">
							<if>
								<xsl:apply-templates select="current()" mode="copy"/>
							</if>
						</xsl:if>
					</xsl:for-each>
				</xsl:when>
				<xsl:otherwise>
					<xsl:apply-templates/>
				</xsl:otherwise>
			</xsl:choose>
		</xsl:copy>
	</xsl:template>


	<xsl:template match="XrefDefinitions">
		<xsl:copy>
			<xsl:copy-of select="@*"/>
			<xsl:variable name="current" select="current()"/>
			<xsl:apply-templates/>
			<xsl:apply-templates select="$formatRoot/StyleRefs/StyleRef/Format/ParamConfig/XrefDefinitions/XrefDefinition[not($current/XrefDefinition/@type = @type)]" mode="copy"/>
		</xsl:copy>
	</xsl:template>



	<xsl:template match="AssetGroup">
		<xsl:copy>
			<xsl:copy-of select="@*"/>
			<xsl:variable name="current" select="current()"/>
			<xsl:apply-templates/>
			<xsl:apply-templates select="$formatRoot/StyleRefs/StyleRef/Format/ParamConfig/AssetGroup/Asset[string-length(url/RefControl/@webdavID) &gt; 0 and not($current/Asset/@name = @name)]" mode="copy"/>
		</xsl:copy>
	</xsl:template>

	<xsl:template match="TableGroup">
		<xsl:copy>
			<xsl:copy-of select="@*"/>
			<xsl:variable name="current" select="current()"/>
			<xsl:apply-templates/>
			<xsl:apply-templates select="$formatRoot/StyleRefs/StyleRef/Format/ParamConfig/TableGroup/TableDef[not($current/TableDef/@tableType = @tableType)]" mode="copy"/>
		</xsl:copy>
	</xsl:template>

	<xsl:template match="IDImagePlacement">
		<xsl:copy>
			<xsl:copy-of select="@*"/>
			<xsl:variable name="current" select="current()"/>
			<xsl:apply-templates/>
			<xsl:apply-templates select="$formatRoot/StyleRefs/StyleRef/Format/ParamConfig/IDImagePlacement/IDImage" mode="copy"/>
		</xsl:copy>
	</xsl:template>

	<xsl:template match="PowerpointTemplateFile">
		<xsl:copy>
			<xsl:copy-of select="@*"/>
			<xsl:choose>
				<xsl:when test="string-length(link.file/Refcontrol/@webdavID) = 0">
					<xsl:apply-templates select="($formatRoot/StyleRefs/StyleRef/Format/PowerpointTemplateFile/link.file[string-length(RefControl/@webdavID) &gt; 0])[1]" mode="copy"/>
				</xsl:when>
				<xsl:otherwise>
					<xsl:apply-templates/>
				</xsl:otherwise>
			</xsl:choose>
		</xsl:copy>
	</xsl:template>

	<xsl:template match="/Format | /RefControl/Format">
		<xsl:copy>
			<xsl:copy-of select="@*"/>
			<xsl:apply-templates/>
			<xsl:if test="not(PowerpointTemplateFile)">
				<xsl:apply-templates select="(StyleRefs/StyleRef/Format/PowerpointTemplateFile[string-length(link.file/RefControl/@webdavID) &gt; 0])[1]" mode="copy"/>
			</xsl:if>
		</xsl:copy>
	</xsl:template>

	<xsl:template match="Asset">
		<xsl:param name="refElem" select="key('RefAssetKey', @name)[1]"/>
		<xsl:copy>
			<xsl:copy-of select="@*"/>
			<xsl:choose>
				<xsl:when test="string-length(url/RefControl/@webdavID) = 0 and $refElem">
					<xsl:apply-templates select="$refElem/url"/>
				</xsl:when>
				<xsl:otherwise>
					<xsl:apply-templates/>
				</xsl:otherwise>
			</xsl:choose>
		</xsl:copy>
	</xsl:template>

	<xsl:template match="ColorProfiles">
		<xsl:copy>
			<xsl:copy-of select="@*"/>
			<xsl:variable name="current" select="current()"/>
			<xsl:apply-templates/>
			<xsl:apply-templates select="$formatRoot/StyleRefs/StyleRef/Format/ParamConfig/ColorDefinition/ColorProfiles/ColorProfile[not($current/Asset/@name = @name)]" mode="copy"/>
		</xsl:copy>
	</xsl:template>

	<xsl:template match="ColorProfile">
		<xsl:param name="refElem" select="key('RefColorProfileKey', @name)[1]"/>
		<xsl:copy>
			<xsl:copy-of select="@*"/>
			<xsl:choose>
				<xsl:when test="string-length(url/RefControl/@webdavID) = 0 and $refElem">
					<xsl:apply-templates select="$refElem/url"/>
				</xsl:when>
				<xsl:otherwise>
					<xsl:apply-templates/>
				</xsl:otherwise>
			</xsl:choose>
		</xsl:copy>
	</xsl:template>

	<xsl:template match="Colors">
		<xsl:copy>
			<xsl:copy-of select="@*"/>
			<xsl:variable name="current" select="current()"/>
			<xsl:apply-templates/>
			<xsl:apply-templates select="$formatRoot/StyleRefs/StyleRef/Format/ParamConfig/ColorDefinition/Colors/Color[not($current/Color/@name = @name)]" mode="copy"/>
		</xsl:copy>
	</xsl:template>

	<xsl:template match="XrefDefinitions">
		<xsl:copy>
			<xsl:copy-of select="@*"/>
			<xsl:variable name="current" select="current()"/>
			<xsl:apply-templates/>
			<xsl:apply-templates select="$formatRoot/StyleRefs/StyleRef/Format/ParamConfig/XrefDefinitions/XrefDefinition[not($current/XrefDefinition/@type = @type)]" mode="copy"/>
		</xsl:copy>
	</xsl:template>

	<xsl:template match="VariableDefinitions">
		<xsl:copy>
			<xsl:copy-of select="@*"/>
			<xsl:variable name="current" select="current()"/>
			<xsl:apply-templates/>
			<xsl:apply-templates select="$formatRoot/StyleRefs/StyleRef/Format/ParamConfig/VariableDefinitions/VariableDefinition[not($current/VariableDefinition/@name = @name)]" mode="copy"/>
		</xsl:copy>
	</xsl:template>

	<xsl:template match="PageGeometry">
		<xsl:copy>
			<xsl:copy-of select="$formatRoot/StyleRefs/StyleRef/Format/PageGeometry/@*[string-length(.) &gt; 0]"/>
			<xsl:copy-of select="@*[string-length(.) &gt; 0]"/>
			<xsl:variable name="current" select="current()"/>
			<xsl:apply-templates/>
			<xsl:if test="not(StandardPageRegion[string-length(@type) &gt; 0])">
				<xsl:for-each select="$formatRoot/StyleRefs/StyleRef/Format/PageGeometry/StandardPageRegion">
					<xsl:variable name="type" select="@type"/>
					<xsl:variable name="filter" select="@filter"/>
					<xsl:if test="not($current/StandardPageRegion[@type = $type and @filter = $filter])">
						<xsl:apply-templates select="current()"/>
					</xsl:if>
				</xsl:for-each>
			</xsl:if>
		</xsl:copy>
	</xsl:template>

	<xsl:template match="IDResources | StyleRefs"/>

</xsl:stylesheet>
