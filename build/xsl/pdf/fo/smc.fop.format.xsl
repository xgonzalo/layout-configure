<?xml version="1.0" encoding="utf-8"?>
<xsl:stylesheet
	xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
	xmlns:fo="http://www.w3.org/1999/XSL/Format"
	xmlns:fox="http://xmlgraphics.apache.org/fop/extensions"
	xmlns:pdf="http://xmlgraphics.apache.org/fop/extensions/pdf"
	xmlns:axf="http://www.antennahouse.com/names/XSL/Extensions"
	version="1.0">

	<xsl:param name="MULTI_STYLE_FORMATTING"/>
	<xsl:variable name="isMULTI_STYLE_FORMATTING" select="$MULTI_STYLE_FORMATTING = 'true' and count(//Format) &gt; 0"/>

	<xsl:key name="FormatIndex" match="//Format" use="name()"/>
	<xsl:key name="FormatElementIndex" match="//Format/ParamConfig/ElementGroup/Element" use="@name"/>
	<xsl:key name="FormatVariableIndex" match="//Format/ParamConfig/VariableDefinitions/VariableDefinition" use="@name"/>
	<xsl:key name="ColorIndex" match="//Format/ParamConfig/ColorDefinition/Colors/Color" use="@name"/>

	<xsl:template match="Format"/>

	<xsl:variable name="USE_PDF_ATTACHMENT">
		<xsl:call-template name="getTemplateVariableValue">
			<xsl:with-param name="name">USE_PDF_ATTACHMENT</xsl:with-param>
			<xsl:with-param name="defaultValue">true</xsl:with-param>
		</xsl:call-template>
	</xsl:variable>

	<xsl:variable name="USE_COLOR_PROFILE">
		<xsl:call-template name="getTemplateVariableValue">
			<xsl:with-param name="name">USE_COLOR_PROFILE</xsl:with-param>
			<xsl:with-param name="defaultValue">true</xsl:with-param>
		</xsl:call-template>
	</xsl:variable>

	<xsl:variable name="ALLOW_BLOCK_TYPE_TO_SECTION_FALLBACK">
		<xsl:call-template name="getTemplateVariableValue">
			<xsl:with-param name="name">ALLOW_BLOCK_TYPE_TO_SECTION_FALLBACK</xsl:with-param>
			<xsl:with-param name="defaultValue">false</xsl:with-param>
		</xsl:call-template>
	</xsl:variable>

	<xsl:variable name="doALLOW_BLOCK_TYPE_TO_SECTION_FALLBACK" select="$ALLOW_BLOCK_TYPE_TO_SECTION_FALLBACK = 'true'"/>

	<xsl:variable name="ALLOW_AUTOMATIC_BLOCK_FILTER">
		<xsl:call-template name="getTemplateVariableValue">
			<xsl:with-param name="name">ALLOW_AUTOMATIC_BLOCK_FILTER</xsl:with-param>
			<xsl:with-param name="defaultValue">true</xsl:with-param>
		</xsl:call-template>
	</xsl:variable>

	<xsl:variable name="doALLOW_AUTOMATIC_BLOCK_FILTER" select="not($ALLOW_AUTOMATIC_BLOCK_FILTER = 'false')"/>

	<xsl:template name="writeFoDeclarations">
		<xsl:param name="applyChildren" select="true()"/>

		<xsl:if test="$isAHMode">
			<xsl:apply-templates select="current()" mode="writeAHDocumentInfo"/>
		</xsl:if>
		<fo:declarations>
			<xsl:if test="not($isAHMode)">
				<xsl:apply-templates select="current()" mode="writeXmpMetadata"/>
			</xsl:if>
			<xsl:if test="$isPDFXMODE or (/*/Format/ParamConfig/ColorDefinition/Colors/Color[string-length(@colorprofile) &gt; 0] and not($USE_COLOR_PROFILE = 'false'))">
				<xsl:for-each select="/*/Format/ParamConfig/ColorDefinition/ColorProfiles/ColorProfile[string-length(@name) &gt; 0]/Link.File[string-length(@originalURL) &gt; 0]">
					<xsl:variable name="colorProfileName" select="parent::ColorProfile/@name"/>
					<xsl:if test="not(parent::ColorProfile/preceding-sibling::ColorProfile[@name = $colorProfileName and Link.File[string-length(@originalURL) &gt; 0]])">
						<xsl:apply-templates select="current()" mode="format"/>
					</xsl:if>
				</xsl:for-each>
			</xsl:if>
			<!--<xsl:if test="$isOffline and not($isPDFXMODE) and $USE_PDF_ATTACHMENT = 'true'">

				<xsl:variable name="attachmentList" select="list:new()"/>
				<xsl:variable name="attachmentNameList" select="list:new()"/>

				<xsl:choose>
					<xsl:when test="$applyChildren">
						<xsl:variable name="clear" select="map:clear($ATTACHMENT_NAME_MAP)"/>
						<xsl:for-each select="descendant-or-self::InfoMap//Link.File[string-length(@originalURL) &gt; 0 and not(ancestor::InfoMap[1]/@fileSectionExtension = 'pdf' or parent::includefile or parent::ColorProfile)]">
							<xsl:apply-templates select="current()" mode="writeAttachmentFile">
								<xsl:with-param name="attachmentList" select="$attachmentList"/>
								<xsl:with-param name="attachmentNameList" select="$attachmentNameList"/>
							</xsl:apply-templates>
						</xsl:for-each>
					</xsl:when>
					<xsl:when test="not(@fileSectionExtension = 'pdf' or parent::includefile or parent::ColorProfile)">
						<xsl:for-each select="*[name() = 'Block' or name() = 'block.titlepage' or name() = 'headline.content']//Link.File[string-length(@originalURL) &gt; 0]">
							<xsl:apply-templates select="current()" mode="writeAttachmentFile">
								<xsl:with-param name="attachmentList" select="$attachmentList"/>
								<xsl:with-param name="attachmentNameList" select="$attachmentNameList"/>
							</xsl:apply-templates>
						</xsl:for-each>
					</xsl:when>
				</xsl:choose>
			</xsl:if>-->

			<xsl:variable name="pdfPageLayout">
				<xsl:call-template name="getTemplateVariableValue">
					<xsl:with-param name="name">PDF_PAGE_LAYOUT</xsl:with-param>
				</xsl:call-template>
			</xsl:variable>

			<xsl:variable name="previewPdfPageLayout">
				<xsl:call-template name="getTemplateVariableValue">
					<xsl:with-param name="name">PREVIEW_PDF_PAGE_LAYOUT</xsl:with-param>
					<xsl:with-param name="defaultValue" select="$pdfPageLayout"/>
				</xsl:call-template>
			</xsl:variable>

			<xsl:variable name="pageLayoutValue">
				<xsl:choose>
		    		<xsl:when test="$CMS = 'CMS'">
		    			<xsl:value-of select="$previewPdfPageLayout"/>
		    		</xsl:when>
		    		<xsl:when test="not($CMS = 'CMS')">
		    			<xsl:value-of select="$pdfPageLayout"/>
		    		</xsl:when>
		    	</xsl:choose>
			</xsl:variable>

			<xsl:variable name="validateLayoutValue">
				<xsl:if test="$pageLayoutValue = 'SinglePage' or $pageLayoutValue = 'OneColumn' or 
	    			$pageLayoutValue = 'TwoColumnLeft' or $pageLayoutValue = 'TwoColumnRight' or $pageLayoutValue = 'TwoPageLeft' 
	    			or $pageLayoutValue = 'TwoPageRight'">
	    			<xsl:text>true</xsl:text>
				</xsl:if>
			</xsl:variable>

			<xsl:variable name="pdfFitWindow">
				<xsl:call-template name="getTemplateVariableValue">
					<xsl:with-param name="name">PDF_FIT_WINDOW</xsl:with-param>
				</xsl:call-template>
			</xsl:variable>

			<xsl:variable name="previewPdfFitWindow">
				<xsl:call-template name="getTemplateVariableValue">
					<xsl:with-param name="name">PREVIEW_PDF_FIT_WINDOW</xsl:with-param>
					<xsl:with-param name="defaultValue" select="$pdfFitWindow"/>
				</xsl:call-template>
			</xsl:variable>

			<xsl:variable name="fitWindowValue">
				<xsl:choose>
		    		<xsl:when test="$CMS = 'CMS'">
		    			<xsl:value-of select="$previewPdfFitWindow"/>
		    		</xsl:when>
		    		<xsl:when test="not($CMS = 'CMS')">
		    			<xsl:value-of select="$pdfFitWindow"/>
		    		</xsl:when>
		    	</xsl:choose>
			</xsl:variable>

			<xsl:variable name="validateFitWindow">
				<xsl:if test="$fitWindowValue = 'true' or $fitWindowValue = 'false'">
	    			<xsl:text>true</xsl:text>
				</xsl:if>
			</xsl:variable>

			<pdf:catalog>
				<xsl:if test="string-length($pageLayoutValue) &gt; 0 and $validateLayoutValue = 'true'">
				    <pdf:name key="PageLayout">
				    	<xsl:value-of select="$pageLayoutValue"/>
				    </pdf:name>
				</xsl:if>
				<xsl:if test="string-length($fitWindowValue) &gt; 0 and $validateFitWindow = 'true'">
				    <pdf:dictionary key="ViewerPreferences">
				        <pdf:boolean key="FitWindow">
				        	<xsl:value-of select="$fitWindowValue"/>
				        </pdf:boolean>
				    </pdf:dictionary>
				</xsl:if>
			</pdf:catalog>

		</fo:declarations>
	</xsl:template>

	<xsl:template match="*" mode="writeAHDocumentInfo">
		<xsl:param name="title">
			<xsl:choose>
				<xsl:when test="string-length(//block.titlepage/title) &gt; 0">
					<xsl:apply-templates select="(//block.titlepage/title)[1]" mode="printText"/>
				</xsl:when>
				<xsl:otherwise>
					<xsl:apply-templates select="(//Headline.content)[1]" mode="printText"/>
				</xsl:otherwise>
			</xsl:choose>
		</xsl:param>
		<xsl:if test="string-length($title) &gt; 0">
			<axf:document-info name="title" value="{$title}"/>
		</xsl:if>
		<xsl:choose>
			<xsl:when test="string-length(/*/User/Property[@name = 'SMCDOCINFO:sn']/@value) &gt; 0 and string-length(/*/User/Property[@name = 'SMCDOCINFO:givenName']/@value) &gt; 0">
				<axf:document-info name="author" value="{concat(/*/User/Property[@name = 'SMCDOCINFO:givenName']/@value, ' ', /*/User/Property[@name = 'SMCDOCINFO:sn']/@value)}"/>
			</xsl:when>
			<xsl:when test="string-length(/*/User/Property[@name = 'SMCDOCINFO:cn']/@value) &gt; 0">
				<axf:document-info name="author" value="{/*/User/Property[@name = 'SMCDOCINFO:cn']/@value}"/>
			</xsl:when>
		</xsl:choose>

		<!--<axf:document-info name="author" value="The author"/>-->
	</xsl:template>

	<xsl:template match="*" mode="writeXmpMetadata">
		<xsl:param name="title">
			<xsl:choose>
				<xsl:when test="string-length(.//block.titlepage/title) &gt; 0">
					<xsl:apply-templates select="(.//block.titlepage/title)[1]" mode="printText"/>
				</xsl:when>
				<xsl:otherwise>
					<xsl:apply-templates select="(.//Headline.content)[1]" mode="printText"/>
				</xsl:otherwise>
			</xsl:choose>
		</xsl:param>
		<x:xmpmeta xmlns:x="adobe:ns:meta/">
			<rdf:RDF xmlns:rdf="http://www.w3.org/1999/02/22-rdf-syntax-ns#">
				<rdf:Description rdf:about="" xmlns:dc="http://purl.org/dc/elements/1.1/">
					<!-- Dublin Core properties go here -->
					<xsl:if test="string-length($title) &gt; 0">
						<dc:title>
							<xsl:value-of select="$title"/>
						</dc:title>
					</xsl:if>
					<xsl:choose>
						<xsl:when test="string-length(/*/User/Property[@name = 'SMCDOCINFO:sn']/@value) &gt; 0 and string-length(/*/User/Property[@name = 'SMCDOCINFO:givenName']/@value) &gt; 0">
							<dc:creator>
								<xsl:value-of select="concat(/*/User/Property[@name = 'SMCDOCINFO:givenName']/@value, ' ', /*/User/Property[@name = 'SMCDOCINFO:sn']/@value)"/>
							</dc:creator>
						</xsl:when>
						<xsl:when test="string-length(/*/User/Property[@name = 'SMCDOCINFO:cn']/@value) &gt; 0">
							<dc:creator>
								<xsl:value-of select="/*/User/Property[@name = 'SMCDOCINFO:cn']/@value"/>
							</dc:creator>
						</xsl:when>
					</xsl:choose>
				</rdf:Description>
				<rdf:Description rdf:about="" xmlns:xmp="http://ns.adobe.com/xap/1.0/">
					<!-- XMP properties go here -->
					<xmp:CreatorTool>Smart Media Creator</xmp:CreatorTool>
				</rdf:Description>
			</rdf:RDF>

		</x:xmpmeta>
	</xsl:template>

	<xsl:template match="Link.File" mode="writeAttachmentFile">
		<xsl:param name="attachmentList"/>
		<xsl:param name="attachmentNameList"/>

		<!--<xsl:variable name="idx" select="list:indexOf($attachmentList, string(@originalURL))"/>
		<xsl:if test="$idx = '-1'">
			<xsl:variable name="preFilename" select="concat(@TargetTitle, '.', @extension)"/>
			<xsl:variable name="filename">
				<xsl:choose>
					<xsl:when test="not(list:indexOf($attachmentNameList, string($preFilename)) = '-1')">
						<xsl:value-of select="concat(@TargetTitle, '-', generate-id(), '.', @extension)"/>
					</xsl:when>
					<xsl:otherwise>
						<xsl:value-of select="$preFilename"/>
					</xsl:otherwise>
				</xsl:choose>
			</xsl:variable>
			<xsl:variable name="put" select="map:put($ATTACHMENT_NAME_MAP, string(@originalURL), string($filename))"/>
			<pdf:embedded-file filename="{$filename}" xmlns:pdf="http://xmlgraphics.apache.org/fop/extensions/pdf">
				<xsl:attribute name="src">
					<xsl:choose>
						<xsl:when test="starts-with(@originalURL, '/')">
							<xsl:value-of select="concat($productionImagePath, @originalURL)"/>
						</xsl:when>
						<xsl:otherwise>
							<xsl:value-of select="concat($productionImagePath, '/', @originalURL)"/>
						</xsl:otherwise>
					</xsl:choose>
				</xsl:attribute>
			</pdf:embedded-file>
			<xsl:variable name="add" select="list:add($attachmentList, string(@originalURL))"/>
			<xsl:variable name="add2" select="list:add($attachmentNameList, string($filename))"/>
		</xsl:if>-->
	</xsl:template>

	<xsl:template match="ColorProfiles" mode="format">
		<xsl:if test="$isPDFXMODE and /*/Format/ParamConfig/ColorDefinition/ColorProfiles/ColorProfile[string-length(@name) &gt; 0]/Link.File[string-length(@originalURL) &gt; 0]">
			<fo:declarations>
				<xsl:for-each select="/*/Format/ParamConfig/ColorDefinition/ColorProfiles/ColorProfile[string-length(@name) &gt; 0]/Link.File[string-length(@originalURL) &gt; 0]">
					<xsl:apply-templates select="current()" mode="format"/>
				</xsl:for-each>
			</fo:declarations>
		</xsl:if>
	</xsl:template>

	<xsl:template match="Link.File" mode="format">
		<xsl:variable name="serverURL">
			<xsl:choose>
				<xsl:when test="$isOffline">
					<xsl:value-of select="$productionImagePath"/>
				</xsl:when>
				<xsl:when test="string-length(@serverURL) &gt; 0">
					<xsl:value-of select="@serverURL"/>
				</xsl:when>
				<xsl:otherwise>
					<xsl:value-of select="$brokerServerURL"/>
				</xsl:otherwise>
			</xsl:choose>
		</xsl:variable>
		<fo:color-profile src="{$serverURL}{@originalURL}" color-profile-name="{ancestor-or-self::ColorProfile[1]/@name}"/>
	</xsl:template>

	<xsl:template name="getStandardPageRegionAttribute">
		<xsl:param name="pageRegionType"/>
		<xsl:param name="filter" select="ancestor::InfoMap[@filter[string-length(.) &gt; 0]][1]/@filter"/>
		<xsl:param name="attributeName"/>
		<xsl:param name="defaultValue"/>
		<xsl:variable name="val">
			<xsl:choose>
				<xsl:when test="string-length($filter) &gt; 0 and key('FormatIndex', 'Format')[1]/PageGeometry[1]/StandardPageRegion[string-length(@filter) &gt; 0 and contains($filter, @filter) and (string-length($pageRegionType) = 0 or @type = $pageRegionType)]">
					<xsl:value-of select="key('FormatIndex', 'Format')[1]/PageGeometry[1]/StandardPageRegion[string-length(@filter) &gt; 0 and contains($filter, @filter) and (string-length($pageRegionType) = 0 or @type = $pageRegionType)][1]/@*[name() = $attributeName]"/>
				</xsl:when>
				<xsl:otherwise>
					<xsl:value-of select="key('FormatIndex', 'Format')[1]/PageGeometry[1]/StandardPageRegion[(string-length($pageRegionType) = 0 or @type = $pageRegionType) and string-length(@filter) = 0][1]/@*[name() = $attributeName]"/>
				</xsl:otherwise>
			</xsl:choose>
		</xsl:variable>
		<xsl:variable name="formatVal">
			<xsl:choose>
				<xsl:when test="string-length($val) = 0">
					<xsl:value-of select="concat(key('FormatIndex', 'Format')[1]/PageGeometry[1]/@*[name() = $attributeName], key('FormatIndex', 'Format')[1]/PageGeometry[1]/@unit)"/>
				</xsl:when>
				<xsl:otherwise>
					<xsl:value-of select="concat($val, key('FormatIndex', 'Format')[1]/PageGeometry[1]/@unit)"/>
				</xsl:otherwise>
			</xsl:choose>
		</xsl:variable>
		<xsl:choose>
			<xsl:when test="string-length($formatVal) = 0">
				<xsl:value-of select="$defaultValue"/>
			</xsl:when>
			<xsl:otherwise>
				<xsl:value-of select="$formatVal"/>
			</xsl:otherwise>
		</xsl:choose>
	</xsl:template>

	<xsl:template name="getStandardPageRegionFormat">
		<xsl:param name="pageRegionElem"/>
		<xsl:param name="pageRegionType"/>
		<xsl:param name="filter" select="ancestor::InfoMap[@filter[string-length(.) &gt; 0]][1]/@filter"/>
		<xsl:param name="name"/>
		<xsl:param name="defaultValue"/>

		<xsl:variable name="formatElemName">
			<xsl:choose>
				<xsl:when test="$pageRegionElem">
					<xsl:value-of select="$pageRegionElem/@formatRef"/>
				</xsl:when>
				<xsl:when test="$isMULTI_STYLE_FORMATTING and ancestor-or-self::*[name() = 'Format' or (name() = 'InfoMap' and Format)][1]">
					<xsl:choose>
						<xsl:when test="ancestor-or-self::*[name() = 'Format' or (name() = 'InfoMap' and Format)][1]/self::InfoMap">
							<xsl:value-of select="ancestor-or-self::InfoMap[Format][1]/Format/PageGeometry/StandardPageRegion[string-length($pageRegionType) = 0 or @type = $pageRegionType][1]/@formatRef"/>
						</xsl:when>
						<xsl:otherwise>
							<xsl:value-of select="ancestor-or-self::Format[1]/PageGeometry/StandardPageRegion[string-length($pageRegionType) = 0 or @type = $pageRegionType][1]/@formatRef"/>
						</xsl:otherwise>
					</xsl:choose>
				</xsl:when>
				<xsl:when test="string-length($filter) &gt; 0 and key('FormatIndex', 'Format')[1]/PageGeometry[1]/StandardPageRegion[string-length(@filter) &gt; 0 and contains($filter, @filter) and (string-length($pageRegionType) = 0 or @type = $pageRegionType)]">
					<xsl:value-of select="key('FormatIndex', 'Format')[1]/PageGeometry[1]/StandardPageRegion[string-length(@filter) &gt; 0 and contains($filter, @filter) and (string-length($pageRegionType) = 0 or @type = $pageRegionType)][1]/@formatRef"/>
				</xsl:when>
				<xsl:otherwise>
					<xsl:value-of select="key('FormatIndex', 'Format')[1]/PageGeometry[1]/StandardPageRegion[(string-length($pageRegionType) = 0 or @type = $pageRegionType) and string-length(@filter) = 0][1]/@formatRef"/>
				</xsl:otherwise>
			</xsl:choose>
		</xsl:variable>

		<xsl:choose>
			<xsl:when test="string-length($formatElemName) &gt; 0">
				<xsl:variable name="val">
					<xsl:call-template name="getFormat">
						<xsl:with-param name="name" select="$formatElemName"/>
						<xsl:with-param name="attributeName" select="$name"/>
					</xsl:call-template>
				</xsl:variable>
				<xsl:choose>
					<xsl:when test="string-length($val) = 0">
						<xsl:value-of select="$defaultValue"/>
					</xsl:when>
					<xsl:otherwise>
						<xsl:value-of select="$val"/>
					</xsl:otherwise>
				</xsl:choose>
			</xsl:when>
			<xsl:otherwise>
				<xsl:value-of select="$defaultValue"/>
			</xsl:otherwise>
		</xsl:choose>

	</xsl:template>

	<xsl:template name="getStandardPageRegionHeadlineHeight">
		<xsl:param name="pageRegionType"/>
		<xsl:param name="filter"/>
		<xsl:call-template name="getStandardPageRegionSpace">
			<xsl:with-param name="filter" select="$filter"/>
			<xsl:with-param name="pageRegionType" select="$pageRegionType"/>
			<xsl:with-param name="elementName">Headline</xsl:with-param>
			<xsl:with-param name="attributeName">height</xsl:with-param>
		</xsl:call-template>
	</xsl:template>

	<xsl:template name="getStandardPageRegionSublineHeight">
		<xsl:param name="pageRegionType"/>
		<xsl:param name="filter"/>
		<xsl:call-template name="getStandardPageRegionSpace">
			<xsl:with-param name="filter" select="$filter"/>
			<xsl:with-param name="pageRegionType" select="$pageRegionType"/>
			<xsl:with-param name="elementName">Subline</xsl:with-param>
			<xsl:with-param name="attributeName">height</xsl:with-param>
		</xsl:call-template>
	</xsl:template>

	<xsl:template name="getStandardPageRegionSpace">
		<xsl:param name="pageRegionType"/>
		<xsl:param name="filter"/>
		<xsl:param name="elementName"/>
		<xsl:param name="attributeName"/>
		<xsl:variable name="val">
			<xsl:choose>
				<xsl:when test="string-length($filter) &gt; 0 and key('FormatIndex', 'Format')[1]/PageGeometry[1]/StandardPageRegion[string-length(@filter) &gt; 0 and contains($filter, @filter) and (string-length($pageRegionType) = 0 or @type = $pageRegionType)]">
					<xsl:value-of select="key('FormatIndex', 'Format')[1]/PageGeometry[1]/StandardPageRegion[string-length(@filter) &gt; 0 and contains($filter, @filter) and (string-length($pageRegionType) = 0 or @type = $pageRegionType)][1]/*[name() = $elementName]/@*[name() = $attributeName]"/>
				</xsl:when>
				<xsl:otherwise>
					<xsl:value-of select="key('FormatIndex', 'Format')[1]/PageGeometry[1]/StandardPageRegion[string-length($pageRegionType) = 0 or @type = $pageRegionType][1]/*[name() = $elementName]/@*[name() = $attributeName]"/>
				</xsl:otherwise>
			</xsl:choose>
		</xsl:variable>
		<xsl:choose>
			<xsl:when test="string(number($val)) != 'NaN'">
				<xsl:value-of select="concat($val, key('FormatIndex', 'Format')[1]/PageGeometry[1]/@unit)"/>
			</xsl:when>
			<xsl:otherwise>0</xsl:otherwise>
		</xsl:choose>
	</xsl:template>

	<xsl:template name="getTemplateGraphicURL">
		<xsl:param name="name"/>
		<xsl:param name="language"/>
		<xsl:param name="defaultValue"/>

		<xsl:variable name="graphicURL">
			<xsl:choose>
				<xsl:when test="$isMULTI_STYLE_FORMATTING and ancestor-or-self::*[name() = 'Format' or (name() = 'InfoMap' and Format)][1]">
					<xsl:choose>
						<xsl:when test="ancestor-or-self::*[name() = 'Format' or (name() = 'InfoMap' and Format)][1]/self::InfoMap">
							<xsl:for-each select="ancestor-or-self::InfoMap[Format][1]/Format/ParamConfig/AssetGroup/Asset[@name = $name][1]/Media.theme">
								<xsl:call-template name="getPicURL"/>
							</xsl:for-each>
						</xsl:when>
						<xsl:otherwise>
							<xsl:for-each select="ancestor-or-self::Format[1]/ParamConfig/AssetGroup/Asset[@name = $name][1]/Media.theme">
								<xsl:call-template name="getPicURL"/>
							</xsl:for-each>
						</xsl:otherwise>
					</xsl:choose>
				</xsl:when>
				<xsl:otherwise>
					<xsl:for-each select="(key('FormatIndex', 'Format')[1]/ParamConfig/AssetGroup/Asset[@name = $name])[1]/Media.theme">
						<xsl:call-template name="getPicURL"/>
					</xsl:for-each>
				</xsl:otherwise>
			</xsl:choose>
		</xsl:variable>

		<xsl:variable name="languageGraphicURL">
			<xsl:if test="$isOffline and string-length($language) &gt; 0">
				<xsl:choose>
					<xsl:when test="$isMULTI_STYLE_FORMATTING and ancestor-or-self::*[name() = 'Format' or (name() = 'InfoMap' and Format)][1]">
						<xsl:choose>
							<xsl:when test="ancestor-or-self::*[name() = 'Format' or (name() = 'InfoMap' and Format)][1]/self::InfoMap">
								<xsl:for-each select="ancestor-or-self::InfoMap[Format][1]/Format[1]/ParamConfig/AssetGroup/Asset[@name = $name][1]/Media.theme/RefControl/substitute[@language = $language][1]">
									<xsl:call-template name="getPicURL"/>
								</xsl:for-each>
							</xsl:when>
							<xsl:otherwise>
								<xsl:for-each select="ancestor-or-self::Format[1]/ParamConfig/AssetGroup/Asset[@name = $name][1]/Media.theme/RefControl/substitute[@language = $language][1]">
									<xsl:call-template name="getPicURL"/>
								</xsl:for-each>
							</xsl:otherwise>
						</xsl:choose>
					</xsl:when>
					<xsl:otherwise>
						<xsl:for-each select="(key('FormatIndex', 'Format')[1]/ParamConfig/AssetGroup/Asset[@name = $name])[1]/Media.theme/RefControl/substitute[@language = $language][1]">
							<xsl:call-template name="getPicURL"/>
						</xsl:for-each>
					</xsl:otherwise>
				</xsl:choose>
			</xsl:if>
		</xsl:variable>

		<xsl:choose>
			<xsl:when test="string-length($languageGraphicURL) &gt; 0">
				<xsl:value-of select="$languageGraphicURL"/>
			</xsl:when>
			<xsl:when test="string-length($graphicURL) &gt; 0">
				<xsl:value-of select="$graphicURL"/>
			</xsl:when>
			<xsl:otherwise>
				<xsl:value-of select="$defaultValue"/>
			</xsl:otherwise>
		</xsl:choose>

	</xsl:template>

	<xsl:template name="addFormat">
		<xsl:param name="name"/>
		<xsl:param name="attributeNamesList"/>
		<xsl:param name="applyRegionFormats"/>
		<xsl:param name="currentElement" select="current()"/>
		<xsl:param name="altCurrentElement"/>

		<xsl:variable name="formatOverwrite" select="string(@formatOverwrite)"/>

		<xsl:if test="$applyRegionFormats = 'true'">
			<xsl:for-each select="ancestor-or-self::Region">
				<xsl:call-template name="writeProperties">
					<xsl:with-param name="attributeNamesList">|color|font-family|font-stytle|font-size|font-weight|word-spacing|letter-spacing|text-decoration|text-transform|line-height</xsl:with-param>
				</xsl:call-template>
			</xsl:for-each>
		</xsl:if>

		<xsl:choose>
			<xsl:when test="$isMULTI_STYLE_FORMATTING and ancestor-or-self::*[name() = 'Format' or (name() = 'InfoMap' and Format)][1]">
				<xsl:choose>
					<xsl:when test="ancestor-or-self::*[name() = 'Format' or (name() = 'InfoMap' and Format)][1]/self::InfoMap">
						<xsl:for-each select="ancestor-or-self::InfoMap[Format][1]/Format/ParamConfig/ElementGroup/Element[@name = $name]">
							<xsl:call-template name="applyFormatAttributes">
								<xsl:with-param name="currentElement" select="$currentElement"/>
								<xsl:with-param name="altCurrentElement" select="$altCurrentElement"/>
								<xsl:with-param name="attributeNamesList" select="$attributeNamesList"/>
							</xsl:call-template>
						</xsl:for-each>
					</xsl:when>
					<xsl:otherwise>
						<xsl:for-each select="ancestor-or-self::Format[1]/ParamConfig/ElementGroup/Element[@name = $name]">
							<xsl:call-template name="applyFormatAttributes">
								<xsl:with-param name="currentElement" select="$currentElement"/>
								<xsl:with-param name="altCurrentElement" select="$altCurrentElement"/>
								<xsl:with-param name="attributeNamesList" select="$attributeNamesList"/>
							</xsl:call-template>
						</xsl:for-each>
					</xsl:otherwise>
				</xsl:choose>
			</xsl:when>
			<xsl:otherwise>
				<xsl:choose>
					<xsl:when test="$formatOverwrite != '' and key('FormatElementIndex', $formatOverwrite)[1]">
						<xsl:for-each select="key('FormatElementIndex', $formatOverwrite)">
							<xsl:call-template name="applyFormatAttributes">
								<xsl:with-param name="currentElement" select="$currentElement"/>
								<xsl:with-param name="altCurrentElement" select="$altCurrentElement"/>
								<xsl:with-param name="attributeNamesList" select="$attributeNamesList"/>
							</xsl:call-template>
						</xsl:for-each>
					</xsl:when>
					<xsl:otherwise>
						<xsl:for-each select="key('FormatElementIndex', $name)">
							<xsl:call-template name="applyFormatAttributes">
								<xsl:with-param name="currentElement" select="$currentElement"/>
								<xsl:with-param name="altCurrentElement" select="$altCurrentElement"/>
								<xsl:with-param name="attributeNamesList" select="$attributeNamesList"/>
							</xsl:call-template>
						</xsl:for-each>
					</xsl:otherwise>
				</xsl:choose>
			</xsl:otherwise>
		</xsl:choose>

	</xsl:template>

	<xsl:template name="applyCondition">
		<xsl:param name="currentElement"/>
		<xsl:param name="attributeNamesList"/>

		<xsl:for-each select="*[string-length(@value) &gt; 0]">
			<xsl:variable name="value" select="string(@value)"/>
			<xsl:variable name="name" select="string(name())"/>
			<xsl:choose>
				<xsl:when test="$name = 'table-type'">
					<xsl:if test="$currentElement/ancestor-or-self::*[name() = 'table' or name() = 'table.NoBorder'][1]/@typ = $value">
						<xsl:apply-templates select="Element" mode="applyFormatAttributes">
							<xsl:with-param name="currentElement" select="$currentElement"/>
							<xsl:with-param name="attributeNamesList" select="$attributeNamesList"/>
						</xsl:apply-templates>
					</xsl:if>
				</xsl:when>
				<xsl:when test="$name = 'warning-type'">
					<xsl:variable name="noticeDefaultType">
						<xsl:call-template name="getTemplateVariableValue">
							<xsl:with-param name="name" select="'NOTICE_DEFAULT_TYPE'"/>
							<xsl:with-param name="defaultValue">xyz</xsl:with-param>
						</xsl:call-template>
					</xsl:variable>
					<xsl:if test="$currentElement/ancestor-or-self::InfoItem.Warning[@type = $value or (string-length(@type) = 0 and $value = $noticeDefaultType)]">
						<xsl:apply-templates select="Element" mode="applyFormatAttributes">
							<xsl:with-param name="currentElement" select="$currentElement"/>
							<xsl:with-param name="attributeNamesList" select="$attributeNamesList"/>
						</xsl:apply-templates>
					</xsl:if>
				</xsl:when>
				<xsl:when test="$name = 'enum-type'">
					<xsl:variable name="enumDefaultType">
						<xsl:call-template name="getTemplateVariableValue">
							<xsl:with-param name="name" select="'ENUM_DEFAULT_TYPE'"/>
							<xsl:with-param name="defaultValue">xyz</xsl:with-param>
						</xsl:call-template>
					</xsl:variable>
					<xsl:if test="$currentElement/ancestor-or-self::Enum[1][@type = $value or (string-length(@type) = 0 and $value = $enumDefaultType)]">
						<xsl:apply-templates select="Element" mode="applyFormatAttributes">
							<xsl:with-param name="currentElement" select="$currentElement"/>
							<xsl:with-param name="attributeNamesList" select="$attributeNamesList"/>
						</xsl:apply-templates>
					</xsl:if>
				</xsl:when>
				<xsl:when test="$name = 'block-type'">
					<xsl:variable name="blockDefaultType">
						<xsl:call-template name="getTemplateVariableValue">
							<xsl:with-param name="name">DEFAULT_BLOCK_FORMAT</xsl:with-param>
							<xsl:with-param name="defaultValue">xyz</xsl:with-param>
						</xsl:call-template>
					</xsl:variable>
					<xsl:if test="$currentElement/ancestor-or-self::*[name() = 'Block' or name() = 'block.titlepage'][1][@Typ = $value or @Function = $value
							or (string-length(@Typ) = 0 and $value = 'null') or ((string-length(@Typ) = 0 or @Typ = 'null') and $value = $blockDefaultType)]
							or ($doALLOW_BLOCK_TYPE_TO_SECTION_FALLBACK and $currentElement/ancestor-or-self::InfoMap[1][@Typ = $value or (string-length(@Typ) = 0 and $value = 'null')])">
						<xsl:apply-templates select="Element" mode="applyFormatAttributes">
							<xsl:with-param name="currentElement" select="$currentElement"/>
							<xsl:with-param name="attributeNamesList" select="$attributeNamesList"/>
						</xsl:apply-templates>
					</xsl:if>
				</xsl:when>
				<xsl:when test="$name = 'section-type'">
					<xsl:if test="$currentElement/ancestor-or-self::InfoMap[1][@Typ = $value or (string-length(@Typ) = 0 and $value = 'null')]">
						<xsl:apply-templates select="Element" mode="applyFormatAttributes">
							<xsl:with-param name="currentElement" select="$currentElement"/>
							<xsl:with-param name="attributeNamesList" select="$attributeNamesList"/>
						</xsl:apply-templates>
					</xsl:if>
				</xsl:when>
				<xsl:when test="$name = 'filter'">
					<xsl:if test="($doALLOW_AUTOMATIC_BLOCK_FILTER and $currentElement/ancestor-or-self::*[name() = 'Block' or name() = 'block.titlepage'][contains(@filter, $value)]) or $currentElement[contains(@filter, $value)]">
						<xsl:apply-templates select="Element" mode="applyFormatAttributes">
							<xsl:with-param name="currentElement" select="$currentElement"/>
							<xsl:with-param name="attributeNamesList" select="$attributeNamesList"/>
						</xsl:apply-templates>
					</xsl:if>
				</xsl:when>
				<xsl:when test="$name = 'parent-filter'">
					<xsl:if test="$currentElement[contains(@inheritedFilter, $value)] or $currentElement/ancestor::*[contains(@filter, $value) or contains(@inheritedFilter, $value)]">
						<xsl:apply-templates select="Element" mode="applyFormatAttributes">
							<xsl:with-param name="currentElement" select="$currentElement"/>
							<xsl:with-param name="attributeNamesList" select="$attributeNamesList"/>
						</xsl:apply-templates>
					</xsl:if>
				</xsl:when>
				<xsl:when test="$name = 'metafilter'">
					<xsl:if test="$currentElement[contains(@metafilter, $value)]">
						<xsl:apply-templates select="Element" mode="applyFormatAttributes">
							<xsl:with-param name="currentElement" select="$currentElement"/>
							<xsl:with-param name="attributeNamesList" select="$attributeNamesList"/>
						</xsl:apply-templates>
					</xsl:if>
				</xsl:when>
				<xsl:when test="$name = 'parent-metafilter'">
					<xsl:if test="$currentElement/ancestor::*[contains(@metafilter, $value)] or $currentElement/ancestor-or-self::InfoMap[1]/Properties/Property[@name = concat('SMCDOCINFO:', substring-before($value, ':')) and @value = substring-after($value, ':')]">
						<xsl:apply-templates select="Element" mode="applyFormatAttributes">
							<xsl:with-param name="currentElement" select="$currentElement"/>
							<xsl:with-param name="attributeNamesList" select="$attributeNamesList"/>
						</xsl:apply-templates>
					</xsl:if>
				</xsl:when>
				<xsl:when test="$name = 'first-parent-filter'">
					<xsl:if test="$currentElement/parent::*[contains(@filter, $value)]">
						<xsl:apply-templates select="Element" mode="applyFormatAttributes">
							<xsl:with-param name="currentElement" select="$currentElement"/>
							<xsl:with-param name="attributeNamesList" select="$attributeNamesList"/>
						</xsl:apply-templates>
					</xsl:if>
				</xsl:when>
				<xsl:when test="$name = 'language'">
					<xsl:variable name="currLanguage">
						<xsl:call-template name="getCurrentLanguage">
							<xsl:with-param name="currentElement" select="$currentElement"/>
						</xsl:call-template>
					</xsl:variable>
					<xsl:if test="$currLanguage = $value">
						<xsl:apply-templates select="Element" mode="applyFormatAttributes">
							<xsl:with-param name="currentElement" select="$currentElement"/>
							<xsl:with-param name="attributeNamesList" select="$attributeNamesList"/>
						</xsl:apply-templates>
					</xsl:if>
				</xsl:when>
				<xsl:when test="$name = 'ancestor-element'">
					<xsl:variable name="result">
						<xsl:apply-templates select="current()" mode="checkCondition">
							<xsl:with-param name="currentElement" select="$currentElement"/>
						</xsl:apply-templates>
					</xsl:variable>
					<xsl:if test="$result = 'true'">
						<xsl:apply-templates select="Element" mode="applyFormatAttributes">
							<xsl:with-param name="currentElement" select="$currentElement"/>
							<xsl:with-param name="attributeNamesList" select="$attributeNamesList"/>
						</xsl:apply-templates>
					</xsl:if>
				</xsl:when>
				<xsl:when test="$name = 'changed-state'">
					<xsl:if test="$currentElement/ancestor-or-self::*[@Changed][1][@Changed = $value]">
						<xsl:apply-templates select="Element" mode="applyFormatAttributes">
							<xsl:with-param name="currentElement" select="$currentElement"/>
							<xsl:with-param name="attributeNamesList" select="$attributeNamesList"/>
						</xsl:apply-templates>
					</xsl:if>
				</xsl:when>
			</xsl:choose>
		</xsl:for-each>
	</xsl:template>

	<xsl:template match="Element" mode="applyFormatAttributes" name="applyFormatAttributes">
		<xsl:param name="currentElement"/>
		<xsl:param name="altCurrentElement"/>
		<xsl:param name="attributeNamesList"/>

		<xsl:for-each select="*[name() != 'if']">
			<xsl:call-template name="writeProperties">
				<xsl:with-param name="attributeNamesList" select="$attributeNamesList"/>
			</xsl:call-template>
		</xsl:for-each>

		<xsl:for-each select="if">
			<xsl:call-template name="applyCondition">
				<xsl:with-param name="currentElement" select="$currentElement"/>
				<xsl:with-param name="attributeNamesList" select="$attributeNamesList"/>
			</xsl:call-template>
			<xsl:if test="$altCurrentElement">
				<xsl:call-template name="applyCondition">
					<xsl:with-param name="currentElement" select="$altCurrentElement"/>
					<xsl:with-param name="attributeNamesList" select="$attributeNamesList"/>
				</xsl:call-template>
			</xsl:if>
		</xsl:for-each>

	</xsl:template>

	<xsl:template name="getFormatAttributeValue">
		<xsl:param name="attributeName"/>
		<xsl:param name="currentElement"/>
		<xsl:param name="altCurrentElement"/>

		<xsl:choose>
			<xsl:when test="if">
				<xsl:variable name="condValue">
					<xsl:apply-templates select="(if)[position() = last()]" mode="flowCondition">
						<xsl:with-param name="currentElement" select="$currentElement"/>
						<xsl:with-param name="attributeName" select="$attributeName"/>
					</xsl:apply-templates>
				</xsl:variable>
				<xsl:variable name="altCondValue">
					<xsl:if test="$altCurrentElement">
						<xsl:apply-templates select="(if)[position() = last()]" mode="flowCondition">
							<xsl:with-param name="currentElement" select="$altCurrentElement"/>
							<xsl:with-param name="attributeName" select="$attributeName"/>
						</xsl:apply-templates>
					</xsl:if>
				</xsl:variable>
				<xsl:choose>
					<xsl:when test="string-length($altCondValue) &gt; 0">
						<xsl:value-of select="$altCondValue"/>
					</xsl:when>
					<xsl:when test="string-length($condValue) &gt; 0">
						<xsl:value-of select="$condValue"/>
					</xsl:when>
					<xsl:otherwise>
						<xsl:apply-templates select="*[name() != 'if']/@*[name() = $attributeName]" mode="getProperty"/>
					</xsl:otherwise>
				</xsl:choose>
			</xsl:when>
			<xsl:otherwise>
				<xsl:apply-templates select="*[name() != 'if']/@*[name() = $attributeName]" mode="getProperty"/>
			</xsl:otherwise>
		</xsl:choose>
	</xsl:template>

	<xsl:template match="if" mode="flowCondition">
		<xsl:param name="currentElement"/>
		<xsl:param name="attributeName"/>
		<xsl:variable name="value">
			<xsl:apply-templates select="current()" mode="getFormat">
				<xsl:with-param name="currentElement" select="$currentElement"/>
				<xsl:with-param name="attributeName" select="$attributeName"/>
			</xsl:apply-templates>
		</xsl:variable>

		<xsl:choose>
			<xsl:when test="string-length($value) &gt; 0">
				<xsl:value-of select="$value"/>
			</xsl:when>
			<xsl:otherwise>
				<xsl:apply-templates select="preceding-sibling::if[1]" mode="flowCondition">
					<xsl:with-param name="currentElement" select="$currentElement"/>
					<xsl:with-param name="attributeName" select="$attributeName"/>
				</xsl:apply-templates>
			</xsl:otherwise>
		</xsl:choose>
	</xsl:template>

	<xsl:template match="if" mode="getFormat">
		<xsl:param name="currentElement"/>
		<xsl:param name="attributeName"/>

		<xsl:for-each select="*[string-length(@value) &gt; 0]">
			<xsl:variable name="filterValue" select="string(@value)"/>
			<xsl:variable name="currentName" select="string(name())"/>

			<xsl:choose>
				<xsl:when test="$currentName = 'filter'">
					<xsl:if test="$currentElement[contains(@filter, $filterValue)] or ($doALLOW_AUTOMATIC_BLOCK_FILTER and $currentElement/ancestor-or-self::*[name() = 'Block' or name() = 'block.titlepage'][1][contains(@filter, $filterValue)])">
						<xsl:for-each select="Element">
							<xsl:call-template name="getFormatAttributeValue">
								<xsl:with-param name="attributeName" select="$attributeName"/>
								<xsl:with-param name="currentElement" select="$currentElement"/>
							</xsl:call-template>
						</xsl:for-each>
					</xsl:if>
				</xsl:when>
				<xsl:when test="$currentName = 'block-type'">
					<xsl:variable name="blockDefaultType">
						<xsl:call-template name="getTemplateVariableValue">
							<xsl:with-param name="name">DEFAULT_BLOCK_FORMAT</xsl:with-param>
							<xsl:with-param name="defaultValue">xyz</xsl:with-param>
						</xsl:call-template>
					</xsl:variable>
					<xsl:if test="$currentElement/ancestor-or-self::*[name() = 'Block' or name() = 'block.titlepage'][1][@Typ = $filterValue or @Function = $filterValue
							or (string-length(@Typ) = 0 and $filterValue = 'null') or ((string-length(@Typ) = 0 or @Typ = 'null') and $filterValue = $blockDefaultType)]
							or ($doALLOW_BLOCK_TYPE_TO_SECTION_FALLBACK and $currentElement/ancestor-or-self::InfoMap[1][@Typ = $filterValue or (string-length(@Typ) = 0 and $filterValue = 'null')])">
						<xsl:for-each select="Element">
							<xsl:call-template name="getFormatAttributeValue">
								<xsl:with-param name="attributeName" select="$attributeName"/>
								<xsl:with-param name="currentElement" select="$currentElement"/>
							</xsl:call-template>
						</xsl:for-each>
					</xsl:if>
				</xsl:when>
				<xsl:when test="$currentName = 'section-type'">
					<xsl:if test="$currentElement/ancestor-or-self::InfoMap[1][@Typ = $filterValue or (string-length(@Typ) = 0 and $filterValue = 'null')]">
						<xsl:for-each select="Element">
							<xsl:call-template name="getFormatAttributeValue">
								<xsl:with-param name="attributeName" select="$attributeName"/>
								<xsl:with-param name="currentElement" select="$currentElement"/>
							</xsl:call-template>
						</xsl:for-each>
					</xsl:if>
				</xsl:when>
				<xsl:when test="$currentName = 'warning-type'">
					<xsl:if test="$currentElement/ancestor-or-self::InfoItem.Warning[1]/@type = @value">
						<xsl:for-each select="Element">
							<xsl:call-template name="getFormatAttributeValue">
								<xsl:with-param name="attributeName" select="$attributeName"/>
								<xsl:with-param name="currentElement" select="$currentElement"/>
							</xsl:call-template>
						</xsl:for-each>
					</xsl:if>
				</xsl:when>
				<xsl:when test="$currentName = 'enum-type'">
					<xsl:if test="$currentElement/ancestor-or-self::Enum[1]/@type = @value">
						<xsl:for-each select="Element">
							<xsl:call-template name="getFormatAttributeValue">
								<xsl:with-param name="attributeName" select="$attributeName"/>
								<xsl:with-param name="currentElement" select="$currentElement"/>
							</xsl:call-template>
						</xsl:for-each>
					</xsl:if>
				</xsl:when>
				<xsl:when test="$currentName = 'table-type'">
					<xsl:if test="$currentElement/ancestor-or-self::*[name() = 'table' or name() = 'table.NoBorder'][1]/@typ = @value">
						<xsl:for-each select="Element">
							<xsl:call-template name="getFormatAttributeValue">
								<xsl:with-param name="attributeName" select="$attributeName"/>
								<xsl:with-param name="currentElement" select="$currentElement"/>
							</xsl:call-template>
						</xsl:for-each>
					</xsl:if>
				</xsl:when>
				<xsl:when test="$currentName = 'parent-filter'">
					<xsl:if test="$currentElement[contains(@inheritedFilter, $filterValue)] or $currentElement/ancestor::*[contains(@filter, $filterValue) or contains(@inheritedFilter, $filterValue)]">
						<xsl:for-each select="Element">
							<xsl:call-template name="getFormatAttributeValue">
								<xsl:with-param name="attributeName" select="$attributeName"/>
								<xsl:with-param name="currentElement" select="$currentElement"/>
							</xsl:call-template>
						</xsl:for-each>
					</xsl:if>
				</xsl:when>
				<xsl:when test="$currentName = 'metafilter'">
					<xsl:if test="$currentElement[contains(@metafilter, $filterValue)]">
						<xsl:for-each select="Element">
							<xsl:call-template name="getFormatAttributeValue">
								<xsl:with-param name="attributeName" select="$attributeName"/>
								<xsl:with-param name="currentElement" select="$currentElement"/>
							</xsl:call-template>
						</xsl:for-each>
					</xsl:if>
				</xsl:when>
				<xsl:when test="$currentName = 'parent-metafilter'">
					<xsl:if test="$currentElement/ancestor::*[contains(@metafilter, $filterValue)] or $currentElement/ancestor-or-self::InfoMap[1]/Properties/Property[@name = concat('SMCDOCINFO:', substring-before($filterValue, ':')) and @value = substring-after($filterValue, ':')]">
						<xsl:for-each select="Element">
							<xsl:call-template name="getFormatAttributeValue">
								<xsl:with-param name="attributeName" select="$attributeName"/>
								<xsl:with-param name="currentElement" select="$currentElement"/>
							</xsl:call-template>
						</xsl:for-each>
					</xsl:if>
				</xsl:when>
				<xsl:when test="$currentName = 'first-parent-filter'">
					<xsl:if test="$currentElement/parent::*[contains(@filter, $filterValue)]">
						<xsl:for-each select="Element">
							<xsl:call-template name="getFormatAttributeValue">
								<xsl:with-param name="attributeName" select="$attributeName"/>
								<xsl:with-param name="currentElement" select="$currentElement"/>
							</xsl:call-template>
						</xsl:for-each>
					</xsl:if>
				</xsl:when>
				<xsl:when test="$currentName = 'language'">
					<xsl:variable name="currLanguage">
						<xsl:call-template name="getCurrentLanguage">
							<xsl:with-param name="currentElement" select="$currentElement"/>
						</xsl:call-template>
					</xsl:variable>
					<xsl:if test="$currLanguage = @value">
						<xsl:for-each select="Element">
							<xsl:call-template name="getFormatAttributeValue">
								<xsl:with-param name="attributeName" select="$attributeName"/>
								<xsl:with-param name="currentElement" select="$currentElement"/>
							</xsl:call-template>
						</xsl:for-each>
					</xsl:if>
				</xsl:when>
				<xsl:when test="$currentName = 'ancestor-element'">
					<xsl:variable name="result">
						<xsl:apply-templates select="current()" mode="checkCondition">
							<xsl:with-param name="currentElement" select="$currentElement"/>
						</xsl:apply-templates>
					</xsl:variable>
					<xsl:if test="$result = 'true'">
						<xsl:for-each select="Element">
							<xsl:call-template name="getFormatAttributeValue">
								<xsl:with-param name="attributeName" select="$attributeName"/>
								<xsl:with-param name="currentElement" select="$currentElement"/>
							</xsl:call-template>
						</xsl:for-each>
					</xsl:if>
				</xsl:when>
				<xsl:when test="$currentName = 'changed-state'">
					<xsl:if test="$currentElement/ancestor-or-self::*[@Changed][1][@Changed = $filterValue]">
						<xsl:for-each select="Element">
							<xsl:call-template name="getFormatAttributeValue">
								<xsl:with-param name="attributeName" select="$attributeName"/>
								<xsl:with-param name="currentElement" select="$currentElement"/>
							</xsl:call-template>
						</xsl:for-each>
					</xsl:if>
				</xsl:when>
			</xsl:choose>

		</xsl:for-each>
	</xsl:template>

	<xsl:template name="getFormat">
		<xsl:param name="name"/>
		<xsl:param name="attributeName"/>
		<xsl:param name="defaultValue"/>
		<xsl:param name="currentElement" select="current()"/>
		<xsl:param name="altCurrentElement"/>

		<xsl:variable name="value">
			<xsl:choose>
				<xsl:when test="$isMULTI_STYLE_FORMATTING and ancestor-or-self::*[name() = 'Format' or (name() = 'InfoMap' and Format)][1]">
					<xsl:choose>
						<xsl:when test="ancestor-or-self::*[name() = 'Format' or (name() = 'InfoMap' and Format)][1]/self::InfoMap">
							<xsl:for-each select="ancestor-or-self::InfoMap[Format][1]/Format/ParamConfig/ElementGroup/Element[@name = $name][1]">
								<xsl:call-template name="getFormatAttributeValue">
									<xsl:with-param name="attributeName" select="$attributeName"/>
									<xsl:with-param name="currentElement" select="$currentElement"/>
									<xsl:with-param name="altCurrentElement" select="$altCurrentElement"/>
								</xsl:call-template>
							</xsl:for-each>
						</xsl:when>
						<xsl:otherwise>
							<xsl:for-each select="ancestor-or-self::Format[1]/ParamConfig/ElementGroup/Element[@name = $name][1]">
								<xsl:call-template name="getFormatAttributeValue">
									<xsl:with-param name="attributeName" select="$attributeName"/>
									<xsl:with-param name="currentElement" select="$currentElement"/>
									<xsl:with-param name="altCurrentElement" select="$altCurrentElement"/>
								</xsl:call-template>
							</xsl:for-each>
						</xsl:otherwise>
					</xsl:choose>
				</xsl:when>
				<xsl:otherwise>
					<xsl:for-each select="key('FormatElementIndex', $name)[1]">
						<xsl:call-template name="getFormatAttributeValue">
							<xsl:with-param name="attributeName" select="$attributeName"/>
							<xsl:with-param name="currentElement" select="$currentElement"/>
							<xsl:with-param name="altCurrentElement" select="$altCurrentElement"/>
						</xsl:call-template>
					</xsl:for-each>
				</xsl:otherwise>
			</xsl:choose>
		</xsl:variable>

		<xsl:choose>
			<xsl:when test="string-length($value) &gt; 0">
				<xsl:value-of select="$value"/>
			</xsl:when>
			<xsl:otherwise>
				<xsl:value-of select="$defaultValue"/>
			</xsl:otherwise>
		</xsl:choose>

	</xsl:template>

	<xsl:template name="getTemplateVariableValue">
		<xsl:param name="name"/>
		<xsl:param name="defaultValue"/>
		<xsl:choose>
			<xsl:when test="$isMULTI_STYLE_FORMATTING and ancestor-or-self::*[name() = 'Format' or (name() = 'InfoMap' and Format)][1]">
				<xsl:variable name="value">
					<xsl:choose>
						<xsl:when test="ancestor-or-self::*[name() = 'Format' or (name() = 'InfoMap' and Format)][1]/self::InfoMap">
							<xsl:apply-templates select="ancestor-or-self::InfoMap[Format][1]/Format/ParamConfig/VariableDefinitions/VariableDefinition[@name = $name][1]" mode="writeTemplateVariableValue"/>
						</xsl:when>
						<xsl:otherwise>
							<xsl:apply-templates select="ancestor-or-self::Format[1]/ParamConfig/VariableDefinitions/VariableDefinition[@name = $name][1]" mode="writeTemplateVariableValue"/>
						</xsl:otherwise>
					</xsl:choose>
				</xsl:variable>
				<xsl:choose>
					<xsl:when test="string-length($value) &gt; 0">
						<xsl:value-of select="$value"/>
					</xsl:when>
					<xsl:otherwise>
						<xsl:value-of select="$defaultValue"/>
					</xsl:otherwise>
				</xsl:choose>
			</xsl:when>
			<xsl:otherwise>
				<xsl:variable name="value">
					<xsl:apply-templates select="key('FormatVariableIndex', $name)[1]" mode="writeTemplateVariableValue"/>
				</xsl:variable>
				<xsl:choose>
					<xsl:when test="string-length($value) &gt; 0">
						<xsl:value-of select="$value"/>
					</xsl:when>
					<xsl:otherwise>
						<xsl:value-of select="$defaultValue"/>
					</xsl:otherwise>
				</xsl:choose>
			</xsl:otherwise>
		</xsl:choose>
	</xsl:template>

	<xsl:template match="VariableDefinition" mode="writeTemplateVariableValue">
		<xsl:choose>
			<xsl:when test="@datatype = 'integer'">
				<xsl:value-of select="@integerValue"/>
			</xsl:when>
			<xsl:when test="@datatype = 'positiveInteger'">
				<xsl:value-of select="@positiveIntegerValue"/>
			</xsl:when>
			<xsl:when test="@datatype = 'float'">
				<xsl:if test="string-length(@floatValue) &gt; 0">
					<xsl:value-of select="concat(@floatValue, @floatUnit)"/>
				</xsl:if>
			</xsl:when>
			<xsl:when test="@datatype = 'color'">
				<xsl:call-template name="writeColorAttributeValue">
					<xsl:with-param name="attrName">colorValue</xsl:with-param>
				</xsl:call-template>
			</xsl:when>
			<xsl:when test="@datatype = 'textarea'">
				<xsl:apply-templates select="text()"/>
			</xsl:when>
			<xsl:when test="string-length(@textValue) &gt; 0">
				<xsl:value-of select="@textValue"/>
			</xsl:when>
			<xsl:otherwise>
				<xsl:value-of select="@default"/>
			</xsl:otherwise>
		</xsl:choose>
	</xsl:template>

	<xsl:template name="writeColorAttribute">
		<xsl:param name="attrName"/>
		<xsl:param name="colorName"/>
		<xsl:variable name="colorValue">
			<xsl:call-template name="writeColorAttributeValue">
				<xsl:with-param name="colorName" select="$colorName"/>
			</xsl:call-template>
		</xsl:variable>
		<xsl:if test="string-length($colorValue) &gt; 0">
			<xsl:attribute name="{$attrName}">
				<xsl:value-of select="$colorValue"/>
			</xsl:attribute>
		</xsl:if>
	</xsl:template>

	<xsl:template name="writeColorAttributeValue">
		<xsl:param name="attrName"/>
		<xsl:param name="colorName" select="@*[name() = $attrName]"/>

		<xsl:choose>
			<xsl:when test="$isMULTI_STYLE_FORMATTING and ancestor-or-self::*[name() = 'Format' or (name() = 'InfoMap' and Format)][1]">
				<xsl:choose>
					<xsl:when test="ancestor-or-self::*[name() = 'Format' or (name() = 'InfoMap' and Format)][1]/self::InfoMap">
						<xsl:for-each select="ancestor-or-self::InfoMap[Format][1]/Format/ParamConfig/ColorDefinition/Colors/Color[@name = $colorName][1]">
							<xsl:call-template name="writeColorValueFromColorElement"/>
						</xsl:for-each>
					</xsl:when>
					<xsl:otherwise>
						<xsl:for-each select="ancestor-or-self::Format[1]/ParamConfig/ColorDefinition/Colors/Color[@name = $colorName][1]">
							<xsl:call-template name="writeColorValueFromColorElement"/>
						</xsl:for-each>
					</xsl:otherwise>
				</xsl:choose>
			</xsl:when>
			<xsl:otherwise>
				<xsl:for-each select="key('ColorIndex', $colorName)[1]">
					<xsl:call-template name="writeColorValueFromColorElement"/>
				</xsl:for-each>
			</xsl:otherwise>
		</xsl:choose>

	</xsl:template>

	<xsl:template name="getCMYKColor">
		<xsl:param name="color"/>
		<xsl:choose>
			<xsl:when test="string(number($color)) != 'NaN'">
				<xsl:value-of select="$color div 100"/>
			</xsl:when>
			<xsl:otherwise>0</xsl:otherwise>
		</xsl:choose>
	</xsl:template>

	<xsl:template name="writeColorValueFromColorElement">
		<xsl:choose>
			<xsl:when test="@fulltone">
				<xsl:value-of select="concat('rgb-icc(', @red, ',', @green, ',', @blue, ',#Separation,')"/>
				<xsl:choose>
					<xsl:when test="contains(@fulltone, ' ')">
						<xsl:text>'</xsl:text>
						<xsl:value-of select="@fulltone"/>
						<xsl:text>'</xsl:text>
					</xsl:when>
					<xsl:otherwise>
						<xsl:value-of select="@fulltone"/>
					</xsl:otherwise>
				</xsl:choose>
				<xsl:text>)</xsl:text>
			</xsl:when>
			<xsl:when test="@colorprofile and not($USE_COLOR_PROFILE = 'false')">
				<xsl:variable name="c">
					<xsl:call-template name="getCMYKColor">
						<xsl:with-param name="color" select="@c"/>
					</xsl:call-template>
				</xsl:variable>
				<xsl:variable name="m">
					<xsl:call-template name="getCMYKColor">
						<xsl:with-param name="color" select="@m"/>
					</xsl:call-template>
				</xsl:variable>
				<xsl:variable name="y">
					<xsl:call-template name="getCMYKColor">
						<xsl:with-param name="color" select="@y"/>
					</xsl:call-template>
				</xsl:variable>
				<xsl:variable name="k">
					<xsl:call-template name="getCMYKColor">
						<xsl:with-param name="color" select="@k"/>
					</xsl:call-template>
				</xsl:variable>
				<xsl:value-of select="concat('rgb-icc(', @red, ',', @green, ',', @blue, ',', @colorprofile, ',', $c, ',', $m, ',', $y, ',', $k, ')')"/>
			</xsl:when>
			<xsl:when test="@c and @m and @y and @k">
				<xsl:variable name="c">
					<xsl:call-template name="getCMYKColor">
						<xsl:with-param name="color" select="@c"/>
					</xsl:call-template>
				</xsl:variable>
				<xsl:variable name="m">
					<xsl:call-template name="getCMYKColor">
						<xsl:with-param name="color" select="@m"/>
					</xsl:call-template>
				</xsl:variable>
				<xsl:variable name="y">
					<xsl:call-template name="getCMYKColor">
						<xsl:with-param name="color" select="@y"/>
					</xsl:call-template>
				</xsl:variable>
				<xsl:variable name="k">
					<xsl:call-template name="getCMYKColor">
						<xsl:with-param name="color" select="@k"/>
					</xsl:call-template>
				</xsl:variable>
				<xsl:value-of select="concat('cmyk(', $c, ',', $m, ',', $y, ',', $k, ')')"/>
			</xsl:when>
			<xsl:when test="@coding = 'Hex'">
				<xsl:choose>
					<xsl:when test="@rgbhex = 'transparent'">transparent</xsl:when>
					<xsl:when test="starts-with(@rgbhex, '#')">
						<xsl:value-of select="@rgbhex"/>
					</xsl:when>
					<xsl:otherwise>
						<xsl:value-of select="concat('#', @rgbhex)"/>
					</xsl:otherwise>
				</xsl:choose>
			</xsl:when>
			<xsl:when test="@coding = 'Decimal'">
				<xsl:value-of select="concat('rgb(', @red, ',', @green, ',', @blue, ')')"/>
			</xsl:when>
		</xsl:choose>
	</xsl:template>

	<xsl:template match="@*" mode="writeProperties">
		<xsl:copy-of select="current()"/>
	</xsl:template>

	<xsl:template match="@orphans | @widows" mode="writeProperties">
		<xsl:if test="not(ancestor::Element[@name = 'table' or @name = 'enum.standard' or @name = 'instruction'])">
			<xsl:copy-of select="current()"/>
		</xsl:if>
	</xsl:template>

	<xsl:template match="@font-weight" mode="writeProperties">
		<xsl:choose>
			<xsl:when test=". = 'bolder'">
				<!-- due to FOP bug bolder is wrongly mapped to 500 -->
				<xsl:attribute name="font-weight">900</xsl:attribute>
			</xsl:when>
			<xsl:otherwise>
				<xsl:copy-of select="current()"/>
			</xsl:otherwise>
		</xsl:choose>
	</xsl:template>

	<xsl:template match="@page-break-before" mode="writeProperties">
		<xsl:choose>
			<xsl:when test=". = 'column'">
				<xsl:attribute name="break-before">column</xsl:attribute>
			</xsl:when>
			<xsl:when test=". = 'auto' or . = 'avoid'">
				<xsl:attribute name="break-before">auto</xsl:attribute>
			</xsl:when>
			<xsl:when test=". = 'always'">
				<xsl:attribute name="break-before">page</xsl:attribute>
			</xsl:when>
			<xsl:when test=". = 'left'">
				<xsl:attribute name="break-before">even-page</xsl:attribute>
			</xsl:when>
			<xsl:when test=". = 'right'">
				<xsl:attribute name="break-before">odd-page</xsl:attribute>
			</xsl:when>
		</xsl:choose>
	</xsl:template>

	<xsl:template match="@font-family" mode="writeProperties">
		<xsl:attribute name="font-family">
			<xsl:value-of select="."/>
			<xsl:if test="../@font-family2">
				<xsl:value-of select="concat(',', ../@font-family2)"/>
			</xsl:if>
		</xsl:attribute>
	</xsl:template>

	<xsl:template match="@font-family2" mode="writeProperties">
		<xsl:if test="not(../@font-family)">
			<xsl:attribute name="font-family">
				<xsl:value-of select="."/>
			</xsl:attribute>
		</xsl:if>
	</xsl:template>

	<xsl:template match="@text-transform" mode="writeProperties">
		<xsl:if test="not(. = 'subscript' or . = 'superscript')">
			<xsl:copy-of select="current()"/>
		</xsl:if>
	</xsl:template>

	<xsl:template match="@initial-page-number | @force-page-count | @auto-number | @number-prefix | @number-text-separator | @deltaMarginBottomSign | @hasDeltaModification | @deltaMarginTopSign" mode="writeProperties"/>

	<xsl:template match="@background-position" mode="writeProperties">
		<xsl:choose>
			<xsl:when test="contains(., ' ')">
				<xsl:attribute name="background-position-horizontal">
					<xsl:value-of select="substring-before(., ' ')"/>
				</xsl:attribute>
				<xsl:attribute name="background-position-vertical">
					<xsl:value-of select="substring-after(., ' ')"/>
				</xsl:attribute>
			</xsl:when>
			<xsl:otherwise>
				<xsl:attribute name="background-position-horizontal">
					<xsl:value-of select="."/>
				</xsl:attribute>
				<xsl:attribute name="background-position-vertical">
					<xsl:value-of select="."/>
				</xsl:attribute>
			</xsl:otherwise>
		</xsl:choose>
	</xsl:template>

	<xsl:template match="@font-size | @line-height | @letter-spacing | @word-spacing | @text-indent | @start-indent | @end-indent | @space-before | @space-after | @height | @width" mode="writeProperties">
		<xsl:variable name="name" select="name()"/>
		<xsl:attribute name="{name()}">
			<xsl:value-of select="translate(., ',', '.')"/>
			<xsl:value-of select="../@*[name() = concat($name, '-unit')]"/>
		</xsl:attribute>
	</xsl:template>

	<xsl:template match="@left | @top | @bottom | @right" mode="writeProperties">
		<xsl:attribute name="{name()}">
			<xsl:value-of select="."/>
			<xsl:value-of select="../@position-unit"/>
		</xsl:attribute>
	</xsl:template>

	<xsl:template match="@color | @background-color | @border-color | @border-left-color | @border-right-color" mode="writeProperties">
		<xsl:call-template name="writeColorAttribute">
			<xsl:with-param name="attrName" select="name()"/>
			<xsl:with-param name="colorName" select="."/>
		</xsl:call-template>
	</xsl:template>

	<xsl:template match="@border-top-color" mode="writeProperties">
		<xsl:call-template name="writeColorAttribute">
			<xsl:with-param name="attrName">border-before-color</xsl:with-param>
			<xsl:with-param name="colorName" select="."/>
		</xsl:call-template>
	</xsl:template>

	<xsl:template match="@border-top-style" mode="writeProperties">
		<xsl:attribute name="border-before-style">
			<xsl:value-of select="."/>
		</xsl:attribute>
	</xsl:template>

	<xsl:template match="@border-bottom-color" mode="writeProperties">
		<xsl:call-template name="writeColorAttribute">
			<xsl:with-param name="attrName">border-after-color</xsl:with-param>
			<xsl:with-param name="colorName" select="."/>
		</xsl:call-template>
	</xsl:template>

	<xsl:template match="@border-bottom-style" mode="writeProperties">
		<xsl:attribute name="border-after-style">
			<xsl:value-of select="."/>
		</xsl:attribute>
	</xsl:template>

	<xsl:template match="@background-image" mode="writeProperties">
		<xsl:variable name="picUrl">
			<xsl:call-template name="getTemplateGraphicURL">
				<xsl:with-param name="name" select="."/>
			</xsl:call-template>
		</xsl:variable>
		<xsl:choose>
			<xsl:when test="string-length($picUrl) &gt; 0">
				<xsl:attribute name="background-image">
					<xsl:value-of select="$picUrl"/>
				</xsl:attribute>
			</xsl:when>
			<xsl:otherwise>
				<xsl:attribute name="background-image">none</xsl:attribute>
			</xsl:otherwise>
		</xsl:choose>
	</xsl:template>

	<xsl:template match="@border-width | @border-right-width | @border-left-width | 
				  @padding-left | @padding-right" mode="writeProperties">
		<xsl:attribute name="{name()}">
			<xsl:value-of select="."/>
			<xsl:value-of select="../@unit"/>
		</xsl:attribute>
	</xsl:template>

	<xsl:template match="@margin-left | @margin-top | @margin-bottom | @margin-right" mode="writeProperties">
		<xsl:attribute name="{name()}">
			<xsl:value-of select="."/>
			<xsl:if test=". != 'auto'">
				<xsl:value-of select="../@unit"/>
			</xsl:if>
		</xsl:attribute>
	</xsl:template>

	<xsl:template match="@padding-bottom" mode="writeProperties">
		<xsl:attribute name="padding-after">
			<xsl:value-of select="."/>
			<xsl:value-of select="../@unit"/>
		</xsl:attribute>
	</xsl:template>

	<xsl:template match="@padding-top" mode="writeProperties">
		<xsl:attribute name="padding-before">
			<xsl:value-of select="."/>
			<xsl:value-of select="../@unit"/>
		</xsl:attribute>
	</xsl:template>

	<xsl:template match="@border-top-width" mode="writeProperties">
		<xsl:attribute name="border-before-width">
			<xsl:value-of select="."/>
			<xsl:value-of select="../@unit"/>
		</xsl:attribute>
	</xsl:template>

	<xsl:template match="@border-top-width.conditionality" mode="writeProperties">
		<xsl:attribute name="border-before-width.conditionality">
			<xsl:value-of select="."/>
		</xsl:attribute>
	</xsl:template>

	<xsl:template match="@border-bottom-width" mode="writeProperties">
		<xsl:attribute name="border-after-width">
			<xsl:value-of select="."/>
			<xsl:value-of select="../@unit"/>
		</xsl:attribute>
	</xsl:template>

	<xsl:template match="@border-bottom-width.conditionality" mode="writeProperties">
		<xsl:attribute name="border-after-width.conditionality">
			<xsl:value-of select="."/>
		</xsl:attribute>
	</xsl:template>

	<xsl:template match="@column-gap" mode="writeProperties">
		<xsl:attribute name="{name()}">
			<xsl:value-of select="concat(., 'pt')"/>
		</xsl:attribute>
	</xsl:template>

	<xsl:template match="@vertical-align" mode="writeProperties">
		<xsl:choose>
			<xsl:when test=". = 'top'">
				<xsl:choose>
					<xsl:when test="ancestor::Element[1]/@isBlockType = 'true'">
						<xsl:attribute name="display-align">before</xsl:attribute>
					</xsl:when>
					<xsl:otherwise>
						<xsl:copy-of select="current()"/>
					</xsl:otherwise>
				</xsl:choose>
			</xsl:when>
			<xsl:when test=". = 'middle'">
				<xsl:attribute name="display-align">center</xsl:attribute>
			</xsl:when>
			<xsl:when test=". = 'bottom'">
				<xsl:attribute name="display-align">after</xsl:attribute>
			</xsl:when>
			<xsl:when test=". = 'sub'">
				<xsl:attribute name="vertical-align">sub</xsl:attribute>
			</xsl:when>
			<xsl:when test=". = 'justify'">
				<xsl:attribute name="display-align">justify</xsl:attribute>
			</xsl:when>
		</xsl:choose>
	</xsl:template>

	<xsl:template name="writeProperties">
		<xsl:param name="attributeNamesList"/>

		<xsl:choose>
			<xsl:when test="$attributeNamesList != ''">
				<xsl:apply-templates select="@*[contains($attributeNamesList, concat('|', name(), '|')) and not(contains(name(), '-unit')) and name() != 'unit']" mode="writeProperties"/>
			</xsl:when>
			<xsl:otherwise>
				<xsl:apply-templates select="@*[not(contains(name(), '-unit')) and name() != 'unit']" mode="writeProperties"/>
			</xsl:otherwise>
		</xsl:choose>

	</xsl:template>

	<xsl:template match="@*" mode="getProperty">
		<xsl:value-of select="."/>
	</xsl:template>

	<xsl:template match="@hasDeltaModification"/>

	<xsl:template match="@font-size | @line-height | @letter-spacing | @word-spacing | @text-indent | @start-indent | @end-indent | @space-before | @space-after | @height | @width" mode="getProperty">
		<xsl:variable name="name" select="name()"/>
		<xsl:value-of select="concat(translate(., ',', '.'), ../@*[name() = concat($name, '-unit')])"/>
	</xsl:template>

	<xsl:template match="@left | @top | @bottom | @right" mode="getProperty">
		<xsl:value-of select="concat(., ../@position-unit)"/>
	</xsl:template>

	<xsl:template match="@color | @background-color | @border-color | @border-top-color | @border-left-color | @border-right-color | @border-bottom-color" mode="getProperty">
		<xsl:call-template name="writeColorAttributeValue">
			<xsl:with-param name="colorName" select="."/>
		</xsl:call-template>
	</xsl:template>

	<xsl:template match="@border-width | @border-top-width | @border-bottom-width | @border-right-width | @border-left-width | 
				  @margin-left | @margin-top | @margin-bottom | @margin-right | 
				  @padding-left | @padding-top | @padding-bottom | @padding-right" mode="getProperty">
		<xsl:value-of select="concat(., ../@unit)"/>
	</xsl:template>

	<xsl:template match="@column-gap" mode="getProperty">
		<xsl:value-of select="concat(., 'pt')"/>
	</xsl:template>

	<xsl:template match="@vertical-align" mode="getProperty">
		<xsl:choose>
			<xsl:when test=". = 'bottom'">after</xsl:when>
			<xsl:when test=". = 'middle'">center</xsl:when>
			<xsl:when test=". = 'top'">before</xsl:when>
		</xsl:choose>
	</xsl:template>

	<xsl:template match="fixtext">
		<!--<xsl:call-template name="translate">
			<xsl:with-param name="ID" select="."/>
		</xsl:call-template>-->
		<xsl:if test="string-length(.) &gt; 0">
			<xsl:choose>
				<xsl:when test="starts-with(., '$')">
					<xsl:variable name="var">
						<xsl:call-template name="getTemplateVariableValue">
							<xsl:with-param name="name" select="substring-after(., '$')"/>
						</xsl:call-template>
					</xsl:variable>
					<xsl:if test="string-length($var) &gt; 0">
						<fo:retrieve-marker retrieve-class-name="{$var}"/>
					</xsl:if>
				</xsl:when>
				<xsl:otherwise>
					<fo:retrieve-marker retrieve-class-name="{.}"/>
				</xsl:otherwise>
			</xsl:choose>
		</xsl:if>
	</xsl:template>

	<xsl:template match="variable">
		<xsl:choose>
			<xsl:when test="@name = 'headline.theme'">
				<fo:retrieve-marker retrieve-class-name="headline.theme"/>
			</xsl:when>
			<xsl:when test="@name = 'title'">
				<fo:retrieve-marker retrieve-class-name="headline"/>
			</xsl:when>
			<xsl:when test="@name = 'titleLastOccur'">
				<fo:retrieve-marker retrieve-class-name="headline" retrieve-position="last-starting-within-page"/>
			</xsl:when>
			<xsl:when test="@name = 'title2FirstOccur'">
				<fo:retrieve-marker retrieve-class-name="headline2"/>
			</xsl:when>
			<xsl:when test="@name = 'title2'">
				<fo:retrieve-marker retrieve-class-name="headline2" retrieve-position="last-starting-within-page"/>
			</xsl:when>
			<xsl:when test="@name = 'title3FirstOccur'">
				<fo:retrieve-marker retrieve-class-name="headline3"/>
			</xsl:when>
			<xsl:when test="@name = 'title3LastOccur'">
				<fo:retrieve-marker retrieve-class-name="headline3" retrieve-position="last-starting-within-page"/>
			</xsl:when>
			<xsl:when test="@name = 'title2WithPrefix'">
				<fo:retrieve-marker retrieve-class-name="headline2WithPrefix" retrieve-position="last-starting-within-page"/>
			</xsl:when>
			<xsl:when test="@name = 'title3WithPrefix'">
				<fo:retrieve-marker retrieve-class-name="headline3WithPrefix" retrieve-position="last-starting-within-page"/>
			</xsl:when>
			<xsl:when test="@name = 'totalPages'">
				<fo:page-number-citation-last ref-id="lastpagesequence"/>
			</xsl:when>
			<xsl:when test="starts-with(@name, 'fixtext.')">
				<xsl:call-template name="translate">
					<xsl:with-param name="ID" select="substring-after(@name, 'fixtext.')"/>
				</xsl:call-template>
			</xsl:when>
			<xsl:when test="@name = 'page'">
				<fo:retrieve-marker retrieve-class-name="fixtext-page"/>
				<xsl:text> </xsl:text>
			</xsl:when>
			<xsl:when test="@name = 'of'">
				<xsl:text> </xsl:text>
				<fo:retrieve-marker retrieve-class-name="fixtext-of"/>
				<xsl:text> </xsl:text>
			</xsl:when>
			<xsl:when test="@name = 'pageName'">
				<fo:page-number/>
			</xsl:when>
			<xsl:when test="@name = 'chapterPageNr'">
				<fo:retrieve-marker retrieve-class-name="chapter-page-nr"/>
				<fo:page-number/>
			</xsl:when>
			<xsl:when test="@name = 'chapterNr'">
				<fo:retrieve-marker retrieve-class-name="chapter-nr"/>
			</xsl:when>
			<xsl:when test="@name = 'chapterNrFirstOccur'">
				<fo:retrieve-marker retrieve-class-name="chapter-nr" retrieve-position="last-starting-within-page"/>
			</xsl:when>
			<xsl:when test="@name = 'chapterNr2'">
				<fo:retrieve-marker retrieve-class-name="chapter-nr2" retrieve-position="last-starting-within-page"/>
			</xsl:when>
			<xsl:when test="@name = 'chapterNr2FirstOccur'">
				<fo:retrieve-marker retrieve-class-name="chapter-nr2"/>
			</xsl:when>
			<xsl:when test="@name = 'chapterNr1And2FirstOccur'">
				<fo:retrieve-marker retrieve-class-name="chapter-nr1and2"/>
			</xsl:when>
			<xsl:when test="@name = 'chapterNr1And2'">
				<fo:retrieve-marker retrieve-class-name="chapter-nr1and2" retrieve-position="last-starting-within-page"/>
			</xsl:when>
			<xsl:when test="@name = 'chapterNrTitle1'">
				<fo:retrieve-marker retrieve-class-name="chapter-nr-headline"/>
			</xsl:when>
			<xsl:when test="@name = 'Title1chapterNr'">
				<fo:retrieve-marker retrieve-class-name="headline-chapter-nr"/>
			</xsl:when>
			<xsl:when test="@name = 'footnotes'">
				<fo:retrieve-marker retrieve-class-name="titlepage-footnote"/>
			</xsl:when>
			<xsl:when test="@name = 'titlepage.version'">
				<fo:retrieve-marker retrieve-class-name="titlepage-version"/>
			</xsl:when>
			<xsl:when test="@name = 'titlepage.title'">
				<fo:retrieve-marker retrieve-class-name="titlepage-title"/>
			</xsl:when>
			<xsl:when test="@name = 'titlepage.optional.title'">
				<fo:retrieve-marker retrieve-class-name="titlepage-optional-title"/>
			</xsl:when>
			<xsl:when test="@name = 'titlepage.title.theme'">
				<fo:retrieve-marker retrieve-class-name="titlepage-title-theme"/>
			</xsl:when>
			<xsl:when test="@name = 'titlepage.date'">
				<fo:retrieve-marker retrieve-class-name="titlepage-date"/>
			</xsl:when>
			<xsl:when test="@name = 'titlepage.imagedetail'">
				<fo:retrieve-marker retrieve-class-name="titlepage-imagedetail"/>
			</xsl:when>
			<xsl:when test="starts-with(@name, 'titlepage.imagedetail.custom.')">
				<xsl:variable name="className" select="translate(@name, '.','-')"/>
				<fo:retrieve-marker retrieve-class-name="{$className}"/>
			</xsl:when>
			<xsl:when test="@name = 'titlepage.content'">
				<fo:retrieve-marker retrieve-class-name="titlepage-content"/>
			</xsl:when>
			<xsl:when test="@name = 'titlepage.headline.content'">
				<fo:inline>
					<xsl:call-template name="addStyle">
						<xsl:with-param name="name">marker.titlepage.headline.content</xsl:with-param>
					</xsl:call-template>
					<xsl:choose>
						<xsl:when test="/InfoMap/Headline.content">
							<xsl:apply-templates select="/InfoMap/Headline.content" mode="applyChildren">
								<xsl:with-param name="isInsideMarker" select="true()"/>
							</xsl:apply-templates>
						</xsl:when>
						<xsl:otherwise>
							<xsl:apply-templates select="/InfoMap/InfoMap[1]/Headline.content" mode="applyChildren">
								<xsl:with-param name="isInsideMarker" select="true()"/>
							</xsl:apply-templates>
						</xsl:otherwise>
					</xsl:choose>
				</fo:inline>
			</xsl:when>
			<xsl:when test="@name = 'titlepage.headline.theme'">
				<fo:inline>
					<xsl:call-template name="addStyle">
						<xsl:with-param name="name">marker.titlepage.headline.theme</xsl:with-param>
					</xsl:call-template>
					<xsl:choose>
						<xsl:when test="/InfoMap/Headline.content">
							<xsl:apply-templates select="/InfoMap/Headline.theme" mode="applyChildren"/>
						</xsl:when>
						<xsl:otherwise>
							<xsl:apply-templates select="/InfoMap/InfoMap[1]/Headline.theme" mode="applyChildren"/>
						</xsl:otherwise>
					</xsl:choose>
				</fo:inline>
			</xsl:when>
			<xsl:when test="@name = 'languagecode'">
				<fo:retrieve-marker retrieve-class-name="languagecode"/>
			</xsl:when>
			<xsl:when test="@name = 'year'">
				<!--<xsl:variable name="calendarInstance" select="calendar:getInstance()"/>
				<xsl:value-of select="calendar:get($calendarInstance, 1)"/>-->
			</xsl:when>
			<xsl:when test="@name = 'book.version'">
				<xsl:choose>
					<xsl:when test="string-length($versionLabel) = 0">Draft</xsl:when>
					<xsl:otherwise>
						<xsl:value-of select="$versionLabel"/>
					</xsl:otherwise>
				</xsl:choose>
			</xsl:when>
			<xsl:when test="@name = 'document.version'">
				<fo:retrieve-marker retrieve-class-name="document-version"/>
			</xsl:when>
			<xsl:when test="@name = 'book.name'">
				<xsl:value-of select="/*/StructureProperties/StructureProperty[@name = 'SMC:name']/@value"/>
			</xsl:when>
			<xsl:when test="@name = 'book.modificationdate'">
				<xsl:value-of select="substring-before(/*/StructureProperties/StructureProperty[@name = 'SMC:lastModificationDate']/@value, ' ')"/>
			</xsl:when>
			<xsl:when test="@name = 'draft.marker'">
				<xsl:choose>
					<xsl:when test="string-length($versionLabel) = 0">
						<xsl:call-template name="translate">
							<xsl:with-param name="ID">Draft</xsl:with-param>
						</xsl:call-template>
					</xsl:when>
					<xsl:otherwise>
						<xsl:text> </xsl:text>
					</xsl:otherwise>
				</xsl:choose>
			</xsl:when>
			<xsl:when test="@name = 'date'">
				<!--<xsl:variable name="calendarInstance" select="calendar:getInstance()"/>
				<xsl:variable name="dateInstance" select="calendar:getTime($calendarInstance)"/>

				<xsl:call-template name="formatDate">
					<xsl:with-param name="date" select="$dateInstance"/>
					<xsl:with-param name="hasDate" select="true()"/>
					<xsl:with-param name="defaultPattern">dd.MM.yyyy</xsl:with-param>
				</xsl:call-template>-->
			</xsl:when>
			<xsl:when test="@name= 'chapterwise.filename'">
				<fo:retrieve-marker retrieve-class-name="chapterwise-filename"/>
			</xsl:when>
			<xsl:when test="@name= 'parentTitle'">
				<fo:retrieve-marker retrieve-class-name="parent-title"/>
			</xsl:when>
		</xsl:choose>
	</xsl:template>

	<xsl:template match="formatRef">
		<xsl:call-template name="addFormat">
			<xsl:with-param name="name" select="@formatRef"/>
		</xsl:call-template>
	</xsl:template>

	<xsl:template match="propmatch">
		<xsl:choose>
			<xsl:when test="string-length(@id) &gt; 0 and ancestor::StandardPageRegion">
				<fo:retrieve-marker retrieve-class-name="{@id}"/>
			</xsl:when>
			<xsl:when test="/InfoMap/ContextProperties/ContextProperty[@name = concat('SMCDOCINFO:',current()/@id)]">
				<xsl:value-of select="/InfoMap/ContextProperties/ContextProperty[@name = concat('SMCDOCINFO:',current()/@id)]/@value"/>
			</xsl:when>
			<xsl:when test="ancestor::InfoMap[1]/Properties/Property[@name = concat('SMCDOCINFO:',current()/@id)]">
				<xsl:value-of select="ancestor::InfoMap[1]/Properties/Property[@name = concat('SMCDOCINFO:',current()/@id)]/@value"/>
			</xsl:when>
		</xsl:choose>
	</xsl:template>

	<xsl:template match="*" mode="applyWidowOrphans">
		<xsl:param name="name"/>
		<xsl:param name="orphansDefault"/>
		<xsl:param name="widowsDefault"/>

		<xsl:variable name="orphans">
			<xsl:call-template name="getFormat">
				<xsl:with-param name="name" select="$name"/>
				<xsl:with-param name="attributeName">orphans</xsl:with-param>
				<xsl:with-param name="defaultValue" select="$orphansDefault"/>
			</xsl:call-template>
		</xsl:variable>
		<xsl:if test="string(number($orphans)) != 'NaN'">
			<xsl:attribute name="fox:orphan-content-limit">
				<xsl:value-of select="concat($orphans, 'em')"/>
			</xsl:attribute>
		</xsl:if>
		<xsl:variable name="widows">
			<xsl:call-template name="getFormat">
				<xsl:with-param name="name" select="$name"/>
				<xsl:with-param name="attributeName">widows</xsl:with-param>
				<xsl:with-param name="defaultValue" select="$widowsDefault"/>
			</xsl:call-template>
		</xsl:variable>
		<xsl:if test="string(number($widows)) != 'NaN'">
			<xsl:attribute name="fox:widow-content-limit">
				<xsl:value-of select="concat($widows, 'em')"/>
			</xsl:attribute>
		</xsl:if>
	</xsl:template>

	<xsl:template match="*" mode="getRegionBodyWidth">
		<xsl:param name="pageRegionType">
			<xsl:choose>
				<xsl:when test="/*/Format/PageGeometry/StandardPageRegion[@type = 'odd' and string-length(@filter) = 0]">odd</xsl:when>
				<xsl:otherwise>even</xsl:otherwise>
			</xsl:choose>
		</xsl:param>
		
		<xsl:variable name="filter" select="ancestor::InfoMap[@filter[string-length(.) &gt; 0]][1]/@filter"/>
		
		<xsl:variable name="pageWidth">
			<xsl:call-template name="getStandardPageRegionAttribute">
				<xsl:with-param name="pageRegionType" select="$pageRegionType"/>
				<xsl:with-param name="attributeName">width</xsl:with-param>
				<xsl:with-param name="defaultValue" select="$PAGE_WIDTH"/>
				<xsl:with-param name="filter" select="$filter"/>
			</xsl:call-template>
		</xsl:variable>

		<!-- Commented due to https://issues.apache.org/jira/browse/FOP-2335 -->
		<!--<xsl:variable name="startRegion">
			<xsl:call-template name="getPixels">
				<xsl:with-param name="value">
					<xsl:call-template name="getStandardPageRegionSpace">
						<xsl:with-param name="pageRegionType" select="$pageRegionType"/>
						<xsl:with-param name="filter" select="ancestor::InfoMap[@filter[string-length(.) &gt; 0]][1]/@filter"/>
						<xsl:with-param name="elementName">Startregion</xsl:with-param>
						<xsl:with-param name="attributeName">width</xsl:with-param>
					</xsl:call-template>
				</xsl:with-param>
				<xsl:with-param name="dpi" select="$OUTPUT_RESOLUTION"/>
			</xsl:call-template>
		</xsl:variable>
		<xsl:variable name="endRegion">
			<xsl:call-template name="getPixels">
				<xsl:with-param name="value">
					<xsl:call-template name="getStandardPageRegionSpace">
						<xsl:with-param name="pageRegionType" select="$pageRegionType"/>
						<xsl:with-param name="filter" select="ancestor::InfoMap[@filter[string-length(.) &gt; 0]][1]/@filter"/>
						<xsl:with-param name="elementName">Endregion</xsl:with-param>
						<xsl:with-param name="attributeName">width</xsl:with-param>
					</xsl:call-template>
				</xsl:with-param>
				<xsl:with-param name="dpi" select="$OUTPUT_RESOLUTION"/>
			</xsl:call-template>
		</xsl:variable>-->

		<xsl:variable name="pageWidthPx">
			<xsl:call-template name="getPixels">
				<xsl:with-param name="value" select="$pageWidth"/>
				<xsl:with-param name="dpi" select="$OUTPUT_RESOLUTION"/>
			</xsl:call-template>
		</xsl:variable>
		<xsl:variable name="leftMarginPx">
			<xsl:call-template name="getPixels">
				<xsl:with-param name="value">
					<xsl:call-template name="getStandardPageRegionFormat">
						<xsl:with-param name="pageRegionType" select="$pageRegionType"/>
						<xsl:with-param name="name">margin-left</xsl:with-param>
						<xsl:with-param name="defaultValue">0mm</xsl:with-param>
						<xsl:with-param name="filter" select="$filter"/>
					</xsl:call-template>
				</xsl:with-param>
				<xsl:with-param name="dpi" select="$OUTPUT_RESOLUTION"/>
			</xsl:call-template>
		</xsl:variable>
		<xsl:variable name="rightMarginPx">
			<xsl:call-template name="getPixels">
				<xsl:with-param name="value">
					<xsl:call-template name="getStandardPageRegionFormat">
						<xsl:with-param name="pageRegionType" select="$pageRegionType"/>
						<xsl:with-param name="name">margin-right</xsl:with-param>
						<xsl:with-param name="defaultValue">0mm</xsl:with-param>
						<xsl:with-param name="filter" select="$filter"/>
					</xsl:call-template>
				</xsl:with-param>
				<xsl:with-param name="dpi" select="$OUTPUT_RESOLUTION"/>
			</xsl:call-template>
		</xsl:variable>
		<xsl:variable name="leftPaddingPx">
			<xsl:call-template name="getPixels">
				<xsl:with-param name="value">
					<xsl:call-template name="getStandardPageRegionFormat">
						<xsl:with-param name="pageRegionType" select="$pageRegionType"/>
						<xsl:with-param name="name">padding-left</xsl:with-param>
						<xsl:with-param name="defaultValue">0mm</xsl:with-param>
						<xsl:with-param name="filter" select="$filter"/>
					</xsl:call-template>
				</xsl:with-param>
				<xsl:with-param name="dpi" select="$OUTPUT_RESOLUTION"/>
			</xsl:call-template>
		</xsl:variable>
		<xsl:variable name="rightPaddingPx">
			<xsl:call-template name="getPixels">
				<xsl:with-param name="value">
					<xsl:call-template name="getStandardPageRegionFormat">
						<xsl:with-param name="pageRegionType" select="$pageRegionType"/>
						<xsl:with-param name="name">padding-right</xsl:with-param>
						<xsl:with-param name="defaultValue">0mm</xsl:with-param>
						<xsl:with-param name="filter" select="$filter"/>
					</xsl:call-template>
				</xsl:with-param>
				<xsl:with-param name="dpi" select="$OUTPUT_RESOLUTION"/>
			</xsl:call-template>
		</xsl:variable>
		<xsl:variable name="gutterPx">
			<xsl:call-template name="getPixels">
				<xsl:with-param name="value">
					<xsl:call-template name="getTemplateVariableValue">
						<xsl:with-param name="name" select="'GUTTER'"/>
						<xsl:with-param name="defaultValue">0cm</xsl:with-param>
					</xsl:call-template>
				</xsl:with-param>
				<xsl:with-param name="dpi" select="$OUTPUT_RESOLUTION"/>
			</xsl:call-template>
		</xsl:variable>

		<!--  - $startRegion - $endRegion -->
		<xsl:value-of select="$pageWidthPx - $leftMarginPx - $rightMarginPx - $leftPaddingPx - $rightPaddingPx - $gutterPx"/>
	</xsl:template>

	<xsl:template match="*" mode="getRegionBodyHeight">
		<xsl:param name="pageRegionType">
			<xsl:choose>
				<xsl:when test="/*/Format/PageGeometry/StandardPageRegion[@type = 'odd' and string-length(@filter) = 0]">odd</xsl:when>
				<xsl:otherwise>even</xsl:otherwise>
			</xsl:choose>
		</xsl:param>

		<xsl:variable name="filter" select="ancestor::InfoMap[@filter[string-length(.) &gt; 0]][1]/@filter"/>

		<xsl:variable name="headlineHeightPx">
			<xsl:call-template name="getPixels">
				<xsl:with-param name="value">
					<xsl:call-template name="getStandardPageRegionHeadlineHeight">
						<xsl:with-param name="pageRegionType" select="$pageRegionType"/>
						<xsl:with-param name="filter" select="$filter"/>
					</xsl:call-template>
				</xsl:with-param>
				<xsl:with-param name="dpi" select="$OUTPUT_RESOLUTION"/>
			</xsl:call-template>
		</xsl:variable>

		<xsl:variable name="sublineHeightPx">
			<xsl:call-template name="getPixels">
				<xsl:with-param name="value">
					<xsl:call-template name="getStandardPageRegionSublineHeight">
						<xsl:with-param name="pageRegionType" select="$pageRegionType"/>
						<xsl:with-param name="filter" select="$filter"/>
					</xsl:call-template>
				</xsl:with-param>
				<xsl:with-param name="dpi" select="$OUTPUT_RESOLUTION"/>
			</xsl:call-template>
		</xsl:variable>

		<xsl:variable name="pageHeightPx">
			<xsl:call-template name="getPixels">
				<xsl:with-param name="value">
					<xsl:call-template name="getStandardPageRegionAttribute">
						<xsl:with-param name="pageRegionType" select="$pageRegionType"/>
						<xsl:with-param name="attributeName">height</xsl:with-param>
						<xsl:with-param name="defaultValue" select="$PAGE_HEIGHT"/>
						<xsl:with-param name="filter" select="$filter"/>
					</xsl:call-template>
				</xsl:with-param>
				<xsl:with-param name="dpi" select="$OUTPUT_RESOLUTION"/>
			</xsl:call-template>
		</xsl:variable>
		<xsl:variable name="topMarginPx">
			<xsl:call-template name="getPixels">
				<xsl:with-param name="value">
					<xsl:call-template name="getStandardPageRegionFormat">
						<xsl:with-param name="pageRegionType" select="$pageRegionType"/>
						<xsl:with-param name="name">margin-top</xsl:with-param>
						<xsl:with-param name="defaultValue">0mm</xsl:with-param>
						<xsl:with-param name="filter" select="$filter"/>
					</xsl:call-template>
				</xsl:with-param>
				<xsl:with-param name="dpi" select="$OUTPUT_RESOLUTION"/>
			</xsl:call-template>
		</xsl:variable>
		<xsl:variable name="bottomMarginPx">
			<xsl:call-template name="getPixels">
				<xsl:with-param name="value">
					<xsl:call-template name="getStandardPageRegionFormat">
						<xsl:with-param name="pageRegionType" select="$pageRegionType"/>
						<xsl:with-param name="name">margin-bottom</xsl:with-param>
						<xsl:with-param name="defaultValue">0mm</xsl:with-param>
						<xsl:with-param name="filter" select="$filter"/>
					</xsl:call-template>
				</xsl:with-param>
				<xsl:with-param name="dpi" select="$OUTPUT_RESOLUTION"/>
			</xsl:call-template>
		</xsl:variable>
		<xsl:variable name="bottomPaddingPx">
			<xsl:call-template name="getPixels">
				<xsl:with-param name="value">
					<xsl:call-template name="getStandardPageRegionFormat">
						<xsl:with-param name="pageRegionType" select="$pageRegionType"/>
						<xsl:with-param name="name">padding-bottom</xsl:with-param>
						<xsl:with-param name="defaultValue">0</xsl:with-param>
						<xsl:with-param name="filter" select="$filter"/>
					</xsl:call-template>
				</xsl:with-param>
				<xsl:with-param name="dpi" select="$OUTPUT_RESOLUTION"/>
			</xsl:call-template>
		</xsl:variable>

		<xsl:value-of select="$pageHeightPx - $topMarginPx - $bottomMarginPx - $headlineHeightPx - $sublineHeightPx - $bottomPaddingPx"/>
	</xsl:template>

	<xsl:template match="ancestor-element" mode="checkCondition">
		<xsl:param name="currentElement"/>
		<xsl:param name="value" select="string(@value)"/>
		<xsl:choose>
			<xsl:when test="$value = 'headline.content'">
				<xsl:if test="$currentElement/ancestor::Headline.content[1]">true</xsl:if>
			</xsl:when>
			<xsl:when test="$value = 'legend'">
				<xsl:if test="$currentElement/ancestor::legend[not(@isTableLegend or parent::Media.theme)][1]">true</xsl:if>
			</xsl:when>
			<xsl:when test="$value = 'table.legend'">
				<xsl:if test="$currentElement/ancestor::legend[@isTableLegend][1]">true</xsl:if>
			</xsl:when>
			<xsl:when test="$value = 'media.legend'">
				<xsl:if test="$currentElement/ancestor::Media.theme/legend">true</xsl:if>
			</xsl:when>
			<xsl:when test="$value = 'label'">
				<xsl:if test="$currentElement/ancestor::Label[1]">true</xsl:if>
			</xsl:when>
			<xsl:when test="$value = 'par'">
				<xsl:if test="$currentElement/ancestor::InfoPar[1]">true</xsl:if>
			</xsl:when>
			<xsl:when test="$value = 'notice'">
				<xsl:if test="$currentElement/ancestor::InfoItem.Warning[1]">true</xsl:if>
			</xsl:when>
			<xsl:when test="$value = 'enum.standard'">
				<xsl:if test="$currentElement/ancestor::Enum[1]">true</xsl:if>
			</xsl:when>
			<xsl:when test="$value = 'instruction'">
				<xsl:if test="$currentElement/ancestor::Enum.Instruction[1]">true</xsl:if>
			</xsl:when>
			<xsl:when test="$value = 'Table'">
				<xsl:if test="$currentElement/ancestor::*[name() = 'table' or name() = 'table.NoBorder']">true</xsl:if>
			</xsl:when>
			<xsl:when test="$value = 'table.NoBorder'">
				<xsl:if test="$currentElement/ancestor::table.NoBorder">true</xsl:if>
			</xsl:when>
			<xsl:when test="$value = 'Table Cell'">
				<xsl:if test="$currentElement/ancestor::tableCell">true</xsl:if>
			</xsl:when>
			<xsl:when test="$value = 'subsection'">
				<xsl:if test="$currentElement/ancestor::InfoMap[@isSubSection]">true</xsl:if>
			</xsl:when>
			<xsl:otherwise>
				<xsl:if test="$currentElement/ancestor::*[name() = $value]">true</xsl:if>
			</xsl:otherwise>
		</xsl:choose>

	</xsl:template>


	<xsl:template name="formatDate">
		<xsl:param name="date"/>
		<xsl:param name="hasDate"/>
		<xsl:param name="dateString"/>
		<xsl:param name="showTime" select="false()"/>
		<xsl:param name="defaultPattern">
			<xsl:choose>
				<xsl:when test="$showTime">yyyy-MM-dd HH:mm:ss</xsl:when>
				<xsl:otherwise>yyyy-MM-dd</xsl:otherwise>
			</xsl:choose>
		</xsl:param>
		<xsl:variable name="varPrefix">
			<xsl:choose>
				<xsl:when test="$showTime">DATE_TIME_FORMAT</xsl:when>
				<xsl:otherwise>DATE_FORMAT</xsl:otherwise>
			</xsl:choose>
		</xsl:variable>
		<xsl:variable name="dateFormat">
			<xsl:call-template name="getTemplateVariableValue">
				<xsl:with-param name="name" select="concat($varPrefix, '_', ancestor::*[string-length(@defaultLanguage) &gt; 0][1]/@defaultLanguage)"/>
				<xsl:with-param name="defaultValue">
					<xsl:call-template name="getTemplateVariableValue">
						<xsl:with-param name="name" select="$varPrefix"/>
						<xsl:with-param name="defaultValue" select="$defaultPattern"/>
					</xsl:call-template>
				</xsl:with-param>
			</xsl:call-template>
		</xsl:variable>

		<!--<xsl:variable name="dateformatInstance" select="dateformat:new(string($dateFormat))"/>-->

		<xsl:value-of select="$dateString"/>
		<!--<xsl:choose>
			<xsl:when test="string-length($dateString) &gt; 0">
				<xsl:choose>
					<xsl:when test="string-length($dateString) = 20 and contains($dateString, '-') and contains($dateString, ':')">
						<xsl:variable name="defaultDateformatInstance" select="dateformat:new('yyyy-MM-dd HH:mm:ss')"/>
						<xsl:variable name="dateInstance" select="dateformat:parse($defaultDateformatInstance, string($dateString))"/>
						<xsl:value-of select="dateformat:format($dateformatInstance, $dateInstance)"/>
					</xsl:when>
					<xsl:when test="string-length($dateString) = 25 and contains($dateString, '-') and contains($dateString, ':')">
						<xsl:variable name="defaultDateformatInstance" select="dateformat:new('yyyy-MM-dd HH:mm:ss Z')"/>
						<xsl:variable name="dateInstance" select="dateformat:parse($defaultDateformatInstance, string($dateString))"/>
						<xsl:value-of select="dateformat:format($dateformatInstance, $dateInstance)"/>
					</xsl:when>
					<xsl:otherwise>
						--><!-- unknown date format --><!--
						<xsl:message>
							<xsl:text>Unknown date format: </xsl:text>
							<xsl:value-of select="$dateString"/>
						</xsl:message>
						<xsl:value-of select="$dateString"/>
					</xsl:otherwise>
				</xsl:choose>
			</xsl:when>
			<xsl:when test="$hasDate">
				<xsl:value-of select="dateformat:format($dateformatInstance, $date)"/>
			</xsl:when>
		</xsl:choose>-->
	</xsl:template>

</xsl:stylesheet>

