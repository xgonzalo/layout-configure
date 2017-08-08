<?xml version="1.0" encoding="utf-8"?>
<xsl:stylesheet
	xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
	xmlns:fo="http://www.w3.org/1999/XSL/Format"
	xmlns:fox="http://xmlgraphics.apache.org/fop/extensions"
	version="1.0">

	<xsl:param name="svgTransformer"/>
	<xsl:param name="sessionid"/>
	<xsl:param name="compareChangedImages"/>

	<xsl:variable name="MEDIA_COL1_DEFAULT_VALUE">23mm</xsl:variable>
	<xsl:variable name="MEDIA_COL2_DEFAULT_VALUE">2mm</xsl:variable>

	<xsl:template name="getPicURL">
		<xsl:param name="pathPrefix" select="''"/>

		<!--<xsl:if test="(string-length(@escapedSubURL) &gt; 0 or string-length(@subURL) &gt; 0) and @subURL != '/media'">

			<xsl:choose>
				<xsl:when test="$Offline = 'Offline'">
					<xsl:value-of select="concat($productionImagePath, $pathPrefix, '/')"/>
					<xsl:call-template name="escapeFileSystemPath">
						<xsl:with-param name="path" select="@subURL"/>
					</xsl:call-template>
				</xsl:when>
				<xsl:otherwise>
					<xsl:value-of select="@serverURL"/>
					<xsl:choose>
						<xsl:when test="contains(@escapedSubURL, '?')">
							<xsl:value-of select="substring-before(@escapedSubURL, '?')"/>
							<xsl:if test="$isAHMode and string-length($sessionid) &gt; 0">
								<xsl:value-of select="concat(';jsessionid=', $sessionid)"/>
							</xsl:if>
							<xsl:text>?</xsl:text>
							<xsl:value-of select="substring-after(@escapedSubURL, '?')"/>
							<xsl:text>&amp;</xsl:text>
						</xsl:when>
						<xsl:when test="$isAHMode">
							<xsl:text>/image</xsl:text>
							<xsl:if test="string-length($sessionid) &gt; 0">
								<xsl:value-of select="concat(';jsessionid=', $sessionid)"/>
							</xsl:if>
							<xsl:text>?objType=</xsl:text>
							<xsl:value-of select="RefControl/@objType"/>
							<xsl:text>&amp;itemUri=</xsl:text>
							<xsl:value-of select="@escapedSubURL"/>
							<xsl:text>&amp;</xsl:text>
						</xsl:when>
						<xsl:otherwise>
							<xsl:value-of select="@escapedSubURL"/>
							<xsl:if test="$isAHMode and string-length($sessionid) &gt; 0">
								<xsl:value-of select="concat(';jsessionid=', $sessionid)"/>
							</xsl:if>
							<xsl:text>?</xsl:text>
						</xsl:otherwise>
					</xsl:choose>
					<xsl:value-of select="concat('dummy=', $TIMESTAMP)"/>
					<xsl:if test="@isSVG and string-length($svgTransformer) &gt; 0">
						<xsl:value-of select="concat('&amp;trafo=', $svgTransformer)"/>
					</xsl:if>
				</xsl:otherwise>
			</xsl:choose>
		</xsl:if>-->
		<xsl:if test="RefControl/File">
			<xsl:choose>
				<xsl:when test="RefControl/File/@isUploaded = 'true'">
					<xsl:value-of select="concat(RefControl/File[@itemName='original']/@basePath, '/uploads/', RefControl/File[@itemName = 'original']/@url)"/>
				</xsl:when>
				<xsl:when test="RefControl/File/@isTypeOfImage = 'true'">
					<xsl:value-of select="concat(RefControl/File[@itemName = 'original']/@basePath, '/framework/css/images/', RefControl/File[@itemName = 'original']/@url)"/>
				</xsl:when>
				<xsl:when test="RefControl/File/@isWaterMark = 'true'">
						<xsl:value-of select="concat(RefControl/File[@itemName = 'original']/@basePath, '/framework/css/images/', RefControl/File[@itemName = 'original']/@url)"/>
				</xsl:when>
				<xsl:when test="ancestor::Format">
					<xsl:value-of select="concat('../../styles/style1/media', RefControl/File[@itemName = 'original']/@url)"/>
				</xsl:when>
				<xsl:otherwise>
					<xsl:value-of select="concat('../../content/media', RefControl/File[@itemName = 'original']/@url)"/>
				</xsl:otherwise>
			</xsl:choose>
		</xsl:if>
	</xsl:template>

	<xsl:template name="getFullWidth">
		<xsl:param name="isLandscape"/>
		<xsl:param name="marginalColumnWidth"/>

		<xsl:apply-templates select="current()" mode="getImageWidth">
			<xsl:with-param name="isLandscape" select="$isLandscape"/>
			<xsl:with-param name="marginalColumnWidth" select="$marginalColumnWidth"/>
		</xsl:apply-templates>
	</xsl:template>

	<xsl:template match="Media.theme" mode="getImageWidth">
		<xsl:param name="marginalColumnWidth"/>
		<xsl:param name="customRegionElem" select="ancestor::Region[1]"/>
		<xsl:param name="mediaColIndentPx" select="0"/>

		<xsl:variable name="COLUMNS">
			<xsl:call-template name="getColumnCount"/>
		</xsl:variable>

		<xsl:variable name="hasColumns" select="$COLUMNS &gt; 1"/>

		<xsl:variable name="COLUMN_GAP">
			<xsl:call-template name="getStandardPageRegionFormat">
				<xsl:with-param name="pageRegionType">odd</xsl:with-param>
				<xsl:with-param name="name">column-gap</xsl:with-param>
				<xsl:with-param name="defaultValue">
					<xsl:call-template name="getStandardPageRegionFormat">
						<xsl:with-param name="pageRegionType">even</xsl:with-param>
						<xsl:with-param name="name">column-gap</xsl:with-param>
						<xsl:with-param name="defaultValue" select="'17pt'"/>
					</xsl:call-template>
				</xsl:with-param>
			</xsl:call-template>
		</xsl:variable>

		<xsl:variable name="COLUMN_GAP_PX">
			<xsl:call-template name="getPixels">
				<xsl:with-param name="value" select="$COLUMN_GAP"/>
				<xsl:with-param name="dpi" select="$OUTPUT_RESOLUTION"/>
			</xsl:call-template>
		</xsl:variable>

		<xsl:variable name="regionBodyWidth">
			<xsl:choose>
				<xsl:when test="$customRegionElem">
					<xsl:call-template name="getPixels">
						<xsl:with-param name="value">
							<xsl:choose>
								<xsl:when test="string(number($customRegionElem/Box/@width)) != 'NaN'">
									<xsl:value-of select="concat($customRegionElem/Box/@width, $customRegionElem/ancestor::PageGeometry[1]/@unit)"/>
								</xsl:when>
								<xsl:when test="string(number($customRegionElem/parent::StandardPageRegion/@width)) != 'NaN'">
									<xsl:value-of select="concat($customRegionElem/parent::StandardPageRegion/@width, $customRegionElem/ancestor::PageGeometry[1]/@unit)"/>
								</xsl:when>
								<xsl:otherwise>
									<xsl:value-of select="concat($customRegionElem/ancestor::PageGeometry[1]/@width, $customRegionElem/ancestor::PageGeometry[1]/@unit)"/>
								</xsl:otherwise>
							</xsl:choose>
						</xsl:with-param>
						<xsl:with-param name="dpi" select="$OUTPUT_RESOLUTION"/>
					</xsl:call-template>
				</xsl:when>
				<xsl:otherwise>
					<xsl:apply-templates select="current()" mode="getRegionBodyWidth"/>
				</xsl:otherwise>
			</xsl:choose>
		</xsl:variable>

		<xsl:variable name="marginalColumnWidthPx">
			<xsl:call-template name="getPixels">
				<xsl:with-param name="value" select="$marginalColumnWidth"/>
				<xsl:with-param name="dpi" select="$OUTPUT_RESOLUTION"/>
			</xsl:call-template>
		</xsl:variable>
		<xsl:variable name="enum" select="ancestor::*[name() = 'Enum.Instruction' or name() = 'Enum'][1]"/>
		<xsl:variable name="isInsideEnum" select="boolean($enum)"/>
		<xsl:variable name="isInsideEnumInstruction" select="$isInsideEnum and name($enum) = 'Enum.Instruction'"/>

		<xsl:variable name="stepIndent">
			<xsl:choose>
				<xsl:when test="$isInsideEnum">
					<xsl:call-template name="getPixels">
						<xsl:with-param name="value">
							<xsl:choose>
								<xsl:when test="$isInsideEnumInstruction">
									<xsl:call-template name="getTemplateVariableValue">
										<xsl:with-param name="name" select="'STEP_INDENT'"/>
										<xsl:with-param name="defaultValue">
											<xsl:call-template name="getTemplateVariableValue">
												<xsl:with-param name="name" select="'ENUM_INDENT'"/>
											</xsl:call-template>
										</xsl:with-param>
									</xsl:call-template>
								</xsl:when>
								<xsl:otherwise>
									<xsl:call-template name="getTemplateVariableValue">
										<xsl:with-param name="name" select="'ENUM_INDENT'"/>
									</xsl:call-template>
								</xsl:otherwise>
							</xsl:choose>
							<xsl:text>mm</xsl:text>
						</xsl:with-param>
						<xsl:with-param name="dpi" select="$OUTPUT_RESOLUTION"/>
					</xsl:call-template>
				</xsl:when>
				<xsl:otherwise>0</xsl:otherwise>
			</xsl:choose>
		</xsl:variable>

		<xsl:variable name="stepIndent2">
			<xsl:choose>
				<xsl:when test="$isInsideEnum">
					<xsl:call-template name="getPixels">
						<xsl:with-param name="value">
							<xsl:call-template name="getFormat">
								<xsl:with-param name="name">
									<xsl:choose>
										<xsl:when test="$isInsideEnumInstruction">instruction</xsl:when>
										<xsl:otherwise>enum.standard</xsl:otherwise>
									</xsl:choose>
								</xsl:with-param>
								<xsl:with-param name="attributeName">start-indent</xsl:with-param>
								<xsl:with-param name="defaultValue">0</xsl:with-param>
							</xsl:call-template>
						</xsl:with-param>
						<xsl:with-param name="dpi" select="$OUTPUT_RESOLUTION"/>
					</xsl:call-template>
				</xsl:when>
				<xsl:otherwise>0</xsl:otherwise>
			</xsl:choose>
		</xsl:variable>

		<xsl:variable name="stepIndent3">
			<xsl:choose>
				<xsl:when test="$isInsideEnum">
					<xsl:call-template name="getPixels">
						<xsl:with-param name="value">
							<xsl:call-template name="getFormat">
								<xsl:with-param name="name">
									<xsl:choose>
										<xsl:when test="$isInsideEnumInstruction">instruction</xsl:when>
										<xsl:otherwise>enum.standard</xsl:otherwise>
									</xsl:choose>
								</xsl:with-param>
								<xsl:with-param name="attributeName">margin-left</xsl:with-param>
								<xsl:with-param name="defaultValue">0</xsl:with-param>
							</xsl:call-template>
						</xsl:with-param>
						<xsl:with-param name="dpi" select="$OUTPUT_RESOLUTION"/>
					</xsl:call-template>
				</xsl:when>
				<xsl:otherwise>0</xsl:otherwise>
			</xsl:choose>
		</xsl:variable>

		<xsl:variable name="mediaIndent">
			<xsl:choose>
				<xsl:when test="parent::Media">
					<xsl:call-template name="getPixels">
						<xsl:with-param name="value">
							<xsl:call-template name="getFormat">
								<xsl:with-param name="name">media</xsl:with-param>
								<xsl:with-param name="attributeName">start-indent</xsl:with-param>
								<xsl:with-param name="defaultValue">0</xsl:with-param>
							</xsl:call-template>
						</xsl:with-param>
						<xsl:with-param name="dpi" select="$OUTPUT_RESOLUTION"/>
					</xsl:call-template>
				</xsl:when>
				<xsl:otherwise>0</xsl:otherwise>
			</xsl:choose>
		</xsl:variable>

		<xsl:variable name="tableIndent">
			<xsl:variable name="indElems">
				<xsl:for-each select="ancestor::table">
					<ind>
						<xsl:call-template name="getPixels">
							<xsl:with-param name="value">
								<xsl:call-template name="getFormat">
									<xsl:with-param name="name">table</xsl:with-param>
									<xsl:with-param name="attributeName">start-indent</xsl:with-param>
									<xsl:with-param name="defaultValue">0</xsl:with-param>
								</xsl:call-template>
							</xsl:with-param>
							<xsl:with-param name="dpi" select="$OUTPUT_RESOLUTION"/>
						</xsl:call-template>
					</ind>
				</xsl:for-each>
			</xsl:variable>
			<xsl:choose>
				<xsl:when test="string-length($indElems) &gt; 0">
					<!--<xsl:value-of select="sum(exslt:node-set($indElems))"/>-->
					<xsl:text>0</xsl:text>
				</xsl:when>
				<xsl:otherwise>0</xsl:otherwise>
			</xsl:choose>
		</xsl:variable>
		
		<xsl:variable name="mediaEndindent">
			<xsl:choose>
				<xsl:when test="parent::Media">
					<xsl:call-template name="getPixels">
						<xsl:with-param name="value">
							<xsl:call-template name="getFormat">
								<xsl:with-param name="name">media</xsl:with-param>
								<xsl:with-param name="attributeName">end-indent</xsl:with-param>
								<xsl:with-param name="defaultValue">0</xsl:with-param>
							</xsl:call-template>
						</xsl:with-param>
						<xsl:with-param name="dpi" select="$OUTPUT_RESOLUTION"/>
					</xsl:call-template>
				</xsl:when>
				<xsl:otherwise>0</xsl:otherwise>
			</xsl:choose>
		</xsl:variable>

		<xsl:variable name="spanPre">
			<xsl:for-each select="ancestor::*[name() = 'Block' or name() = 'block.titlepage'][1]">
				<xsl:call-template name="getFormat">
					<xsl:with-param name="name">container-block</xsl:with-param>
					<xsl:with-param name="attributeName">span</xsl:with-param>
				</xsl:call-template>
			</xsl:for-each>
		</xsl:variable>

		<xsl:variable name="spanPre2">
			<xsl:choose>
				<xsl:when test="string-length($spanPre) = 0">
					<xsl:for-each select="parent::Media">
						<xsl:call-template name="getFormat">
							<xsl:with-param name="name">media.container</xsl:with-param>
							<xsl:with-param name="attributeName">span</xsl:with-param>
						</xsl:call-template>
					</xsl:for-each>
				</xsl:when>
				<xsl:otherwise>
					<xsl:value-of select="$spanPre"/>
				</xsl:otherwise>
			</xsl:choose>
		</xsl:variable>

		<xsl:variable name="spanPre3">
			<xsl:choose>
				<xsl:when test="string-length($spanPre2) = 0">
					<xsl:for-each select="ancestor::*[name() = 'table' or name() = 'table.NoBorder'][1]">
						<xsl:call-template name="getFormat">
							<xsl:with-param name="name">table.container</xsl:with-param>
							<xsl:with-param name="attributeName">span</xsl:with-param>
						</xsl:call-template>
					</xsl:for-each>
				</xsl:when>
				<xsl:otherwise>
					<xsl:value-of select="$spanPre2"/>
				</xsl:otherwise>
			</xsl:choose>
		</xsl:variable>

		<xsl:variable name="span">
			<xsl:choose>
				<xsl:when test="string-length($spanPre3) = 0">
					<xsl:for-each select="ancestor::InfoMap[1]">
						<xsl:call-template name="getFormat">
							<xsl:with-param name="name">section</xsl:with-param>
							<xsl:with-param name="attributeName">span</xsl:with-param>
						</xsl:call-template>
					</xsl:for-each>
				</xsl:when>
				<xsl:otherwise>
					<xsl:value-of select="$spanPre3"/>
				</xsl:otherwise>
			</xsl:choose>
		</xsl:variable>

		<xsl:variable name="applyColumnSpace" select="$hasColumns and not($span = 'all' or ancestor::Headline or ancestor::Subline)"/>

		<xsl:variable name="availableWidth">
			<xsl:choose>
				<xsl:when test="$applyColumnSpace and not($customRegionElem)">
					<xsl:value-of select="($regionBodyWidth - $marginalColumnWidthPx - 
							  $COLUMN_GAP_PX * ($COLUMNS - 1)) div $COLUMNS - $mediaColIndentPx - $mediaIndent - $mediaEndindent - $stepIndent - $stepIndent2 - $stepIndent3 - $tableIndent"/>
				</xsl:when>
				<xsl:otherwise>
					<xsl:value-of select="$regionBodyWidth - $mediaColIndentPx - $mediaIndent - $mediaEndindent - $marginalColumnWidthPx - $stepIndent - $stepIndent2 - $stepIndent3 - $tableIndent"/>
				</xsl:otherwise>
			</xsl:choose>
		</xsl:variable>

		<xsl:variable name="preAddSpace">
			<xsl:apply-templates select="current()" mode="getAdditionalSpace">
				<xsl:with-param name="availableWidth" select="$availableWidth"/>
			</xsl:apply-templates>
		</xsl:variable>

		<xsl:variable name="addSpace">
			<xsl:choose>
				<xsl:when test="string(number($preAddSpace)) != 'NaN'">
					<xsl:value-of select="$preAddSpace"/>
				</xsl:when>
				<xsl:otherwise>
					<xsl:call-template name="getPixels">
						<xsl:with-param name="value" select="$preAddSpace"/>
						<xsl:with-param name="dpi" select="$OUTPUT_RESOLUTION"/>
					</xsl:call-template>
				</xsl:otherwise>
			</xsl:choose>
		</xsl:variable>

		<xsl:choose>
			<xsl:when test="string(number(@content-size-modification)) != 'NaN'">
				<xsl:value-of select="($availableWidth - $addSpace) * (@content-size-modification div 100)"/>
			</xsl:when>
			<xsl:otherwise>
				<xsl:value-of select="$availableWidth - $addSpace"/>
			</xsl:otherwise>
		</xsl:choose>

	</xsl:template>

	<xsl:template name="getFullHeight">
		<xsl:param name="isLandscape"/>
		<xsl:param name="heightCorrection" select="60"/>

		<xsl:apply-templates select="current()" mode="getImageHeight">
			<xsl:with-param name="isLandscape" select="$isLandscape"/>
			<xsl:with-param name="heightCorrection" select="$heightCorrection"/>
		</xsl:apply-templates>

	</xsl:template>

	<xsl:template match="*" mode="getImageHeight">
		<xsl:param name="customRegionElem"/>
		<xsl:param name="blockType" select="ancestor::*[starts-with(name(),'Block')]/@Typ"/>
		<xsl:param name="heightCorrection">
			<xsl:call-template name="getTemplateVariableValue">
				<xsl:with-param name="name">MEDIA_THEME_HEIGHT_CORRECTION</xsl:with-param>
				<xsl:with-param name="defaultValue" select="60"/>
			</xsl:call-template>
		</xsl:param>

		<xsl:variable name="heightCorrection2">
			<xsl:choose>
				<xsl:when test="string(number($heightCorrection)) != 'NaN'">
					<xsl:value-of select="$heightCorrection"/>
				</xsl:when>
				<xsl:otherwise>60</xsl:otherwise>
			</xsl:choose>
		</xsl:variable>

		<xsl:variable name="regionBodyHeight">
			<xsl:apply-templates select="current()" mode="getRegionBodyHeight"/>
		</xsl:variable>


		<xsl:variable name="preAddSpace">
			<xsl:apply-templates select="current()" mode="getAdditionalVSpace"/>
		</xsl:variable>

		<xsl:variable name="addSpace">
			<xsl:choose>
				<xsl:when test="string(number($preAddSpace)) != 'NaN'">
					<xsl:value-of select="$preAddSpace"/>
				</xsl:when>
				<xsl:otherwise>
					<xsl:call-template name="getPixels">
						<xsl:with-param name="value" select="$preAddSpace"/>
						<xsl:with-param name="dpi" select="$OUTPUT_RESOLUTION"/>
					</xsl:call-template>
				</xsl:otherwise>
			</xsl:choose>
		</xsl:variable>

		<xsl:variable name="blockMaxHeight">
			<xsl:if test="string-length($blockType) &gt; 0">
				<xsl:call-template name="getPixels">
					<xsl:with-param name="value">
						<xsl:call-template name="getTemplateVariableValue">
							<xsl:with-param name="name" select="concat($blockType, '_MEDIA_THEME_MAX_HEIGHT')"/>
							<xsl:with-param name="defaultValue" select="0"/>
						</xsl:call-template>
					</xsl:with-param>
					<xsl:with-param name="dpi" select="$OUTPUT_RESOLUTION"/>
				</xsl:call-template>
			</xsl:if>
		</xsl:variable>

		<xsl:variable name="customRegionHeight">
			<xsl:if test="$customRegionElem">
				<xsl:call-template name="getPixels">
					<xsl:with-param name="value">
						<xsl:choose>
							<xsl:when test="string(number($customRegionElem/Box/@height)) != 'NaN'">
								<xsl:value-of select="concat($customRegionElem/Box/@height, $customRegionElem/ancestor::PageGeometry[1]/@unit)"/>
							</xsl:when>
							<xsl:when test="string(number($customRegionElem/parent::StandardPageRegion/@height)) != 'NaN'">
								<xsl:value-of select="concat($customRegionElem/parent::StandardPageRegion/@height, $customRegionElem/ancestor::PageGeometry[1]/@unit)"/>
							</xsl:when>
							<xsl:otherwise>
								<xsl:value-of select="concat($customRegionElem/ancestor::PageGeometry[1]/@height, $customRegionElem/ancestor::PageGeometry[1]/@unit)"/>
							</xsl:otherwise>
						</xsl:choose>
					</xsl:with-param>
					<xsl:with-param name="dpi" select="$OUTPUT_RESOLUTION"/>
				</xsl:call-template>
			</xsl:if>
		</xsl:variable>

		<xsl:variable name="maxHeight" select="$regionBodyHeight - $heightCorrection2 - $addSpace"/>

		<xsl:choose>
			<xsl:when test="string-length($blockMaxHeight) &gt; 0 and $blockMaxHeight &gt; 0 and $blockMaxHeight &lt; $maxHeight">
				<xsl:value-of select="$blockMaxHeight"/>
			</xsl:when>
			<xsl:when test="string-length($customRegionHeight) &gt; 0 and $customRegionHeight &gt; 0 and $customRegionHeight &lt; $maxHeight">
				<xsl:value-of select="$customRegionHeight"/>
			</xsl:when>
			<xsl:otherwise>
				<xsl:value-of select="$maxHeight"/>
			</xsl:otherwise>
		</xsl:choose>
	</xsl:template>

	<!--<xsl:template match="*" mode="getAdditionalSpace">
		<xsl:variable name="startIndent">
			<xsl:call-template name="getPixels">
				<xsl:with-param name="value">
					<xsl:call-template name="getFormat">
						<xsl:with-param name="attributeName">start-indent</xsl:with-param>
						<xsl:with-param name="name">block</xsl:with-param>
						<xsl:with-param name="defaultValue">0cm</xsl:with-param>
					</xsl:call-template>
				</xsl:with-param>
				<xsl:with-param name="dpi" select="$OUTPUT_RESOLUTION"/>
			</xsl:call-template>
		</xsl:variable>
		<xsl:value-of select="concat($startIndent, 'px')"/>
	</xsl:template>-->

	<xsl:template match="*" mode="getAdditionalVSpace">
		<xsl:value-of select="0"/>
	</xsl:template>

	<xsl:template match="Media.theme">
		<xsl:param name="P_WholeWidth"/>
		<xsl:param name="P_TextIntense"/>
		<xsl:param name="P_Indented"/>
		<xsl:param name="P_maxHeight"/>
		<xsl:param name="cellPaddingMinifier" select="0"/>
		<xsl:param name="marginalColumnWidth">0mm</xsl:param>
		<xsl:param name="isInline" select="false()"/>
		<xsl:param name="customRegionElem" select="ancestor::Region[1]"/>

		<xsl:apply-templates select="current()" mode="writeMediaPicture">
			<xsl:with-param name="P_WholeWidth" select="$P_WholeWidth"/>
			<xsl:with-param name="P_TextIntense" select="$P_TextIntense"/>
			<xsl:with-param name="P_Indented" select="$P_Indented"/>
			<xsl:with-param name="P_maxHeight" select="$P_maxHeight"/>
			<xsl:with-param name="cellPaddingMinifier" select="$cellPaddingMinifier"/>
			<xsl:with-param name="marginalColumnWidth" select="$marginalColumnWidth"/>
			<xsl:with-param name="isInline" select="$isInline"/>
			<xsl:with-param name="customRegionElem" select="$customRegionElem"/>
		</xsl:apply-templates>
	</xsl:template>

	<xsl:template match="*" mode="getImageResolution">
		<xsl:param name="imageResolution" select="@resolution"/>
		<xsl:choose>
			<xsl:when test="string(number($imageResolution)) != 'NaN'">
				<xsl:value-of select="$imageResolution"/>
			</xsl:when>
			<xsl:otherwise>
				<xsl:value-of select="72"/>
			</xsl:otherwise>
		</xsl:choose>
	</xsl:template>

	<xsl:template match="Media.theme" mode="getDefaultFont">Helvetica</xsl:template>

	<xsl:template name="writeMediaPicture">
		<xsl:param name="P_WholeWidth"/>
		<xsl:param name="P_Indented"/>
		<xsl:param name="P_maxHeight"/>
		<xsl:param name="cellPaddingMinifier" select="0"/>
		<xsl:param name="marginalColumnWidth">0mm</xsl:param>
		<xsl:param name="customRegionElem" select="ancestor::Region[1]"/>
		<xsl:param name="isInline"/>

		<xsl:variable name="BlockType" select="ancestor::*[starts-with(name(),'Block')]/@Typ"/>

		<xsl:variable name="captionPosition">
			<xsl:call-template name="getTemplateVariableValue">
				<xsl:with-param name="name" select="'MEDIA_CAPTION_POSITION'"/>
				<xsl:with-param name="defaultValue">inner</xsl:with-param>
			</xsl:call-template>
		</xsl:variable>

		<xsl:variable name="writeCaption" select="not(@inline) and (not(count(parent::Media/Media.theme) &gt; 1) or $compareChangedImages = 'true')"/>
		<xsl:variable name="isLeftCaption" select="$writeCaption and $captionPosition = 'left' and not(parent::Media/parent::tableCell)"/>

		<xsl:variable name="MEDIA_COL1_PX">
			<xsl:if test="$isLeftCaption">
				<xsl:call-template name="getPixels">
					<xsl:with-param name="value">
						<xsl:call-template name="getTemplateVariableValue">
							<xsl:with-param name="name" select="'MEDIA_COL1'"/>
							<xsl:with-param name="defaultValue" select="$MEDIA_COL1_DEFAULT_VALUE"/>
						</xsl:call-template>
					</xsl:with-param>
					<xsl:with-param name="dpi" select="$OUTPUT_RESOLUTION"/>
				</xsl:call-template>
			</xsl:if>
		</xsl:variable>
		<xsl:variable name="MEDIA_COL2_PX">
			<xsl:if test="$isLeftCaption">
				<xsl:call-template name="getPixels">
					<xsl:with-param name="value">
						<xsl:call-template name="getTemplateVariableValue">
							<xsl:with-param name="name" select="'MEDIA_COL2'"/>
							<xsl:with-param name="defaultValue" select="$MEDIA_COL2_DEFAULT_VALUE"/>
						</xsl:call-template>
					</xsl:with-param>
					<xsl:with-param name="dpi" select="$OUTPUT_RESOLUTION"/>
				</xsl:call-template>
			</xsl:if>
		</xsl:variable>

		<xsl:variable name="mediaColIndent">
			<xsl:choose>
				<xsl:when test="$isLeftCaption">
					<xsl:value-of select="$MEDIA_COL1_PX + $MEDIA_COL2_PX"/>
				</xsl:when>
				<xsl:otherwise>0</xsl:otherwise>
			</xsl:choose>
		</xsl:variable>
		
		<xsl:variable name="fWidth">
			<xsl:apply-templates select="current()" mode="getImageWidth">
				<xsl:with-param name="marginalColumnWidth" select="$marginalColumnWidth"/>
				<xsl:with-param name="customRegionElem" select="$customRegionElem"/>
				<xsl:with-param name="mediaColIndentPx" select="$mediaColIndent"/>
			</xsl:apply-templates>
		</xsl:variable>

		<xsl:variable name="fHeight">
			<xsl:apply-templates select="current()" mode="getImageHeight">
				<xsl:with-param name="blockType" select="$BlockType"/>
				<xsl:with-param name="customRegionElem" select="$customRegionElem"/>
			</xsl:apply-templates>
		</xsl:variable>

		<xsl:variable name="formatElement">
			<xsl:choose>
				<xsl:when test="@inline">media.theme</xsl:when>
				<xsl:when test="RefControl/@objType = 'mathml'">formula</xsl:when>
				<xsl:otherwise>media</xsl:otherwise>
			</xsl:choose>
		</xsl:variable>

		<xsl:variable name="mediaBorder">
			<xsl:call-template name="getPixels">
				<xsl:with-param name="value">
					<xsl:call-template name="getFormat">
						<xsl:with-param name="attributeName">border-width</xsl:with-param>
						<xsl:with-param name="name" select="$formatElement"/>
					</xsl:call-template>
				</xsl:with-param>
				<xsl:with-param name="dpi" select="$OUTPUT_RESOLUTION"/>
			</xsl:call-template>
		</xsl:variable>

		<xsl:variable name="mediaPadding">
			<xsl:call-template name="getPixels">
				<xsl:with-param name="value">
					<xsl:call-template name="getFormat">
						<xsl:with-param name="attributeName">padding-left</xsl:with-param>
						<xsl:with-param name="name" select="$formatElement"/>
					</xsl:call-template>
				</xsl:with-param>
				<xsl:with-param name="dpi" select="$OUTPUT_RESOLUTION"/>
			</xsl:call-template>
		</xsl:variable>

		<xsl:variable name="refOrient">
			<xsl:call-template name="getFormat">
				<xsl:with-param name="name" select="$formatElement"/>
				<xsl:with-param name="attributeName">reference-orientation</xsl:with-param>
			</xsl:call-template>
		</xsl:variable>

		<xsl:variable name="hasRotation" select="$refOrient = '90' or $refOrient = '180' or $refOrient = '270'"/>

		<xsl:variable name="WholeWidth">
			<xsl:choose>
				<xsl:when test="string-length($P_WholeWidth) &gt; 0">
					<xsl:value-of select="$P_WholeWidth"/>
				</xsl:when>
				<xsl:when test="number($fWidth)">
					<xsl:value-of select="$fWidth - $mediaBorder * 2 - $mediaPadding * 2"/>
				</xsl:when>
				<xsl:otherwise>
					<xsl:value-of select="642"/>
				</xsl:otherwise>
			</xsl:choose>
		</xsl:variable>

		<xsl:variable name="Indented">
			<xsl:choose>
				<xsl:when test="string-length($P_Indented) &gt; 0">
					<xsl:value-of select="$P_Indented"/>
				</xsl:when>
				<xsl:otherwise>
					<xsl:value-of select="$WholeWidth"/>
				</xsl:otherwise>
			</xsl:choose>
		</xsl:variable>

		<xsl:variable name="resolution">
			<xsl:apply-templates select="current()" mode="getImageResolution"/>
		</xsl:variable>

		<xsl:variable name="tableCell" select="ancestor::tableCell[1]"/>

		<xsl:variable name="maxGraphicWidth">
			<xsl:choose>
				<xsl:when test="$BlockType='GanzeBreite'">
					<xsl:value-of select="$WholeWidth"/>
				</xsl:when>
				<xsl:otherwise>
					<xsl:value-of select="$Indented"/>
				</xsl:otherwise>
			</xsl:choose>
		</xsl:variable>

		<xsl:variable name="maxGraphicHeight">
			<xsl:choose>
				<xsl:when test="number($P_maxHeight)">
					<xsl:value-of select="$P_maxHeight"/>
				</xsl:when>
				<xsl:when test="number($fHeight)">
					<xsl:value-of select="$fHeight"/>
				</xsl:when>
				<xsl:otherwise>
					<xsl:value-of select="840"/>
				</xsl:otherwise>
			</xsl:choose>
		</xsl:variable>

		<xsl:variable name="maxWidthPx">
			<xsl:choose>
				<xsl:when test="$tableCell">
					<xsl:for-each select="ancestor::tableCell[1]">
						<xsl:call-template name="getMediaTableCellWidth">
							<xsl:with-param name="cellPaddingMinifier" select="$cellPaddingMinifier"/>
							<xsl:with-param name="maxGraphicWidth" select="$maxGraphicWidth"/>
						</xsl:call-template>
					</xsl:for-each>
				</xsl:when>
				<xsl:otherwise>
					<xsl:value-of select="$maxGraphicWidth"/>
				</xsl:otherwise>
			</xsl:choose>
		</xsl:variable>

		<xsl:variable name="maxWidth" select="($maxWidthPx div $OUTPUT_RESOLUTION) * 25.4"/>
		<xsl:variable name="maxHeight" select="($maxGraphicHeight div $OUTPUT_RESOLUTION) * 25.4"/>

		<xsl:variable name="hasFixedDim" select="string-length(@fixedWidth) &gt; 0 or string-length(@fixedHeight) &gt; 0"/>
		
		<xsl:variable name="imageWidth">
			<xsl:choose>
				<xsl:when test="$hasFixedDim and string-length(@size-unit) &gt; 0">
					<xsl:call-template name="getPixels">
						<xsl:with-param name="value" select="concat(@width, @size-unit)"/>
						<xsl:with-param name="dpi" select="number(@resolution)"/>
					</xsl:call-template>
				</xsl:when>
				<xsl:otherwise>
					<xsl:value-of select="RefControl/File[@itemName = 'original']/MetaProperties/MetaProperty[@name = 'SMCIMG:width']/@value"/>
				</xsl:otherwise>
			</xsl:choose>
		</xsl:variable>

		<xsl:variable name="imageHeight">
			<xsl:choose>
				<xsl:when test="$hasFixedDim and string-length(@size-unit) &gt; 0">
					<xsl:call-template name="getPixels">
						<xsl:with-param name="value" select="concat(@height, @size-unit)"/>
						<xsl:with-param name="dpi" select="number(@resolution)"/>
					</xsl:call-template>
				</xsl:when>
				<xsl:otherwise>
					<xsl:value-of select="RefControl/File[@itemName = 'original']/MetaProperties/MetaProperty[@name = 'SMCIMG:height']/@value"/>
				</xsl:otherwise>
			</xsl:choose>
		</xsl:variable>
		
		<xsl:variable name="orig_width">
			<xsl:choose>
				<xsl:when test="$hasRotation">
					<xsl:value-of select="($imageHeight div $resolution) * 25.4"/>
				</xsl:when>
				<xsl:otherwise>
					<xsl:value-of select="($imageWidth div $resolution) * 25.4"/>
				</xsl:otherwise>
			</xsl:choose>
		</xsl:variable>
		<xsl:variable name="orig_height">
			<xsl:choose>
				<xsl:when test="$hasRotation">
					<xsl:value-of select="($imageWidth div $resolution) * 25.4"/>
				</xsl:when>
				<xsl:otherwise>
					<xsl:value-of select="($imageHeight div $resolution) * 25.4"/>
				</xsl:otherwise>
			</xsl:choose>
		</xsl:variable>

		<xsl:variable name="width">
			<xsl:call-template name="calcDimension">
				<xsl:with-param name="dimToCalc" select="number($orig_width)"/>
				<xsl:with-param name="dimToCalcMax" select="number($maxWidth)"/>
				<xsl:with-param name="secondDim" select="number($orig_height)"/>
				<xsl:with-param name="secondDimMax" select="number($maxHeight)"/>
			</xsl:call-template>
		</xsl:variable>

		<xsl:variable name="height">
			<xsl:call-template name="calcDimension">
				<xsl:with-param name="dimToCalc" select="number($orig_height)"/>
				<xsl:with-param name="dimToCalcMax" select="number($maxHeight)"/>
				<xsl:with-param name="secondDim" select="number($orig_width)"/>
				<xsl:with-param name="secondDimMax" select="number($maxWidth)"/>
			</xsl:call-template>
		</xsl:variable>

		<xsl:variable name="parentElemName">
			<xsl:choose>
				<xsl:when test="$isInline or parent::Headline.content or parent::InfoPar
						  or parent::EnumElement or parent::Label or parent::InfoItem.Warning or parent::result
						  or count(parent::Media/Media.theme[not(@Changed) or not($compareChangedImages = 'true')]) &gt; 1">
					<xsl:text>fo:inline</xsl:text>
				</xsl:when>
				<xsl:otherwise>
					<xsl:text>fo:block</xsl:text>
				</xsl:otherwise>
			</xsl:choose>
		</xsl:variable>

		<xsl:variable name="captionPosition">
			<xsl:call-template name="getTemplateVariableValue">
				<xsl:with-param name="name" select="'CAPTION_POSITION'"/>
				<xsl:with-param name="defaultValue" select="'BOTTOM'"/>
			</xsl:call-template>
		</xsl:variable>



		<!--<fo:block>
			width:<xsl:value-of select="$width"/>
		</fo:block>
		<fo:block>
			height:<xsl:value-of select="$height"/>
		</fo:block>

		<fo:block>origWidth:<xsl:value-of select="$orig_width"/></fo:block>
		<fo:block>origHeight:<xsl:value-of select="$orig_height"/></fo:block>-->

		<!--<fo:block><xsl:value-of select="$maxWidth"/></fo:block>-->
		<!--<fo:block><xsl:value-of select="@resolution"/></fo:block>-->

		<!--<fo:block><xsl:value-of select="$cmWidth"/></fo:block>
		<fo:block><xsl:value-of select="$cmHeight"/></fo:block>-->

		<xsl:if test="not(@isSWF) and RefControl/File">
			<xsl:if test="$parentElemName = 'fo:inline' and preceding-sibling::Media.theme and parent::Media">
				<fo:inline font-family="Arial">
					<xsl:choose>
						<xsl:when test="$isPDFXMODE">
							<xsl:attribute name="font-family">Arial</xsl:attribute>
						</xsl:when>
						<xsl:otherwise>
							<xsl:attribute name="font-family">
								<xsl:apply-templates select="current()" mode="getDefaultFont"/>
							</xsl:attribute>
						</xsl:otherwise>
					</xsl:choose>
					<xsl:call-template name="addStyle">
						<xsl:with-param name="name">media.theme.separator</xsl:with-param>
					</xsl:call-template>
					<xsl:text>&#8203;</xsl:text>
				</fo:inline>
			</xsl:if>
			
				
			
			<xsl:if test="$writeCaption  and $captionPosition='TOP'">
				<xsl:apply-templates select="current()" mode="writeMediaCaption">
					<xsl:with-param name="position">outer</xsl:with-param>
				</xsl:apply-templates>
			</xsl:if>			
			
			<xsl:element name="{$parentElemName}">
				<xsl:if test="string-length(@align) &gt; 0">
					<xsl:attribute name="text-align">
						<xsl:value-of select="@align"/>
					</xsl:attribute>
				</xsl:if>
				<xsl:if test="$parentElemName = 'fo:block' and @isFormula">
					<xsl:call-template name="addStyle">
						<xsl:with-param name="name">block-level-element</xsl:with-param>
					</xsl:call-template>
				</xsl:if>
				<xsl:call-template name="addStyle">
					<xsl:with-param name="name" select="$formatElement"/>
				</xsl:call-template>
				<xsl:if test="parent::Media/parent::tableCell">
					<xsl:call-template name="addStyle">
						<xsl:with-param name="name" select="concat('table.cell.', $formatElement)"/>
					</xsl:call-template>
				</xsl:if>

				<xsl:apply-templates select="current()" mode="writeCharacterizationInfo">
					<xsl:with-param name="bPadding" select="true()"/>
					<xsl:with-param name="isInline" select="$parentElemName = 'fo:inline'"/>
				</xsl:apply-templates>

				<xsl:if test="string-length(@ID) &gt; 0">
					<xsl:apply-templates select="current()" mode="writeDestination"/>
				</xsl:if>

				<xsl:if test="$writeCaption and $captionPosition='TOP'">
					<xsl:apply-templates select="current()" mode="writeMediaCaption">
						<xsl:with-param name="position">inner</xsl:with-param>
					</xsl:apply-templates>
				</xsl:if>


				<xsl:choose>
					<xsl:when test="$isLeftCaption">
						<fo:table table-layout="fixed">
							<xsl:call-template name="addStyle">
								<xsl:with-param name="name">media.table</xsl:with-param>
							</xsl:call-template>
							<xsl:call-template name="generateLegendColumns">
								<xsl:with-param name="colCount" select="1"/>
								<xsl:with-param name="legendCol1">
									<xsl:call-template name="getTemplateVariableValue">
										<xsl:with-param name="name" select="'MEDIA_COL1'"/>
										<xsl:with-param name="defaultValue" select="$MEDIA_COL1_DEFAULT_VALUE"/>
									</xsl:call-template>
								</xsl:with-param>
								<xsl:with-param name="legendCol2">
									<xsl:call-template name="getTemplateVariableValue">
										<xsl:with-param name="name" select="'MEDIA_COL2'"/>
										<xsl:with-param name="defaultValue" select="$MEDIA_COL2_DEFAULT_VALUE"/>
									</xsl:call-template>
								</xsl:with-param>
								<xsl:with-param name="legendCol3">
									<xsl:call-template name="getTemplateVariableValue">
										<xsl:with-param name="name" select="'MEDIA_COL3'"/>
										<xsl:with-param name="defaultValue">*</xsl:with-param>
									</xsl:call-template>
								</xsl:with-param>
							</xsl:call-template>
							<fo:table-body>
								<fo:table-row>
									<fo:table-cell>
										<xsl:call-template name="addStyle">
											<xsl:with-param name="name">media.cell.1</xsl:with-param>
										</xsl:call-template>
										<xsl:apply-templates select="current()" mode="writeMediaCaption">
											<xsl:with-param name="position">left</xsl:with-param>
										</xsl:apply-templates>
									</fo:table-cell>
									<fo:table-cell>
										<xsl:call-template name="addStyle">
											<xsl:with-param name="name">media.cell.2</xsl:with-param>
										</xsl:call-template>
										<fo:block/>
									</fo:table-cell>
									<fo:table-cell>
										<xsl:call-template name="addStyle">
											<xsl:with-param name="name">media.cell.3</xsl:with-param>
										</xsl:call-template>
										<fo:block>
											<xsl:apply-templates select="current()" mode="writeGraphic">
												<xsl:with-param name="height" select="$height"/>
												<xsl:with-param name="maxHeight" select="$maxHeight"/>
												<xsl:with-param name="maxWidth" select="$maxWidth"/>
												<xsl:with-param name="origWidth" select="$orig_width"/>
												<xsl:with-param name="width" select="$width"/>
												<xsl:with-param name="hasRotation" select="$hasRotation"/>
												<xsl:with-param name="refOrient" select="$refOrient"/>
											</xsl:apply-templates>
										</fo:block>
									</fo:table-cell>
								</fo:table-row>
							</fo:table-body>
						</fo:table>
					</xsl:when>
					<xsl:otherwise>
						<xsl:apply-templates select="current()" mode="writeGraphic">
							<xsl:with-param name="height" select="$height"/>
							<xsl:with-param name="maxHeight" select="$maxHeight"/>
							<xsl:with-param name="maxWidth" select="$maxWidth"/>
							<xsl:with-param name="origWidth" select="$orig_width"/>
							<xsl:with-param name="width" select="$width"/>
							<xsl:with-param name="hasRotation" select="$hasRotation"/>
							<xsl:with-param name="refOrient" select="$refOrient"/>
						</xsl:apply-templates>
					</xsl:otherwise>
				</xsl:choose>



				<xsl:if test="$writeCaption and $captionPosition='BOTTOM'">
					<xsl:apply-templates select="current()" mode="writeMediaCaption">
						<xsl:with-param name="position">inner</xsl:with-param>
					</xsl:apply-templates>
				</xsl:if>
			</xsl:element>
			<xsl:if test="$writeCaption  and $captionPosition='BOTTOM'">
				<xsl:apply-templates select="current()" mode="writeMediaCaption">
					<xsl:with-param name="position">outer</xsl:with-param>
				</xsl:apply-templates>
			</xsl:if>
		</xsl:if>
	</xsl:template>

	<xsl:template match="Media.theme" mode="writeGraphic">
		<xsl:param name="width"/>
		<xsl:param name="height"/>
		<xsl:param name="origWidth"/>
		<xsl:param name="maxWidth"/>
		<xsl:param name="maxHeight"/>
		<xsl:param name="hasRotation"/>
		<xsl:param name="refOrient"/>
		
		<xsl:choose>
			<xsl:when test="$hasRotation">
				<fo:block-container reference-orientation="{$refOrient}" width="{$height}mm">
					<fo:block>
						<xsl:apply-templates select="current()" mode="writeGraphicsElement">
							<xsl:with-param name="height" select="$width"/>
							<xsl:with-param name="maxHeight" select="$maxHeight"/>
							<xsl:with-param name="maxWidth" select="$maxWidth"/>
							<xsl:with-param name="origWidth" select="$origWidth"/>
							<xsl:with-param name="width" select="$height"/>
						</xsl:apply-templates>
					</fo:block>
				</fo:block-container>
			</xsl:when>
			<xsl:otherwise>
				<xsl:apply-templates select="current()" mode="writeGraphicsElement">
					<xsl:with-param name="height" select="$height"/>
					<xsl:with-param name="maxHeight" select="$maxHeight"/>
					<xsl:with-param name="maxWidth" select="$maxWidth"/>
					<xsl:with-param name="origWidth" select="$origWidth"/>
					<xsl:with-param name="width" select="$width"/>
				</xsl:apply-templates>
			</xsl:otherwise>
		</xsl:choose>
	</xsl:template>

	<xsl:template match="Media.theme" mode="writeGraphicsElement">
		<xsl:param name="width"/>
		<xsl:param name="height"/>
		<xsl:param name="origWidth"/>
		<xsl:param name="maxWidth"/>
		<xsl:param name="maxHeight"/>

		<xsl:choose>
			<xsl:when test="RefControl/@objType = 'mathml' and RefControl/substitute/m:math" xmlns:m="http://www.w3.org/1998/Math/MathML">
				<fo:instream-foreign-object content-width="scale-to-fit" max-width="100%">
					<xsl:call-template name="addStyle">
						<xsl:with-param name="name">formula.graphic</xsl:with-param>
					</xsl:call-template>
					<!-- <xsl:copy-of select="RefControl/substitute[m:math][1]/m:math[1]"/>  -->
					<xsl:variable name="inline">
						<xsl:value-of select = "@inline"/>
					</xsl:variable>
					<xsl:for-each select = "RefControl/substitute[m:math][1]/m:math[1]">
						<xsl:copy>
							<xsl:copy-of select = "@*"/>
							<xsl:choose>
								<xsl:when test = "$inline='true'">
									<xsl:attribute name="mode">inline</xsl:attribute>
								</xsl:when>
								<xsl:otherwise>
									<xsl:attribute name="mode">display</xsl:attribute>
								</xsl:otherwise>
							</xsl:choose>
							<xsl:copy-of select = "*"/>
						</xsl:copy>
					</xsl:for-each>
					
					
				</fo:instream-foreign-object>
			</xsl:when>
			<xsl:when test="RefControl/substitute/svg:svg" xmlns:svg="http://www.w3.org/2000/svg">
				<fo:instream-foreign-object>
					<xsl:choose>
						<xsl:when test="@inline">
							<xsl:call-template name="addStyle">
								<xsl:with-param name="name">media.theme.graphic</xsl:with-param>
							</xsl:call-template>
							<xsl:variable name="verticalAlign">
								<xsl:call-template name="getFormat">
									<xsl:with-param name="name">media.theme.graphic</xsl:with-param>
									<xsl:with-param name="attributeName">vertical-align</xsl:with-param>
								</xsl:call-template>
							</xsl:variable>
							<xsl:choose>
								<xsl:when test="$verticalAlign = 'center'">
									<xsl:attribute name="alignment-adjust">middle</xsl:attribute>
								</xsl:when>
								<xsl:otherwise>
									<xsl:attribute name="alignment-adjust">auto</xsl:attribute>
								</xsl:otherwise>
							</xsl:choose>
						</xsl:when>
						<xsl:otherwise>
							<xsl:call-template name="addStyle">
								<xsl:with-param name="name">media.graphic</xsl:with-param>
							</xsl:call-template>
						</xsl:otherwise>
					</xsl:choose>
					<xsl:if test="number($width)">
						<xsl:attribute name="width">
							<xsl:value-of select="concat($width, 'mm')"/>
						</xsl:attribute>
						<xsl:attribute name="height">
							<xsl:value-of select="concat($height, 'mm')"/>
						</xsl:attribute>
						<xsl:attribute name="content-width">scale-to-fit</xsl:attribute>
					</xsl:if>
					<xsl:if test="string-length(@ID) &gt; 0">
						<xsl:attribute name="id">
							<xsl:value-of select="@ID"/>
						</xsl:attribute>
					</xsl:if>
					<xsl:apply-templates select="RefControl/substitute/svg:svg" mode="svg"/>
				</fo:instream-foreign-object>
			</xsl:when>
			<xsl:otherwise>
				<xsl:variable name="picURL">
					<xsl:call-template name="getPicURL"/>
				</xsl:variable>
				<xsl:if test="string-length($picURL) &gt; 0">
					<fo:external-graphic src="url('{$picURL}')">
						<xsl:attribute name="max-width">100%</xsl:attribute>
						<xsl:if test="string-length($origWidth) = 0">
							<xsl:attribute name="content-width">scale-to-fit</xsl:attribute>
						</xsl:if>
						<xsl:variable name="fixedWidth">
							<xsl:choose>
								<xsl:when test="string-length(@formatRef) &gt; 0">
									<xsl:call-template name="getFormat">
										<xsl:with-param name="name" select="@formatRef"/>
										<xsl:with-param name="attributeName">width</xsl:with-param>
									</xsl:call-template>
								</xsl:when>
								<xsl:when test="string-length(@style) &gt; 0">
									<xsl:call-template name="getFormat">
										<xsl:with-param name="name" select="@style"/>
										<xsl:with-param name="attributeName">width</xsl:with-param>
									</xsl:call-template>
								</xsl:when>
							</xsl:choose>
						</xsl:variable>
						<xsl:if test="number($width)">
							<xsl:choose>
								<!-- this might not always work correctly -->
								<xsl:when test="$origWidth &gt; $maxWidth and ancestor::InfoPar.Warning">
									<xsl:attribute name="max-width">100%</xsl:attribute>
									<xsl:attribute name="max-height">
										<xsl:value-of select="concat($maxHeight, 'mm')"/>
									</xsl:attribute>
								</xsl:when>
								<xsl:otherwise>
									<xsl:attribute name="width">
										<xsl:value-of select="concat($width, 'mm')"/>
									</xsl:attribute>
									<xsl:if test="not(@fileType = 'pdf' or string-length($fixedWidth) &gt; 0)">
										<xsl:attribute name="height">
											<xsl:value-of select="concat($height, 'mm')"/>
										</xsl:attribute>
									</xsl:if>
								</xsl:otherwise>
							</xsl:choose>
							<xsl:attribute name="content-width">scale-to-fit</xsl:attribute>
						</xsl:if>
						<xsl:choose>
							<xsl:when test="@inline">
								<xsl:call-template name="addStyle">
									<xsl:with-param name="name">media.theme.graphic</xsl:with-param>
								</xsl:call-template>
								<xsl:variable name="verticalAlign">
									<xsl:call-template name="getFormat">
										<xsl:with-param name="name">media.theme.graphic</xsl:with-param>
										<xsl:with-param name="attributeName">vertical-align</xsl:with-param>
									</xsl:call-template>
								</xsl:variable>
								<xsl:choose>
									<xsl:when test="$verticalAlign = 'center'">
										<xsl:attribute name="alignment-adjust">middle</xsl:attribute>
									</xsl:when>
									<xsl:otherwise>
										<xsl:attribute name="alignment-adjust">auto</xsl:attribute>
									</xsl:otherwise>
								</xsl:choose>
							</xsl:when>
							<xsl:otherwise>
								<xsl:call-template name="addStyle">
									<xsl:with-param name="name">media.graphic</xsl:with-param>
								</xsl:call-template>
							</xsl:otherwise>
						</xsl:choose>
						<xsl:if test="string-length(@ID) &gt; 0">
							<xsl:attribute name="id">
								<xsl:value-of select="@ID"/>
							</xsl:attribute>
						</xsl:if>
						<xsl:if test="string-length(@style) &gt; 0">
							<xsl:call-template name="addStyle">
								<xsl:with-param name="name" select="@style"/>
							</xsl:call-template>
						</xsl:if>
						<xsl:if test="string-length(@formatRef) &gt; 0">
							<xsl:call-template name="addStyle">
								<xsl:with-param name="name" select="@formatRef"/>
							</xsl:call-template>
						</xsl:if>
					</fo:external-graphic>
				</xsl:if>
			</xsl:otherwise>
		</xsl:choose>
	</xsl:template>

	<xsl:template name="getMediaTableCellWidth">
		<xsl:param name="cellPaddingMinifier" select="0"/>
		<xsl:param name="maxGraphicWidth"/>

		<xsl:variable name="currentRow" select="count(parent::tableRow/preceding-sibling::tableRow)"/>
		<xsl:variable name="currentColPre" select="count(preceding-sibling::tableCell[not(@hstraddle)]) + sum(preceding-sibling::tableCell/@hstraddle) + 1"/>
		<xsl:variable name="currentCol">
			<xsl:choose>
				<xsl:when test="@idx">
					<xsl:value-of select="@idx + 1"/>
				</xsl:when>
				<xsl:when test="parent::tableRow/preceding-sibling::tableRow
						  [tableCell[position() &lt;= $currentColPre]/@morerows + count(preceding-sibling::tableRow) &gt;= $currentRow]">
					<xsl:value-of select="$currentColPre + 1"/>
				</xsl:when>
				<xsl:otherwise>
					<xsl:value-of select="$currentColPre"/>
				</xsl:otherwise>
			</xsl:choose>
		</xsl:variable>

		<xsl:variable name="preColSpan" select="number(@hstraddle)"/>
		<xsl:variable name="colSpan">
			<xsl:choose>
				<xsl:when test="string(@hstraddle) != 'NaN'">
					<xsl:value-of select="@hstraddle"/>
				</xsl:when>
				<xsl:otherwise>0</xsl:otherwise>
			</xsl:choose>
		</xsl:variable>

		<xsl:variable name="colSpecElem" select="ancestor::*[name() = 'table' or name() = 'table.NoBorder'][1]/following::TableDesc[1]/TableColSpec[number($currentCol)]"/>

		<xsl:variable name="colWidth">
			<xsl:choose>
				<xsl:when test="string(number($colSpan)) != 'NaN' and $colSpan &gt; 0">
					<xsl:value-of select="sum(ancestor::*[name() = 'table' or name() = 'table.NoBorder'][1]/following::TableDesc[1]/TableColSpec[position() &gt;= $currentCol and position() &lt; ($currentCol + $colSpan)]/@width)"/>
				</xsl:when>
				<xsl:when test="$colSpecElem/@width = '*'">
					<xsl:variable name="cols">
						<xsl:for-each select="$colSpecElem/parent::*/TableColSpec[@width != '*']">
							<col>
								<xsl:call-template name="getPixels">
									<xsl:with-param name="value" select="@width"/>
									<xsl:with-param name="dpi" select="$OUTPUT_RESOLUTION"/>
								</xsl:call-template>
							</col>
						</xsl:for-each>
					</xsl:variable>
					<!--<xsl:value-of select="$maxGraphicWidth - sum(exslt:node-set($cols)/col)"/>-->
					<xsl:value-of select="$maxGraphicWidth - sum($colSpecElem/parent::*/TableColSpec[string(number(@width)) != 'NaN']/@width)"/>
					<xsl:text>px</xsl:text>
				</xsl:when>
				<xsl:otherwise>
					<xsl:value-of select="translate($colSpecElem/@width, ',', '.')"/>
				</xsl:otherwise>
			</xsl:choose>
		</xsl:variable>

		<xsl:variable name="colWidthPx">
			<xsl:call-template name="getPixels">
				<xsl:with-param name="value" select="$colWidth"/>
				<xsl:with-param name="dpi" select="$OUTPUT_RESOLUTION"/>
			</xsl:call-template>
		</xsl:variable>

		<xsl:variable name="paddingLeft">
			<xsl:choose>
				<xsl:when test="$cellPaddingMinifier &gt; 0">
					<xsl:value-of select="$cellPaddingMinifier div 2"/>
				</xsl:when>
				<xsl:when test="name(ancestor::*[name() = 'table' or name() = 'table.NoBorder'][1]) = 'table'">
					<xsl:call-template name="getPixels">
						<xsl:with-param name="value">
							<xsl:call-template name="getFormat">
								<xsl:with-param name="name">table.cell</xsl:with-param>
								<xsl:with-param name="attributeName">padding-left</xsl:with-param>
								<xsl:with-param name="defaultValue">
									<xsl:call-template name="getFormat">
										<xsl:with-param name="name">table.cell</xsl:with-param>
										<xsl:with-param name="attributeName">padding</xsl:with-param>
									</xsl:call-template>
								</xsl:with-param>
							</xsl:call-template>
						</xsl:with-param>
						<xsl:with-param name="dpi" select="$OUTPUT_RESOLUTION"/>
					</xsl:call-template>
				</xsl:when>
				<xsl:otherwise>
					<xsl:call-template name="getPixels">
						<xsl:with-param name="value">
							<xsl:call-template name="getFormat">
								<xsl:with-param name="name">table.nolines.cell</xsl:with-param>
								<xsl:with-param name="attributeName">padding-left</xsl:with-param>
								<xsl:with-param name="defaultValue">
									<xsl:call-template name="getFormat">
										<xsl:with-param name="name">table.nolines.cell</xsl:with-param>
										<xsl:with-param name="attributeName">padding</xsl:with-param>
									</xsl:call-template>
								</xsl:with-param>
							</xsl:call-template>
						</xsl:with-param>
						<xsl:with-param name="dpi" select="$OUTPUT_RESOLUTION"/>
					</xsl:call-template>
				</xsl:otherwise>
			</xsl:choose>
		</xsl:variable>

		<xsl:variable name="paddingRight">
			<xsl:choose>
				<xsl:when test="$cellPaddingMinifier &gt; 0">
					<xsl:value-of select="$cellPaddingMinifier div 2"/>
				</xsl:when>
				<xsl:when test="name(ancestor::*[name() = 'table' or name() = 'table.NoBorder'][1]) = 'table'">
					<xsl:call-template name="getPixels">
						<xsl:with-param name="value">
							<xsl:call-template name="getFormat">
								<xsl:with-param name="name">table.cell</xsl:with-param>
								<xsl:with-param name="attributeName">padding-right</xsl:with-param>
								<xsl:with-param name="defaultValue">
									<xsl:call-template name="getFormat">
										<xsl:with-param name="name">table.cell</xsl:with-param>
										<xsl:with-param name="attributeName">padding</xsl:with-param>
									</xsl:call-template>
								</xsl:with-param>
							</xsl:call-template>
						</xsl:with-param>
						<xsl:with-param name="dpi" select="$OUTPUT_RESOLUTION"/>
					</xsl:call-template>
				</xsl:when>
				<xsl:otherwise>
					<xsl:call-template name="getPixels">
						<xsl:with-param name="value">
							<xsl:call-template name="getFormat">
								<xsl:with-param name="name">table.nolines.cell</xsl:with-param>
								<xsl:with-param name="attributeName">padding-right</xsl:with-param>
								<xsl:with-param name="defaultValue">
									<xsl:call-template name="getFormat">
										<xsl:with-param name="name">table.nolines.cell</xsl:with-param>
										<xsl:with-param name="attributeName">padding</xsl:with-param>
									</xsl:call-template>
								</xsl:with-param>
							</xsl:call-template>
						</xsl:with-param>
						<xsl:with-param name="dpi" select="$OUTPUT_RESOLUTION"/>
					</xsl:call-template>
				</xsl:otherwise>
			</xsl:choose>
		</xsl:variable>

		<xsl:variable name="maxTableWidth">
			<xsl:choose>
				<xsl:when test="ancestor::tableCell">
					<xsl:for-each select="ancestor::tableCell[1]">
						<xsl:call-template name="getMediaTableCellWidth">
							<xsl:with-param name="maxGraphicWidth" select="$maxGraphicWidth"/>
							<xsl:with-param name="cellPaddingMinifier" select="$cellPaddingMinifier"/>
						</xsl:call-template>
					</xsl:for-each>
				</xsl:when>
				<xsl:otherwise>
					<xsl:value-of select="$maxGraphicWidth"/>
				</xsl:otherwise>
			</xsl:choose>
		</xsl:variable>

		<xsl:choose>
			<xsl:when test="string(number($colWidth)) = 'NaN' and string(number($colWidthPx)) != 'NaN' and $colWidthPx &gt; 0">
				<xsl:value-of select="$colWidthPx - $paddingLeft - $paddingRight"/>
			</xsl:when>
			<xsl:when test="$cellPaddingMinifier &gt; 0">
				<xsl:value-of select="($colWidth div (100 + $cellPaddingMinifier)) * $maxTableWidth"/>
			</xsl:when>
			<xsl:otherwise>
				<xsl:value-of select="($colWidth div 100) * $maxTableWidth - $paddingLeft - $paddingRight"/>
			</xsl:otherwise>
		</xsl:choose>

	</xsl:template>

	<xsl:template match="Media.theme" mode="writeMediaCaption">
		<xsl:param name="position">inner</xsl:param>

		<xsl:variable name="captionPosition">
			<xsl:call-template name="getTemplateVariableValue">
				<xsl:with-param name="name" select="'MEDIA_CAPTION_POSITION'"/>
				<xsl:with-param name="defaultValue">
					<xsl:choose>
						<xsl:when test="$compareChangedImages = 'true'">outer</xsl:when>
						<xsl:otherwise>inner</xsl:otherwise>
					</xsl:choose>
				</xsl:with-param>
			</xsl:call-template>
		</xsl:variable>

		<xsl:variable name="legendPosition">
			<xsl:call-template name="getTemplateVariableValue">
				<xsl:with-param name="name" select="'MEDIA_LEGEND_POSITION'"/>
				<xsl:with-param name="defaultValue">outer</xsl:with-param>
			</xsl:call-template>
		</xsl:variable>

		<xsl:if test="$position = $captionPosition and not(@isFormula)">

			<xsl:if test="$legendPosition = 'inner'">
				<xsl:if test="legend/legend.row">
					<xsl:apply-templates select="legend" mode="media"/>
				</xsl:if>
			</xsl:if>

			<xsl:variable name="alwaysShowMediaCaption">
				<xsl:call-template name="getTemplateVariableValue">
					<xsl:with-param name="name" select="'MEDIA_CAPTION_SHOW_ALWAYS'"/>
					<xsl:with-param name="defaultValue">false</xsl:with-param>
				</xsl:call-template>
			</xsl:variable>



			<xsl:if test="media.code">
				<xsl:apply-templates select="current()" mode="writeMediaCode"/>
			</xsl:if>


			<xsl:variable name="hasCaption" select="string-length(InfoPar.Subtitle) &gt; 0"/>
			<xsl:if test="$hasCaption or $alwaysShowMediaCaption = 'true'">
				<xsl:apply-templates select="current()" mode="writeMediaSubtitle">
					<xsl:with-param name="hasCaption" select="$hasCaption"/>
				</xsl:apply-templates>
			</xsl:if>

			<xsl:if test="$legendPosition = 'outer'">
				<xsl:if test="legend/legend.row">
					<xsl:apply-templates select="legend" mode="media"/>
				</xsl:if>
			</xsl:if>

		</xsl:if>
	</xsl:template>

	<xsl:template match="Media.theme" mode="writeMediaCode">
		<fo:block keep-with-previous="always">
			<xsl:call-template name="addStyle">
				<xsl:with-param name="name">media.code</xsl:with-param>
			</xsl:call-template>
			<xsl:apply-templates select="media.code"/>
		</fo:block>
	</xsl:template>
	

	<xsl:template match="Media.theme" mode="writeMediaSubtitle">
		<xsl:param name="hasCaption" select="string-length(InfoPar.Subtitle) &gt; 0"/>
		<xsl:variable name="displayTypePre">
			<xsl:call-template name="getTemplateVariableValue">
				<xsl:with-param name="name" select="'MEDIA_CAPTION_DISPLAY_TYPE'"/>
				<xsl:with-param name="defaultValue">
					<xsl:apply-templates select="current()" mode="getDefaultDisplayType"/>
				</xsl:with-param>
			</xsl:call-template>
		</xsl:variable>
		<xsl:variable name="autoNumber" select="not(parent::Media[@notAutoNumber = 'true'])"/>
		<xsl:variable name="displayType">
		<xsl:choose>
				<xsl:when test="not($autoNumber)">
					<xsl:call-template name="getTemplateVariableValue">
						<xsl:with-param name="name" select="'MEDIA_CAPTION_NOT_AUTO_NUMBER_DISPLAY_TYPE'"/>
						<xsl:with-param name="defaultValue" select="$displayTypePre"/>
					</xsl:call-template>
				</xsl:when>
				<xsl:otherwise>
					<xsl:value-of select="$displayTypePre"/>
				</xsl:otherwise>
			</xsl:choose>
		</xsl:variable>
		<xsl:choose>
			<xsl:when test="$displayType = 'numbered'">
				<xsl:apply-templates select="current()" mode="writeMediaSubtitleNumbered">
					<xsl:with-param name="hasCaption" select="$hasCaption"/>
					<xsl:with-param name="autoNumber" select="$autoNumber"/>
				</xsl:apply-templates>
			</xsl:when>
			<xsl:when test="$displayType = 'numbered-and-indent'">
				<xsl:apply-templates select="current()" mode="writeMediaSubtitleNumbered">
					<xsl:with-param name="useListBlock" select="true()"/>
					<xsl:with-param name="hasCaption" select="$hasCaption"/>
					<xsl:with-param name="autoNumber" select="$autoNumber"/>
				</xsl:apply-templates>
			</xsl:when>
			<xsl:when test="$displayType = 'numbered-with-chapter'">
				<xsl:apply-templates select="current()" mode="writeMediaSubtitleNumberedWithChapter">
					<xsl:with-param name="hasCaption" select="$hasCaption"/>
				<xsl:with-param name="autoNumber" select="$autoNumber"/>
				</xsl:apply-templates>
			</xsl:when>
			<xsl:when test="$displayType = 'fixtext'">
				<xsl:apply-templates select="current()" mode="writeMediaSubtitleSimple">
					<xsl:with-param name="hasCaption" select="$hasCaption"/>
					<xsl:with-param name="autoNumber" select="$autoNumber"/>
					<xsl:with-param name="showFixText" select="true()"/>
				</xsl:apply-templates>
			</xsl:when>
			<xsl:otherwise>
				<xsl:apply-templates select="current()" mode="writeMediaSubtitleSimple">
					<xsl:with-param name="hasCaption" select="$hasCaption"/>
					<xsl:with-param name="autoNumber" select="$autoNumber"/>
				</xsl:apply-templates>
			</xsl:otherwise>
		</xsl:choose>
	</xsl:template>

	<xsl:template match="Media.theme" mode="getDefaultDisplayType">simple</xsl:template>

	<xsl:template match="Media.theme" mode="writeMediaSubtitleSimple">
		<xsl:param name="hasCaption"/>
		<xsl:param name="showFixText" select="false()"/>
		<fo:block keep-with-previous="always">
			<xsl:call-template name="addStyle">
				<xsl:with-param name="name">mediasubtitle</xsl:with-param>
			</xsl:call-template>
			<xsl:call-template name="addStyle">
				<xsl:with-param name="name">media.caption</xsl:with-param>
			</xsl:call-template>
			<xsl:if test="InfoPar.Subtitle">
				<xsl:call-template name="addStyle">
					<xsl:with-param name="name">media.caption</xsl:with-param>
					<xsl:with-param name="currentElement" select="InfoPar.Subtitle"/>
				</xsl:call-template>
			</xsl:if>

			<xsl:if test="$showFixText">
				<xsl:call-template name="translate">
					<xsl:with-param name="ID">Image</xsl:with-param>
				</xsl:call-template>
			</xsl:if>

			<xsl:if test="$hasCaption">
				<xsl:if test="$showFixText">
					<xsl:text>: </xsl:text>
				</xsl:if>
				<xsl:apply-templates select="InfoPar.Subtitle"/>
			</xsl:if>
		</fo:block>
	</xsl:template>

	<!--<xsl:variable name="IMAGE_COUNTER_MAP" select="map:new()"/>-->

	<xsl:template name="getMediaNumber">
		<xsl:param name="autoNumber"/>
		<xsl:variable name="restart">
			<xsl:call-template name="getTemplateVariableValue">
				<xsl:with-param name="name">MEDIA_NR_RESTART_WITH_LANGUAGE_CHANGE</xsl:with-param>
				<xsl:with-param name="defaultValue">false</xsl:with-param>
			</xsl:call-template>
		</xsl:variable>
		<xsl:variable name="key">
			<xsl:choose>
				<xsl:when test="$restart = 'true'">
					<xsl:call-template name="getCurrentLanguage"/>
				</xsl:when>
				<xsl:otherwise>neutral</xsl:otherwise>
			</xsl:choose>
		</xsl:variable>
		<!--<xsl:if test="string(map:containsKey($IMAGE_COUNTER_MAP, string($key))) = 'false'">
			<xsl:variable name="addKey" select="map:put($IMAGE_COUNTER_MAP, string($key), list:new())"/>
		</xsl:if>-->
		<!--<xsl:variable name="IMAGE_COUNTER" select="map:get($IMAGE_COUNTER_MAP, string($key))"/>-->
		<xsl:variable name="IMAGE_COUNTER" select="count(preceding::Media.theme)"/>
		<xsl:variable name="baseCounter" select="number(/*/Navigation/@incrementalMediaCount)"/>
		<xsl:if test="$autoNumber">
			<!--<xsl:if test="list:indexOf($IMAGE_COUNTER, generate-id()) = '-1'">
				<xsl:variable name="add" select="list:add($IMAGE_COUNTER, generate-id())"/>
			</xsl:if>-->
		</xsl:if>
		<xsl:choose>
			<xsl:when test="string($baseCounter) != 'NaN'">
				<xsl:value-of select="$IMAGE_COUNTER + 1 + $baseCounter"/>
			</xsl:when>
			<xsl:otherwise>
				<xsl:value-of select="$IMAGE_COUNTER + 1"/>
			</xsl:otherwise>
		</xsl:choose>
	</xsl:template>

	<xsl:template match="Media.theme" mode="writeMediaSubtitleNumbered">
		<xsl:param name="useListBlock" select="false()"/>
		<xsl:param name="listSeparator">
			<xsl:if test="$language = 'fr'">
				<xsl:text> </xsl:text>
			</xsl:if>
			<xsl:call-template name="getTemplateVariableValue">
				<xsl:with-param name="name" select="'MEDIA_CAPTION_SEPARATOR'"/>
				<xsl:with-param name="defaultValue">:</xsl:with-param>
			</xsl:call-template>
		</xsl:param>
		<xsl:param name="hasCaption" select="string-length(InfoPar.Subtitle) &gt; 0"/>
		<xsl:param name="nrPrefix"/>
		<xsl:param name="autoNumber" select="not(parent::Media[@notAutoNumber = 'true'])"/>

		<xsl:variable name="useFixtext">
			<xsl:call-template name="getTemplateVariableValue">
				<xsl:with-param name="name" select="'MEDIA_CAPTION_USE_FIXTEXT'"/>
			</xsl:call-template>
		</xsl:variable>
		
		<xsl:variable name="imageCount">
			<xsl:call-template name="getMediaNumber">
				<xsl:with-param name="autoNumber" select="$autoNumber"/>
			</xsl:call-template>
		</xsl:variable>

		<fo:block keep-with-previous="always">
			<xsl:call-template name="addStyle">
				<xsl:with-param name="name">media.caption</xsl:with-param>
			</xsl:call-template>
			<xsl:if test="InfoPar.Subtitle">
				<xsl:call-template name="addStyle">
					<xsl:with-param name="name">media.caption</xsl:with-param>
					<xsl:with-param name="currentElement" select="InfoPar.Subtitle"/>
				</xsl:call-template>
			</xsl:if>
			<xsl:choose>
				<xsl:when test="$useListBlock">
					<xsl:variable name="MEDIA_CAPTION_INDENT">
						<xsl:call-template name="getTemplateVariableValue">
							<xsl:with-param name="name" select="concat('MEDIA_CAPTION_INDENT_', $language)"/>
							<xsl:with-param name="defaultValue">
								<xsl:call-template name="getTemplateVariableValue">
									<xsl:with-param name="name" select="'MEDIA_CAPTION_INDENT'"/>
									<xsl:with-param name="defaultValue">24mm</xsl:with-param>
								</xsl:call-template>
							</xsl:with-param>
						</xsl:call-template>
					</xsl:variable>
					<fo:list-block provisional-distance-between-starts="{$MEDIA_CAPTION_INDENT}">
						<fo:list-item>
							<fo:list-item-label end-indent="label-end()">
								<fo:block>
									<xsl:if test="not($useFixtext = 'false')">
										<xsl:call-template name="translate">
											<xsl:with-param name="ID">Image</xsl:with-param>
										</xsl:call-template>
										<xsl:if test="$autoNumber">
											<xsl:text> </xsl:text>
										</xsl:if>
									</xsl:if>

									<xsl:if test="$autoNumber">
										<xsl:value-of select="concat($nrPrefix, $imageCount)"/>
									</xsl:if>
									<xsl:if test="$hasCaption">
										<xsl:value-of select="$listSeparator"/>
									</xsl:if>
								</fo:block>
							</fo:list-item-label>
							<fo:list-item-body start-indent="body-start()">
								<fo:block>
									<xsl:if test="$hasCaption">
										<xsl:apply-templates select="InfoPar.Subtitle"/>
									</xsl:if>
								</fo:block>
							</fo:list-item-body>
						</fo:list-item>
					</fo:list-block>
				</xsl:when>
				<xsl:otherwise>
					<xsl:if test="not($useFixtext = 'false')">
						<xsl:call-template name="translate">
							<xsl:with-param name="ID">
								<xsl:apply-templates select="current()" mode="getDefaultFixtext"/>
							</xsl:with-param>
						</xsl:call-template>
						<xsl:if test="$autoNumber">
							<xsl:text> </xsl:text>
						</xsl:if>
					</xsl:if>

					<xsl:if test="$autoNumber">
						<xsl:value-of select="concat($nrPrefix, $imageCount)"/>
					</xsl:if>
					<xsl:if test="$hasCaption">
						<xsl:value-of select="concat($listSeparator, ' ')"/>
						<xsl:apply-templates select="InfoPar.Subtitle"/>
					</xsl:if>
				</xsl:otherwise>
			</xsl:choose>
		</fo:block>
	</xsl:template>

	<xsl:template match="Media.theme" mode="getDefaultFixtext">Image</xsl:template>

	<!--<xsl:variable name="CURRENT_IMAGE_CHAPTER" select="list:new()"/>-->

	<xsl:template match="Media.theme" mode="writeMediaSubtitleNumberedWithChapter">
		<xsl:param name="useListBlock" select="false()"/>
		<xsl:param name="separator">-</xsl:param>
		<xsl:param name="listSeparator">
			<xsl:if test="$language = 'fr'">
				<xsl:text> </xsl:text>
			</xsl:if>
			<xsl:call-template name="getTemplateVariableValue">
				<xsl:with-param name="name" select="'MEDIA_CAPTION_SEPARATOR'"/>
				<xsl:with-param name="defaultValue">:</xsl:with-param>
			</xsl:call-template>
		</xsl:param>
		<xsl:param name="hasCaption" select="string-length(InfoPar.Subtitle) &gt; 0"/>
		<xsl:param name="autoNumber" select="not(parent::Media[@notAutoNumber = 'true'])"/>

		<xsl:variable name="useFixtext">
			<xsl:call-template name="getTemplateVariableValue">
				<xsl:with-param name="name" select="'MEDIA_CAPTION_USE_FIXTEXT'"/>
			</xsl:call-template>
		</xsl:variable>

		<xsl:variable name="currChapt">
			<xsl:apply-templates select="current()" mode="getMainChapterNr"/>
		</xsl:variable>

		<xsl:variable name="internalCurrChapt">
			<xsl:choose>
				<xsl:when test="string-length($currChapt) = 0">
					<xsl:value-of select="generate-id(/InfoMap)"/>
				</xsl:when>
				<xsl:otherwise>
					<xsl:value-of select="$currChapt"/>
				</xsl:otherwise>
			</xsl:choose>
		</xsl:variable>

		<!--<xsl:if test="string(list:contains($CURRENT_IMAGE_CHAPTER, string($internalCurrChapt))) = 'false'">
			<xsl:variable name="remove" select="map:clear($IMAGE_COUNTER_MAP)"/>
			<xsl:variable name="remove2" select="list:removeAllElements($CURRENT_IMAGE_CHAPTER)"/>
			<xsl:variable name="add" select="list:add($CURRENT_IMAGE_CHAPTER, string($internalCurrChapt))"/>
		</xsl:if>-->

		<xsl:variable name="baseCounter" select="number(/*/Navigation/@incrementalMediaCount)"/>

		<xsl:variable name="imageCount">
			<xsl:call-template name="getMediaNumber">
				<xsl:with-param name="autoNumber" select="$autoNumber"/>
			</xsl:call-template>
		</xsl:variable>

		<fo:block keep-with-previous="always">
			<xsl:call-template name="addStyle">
				<xsl:with-param name="name">media.caption</xsl:with-param>
			</xsl:call-template>
			<xsl:if test="InfoPar.Subtitle">
				<xsl:call-template name="addStyle">
					<xsl:with-param name="name">media.caption</xsl:with-param>
					<xsl:with-param name="currentElement" select="InfoPar.Subtitle"/>
				</xsl:call-template>
			</xsl:if>
			<xsl:choose>
				<xsl:when test="$useListBlock">
					<xsl:variable name="MEDIA_CAPTION_INDENT">
						<xsl:call-template name="getTemplateVariableValue">
							<xsl:with-param name="name" select="concat('MEDIA_CAPTION_INDENT_', $language)"/>
							<xsl:with-param name="defaultValue">
								<xsl:call-template name="getTemplateVariableValue">
									<xsl:with-param name="name" select="'MEDIA_CAPTION_INDENT'"/>
									<xsl:with-param name="defaultValue">24mm</xsl:with-param>
								</xsl:call-template>
							</xsl:with-param>
						</xsl:call-template>
					</xsl:variable>
					<fo:list-block provisional-distance-between-starts="{$MEDIA_CAPTION_INDENT}">
						<fo:list-item>
							<fo:list-item-label end-indent="label-end()">
								<fo:block>
									<xsl:if test="not($useFixtext = 'false')">
										<xsl:call-template name="translate">
											<xsl:with-param name="ID">Image</xsl:with-param>
										</xsl:call-template>
										<xsl:if test="$autoNumber">
											<xsl:text> </xsl:text>
											<xsl:if test="string-length($currChapt) &gt; 0">
												<xsl:value-of select="concat($currChapt, $separator)"/>
											</xsl:if>
											<xsl:value-of select="$imageCount"/>
										</xsl:if>
									</xsl:if>
									<xsl:if test="$hasCaption">
										<xsl:value-of select="$listSeparator"/>
									</xsl:if>
								</fo:block>
							</fo:list-item-label>
							<fo:list-item-body start-indent="body-start()">
								<fo:block>
									<xsl:apply-templates select="InfoPar.Subtitle"/>
								</fo:block>
							</fo:list-item-body>
						</fo:list-item>
					</fo:list-block>
				</xsl:when>
				<xsl:otherwise>
					<xsl:if test="not($useFixtext = 'false')">
						<xsl:call-template name="translate">
							<xsl:with-param name="ID">Image</xsl:with-param>
						</xsl:call-template>
						<xsl:if test="$autoNumber">
							<xsl:text> </xsl:text>
							<xsl:if test="string-length($currChapt) &gt; 0">
								<xsl:value-of select="concat($currChapt, $separator)"/>
							</xsl:if>
							<xsl:value-of select="$imageCount"/>
						</xsl:if>
					</xsl:if>
					<xsl:if test="$hasCaption">
						<xsl:value-of select="concat($listSeparator, ' ')"/>
						<xsl:apply-templates select="InfoPar.Subtitle"/>
					</xsl:if>
				</xsl:otherwise>
			</xsl:choose>
		</fo:block>
	</xsl:template>

	<xsl:template match="Media.theme" mode="writeMediaPicture">
		<xsl:param name="P_WholeWidth"/>
		<xsl:param name="P_TextIntense"/>
		<xsl:param name="P_Indented"/>
		<xsl:param name="P_maxHeight"/>
		<xsl:param name="cellPaddingMinifier" select="0"/>
		<xsl:param name="marginalColumnWidth">0mm</xsl:param>
		<xsl:param name="isInline" select="false()"/>
		<xsl:param name="customRegionElem" select="ancestor::Region[1]"/>

		<xsl:call-template name="writeMediaPicture">
			<xsl:with-param name="P_WholeWidth" select="$P_WholeWidth"/>
			<xsl:with-param name="P_TextIntense" select="$P_TextIntense"/>
			<xsl:with-param name="P_Indented" select="$P_Indented"/>
			<xsl:with-param name="P_maxHeight" select="$P_maxHeight"/>
			<xsl:with-param name="cellPaddingMinifier" select="$cellPaddingMinifier"/>
			<xsl:with-param name="marginalColumnWidth" select="$marginalColumnWidth"/>
			<xsl:with-param name="isInline" select="$isInline"/>
			<xsl:with-param name="customRegionElem" select="$customRegionElem"/>
		</xsl:call-template>


	</xsl:template>

	<xsl:template match="legend.term | legend.def" mode="media">
		<xsl:apply-templates/>
	</xsl:template>

	<xsl:template match="Media">
		<xsl:param name="marginalColumnWidth">0mm</xsl:param>
		<xsl:param name="customRegionElem" select="ancestor::Region[1]"/>
		<xsl:variable name="visible">
			<xsl:call-template name="getFormat">
				<xsl:with-param name="name">media</xsl:with-param>
				<xsl:with-param name="attributeName">visibility</xsl:with-param>
			</xsl:call-template>
		</xsl:variable>
		<xsl:if test="not($visible = 'hidden')">
			<fo:block>
				<xsl:call-template name="addStyle">
					<xsl:with-param name="name">block-level-element</xsl:with-param>
				</xsl:call-template>
				<xsl:call-template name="addStyle">
					<xsl:with-param name="name">media.container</xsl:with-param>
				</xsl:call-template>
				<xsl:apply-templates>
					<xsl:with-param name="marginalColumnWidth" select="$marginalColumnWidth"/>
					<xsl:with-param name="customRegionElem" select="$customRegionElem"/>
				</xsl:apply-templates>
			</fo:block>
		</xsl:if>
	</xsl:template>

	<xsl:template match="i:pgf" mode="svg" xmlns:i="http://ns.adobe.com/AdobeIllustrator/10.0/"/>

	<xsl:template match="*" mode="svg">
		<xsl:copy>
			<xsl:apply-templates select="@* | node()" mode="svg"/>
		</xsl:copy>
	</xsl:template>

	<xsl:template match="@*" mode="svg">
		<xsl:copy-of select="current()"/>
	</xsl:template>

	<xsl:template match="@font-family" mode="svg" priority="1">
		<xsl:attribute name="font-family">
			<xsl:value-of select="."/>
			<xsl:if test="not(contains(., 'Arial Unicode MS'))">
				<xsl:text>,Arial Unicode MS</xsl:text>
			</xsl:if>
		</xsl:attribute>
	</xsl:template>

	<xsl:template match="@style" mode="svg" priority="1">
		<xsl:attribute name="style">
			<xsl:choose>
				<xsl:when test="contains(., 'font-family:') and not(contains(., 'Arial Unicode MS'))">
					<xsl:value-of select="substring-before(., 'font-family:')"/>
					<xsl:text>font-family:</xsl:text>
					<xsl:variable name="rest" select="substring-after(., 'font-family:')"/>
					<xsl:choose>
						<xsl:when test="contains($rest, ';')">
							<xsl:value-of select="substring-before($rest, ';')"/>
							<xsl:text>,Arial Unicode MS;</xsl:text>
							<xsl:value-of select="substring-after($rest, ';')"/>
						</xsl:when>
						<xsl:otherwise>
							<xsl:text>,Arial Unicode MS;</xsl:text>
						</xsl:otherwise>
					</xsl:choose>
				</xsl:when>
				<xsl:otherwise>
					<xsl:value-of select="."/>
				</xsl:otherwise>
			</xsl:choose>
		</xsl:attribute>
	</xsl:template>

</xsl:stylesheet>