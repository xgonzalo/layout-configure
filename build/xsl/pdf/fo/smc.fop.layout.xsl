<?xml version="1.0" encoding="utf-8"?>
<xsl:stylesheet
	xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
	xmlns:fo="http://www.w3.org/1999/XSL/Format"
	xmlns:fox="http://xmlgraphics.apache.org/fop/extensions"
	xmlns:psmi="http://www.CraneSoftwrights.com/resources/psmi"
	xmlns:axf="http://www.antennahouse.com/names/XSL/Extensions"
	version="1.0">

	<xsl:param name="mimeType"/>

	<xsl:variable name="FIRST_BLOCK_TITLEPAGE" select="(//block.titlepage)[1]"/>
	<xsl:variable name="hasBlockTitlepage" select="boolean($FIRST_BLOCK_TITLEPAGE)"/>

	<xsl:variable name="LANG">
		<xsl:choose>
			<xsl:when test="string-length(/InfoMap/@Lang) &gt; 0">
				<xsl:value-of select="/InfoMap/@Lang"/>
			</xsl:when>
			<xsl:otherwise>de</xsl:otherwise>
		</xsl:choose>
	</xsl:variable>

	<xsl:param name="PREPRESS_SUPPORT"/>
	<xsl:param name="IMPOSE"/>

	<xsl:variable name="BLEED_DEFAULT_VALUE" select="3"/>
	<xsl:variable name="CROP_OFFSET_DEFAULT_VALUE" select="10"/>

	<xsl:variable name="formatElements" select="/*/Format[1] | /*[$isMULTI_STYLE_FORMATTING]//Format"/>

	<xsl:variable name="outputTitlepageContentMarker" select="boolean($formatElements/PageGeometry//variable[@name = 'titlepage.content'])"/>

	<xsl:template name="addPrintMarkAttributes">
		<xsl:if test="$PREPRESS_SUPPORT = 'true' and not($IMPOSE = 'true')">
			<xsl:choose>
				<xsl:when test="$isAHMode">
					<xsl:attribute name="axf:printer-marks">crop</xsl:attribute>
					<xsl:attribute name="axf:crop-offset">
						<xsl:call-template name="getTemplateVariableValue">
							<xsl:with-param name="name" select="'CROP_OFFSET'"/>
							<xsl:with-param name="defaultValue" select="$CROP_OFFSET_DEFAULT_VALUE"/>
						</xsl:call-template>
						<xsl:text>mm</xsl:text>
					</xsl:attribute>
					<xsl:attribute name="axf:bleed">
						<xsl:call-template name="getTemplateVariableValue">
							<xsl:with-param name="name" select="'BLEED'"/>
							<xsl:with-param name="defaultValue" select="$BLEED_DEFAULT_VALUE"/>
						</xsl:call-template>
						<xsl:text>mm</xsl:text>
					</xsl:attribute>
				</xsl:when>
				<xsl:otherwise>
					<xsl:attribute name="fox:crop-box">media-box</xsl:attribute>
					<xsl:attribute name="fox:crop-offset">
						<xsl:call-template name="getTemplateVariableValue">
							<xsl:with-param name="name" select="'CROP_OFFSET'"/>
							<xsl:with-param name="defaultValue" select="$CROP_OFFSET_DEFAULT_VALUE"/>
						</xsl:call-template>
						<xsl:text>mm</xsl:text>
					</xsl:attribute>
					<xsl:attribute name="fox:bleed">
						<xsl:call-template name="getTemplateVariableValue">
							<xsl:with-param name="name" select="'BLEED'"/>
							<xsl:with-param name="defaultValue" select="$BLEED_DEFAULT_VALUE"/>
						</xsl:call-template>
						<xsl:text>mm</xsl:text>
					</xsl:attribute>
				</xsl:otherwise>
			</xsl:choose>
		</xsl:if>
	</xsl:template>

	<xsl:template name="addCustomPrintMarks">
		<xsl:if test="$PREPRESS_SUPPORT = 'true' and not($isAHMode) and not($IMPOSE = 'true')">
			<xsl:variable name="pageWidth">
				<xsl:choose>
					<xsl:when test="string(number(ancestor::StandardPageRegion[1]/@width)) != 'NaN'">
						<xsl:value-of select="concat(ancestor::StandardPageRegion[1]/@width, ancestor::PageGeometry[1]/@unit)"/>
					</xsl:when>
					<xsl:otherwise>
						<xsl:value-of select="$PAGE_WIDTH"/>
					</xsl:otherwise>
				</xsl:choose>
			</xsl:variable>
			<xsl:variable name="pageHeight">
				<xsl:choose>
					<xsl:when test="string(number(ancestor::StandardPageRegion[1]/@height)) != 'NaN'">
						<xsl:value-of select="concat(ancestor::StandardPageRegion[1]/@height, ancestor::PageGeometry[1]/@unit)"/>
					</xsl:when>
					<xsl:otherwise>
						<xsl:value-of select="$PAGE_HEIGHT"/>
					</xsl:otherwise>
				</xsl:choose>
			</xsl:variable>
			<xsl:call-template name="addPrintMarks">
				<xsl:with-param name="pageWidth" select="$pageWidth"/>
				<xsl:with-param name="pageHeight" select="$pageHeight"/>
				<xsl:with-param name="bleed">
					<xsl:call-template name="getTemplateVariableValue">
						<xsl:with-param name="name" select="'BLEED'"/>
						<xsl:with-param name="defaultValue" select="$BLEED_DEFAULT_VALUE"/>
					</xsl:call-template>
				</xsl:with-param>
				<xsl:with-param name="cropOffset">
					<xsl:call-template name="getTemplateVariableValue">
						<xsl:with-param name="name" select="'CROP_OFFSET'"/>
						<xsl:with-param name="defaultValue" select="$CROP_OFFSET_DEFAULT_VALUE"/>
					</xsl:call-template>
				</xsl:with-param>
				<xsl:with-param name="showColorBars">
					<xsl:call-template name="getTemplateVariableValue">
						<xsl:with-param name="name" select="'PRINT_MARKS_SHOW_COLOR_BARS'"/>
						<xsl:with-param name="defaultValue">false</xsl:with-param>
					</xsl:call-template>
				</xsl:with-param>
			</xsl:call-template>
		</xsl:if>
	</xsl:template>

	<xsl:template match="/">
		<xsl:choose>
			<xsl:when test="not(/InfoMap[Headline.content or Block or InfoMap]) and /InfoMap/Format/PageGeometry/Page">
				<xsl:apply-templates select="/InfoMap" mode="writeImFoRoot"/>
			</xsl:when>
			<xsl:when test="$isChapterWise">
				<Result>
					<xsl:for-each select="/InfoMap[Headline.content or Block or Block.remark or block.titlepage or Include.Block]">
						<Fo>
							<xsl:attribute name="name">
								<xsl:apply-templates select="current()" mode="getChapterWiseFileName"/>
							</xsl:attribute>
							<xsl:call-template name="writeFoRoot">
								<xsl:with-param name="applyChildren" select="false()"/>
								<xsl:with-param name="level">0</xsl:with-param>
							</xsl:call-template>
						</Fo>
					</xsl:for-each>
					<xsl:for-each select="/InfoMap/InfoMap">
						<Fo>
							<xsl:attribute name="name">
								<xsl:apply-templates select="current()" mode="getChapterWiseFileName"/>
							</xsl:attribute>
							<xsl:call-template name="writeFoRoot">
								<xsl:with-param name="level">1</xsl:with-param>
							</xsl:call-template>
						</Fo>
					</xsl:for-each>
				</Result>
			</xsl:when>
			<xsl:otherwise>
				<xsl:for-each select="/InfoMap">
					<xsl:call-template name="writeFoRoot"/>
				</xsl:for-each>
			</xsl:otherwise>
		</xsl:choose>

	</xsl:template>

	<xsl:template match="InfoMap" mode="writeFoRootAttributes">

		<xsl:variable name="targetResolution">
			<xsl:call-template name="getTemplateVariableValue">
				<xsl:with-param name="name" select="'TARGET_RESOLUTION'"/>
				<xsl:with-param name="defaultValue" select="72"/>
			</xsl:call-template>
		</xsl:variable>

		<xsl:variable name="useLastPageSequenceOnlyOnLast">
			<xsl:call-template name="getTemplateVariableValue">
				<xsl:with-param name="name">USE_LAST_PAGE_SEQUENCE_ONLY_ON_LAST</xsl:with-param>
				<xsl:with-param name="defaultValue">false</xsl:with-param>
			</xsl:call-template>
		</xsl:variable>

		<!-- FOP workaround, don't apply for arabic -->
		<xsl:if test="$LANG != 'ar'">
			<xsl:attribute name="language">
				<xsl:choose>
					<xsl:when test="$LANG = 'en-us' and $isAHMode">
						<xsl:value-of select="$LANG"/>
					</xsl:when>
					<xsl:when test="contains($LANG, '-')">
						<xsl:value-of select="substring-before($LANG, '-')"/>
					</xsl:when>
					<xsl:otherwise>
						<xsl:value-of select="$LANG"/>
					</xsl:otherwise>
				</xsl:choose>
			</xsl:attribute>
		</xsl:if>
		<xsl:if test="string(number($targetResolution)) != 'NaN' and $targetResolution != 72">
			<xsl:attribute name="smc:targetResolution" xmlns:smc="http://www.expert-communication.de/smc">
				<xsl:value-of select="$targetResolution"/>
			</xsl:attribute>
		</xsl:if>
		<xsl:if test="$useLastPageSequenceOnlyOnLast = 'true'">
			<xsl:attribute name="smc:useLastPageSequenceOnlyOnLast" xmlns:smc="http://www.expert-communication.de/smc">true</xsl:attribute>
		</xsl:if>
		<xsl:apply-templates select="current()" mode="writeDefaultStyle">
			<xsl:with-param name="writeTranslationHelperStyle" select="false()"/>
		</xsl:apply-templates>
	</xsl:template>
	
	<xsl:template match="InfoMap" mode="writeDefaultStyle">
		<xsl:param name="writeTranslationHelperStyle" select="true()"/>
		<xsl:call-template name="addStyle">
			<xsl:with-param name="name">default</xsl:with-param>
			<xsl:with-param name="writeTranslationHelperStyle" select="$writeTranslationHelperStyle"/>
		</xsl:call-template>
		<xsl:call-template name="addStyle">
			<xsl:with-param name="name" select="concat('default.', $language)"/>
			<xsl:with-param name="writeTranslationHelperStyle" select="$writeTranslationHelperStyle"/>
		</xsl:call-template>
		<xsl:if test="string-length($translation_target_language) &gt; 0">
			<xsl:call-template name="addStyle">
				<xsl:with-param name="name" select="concat('default.', $translation_target_language)"/>
				<xsl:with-param name="writeTranslationHelperStyle" select="$writeTranslationHelperStyle"/>
			</xsl:call-template>
		</xsl:if>
	</xsl:template>

	<xsl:template name="doSplitPageSequences">
		<xsl:variable name="disablePageSequenceSplitting">
			<xsl:call-template name="getTemplateVariableValue">
				<xsl:with-param name="name">DISABLE_PAGE_SEQUENCE_SPLITTING</xsl:with-param>
				<xsl:with-param name="defaultValue">false</xsl:with-param>
			</xsl:call-template>
		</xsl:variable>
		<xsl:variable name="pageBreakFirstLevel">
			<xsl:call-template name="getFormat">
				<xsl:with-param name="name">headline.content.1</xsl:with-param>
				<xsl:with-param name="attributeName">page-break-before</xsl:with-param>
			</xsl:call-template>
		</xsl:variable>
		<xsl:if test="not($disablePageSequenceSplitting = 'true') and ($pageBreakFirstLevel = 'always'
				or $pageBreakFirstLevel = 'right' or $pageBreakFirstLevel = 'left'
				or ($isMULTI_STYLE_FORMATTING and /InfoMap/InfoMap/Format))">true</xsl:if>
	</xsl:template>
	
	<xsl:template name="writeFoRoot">
		<xsl:param name="applyChildren" select="true()"/>
		<xsl:param name="level">0</xsl:param>

		<xsl:variable name="blockTitlePageDisplayType">
			<xsl:call-template name="getTemplateVariableValue">
				<xsl:with-param name="name">BLOCK_TITLEPAGE_DISPLAY_TYPE</xsl:with-param>
			</xsl:call-template>
		</xsl:variable>

		<xsl:variable name="doSplitPageSequences">
			<xsl:call-template name="doSplitPageSequences"/>
		</xsl:variable>
		
		<xsl:variable name="splitPageSequences" select="$doSplitPageSequences = 'true'"/>

		<fo:root hyphenate="true" xmlns:fox="http://xmlgraphics.apache.org/fop/extensions">
			<xsl:apply-templates select="current()" mode="writeFoRootAttributes"/>
			

			<xsl:call-template name="writeLayoutMasterSet">
				<xsl:with-param name="splitPageSequences" select="$splitPageSequences"/>
			</xsl:call-template>

			<xsl:variable name="isSingleInfomap" select="not(InfoMap)"/>

			<xsl:call-template name="writeFoDeclarations">
				<xsl:with-param name="applyChildren" select="$applyChildren"/>
			</xsl:call-template>

			<xsl:if test="not($isSingleInfomap) and $applyChildren">
				<xsl:apply-templates select="current()" mode="TOC">
					<xsl:with-param name="isRoot" select="true()"/>
					<xsl:with-param name="isChapterWise" select="$isChapterWise"/>
				</xsl:apply-templates>
			</xsl:if>

			<xsl:variable name="hasCustomRegions" select="boolean($formatElements/PageGeometry/StandardPageRegion[(@type = 'odd' or @type = 'even') and string-length(@filter) = 0 and CustomRegions/Region])"/>
			
			<xsl:choose>
				<xsl:when test="$splitPageSequences and not($isChapterWise)">

					<xsl:if test="(block.titlepage and not($blockTitlePageDisplayType = 'hidden')) or $isSingleInfomap">
						<fo:page-sequence master-reference="basicPSM">
							<xsl:if test="$isSingleInfomap">
								<xsl:attribute name="id">lastpagesequence</xsl:attribute>
							</xsl:if>
							<xsl:if test="$isRightToLeftLanguage">
								<xsl:attribute name="writing-mode">rl-tb</xsl:attribute>
							</xsl:if>
							<xsl:call-template name="applyPageSequenceAttribute">
								<xsl:with-param name="attributeName">initial-page-number</xsl:with-param>
								<xsl:with-param name="level">0</xsl:with-param>
							</xsl:call-template>
							<xsl:call-template name="applyPageSequenceAttribute">
								<xsl:with-param name="attributeName">force-page-count</xsl:with-param>
								<xsl:with-param name="level">0</xsl:with-param>
							</xsl:call-template>
							<xsl:call-template name="applyPageSequenceAttribute">
								<xsl:with-param name="attributeName">format</xsl:with-param>
								<xsl:with-param name="level">0</xsl:with-param>
							</xsl:call-template>
							<!-- re-apply color because color profiles have been processed now (setting on root, doesn't work FOP BUG) -->
							<xsl:call-template name="addStyle">
								<xsl:with-param name="name">default</xsl:with-param>
								<xsl:with-param name="attributeNamesList">|color|</xsl:with-param>
							</xsl:call-template>
			
							<xsl:call-template name="writeStaticContent">
								<xsl:with-param name="level" select="''"/>
							</xsl:call-template>

							<fo:flow flow-name="xsl-region-body">
								<xsl:if test="$DISABLE_COLUMN_BALANCING">
									<xsl:attribute name="fox:disable-column-balancing">true</xsl:attribute>
								</xsl:if>
								<xsl:if test="not(block.titlepage) or $blockTitlePageDisplayType = 'hidden'">
									<!-- don't output in case of block.titlepage because this generates an error with psmi template -->
									<xsl:apply-templates select="StructureProperties" mode="writeBookMarker"/>
								</xsl:if>
								<xsl:apply-templates select="current()">
									<xsl:with-param name="applyChildren" select="1 = 2"/>
									<xsl:with-param name="isLast" select="$isSingleInfomap"/>
									<xsl:with-param name="outputBookMarker" select="boolean(block.titlepage)"/>
									<xsl:with-param name="hasCustomRegions" select="$hasCustomRegions"/>
								</xsl:apply-templates>
							</fo:flow>
						</fo:page-sequence>
					</xsl:if>

					<xsl:for-each select="InfoMap[not(/InfoMap[not(block.titlepage) and (Block or Headline.content) and not($isSingleInfomap)])] | /InfoMap[not(block.titlepage) and (Block or Headline.content) and not($isSingleInfomap)]">
						<xsl:variable name="currentLevel" select="position()"/>
						<xsl:variable name="last" select="last()"/>

						<xsl:variable name="customFormatElement" select="Format[@styleID][1]"/>
						
						<xsl:variable name="masterName">
							<xsl:choose>
								<xsl:when test="$customFormatElement">
									<xsl:apply-templates select="$customFormatElement" mode="getMasterSuffix">
										<xsl:with-param name="level" select="$currentLevel"/>
									</xsl:apply-templates>
								</xsl:when>
								<xsl:otherwise>
									<xsl:value-of select="$currentLevel"/>
								</xsl:otherwise>
							</xsl:choose>
						</xsl:variable>

						<fo:page-sequence master-reference="basicPSM{$masterName}">
							<xsl:if test="string-length(@defaultLanguage) &gt; 0 and parent::*/@defaultLanguage != @defaultLanguage">
								<xsl:apply-templates select="current()" mode="writeDefaultStyle">
									<xsl:with-param name="writeTranslationHelperStyle" select="false()"/>
								</xsl:apply-templates>
							</xsl:if>
							<xsl:if test="$currentLevel = $last">
								<xsl:attribute name="id">lastpagesequence</xsl:attribute>
							</xsl:if>
							<xsl:if test="$isRightToLeftLanguage">
								<xsl:attribute name="writing-mode">rl-tb</xsl:attribute>
							</xsl:if>
							<xsl:call-template name="applyPageSequenceAttribute">
								<xsl:with-param name="attributeName">initial-page-number</xsl:with-param>
								<xsl:with-param name="level">1</xsl:with-param>
							</xsl:call-template>
							<xsl:call-template name="applyPageSequenceAttribute">
								<xsl:with-param name="attributeName">force-page-count</xsl:with-param>
								<xsl:with-param name="level">1</xsl:with-param>
							</xsl:call-template>
							<xsl:call-template name="applyPageSequenceAttribute">
								<xsl:with-param name="attributeName">format</xsl:with-param>
								<xsl:with-param name="level">1</xsl:with-param>
							</xsl:call-template>
							<!-- re-apply color because color profiles have been processed now (setting on root, doesn't work FOP BUG) -->
							<xsl:call-template name="addStyle">
								<xsl:with-param name="name">default</xsl:with-param>
								<xsl:with-param name="attributeNamesList">|color|</xsl:with-param>
								<xsl:with-param name="writeTranslationHelperStyle" select="false()"/>
							</xsl:call-template>
							<xsl:choose>
								<xsl:when test="$customFormatElement">
									<xsl:call-template name="writeStaticContent">
										<xsl:with-param name="level" select="$masterName"/>
										<xsl:with-param name="formatElement" select="$customFormatElement"/>
									</xsl:call-template>
								</xsl:when>
								<xsl:otherwise>
									<xsl:call-template name="writeStaticContent">
										<xsl:with-param name="level" select="$masterName"/>
									</xsl:call-template>
								</xsl:otherwise>
							</xsl:choose>

							<fo:flow flow-name="xsl-region-body">
								<xsl:if test="$DISABLE_COLUMN_BALANCING">
									<xsl:attribute name="fox:disable-column-balancing">true</xsl:attribute>
								</xsl:if>
								<xsl:if test="not(@fileSectionExtension = 'pdf') and (not(block.titlepage) or $blockTitlePageDisplayType = 'hidden')">
									<xsl:apply-templates select="StructureProperties" mode="writeBookMarker"/>
									<xsl:apply-templates select="current()" mode="writeMarker">
										<xsl:with-param name="internalID" select="$currentLevel"/>
										<xsl:with-param name="splitPageSequences" select="$splitPageSequences"/>
									</xsl:apply-templates>
								</xsl:if>
								<xsl:apply-templates select="current()">
									<xsl:with-param name="internalID" select="$currentLevel"/>
									<xsl:with-param name="isLast" select="$last = $currentLevel"/>
									<xsl:with-param name="hasCustomRegions" select="$hasCustomRegions"/>
									<xsl:with-param name="useCustomPageSequenceForEmbeddedFormatElement" select="false()"/>
								</xsl:apply-templates>
								<xsl:choose>
									<xsl:when test="not($last = $currentLevel) and not(Block or Block.remark or block.titlepage or Headline.content or Include.Block)">
										<fo:block/>
									</xsl:when>
								</xsl:choose>
							</fo:flow>

						</fo:page-sequence>
					</xsl:for-each>

				</xsl:when>
				<xsl:otherwise>
					<fo:page-sequence master-reference="basicPSM" id="lastpagesequence">
						<xsl:if test="$isRightToLeftLanguage">
							<xsl:attribute name="writing-mode">rl-tb</xsl:attribute>
						</xsl:if>
						<xsl:call-template name="applyPageSequenceAttribute">
							<xsl:with-param name="attributeName">initial-page-number</xsl:with-param>
							<xsl:with-param name="level" select="$level"/>
						</xsl:call-template>
						<xsl:call-template name="applyPageSequenceAttribute">
							<xsl:with-param name="attributeName">force-page-count</xsl:with-param>
							<xsl:with-param name="level" select="$level"/>
						</xsl:call-template>
						<xsl:call-template name="applyPageSequenceAttribute">
							<xsl:with-param name="attributeName">format</xsl:with-param>
							<xsl:with-param name="level" select="$level"/>
						</xsl:call-template>
						<!-- re-apply color because color profiles have been processed now (setting on root, doesn't work FOP BUG) -->
						<xsl:call-template name="addStyle">
							<xsl:with-param name="name">default</xsl:with-param>
							<xsl:with-param name="attributeNamesList">|color|</xsl:with-param>
							<xsl:with-param name="writeTranslationHelperStyle" select="false()"/>
						</xsl:call-template>
						<xsl:call-template name="writeStaticContent">
							<xsl:with-param name="level" select="''"/>
							<xsl:with-param name="splitPageSequences" select="$splitPageSequences"/>
						</xsl:call-template>

						<fo:flow flow-name="xsl-region-body">
							<xsl:if test="$DISABLE_COLUMN_BALANCING">
								<xsl:attribute name="fox:disable-column-balancing">true</xsl:attribute>
							</xsl:if>
							<xsl:variable name="hasTitlepage" select="block.titlepage and not($blockTitlePageDisplayType = 'hidden')"/>
							<xsl:variable name="hasBlocks" select="Block or Block.remark or Headline.content or Include.Block"/>
							<xsl:if test="not($hasTitlepage) and (Block or Block.remark or Headline.content or Include.Block or InfoMap[1][not(@fileSectionExtension = 'pdf') and (not(block.titlepage) or $blockTitlePageDisplayType = 'hidden')])">
								<xsl:apply-templates select="ancestor-or-self::InfoMap[StructureProperties][1]/StructureProperties" mode="writeBookMarker"/>
							</xsl:if>
							<xsl:choose>
								<xsl:when test="$hasTitlepage">
									<xsl:apply-templates select="current()">
										<xsl:with-param name="applyChildren" select="false()"/>
										<xsl:with-param name="isLast" select="not(InfoMap)"/>
										<xsl:with-param name="isLastBranch" select="not(InfoMap)"/>
										<xsl:with-param name="hasCustomRegions" select="$hasCustomRegions"/>
										<xsl:with-param name="splitPageSequences" select="$splitPageSequences"/>
										<xsl:with-param name="useCustomPageSequenceForEmbeddedFormatElement" select="false()"/>
									</xsl:apply-templates>
									<xsl:if test="$applyChildren">
										<xsl:apply-templates select="InfoMap">
											<xsl:with-param name="splitPageSequences" select="$splitPageSequences"/>
											<xsl:with-param name="hasCustomRegions" select="$hasCustomRegions"/>
										</xsl:apply-templates>
									</xsl:if>
								</xsl:when>
								<xsl:when test="$hasBlocks">
									<xsl:apply-templates select="current()">
										<xsl:with-param name="applyChildren" select="$applyChildren"/>
										<xsl:with-param name="hasCustomRegions" select="$hasCustomRegions"/>
										<xsl:with-param name="splitPageSequences" select="$splitPageSequences"/>
										<xsl:with-param name="useCustomPageSequenceForEmbeddedFormatElement" select="false()"/>
										<!--<xsl:with-param name="isLast" select="not(InfoMap)"/>
										<xsl:with-param name="isLastBranch" select="not(InfoMap)"/>-->
									</xsl:apply-templates>
								</xsl:when>
								<xsl:otherwise>
									<xsl:apply-templates select="InfoMap">
										<xsl:with-param name="hasCustomRegions" select="$hasCustomRegions"/>
										<xsl:with-param name="splitPageSequences" select="$splitPageSequences"/>
										<xsl:with-param name="useCustomPageSequenceForEmbeddedFormatElement" select="false()"/>
									</xsl:apply-templates>
								</xsl:otherwise>
							</xsl:choose>
							<xsl:variable name="resetMarkers">
								<xsl:call-template name="getTemplateVariableValue">
									<xsl:with-param name="name">RESET_MARKERS_ON_END</xsl:with-param>
								</xsl:call-template>
							</xsl:variable>
							<xsl:if test="$resetMarkers = 'true'">
								<fo:block>
									<fo:marker marker-class-name="headline"></fo:marker>
									<fo:marker marker-class-name="headline.theme"></fo:marker>
									<fo:marker marker-class-name="headline2"></fo:marker>
									<fo:marker marker-class-name="chapter-nr2"></fo:marker>
									<fo:marker marker-class-name="headline2WithPrefix"></fo:marker>
								</fo:block>
							</xsl:if>
						</fo:flow>
					</fo:page-sequence>
				</xsl:otherwise>
			</xsl:choose>

		</fo:root>
	</xsl:template>

	<xsl:template name="writeLayoutMasterSet">
		<xsl:param name="splitPageSequences" select="true()"/>

		<fo:layout-master-set>
			<xsl:call-template name="writeSimplePageMasters">
				<xsl:with-param name="level" select="''"/>
			</xsl:call-template>
			<xsl:if test="not($mimeType = 'application/rtf')">
				<xsl:call-template name="writePageSequenceMaster">
					<xsl:with-param name="level" select="''"/>
				</xsl:call-template>
			</xsl:if>
			<xsl:if test="not($isChapterWise) and $splitPageSequences">
				<xsl:for-each select="InfoMap">
					<xsl:if test="not($mimeType = 'application/rtf')">
						<xsl:call-template name="writeSimplePageMasters">
							<xsl:with-param name="level" select="position()"/>
						</xsl:call-template>
					</xsl:if>
					<xsl:call-template name="writePageSequenceMaster">
						<xsl:with-param name="level" select="position()"/>
						<xsl:with-param name="isLast" select="position() = last()"/>
					</xsl:call-template>
				</xsl:for-each>
			</xsl:if>

		</fo:layout-master-set>
	</xsl:template>

	<xsl:template name="writeSimplePageMasters">
		<xsl:param name="level"/>

		<!--<xsl:variable name="masterSuffixList" select="list:new()"/>-->
		<xsl:choose>
			<xsl:when test="$mimeType = 'application/rtf'">
				<xsl:variable name="odd" select="$formatElements/PageGeometry/StandardPageRegion[@type = 'odd' and string-length(@filter) = 0]"/>
				<xsl:variable name="even" select="$formatElements/PageGeometry/StandardPageRegion[@type = 'even' and string-length(@filter) = 0]"/>
				<xsl:apply-templates select="$odd | $even[not($odd)]" mode="writeSimplePageMaster">
					<xsl:with-param name="level" select="$level"/>
					<xsl:with-param name="masterName">basicPSM</xsl:with-param>
					<!--<xsl:with-param name="masterSuffixList" select="$masterSuffixList"/>-->
				</xsl:apply-templates>
			</xsl:when>
			<xsl:when test="not($formatElements/PageGeometry/StandardPageRegion[string-length(@type) &gt; 0])">
				<xsl:call-template name="writeSimplePageMaster">
					<xsl:with-param name="type">odd</xsl:with-param>
					<xsl:with-param name="level" select="$level"/>
					<xsl:with-param name="pageWidth" select="$PAGE_WIDTH"/>
					<xsl:with-param name="pageHeight" select="$PAGE_HEIGHT"/>
				</xsl:call-template>
				<xsl:call-template name="writeSimplePageMaster">
					<xsl:with-param name="type">first</xsl:with-param>
					<xsl:with-param name="level" select="$level"/>
					<xsl:with-param name="pageWidth" select="$PAGE_WIDTH"/>
					<xsl:with-param name="pageHeight" select="$PAGE_HEIGHT"/>
				</xsl:call-template>
			</xsl:when>
			<xsl:otherwise>
				<xsl:apply-templates select="$formatElements/PageGeometry/StandardPageRegion[string-length(@type) &gt; 0]" mode="writeSimplePageMaster">
					<xsl:with-param name="level" select="$level"/>
					<!--<xsl:with-param name="masterSuffixList" select="$masterSuffixList"/>-->
				</xsl:apply-templates>
			</xsl:otherwise>
		</xsl:choose>

		<xsl:if test="not($formatElements/PageGeometry/StandardPageRegion[@type = 'first' and string-length(@filter) = 0])">

			<xsl:choose>
				<xsl:when test="$formatElements/PageGeometry/StandardPageRegion[@type = 'odd' and string-length(@filter) = 0]">
					<xsl:apply-templates select="$formatElements/PageGeometry/StandardPageRegion[@type = 'odd' and string-length(@filter) = 0][1]" mode="writeSimplePageMaster">
						<xsl:with-param name="level" select="$level"/>
						<xsl:with-param name="type" select="'first'"/>
						<!--<xsl:with-param name="masterSuffixList" select="$masterSuffixList"/>-->
					</xsl:apply-templates>
				</xsl:when>
				<xsl:otherwise>
					<xsl:apply-templates select="$formatElements/PageGeometry/StandardPageRegion[@type = 'even' and string-length(@filter) = 0][1]" mode="writeSimplePageMaster">
						<xsl:with-param name="level" select="$level"/>
						<xsl:with-param name="type" select="'first'"/>
						<!--<xsl:with-param name="masterSuffixList" select="$masterSuffixList"/>-->
					</xsl:apply-templates>
				</xsl:otherwise>
			</xsl:choose>

		</xsl:if>

	</xsl:template>

	<xsl:template match="StandardPageRegion" mode="writeSimplePageMaster" name="writeSimplePageMaster">
		<xsl:param name="level"/>
		<xsl:param name="filter" select="@filter"/>
		<xsl:param name="type" select="@type"/>
		<xsl:param name="unit" select="parent::PageGeometry/@unit"/>
		<xsl:param name="masterName" select="$type"/>
		<xsl:param name="pageWidth" select="concat(@width, $unit)"/>
		<xsl:param name="pageHeight" select="concat(@height, $unit)"/>
		<!--<xsl:param name="masterSuffixList" select="list:new()"/>-->

		<xsl:variable name="masterSuffix">
			<xsl:choose>
				<xsl:when test="self::StandardPageRegion">
					<xsl:apply-templates select="self::StandardPageRegion" mode="getMasterSuffix">
						<xsl:with-param name="level" select="$level"/>
					</xsl:apply-templates>
				</xsl:when>
				<xsl:otherwise>
					<xsl:value-of select="$level"/>
				</xsl:otherwise>
			</xsl:choose>
		</xsl:variable>

		<!--<xsl:variable name="listKey" select="string(concat($masterName, $masterSuffix))"/>-->

		<!--<xsl:if test="not(list:contains($masterSuffixList, $listKey))">
			<xsl:variable name="add" select="list:add($masterSuffixList, $listKey)"/>-->

			<fo:simple-page-master master-name="{$masterName}{$masterSuffix}" page-height="{$pageHeight}" page-width="{$pageWidth}">
				<xsl:call-template name="addPrintMarkAttributes"/>
				<xsl:call-template name="addStyle">
					<xsl:with-param name="name" select="@formatRef"/>
					<xsl:with-param name="attributeNamesList" select="'|margin-bottom|margin-top|margin-right|margin-left|'"/>
				</xsl:call-template>

				<xsl:variable name="headlineHeight">
					<xsl:choose>
						<xsl:when test="not(Headline or Headline/*)">0cm</xsl:when>
						<xsl:when test="string(number(Headline/@height)) != 'NaN'">
							<xsl:value-of select="concat(Headline/@height, $unit)"/>
						</xsl:when>
						<xsl:otherwise>
							<xsl:value-of select="'0cm'"/>
						</xsl:otherwise>
					</xsl:choose>
				</xsl:variable>

				<xsl:variable name="sublineHeight">
					<xsl:choose>
						<xsl:when test="not(Subline or Subline/*)">0cm</xsl:when>
						<xsl:when test="string(number(Subline/@height)) != 'NaN'">
							<xsl:value-of select="concat(Subline/@height, $unit)"/>
						</xsl:when>
						<xsl:otherwise>
							<xsl:value-of select="'0cm'"/>
						</xsl:otherwise>
					</xsl:choose>
				</xsl:variable>

				<xsl:variable name="startregionWidth">
					<xsl:choose>
						<xsl:when test="not(Startregion or Startregion/*)">0cm</xsl:when>
						<xsl:when test="string(number(Startregion/@width)) != 'NaN'">
							<xsl:value-of select="concat(Startregion/@width, $unit)"/>
						</xsl:when>
						<xsl:otherwise>
							<xsl:value-of select="'0cm'"/>
						</xsl:otherwise>
					</xsl:choose>
				</xsl:variable>

				<xsl:variable name="endregionWidth">
					<xsl:choose>
						<xsl:when test="not(Endregion or Endregion/*)">0cm</xsl:when>
						<xsl:when test="string(number(Endregion/@width)) != 'NaN'">
							<xsl:value-of select="concat(Endregion/@width, $unit)"/>
						</xsl:when>
						<xsl:otherwise>
							<xsl:value-of select="'0cm'"/>
						</xsl:otherwise>
					</xsl:choose>
				</xsl:variable>

				<fo:region-body>
					<xsl:call-template name="addStyle">
						<xsl:with-param name="name" select="@formatRef"/>
						<xsl:with-param name="attributeNamesList" select="'|background-color|column-count|column-gap|padding-bottom|padding-top|padding-left|padding-right|background-image|background-repeat|background-position|vertical-align|border-style|border-width|border-color|border-left-width|border-left-style|border-left-color|border-right-width|border-right-style|border-right-color|border-top-width|border-top-style|border-top-color|border-bottom-width|border-bottom-style|border-bottom-color|'"/>
					</xsl:call-template>
					<xsl:call-template name="addStyle">
						<xsl:with-param name="name" select="concat(@formatRef, '.body')"/>
						<xsl:with-param name="attributeNamesList" select="'|margin-left|margin-right|'"/>
					</xsl:call-template>
					<!-- Commented due to https://issues.apache.org/jira/browse/FOP-2335 -->
					<!--<xsl:attribute name="margin-left">
						<xsl:value-of select="$startregionWidth"/>
					</xsl:attribute>
					<xsl:attribute name="margin-right">
						<xsl:value-of select="$endregionWidth"/>
					</xsl:attribute>-->
					<xsl:attribute name="margin-top">
						<xsl:value-of select="$headlineHeight"/>
					</xsl:attribute>
					<xsl:attribute name="margin-bottom">
						<xsl:value-of select="$sublineHeight"/>
					</xsl:attribute>
					<xsl:apply-templates select="/*" mode="setCustomRegionBodyStyles"/>
				</fo:region-body>
				
				<xsl:variable name="applySideRegionExtent">
					<xsl:call-template name="getTemplateVariableValue">
						<xsl:with-param name="name">APPLY_SIDEREGION_EXTENT</xsl:with-param>
					</xsl:call-template>
				</xsl:variable>


				<xsl:if test="$headlineHeight != '0cm' or ($PREPRESS_SUPPORT = 'true' and not($isAHMode) and not($IMPOSE = 'true')) or CustomRegions/Region">
					<fo:region-before region-name="before-{$masterName}{$masterSuffix}" extent="{$headlineHeight}"/>
				</xsl:if>

				<xsl:if test="$sublineHeight != '0cm'">
					<fo:region-after region-name="after-{$masterName}{$masterSuffix}" extent="{$sublineHeight}"/>
				</xsl:if>

				<xsl:if test="$startregionWidth != '0cm'">
					<fo:region-start region-name="start-{$masterName}{$masterSuffix}">
						<xsl:if test="not($applySideRegionExtent = 'false')">
							<xsl:attribute name="extent">
								<xsl:value-of select="$startregionWidth"/>
							</xsl:attribute>
						</xsl:if>
					</fo:region-start>
				</xsl:if>

				<xsl:if test="$endregionWidth != '0cm'">
					<fo:region-end region-name="end-{$masterName}{$masterSuffix}">
						<xsl:if test="not($applySideRegionExtent = 'false')">
							<xsl:attribute name="extent">
								<xsl:value-of select="$endregionWidth"/>
							</xsl:attribute>
						</xsl:if>
					</fo:region-end>
				</xsl:if>
			</fo:simple-page-master>
		<!--</xsl:if>-->
	</xsl:template>

	<xsl:template match="/*" mode="setCustomRegionBodyStyles"/>

	<xsl:template name="writePageNumbering">
		<fo:page-number/>
	</xsl:template>

	<xsl:template match="Headline" mode="static-content">
		<xsl:param name="level"/>
		<xsl:param name="currentElement"/>
		<fo:static-content flow-name="before-{../@type}{$level}{../@filter}">
			<xsl:call-template name="addCustomPrintMarks"/>
			<fo:block-container>
				<xsl:call-template name="addStyle">
					<xsl:with-param name="name">headernote.container</xsl:with-param>
				</xsl:call-template>
				<xsl:call-template name="addStyle">
					<xsl:with-param name="name" select="concat('headernote.container.', ../@type)"/>
				</xsl:call-template>
				<xsl:apply-templates select="*"/>
				<xsl:if test="not(*)">
					<fo:block/>
				</xsl:if>
			</fo:block-container>
			<xsl:apply-templates select="parent::StandardPageRegion[CustomRegions/Region]" mode="addCustomRegions">
				<xsl:with-param name="currentElement" select="$currentElement"/>
			</xsl:apply-templates>
		</fo:static-content>
	</xsl:template>

	<xsl:template match="Subline" mode="static-content">
		<xsl:param name="level"/>
		<fo:static-content flow-name="after-{../@type}{$level}{../@filter}">
			<fo:block-container>
				<xsl:call-template name="addStyle">
					<xsl:with-param name="name">footer.container</xsl:with-param>
				</xsl:call-template>
				<xsl:call-template name="addStyle">
					<xsl:with-param name="name" select="concat('footer.container.', ../@type)"/>
				</xsl:call-template>
				<xsl:apply-templates select="*"/>
				<xsl:if test="not(*)">
					<fo:block/>
				</xsl:if>
			</fo:block-container>
		</fo:static-content>
	</xsl:template>

	<xsl:template match="Startregion | Endregion" mode="static-content">
		<xsl:param name="level"/>
		<xsl:param name="currentElement"/>
		<xsl:param name="splitPageSequences" select="true()"/>

		<xsl:variable name="name">
			<xsl:choose>
				<xsl:when test="name() = 'Startregion'">start</xsl:when>
				<xsl:otherwise>end</xsl:otherwise>
			</xsl:choose>
		</xsl:variable>

		<fo:static-content flow-name="{$name}-{../@type}{$level}{../@filter}" width="{concat(@width, ancestor::PageGeometry[1]/@unit)}">
			<xsl:choose>
				<xsl:when test="not($splitPageSequences)">
					<fo:retrieve-marker retrieve-class-name="{$name}-{../@type}{$level}{../@filter}region"/>
				</xsl:when>
				<xsl:otherwise>
					<xsl:apply-templates select="current()" mode="writeSideRegionContent">
						<xsl:with-param name="currentElement" select="$currentElement"/>
						<xsl:with-param name="name" select="$name"/>
					</xsl:apply-templates>
				</xsl:otherwise>
			</xsl:choose>
			<xsl:apply-templates select="current()" mode="writeCustomSideRegionContent">
				<xsl:with-param name="currentElement" select="$currentElement"/>
				<xsl:with-param name="name" select="$name"/>
			</xsl:apply-templates>
		</fo:static-content>
	</xsl:template>

	<xsl:template match="Startregion | Endregion" mode="writeCustomSideRegionContent"/>

	<xsl:template match="Startregion | Endregion" mode="getMarkerName">
		<xsl:param name="level"/>
		<xsl:param name="name">
			<xsl:choose>
				<xsl:when test="name() = 'Startregion'">start</xsl:when>
				<xsl:otherwise>end</xsl:otherwise>
			</xsl:choose>
		</xsl:param>
		<xsl:value-of select="concat($name, '-', ../@type, $level, ../@filter, 'region')"/>
	</xsl:template>

	<xsl:template match="Startregion | Endregion" mode="writeSideRegionContent">
		<xsl:param name="currentElement"/>
		<xsl:param name="name">
			<xsl:choose>
				<xsl:when test="name() = 'Startregion'">start</xsl:when>
				<xsl:otherwise>end</xsl:otherwise>
			</xsl:choose>
		</xsl:param>
			<fo:block-container>
				<xsl:call-template name="addStyle">
				<xsl:with-param name="name" select="concat($name, 'region.container')"/>
					<xsl:with-param name="currentElement" select="$currentElement"/>
				</xsl:call-template>
				<xsl:apply-templates select="current()" mode="static-content-multiplier">
					<xsl:with-param name="currentElement" select="$currentElement"/>
				</xsl:apply-templates>
				<xsl:apply-templates select="*">
					<xsl:with-param name="isInsideStartregion" select="name() = 'Startregion'"/>
					<xsl:with-param name="isInsideEndregion" select="name() = 'Endregion'"/>
					<xsl:with-param name="currentElement" select="$currentElement"/>
				</xsl:apply-templates>
				<xsl:if test="not(*)">
					<fo:block/>
				</xsl:if>
			</fo:block-container>
	</xsl:template>

	<xsl:template match="Startregion | Endregion" mode="static-content-multiplier">
		<xsl:param name="currentElement"/>
		<xsl:if test="string(number(@y-multiplier)) != 'NaN' or @y-autocalc='true'">
			<xsl:variable name="absPositionType">
				<xsl:call-template name="getFormat">
					<xsl:with-param name="name">
						<xsl:choose>
							<xsl:when test="name() = 'Startregion'">startregion.container</xsl:when>
							<xsl:otherwise>endregion.container</xsl:otherwise>
						</xsl:choose>
					</xsl:with-param>
					<xsl:with-param name="currentElement" select="$currentElement"/>
					<xsl:with-param name="attributeName">position</xsl:with-param>
				</xsl:call-template>
			</xsl:variable>
			<xsl:variable name="marginTopPx">
				<xsl:call-template name="getPixels">
					<xsl:with-param name="value">
						<xsl:call-template name="getFormat">
							<xsl:with-param name="name">
								<xsl:choose>
									<xsl:when test="name() = 'Startregion'">startregion.container</xsl:when>
									<xsl:otherwise>endregion.container</xsl:otherwise>
								</xsl:choose>
							</xsl:with-param>
							<xsl:with-param name="currentElement" select="$currentElement"/>
							<xsl:with-param name="attributeName">top</xsl:with-param>
							<xsl:with-param name="defaultValue">0</xsl:with-param>
						</xsl:call-template>
					</xsl:with-param>
					<xsl:with-param name="dpi" select="$OUTPUT_RESOLUTION"/>
				</xsl:call-template>
			</xsl:variable>
			<xsl:variable name="fullHeightPx">
				<xsl:choose>
					<xsl:when test="$absPositionType = 'fixed'">
						<xsl:call-template name="getPixels">
							<xsl:with-param name="value" select="$PAGE_HEIGHT"/>
							<xsl:with-param name="dpi" select="$OUTPUT_RESOLUTION"/>
						</xsl:call-template>
					</xsl:when>
					<xsl:otherwise>
						<xsl:call-template name="getFullHeight">
							<xsl:with-param name="heightCorrection" select="0"/>
						</xsl:call-template>
					</xsl:otherwise>
				</xsl:choose>
			</xsl:variable>
			<xsl:variable name="freePixels" select="$fullHeightPx - $marginTopPx"/>
			<xsl:variable name="chapterCount" select="count(/InfoMap/InfoMap[not(@HideInNavigation='true')])"/>
			<xsl:variable name="multiPx">
				<xsl:choose>
					<xsl:when test="@y-autocalc='true'">
						<xsl:value-of select="$freePixels div $chapterCount"/>
					</xsl:when>
					<xsl:otherwise>
						<xsl:call-template name="getPixels">
							<xsl:with-param name="value" select="concat(@y-multiplier, ancestor::PageGeometry[1]/@unit)"/>
							<xsl:with-param name="dpi" select="$OUTPUT_RESOLUTION"/>
						</xsl:call-template>
					</xsl:otherwise>
				</xsl:choose>
			</xsl:variable>
			<xsl:variable name="maxBoxesPerPage">
				<xsl:choose>
					<xsl:when test="string(number(@maxPositionsPerPage)) != 'NaN'">
						<xsl:value-of select="floor(@maxPositionsPerPage)"/>
					</xsl:when>
					<xsl:when test="@y-autocalc='true'">
						<xsl:value-of select="$chapterCount"/>
					</xsl:when>
					<xsl:otherwise>
						<xsl:value-of select="floor(($fullHeightPx - $marginTopPx) div $multiPx)"/>
					</xsl:otherwise>
				</xsl:choose>
			</xsl:variable>
			<xsl:variable name="positionStr">
				<xsl:apply-templates select="$currentElement/ancestor-or-self::InfoMap[@level = $BASE_LEVEL]" mode="getPosition">
					<xsl:with-param name="suffix"></xsl:with-param>
					<xsl:with-param name="isSideRegion" select="true()"/>
				</xsl:apply-templates>
			</xsl:variable>
			<xsl:variable name="position">
				<xsl:choose>
					<xsl:when test="string(number($positionStr)) != 'NaN'">
						<xsl:value-of select="$positionStr"/>
					</xsl:when>
					<xsl:otherwise>1</xsl:otherwise>
				</xsl:choose>
			</xsl:variable>

			<xsl:attribute name="position">absolute</xsl:attribute>
			<xsl:if test="string-length($absPositionType) &gt; 0">
				<xsl:attribute name="position">
					<xsl:value-of select="$absPositionType"/>
				</xsl:attribute>
			</xsl:if>
			<xsl:variable name="top" select="$marginTopPx + $multiPx * (($position - 1) mod $maxBoxesPerPage)"/>
			<xsl:attribute name="top">
				<xsl:value-of select="concat($top, 'px')"/>
			</xsl:attribute>
			<xsl:choose>
				<xsl:when test="@height-autocalc = 'true'">
					<xsl:attribute name="height">
						<xsl:value-of select="$multiPx"/>
						<xsl:text>px</xsl:text>
					</xsl:attribute>
				</xsl:when>
				<xsl:when test="string(number(@height)) != 'NaN'">
					<xsl:attribute name="height">
						<xsl:value-of select="@height"/>
						<xsl:value-of select="ancestor::PageGeometry[1]/@unit"/>
					</xsl:attribute>
				</xsl:when>
			</xsl:choose>
			<!--<xsl:message>
				<xsl:value-of select="concat('$multiPx: ', $multiPx)"/>
			</xsl:message>
			<xsl:message>
				<xsl:value-of select="concat('$fullHeightPx: ', $fullHeightPx)"/>
			</xsl:message>
			<xsl:message>
				<xsl:value-of select="concat('$marginTopPx: ', $marginTopPx)"/>
			</xsl:message>
			<xsl:message>
				<xsl:value-of select="concat('$position: ', $position)"/>
			</xsl:message>
			<xsl:message>
				<xsl:value-of select="concat('$maxBoxesPerPage: ', $maxBoxesPerPage)"/>
			</xsl:message>
			<xsl:message>
				<xsl:value-of select="concat('$top: ', $top)"/>
			</xsl:message>-->
		</xsl:if>
	</xsl:template>

	<xsl:template name="writeStaticContent">
		<xsl:param name="level"/>
		<xsl:param name="splitPageSequences" select="true()"/>
		<xsl:param name="formatElement" select="$formatElements"/>

		<xsl:choose>
			<xsl:when test="$mimeType = 'application/rtf'">
				<xsl:variable name="odd" select="$formatElements/PageGeometry/StandardPageRegion[@type = 'odd' and string-length(@filter) = 0]"/>
				<xsl:variable name="even" select="$formatElements/PageGeometry/StandardPageRegion[@type = 'even' and string-length(@filter) = 0]"/>

				<xsl:apply-templates select="$odd | $even[not($odd)]" mode="writeStaticContent">
					<xsl:with-param name="currentElement" select="current()"/>
					<xsl:with-param name="level" select="$level"/>
					<xsl:with-param name="splitPageSequences" select="$splitPageSequences"/>
				</xsl:apply-templates>
			</xsl:when>
			<xsl:otherwise>
				<xsl:apply-templates select="$formatElement/PageGeometry/StandardPageRegion[string-length(@type) &gt; 0]" mode="writeStaticContent">
					<xsl:with-param name="currentElement" select="current()"/>
					<xsl:with-param name="level" select="$level"/>
					<xsl:with-param name="splitPageSequences" select="$splitPageSequences"/>
				</xsl:apply-templates>

				<fo:static-content flow-name="xsl-footnote-separator">
					<fo:block-container>
						<xsl:call-template name="addStyle">
							<xsl:with-param name="name">footnote.separator</xsl:with-param>
						</xsl:call-template>
						<fo:block></fo:block>
					</fo:block-container>
				</fo:static-content>
			</xsl:otherwise>
		</xsl:choose>

	</xsl:template>

	<xsl:template match="StandardPageRegion" mode="writeStaticContent">
		<xsl:param name="level"/>
		<xsl:param name="splitPageSequences"/>
		<xsl:param name="currentElement"/>
		<xsl:variable name="headlineHeight" select="Headline/@height"/>
		<xsl:if test="string(number($headlineHeight)) != 'NaN' or ($PREPRESS_SUPPORT = 'true' and not($isAHMode) and not($IMPOSE = 'true')) or CustomRegions/Region">
			<xsl:apply-templates select="Headline" mode="static-content">
				<xsl:with-param name="level" select="$level"/>
				<xsl:with-param name="currentElement" select="$currentElement"/>
			</xsl:apply-templates>
		</xsl:if>
		<xsl:variable name="sublineHeight" select="Subline/@height"/>
		<xsl:if test="string(number($sublineHeight)) != 'NaN'">
			<xsl:apply-templates select="Subline" mode="static-content">
				<xsl:with-param name="level" select="$level"/>
				<xsl:with-param name="currentElement" select="$currentElement"/>
			</xsl:apply-templates>
		</xsl:if>

		<xsl:variable name="startregionWidth" select="Startregion/@width"/>
		<xsl:if test="string(number($startregionWidth)) != 'NaN'">
			<xsl:apply-templates select="Startregion" mode="static-content">
				<xsl:with-param name="level" select="$level"/>
				<xsl:with-param name="currentElement" select="$currentElement"/>
				<xsl:with-param name="splitPageSequences" select="$splitPageSequences"/>
			</xsl:apply-templates>
		</xsl:if>
		<xsl:variable name="endregionWidth" select="Endregion/@width"/>
		<xsl:if test="string(number($endregionWidth)) != 'NaN'">
			<xsl:apply-templates select="Endregion" mode="static-content">
				<xsl:with-param name="level" select="$level"/>
				<xsl:with-param name="currentElement" select="$currentElement"/>
				<xsl:with-param name="splitPageSequences" select="$splitPageSequences"/>
			</xsl:apply-templates>
		</xsl:if>
	</xsl:template>

	<xsl:template match="StandardPageRegion" mode="addCustomRegions">
		<xsl:param name="currentElement"/>

		<xsl:apply-templates select="CustomRegions/Region" mode="normal">
			<xsl:with-param name="currentElement" select="$currentElement"/>
		</xsl:apply-templates>
	</xsl:template>

	<xsl:template match="Region" mode="normal">
		<xsl:param name="id"/>
		<xsl:param name="currentElement"/>
		<xsl:param name="useMarker" select="true()"/>
		<xsl:variable name="unit" select="ancestor::PageGeometry[1]/@unit"/>
		<fo:block-container position="fixed">
			<xsl:if test="string-length($id) &gt; 0">
				<xsl:attribute name="id">
					<xsl:value-of select="$id"/>
				</xsl:attribute>
			</xsl:if>
			<xsl:for-each select="Box">
				<xsl:variable name="y">
					<xsl:choose>
						<xsl:when test="string-length(@y) &gt; 0 and string(number(@y)) != 'NaN'">
							<xsl:value-of select="@y"/>
						</xsl:when>
						<xsl:otherwise>0</xsl:otherwise>
					</xsl:choose>
				</xsl:variable>
				<xsl:attribute name="top">
					<xsl:value-of select="concat($y, $unit)"/>
				</xsl:attribute>
				<xsl:variable name="x">
					<xsl:choose>
						<xsl:when test="string-length(@x) &gt; 0 and string(number(@x)) != 'NaN'">
							<xsl:value-of select="@x"/>
						</xsl:when>
						<xsl:otherwise>0</xsl:otherwise>
					</xsl:choose>
				</xsl:variable>
				<xsl:attribute name="left">
					<xsl:value-of select="concat($x, $unit)"/>
				</xsl:attribute>
				<xsl:if test="string-length(@width) &gt; 0 and string(number(@width)) != 'NaN'">
					<xsl:attribute name="width">
						<xsl:value-of select="concat(@width, $unit)"/>
					</xsl:attribute>
				</xsl:if>
				<xsl:if test="string-length(@height) &gt; 0 and string(number(@height)) != 'NaN'">
					<xsl:attribute name="height">
						<xsl:value-of select="concat(@height, $unit)"/>
					</xsl:attribute>
				</xsl:if>
				<xsl:if test="string-length(@align) &gt; 0">
					<xsl:choose>
						<xsl:when test="@align = 'bottom'">
							<xsl:attribute name="display-align">after</xsl:attribute>
						</xsl:when>
						<xsl:when test="@align = 'middle'">
							<xsl:attribute name="display-align">center</xsl:attribute>
						</xsl:when>
					</xsl:choose>
				</xsl:if>
			</xsl:for-each>
			<fo:block>
				<xsl:if test="string-length(@formatRef) &gt; 0">
					<xsl:call-template name="addStyle">
						<xsl:with-param name="name" select="@formatRef"/>
					</xsl:call-template>
				</xsl:if>
				<xsl:if test="not($useMarker)">
					<xsl:apply-templates select="$currentElement" mode="writeMarker"/>
				</xsl:if>
				<xsl:if test="string-length(label) &gt; 0">
					<fo:block>
						<xsl:call-template name="addStyle">
							<xsl:with-param name="name">label</xsl:with-param>
						</xsl:call-template>
						<xsl:apply-templates select="label/node()"/>
					</fo:block>
				</xsl:if>
				<xsl:apply-templates select="InfoPar"/>
				<xsl:choose>
					<xsl:when test="@assignContentType = 'Image'">
						<xsl:apply-templates select="$currentElement/*[self::Block or self::Block.remark or self::block.titlepage or self::Include.Block]/Media">
							<xsl:with-param name="customRegionElem" select="current()"/>
						</xsl:apply-templates>
					</xsl:when>
					<xsl:when test="@assignContentType = 'Text'">
						<xsl:apply-templates select="$currentElement/*[self::Block or self::Block.remark or self::Include.Block]/*[name() != 'Label' and name() != 'Media']"/>
					</xsl:when>
					<xsl:when test="@assignContentType = 'Title'">
						<xsl:apply-templates select="$currentElement/Headline.content"/>
					</xsl:when>
					<xsl:when test="@assignContentType = 'Label'">
						<xsl:for-each select="$currentElement/*[self::Block or self::Block.remark or self::block.titlepage or self::Include.Block]/Label">
							<fo:block>
								<xsl:call-template name="addStyle">
									<xsl:with-param name="name">label</xsl:with-param>
								</xsl:call-template>
								<xsl:apply-templates select="current()"/>
							</fo:block>
						</xsl:for-each>
					</xsl:when>
					<xsl:when test="@assignContentType = 'TextLabel'">
						<xsl:for-each select="$currentElement/*[self::Block or self::Block.remark or self::block.titlepage or self::Include.Block]">
							<xsl:if test="string-length(Label) &gt; 0">
								<fo:block>
									<xsl:call-template name="addStyle">
										<xsl:with-param name="name">label</xsl:with-param>
									</xsl:call-template>
									<xsl:apply-templates select="Label"/>
								</fo:block>
							</xsl:if>
							<xsl:apply-templates select="*[name() != 'Label' and name() != 'Media']"/>
						</xsl:for-each>
					</xsl:when>
					<xsl:when test="@assignContentType = 'Block'">
						<xsl:apply-templates select="$currentElement/*[self::Block or self::Block.remark or self::block.titlepage or self::Include.Block]"/>
					</xsl:when>
					<xsl:when test="@assignContentType = 'headline.theme'">
						<xsl:apply-templates select="$currentElement/Headline.theme"/>
					</xsl:when>
					<xsl:when test="@assignContentType = 'All'">
						<xsl:apply-templates select="$currentElement" mode="writeContent">
							<xsl:with-param name="customRegionElem" select="current()"/>
						</xsl:apply-templates>
					</xsl:when>
					<xsl:when test="@assignContentType = 'title.theme'">
						<xsl:choose>
							<xsl:when test="$useMarker">
								<fo:retrieve-marker retrieve-class-name="titlepage-title-theme"/>
							</xsl:when>
							<xsl:otherwise>
								<xsl:apply-templates select="$currentElement/block.titlepage/title.theme/node()"/>
							</xsl:otherwise>
						</xsl:choose>
					</xsl:when>
					<xsl:when test="@assignContentType = 'title'">
						<xsl:choose>
							<xsl:when test="$useMarker">
								<fo:retrieve-marker retrieve-class-name="titlepage-title"/>
							</xsl:when>
							<xsl:otherwise>
								<xsl:apply-templates select="$currentElement/block.titlepage/title/node()"/>
							</xsl:otherwise>
						</xsl:choose>
					</xsl:when>
					<xsl:when test="@assignContentType = 'date'">
						<xsl:choose>
							<xsl:when test="$useMarker">
								<fo:retrieve-marker retrieve-class-name="titlepage-date"/>
							</xsl:when>
							<xsl:otherwise>
								<xsl:apply-templates select="$currentElement/block.titlepage/date/node()"/>
							</xsl:otherwise>
						</xsl:choose>
					</xsl:when>
					<xsl:when test="@assignContentType = 'version'">
						<xsl:choose>
							<xsl:when test="$useMarker">
								<fo:retrieve-marker retrieve-class-name="titlepage-version"/>
							</xsl:when>
							<xsl:otherwise>
								<xsl:apply-templates select="$currentElement/block.titlepage/version/node()"/>
							</xsl:otherwise>
						</xsl:choose>
					</xsl:when>
					<xsl:when test="@assignContentType = 'optional.title'">
						<xsl:choose>
							<xsl:when test="$useMarker">
								<fo:retrieve-marker retrieve-class-name="titlepage-optional-title"/>
							</xsl:when>
							<xsl:otherwise>
								<xsl:apply-templates select="$currentElement/block.titlepage/optional.title/node()"/>
							</xsl:otherwise>
						</xsl:choose>
					</xsl:when>
					<xsl:when test="@assignContentType = 'footnote'">
						<xsl:choose>
							<xsl:when test="$useMarker">
								<fo:retrieve-marker retrieve-class-name="titlepage-footnote"/>
							</xsl:when>
							<xsl:otherwise>
								<xsl:apply-templates select="$currentElement/block.titlepage/footnote/node()"/>
							</xsl:otherwise>
						</xsl:choose>
					</xsl:when>
					<xsl:when test="string-length(@assignContentType) = 0 and regioncontent">
						<xsl:apply-templates select="regioncontent/*"/>
					</xsl:when>
				</xsl:choose>
			</fo:block>
		</fo:block-container>
	</xsl:template>

	<xsl:template match="Format" mode="getMasterSuffix">
		<xsl:param name="level"/>
		<xsl:param name="filter"/>
		<!-- Don't add for default Format element (which is child of root) -->
		<xsl:if test="$isMULTI_STYLE_FORMATTING and string-length(@styleID) &gt; 0 and generate-id(/*/Format) != generate-id()">
			<xsl:value-of select="concat('-', @styleID)"/>
			<xsl:if test="string-length($level) &gt; 0">-</xsl:if>
		</xsl:if>
		<xsl:choose>
			<xsl:when test="string-length($filter) &gt; 0">
				<xsl:value-of select="concat($level, $filter)"/>
			</xsl:when>
			<xsl:otherwise>
				<xsl:value-of select="$level"/>
			</xsl:otherwise>
		</xsl:choose>
	</xsl:template>

	<xsl:template match="StandardPageRegion" mode="getMasterSuffix">
		<xsl:param name="level"/>

		<xsl:apply-templates select="ancestor::Format[1]" mode="getMasterSuffix">
			<xsl:with-param name="level" select="$level"/>
			<xsl:with-param name="filter" select="@filter"/>
		</xsl:apply-templates>
	</xsl:template>

	<xsl:template name="writePageSequenceMaster">
		<xsl:param name="level"/>
		<xsl:param name="isLast"/>
		<!--{@filter}-->
		<xsl:variable name="alwaysUseLastPageSequence">
			<xsl:call-template name="getTemplateVariableValue">
				<xsl:with-param name="name">ALWAYS_USE_LAST_PAGE_SEQUENCE</xsl:with-param>
				<xsl:with-param name="defaultValue">false</xsl:with-param>
			</xsl:call-template>
		</xsl:variable>
		<xsl:variable name="alwaysUseFirstPageSequence">
			<xsl:call-template name="getTemplateVariableValue">
				<xsl:with-param name="name">ALWAYS_USE_FIRST_PAGE_SEQUENCE</xsl:with-param>
				<xsl:with-param name="defaultValue">false</xsl:with-param>
			</xsl:call-template>
		</xsl:variable>
		<xsl:variable name="useLastPageSequenceOnlyOnLast">
			<xsl:call-template name="getTemplateVariableValue">
				<xsl:with-param name="name">USE_LAST_PAGE_SEQUENCE_ONLY_ON_LAST</xsl:with-param>
				<xsl:with-param name="defaultValue">false</xsl:with-param>
			</xsl:call-template>
		</xsl:variable>
		<xsl:if test="not($formatElements/PageGeometry/StandardPageRegion[string-length(@type) &gt; 0])">
			<fo:page-sequence-master master-name="basicPSM{$level}">
				<fo:repeatable-page-master-alternatives>
					<fo:conditional-page-master-reference master-reference="odd{$level}" page-position="any" odd-or-even="any"/>
				</fo:repeatable-page-master-alternatives>
			</fo:page-sequence-master>
		</xsl:if>
		<!--<xsl:variable name="masterSuffixList" select="list:new()"/>-->
		<xsl:for-each select="$formatElements/PageGeometry/StandardPageRegion[string-length(@type) &gt; 0]">
			<xsl:variable name="filter" select="@filter"/>
			<xsl:variable name="hasFilter" select="string-length(@filter) &gt; 0"/>

			<xsl:if test="(not($hasFilter) and not(preceding-sibling::StandardPageRegion[string-length(@filter) = 0]))
					or ($hasFilter and not(preceding-sibling::StandardPageRegion[@filter = $filter]))">
				<xsl:variable name="masterSuffix">
					<xsl:apply-templates select="current()" mode="getMasterSuffix">
						<xsl:with-param name="level" select="$level"/>
					</xsl:apply-templates>
				</xsl:variable>
				<!--<xsl:if test="not(list:contains($masterSuffixList, string($masterSuffix)))">
					<xsl:variable name="add" select="list:add($masterSuffixList, string($masterSuffix))"/>-->
					<xsl:choose>
						<xsl:when test="$hasFilter">
							<fo:page-sequence-master master-name="basicPSM{$masterSuffix}">
								<fo:repeatable-page-master-alternatives>
									<xsl:variable name="hasLast" select="parent::PageGeometry/StandardPageRegion[@type = 'last' and @filter = $filter] and ($hasBlockTitlepage or $alwaysUseLastPageSequence = 'true') and not($useLastPageSequenceOnlyOnLast = 'true' and not($isLast))"/>
									<xsl:choose>
										<xsl:when test="parent::PageGeometry/StandardPageRegion[@type = 'chapter-last' and @filter = $filter]">
											<fo:conditional-page-master-reference master-reference="chapter-last{$masterSuffix}" page-position="last" odd-or-even="any"/>
										</xsl:when>
										<xsl:when test="$hasLast and $useLastPageSequenceOnlyOnLast = 'true' and $isLast">
											<fo:conditional-page-master-reference master-reference="last{$masterSuffix}" page-position="any" odd-or-even="any"/>
										</xsl:when>
										<xsl:when test="$hasLast">
											<fo:conditional-page-master-reference master-reference="last{$masterSuffix}" page-position="last" odd-or-even="any"/>
										</xsl:when>
									</xsl:choose>
									<xsl:if test="not($hasLast and $useLastPageSequenceOnlyOnLast = 'true' and $isLast)">
										<xsl:choose>
											<xsl:when test="parent::PageGeometry/StandardPageRegion[@type = 'chapter-first-even' and @filter = $filter]
													  and parent::PageGeometry/StandardPageRegion[@type = 'chapter-first-odd' and @filter = $filter]">
												<fo:conditional-page-master-reference master-reference="chapter-first-odd{$masterSuffix}" page-position="first" odd-or-even="odd"/>
												<fo:conditional-page-master-reference master-reference="chapter-first-even{$masterSuffix}" page-position="first" odd-or-even="even"/>
											</xsl:when>
											<xsl:when test="parent::PageGeometry/StandardPageRegion[@type = 'chapter-first' and @filter = $filter]">
												<fo:conditional-page-master-reference master-reference="chapter-first{$masterSuffix}" page-position="first" odd-or-even="any"/>
											</xsl:when>
										</xsl:choose>
										<xsl:if test="(($alwaysUseFirstPageSequence = 'true' and $hasBlockTitlepage)
												or $alwaysUseFirstPageSequence = 'force') and parent::PageGeometry/StandardPageRegion[@type = 'first' and @filter = $filter]">
											<fo:conditional-page-master-reference master-reference="first{$masterSuffix}" page-position="first" odd-or-even="any"/>
										</xsl:if>
										<xsl:choose>
											<xsl:when test="parent::PageGeometry/StandardPageRegion[@type = 'odd' and @filter = $filter]
								  and parent::PageGeometry/StandardPageRegion[@type = 'even' and @filter = $filter]">
												<fo:conditional-page-master-reference master-reference="odd{$masterSuffix}" page-position="any" odd-or-even="odd"/>
												<fo:conditional-page-master-reference master-reference="even{$masterSuffix}" page-position="any" odd-or-even="even"/>
											</xsl:when>
											<xsl:when test="parent::PageGeometry/StandardPageRegion[@type = 'odd' and @filter = $filter]">
												<fo:conditional-page-master-reference master-reference="odd{$masterSuffix}" page-position="any" odd-or-even="any"/>
											</xsl:when>
											<xsl:when test="parent::PageGeometry/StandardPageRegion[@type = 'even' and @filter = $filter]">
												<fo:conditional-page-master-reference master-reference="even{$masterSuffix}" page-position="any" odd-or-even="any"/>
											</xsl:when>
										</xsl:choose>
									</xsl:if>
								</fo:repeatable-page-master-alternatives>
							</fo:page-sequence-master>
						</xsl:when>
						<xsl:otherwise>
							<fo:page-sequence-master master-name="basicPSM{$masterSuffix}">
								<fo:repeatable-page-master-alternatives>
									<xsl:variable name="hasLast" select="parent::PageGeometry/StandardPageRegion[@type = 'last' and string-length(@filter) = 0] and ($hasBlockTitlepage or $alwaysUseLastPageSequence = 'true') and not($useLastPageSequenceOnlyOnLast = 'true' and not($isLast))"/>
									<xsl:choose>
										<xsl:when test="parent::PageGeometry/StandardPageRegion[@type = 'chapter-last' and string-length(@filter) = 0]">
											<fo:conditional-page-master-reference master-reference="chapter-last{$masterSuffix}" page-position="last" odd-or-even="any"/>
										</xsl:when>
										<xsl:when test="$hasLast and $useLastPageSequenceOnlyOnLast = 'true' and $isLast">
											<fo:conditional-page-master-reference master-reference="last{$masterSuffix}" page-position="any" odd-or-even="any"/>
										</xsl:when>
										<xsl:when test="$hasLast">
											<fo:conditional-page-master-reference master-reference="last{$masterSuffix}" page-position="last" odd-or-even="any"/>
										</xsl:when>
									</xsl:choose>
									<xsl:if test="not($hasLast and $useLastPageSequenceOnlyOnLast = 'true' and $isLast)">
										<xsl:choose>
											<xsl:when test="parent::PageGeometry/StandardPageRegion[@type = 'chapter-first-even' and string-length(@filter) = 0]
													  and parent::PageGeometry/StandardPageRegion[@type = 'chapter-first-odd' and string-length(@filter) = 0]">
												<fo:conditional-page-master-reference master-reference="chapter-first-odd{$masterSuffix}" page-position="first" odd-or-even="odd"/>
												<fo:conditional-page-master-reference master-reference="chapter-first-even{$masterSuffix}" page-position="first" odd-or-even="even"/>
											</xsl:when>
											<xsl:when test="parent::PageGeometry/StandardPageRegion[@type = 'chapter-first' and string-length(@filter) = 0]">
												<fo:conditional-page-master-reference master-reference="chapter-first{$masterSuffix}" page-position="first" odd-or-even="any"/>
											</xsl:when>
										</xsl:choose>
										<xsl:if test="(($alwaysUseFirstPageSequence = 'true' and $hasBlockTitlepage)
												or $alwaysUseFirstPageSequence = 'force') and parent::PageGeometry/StandardPageRegion[@type = 'first' and string-length(@filter) = 0]">
											<fo:conditional-page-master-reference master-reference="first{$masterSuffix}" page-position="first" odd-or-even="any"/>
										</xsl:if>
										<xsl:choose>
											<xsl:when test="parent::PageGeometry/StandardPageRegion[@type = 'odd' and string-length(@filter) = 0]
								  and parent::PageGeometry/StandardPageRegion[@type = 'even' and string-length(@filter) = 0]">
												<fo:conditional-page-master-reference master-reference="odd{$masterSuffix}" page-position="any" odd-or-even="odd"/>
												<fo:conditional-page-master-reference master-reference="even{$masterSuffix}" page-position="any" odd-or-even="even"/>
											</xsl:when>
											<xsl:when test="parent::PageGeometry/StandardPageRegion[@type = 'odd' and string-length(@filter) = 0]">
												<fo:conditional-page-master-reference master-reference="odd{$masterSuffix}" page-position="any" odd-or-even="any"/>
											</xsl:when>
											<xsl:when test="parent::PageGeometry/StandardPageRegion[@type = 'even' and string-length(@filter) = 0]">
												<fo:conditional-page-master-reference master-reference="even{$masterSuffix}" page-position="any" odd-or-even="any"/>
											</xsl:when>
										</xsl:choose>
									</xsl:if>
								</fo:repeatable-page-master-alternatives>
							</fo:page-sequence-master>
						</xsl:otherwise>
					</xsl:choose>
				<!--</xsl:if>-->
			</xsl:if>
		</xsl:for-each>


	</xsl:template>

	<!-- ***********************************************************************************
** 
** Write out chapter (InfoMap)
**
*************************************************************************************** -->

	<xsl:template match="InfoMap" mode="writeMarker">
		<xsl:param name="internalID"/>
		<xsl:param name="splitPageSequences" select="true()"/>
		<xsl:apply-templates select="current()" mode="writeMarkerInternal">
			<xsl:with-param name="internalID" select="$internalID"/>
			<xsl:with-param name="splitPageSequences" select="$splitPageSequences"/>
		</xsl:apply-templates>
	</xsl:template>

	<xsl:template match="StructureProperties" mode="writeBookMarker">
		<xsl:apply-templates select="StructureProperty[starts-with(@name, 'SMCDOCINFO:')]" mode="writePropertyMarker"/>
		<xsl:apply-templates select="/*/ContextProperties/ContextProperty[starts-with(@name, 'SMCDOCINFO:')]" mode="writePropertyMarker"/>
	</xsl:template>

	<xsl:template match="StructureProperty | ContextProperty" mode="writePropertyMarker">
		<fo:marker marker-class-name="{substring-after(@name, 'SMCDOCINFO:')}">
			<xsl:apply-templates select="@value"/>
		</fo:marker>
	</xsl:template>

	<xsl:variable name="fixtextElements" select="$formatElements/PageGeometry/StandardPageRegion//fixtext[string-length(.) &gt; 0]"/>

	<xsl:template match="InfoMap" mode="writeMarkerInternal">
		<xsl:param name="usePointSuffix" select="true()"/>
		<xsl:param name="usePointSuffixForNumberOnly" select="false()"/>
		<xsl:param name="nrTextSeparator">.</xsl:param>
		<xsl:param name="headline2Prefix">-</xsl:param>
		<xsl:param name="alwaysGenerateChapterNr" select="false()"/>
		<xsl:param name="generateBlockLevelHeadlineMarker" select="false()"/>
		<xsl:param name="internalID"/>
		<xsl:param name="splitPageSequences" select="true()"/>

		<xsl:variable name="chapNr">
			<xsl:choose>
				<xsl:when test="$isMultiMap or $alwaysGenerateChapterNr">
					<xsl:apply-templates select="ancestor-or-self::InfoMap[@level = $BASE_LEVEL]" mode="getChapterNr">
						<xsl:with-param name="removePointSuffix">true</xsl:with-param>
					</xsl:apply-templates>
				</xsl:when>
			</xsl:choose>
		</xsl:variable>
		<xsl:for-each select="ancestor-or-self::InfoMap[@level = $BASE_LEVEL]">
			<xsl:if test="not($splitPageSequences)">
				<xsl:variable name="infoMapElem" select="current()"/>
				<xsl:for-each select="$formatElements/PageGeometry/StandardPageRegion[string-length(@filter) = 0 or contains(current()/ancestor-or-self::InfoMap/@filter, @filter)]/*[name() = 'Startregion' or name() = 'Endregion']">
					<fo:marker>
						<xsl:attribute name="marker-class-name">
							<xsl:apply-templates select="current()" mode="getMarkerName">
								<xsl:with-param name="level" select="$internalID"/>
							</xsl:apply-templates>
						</xsl:attribute>
						<xsl:apply-templates select="current()" mode="writeSideRegionContent">
							<xsl:with-param name="currentElement" select="$infoMapElem"/>
						</xsl:apply-templates>
					</fo:marker>
				</xsl:for-each>
			</xsl:if>
			<xsl:apply-templates select="current()" mode="writeTitlePageMarker"/>
			<xsl:apply-templates select="ancestor-or-self::InfoMap/StructureProperties" mode="writeBookMarker"/>
			<fo:marker marker-class-name="chapter-nr">
				<xsl:value-of select="$chapNr"/>
				<xsl:if test="$usePointSuffixForNumberOnly and string-length($chapNr) &gt; 0">.</xsl:if>
			</fo:marker>
			<fo:marker marker-class-name="chapter-nr-headline">
				<xsl:if test="string-length($chapNr) &gt; 0">
					<fo:inline>
						<xsl:call-template name="addStyle">
							<xsl:with-param name="name">marker.headline.content.nr</xsl:with-param>
						</xsl:call-template>
						<xsl:call-template name="addStyle">
							<xsl:with-param name="name">marker.headline.content.nr.first</xsl:with-param>
						</xsl:call-template>
						<xsl:value-of select="$chapNr"/>
						<xsl:if test="$usePointSuffix">
							<xsl:value-of select="$nrTextSeparator"/>
						</xsl:if>
						<xsl:text> </xsl:text>
					</fo:inline>
				</xsl:if>
				<xsl:choose>
					<xsl:when test="string-length(Headline.content) &gt; 0">
						<xsl:apply-templates select="Headline.content" mode="printText"/>
					</xsl:when>
					<xsl:when test="string-length(@NavigationsBez) &gt; 0">
						<xsl:value-of select="@NavigationsBez"/>
					</xsl:when>
				</xsl:choose>
			</fo:marker>
			<fo:marker marker-class-name="headline-chapter-nr">
				<xsl:choose>
					<xsl:when test="string-length(Headline.content) &gt; 0">
						<xsl:apply-templates select="Headline.content" mode="printText"/>
					</xsl:when>
					<xsl:when test="string-length(@NavigationsBez) &gt; 0">
						<xsl:value-of select="@NavigationsBez"/>
					</xsl:when>
				</xsl:choose>
				<xsl:if test="string-length($chapNr) &gt; 0">
					<xsl:text> </xsl:text>
					<fo:inline>
						<xsl:call-template name="addStyle">
							<xsl:with-param name="name">marker.headline.content.nr</xsl:with-param>
						</xsl:call-template>
						<xsl:call-template name="addStyle">
							<xsl:with-param name="name">marker.headline.content.nr.last</xsl:with-param>
						</xsl:call-template>
						<xsl:value-of select="$chapNr"/>
						<xsl:if test="$usePointSuffix">
							<xsl:value-of select="$nrTextSeparator"/>
						</xsl:if>
					</fo:inline>
				</xsl:if>
			</fo:marker>
			<fo:marker marker-class-name="chapter-page-nr">
				<xsl:value-of select="$chapNr"/>
				<xsl:if test="string-length($chapNr) &gt; 0">-</xsl:if>
			</fo:marker>
			<fo:marker marker-class-name="headline">
				<xsl:choose>
					<xsl:when test="$generateBlockLevelHeadlineMarker and @HideInNavigation = 'true'">
						<fo:block>
							<xsl:call-template name="addStyle">
								<xsl:with-param name="name">marker.headline.content.hideinnavigation</xsl:with-param>
							</xsl:call-template>
							<xsl:apply-templates select="current()" mode="writeHeadlineContentMarkerText">
								<xsl:with-param name="useWorkaround" select="true()"/>
							</xsl:apply-templates>
						</fo:block>
					</xsl:when>
					<xsl:otherwise>
						<xsl:apply-templates select="current()" mode="writeHeadlineContentMarkerText">
							<xsl:with-param name="useWorkaround" select="true()"/>
						</xsl:apply-templates>
					</xsl:otherwise>
				</xsl:choose>
			</fo:marker>
			<fo:marker marker-class-name="headline.theme">
				<xsl:choose>
					<xsl:when test="string-length(Headline.theme) &gt; 0">
						<xsl:apply-templates select="Headline.theme/node()"/>
					</xsl:when>
				</xsl:choose>
			</fo:marker>
			<fo:marker marker-class-name="chapterwise-filename">
				<xsl:apply-templates select="current()" mode="getChapterWiseFileName"/>
			</fo:marker>
		</xsl:for-each>

		<xsl:choose>
			<xsl:when test="@level = $BASE_LEVEL">
				<xsl:variable name="doSplitPageSequences">
					<xsl:call-template name="doSplitPageSequences"/>
				</xsl:variable>
				<xsl:if test="not($doSplitPageSequences = 'true')">
					<fo:marker marker-class-name="headline2"></fo:marker>
					<fo:marker marker-class-name="chapter-nr2"></fo:marker>
					<fo:marker marker-class-name="chapter-nr1and2"></fo:marker>
					<fo:marker marker-class-name="headline2WithPrefix"></fo:marker>
					<fo:marker marker-class-name="headline3"></fo:marker>
					<fo:marker marker-class-name="headline3WithPrefix"></fo:marker>
				</xsl:if>
			</xsl:when>
			<xsl:otherwise>
				<xsl:if test="@level = ($BASE_LEVEL + 1) and preceding-sibling::InfoMap/InfoMap">
					<fo:marker marker-class-name="headline3"></fo:marker>
					<fo:marker marker-class-name="headline3WithPrefix"></fo:marker>
				</xsl:if>
				<xsl:for-each select="ancestor-or-self::InfoMap[@level = ($BASE_LEVEL + 1)][1]">
					<xsl:variable name="text">
						<xsl:choose>
							<xsl:when test="string-length(Headline.content) &gt; 0">
								<xsl:apply-templates select="Headline.content" mode="printText"/>
							</xsl:when>
							<xsl:when test="string-length(@NavigationsBez) &gt; 0">
								<xsl:value-of select="@NavigationsBez"/>
							</xsl:when>
						</xsl:choose>
					</xsl:variable>
					<fo:marker marker-class-name="headline2">
						<xsl:apply-templates select="current()" mode="writeHeadlineContentMarkerText"/>
					</fo:marker>
					<xsl:variable name="chapNr2Complete">
						<xsl:choose>
							<xsl:when test="$isMultiMap">
								<xsl:apply-templates select="current()" mode="getChapterNr">
									<xsl:with-param name="removePointSuffix">true</xsl:with-param>
									<xsl:with-param name="isMarker" select="true()"/>
								</xsl:apply-templates>
							</xsl:when>
						</xsl:choose>
					</xsl:variable>
					<xsl:variable name="chapNr2">
						<xsl:choose>
							<xsl:when test="string-length($chapNr) &gt; 0 and starts-with($chapNr2Complete, $chapNr)">
								<xsl:value-of select="substring-after($chapNr2Complete, concat($chapNr, '.'))"/>
							</xsl:when>
							<xsl:otherwise>
								<xsl:value-of select="$chapNr2Complete"/>
							</xsl:otherwise>
						</xsl:choose>
					</xsl:variable>
					<fo:marker marker-class-name="chapter-nr2">
						<xsl:value-of select="$chapNr2"/>
					</fo:marker>
					<fo:marker marker-class-name="chapter-nr1and2">
						<xsl:value-of select="$chapNr2Complete"/>
					</fo:marker>
					<fo:marker marker-class-name="headline2WithPrefix">
						<xsl:if test="string-length($text) &gt; 1">
							<xsl:value-of select="concat('&#160;', $headline2Prefix, ' ')"/>
						</xsl:if>
						<xsl:apply-templates select="current()" mode="writeHeadlineContentMarkerText"/>
					</fo:marker>
				</xsl:for-each>
				<xsl:for-each select="ancestor-or-self::InfoMap[@level = ($BASE_LEVEL + 2)][1]">
					<xsl:variable name="text">
						<xsl:choose>
							<xsl:when test="string-length(Headline.content) &gt; 0">
								<xsl:apply-templates select="Headline.content" mode="printText"/>
							</xsl:when>
							<xsl:when test="string-length(@NavigationsBez) &gt; 0">
								<xsl:value-of select="@NavigationsBez"/>
							</xsl:when>
						</xsl:choose>
					</xsl:variable>
					<fo:marker marker-class-name="headline3">
						<xsl:apply-templates select="current()" mode="writeHeadlineContentMarkerText"/>
					</fo:marker>
					<fo:marker marker-class-name="headline3WithPrefix">
						<xsl:if test="string-length($text) &gt; 1">
							<xsl:value-of select="concat('&#160;', $headline2Prefix, ' ')"/>
						</xsl:if>
						<xsl:apply-templates select="current()" mode="writeHeadlineContentMarkerText"/>
					</fo:marker>
				</xsl:for-each>
			</xsl:otherwise>
		</xsl:choose>

		<xsl:for-each select="Properties/Property[starts-with(@name, 'SMCDOCINFO:')]">
			<fo:marker marker-class-name="{substring-after(@name, 'SMCDOCINFO:')}">
				<xsl:apply-templates select="@value"/>
			</fo:marker>
		</xsl:for-each>

		<xsl:variable name="infoMapLanguage" select="ancestor-or-self::InfoMap[@defaultLanguage][1]/@defaultLanguage"/>

		<fo:marker marker-class-name="languagecode">
			<xsl:variable name="lc">
				<xsl:call-template name="translate">
					<xsl:with-param name="ID" select="concat('languagecode.', ancestor-or-self::InfoMap[@defaultLanguage][1]/@defaultLanguage)"/>
					<xsl:with-param name="defaultValue" select="ancestor-or-self::InfoMap[@defaultLanguage][1]/@defaultLanguage"/>
				</xsl:call-template>
			</xsl:variable>
			<xsl:choose>
				<xsl:when test="string-length($lc) &gt; 0">
					<xsl:value-of select="$lc"/>
				</xsl:when>
				<xsl:otherwise>
					<xsl:value-of select="$infoMapLanguage"/>
				</xsl:otherwise>
			</xsl:choose>
		</fo:marker>

		<fo:marker marker-class-name="fixtext-page">
			<xsl:call-template name="translate">
				<xsl:with-param name="ID">Page</xsl:with-param>
				<xsl:with-param name="language" select="$infoMapLanguage"/>
			</xsl:call-template>
		</fo:marker>
		<fo:marker marker-class-name="fixtext-of">
			<xsl:call-template name="translate">
				<xsl:with-param name="ID">Of</xsl:with-param>
				<xsl:with-param name="language" select="$infoMapLanguage"/>
			</xsl:call-template>
		</fo:marker>

		<!--<xsl:variable name="fixtextList" select="list:new()"/>-->
		<xsl:for-each select="$fixtextElements">
			<xsl:variable name="fixtext" select="string(.)"/>
			<!--<xsl:variable name="idx" select="list:indexOf($fixtextList, $fixtext)"/>
			<xsl:if test="$idx = '-1'">-->

				<xsl:choose>
					<xsl:when test="starts-with($fixtext, '$')">
						<xsl:variable name="var">
							<xsl:call-template name="getTemplateVariableValue">
								<xsl:with-param name="name" select="substring-after($fixtext, '$')"/>
							</xsl:call-template>
						</xsl:variable>
						<xsl:if test="string-length($var) &gt; 0">
							<fo:marker marker-class-name="{$var}">
								<xsl:call-template name="translate">
									<xsl:with-param name="ID" select="$var"/>
									<xsl:with-param name="language" select="$infoMapLanguage"/>
								</xsl:call-template>
							</fo:marker>
						</xsl:if>
					</xsl:when>
					<xsl:otherwise>
						<fo:marker marker-class-name="{$fixtext}">
							<xsl:call-template name="translate">
								<xsl:with-param name="ID" select="$fixtext"/>
								<xsl:with-param name="language" select="$infoMapLanguage"/>
							</xsl:call-template>
						</fo:marker>
					</xsl:otherwise>
				</xsl:choose>

				<!--<xsl:variable name="add" select="list:add($fixtextList, $fixtext)"/>-->
			<!--</xsl:if>-->
		</xsl:for-each>

		<fo:marker marker-class-name="parent-title">
			<xsl:value-of select="@ParentTitle"/>
		</fo:marker>
	
		<fo:marker marker-class-name="document-version">
			<xsl:choose>
				<xsl:when test="$objType = 'doc'">
					<xsl:value-of select="$versionLabel"/>
				</xsl:when>
				<xsl:otherwise>
					<xsl:value-of select="@versionLabel"/>
				</xsl:otherwise>
			</xsl:choose>
		</fo:marker>
	</xsl:template>

	<xsl:template match="InfoMap" mode="writeHeadlineContentMarkerText">
		<xsl:param name="useWorkaround" select="false()"/>
		<xsl:choose>
			<xsl:when test="string-length(Headline.content) &gt; 0">
				<fo:inline>
					<xsl:call-template name="addStyle">
						<xsl:with-param name="name">marker.headline.content</xsl:with-param>
					</xsl:call-template>
					<xsl:apply-templates select="Headline.content/node()[not(name() = 'Link.note') and not(name() = 'InfoChunk.Marked')]"/>
				</fo:inline>
			</xsl:when>
			<xsl:when test="string-length(@NavigationsBez) &gt; 0">
				<fo:inline>
					<xsl:call-template name="addStyle">
						<xsl:with-param name="name">marker.headline.content</xsl:with-param>
					</xsl:call-template>
					<xsl:value-of select="@NavigationsBez"/>
				</fo:inline>
			</xsl:when>
			<!-- don't generate empty markers because that triggers a FOP bug if only one big page sequence is used -->
			<xsl:when test="$useWorkaround and generate-id(parent::InfoMap) = generate-id(/InfoMap)">
				<xsl:variable name="doSplitPageSequences">
					<xsl:call-template name="doSplitPageSequences"/>
				</xsl:variable>
				<xsl:if test="$doSplitPageSequences = 'true'">&#160;</xsl:if>
			</xsl:when>
		</xsl:choose>
	</xsl:template>

	<xsl:template match="InfoMap" mode="writeTitlePageMarker">
		<xsl:variable name="language" select="string(@defaultLanguage | @Lang)"/>
		<xsl:variable name="blockTitlepage" select="key('BlockTitlepageLanguageKey', $language)"/>
		<xsl:choose>
			<xsl:when test="block.titlepage">
				<xsl:apply-templates select="block.titlepage" mode="writeTitlePageMarker"/>
			</xsl:when>
			<xsl:when test="$blockTitlepage">
				<xsl:apply-templates select="$blockTitlepage[1]" mode="writeTitlePageMarker"/>
			</xsl:when>
			<xsl:otherwise>
				<xsl:variable name="languageIndependent">
					<xsl:call-template name="getTemplateVariableValue">
						<xsl:with-param name="name" select="'LANGUAGE_INDEPENDENT_TITLEPAGE'"/>
					</xsl:call-template>
				</xsl:variable>
				<xsl:if test="$languageIndependent = 'true'">
					<xsl:apply-templates select="$FIRST_BLOCK_TITLEPAGE" mode="writeTitlePageMarker"/>
				</xsl:if>
			</xsl:otherwise>
		</xsl:choose>
	</xsl:template>

	<xsl:template match="block.titlepage" mode="writeTitlePageMarker">
		<fo:marker marker-class-name="titlepage-footnote">
			<xsl:if test="string-length(footnote) &gt; 0 or footnote/*">
				<fo:inline>
					<xsl:call-template name="addStyle">
						<xsl:with-param name="name">marker.titlepage.footnote</xsl:with-param>
					</xsl:call-template>
					<xsl:apply-templates select="footnote" mode="applyChildren"/>
				</fo:inline>
			</xsl:if>
		</fo:marker>
		<fo:marker marker-class-name="titlepage-version">
			<xsl:if test="string-length(version) &gt; 0 or version/*">
				<fo:inline>
					<xsl:call-template name="addStyle">
						<xsl:with-param name="name">marker.titlepage.version</xsl:with-param>
					</xsl:call-template>
					<xsl:apply-templates select="version" mode="applyChildren"/>
				</fo:inline>
			</xsl:if>
		</fo:marker>
		<fo:marker marker-class-name="titlepage-date">
			<xsl:if test="string-length(date) &gt; 0 or date/*">
				<fo:inline>
					<xsl:call-template name="addStyle">
						<xsl:with-param name="name">marker.titlepage.date</xsl:with-param>
					</xsl:call-template>
					<xsl:apply-templates select="date" mode="applyChildren"/>
				</fo:inline>
			</xsl:if>
		</fo:marker>
		<fo:marker marker-class-name="titlepage-title">
			<xsl:if test="string-length(title) &gt; 0 or title/*">
				<fo:inline>
					<xsl:call-template name="addStyle">
						<xsl:with-param name="name">marker.titlepage.title</xsl:with-param>
					</xsl:call-template>
					<xsl:apply-templates select="title" mode="applyChildren"/>
				</fo:inline>
			</xsl:if>
		</fo:marker>
		<fo:marker marker-class-name="titlepage-optional-title">
			<xsl:if test="string-length(optional.title) &gt; 0 or optional.title/*">
				<fo:inline>
					<xsl:call-template name="addStyle">
						<xsl:with-param name="name">marker.titlepage.optional.title</xsl:with-param>
					</xsl:call-template>
					<xsl:apply-templates select="optional.title" mode="applyChildren"/>
				</fo:inline>
			</xsl:if>
		</fo:marker>

		<fo:marker marker-class-name="titlepage-title-theme">
			<xsl:if test="string-length(title.theme) &gt; 0 or title.theme/*">
				<fo:inline>
					<xsl:call-template name="addStyle">
						<xsl:with-param name="name">marker.titlepage.title.theme</xsl:with-param>
					</xsl:call-template>
					<xsl:apply-templates select="title.theme" mode="applyChildren"/>
				</fo:inline>
			</xsl:if>
		</fo:marker>

		<fo:marker marker-class-name="titlepage-imagedetail">
			<xsl:if test="image.detail/Media.theme/RefControl[@webdavID]">
				<fo:inline>
					<xsl:call-template name="addStyle">
						<xsl:with-param name="name">marker.titlepage.imagedetail</xsl:with-param>
					</xsl:call-template>
					<xsl:apply-templates select="image.detail/Media.theme"/>
				</fo:inline>
			</xsl:if>
		</fo:marker>

		<xsl:for-each select="image.detail[string-length(@type) &gt; 0]">
			<xsl:variable name="className" select="concat('titlepage-imagedetail-custom-',@type)"/>
			<fo:marker marker-class-name="{$className}">
				<xsl:if test="Media.theme/RefControl[@webdavID]">
					<fo:inline>
						<xsl:call-template name="addStyle">
							<xsl:with-param name="name">marker.titlepage.imagedetail</xsl:with-param>
						</xsl:call-template>
						<xsl:call-template name="addStyle">
							<xsl:with-param name="name">
								<xsl:text>marker.titlepage.imagedetail.</xsl:text>
								<xsl:value-of select="@type"/>
							</xsl:with-param>
						</xsl:call-template>
						<xsl:apply-templates select="Media.theme"/>
					</fo:inline>
				</xsl:if>
			</fo:marker>
		</xsl:for-each>

		<!-- do this only if really necessary because it can be performance costly -->
		<xsl:if test="$outputTitlepageContentMarker">
			<fo:marker marker-class-name="titlepage-content">
				<xsl:if test="../Block">
					<xsl:apply-templates select="../Block"/>
				</xsl:if>
			</fo:marker>
		</xsl:if>
	</xsl:template>

	<xsl:template match="InfoMap">
		<xsl:param name="internalID"/>
		<xsl:param name="applyChildren" select="1 = 1"/>
		<xsl:param name="isLast" select="not(following-sibling::InfoMap)"/>
		<xsl:param name="isLastBranch" select="$isLast and not(following-sibling::InfoMap)"/>
		<xsl:param name="outputBookMarker" select="false()"/>
		<xsl:param name="hasCustomRegions"/>
		<xsl:param name="splitPageSequences" select="true()"/>
		<xsl:param name="isCustomPageSequence" select="false()"/>
		<xsl:param name="useCustomPageSequenceForEmbeddedFormatElement" select="true()"/>
		<xsl:param name="inheritId"/>

		<xsl:variable name="isLastInfoMap" select="$isLastBranch and not(InfoMap)"/>

		<xsl:variable name="filter" select="@filter"/>

		<xsl:variable name="allowNestedCustomPageSequences">
			<xsl:call-template name="getTemplateVariableValue">
				<xsl:with-param name="name">ALLOW_NESTED_CUSTOM_PAGE_SEQUENCIES</xsl:with-param>
				<xsl:with-param name="defaultValue">false</xsl:with-param>
			</xsl:call-template>
		</xsl:variable>

		<xsl:choose>
			<xsl:when test="@objType = 'urilink'">
				<xsl:apply-templates select="URIDefinition" mode="writeUriSection"/>
			</xsl:when>
			<xsl:when test="@fileSectionExtension and (@fileSectionExtension = 'pdf' or @fileSectionExtension = 'jpg'
					   or @fileSectionExtension = 'jpeg' or @fileSectionExtension = 'gif' or @fileSectionExtension = 'png'
					   or @fileSectionExtension = 'svg')">
				<xsl:apply-templates select="current()" mode="writeFileSection">
					<xsl:with-param name="internalID" select="$internalID"/>
					<xsl:with-param name="applyChildren" select="$applyChildren"/>
					<xsl:with-param name="isLastBranch" select="$isLastBranch"/>
					<xsl:with-param name="isLastInfoMap" select="$isLastInfoMap"/>
					<xsl:with-param name="filter" select="$filter"/>
					<xsl:with-param name="splitPageSequences" select="$splitPageSequences"/>
					<xsl:with-param name="inheritId" select="$inheritId"/>
				</xsl:apply-templates>
			</xsl:when>
			<!-- nested custom page sequences are not supported -->
			<xsl:when test="(not($isCustomPageSequence) or $allowNestedCustomPageSequences = 'true') and string-length(@filter) &gt; 0
					  and $formatElements/PageGeometry/StandardPageRegion[contains($filter, @filter) and string-length(@filter) &gt; 0]">
				<xsl:variable name="blockTitlePageDisplayType">
					<xsl:apply-templates select="block.titlepage[1]" mode="getDisplayType"/>
				</xsl:variable>
				<xsl:choose>
					<xsl:when test="block.titlepage and not($blockTitlePageDisplayType = 'hidden')
							  and $formatElements/PageGeometry/StandardPageRegion[contains($filter, @filter) and string-length(@filter) &gt; 0
											and @type = 'first']">
						<xsl:apply-templates select="current()" mode="writeContentWithTitlepage">
							<xsl:with-param name="internalID" select="$internalID"/>
							<xsl:with-param name="applyChildren" select="$applyChildren"/>
							<xsl:with-param name="isLast" select="$isLastBranch"/>
							<xsl:with-param name="outputBookMarker" select="$outputBookMarker"/>
							<xsl:with-param name="splitPageSequences" select="$splitPageSequences"/>
							<xsl:with-param name="pageRegionElem" select="$formatElements/PageGeometry/StandardPageRegion[contains($filter, @filter) and string-length(@filter) &gt; 0
											and @type = 'first']"/>
							<xsl:with-param name="isCustomPageSequence" select="true()"/>
						</xsl:apply-templates>
					</xsl:when>
					<xsl:otherwise>
						<xsl:apply-templates select="current()" mode="writeCustomPageSequence">
							<xsl:with-param name="internalID" select="$internalID"/>
							<xsl:with-param name="applyChildren" select="$applyChildren"/>
							<xsl:with-param name="isLastBranch" select="$isLastBranch"/>
							<xsl:with-param name="isLastInfoMap" select="$isLastInfoMap"/>
							<xsl:with-param name="filter" select="$filter"/>
							<xsl:with-param name="splitPageSequences" select="$splitPageSequences"/>
					<xsl:with-param name="inheritId" select="$inheritId"/>
						</xsl:apply-templates>
					</xsl:otherwise>
				</xsl:choose>
			</xsl:when>
			<xsl:when test="(not($isCustomPageSequence) or $allowNestedCustomPageSequences = 'true') and string-length(@inheritedFilter) &gt; 0
					  and $formatElements/PageGeometry/StandardPageRegion[contains(@inheritedFilter, @filter)]">
				<xsl:apply-templates select="current()" mode="writeCustomPageSequence">
					<xsl:with-param name="internalID" select="$internalID"/>
					<xsl:with-param name="applyChildren" select="$applyChildren"/>
					<xsl:with-param name="isLastBranch" select="$isLastBranch"/>
					<xsl:with-param name="isLastInfoMap" select="$isLastInfoMap"/>
					<xsl:with-param name="filter" select="@inheritedFilter"/>
					<xsl:with-param name="splitPageSequences" select="$splitPageSequences"/>
					<xsl:with-param name="inheritId" select="$inheritId"/>
				</xsl:apply-templates>
			</xsl:when>
			<xsl:when test="$useCustomPageSequenceForEmbeddedFormatElement and $isMULTI_STYLE_FORMATTING and Format">
				<xsl:apply-templates select="current()" mode="writeCustomPageSequence">
					<xsl:with-param name="internalID" select="$internalID"/>
					<xsl:with-param name="applyChildren" select="$applyChildren"/>
					<xsl:with-param name="isLastBranch" select="$isLastBranch"/>
					<xsl:with-param name="isLastInfoMap" select="$isLastInfoMap"/>
					<xsl:with-param name="filter" select="$filter"/>
					<xsl:with-param name="splitPageSequences" select="$splitPageSequences"/>
					<xsl:with-param name="pageRegionElem" select="Format/PageGeometry/StandardPageRegion[(string-length($filter) &gt; 0 and contains($filter, @filter) and string-length(@filter) &gt; 0)
					  or (string-length(@filter) = 0 and (string-length($filter) = 0 or not(../StandardPageRegion[contains($filter, @filter) and string-length(@filter) &gt; 0])))]"/>
					<xsl:with-param name="inheritId" select="$inheritId"/>
					<xsl:with-param name="customFormatElement" select="Format"/>
				</xsl:apply-templates>
			</xsl:when>
			<xsl:when test="block.titlepage">
				<xsl:apply-templates select="current()" mode="writeContentWithTitlepage">
					<xsl:with-param name="internalID" select="$internalID"/>
					<xsl:with-param name="applyChildren" select="$applyChildren"/>
					<xsl:with-param name="isLast" select="$isLastBranch"/>
					<xsl:with-param name="outputBookMarker" select="$outputBookMarker"/>
					<xsl:with-param name="splitPageSequences" select="$splitPageSequences"/>
					<xsl:with-param name="pageRegionElem" select="$formatElements/PageGeometry/StandardPageRegion[@type = 'first' and string-length(@filter) = 0]"/>
					<xsl:with-param name="inheritId" select="$inheritId"/>
				</xsl:apply-templates>
			</xsl:when>
			<xsl:otherwise>
				<xsl:apply-templates select="current()" mode="writeContent">
					<xsl:with-param name="applyChildren" select="$applyChildren"/>
					<xsl:with-param name="internalID" select="$internalID"/>
					<xsl:with-param name="isLast" select="$isLastBranch"/>
					<xsl:with-param name="hasCustomRegions" select="$hasCustomRegions"/>
					<xsl:with-param name="pageRegionElem" select="$formatElements/PageGeometry/StandardPageRegion[(@type = 'odd' or @type = 'even') and string-length(@filter) = 0]"/>
					<xsl:with-param name="splitPageSequences" select="$splitPageSequences"/>
					<xsl:with-param name="inheritId" select="$inheritId"/>
				</xsl:apply-templates>
			</xsl:otherwise>
		</xsl:choose>

	</xsl:template>

	<xsl:template match="URIDefinition" mode="writeUriSection">
		<xsl:param name="level">
			<xsl:apply-templates select="ancestor::InfoMap[1]" mode="getCurrentLevel"/>
		</xsl:param>
		<fo:block keep-with-next="true">
			<xsl:call-template name="addStyle">
				<xsl:with-param name="name">headline.content</xsl:with-param>
			</xsl:call-template>
			<xsl:apply-templates select="URI/node()"/>
		</fo:block>
		<fo:table width="100%" table-layout="fixed" keep-together.within-column="true">
			<fo:table-column column-width="4.5cm"/>
			<fo:table-column column-width="proportional-column-width(1)"/>
			<fo:table-body>
				<fo:table-row>
					<fo:table-cell>
						<fo:block>URI</fo:block>
					</fo:table-cell>
					<fo:table-cell>
						<fo:block>
							<xsl:apply-templates select="URI/node()"/>
						</fo:block>
					</fo:table-cell>
				</fo:table-row>
				<fo:table-row>
					<fo:table-cell>
						<fo:block>Link text</fo:block>
					</fo:table-cell>
					<fo:table-cell>
						<fo:block>
							<xsl:apply-templates select="Linktext/node()"/>
						</fo:block>
					</fo:table-cell>
				</fo:table-row>
				<xsl:if test="AltLinktext/node()">
					<fo:table-row>
						<fo:table-cell>
							<fo:block>Alternative link text</fo:block>
						</fo:table-cell>
						<fo:table-cell>
							<fo:block>
								<xsl:apply-templates select="AltLinktext/node()"/>
							</fo:block>
						</fo:table-cell>
					</fo:table-row>
				</xsl:if>
			</fo:table-body>
		</fo:table>
	</xsl:template>

	<xsl:template match="InfoMap" mode="writeFileSection">
		<xsl:param name="applyChildren"/>
		<xsl:param name="internalID"/>
		<xsl:param name="isLastBranch"/>
		<xsl:param name="isLastInfoMap"/>
		<xsl:param name="filter"/>

		<xsl:variable name="ID" select="@ID"/>
		<xsl:for-each select="Block">
			<xsl:for-each select=".//Link.File">
				<xsl:if test="string-length(@originalURL) &gt; 0 and @originalURL != '/media'">
					<psmi:page-sequence master-reference="basicPSM{$filter}" isExternalDoc="true">
						<fo:flow flow-name="xsl-region-body">
							<fox:external-document id="{$ID}">
								<xsl:choose>
									<xsl:when test="$isOffline">
										<xsl:attribute name="src">
											<xsl:value-of select="concat('file:///', translate($productionTempPath, '\', '/'))"/>
											<xsl:call-template name="escapeFileSystemPath">
												<xsl:with-param name="path" select="@originalURL"/>
											</xsl:call-template>
										</xsl:attribute>
									</xsl:when>
									<xsl:otherwise>
										<xsl:variable name="pre_picURL" select="concat(@serverURL, @escapedOriginalURL)"/>
										<xsl:attribute name="src">
											<xsl:choose>
												<xsl:when test="contains($pre_picURL, '?')">
													<xsl:value-of select="concat($pre_picURL, '&amp;dummy=', $TIMESTAMP)"/>
												</xsl:when>
												<xsl:otherwise>
													<xsl:value-of select="concat($pre_picURL, '?dummy=', $TIMESTAMP)"/>
												</xsl:otherwise>
											</xsl:choose>
										</xsl:attribute>
									</xsl:otherwise>
								</xsl:choose>
							</fox:external-document>
						</fo:flow>
					</psmi:page-sequence>
				</xsl:if>
			</xsl:for-each>
			<xsl:for-each select=".//Media.theme">
				<psmi:page-sequence master-reference="basicPSM{$filter}" isExternalDoc="true">
					<fo:flow flow-name="xsl-region-body">
						<fox:external-document id="{$ID}">
							<xsl:attribute name="src">
								<xsl:call-template name="getPicURL"/>
							</xsl:attribute>
						</fox:external-document>
					</fo:flow>
				</psmi:page-sequence>
			</xsl:for-each>
		</xsl:for-each>
	</xsl:template>

	<xsl:template match="InfoMap" mode="writeCustomPageSequence">
		<xsl:param name="applyChildren"/>
		<xsl:param name="internalID"/>
		<xsl:param name="isLastBranch"/>
		<xsl:param name="isLastInfoMap"/>
		<xsl:param name="filter"/>
		<xsl:param name="splitPageSequences" select="true()"/>
		<xsl:param name="pageRegionElem" select="$formatElements/PageGeometry/StandardPageRegion[contains($filter, @filter) and string-length(@filter) &gt; 0]"/>
		<xsl:param name="inheritId"/>
		<xsl:param name="customFormatElement"/>

		<xsl:variable name="hasCustomRegions" select="boolean($pageRegionElem[CustomRegions/Region])"/>
		<xsl:variable name="masterSuffix">
			<xsl:choose>
				<xsl:when test="$customFormatElement">
					<xsl:apply-templates select="$customFormatElement" mode="getMasterSuffix">
						<xsl:with-param name="level" select="$internalID"/>
					</xsl:apply-templates>
				</xsl:when>
				<xsl:otherwise>
			<xsl:apply-templates select="$pageRegionElem[1]" mode="getMasterSuffix">
				<xsl:with-param name="level" select="$internalID"/>
			</xsl:apply-templates>
				</xsl:otherwise>
			</xsl:choose>
		</xsl:variable>
		<xsl:variable name="forceStaticContent">
			<xsl:call-template name="getTemplateVariableValue">
				<xsl:with-param name="name">GENERATE_STATIC_CONTENT_FOR_CUSTOM_PAGE_SEQUENCE</xsl:with-param>
			</xsl:call-template>
		</xsl:variable>
		<psmi:page-sequence master-reference="basicPSM{$masterSuffix}">
			<xsl:variable name="level">
				<xsl:apply-templates select="current()" mode="getCurrentLevel"/>
			</xsl:variable>
			<xsl:call-template name="applyPageSequenceAttribute">
				<xsl:with-param name="attributeName">initial-page-number</xsl:with-param>
				<xsl:with-param name="level" select="$level"/>
			</xsl:call-template>
			<xsl:call-template name="applyPageSequenceAttribute">
				<xsl:with-param name="attributeName">force-page-count</xsl:with-param>
				<xsl:with-param name="level" select="$level"/>
			</xsl:call-template>
			<xsl:call-template name="applyPageSequenceAttribute">
				<xsl:with-param name="attributeName">format</xsl:with-param>
				<xsl:with-param name="level" select="$level"/>
			</xsl:call-template>			
			<xsl:if test="$hasCustomRegions or $forceStaticContent = 'true'">
				<xsl:choose>
					<xsl:when test="$customFormatElement">
						<xsl:call-template name="writeStaticContent">
							<xsl:with-param name="level" select="$masterSuffix"/>
							<xsl:with-param name="formatElement" select="$customFormatElement"/>
						</xsl:call-template>
					</xsl:when>
					<xsl:otherwise>
						<xsl:call-template name="writeStaticContent">
							<xsl:with-param name="level" select="$internalID"/>
						</xsl:call-template>
					</xsl:otherwise>
				</xsl:choose>
			</xsl:if>
			<fo:flow flow-name="xsl-region-body">
				<xsl:if test="$DISABLE_COLUMN_BALANCING">
					<xsl:attribute name="fox:disable-column-balancing">true</xsl:attribute>
				</xsl:if>
				<xsl:apply-templates select="current()" mode="writeContent">
					<xsl:with-param name="applyChildren" select="$applyChildren"/>
					<xsl:with-param name="internalID" select="$internalID"/>
					<xsl:with-param name="isLast" select="$isLastBranch"/>
					<xsl:with-param name="hasCustomRegions" select="$hasCustomRegions"/>
					<xsl:with-param name="pageRegionElem" select="$pageRegionElem"/>
					<xsl:with-param name="splitPageSequences" select="$splitPageSequences"/>
					<xsl:with-param name="isCustomPageSequence" select="true()"/>
					<xsl:with-param name="inheritId" select="$inheritId"/>
				</xsl:apply-templates>
			</fo:flow>
		</psmi:page-sequence>
	</xsl:template>

	<xsl:template match="block.titlepage" mode="getDisplayType">
		<xsl:choose>
			<xsl:when test="string-length(@Typ) &gt; 0">
				<xsl:call-template name="getTemplateVariableValue">
					<xsl:with-param name="name" select="concat('BLOCK_TITLEPAGE_', @Typ, '_DISPLAY_TYPE')"/>
					<xsl:with-param name="defaultValue">
						<xsl:call-template name="getTemplateVariableValue">
							<xsl:with-param name="name">BLOCK_TITLEPAGE_DISPLAY_TYPE</xsl:with-param>
						</xsl:call-template>
					</xsl:with-param>
				</xsl:call-template>
			</xsl:when>
			<xsl:otherwise>
				<xsl:call-template name="getTemplateVariableValue">
					<xsl:with-param name="name">BLOCK_TITLEPAGE_DISPLAY_TYPE</xsl:with-param>
				</xsl:call-template>
			</xsl:otherwise>
		</xsl:choose>
	</xsl:template>

	<xsl:template match="InfoMap" mode="writeContentWithTitlepage">
		<xsl:param name="internalID"/>
		<xsl:param name="applyChildren"/>
		<xsl:param name="isLast"/>
		<xsl:param name="splitPageSequences" select="true()"/>
		<xsl:param name="pageRegionElem"/>
		<xsl:param name="isCustomPageSequence"/>
		<xsl:param name="inheritId"/>

		<xsl:variable name="blockTitlePageDisplayType">
			<xsl:apply-templates select="block.titlepage[1]" mode="getDisplayType"/>
		</xsl:variable>

		<xsl:choose>
			<xsl:when test="$blockTitlePageDisplayType = 'hidden'">
				<xsl:apply-templates select="current()" mode="writeContent">
					<xsl:with-param name="applyChildren" select="$applyChildren"/>
					<xsl:with-param name="internalID" select="$internalID"/>
					<xsl:with-param name="isLast" select="$isLast"/>
					<xsl:with-param name="splitPageSequences" select="$splitPageSequences"/>
				</xsl:apply-templates>
			</xsl:when>
			<xsl:otherwise>
				<xsl:variable name="masterRefId">
					<xsl:choose>
						<xsl:when test="$isCustomPageSequence">
							<xsl:apply-templates select="$pageRegionElem[1]" mode="getMasterSuffix">
								<xsl:with-param name="level" select="$internalID"/>
							</xsl:apply-templates>
						</xsl:when>
						<xsl:otherwise>
							<xsl:value-of select="$internalID"/>
						</xsl:otherwise>
					</xsl:choose>
				</xsl:variable>
				<xsl:variable name="autoPageBreak">
					<xsl:call-template name="getTemplateVariableValue">
						<xsl:with-param name="name">TITLEPAGE_AUTO_PAGEBREAK</xsl:with-param>
						<xsl:with-param name="defaultValue">true</xsl:with-param>
					</xsl:call-template>
				</xsl:variable>
				<psmi:page-sequence master-reference="first{$masterRefId}">
					<fo:flow flow-name="xsl-region-body">
						<xsl:if test="$DISABLE_COLUMN_BALANCING">
							<xsl:attribute name="fox:disable-column-balancing">true</xsl:attribute>
						</xsl:if>
						<xsl:call-template name="addStyle">
							<xsl:with-param name="name">titlepage</xsl:with-param>
						</xsl:call-template>
						<xsl:variable name="regions" select="($pageRegionElem/CustomRegions/Region)"/>
						<xsl:choose>
							<xsl:when test="count($regions) &gt; 0">
								<xsl:apply-templates select="$regions[1]" mode="normal">
									<xsl:with-param name="id" select="@ID"/>
									<xsl:with-param name="currentElement" select="current()"/>
									<xsl:with-param name="useMarker" select="false()"/>
								</xsl:apply-templates>
								<xsl:apply-templates select="$regions[position() &gt; 1]" mode="normal">
									<xsl:with-param name="currentElement" select="current()"/>
									<xsl:with-param name="useMarker" select="false()"/>
								</xsl:apply-templates>
							</xsl:when>
							<xsl:otherwise>
								<xsl:apply-templates select="current()" mode="writeContent">
									<xsl:with-param name="applyChildren" select="false()"/>
									<xsl:with-param name="internalID" select="$internalID"/>
									<xsl:with-param name="isLast" select="$isLast"/>
									<xsl:with-param name="splitPageSequences" select="$splitPageSequences"/>
									<xsl:with-param name="inheritId" select="$inheritId"/>
								</xsl:apply-templates>
							</xsl:otherwise>
						</xsl:choose>
						<xsl:if test="$autoPageBreak = 'false' and $applyChildren">
							<xsl:apply-templates select="InfoMap">
								<xsl:with-param name="internalID" select="$internalID"/>
								<xsl:with-param name="isLast" select="$isLast"/>
								<xsl:with-param name="splitPageSequences" select="$splitPageSequences"/>
							</xsl:apply-templates>
						</xsl:if>
					</fo:flow>
				</psmi:page-sequence>
				<xsl:if test="not($autoPageBreak = 'false') and $applyChildren">
					<xsl:apply-templates select="InfoMap">
						<xsl:with-param name="internalID" select="$internalID"/>
						<xsl:with-param name="isLast" select="$isLast"/>
						<xsl:with-param name="splitPageSequences" select="$splitPageSequences"/>
					</xsl:apply-templates>
				</xsl:if>
			</xsl:otherwise>
		</xsl:choose>
	</xsl:template>

	<xsl:template match="InfoMap" mode="writeHeadlineContent">
		<xsl:param name="level">
			<xsl:apply-templates select="current()" mode="getCurrentLevel"/>
		</xsl:param>
		<xsl:param name="keep-with-next">always</xsl:param>
		<xsl:param name="internalID"/>
		<xsl:param name="customRegionElem"/>
		<xsl:param name="hasCustomRegions"/>
		<xsl:param name="pageRegionElem"/>
		<xsl:param name="splitPageSequences" select="true()"/>
		<xsl:param name="inheritId"/>

		<xsl:apply-templates select="Headline.theme" mode="writeHeadlineTheme">
			<xsl:with-param name="keep-with-next" select="$keep-with-next"/>
			<xsl:with-param name="customRegionElem" select="$customRegionElem"/>
			<xsl:with-param name="hasCustomRegions" select="$hasCustomRegions"/>
			<xsl:with-param name="pageRegionElem" select="$pageRegionElem"/>
			<xsl:with-param name="headlineThemePosition">top</xsl:with-param>
		</xsl:apply-templates>

		<xsl:apply-templates select="current()" mode="writeHeadlineContentInternal">
			<xsl:with-param name="internalID" select="$internalID"/>
			<xsl:with-param name="splitPageSequences" select="$splitPageSequences"/>
			<xsl:with-param name="keep-with-next" select="$keep-with-next"/>
			<xsl:with-param name="customRegionElem" select="$customRegionElem"/>
			<xsl:with-param name="inheritId" select="$inheritId"/>
		</xsl:apply-templates>

		<xsl:apply-templates select="Headline.theme" mode="writeHeadlineTheme">
			<xsl:with-param name="keep-with-next" select="$keep-with-next"/>
			<xsl:with-param name="customRegionElem" select="$customRegionElem"/>
			<xsl:with-param name="hasCustomRegions" select="$hasCustomRegions"/>
			<xsl:with-param name="pageRegionElem" select="$pageRegionElem"/>
			<xsl:with-param name="headlineThemePosition">bottom</xsl:with-param>
		</xsl:apply-templates>
	</xsl:template>

	<xsl:template match="Headline.theme" mode="writeHeadlineTheme">
		<xsl:param name="position"/>
		<xsl:param name="keep-with-next"/>
		<xsl:param name="hasCustomRegions"/>
		<xsl:param name="pageRegionElem"/>
		<xsl:param name="headlineThemePosition">top</xsl:param>

		<xsl:variable name="defaultHeadlineThemePosition">
			<xsl:call-template name="getTemplateVariableValue">
				<xsl:with-param name="name">HEADLINE_THEME_POSITION</xsl:with-param>
				<xsl:with-param name="defaultValue">top</xsl:with-param>
			</xsl:call-template>
		</xsl:variable>

		<xsl:if test="string-length(.) &gt; 0 and $headlineThemePosition = $defaultHeadlineThemePosition  and (not($hasCustomRegions) or not($pageRegionElem/CustomRegions/Region[@assignContentType = 'headline.theme']))">
			<xsl:variable name="mode">
				<xsl:call-template name="getTemplateVariableValue">
					<xsl:with-param name="name">HEADLINE_THEME_DISPLAY_TYPE</xsl:with-param>
					<xsl:with-param name="defaultValue">complex</xsl:with-param>
				</xsl:call-template>
			</xsl:variable>
			<xsl:if test="not($mode = 'none') and (($position = 'inline' and $mode = 'inline') or ($position != 'inline' and $mode != 'inline'))">
				<fo:block keep-with-next="{$keep-with-next}">
					<xsl:for-each select="ancestor::InfoMap[1]">
						<xsl:if test="string-length(@defaultLanguage) &gt; 0 and ancestor::InfoMap/@defaultLanguage != @defaultLanguage">
							<xsl:apply-templates select="current()" mode="writeDefaultStyle"/>
						</xsl:if>
					</xsl:for-each>
					<xsl:call-template name="addStyle">
						<xsl:with-param name="name">headline.theme</xsl:with-param>
					</xsl:call-template>
					<xsl:apply-templates/>
				</fo:block>
			</xsl:if>
		</xsl:if>
	</xsl:template>

	<xsl:template match="InfoMap" mode="writeHeadlineContentInternal">
		<xsl:param name="level">
			<xsl:apply-templates select="current()" mode="getCurrentLevel"/>
		</xsl:param>
		<xsl:param name="internalID"/>
		<xsl:param name="splitPageSequences" select="true()"/>
		<xsl:param name="keep-with-next">always</xsl:param>
		<xsl:param name="customRegionElem"/>
		<xsl:param name="inheritId"/>

		<fo:block keep-with-next="{$keep-with-next}">
			<xsl:if test="string-length(@defaultLanguage) &gt; 0 and ancestor::InfoMap/@defaultLanguage != @defaultLanguage">
				<xsl:apply-templates select="current()" mode="writeDefaultStyle"/>
			</xsl:if>
			<xsl:apply-templates select="current()" mode="writeSectionPageBreak">
				<xsl:with-param name="level" select="$level"/>
			</xsl:apply-templates>
			<xsl:call-template name="addStyle">
				<xsl:with-param name="name" select="'headline.content-container'"/>
			</xsl:call-template>
			<xsl:call-template name="addStyle">
				<xsl:with-param name="name" select="concat('headline.content.', $level, '-container')"/>
			</xsl:call-template>
			<xsl:for-each select="Headline.content[1]">
				<!-- because again because of different element context -->
				<xsl:call-template name="addStyle">
					<xsl:with-param name="name" select="'headline.content-container'"/>
				</xsl:call-template>
				<xsl:call-template name="addStyle">
					<xsl:with-param name="name" select="'headline.content'"/>
					<xsl:with-param name="attributeNamesList">|span|</xsl:with-param>
				</xsl:call-template>
				<xsl:call-template name="addStyle">
					<xsl:with-param name="name" select="concat('headline.content.', $level)"/>
					<xsl:with-param name="attributeNamesList">|span|</xsl:with-param>
				</xsl:call-template>
			</xsl:for-each>
			<xsl:choose>
				<xsl:when test="string-length(@ID) &gt; 0">
					<xsl:attribute name="id">
						<xsl:value-of select="@ID"/>
					</xsl:attribute>
					<xsl:if test="not($customRegionElem)">
						<xsl:apply-templates select="current()" mode="writeMarker">
							<xsl:with-param name="internalID" select="$internalID"/>
							<xsl:with-param name="splitPageSequences" select="$splitPageSequences"/>
						</xsl:apply-templates>
					</xsl:if>
					<xsl:apply-templates select="current()" mode="writeDestination"/>
				</xsl:when>
				<xsl:when test="not($customRegionElem)">
					<xsl:apply-templates select="current()" mode="writeMarker">
						<xsl:with-param name="internalID" select="$internalID"/>
						<xsl:with-param name="splitPageSequences" select="$splitPageSequences"/>
					</xsl:apply-templates>
				</xsl:when>
			</xsl:choose>
			<xsl:choose>
				<xsl:when test="string-length($inheritId) &gt; 0">
					<xsl:call-template name="outputInheritIds">
						<xsl:with-param name="inheritIds" select="$inheritId"/>
						<xsl:with-param name="contentElem" select="Headline.content"/>
					</xsl:call-template>
				</xsl:when>
				<xsl:otherwise>
			<xsl:apply-templates select="Headline.content"/>
				</xsl:otherwise>
			</xsl:choose>
		</fo:block>
	</xsl:template>

	<xsl:template match="InfoMap" mode="doShowHeadlineContent">
		<xsl:param name="level"/>
		<xsl:variable name="blockTitlePageDisplayType">
			<xsl:choose>
				<xsl:when test="block.titlepage">
					<xsl:apply-templates select="block.titlepage[1]" mode="getDisplayType"/>
				</xsl:when>
				<xsl:otherwise>
					<xsl:call-template name="getTemplateVariableValue">
						<xsl:with-param name="name">BLOCK_TITLEPAGE_DISPLAY_TYPE</xsl:with-param>
					</xsl:call-template>
				</xsl:otherwise>
			</xsl:choose>
		</xsl:variable>
		<xsl:variable name="mode">
			<xsl:call-template name="getTemplateVariableValue">
				<xsl:with-param name="name" select="concat('HEADLINE_CONTENT_', $level, '_DISPLAY_TYPE')"/>
				<xsl:with-param name="defaultValue">complex</xsl:with-param>
			</xsl:call-template>
		</xsl:variable>
		<xsl:variable name="visible">
			<xsl:call-template name="getFormat">
				<xsl:with-param name="name" select="concat('headline.content.', $level)"/>
				<xsl:with-param name="attributeName">visibility</xsl:with-param>
				<xsl:with-param name="defaultValue">
					<xsl:call-template name="getFormat">
						<xsl:with-param name="name">headline.content</xsl:with-param>
						<xsl:with-param name="attributeName">visibility</xsl:with-param>
					</xsl:call-template>
				</xsl:with-param>
			</xsl:call-template>
		</xsl:variable>
		<xsl:if test="string-length(Headline.content) &gt; 0 and (not(block.titlepage) or $blockTitlePageDisplayType = 'hidden') and not($mode = 'none') and not($visible = 'hidden')">true</xsl:if>
	</xsl:template>

	<xsl:template match="InfoMap" mode="writeContent">
		<xsl:param name="applyChildren"/>
		<xsl:param name="internalID"/>
		<xsl:param name="isLast"/>
		<xsl:param name="customRegionElem"/>
		<xsl:param name="splitPageSequences" select="true()"/>
		<xsl:param name="isLastBranch" select="$isLast and not(following-sibling::InfoMap)"/>
		<xsl:param name="hasCustomRegions"/>
		<xsl:param name="pageRegionElem" select="$formatElements/PageGeometry/StandardPageRegion[(@type = 'odd' or @type = 'even') and string-length(@filter) = 0]"/>
		<xsl:param name="isCustomPageSequence" select="false()"/>
		<xsl:param name="inheritId"/>

		<xsl:apply-templates select="current()" mode="writeContentInternal">
			<xsl:with-param name="applyChildren" select="$applyChildren"/>
			<xsl:with-param name="internalID" select="$internalID"/>
			<xsl:with-param name="isLast" select="$isLast"/>
			<xsl:with-param name="isLastBranch" select="$isLastBranch"/>
			<xsl:with-param name="customRegionElem" select="$customRegionElem"/>
			<xsl:with-param name="hasCustomRegions" select="$hasCustomRegions"/>
			<xsl:with-param name="pageRegionElem" select="$pageRegionElem"/>
			<xsl:with-param name="splitPageSequences" select="$splitPageSequences"/>
			<xsl:with-param name="isCustomPageSequence" select="$isCustomPageSequence"/>
			<xsl:with-param name="inheritId" select="$inheritId"/>
		</xsl:apply-templates>
	</xsl:template>

	<xsl:template match="InfoMap" mode="getSectionMarginalColumnWidthPx">
		<xsl:param name="level"/>
		<xsl:choose>
			<xsl:when test="string-length(@Typ) &gt; 0">
				<xsl:call-template name="getPixels">
					<xsl:with-param name="value">
						<xsl:call-template name="getTemplateVariableValue">
							<xsl:with-param name="name" select="concat('SECTION_MARGINAL_COLUMN_WIDTH.', @Typ)"/>
							<xsl:with-param name="defaultValue">
								<xsl:call-template name="getTemplateVariableValue">
									<xsl:with-param name="name" select="concat('SECTION_MARGINAL_COLUMN_WIDTH.', $level)"/>
									<xsl:with-param name="defaultValue">0cm</xsl:with-param>
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
						<xsl:call-template name="getTemplateVariableValue">
							<xsl:with-param name="name" select="concat('SECTION_MARGINAL_COLUMN_WIDTH.', $level)"/>
							<xsl:with-param name="defaultValue">0cm</xsl:with-param>
						</xsl:call-template>
					</xsl:with-param>
					<xsl:with-param name="dpi" select="$OUTPUT_RESOLUTION"/>
				</xsl:call-template>
			</xsl:otherwise>
		</xsl:choose>
	</xsl:template>

	<xsl:template match="InfoMap" mode="writeSectionPageBreak">
		<xsl:param name="level">
			<xsl:apply-templates select="current()" mode="getCurrentLevel"/>
		</xsl:param>
		<xsl:call-template name="addStyle">
			<xsl:with-param name="name">section</xsl:with-param>
			<xsl:with-param name="attributeNamesList">|page-break-before|</xsl:with-param>
		</xsl:call-template>
		<xsl:variable name="autoFixPageBreaks">
			<xsl:call-template name="getTemplateVariableValue">
				<xsl:with-param name="name">HEADLINE_CONTENT_AUTO_FIX_PAGE_BREAKS</xsl:with-param>
				<xsl:with-param name="defaultValue">false</xsl:with-param>
			</xsl:call-template>
		</xsl:variable>
		<xsl:apply-templates select="current()" mode="applyPageBreak">
			<xsl:with-param name="level" select="$level"/>
			<xsl:with-param name="autoFixPageBreaks" select="$autoFixPageBreaks = 'true'"/>
		</xsl:apply-templates>
	</xsl:template>

	<xsl:template name="outputInheritIds">
		<xsl:param name="inheritIds"/>
		<xsl:param name="contentElem"/>
		<xsl:choose>
			<xsl:when test="contains($inheritIds, '|')">
				<fo:block id="{substring-before($inheritIds, '|')}">
					<xsl:call-template name="outputInheritIds">
						<xsl:with-param name="inheritIds" select="substring-after($inheritIds, '|')"/>
						<xsl:with-param name="contentElem" select="$contentElem"/>
					</xsl:call-template>
				</fo:block>
			</xsl:when>
			<xsl:when test="string-length($inheritIds) &gt; 0">
				<fo:block id="{$inheritIds}">
					<xsl:if test="$contentElem">
						<xsl:apply-templates select="$contentElem"/>
					</xsl:if>
				</fo:block>
			</xsl:when>
		</xsl:choose>
	</xsl:template>

	<xsl:template match="InfoMap" mode="writeContentInternal">
		<xsl:param name="applyChildren"/>
		<xsl:param name="internalID"/>
		<xsl:param name="isLast"/>
		<xsl:param name="isLastBranch"/>
		<xsl:param name="customRegionElem"/>
		<xsl:param name="hasCustomRegions"/>
		<xsl:param name="pageRegionElem" select="$formatElements/PageGeometry/StandardPageRegion[(@type = 'odd' or @type = 'even') and string-length(@filter) = 0]"/>
		<xsl:param name="splitPageSequences" select="true()"/>
		<xsl:param name="isCustomPageSequence" select="false()"/>
		<xsl:param name="inheritId"/>

		<xsl:variable name="isLastInfoMap" select="$isLastBranch and not(InfoMap)"/>
		<xsl:variable name="ID" select="@ID"/>

				<xsl:variable name="level">
					<xsl:apply-templates select="current()" mode="getCurrentLevel"/>
				</xsl:variable>

				<xsl:variable name="doShowHeadlineContent">
					<xsl:choose>
						<xsl:when test="$hasCustomRegions and $pageRegionElem/CustomRegions/Region[@assignContentType = 'Title']">false</xsl:when>
						<xsl:otherwise>
							<xsl:apply-templates select="current()" mode="doShowHeadlineContent">
								<xsl:with-param name="level" select="$level"/>
							</xsl:apply-templates>
						</xsl:otherwise>
					</xsl:choose>
				</xsl:variable>

				<xsl:variable name="showHeadlineContent" select="$doShowHeadlineContent = 'true'"/>

				<xsl:variable name="hasID" select="string-length(@ID) &gt; 0"/>

		<xsl:variable name="outputDocPlaceholder">
			<xsl:call-template name="getTemplateVariableValue">
				<xsl:with-param name="name">USE_EMPTY_DOCUMENT_PLACEHOLDER</xsl:with-param>
			</xsl:call-template>
		</xsl:variable>

		<xsl:variable name="currInheritId">
			<xsl:if test="not($showHeadlineContent) and not(Block or block.titlepage) and $hasID and $outputDocPlaceholder = 'false' and InfoMap">
				<xsl:if test="string-length($inheritId)">
					<xsl:value-of select="concat($inheritId, '|')"/>
				</xsl:if>
				<xsl:value-of select="@ID"/>
			</xsl:if>
		</xsl:variable>

		<xsl:choose>
			<xsl:when test="not($hasCustomRegions) or not($pageRegionElem/CustomRegions/Region[@assignContentType = 'All'])">

				<xsl:variable name="sectionSpan">
					<xsl:call-template name="getFormat">
						<xsl:with-param name="name">section</xsl:with-param>
						<xsl:with-param name="attributeName">span</xsl:with-param>
					</xsl:call-template>
				</xsl:variable>

				<xsl:variable name="sectionOrphans">
					<xsl:call-template name="getFormat">
						<xsl:with-param name="name" select="concat('section.', $level)"/>
						<xsl:with-param name="attributeName">orphans</xsl:with-param>
						<xsl:with-param name="defaultValue" select="0"/>
					</xsl:call-template>
				</xsl:variable>

				<xsl:variable name="marginColumnWidthPx">
					<xsl:apply-templates select="current()" mode="getSectionMarginalColumnWidthPx">
						<xsl:with-param name="level" select="$level"/>
					</xsl:apply-templates>
				</xsl:variable>

				<xsl:choose>
					<xsl:when test="$showHeadlineContent">
						<xsl:if test="not($sectionSpan = 'all' or $marginColumnWidthPx &gt; 0)">
							<xsl:apply-templates select="current()" mode="writeHeadlineContent">
								<xsl:with-param name="level" select="$level"/>
								<xsl:with-param name="internalID" select="$internalID"/>
								<xsl:with-param name="customRegionElem" select="$customRegionElem"/>
								<xsl:with-param name="hasCustomRegions" select="$hasCustomRegions"/>
								<xsl:with-param name="pageRegionElem" select="$pageRegionElem"/>
						<xsl:with-param name="splitPageSequences" select="$splitPageSequences"/>
								<xsl:with-param name="inheritId" select="$inheritId"/>
							</xsl:apply-templates>
						</xsl:if>
					</xsl:when>
					<xsl:when test="not($showHeadlineContent) and not(Block or block.titlepage) and $hasID and (not($outputDocPlaceholder = 'false') or not(InfoMap))">
						<fo:block id="{@ID}">
							<xsl:apply-templates select="current()" mode="writeSectionPageBreak">
								<xsl:with-param name="level" select="$level"/>
							</xsl:apply-templates>
							<xsl:if test="not($customRegionElem)">
								<xsl:apply-templates select="current()" mode="writeMarker">
									<xsl:with-param name="internalID" select="$internalID"/>
									<xsl:with-param name="splitPageSequences" select="$splitPageSequences"/>
								</xsl:apply-templates>
							</xsl:if>
						</fo:block>
					</xsl:when>
				</xsl:choose>

				<xsl:variable name="outputBlocks" select="not($hasCustomRegions) or not($pageRegionElem/CustomRegions/Region[@assignContentType = 'Block'])"/>

				<xsl:choose>
					<xsl:when test="$marginColumnWidthPx &gt; 0">
						<xsl:variable name="sectionMarginalBlockCount">
							<xsl:call-template name="getTemplateVariableValue">
								<xsl:with-param name="name" select="concat('SECTION_MARGINAL_BLOCK_COUNT.', $level)"/>
								<xsl:with-param name="defaultValue">
									<xsl:call-template name="getTemplateVariableValue">
										<xsl:with-param name="name">SECTION_MARGINAL_BLOCK_COUNT</xsl:with-param>
									</xsl:call-template>
								</xsl:with-param>
							</xsl:call-template>
						</xsl:variable>
						<fo:block start-indent="0" end-indent="0">
							<xsl:if test="string-length(@defaultLanguage) &gt; 0 and ancestor::InfoMap/@defaultLanguage != @defaultLanguage">
								<xsl:apply-templates select="current()" mode="writeDefaultStyle"/>
							</xsl:if>
							<xsl:call-template name="addStyle">
								<xsl:with-param name="name">section</xsl:with-param>
							</xsl:call-template>
							<xsl:call-template name="addStyle">
								<xsl:with-param name="name" select="concat('section.', $level)"/>
							</xsl:call-template>
							<xsl:choose>
								<xsl:when test="not($showHeadlineContent) and $hasID">
									<xsl:attribute name="id">
										<xsl:value-of select="$ID"/>
									</xsl:attribute>
									<xsl:if test="not($customRegionElem)">
										<xsl:apply-templates select="current()" mode="writeMarker">
											<xsl:with-param name="internalID" select="$internalID"/>
											<xsl:with-param name="splitPageSequences" select="$splitPageSequences"/>
										</xsl:apply-templates>
									</xsl:if>
									<xsl:apply-templates select="current()" mode="writeDestination">
										<xsl:with-param name="ID" select="$ID"/>
									</xsl:apply-templates>
									<xsl:if test="string-length($inheritId) &gt; 0">
										<xsl:call-template name="outputInheritIds">
											<xsl:with-param name="inheritIds" select="$inheritId"/>
										</xsl:call-template>
									</xsl:if>
								</xsl:when>
								<xsl:when test="not($customRegionElem)">
									<xsl:apply-templates select="current()" mode="writeMarker">
										<xsl:with-param name="internalID" select="$internalID"/>
										<xsl:with-param name="splitPageSequences" select="$splitPageSequences"/>
									</xsl:apply-templates>
								</xsl:when>
							</xsl:choose>
							<xsl:variable name="SPACER_COLUMN_WIDTH">
								<xsl:call-template name="getTemplateVariableValue">
									<xsl:with-param name="name">SPACER_COLUMN_WIDTH</xsl:with-param>
									<xsl:with-param name="defaultValue">0cm</xsl:with-param>
								</xsl:call-template>
							</xsl:variable>
							<fo:table table-layout="fixed" width="100%">
								<xsl:call-template name="addStyle">
									<xsl:with-param name="name">section.table</xsl:with-param>
								</xsl:call-template>
								<fo:table-column column-width="{$marginColumnWidthPx}px"/>
								<fo:table-column column-width="{$SPACER_COLUMN_WIDTH}"/>
								<fo:table-column column-width="proportional-column-width(1)"/>
								<fo:table-body>
									<fo:table-row>
										<fo:table-cell>
											<xsl:choose>
												<xsl:when test="$showHeadlineContent">
													<xsl:apply-templates select="current()" mode="writeHeadlineContent">
														<xsl:with-param name="level" select="$level"/>
														<xsl:with-param name="internalID" select="$internalID"/>
														<xsl:with-param name="splitPageSequences" select="$splitPageSequences"/>
														<xsl:with-param name="keep-with-next">auto</xsl:with-param>
														<xsl:with-param name="customRegionElem" select="$customRegionElem"/>
														<xsl:with-param name="hasCustomRegions" select="$hasCustomRegions"/>
														<xsl:with-param name="pageRegionElem" select="$pageRegionElem"/>
														<xsl:with-param name="inheritId" select="$inheritId"/>
													</xsl:apply-templates>
												</xsl:when>
												<xsl:otherwise>
													<fo:block></fo:block>
												</xsl:otherwise>
											</xsl:choose>
										</fo:table-cell>
										<fo:table-cell>
											<fo:block></fo:block>
										</fo:table-cell>
										<fo:table-cell>
											<xsl:choose>
												<xsl:when test="not($outputBlocks)">
													<fo:block></fo:block>
												</xsl:when>
												<xsl:when test="string(number($sectionMarginalBlockCount)) != 'NaN'">
													<xsl:for-each select="(Block | Block.remark | block.titlepage)[position() &lt;= number($sectionMarginalBlockCount)]">
														<fo:block widows="1" orphans="1">
															<xsl:apply-templates select="current()"/>
														</fo:block>
													</xsl:for-each>
												</xsl:when>
												<xsl:otherwise>
													<xsl:for-each select="Block | Block.remark | block.titlepage | Include.Block">
														<fo:block widows="1" orphans="1">
															<xsl:apply-templates select="current()">
																<xsl:with-param name="customRegionElem" select="$customRegionElem"/>
																<xsl:with-param name="hasCustomRegions" select="$hasCustomRegions"/>
																<xsl:with-param name="pageRegionElem" select="$pageRegionElem"/>
															</xsl:apply-templates>
														</fo:block>
													</xsl:for-each>
												</xsl:otherwise>
											</xsl:choose>
										</fo:table-cell>
									</fo:table-row>
								</fo:table-body>
							</fo:table>
							<xsl:if test="$outputBlocks and string(number($sectionMarginalBlockCount)) != 'NaN'">
								<xsl:for-each select="(Block | Block.remark | block.titlepage)[position() &gt; number($sectionMarginalBlockCount)]">
									<fo:block widows="1" orphans="1">
										<xsl:apply-templates select="current()">
											<xsl:with-param name="customRegionElem" select="$customRegionElem"/>
											<xsl:with-param name="hasCustomRegions" select="$hasCustomRegions"/>
											<xsl:with-param name="pageRegionElem" select="$pageRegionElem"/>
										</xsl:apply-templates>
									</fo:block>
								</xsl:for-each>
							</xsl:if>
						</fo:block>
					</xsl:when>
					<xsl:when test="$sectionSpan = 'all'">
						<fo:block>
							<xsl:if test="string-length(@defaultLanguage) &gt; 0 and ancestor::InfoMap/@defaultLanguage != @defaultLanguage">
								<xsl:apply-templates select="current()" mode="writeDefaultStyle"/>
							</xsl:if>
							<xsl:call-template name="addStyle">
								<xsl:with-param name="name">section</xsl:with-param>
							</xsl:call-template>
							<xsl:choose>
								<xsl:when test="not($showHeadlineContent) and $hasID">
									<xsl:attribute name="id">
										<xsl:value-of select="$ID"/>
									</xsl:attribute>
									<xsl:if test="not($customRegionElem)">
										<xsl:apply-templates select="current()" mode="writeMarker">
											<xsl:with-param name="internalID" select="$internalID"/>
											<xsl:with-param name="splitPageSequences" select="$splitPageSequences"/>
										</xsl:apply-templates>
									</xsl:if>
									<xsl:apply-templates select="current()" mode="writeDestination"/>
									<xsl:if test="string-length($inheritId) &gt; 0">
										<xsl:call-template name="outputInheritIds">
											<xsl:with-param name="inheritIds" select="$inheritId"/>
										</xsl:call-template>
									</xsl:if>
								</xsl:when>
								<xsl:when test="not($customRegionElem)">
							<xsl:apply-templates select="current()" mode="writeMarker">
								<xsl:with-param name="internalID" select="$internalID"/>
								<xsl:with-param name="splitPageSequences" select="$splitPageSequences"/>
							</xsl:apply-templates>
								</xsl:when>
							</xsl:choose>
							<xsl:if test="$showHeadlineContent">
								<xsl:apply-templates select="current()" mode="writeHeadlineContent">
									<xsl:with-param name="level" select="$level"/>
									<xsl:with-param name="internalID" select="$internalID"/>
									<xsl:with-param name="customRegionElem" select="$customRegionElem"/>
									<xsl:with-param name="hasCustomRegions" select="$hasCustomRegions"/>
									<xsl:with-param name="pageRegionElem" select="$pageRegionElem"/>
									<xsl:with-param name="splitPageSequences" select="$splitPageSequences"/>
									<xsl:with-param name="inheritId" select="$inheritId"/>
								</xsl:apply-templates>
							</xsl:if>
							<xsl:if test="$outputBlocks">
								<xsl:for-each select="Block | Block.remark | block.titlepage | InfoMap[@isSubSection] | include.document/InfoMap[@isSubSection] | Include.Block">
									<fo:block widows="1" orphans="1">
										<xsl:choose>
											<xsl:when test="name() = 'InfoMap'">
												<xsl:if test="parent::include.document">
													<!-- mainly for diff highlighint -->
													<xsl:call-template name="addStyle">
														<xsl:with-param name="name">include.document</xsl:with-param>
														<xsl:with-param name="currentElement" select="parent::*"/>
													</xsl:call-template>
												</xsl:if>
												<xsl:apply-templates select="current()" mode="writeContent">
													<xsl:with-param name="internalID" select="$internalID"/>
													<xsl:with-param name="isLast" select="$isLastBranch"/>
													<xsl:with-param name="applyChildren" select="$applyChildren"/>
												</xsl:apply-templates>
											</xsl:when>
											<xsl:when test="name() = 'Include.Block'">
												<xsl:apply-templates select="current()"/>
											</xsl:when>
											<xsl:otherwise>
												<fo:block>
													<xsl:apply-templates select="current()">
														<xsl:with-param name="customRegionElem" select="$customRegionElem"/>
														<xsl:with-param name="hasCustomRegions" select="$hasCustomRegions"/>
														<xsl:with-param name="pageRegionElem" select="$pageRegionElem"/>
													</xsl:apply-templates>
												</fo:block>
											</xsl:otherwise>
										</xsl:choose>
									</fo:block>
								</xsl:for-each>
							</xsl:if>
						</fo:block>
					</xsl:when>
					<xsl:when test="$sectionOrphans &gt; 0 and (Block or Block.remark or block.titlepage or InfoMap[@isSubSection] or include.document/InfoMap[@isSubSection])">
						<fo:block orphans="{$sectionOrphans}">
							<xsl:if test="string-length(@defaultLanguage) &gt; 0 and ancestor::InfoMap/@defaultLanguage != @defaultLanguage">
								<xsl:apply-templates select="current()" mode="writeDefaultStyle"/>
							</xsl:if>
							<xsl:call-template name="addStyle">
								<xsl:with-param name="name">section</xsl:with-param>
								<xsl:with-param name="attributeNamesList">|widows|</xsl:with-param>
							</xsl:call-template>
							<xsl:if test="$outputBlocks">
								<xsl:for-each select="Block | Block.remark | block.titlepage | InfoMap[@isSubSection] | include.document/InfoMap[@isSubSection] | Include.Block">
									<fo:block widows="1" orphans="1">
										<xsl:call-template name="addStyle">
											<xsl:with-param name="name">container-block</xsl:with-param>
											<xsl:with-param name="attributeNamesList">|span|</xsl:with-param>
										</xsl:call-template>
										<xsl:call-template name="addStyle">
											<xsl:with-param name="name" select="concat('container-block.', substring-after(@Function, '.'))"/>
											<xsl:with-param name="attributeNamesList">|span|</xsl:with-param>
										</xsl:call-template>
										<xsl:if test="parent::include.document">
											<!-- mainly for diff highlighint -->
											<xsl:call-template name="addStyle">
												<xsl:with-param name="name">include.document</xsl:with-param>
												<xsl:with-param name="currentElement" select="parent::*"/>
											</xsl:call-template>
										</xsl:if>

										<xsl:choose>
											<xsl:when test="position() = 1 and not($showHeadlineContent) and $hasID">
												<xsl:attribute name="id">
													<xsl:value-of select="$ID"/>
												</xsl:attribute>
												<xsl:apply-templates select="parent::*" mode="writeSectionPageBreak">
													<xsl:with-param name="level" select="$level"/>
												</xsl:apply-templates>
												<xsl:if test="not($customRegionElem)">
													<xsl:apply-templates select="parent::*" mode="writeMarker">
														<xsl:with-param name="internalID" select="$internalID"/>
														<xsl:with-param name="splitPageSequences" select="$splitPageSequences"/>
													</xsl:apply-templates>
												</xsl:if>
												<xsl:apply-templates select="parent::*" mode="writeDestination">
													<xsl:with-param name="ID" select="$ID"/>
												</xsl:apply-templates>
												<xsl:if test="string-length($inheritId) &gt; 0">
													<xsl:call-template name="outputInheritIds">
														<xsl:with-param name="inheritIds" select="$inheritId"/>
													</xsl:call-template>
												</xsl:if>
											</xsl:when>
											<xsl:when test="not($customRegionElem)">
												<xsl:apply-templates select="parent::*" mode="writeMarker">
													<xsl:with-param name="internalID" select="$internalID"/>
													<xsl:with-param name="splitPageSequences" select="$splitPageSequences"/>
												</xsl:apply-templates>
											</xsl:when>
										</xsl:choose>

										<xsl:apply-templates select="current()">
											<xsl:with-param name="customRegionElem" select="$customRegionElem"/>
											<xsl:with-param name="hasCustomRegions" select="$hasCustomRegions"/>
											<xsl:with-param name="pageRegionElem" select="$pageRegionElem"/>
										</xsl:apply-templates>
									</fo:block>
								</xsl:for-each>
							</xsl:if>
						</fo:block>
					</xsl:when>
					<xsl:when test="$outputBlocks">
						<xsl:for-each select="Block | Block.remark | block.titlepage | InfoMap[@isSubSection] | include.document/InfoMap[@isSubSection] | Include.Block">
							<xsl:choose>
								<xsl:when test="name() = 'InfoMap'">
									<xsl:if test="parent::include.document">
										<!-- mainly for diff highlighint -->
										<xsl:call-template name="addStyle">
											<xsl:with-param name="name">include.document</xsl:with-param>
											<xsl:with-param name="currentElement" select="parent::*"/>
										</xsl:call-template>
									</xsl:if>
									<xsl:apply-templates select="current()" mode="writeContent">
										<xsl:with-param name="internalID" select="$internalID"/>
										<xsl:with-param name="isLast" select="$isLastBranch"/>
										<xsl:with-param name="applyChildren" select="$applyChildren"/>
										<xsl:with-param name="customRegionElem" select="$customRegionElem"/>
										<xsl:with-param name="hasCustomRegions" select="$hasCustomRegions"/>
										<xsl:with-param name="pageRegionElem" select="$pageRegionElem"/>
										<xsl:with-param name="splitPageSequences" select="$splitPageSequences"/>
									</xsl:apply-templates>
								</xsl:when>
								<xsl:when test="name() = 'Include.Block'">
									<xsl:apply-templates select="current()"/>
								</xsl:when>
								<xsl:otherwise>
									<fo:block widows="1" orphans="1">
										<xsl:variable name="position" select="position()"/>
										<xsl:for-each select="ancestor::InfoMap[1]">
											<xsl:if test="string-length(@defaultLanguage) &gt; 0 and ancestor::InfoMap/@defaultLanguage != @defaultLanguage">
												<xsl:apply-templates select="current()" mode="writeDefaultStyle"/>
											</xsl:if>
											<xsl:if test="$position = 1 and not($showHeadlineContent)">
												<xsl:apply-templates select="current()" mode="writeSectionPageBreak">
													<xsl:with-param name="level" select="$level"/>
												</xsl:apply-templates>
											</xsl:if>
										</xsl:for-each>
										<xsl:call-template name="addStyle">
											<xsl:with-param name="name">container-block</xsl:with-param>
											<xsl:with-param name="attributeNamesList">|span|</xsl:with-param>
										</xsl:call-template>
										<xsl:call-template name="addStyle">
											<xsl:with-param name="name" select="concat('container-block.', substring-after(@Function, '.'))"/>
											<xsl:with-param name="attributeNamesList">|span|</xsl:with-param>
										</xsl:call-template>

										<xsl:choose>
											<xsl:when test="position() = 1 and not($showHeadlineContent) and $hasID">
												<xsl:attribute name="id">
													<xsl:value-of select="$ID"/>
												</xsl:attribute>
												<xsl:if test="not($customRegionElem)">
													<xsl:apply-templates select="parent::*" mode="writeMarker">
														<xsl:with-param name="internalID" select="$internalID"/>
														<xsl:with-param name="splitPageSequences" select="$splitPageSequences"/>
													</xsl:apply-templates>
												</xsl:if>
												<xsl:apply-templates select="parent::*" mode="writeDestination">
													<xsl:with-param name="ID" select="$ID"/>
												</xsl:apply-templates>
												<xsl:if test="string-length($inheritId) &gt; 0">
													<xsl:call-template name="outputInheritIds">
														<xsl:with-param name="inheritIds" select="$inheritId"/>
													</xsl:call-template>
												</xsl:if>
											</xsl:when>
											<xsl:when test="not($customRegionElem)">
												<xsl:apply-templates select="parent::*" mode="writeMarker">
													<xsl:with-param name="internalID" select="$internalID"/>
													<xsl:with-param name="splitPageSequences" select="$splitPageSequences"/>
												</xsl:apply-templates>
											</xsl:when>
										</xsl:choose>

										<xsl:apply-templates select="current()">
											<xsl:with-param name="customRegionElem" select="$customRegionElem"/>
											<xsl:with-param name="hasCustomRegions" select="$hasCustomRegions"/>
											<xsl:with-param name="pageRegionElem" select="$pageRegionElem"/>
										</xsl:apply-templates>
									</fo:block>
								</xsl:otherwise>
							</xsl:choose>
						</xsl:for-each>
					</xsl:when>
				</xsl:choose>
			</xsl:when>
			<xsl:otherwise>
				<fo:block>
					<xsl:attribute name="id">
						<xsl:value-of select="$ID"/>
					</xsl:attribute>
					<xsl:if test="not($customRegionElem)">
						<xsl:apply-templates select="current()" mode="writeMarker"/>
					</xsl:if>
					<xsl:apply-templates select="current()" mode="writeDestination"/>
					<xsl:if test="string-length($inheritId) &gt; 0">
						<xsl:call-template name="outputInheritIds">
							<xsl:with-param name="inheritIds" select="$inheritId"/>
						</xsl:call-template>
					</xsl:if>
				</fo:block>
			</xsl:otherwise>
		</xsl:choose>

		<xsl:if test="$applyChildren">
			<xsl:apply-templates select="InfoMap[not(@isSubSection)]">
				<xsl:with-param name="internalID" select="$internalID"/>
				<xsl:with-param name="isLast" select="$isLast"/>
				<xsl:with-param name="customRegionElem" select="$customRegionElem"/>
				<xsl:with-param name="pageRegionElem" select="$pageRegionElem"/>
				<xsl:with-param name="hasCustomRegions" select="$hasCustomRegions"/>
				<xsl:with-param name="splitPageSequences" select="$splitPageSequences"/>
				<xsl:with-param name="isCustomPageSequence" select="$isCustomPageSequence"/>
				<xsl:with-param name="inheritId" select="$currInheritId"/>
			</xsl:apply-templates>
		</xsl:if>

	</xsl:template>

	<xsl:template match="Block | Block.remark">
		<xsl:param name="customRegionElem"/>
		<xsl:param name="hasCustomRegions"/>
		<xsl:param name="pageRegionElem"/>
		<xsl:variable name="visible">
			<xsl:call-template name="getFormat">
				<xsl:with-param name="name">block</xsl:with-param>
				<xsl:with-param name="attributeName">visibility</xsl:with-param>
			</xsl:call-template>
		</xsl:variable>
		<xsl:if test="not($visible = 'hidden')">
			<xsl:variable name="placeLabelOnTop">
				<xsl:call-template name="getTemplateVariableValue">
					<xsl:with-param name="name">BLOCK_LABEL_ON_TOP</xsl:with-param>
				</xsl:call-template>
			</xsl:variable>
			<xsl:apply-templates select="current()" mode="writeBlock">
				<xsl:with-param name="customRegionElem" select="$customRegionElem"/>
				<xsl:with-param name="hasCustomRegions" select="$hasCustomRegions"/>
				<xsl:with-param name="pageRegionElem" select="$pageRegionElem"/>
				<xsl:with-param name="placeLabelOnTop" select="$placeLabelOnTop = 'true'"/>
			</xsl:apply-templates>
		</xsl:if>
	</xsl:template>

	<xsl:template match="Block | Block.remark" mode="getBlockFormat">
		<xsl:choose>
			<xsl:when test="string-length(@Typ) = 0 or @Typ = 'null'">
				<xsl:call-template name="getTemplateVariableValue">
					<xsl:with-param name="name">DEFAULT_BLOCK_FORMAT</xsl:with-param>
				</xsl:call-template>
			</xsl:when>
			<xsl:otherwise>
				<xsl:value-of select="@Typ"/>
			</xsl:otherwise>
		</xsl:choose>
	</xsl:template>

	<xsl:template match="Block | Block.remark" mode="writeBlock">
		<xsl:param name="placeTablesWithImages" select="true()"/>
		<xsl:param name="placeLabelOnTop" select="false()"/>
		<xsl:param name="isGlossary" select="boolean(ancestor::*[@glossary])"/>
		<xsl:param name="customRegionElem"/>
		<xsl:param name="hasCustomRegions"/>
		<xsl:param name="pageRegionElem"/>
		
		<xsl:variable name="indentVar">
			<xsl:call-template name="getTemplateVariableValue">
				<xsl:with-param name="name">LEFT_SPACE</xsl:with-param>
			</xsl:call-template>
		</xsl:variable>

		<xsl:variable name="blockPos" select="count(preceding-sibling::Block | preceding-sibling::Block.remark) + 1"/>

		<xsl:variable name="marginColumnWidthPx">
			<xsl:call-template name="getPixels">
				<xsl:with-param name="value">
					<xsl:apply-templates select="current()" mode="getMarginalColumnWidth">
						<xsl:with-param name="blockPos" select="$blockPos"/>
						<xsl:with-param name="isGlossary" select="$isGlossary"/>
					</xsl:apply-templates>
				</xsl:with-param>
				<xsl:with-param name="dpi" select="$OUTPUT_RESOLUTION"/>
			</xsl:call-template>
		</xsl:variable>

		<xsl:variable name="customMarginColumnWidthPx">
			<xsl:call-template name="getPixels">
				<xsl:with-param name="value">
					<xsl:choose>
						<xsl:when test="string-length(@Typ) &gt; 0">
							<xsl:apply-templates select="current()" mode="getMarginalColumnWidth">
								<xsl:with-param name="blockPos" select="$blockPos"/>
								<xsl:with-param name="useFallback" select="false()"/>
							</xsl:apply-templates>
						</xsl:when>
						<xsl:otherwise>0cm</xsl:otherwise>
					</xsl:choose>
				</xsl:with-param>
				<xsl:with-param name="dpi" select="$OUTPUT_RESOLUTION"/>
			</xsl:call-template>
		</xsl:variable>

		<xsl:variable name="hasCustomMarginColumnWidthPx" select="$customMarginColumnWidthPx &gt; 0"/>

		<xsl:variable name="blockType">
			<xsl:apply-templates select="current()" mode="getBlockFormat"/>
		</xsl:variable>

		<fo:block-container>
			<xsl:if test="string-length($indentVar) &gt; 0">
				<xsl:attribute name="start-indent">
					<xsl:value-of select="$indentVar"/>
				</xsl:attribute>
			</xsl:if>
			<xsl:if test="$blockType = 'GanzeBreite'">
				<xsl:attribute name="start-indent">0cm</xsl:attribute>
			</xsl:if>
			<xsl:call-template name="addStyle">
				<xsl:with-param name="name">block</xsl:with-param>
			</xsl:call-template>
			<xsl:if test="not(preceding-sibling::Block)">
				<xsl:call-template name="addStyle">
					<xsl:with-param name="name">block.first</xsl:with-param>
				</xsl:call-template>
			</xsl:if>
			<xsl:if test="not(following-sibling::Block)">
				<xsl:call-template name="addStyle">
					<xsl:with-param name="name">block.last</xsl:with-param>
				</xsl:call-template>
			</xsl:if>
			<xsl:call-template name="addStyle">
				<xsl:with-param name="name" select="@Function"/>
			</xsl:call-template>
			<xsl:if test="not(@Changed) and parent::InfoMap/@Changed">
				<xsl:apply-templates select="parent::InfoMap" mode="setDiffStyle"/>
			</xsl:if>
			<xsl:if test="$isGlossary">
				<xsl:attribute name="start-indent">0cm</xsl:attribute>
			</xsl:if>
			<xsl:if test="string-length(@ID) &gt; 0">
				<xsl:attribute name="id">
					<xsl:value-of select="@ID"/>
				</xsl:attribute>
				<xsl:apply-templates select="current()" mode="writeDestination"/>
			</xsl:if>
			
			<xsl:apply-templates select="current()" mode="writeCharacterizationInfo">
				<xsl:with-param name="bPadding" select="true()"/>
			</xsl:apply-templates>

			<xsl:choose>
				<!-- short cut for the most common case -->
				<xsl:when test="not($marginColumnWidthPx &gt; 0) and (string-length($blockType) = 0 or $blockType = 'null' or $blockType = 'Standard' or $isGlossary)">
					<xsl:apply-templates select="current()" mode="writeDefaultBlock">
						<xsl:with-param name="isGlossary" select="$isGlossary"/>
						<xsl:with-param name="hasCustomRegions" select="$hasCustomRegions"/>
						<xsl:with-param name="pageRegionElem" select="$pageRegionElem"/>
					</xsl:apply-templates>
				</xsl:when>
				<xsl:when test="$blockType = 'TextintensivTextbetont' or $blockType = 'TextText'
						  or $blockType = 'TextintensivBildbetont' or $blockType = 'TextBild'
						  or $blockType = 'BildTabelle' or $blockType = 'BildintensivTextbetont'
						  or $blockType = 'BildintensivBildbetont'
						  or $blockType = 'FiftyFiftyText'
						  or $blockType = 'FiftyFiftyPic' or $blockType = 'FiftyFiftyMedia'
						  or $blockType = 'Multimedia'">
					<xsl:choose>
						<xsl:when test="$hasCustomMarginColumnWidthPx">
							<xsl:variable name="SPACER_COLUMN_WIDTH">
								<xsl:call-template name="getTemplateVariableValue">
									<xsl:with-param name="name">SPACER_COLUMN_WIDTH</xsl:with-param>
									<xsl:with-param name="defaultValue">0cm</xsl:with-param>
								</xsl:call-template>
							</xsl:variable>
							<fo:table table-layout="fixed" width="100%">
								<fo:table-column column-width="{$customMarginColumnWidthPx}px"/>
								<fo:table-column column-width="{$SPACER_COLUMN_WIDTH}"/>
								<fo:table-column column-width="proportional-column-width(1)"/>
								<fo:table-body>
									<fo:table-row>
										<fo:table-cell>
											<xsl:apply-templates select="current()" mode="writeLabel">
												<xsl:with-param name="keep-with-next">auto</xsl:with-param>
												<xsl:with-param name="customStyle">label.marginal</xsl:with-param>
												<xsl:with-param name="hasCustomRegions" select="$hasCustomRegions"/>
												<xsl:with-param name="pageRegionElem" select="$pageRegionElem"/>
												<xsl:with-param name="blockPos" select="$blockPos"/>
											</xsl:apply-templates>
										</fo:table-cell>
										<fo:table-cell>
											<fo:block/>
										</fo:table-cell>
										<fo:table-cell>
											<xsl:apply-templates select="current()" mode="writeBlockFormat">
												<xsl:with-param name="blockType" select="$blockType"/>
												<xsl:with-param name="placeLabel" select="false()"/>
												<xsl:with-param name="placeTablesWithImages" select="$placeTablesWithImages"/>
												<xsl:with-param name="hasCustomRegions" select="$hasCustomRegions"/>
												<xsl:with-param name="pageRegionElem" select="$pageRegionElem"/>
											</xsl:apply-templates>
										</fo:table-cell>
									</fo:table-row>
								</fo:table-body>
							</fo:table>
						</xsl:when>
						<xsl:otherwise>
							<xsl:apply-templates select="current()" mode="writeBlockFormat">
								<xsl:with-param name="blockType" select="$blockType"/>
								<xsl:with-param name="placeLabelOnTop" select="$placeLabelOnTop"/>
								<xsl:with-param name="placeTablesWithImages" select="$placeTablesWithImages"/>
								<xsl:with-param name="hasCustomRegions" select="$hasCustomRegions"/>
								<xsl:with-param name="pageRegionElem" select="$pageRegionElem"/>
								<xsl:with-param name="blockPos" select="$blockPos"/>
							</xsl:apply-templates>
						</xsl:otherwise>
					</xsl:choose>
				</xsl:when>
				<xsl:when test="$marginColumnWidthPx &gt; 0">
					<fo:block start-indent="0" end-indent="0">
						<xsl:call-template name="addStyle">
							<xsl:with-param name="name">container-block</xsl:with-param>
						</xsl:call-template>
						<xsl:variable name="SPACER_COLUMN_WIDTH">
							<xsl:call-template name="getTemplateVariableValue">
								<xsl:with-param name="name">SPACER_COLUMN_WIDTH</xsl:with-param>
								<xsl:with-param name="defaultValue">0cm</xsl:with-param>
							</xsl:call-template>
						</xsl:variable>
						<fo:table table-layout="fixed" width="100%">
								<fo:table-column column-width="{$marginColumnWidthPx}px"/>
							<fo:table-column column-width="{$SPACER_COLUMN_WIDTH}"/>
							<fo:table-column column-width="proportional-column-width(1)"/>
							<fo:table-body>
								<fo:table-row>
									<fo:table-cell>
										<xsl:apply-templates select="current()" mode="writeLabel">
											<xsl:with-param name="keep-with-next">auto</xsl:with-param>
											<xsl:with-param name="customStyle">label.marginal</xsl:with-param>
											<xsl:with-param name="hasCustomRegions" select="$hasCustomRegions"/>
											<xsl:with-param name="pageRegionElem" select="$pageRegionElem"/>
											<xsl:with-param name="blockPos" select="$blockPos"/>
										</xsl:apply-templates>
									</fo:table-cell>
									<fo:table-cell>
											<fo:block></fo:block>
									</fo:table-cell>
									<fo:table-cell>
										<xsl:apply-templates select="current()" mode="writeBlockContents">
											<xsl:with-param name="hasCustomRegions" select="$hasCustomRegions"/>
											<xsl:with-param name="pageRegionElem" select="$pageRegionElem"/>
										</xsl:apply-templates>
									</fo:table-cell>
								</fo:table-row>
							</fo:table-body>
						</fo:table>
					</fo:block>
				</xsl:when>
				<xsl:when test="$blockType = 'GanzeBreite'">
					<xsl:apply-templates select="current()" mode="writeDefaultBlock">
						<xsl:with-param name="isGlossary" select="$isGlossary"/>
						<xsl:with-param name="hasCustomRegions" select="$hasCustomRegions"/>
						<xsl:with-param name="pageRegionElem" select="$pageRegionElem"/>
						<xsl:with-param name="blockPos" select="$blockPos"/>
					</xsl:apply-templates>
				</xsl:when>
				<xsl:otherwise>
					<xsl:apply-templates select="current()" mode="writeDefaultBlock">
						<xsl:with-param name="isGlossary" select="$isGlossary"/>
						<xsl:with-param name="hasCustomRegions" select="$hasCustomRegions"/>
						<xsl:with-param name="pageRegionElem" select="$pageRegionElem"/>
						<xsl:with-param name="blockPos" select="$blockPos"/>
					</xsl:apply-templates>
				</xsl:otherwise>
			</xsl:choose>
		</fo:block-container>
	</xsl:template>

	<xsl:template match="Block | Block.remark" mode="writeBlockFormat">
		<xsl:param name="blockType"/>
		<xsl:param name="placeLabel" select="true()"/>
		<xsl:param name="placeLabelOnTop"/>
		<xsl:param name="placeTablesWithImages"/>
		<xsl:param name="hasCustomRegions"/>
		<xsl:param name="pageRegionElem"/>
		<xsl:param name="blockPos"/>
		
		<xsl:variable name="colDistance">
			<xsl:call-template name="getTemplateVariableValue">
				<xsl:with-param name="name" select="concat('COL_DISTANCE_', $blockType)"/>
				<xsl:with-param name="defaultValue">
					<xsl:call-template name="getTemplateVariableValue">
						<xsl:with-param name="name">COL_DISTANCE</xsl:with-param>
						<xsl:with-param name="defaultValue" select="$COL_DISTANCE_DEFAULT_VALUE"/>
					</xsl:call-template>
				</xsl:with-param>
			</xsl:call-template>
		</xsl:variable>
		
		<xsl:choose>
			<xsl:when test="$blockType = 'TextintensivTextbetont' or $blockType = 'TextText'">
				<!--Textintensiv textbetont -->
				<fo:block start-indent="0" end-indent="0">
					<xsl:call-template name="addStyle">
						<xsl:with-param name="name">container-block</xsl:with-param>
					</xsl:call-template>
					<xsl:if test="$placeLabel and $placeLabelOnTop">
						<xsl:apply-templates select="current()" mode="writeLabel">
							<xsl:with-param name="hasCustomRegions" select="$hasCustomRegions"/>
							<xsl:with-param name="pageRegionElem" select="$pageRegionElem"/>
						</xsl:apply-templates>
					</xsl:if>
					<xsl:variable name="TEXTTEXT_COL">
						<xsl:call-template name="getTemplateVariableValue">
							<xsl:with-param name="name">TEXTTEXT_COL</xsl:with-param>
							<xsl:with-param name="defaultValue" select="$TEXTTEXT_COL_DEFAULT_VALUE"/>
						</xsl:call-template>
					</xsl:variable>
					<fo:table table-layout="fixed" width="100%">
						<xsl:call-template name="addStyle">
							<xsl:with-param name="name">block.table</xsl:with-param>
						</xsl:call-template>
						<fo:table-column column-width="proportional-column-width(1)"/>
						<xsl:if test="$colDistance &gt; 0">
							<fo:table-column column-width="{$colDistance}%"/>
						</xsl:if>
						<fo:table-column column-width="{$TEXTTEXT_COL}%"/>
						<fo:table-body>
							<fo:table-row>
								<fo:table-cell>
									<xsl:call-template name="addStyle">
										<xsl:with-param name="name">block.cell.1</xsl:with-param>
									</xsl:call-template>
									<xsl:if test="$placeLabel and not($placeLabelOnTop)">
										<xsl:apply-templates select="current()" mode="writeLabel">
											<xsl:with-param name="keep-with-next">auto</xsl:with-param>
											<xsl:with-param name="hasCustomRegions" select="$hasCustomRegions"/>
											<xsl:with-param name="pageRegionElem" select="$pageRegionElem"/>
											<xsl:with-param name="blockPos" select="$blockPos"/>
										</xsl:apply-templates>
									</xsl:if>

									<xsl:apply-templates select="current()" mode="writeBlockFormatTextSide">
										<xsl:with-param name="placeTablesWithImages" select="$placeTablesWithImages"/>
										<xsl:with-param name="blockType" select="$blockType"/>
										<xsl:with-param name="hasCustomRegions" select="$hasCustomRegions"/>
										<xsl:with-param name="pageRegionElem" select="$pageRegionElem"/>
									</xsl:apply-templates>

								</fo:table-cell>
								<xsl:if test="$colDistance &gt; 0">
								<fo:table-cell>
									<fo:block/>
								</fo:table-cell>
								</xsl:if>
								<fo:table-cell text-align="right">
									<xsl:call-template name="addStyle">
										<xsl:with-param name="name">block.cell.2</xsl:with-param>
									</xsl:call-template>
									<xsl:apply-templates select="current()" mode="writeBlockFormatMediaSide">
										<xsl:with-param name="placeTablesWithImages" select="$placeTablesWithImages"/>
										<xsl:with-param name="blockType" select="$blockType"/>
										<xsl:with-param name="hasCustomRegions" select="$hasCustomRegions"/>
										<xsl:with-param name="pageRegionElem" select="$pageRegionElem"/>
									</xsl:apply-templates>
								</fo:table-cell>
							</fo:table-row>
						</fo:table-body>
					</fo:table>
				</fo:block>
			</xsl:when>
			<xsl:when test="$blockType = 'TextintensivBildbetont' or $blockType = 'TextBild'">
				<!-- Textintensiv bildbetont -->
				<fo:block start-indent="0" end-indent="0">
					<xsl:call-template name="addStyle">
						<xsl:with-param name="name">container-block</xsl:with-param>
					</xsl:call-template>
					<xsl:if test="$placeLabel and $placeLabelOnTop">
						<xsl:apply-templates select="current()" mode="writeLabel">
							<xsl:with-param name="hasCustomRegions" select="$hasCustomRegions"/>
							<xsl:with-param name="pageRegionElem" select="$pageRegionElem"/>
							<xsl:with-param name="blockPos" select="$blockPos"/>
						</xsl:apply-templates>
					</xsl:if>
					<xsl:variable name="TEXTBILD_COL">
						<xsl:call-template name="getTemplateVariableValue">
							<xsl:with-param name="name">TEXTBILD_COL</xsl:with-param>
							<xsl:with-param name="defaultValue" select="$TEXTBILD_COL_DEFAULT_VALUE"/>
						</xsl:call-template>
					</xsl:variable>
					<fo:table table-layout="fixed" width="100%">
						<xsl:call-template name="addStyle">
							<xsl:with-param name="name">block.table</xsl:with-param>
						</xsl:call-template>
						<fo:table-column column-width="{$TEXTBILD_COL}%"/>
						<xsl:if test="$colDistance &gt; 0">
							<fo:table-column column-width="{$colDistance}%"/>
						</xsl:if>
						<fo:table-column column-width="proportional-column-width(1)"/>
						<fo:table-body>
							<fo:table-row>
								<fo:table-cell>
									<xsl:call-template name="addStyle">
										<xsl:with-param name="name">block.cell.1</xsl:with-param>
									</xsl:call-template>
									<xsl:apply-templates select="current()" mode="writeBlockFormatMediaSide">
										<xsl:with-param name="placeTablesWithImages" select="$placeTablesWithImages"/>
										<xsl:with-param name="blockType" select="$blockType"/>
										<xsl:with-param name="hasCustomRegions" select="$hasCustomRegions"/>
										<xsl:with-param name="pageRegionElem" select="$pageRegionElem"/>
									</xsl:apply-templates>
								</fo:table-cell>
								<xsl:if test="$colDistance &gt; 0">
								<fo:table-cell>
									<fo:block/>
								</fo:table-cell>
								</xsl:if>
								<fo:table-cell>
									<fo:block>
										<xsl:call-template name="addStyle">
											<xsl:with-param name="name">block.cell.2</xsl:with-param>
										</xsl:call-template>
										<xsl:if test="$placeLabel and not($placeLabelOnTop)">
											<xsl:apply-templates select="current()" mode="writeLabel">
												<xsl:with-param name="keep-with-next">auto</xsl:with-param>
												<xsl:with-param name="hasCustomRegions" select="$hasCustomRegions"/>
												<xsl:with-param name="pageRegionElem" select="$pageRegionElem"/>
												<xsl:with-param name="blockPos" select="$blockPos"/>
											</xsl:apply-templates>
										</xsl:if>
										<xsl:apply-templates select="current()" mode="writeBlockFormatTextSide">
											<xsl:with-param name="placeTablesWithImages" select="$placeTablesWithImages"/>
											<xsl:with-param name="blockType" select="$blockType"/>
											<xsl:with-param name="hasCustomRegions" select="$hasCustomRegions"/>
											<xsl:with-param name="pageRegionElem" select="$pageRegionElem"/>
										</xsl:apply-templates>
									</fo:block>
								</fo:table-cell>
							</fo:table-row>
						</fo:table-body>
					</fo:table>
				</fo:block>
			</xsl:when>
			<xsl:when test="$blockType = 'BildTabelle' or $blockType = 'BildintensivTextbetont'">
				<!-- Bildintensiv Textbetont-->
				<fo:block start-indent="0" end-indent="0">
					<xsl:call-template name="addStyle">
						<xsl:with-param name="name">container-block</xsl:with-param>
					</xsl:call-template>
					<xsl:if test="$placeLabel and $placeLabelOnTop">
						<xsl:apply-templates select="current()" mode="writeLabel">
							<xsl:with-param name="hasCustomRegions" select="$hasCustomRegions"/>
							<xsl:with-param name="pageRegionElem" select="$pageRegionElem"/>
							<xsl:with-param name="blockPos" select="$blockPos"/>
						</xsl:apply-templates>
					</xsl:if>
					<xsl:variable name="BILDTABELLE_COL">
						<xsl:call-template name="getTemplateVariableValue">
							<xsl:with-param name="name">BILDTABELLE_COL</xsl:with-param>
							<xsl:with-param name="defaultValue" select="$BILDTABELLE_COL_DEFAULT_VALUE"/>
						</xsl:call-template>
					</xsl:variable>
					<fo:table table-layout="fixed" width="100%">
						<xsl:call-template name="addStyle">
							<xsl:with-param name="name">block.table</xsl:with-param>
						</xsl:call-template>
						<fo:table-column column-width="proportional-column-width(1)"/>
						<xsl:if test="$colDistance &gt; 0">
							<fo:table-column column-width="{$colDistance}%"/>
						</xsl:if>
						<fo:table-column column-width="{$BILDTABELLE_COL}%"/>
						<fo:table-body>
							<fo:table-row>
								<fo:table-cell>
									<xsl:call-template name="addStyle">
										<xsl:with-param name="name">block.cell.1</xsl:with-param>
									</xsl:call-template>
									<xsl:if test="$placeLabel and not($placeLabelOnTop)">
										<xsl:apply-templates select="current()" mode="writeLabel">
											<xsl:with-param name="keep-with-next">auto</xsl:with-param>
											<xsl:with-param name="hasCustomRegions" select="$hasCustomRegions"/>
											<xsl:with-param name="pageRegionElem" select="$pageRegionElem"/>
											<xsl:with-param name="blockPos" select="$blockPos"/>
										</xsl:apply-templates>
									</xsl:if>
									<xsl:apply-templates select="current()" mode="writeBlockFormatTextSide">
										<xsl:with-param name="placeTablesWithImages" select="$placeTablesWithImages"/>
										<xsl:with-param name="blockType" select="$blockType"/>
										<xsl:with-param name="hasCustomRegions" select="$hasCustomRegions"/>
										<xsl:with-param name="pageRegionElem" select="$pageRegionElem"/>
									</xsl:apply-templates>
								</fo:table-cell>
								<xsl:if test="$colDistance &gt; 0">
								<fo:table-cell>
									<fo:block/>
								</fo:table-cell>
								</xsl:if>
								<fo:table-cell text-align="right">
									<xsl:call-template name="addStyle">
										<xsl:with-param name="name">block.cell.2</xsl:with-param>
									</xsl:call-template>
									<xsl:apply-templates select="current()" mode="writeBlockFormatMediaSide">
										<xsl:with-param name="placeTablesWithImages" select="$placeTablesWithImages"/>
										<xsl:with-param name="blockType" select="$blockType"/>
										<xsl:with-param name="hasCustomRegions" select="$hasCustomRegions"/>
										<xsl:with-param name="pageRegionElem" select="$pageRegionElem"/>
									</xsl:apply-templates>
								</fo:table-cell>
							</fo:table-row>
						</fo:table-body>
					</fo:table>
				</fo:block>
			</xsl:when>
			<xsl:when test="$blockType = 'BildintensivBildbetont'">
				<!-- Bildintensiv Textbetont-->
				<fo:block start-indent="0" end-indent="0">
					<xsl:call-template name="addStyle">
						<xsl:with-param name="name">container-block</xsl:with-param>
					</xsl:call-template>
					<xsl:if test="$placeLabel and $placeLabelOnTop">
						<xsl:apply-templates select="current()" mode="writeLabel">
							<xsl:with-param name="hasCustomRegions" select="$hasCustomRegions"/>
							<xsl:with-param name="pageRegionElem" select="$pageRegionElem"/>
							<xsl:with-param name="blockPos" select="$blockPos"/>
						</xsl:apply-templates>
					</xsl:if>
					<xsl:variable name="BILDTABELLE_COL">
						<xsl:call-template name="getTemplateVariableValue">
							<xsl:with-param name="name">BILDTABELLE_COL</xsl:with-param>
							<xsl:with-param name="defaultValue" select="$BILDTABELLE_COL_DEFAULT_VALUE"/>
						</xsl:call-template>
					</xsl:variable>
					<fo:table table-layout="fixed" width="100%">
						<xsl:call-template name="addStyle">
							<xsl:with-param name="name">block.table</xsl:with-param>
						</xsl:call-template>
						<fo:table-column column-width="{$BILDTABELLE_COL}%"/>
						<xsl:if test="$colDistance &gt; 0">
							<fo:table-column column-width="{$colDistance}%"/>
						</xsl:if>
						<fo:table-column column-width="proportional-column-width(1)"/>
						<fo:table-body>
							<fo:table-row>
								<fo:table-cell>
									<xsl:call-template name="addStyle">
										<xsl:with-param name="name">block.cell.1</xsl:with-param>
									</xsl:call-template>
									<xsl:apply-templates select="current()" mode="writeBlockFormatMediaSide">
										<xsl:with-param name="placeTablesWithImages" select="$placeTablesWithImages"/>
										<xsl:with-param name="blockType" select="$blockType"/>
										<xsl:with-param name="hasCustomRegions" select="$hasCustomRegions"/>
										<xsl:with-param name="pageRegionElem" select="$pageRegionElem"/>
									</xsl:apply-templates>
								</fo:table-cell>
								<xsl:if test="$colDistance &gt; 0">
								<fo:table-cell>
									<fo:block/>
								</fo:table-cell>
								</xsl:if>
								<fo:table-cell>
									<xsl:call-template name="addStyle">
										<xsl:with-param name="name">block.cell.2</xsl:with-param>
									</xsl:call-template>
									<xsl:if test="$placeLabel and not($placeLabelOnTop)">
										<xsl:apply-templates select="current()" mode="writeLabel">
											<xsl:with-param name="keep-with-next">auto</xsl:with-param>
											<xsl:with-param name="hasCustomRegions" select="$hasCustomRegions"/>
											<xsl:with-param name="pageRegionElem" select="$pageRegionElem"/>
											<xsl:with-param name="blockPos" select="$blockPos"/>
										</xsl:apply-templates>
									</xsl:if>
									<xsl:apply-templates select="current()" mode="writeBlockFormatTextSide">
										<xsl:with-param name="placeTablesWithImages" select="$placeTablesWithImages"/>
										<xsl:with-param name="blockType" select="$blockType"/>
										<xsl:with-param name="hasCustomRegions" select="$hasCustomRegions"/>
										<xsl:with-param name="pageRegionElem" select="$pageRegionElem"/>
									</xsl:apply-templates>
								</fo:table-cell>
							</fo:table-row>
						</fo:table-body>
					</fo:table>
				</fo:block>
			</xsl:when>
			<xsl:when test="$blockType = 'FiftyFiftyText'">
				<!-- Fifty Fifty Text-->
				<fo:block start-indent="0" end-indent="0">
					<xsl:call-template name="addStyle">
						<xsl:with-param name="name">container-block</xsl:with-param>
					</xsl:call-template>
					<xsl:if test="$placeLabel and $placeLabelOnTop">
						<xsl:apply-templates select="current()" mode="writeLabel">
							<xsl:with-param name="hasCustomRegions" select="$hasCustomRegions"/>
							<xsl:with-param name="pageRegionElem" select="$pageRegionElem"/>
							<xsl:with-param name="blockPos" select="$blockPos"/>
						</xsl:apply-templates>
					</xsl:if>
					<fo:table table-layout="fixed" width="100%">
						<xsl:call-template name="addStyle">
							<xsl:with-param name="name">block.table</xsl:with-param>
						</xsl:call-template>
						<xsl:variable name="FIFTYFIFTYTEXT_COL">
							<xsl:call-template name="getTemplateVariableValue">
								<xsl:with-param name="name">FIFTYFIFTYTEXT_COL</xsl:with-param>
								<xsl:with-param name="defaultValue">0</xsl:with-param>
							</xsl:call-template>
						</xsl:variable>
						<xsl:choose>
							<xsl:when test = "not($FIFTYFIFTYTEXT_COL='0')">
								<fo:table-column column-width="{$FIFTYFIFTYTEXT_COL}%"/>
								<xsl:if test="$colDistance &gt; 0">
									<fo:table-column column-width="{$colDistance}%"/>
								</xsl:if>
								<fo:table-column column-width="proportional-column-width(1)"/>
							</xsl:when>
							<xsl:otherwise>
								<fo:table-column column-width="{50 - $colDistance div 2}%"/>
								<xsl:if test="$colDistance &gt; 0">
									<fo:table-column column-width="{$colDistance}%"/>
								</xsl:if>
								<fo:table-column column-width="proportional-column-width(1)"/>
							</xsl:otherwise>
						</xsl:choose>

						<fo:table-body>
							<fo:table-row>
								<fo:table-cell>
									<xsl:call-template name="addStyle">
										<xsl:with-param name="name">block.cell.1</xsl:with-param>
									</xsl:call-template>
									<xsl:if test="$placeLabel and not($placeLabelOnTop)">
										<xsl:apply-templates select="current()" mode="writeLabel">
											<xsl:with-param name="keep-with-next">auto</xsl:with-param>
											<xsl:with-param name="hasCustomRegions" select="$hasCustomRegions"/>
											<xsl:with-param name="pageRegionElem" select="$pageRegionElem"/>
											<xsl:with-param name="blockPos" select="$blockPos"/>
										</xsl:apply-templates>
									</xsl:if>
									<xsl:apply-templates select="current()" mode="writeBlockFormatTextSide">
										<xsl:with-param name="placeTablesWithImages" select="$placeTablesWithImages"/>
										<xsl:with-param name="blockType" select="$blockType"/>
										<xsl:with-param name="hasCustomRegions" select="$hasCustomRegions"/>
										<xsl:with-param name="pageRegionElem" select="$pageRegionElem"/>
									</xsl:apply-templates>
								</fo:table-cell>
								<xsl:if test="$colDistance &gt; 0">
								<fo:table-cell>
									<fo:block/>
								</fo:table-cell>
								</xsl:if>
								<fo:table-cell text-align="right">
									<xsl:call-template name="addStyle">
										<xsl:with-param name="name">block.cell.2</xsl:with-param>
									</xsl:call-template>
									<xsl:apply-templates select="current()" mode="writeBlockFormatMediaSide">
										<xsl:with-param name="placeTablesWithImages" select="$placeTablesWithImages"/>
										<xsl:with-param name="blockType" select="$blockType"/>
										<xsl:with-param name="hasCustomRegions" select="$hasCustomRegions"/>
										<xsl:with-param name="pageRegionElem" select="$pageRegionElem"/>
									</xsl:apply-templates>
								</fo:table-cell>
							</fo:table-row>
						</fo:table-body>
					</fo:table>
				</fo:block>
			</xsl:when>
			<xsl:when test="$blockType = 'FiftyFiftyPic' or $blockType = 'FiftyFiftyMedia'">
				<!-- Fifty Fifty Media -->
				<fo:block start-indent="0" end-indent="0">
					<xsl:call-template name="addStyle">
						<xsl:with-param name="name">container-block</xsl:with-param>
					</xsl:call-template>
					<xsl:if test="$placeLabel and $placeLabelOnTop">
						<xsl:apply-templates select="current()" mode="writeLabel">
							<xsl:with-param name="hasCustomRegions" select="$hasCustomRegions"/>
							<xsl:with-param name="pageRegionElem" select="$pageRegionElem"/>
							<xsl:with-param name="blockPos" select="$blockPos"/>
						</xsl:apply-templates>
					</xsl:if>
					<fo:table table-layout="fixed" width="100%">
						<xsl:call-template name="addStyle">
							<xsl:with-param name="name">block.table</xsl:with-param>
						</xsl:call-template>
						<xsl:variable name="FIFTYFIFTYPIC_COL">
							<xsl:call-template name="getTemplateVariableValue">
								<xsl:with-param name="name">FIFTYFIFTYPIC_COL</xsl:with-param>
								<xsl:with-param name="defaultValue">0</xsl:with-param>
							</xsl:call-template>
						</xsl:variable>
						<xsl:choose>
							<xsl:when test = "not($FIFTYFIFTYPIC_COL='0')">
								<fo:table-column column-width="{$FIFTYFIFTYPIC_COL}%"/>
								<xsl:if test="$colDistance &gt; 0">
									<fo:table-column column-width="{$colDistance}%"/>
								</xsl:if>
								<fo:table-column column-width="proportional-column-width(1)"/>
							</xsl:when>
							<xsl:otherwise>
								<fo:table-column column-width="{50 - $colDistance div 2}%"/>
								<xsl:if test="$colDistance &gt; 0">
									<fo:table-column column-width="{$colDistance}%"/>
								</xsl:if>
								<fo:table-column column-width="proportional-column-width(1)"/>
							</xsl:otherwise>
						</xsl:choose>




						<fo:table-body>
							<fo:table-row>
								<fo:table-cell>
									<xsl:call-template name="addStyle">
										<xsl:with-param name="name">block.cell.1</xsl:with-param>
									</xsl:call-template>
									<xsl:apply-templates select="current()" mode="writeBlockFormatMediaSide">
										<xsl:with-param name="placeTablesWithImages" select="$placeTablesWithImages"/>
										<xsl:with-param name="blockType" select="$blockType"/>
										<xsl:with-param name="hasCustomRegions" select="$hasCustomRegions"/>
										<xsl:with-param name="pageRegionElem" select="$pageRegionElem"/>
									</xsl:apply-templates>
								</fo:table-cell>
								<xsl:if test="$colDistance &gt; 0">
								<fo:table-cell>
									<fo:block/>
								</fo:table-cell>
								</xsl:if>
								<fo:table-cell>
									<xsl:call-template name="addStyle">
										<xsl:with-param name="name">block.cell.2</xsl:with-param>
									</xsl:call-template>
									<xsl:if test="$placeLabel and not($placeLabelOnTop)">
										<xsl:apply-templates select="current()" mode="writeLabel">
											<xsl:with-param name="keep-with-next">auto</xsl:with-param>
											<xsl:with-param name="hasCustomRegions" select="$hasCustomRegions"/>
											<xsl:with-param name="pageRegionElem" select="$pageRegionElem"/>
											<xsl:with-param name="blockPos" select="$blockPos"/>
										</xsl:apply-templates>
									</xsl:if>
									<xsl:apply-templates select="current()" mode="writeBlockFormatTextSide">
										<xsl:with-param name="placeTablesWithImages" select="$placeTablesWithImages"/>
										<xsl:with-param name="blockType" select="$blockType"/>
										<xsl:with-param name="hasCustomRegions" select="$hasCustomRegions"/>
										<xsl:with-param name="pageRegionElem" select="$pageRegionElem"/>
									</xsl:apply-templates>
								</fo:table-cell>
							</fo:table-row>
						</fo:table-body>
					</fo:table>
				</fo:block>
			</xsl:when>
			<xsl:when test="$blockType = 'Multimedia'">
				<!-- Multimedia -->
				<fo:block start-indent="0" end-indent="0">
					<xsl:call-template name="addStyle">
						<xsl:with-param name="name">container-block</xsl:with-param>
					</xsl:call-template>
					<xsl:if test="$placeLabel and $placeLabelOnTop">
						<xsl:apply-templates select="current()" mode="writeLabel">
							<xsl:with-param name="hasCustomRegions" select="$hasCustomRegions"/>
							<xsl:with-param name="pageRegionElem" select="$pageRegionElem"/>
							<xsl:with-param name="blockPos" select="$blockPos"/>
						</xsl:apply-templates>
					</xsl:if>
					<xsl:variable name="MULTIMEDIA_COL">
						<xsl:call-template name="getTemplateVariableValue">
							<xsl:with-param name="name">MULTIMEDIA_COL</xsl:with-param>
							<xsl:with-param name="defaultValue">64</xsl:with-param>
						</xsl:call-template>
					</xsl:variable>
					<fo:table table-layout="fixed" width="100%">
						<xsl:call-template name="addStyle">
							<xsl:with-param name="name">block.table</xsl:with-param>
						</xsl:call-template>
						<fo:table-column column-width="proportional-column-width(1)"/>
						<xsl:if test="$colDistance &gt; 0">
							<fo:table-column column-width="{$colDistance}%"/>
						</xsl:if>
						<fo:table-column column-width="{$MULTIMEDIA_COL}%"/>
						<fo:table-body>
							<fo:table-row>
								<fo:table-cell>
									<xsl:call-template name="addStyle">
										<xsl:with-param name="name">block.cell.1</xsl:with-param>
									</xsl:call-template>
									<xsl:if test="$placeLabel and not($placeLabelOnTop)">
										<xsl:apply-templates select="current()" mode="writeLabel">
											<xsl:with-param name="keep-with-next">auto</xsl:with-param>
											<xsl:with-param name="hasCustomRegions" select="$hasCustomRegions"/>
											<xsl:with-param name="pageRegionElem" select="$pageRegionElem"/>
											<xsl:with-param name="blockPos" select="$blockPos"/>
										</xsl:apply-templates>
									</xsl:if>
									<xsl:apply-templates select="current()" mode="writeBlockFormatTextSide">
										<xsl:with-param name="placeTablesWithImages" select="$placeTablesWithImages"/>
										<xsl:with-param name="blockType" select="$blockType"/>
										<xsl:with-param name="hasCustomRegions" select="$hasCustomRegions"/>
										<xsl:with-param name="pageRegionElem" select="$pageRegionElem"/>
									</xsl:apply-templates>
								</fo:table-cell>
								<xsl:if test="$colDistance &gt; 0">
								<fo:table-cell>
									<fo:block/>
								</fo:table-cell>
								</xsl:if>
								<fo:table-cell text-align="right">
									<xsl:call-template name="addStyle">
										<xsl:with-param name="name">block.cell.2</xsl:with-param>
									</xsl:call-template>
									<xsl:apply-templates select="current()" mode="writeBlockFormatMediaSide">
										<xsl:with-param name="placeTablesWithImages" select="$placeTablesWithImages"/>
										<xsl:with-param name="blockType" select="$blockType"/>
										<xsl:with-param name="hasCustomRegions" select="$hasCustomRegions"/>
										<xsl:with-param name="pageRegionElem" select="$pageRegionElem"/>
									</xsl:apply-templates>
								</fo:table-cell>
							</fo:table-row>
						</fo:table-body>
					</fo:table>
				</fo:block>
			</xsl:when>
		</xsl:choose>
	</xsl:template>


	<xsl:template match="Block | Block.remark" mode="writeBlockFormatMediaSide">
		<xsl:param name="hasCustomRegions"/>
		<xsl:param name="pageRegionElem"/>
		<xsl:param name="placeTablesWithImages"/>
		<xsl:param name="blockType"/>
		<xsl:if test="not($hasCustomRegions) or not($pageRegionElem/CustomRegions/Region[@assignContentType = 'Image'])">
			<xsl:variable name="elementList">
				<xsl:call-template name="getTemplateVariableValue">
					<xsl:with-param name="name" select="concat('BLOCK_', $blockType, '_IMAGE_SIDE_ELEMENTS')"/>
					<xsl:with-param name="defaultValue">
						<xsl:call-template name="getTemplateVariableValue">
							<xsl:with-param name="name">BLOCK_FORMAT_IMAGE_SIDE_ELEMENTS</xsl:with-param>
						</xsl:call-template>
					</xsl:with-param>
				</xsl:call-template>
			</xsl:variable>
			<xsl:variable name="elementXpath">
				<xsl:call-template name="getTemplateVariableValue">
					<xsl:with-param name="name" select="concat('BLOCK_', $blockType, '_IMAGE_SIDE_ELEMENTS_XPATH')"/>
					<xsl:with-param name="defaultValue">
						<xsl:call-template name="getTemplateVariableValue">
							<xsl:with-param name="name">BLOCK_FORMAT_IMAGE_SIDE_ELEMENTS_XPATH</xsl:with-param>
						</xsl:call-template>
					</xsl:with-param>
				</xsl:call-template>
			</xsl:variable>
			<xsl:choose>
				<!--<xsl:when test="string-length($elementXpath) &gt; 0">
					<xsl:for-each select="*">
						<xsl:if test="xalan:evaluate($elementXpath)">
							<xsl:apply-templates select="current()"/>
						</xsl:if>
					</xsl:for-each>
				</xsl:when>-->
				<xsl:when test="string-length($elementList) &gt; 0">
					<xsl:for-each select="*">
						<xsl:if test="contains($elementList, name())">
							<xsl:apply-templates select="current()"/>
						</xsl:if>
					</xsl:for-each>
				</xsl:when>
				<xsl:when test="$placeTablesWithImages">
					<xsl:apply-templates select="Media | table"/>
				</xsl:when>
				<xsl:otherwise>
					<xsl:apply-templates select="Media"/>
				</xsl:otherwise>
			</xsl:choose>
		</xsl:if>
	</xsl:template>

	<xsl:template match="Block | Block.remark" mode="writeBlockFormatTextSide">
		<xsl:param name="hasCustomRegions"/>
		<xsl:param name="pageRegionElem"/>
		<xsl:param name="placeTablesWithImages"/>
		<xsl:param name="blockType"/>
		<xsl:if test="not($hasCustomRegions) or not($pageRegionElem/CustomRegions/Region[@assignContentType = 'Text' or @assignContentType = 'TextLabel'])">
			<xsl:variable name="elementList">
				<xsl:call-template name="getTemplateVariableValue">
					<xsl:with-param name="name" select="concat('BLOCK_', $blockType, '_IMAGE_SIDE_ELEMENTS')"/>
					<xsl:with-param name="defaultValue">
						<xsl:call-template name="getTemplateVariableValue">
							<xsl:with-param name="name">BLOCK_FORMAT_IMAGE_SIDE_ELEMENTS</xsl:with-param>
						</xsl:call-template>
					</xsl:with-param>
				</xsl:call-template>
			</xsl:variable>
			<xsl:variable name="elementXpath">
				<xsl:call-template name="getTemplateVariableValue">
					<xsl:with-param name="name" select="concat('BLOCK_', $blockType, '_IMAGE_SIDE_ELEMENTS_XPATH')"/>
					<xsl:with-param name="defaultValue">
						<xsl:call-template name="getTemplateVariableValue">
							<xsl:with-param name="name">BLOCK_FORMAT_IMAGE_SIDE_ELEMENTS_XPATH</xsl:with-param>
						</xsl:call-template>
					</xsl:with-param>
				</xsl:call-template>
			</xsl:variable>
			<xsl:choose>
				<!--<xsl:when test="string-length($elementXpath) &gt; 0">
					<xsl:for-each select="*[not(name() = 'Label')]">
						<xsl:if test="xalan:evaluate(concat('not(', $elementXpath, ')'))">
							<xsl:apply-templates select="current()"/>
						</xsl:if>
					</xsl:for-each>
				</xsl:when>-->
				<xsl:when test="string-length($elementList) &gt; 0">
					<xsl:for-each select="*[not(name() = 'Label')]">
						<xsl:if test="not(contains($elementList, name()))">
							<xsl:apply-templates select="current()"/>
						</xsl:if>
					</xsl:for-each>
				</xsl:when>
				<xsl:when test="$placeTablesWithImages">
					<xsl:apply-templates select="*[not(name() = 'Label' or name() = 'Media' or name() = 'table')]"/>
				</xsl:when>
				<xsl:otherwise>
					<xsl:apply-templates select="*[not(name() = 'Label' or name() = 'Media')]"/>
				</xsl:otherwise>
			</xsl:choose>
		</xsl:if>
	</xsl:template>

	<xsl:template match="*" mode="isOnBlockFormatMediaSide">
		<xsl:param name="placeTablesWithImages"/>
		<xsl:param name="blockType">
			<xsl:apply-templates select="ancestor::Block[1]" mode="getBlockFormat"/>
		</xsl:param>
		<xsl:variable name="elementList">
			<xsl:call-template name="getTemplateVariableValue">
				<xsl:with-param name="name" select="concat('BLOCK_', $blockType, '_IMAGE_SIDE_ELEMENTS')"/>
				<xsl:with-param name="defaultValue">
					<xsl:call-template name="getTemplateVariableValue">
						<xsl:with-param name="name">BLOCK_FORMAT_IMAGE_SIDE_ELEMENTS</xsl:with-param>
					</xsl:call-template>
				</xsl:with-param>
			</xsl:call-template>
		</xsl:variable>
		<xsl:variable name="elementXpath">
			<xsl:call-template name="getTemplateVariableValue">
				<xsl:with-param name="name" select="concat('BLOCK_', $blockType, '_IMAGE_SIDE_ELEMENTS_XPATH')"/>
				<xsl:with-param name="defaultValue">
					<xsl:call-template name="getTemplateVariableValue">
						<xsl:with-param name="name">BLOCK_FORMAT_IMAGE_SIDE_ELEMENTS_XPATH</xsl:with-param>
					</xsl:call-template>
				</xsl:with-param>
			</xsl:call-template>
		</xsl:variable>
		<xsl:choose>
			<!--<xsl:when test="string-length($elementXpath) &gt; 0">
				<xsl:choose>
					<xsl:when test="xalan:evaluate($elementXpath)">true</xsl:when>
					<xsl:otherwise>false</xsl:otherwise>
				</xsl:choose>
			</xsl:when>-->
			<xsl:when test="string-length($elementList) &gt; 0">
				<xsl:choose>
					<xsl:when test="contains($elementList, name())">true</xsl:when>
					<xsl:otherwise>false</xsl:otherwise>
				</xsl:choose>
			</xsl:when>
			<xsl:when test="name() = 'Media'">true</xsl:when>
			<xsl:otherwise>false</xsl:otherwise>
		</xsl:choose>
	</xsl:template>


	<xsl:template match="*" mode="getAdditionalSpace">
		<xsl:param name="availableWidth"/>
		<xsl:variable name="startIndent1">
			<xsl:call-template name="getPixels">
				<xsl:with-param name="value">
					<xsl:for-each select="ancestor::*[starts-with(name(), 'Block')][1]">
						<xsl:call-template name="getFormat">
							<xsl:with-param name="attributeName">start-indent</xsl:with-param>
							<xsl:with-param name="name" select="@Function"/>
							<xsl:with-param name="defaultValue">
								<xsl:call-template name="getFormat">
									<xsl:with-param name="attributeName">start-indent</xsl:with-param>
									<xsl:with-param name="name">block</xsl:with-param>
									<xsl:with-param name="defaultValue">0cm</xsl:with-param>
								</xsl:call-template>
							</xsl:with-param>
						</xsl:call-template>
					</xsl:for-each>
				</xsl:with-param>
				<xsl:with-param name="dpi" select="$OUTPUT_RESOLUTION"/>
			</xsl:call-template>
		</xsl:variable>
		<xsl:variable name="startIndent2">
			<xsl:call-template name="getPixels">
				<xsl:with-param name="value">
					<xsl:call-template name="getFormat">
						<xsl:with-param name="attributeName">start-indent</xsl:with-param>
						<xsl:with-param name="name">container-block</xsl:with-param>
						<xsl:with-param name="defaultValue">0cm</xsl:with-param>
					</xsl:call-template>
				</xsl:with-param>
				<xsl:with-param name="dpi" select="$OUTPUT_RESOLUTION"/>
			</xsl:call-template>
		</xsl:variable>

		<xsl:variable name="endIndent">
			<xsl:call-template name="getPixels">
				<xsl:with-param name="value">
					<xsl:call-template name="getFormat">
						<xsl:with-param name="attributeName">end-indent</xsl:with-param>
						<xsl:with-param name="name">block</xsl:with-param>
						<xsl:with-param name="defaultValue">0cm</xsl:with-param>
					</xsl:call-template>
				</xsl:with-param>
				<xsl:with-param name="dpi" select="$OUTPUT_RESOLUTION"/>
			</xsl:call-template>
		</xsl:variable>

		<xsl:variable name="level">
			<xsl:apply-templates select="ancestor::InfoMap[1]" mode="getCurrentLevel"/>
		</xsl:variable>

		<xsl:variable name="sectionMarginalBlockCount">
			<xsl:call-template name="getTemplateVariableValue">
				<xsl:with-param name="name" select="concat('SECTION_MARGINAL_BLOCK_COUNT.', $level)"/>
				<xsl:with-param name="defaultValue">
					<xsl:call-template name="getTemplateVariableValue">
						<xsl:with-param name="name">SECTION_MARGINAL_BLOCK_COUNT</xsl:with-param>
					</xsl:call-template>
				</xsl:with-param>
			</xsl:call-template>
		</xsl:variable>

		<xsl:variable name="preSectionMarginalColumnWidthPx">
			<xsl:choose>
				<xsl:when test="string(number($sectionMarginalBlockCount)) != 'NaN' and $sectionMarginalBlockCount &gt; 0 and $sectionMarginalBlockCount &lt; (count(ancestor::Block[1]/preceding-sibling::Block) + 1)">
					<xsl:value-of select="0"/>
				</xsl:when>
				<xsl:otherwise>
					<xsl:apply-templates select="ancestor-or-self::InfoMap[1]" mode="getSectionMarginalColumnWidthPx">
						<xsl:with-param name="level" select="$level"/>
					</xsl:apply-templates>
				</xsl:otherwise>
			</xsl:choose>
		</xsl:variable>

		<xsl:variable name="SPACER_COLUMN_WIDTH">
			<xsl:call-template name="getTemplateVariableValue">
				<xsl:with-param name="name">SPACER_COLUMN_WIDTH</xsl:with-param>
				<xsl:with-param name="defaultValue">0cm</xsl:with-param>
			</xsl:call-template>
		</xsl:variable>
		<xsl:variable name="SPACER_COLUMN_WIDTH_PX">
			<xsl:call-template name="getPixels">
				<xsl:with-param name="value" select="$SPACER_COLUMN_WIDTH"/>
				<xsl:with-param name="dpi" select="$OUTPUT_RESOLUTION"/>
			</xsl:call-template>
		</xsl:variable>

		<xsl:variable name="sectionMarginalColumnWidthPx">
			<xsl:choose>
				<xsl:when test="$preSectionMarginalColumnWidthPx &gt; 0">
					<xsl:value-of select="$preSectionMarginalColumnWidthPx + $SPACER_COLUMN_WIDTH_PX"/>
				</xsl:when>
				<xsl:otherwise>
					<xsl:value-of select="0"/>
				</xsl:otherwise>
			</xsl:choose>
		</xsl:variable>

		<xsl:variable name="blockType">
			<xsl:apply-templates select="ancestor-or-self::Block[1]" mode="getBlockFormat"/>
		</xsl:variable>

		<xsl:variable name="preCustomMarginColumnWidthPx">
			<xsl:call-template name="getPixels">
				<xsl:with-param name="value">
					<xsl:choose>
						<xsl:when test="string-length($blockType) &gt; 0">
							<xsl:for-each select="ancestor-or-self::Block[1]">
								<xsl:apply-templates select="current()" mode="getMarginalColumnWidth">
									<xsl:with-param name="useFallback" select="false()"/>
								</xsl:apply-templates>
							</xsl:for-each>
						</xsl:when>
						<xsl:otherwise>0cm</xsl:otherwise>
					</xsl:choose>
				</xsl:with-param>
				<xsl:with-param name="dpi" select="$OUTPUT_RESOLUTION"/>
			</xsl:call-template>
		</xsl:variable>

		<xsl:variable name="customMarginColumnWidthPx">
			<xsl:choose>
				<xsl:when test="$preCustomMarginColumnWidthPx &gt; 0">
					<xsl:value-of select="$preCustomMarginColumnWidthPx + $SPACER_COLUMN_WIDTH_PX"/>
				</xsl:when>
				<xsl:otherwise>
					<xsl:value-of select="0"/>
				</xsl:otherwise>
			</xsl:choose>
		</xsl:variable>

		<xsl:variable name="colDistance">
			<xsl:call-template name="getTemplateVariableValue">
				<xsl:with-param name="name" select="concat('COL_DISTANCE_', $blockType)"/>
				<xsl:with-param name="defaultValue">
					<xsl:call-template name="getTemplateVariableValue">
						<xsl:with-param name="name">COL_DISTANCE</xsl:with-param>
						<xsl:with-param name="defaultValue" select="$COL_DISTANCE_DEFAULT_VALUE"/>
					</xsl:call-template>
				</xsl:with-param>
			</xsl:call-template>
		</xsl:variable>

		<xsl:variable name="startIndent" select="$startIndent1 + $startIndent2 + $endIndent + $customMarginColumnWidthPx + $sectionMarginalColumnWidthPx"/>
		<xsl:variable name="newWidth" select="$availableWidth - $startIndent"/>

		<xsl:variable name="isInline" select="parent::InfoPar or parent::EnumElement"/>

		<xsl:variable name="isMediaSide">
			<xsl:apply-templates select="parent::Media" mode="isOnBlockFormatMediaSide">
				<xsl:with-param name="blockType" select="$blockType"/>
			</xsl:apply-templates>
		</xsl:variable>

		<xsl:choose>
			<xsl:when test="$blockType = 'FiftyFiftyMedia' or $blockType = 'FiftyFiftyPic' or $blockType = 'FiftyFiftyText'">
			
				<xsl:variable name="colwidth">
					<xsl:choose>
						<xsl:when test="$blockType = 'FiftyFiftyText'">
							<xsl:call-template name="getTemplateVariableValue">
								<xsl:with-param name="name" select="'FIFTYFIFTYTEXT_COL'"/>
								<xsl:with-param name="defaultValue">0</xsl:with-param>
							</xsl:call-template>
						</xsl:when>
						<xsl:when test="$blockType = 'FiftyFiftyPic'">
							<xsl:call-template name="getTemplateVariableValue">
								<xsl:with-param name="name" select="'FIFTYFIFTYPIC_COL'"/>
								<xsl:with-param name="defaultValue">0</xsl:with-param>
							</xsl:call-template>
						</xsl:when>	
						<xsl:otherwise>0</xsl:otherwise>
					</xsl:choose>
				</xsl:variable>

				<xsl:choose>
					<xsl:when test="$colwidth &gt; 0">
						<xsl:choose>
							<xsl:when test="$blockType = 'FiftyFiftyText'">
								<xsl:choose>
									<xsl:when test="$isInline or $isMediaSide = 'false'">
										<xsl:value-of select="($newWidth * (100 - $colwidth) div 100)"/>
									</xsl:when>
									<xsl:otherwise>
										<xsl:value-of select="($newWidth * (($colwidth + $colDistance) div 100))"/>
									</xsl:otherwise>
								</xsl:choose>
							</xsl:when>
							<xsl:otherwise>
								<xsl:choose>
									<xsl:when test="$isInline or $isMediaSide = 'false'">
										<xsl:value-of select="($newWidth * (($colwidth + $colDistance) div 100))"/>
									</xsl:when>
									<xsl:otherwise>
										<xsl:value-of select="($newWidth * (100 - $colwidth) div 100)"/>
									</xsl:otherwise>
								</xsl:choose>
							</xsl:otherwise>
						</xsl:choose>
					</xsl:when>
					<xsl:otherwise>
						<xsl:value-of select="concat($startIndent + ($newWidth * ((50 + $colDistance div 2) div 100)), 'px')"/>
					</xsl:otherwise>	
				</xsl:choose>	
			</xsl:when>
			<xsl:when test="$blockType = 'TextintensivTextbetont' or $blockType = 'TextText'">
				<xsl:variable name="TEXTTEXT_COL">
					<xsl:call-template name="getTemplateVariableValue">
						<xsl:with-param name="name">TEXTTEXT_COL</xsl:with-param>
						<xsl:with-param name="defaultValue" select="$TEXTTEXT_COL_DEFAULT_VALUE"/>
					</xsl:call-template>
				</xsl:variable>
				<xsl:choose>
					<xsl:when test="$isInline or $isMediaSide = 'false'">
						<xsl:value-of select="concat($startIndent + ($newWidth * ($TEXTTEXT_COL div 100)), 'px')"/>
					</xsl:when>
					<xsl:otherwise>
						<xsl:value-of select="concat($startIndent + ($newWidth * ((100 - $TEXTTEXT_COL) div 100)), 'px')"/>
					</xsl:otherwise>
				</xsl:choose>
			</xsl:when>
			<xsl:when test="$blockType = 'TextintensivBildbetont' or $blockType = 'TextBild'">
				<xsl:variable name="TEXTBILD_COL">
					<xsl:call-template name="getTemplateVariableValue">
						<xsl:with-param name="name">TEXTBILD_COL</xsl:with-param>
						<xsl:with-param name="defaultValue" select="$TEXTBILD_COL_DEFAULT_VALUE"/>
					</xsl:call-template>
				</xsl:variable>
				<xsl:choose>
					<xsl:when test="$isInline or $isMediaSide = 'false'">
						<xsl:value-of select="concat($startIndent + ($newWidth * ($TEXTBILD_COL div 100)), 'px')"/>
					</xsl:when>
					<xsl:otherwise>
						<xsl:value-of select="concat($startIndent + ($newWidth * ((100 - $TEXTBILD_COL) div 100)), 'px')"/>
					</xsl:otherwise>
				</xsl:choose>
			</xsl:when>
			<xsl:when test="$blockType = 'BildTabelle' or $blockType = 'BildintensivTextbetont' or $blockType = 'BildintensivBildbetont'">
				<xsl:variable name="BILDTABELLE_COL">
					<xsl:call-template name="getTemplateVariableValue">
						<xsl:with-param name="name">BILDTABELLE_COL</xsl:with-param>
						<xsl:with-param name="defaultValue" select="$BILDTABELLE_COL_DEFAULT_VALUE"/>
					</xsl:call-template>
				</xsl:variable>
				<xsl:choose>
					<xsl:when test="$isInline or $isMediaSide = 'false'">
						<xsl:value-of select="concat($startIndent + ($newWidth * ($BILDTABELLE_COL div 100)), 'px')"/>
					</xsl:when>
					<xsl:otherwise>
						<xsl:value-of select="concat($startIndent + ($newWidth * ((100 - $BILDTABELLE_COL) div 100)), 'px')"/>
					</xsl:otherwise>
				</xsl:choose>
			</xsl:when>
			<xsl:when test="$blockType = 'GanzeBreite'">
				<xsl:value-of select="concat($startIndent, 'px')"/>
			</xsl:when>
			<xsl:otherwise>
				<xsl:variable name="marginColumnWidthPx">
					<xsl:call-template name="getPixels">
						<xsl:with-param name="value">
							<xsl:apply-templates select="ancestor::*[starts-with(name(), 'Block')][1]" mode="getMarginalColumnWidth"/>
						</xsl:with-param>
						<xsl:with-param name="dpi" select="$OUTPUT_RESOLUTION"/>
					</xsl:call-template>
				</xsl:variable>
				<xsl:choose>
					<xsl:when test="$marginColumnWidthPx &gt; 0">
						<xsl:value-of select="concat($startIndent - $customMarginColumnWidthPx + $marginColumnWidthPx + $SPACER_COLUMN_WIDTH_PX, 'px')"/>
					</xsl:when>
					<xsl:otherwise>
						<xsl:value-of select="concat($startIndent, 'px')"/>
					</xsl:otherwise>
				</xsl:choose>
			</xsl:otherwise>
		</xsl:choose>
	</xsl:template>

	<xsl:template match="Block | Block.remark" mode="getMarginalColumnWidth">
		<xsl:param name="blockPos" select="count(preceding-sibling::Block) + 1"/>
		<xsl:param name="useFallback" select="true()"/>
		<xsl:param name="isGlossary" select="boolean(ancestor::*[@glossary])"/>
		<xsl:choose>
			<xsl:when test="$isGlossary">0</xsl:when>
			<xsl:otherwise>
				<xsl:variable name="level">
					<xsl:apply-templates select="ancestor::InfoMap[1]" mode="getCurrentLevel"/>
				</xsl:variable>
				<xsl:variable name="width">
					<xsl:call-template name="getTemplateVariableValue">
						<xsl:with-param name="name" select="concat($level, '_', $blockPos, '_MARGINAL_COLUMN_WIDTH')"/>
						<xsl:with-param name="defaultValue">
							<xsl:call-template name="getTemplateVariableValue">
								<xsl:with-param name="name" select="concat(@Function, '_MARGINAL_COLUMN_WIDTH')"/>
								<xsl:with-param name="defaultValue">
									<xsl:call-template name="getTemplateVariableValue">
										<xsl:with-param name="name">MARGINAL_COLUMN_WIDTH</xsl:with-param>
										<xsl:with-param name="defaultValue">0cm</xsl:with-param>
									</xsl:call-template>
								</xsl:with-param>
							</xsl:call-template>
						</xsl:with-param>
					</xsl:call-template>
				</xsl:variable>
				<xsl:choose>
					<xsl:when test="string-length(@Typ) &gt; 0">
						<xsl:call-template name="getTemplateVariableValue">
							<xsl:with-param name="name" select="concat($level, '_', $blockPos, '_', @Typ, '_MARGINAL_COLUMN_WIDTH')"/>
							<xsl:with-param name="defaultValue">
								<xsl:call-template name="getTemplateVariableValue">
									<xsl:with-param name="name" select="concat(@Typ, '_MARGINAL_COLUMN_WIDTH')"/>
									<xsl:with-param name="defaultValue">
										<xsl:choose>
											<xsl:when test="$useFallback">
												<xsl:value-of select="$width"/>
											</xsl:when>
											<xsl:otherwise>0cm</xsl:otherwise>
										</xsl:choose>
									</xsl:with-param>
								</xsl:call-template>
							</xsl:with-param>
						</xsl:call-template>
					</xsl:when>
					<xsl:otherwise>
						<xsl:value-of select="$width"/>
					</xsl:otherwise>
				</xsl:choose>
			</xsl:otherwise>
		</xsl:choose>
	</xsl:template>

	<xsl:template match="Block | Block.remark" mode="writeDefaultBlock">
		<xsl:param name="isGlossary" select="boolean(ancestor::*[@glossary])"/>
		<xsl:param name="hasCustomRegions"/>
		<xsl:param name="pageRegionElem"/>
		<xsl:param name="blockPos"/>
		<fo:block start-indent="0" end-indent="0">
			<xsl:call-template name="addStyle">
				<xsl:with-param name="name">container-block</xsl:with-param>
			</xsl:call-template>
			<xsl:if test="$isGlossary">
				<xsl:attribute name="start-indent">0.3cm</xsl:attribute>
			</xsl:if>
			<xsl:apply-templates select="current()" mode="writeLabel">
				<xsl:with-param name="isGlossary" select="$isGlossary"/>
				<xsl:with-param name="hasCustomRegions" select="$hasCustomRegions"/>
				<xsl:with-param name="pageRegionElem" select="$pageRegionElem"/>
				<xsl:with-param name="blockPos" select="$blockPos"/>
			</xsl:apply-templates>
			<fo:block start-indent="0cm">
				<xsl:call-template name="addStyle">
					<xsl:with-param name="name">container-block-contents</xsl:with-param>
				</xsl:call-template>
				<xsl:if test="$isGlossary">
					<xsl:attribute name="start-indent">0cm</xsl:attribute>
				</xsl:if>
				<xsl:apply-templates select="current()" mode="writeBlockContents">
					<xsl:with-param name="hasCustomRegions" select="$hasCustomRegions"/>
					<xsl:with-param name="pageRegionElem" select="$pageRegionElem"/>
				</xsl:apply-templates>
			</fo:block>
		</fo:block>
	</xsl:template>

	<xsl:template match="Block | Block.remark" mode="writeBlockContents">
		<xsl:param name="hasCustomRegions"/>
		<xsl:param name="pageRegionElem"/>
		<xsl:choose>
			<xsl:when test="$hasCustomRegions">
				<xsl:variable name="ignoreText" select="boolean($pageRegionElem/CustomRegions/Region[@assignContentType = 'Text' or @assignContentType = 'TextLabel'])"/>
				<xsl:variable name="ignoreImages" select="boolean($pageRegionElem/CustomRegions/Region[@assignContentType = 'Image'])"/>
				<xsl:choose>
					<xsl:when test="$ignoreText and not($ignoreImages)">
						<xsl:apply-templates select="Media"/>
					</xsl:when>
					<xsl:when test="not($ignoreText) and $ignoreImages">
						<xsl:apply-templates select="*[not(name() = 'Label' or name() = 'Media')]"/>
					</xsl:when>
					<xsl:when test="not($ignoreText) and not($ignoreImages)">
						<xsl:apply-templates select="*[not(name() = 'Label')]"/>
					</xsl:when>
				</xsl:choose>
			</xsl:when>
			<xsl:otherwise>
				<xsl:apply-templates select="*[not(name() = 'Label')]"/>
			</xsl:otherwise>
		</xsl:choose>
	</xsl:template>

	<xsl:template match="Block | Block.remark" mode="writeLabel">
		<xsl:param name="isGlossary" select="boolean(ancestor::*[@glossary])"/>
		<xsl:param name="keep-with-next">always</xsl:param>
		<xsl:param name="customStyle"/>
		<xsl:param name="hasCustomRegions"/>
		<xsl:param name="pageRegionElem"/>
		<xsl:param name="blockPos"/>

		<xsl:if test="$blockPos = 1">
			<xsl:variable name="writeHeadline">
				<xsl:call-template name="getTemplateVariableValue">
					<xsl:with-param name="name">RENDER_HEADLINE_CONTENT_WITH_FIRST_BLOCK</xsl:with-param>
					<xsl:with-param name="defaultValue">false</xsl:with-param>
				</xsl:call-template>
			</xsl:variable>
			<xsl:if test="$writeHeadline = 'true'">
				<xsl:apply-templates select="ancestor::InfoMap[1]" mode="writeHeadlineContent"/>
			</xsl:if>
		</xsl:if>
		
		<xsl:variable name="writeEmptyLabel">
			<xsl:call-template name="getTemplateVariableValue">
				<xsl:with-param name="name" select="'ALLOW_EMPTY_LABEL'"/>
				<xsl:with-param name="defaultValue">true</xsl:with-param>
			</xsl:call-template>
		</xsl:variable>
		<xsl:variable name="hasLabel" select="string-length(Label) &gt; 0 or Label/Media.theme"/>
		<xsl:if test="($writeEmptyLabel = 'true' or $hasLabel) and (not($hasCustomRegions) or not($pageRegionElem/CustomRegions/Region[@assignContentType = 'Label' or @assignContentType = 'TextLabel']))">
			<fo:block start-indent="0cm" keep-with-next="{$keep-with-next}" orphans="2" widows="2">
				<xsl:choose>
					<xsl:when test="not($hasLabel)">
						<xsl:call-template name="addStyle">
							<xsl:with-param name="name">label</xsl:with-param>
						</xsl:call-template>
						<xsl:call-template name="addStyle">
							<xsl:with-param name="name">label.empty</xsl:with-param>
						</xsl:call-template>
						<xsl:if test="$isGlossary">
							<xsl:attribute name="space-before">3pt</xsl:attribute>
							<xsl:attribute name="start-indent">0cm</xsl:attribute>
						</xsl:if>
						<xsl:text> </xsl:text>
					</xsl:when>
					<xsl:otherwise>
						<xsl:call-template name="addStyle">
							<xsl:with-param name="name">label</xsl:with-param>
						</xsl:call-template>
						<xsl:if test="Label">
							<xsl:call-template name="addStyle">
								<xsl:with-param name="name">label</xsl:with-param>
								<xsl:with-param name="currentElement" select="Label"/>
							</xsl:call-template>
						</xsl:if>
						<xsl:if test="string-length($customStyle) &gt; 0">
							<xsl:call-template name="addStyle">
								<xsl:with-param name="name" select="$customStyle"/>
							</xsl:call-template>
						</xsl:if>
						<xsl:if test="$isGlossary">
							<xsl:attribute name="space-before">3pt</xsl:attribute>
							<xsl:attribute name="start-indent">0cm</xsl:attribute>
						</xsl:if>
						<fo:block>
							<xsl:apply-templates select="Label"/>
						</fo:block>
					</xsl:otherwise>
				</xsl:choose>
			</fo:block>
		</xsl:if>
	</xsl:template>

	<xsl:template match="block.titlepage">
		<xsl:variable name="blockTitlePageDisplayType">
			<xsl:apply-templates select="current()" mode="getDisplayType"/>
		</xsl:variable>

		<xsl:if test="not($blockTitlePageDisplayType = 'hidden')">
			<fo:block>
				<xsl:call-template name="addStyle">
					<xsl:with-param name="name">titlepage.topbar</xsl:with-param>
				</xsl:call-template>
			</fo:block>

			<xsl:variable name="logoUrl">
				<xsl:call-template name="getTemplateGraphicURL">
					<xsl:with-param name="name">logo</xsl:with-param>
				</xsl:call-template>
			</xsl:variable>

			<xsl:if test="string-length($logoUrl) &gt; 0">

				<fo:block>
					<xsl:call-template name="addStyle">
						<xsl:with-param name="name">titlepage.logo.container</xsl:with-param>
					</xsl:call-template>
					<fo:external-graphic src="url('{normalize-space($logoUrl)}')" content-width="scale-to-fit">
						<xsl:call-template name="addStyle">
							<xsl:with-param name="name">titlepage.logo</xsl:with-param>
						</xsl:call-template>
					</fo:external-graphic>
				</fo:block>

			</xsl:if>

			<fo:block>
				<xsl:call-template name="addStyle">
					<xsl:with-param name="name">titlepage.title.theme</xsl:with-param>
				</xsl:call-template>
				<xsl:apply-templates select="title.theme"/>
			</fo:block>

			<fo:block>
				<xsl:call-template name="addStyle">
					<xsl:with-param name="name">titlepage.image</xsl:with-param>
				</xsl:call-template>
				<xsl:apply-templates select="image.detail/Media.theme"/>
			</fo:block>

			<fo:block>
				<xsl:call-template name="addStyle">
					<xsl:with-param name="name">titlepage.optional.title</xsl:with-param>
				</xsl:call-template>
				<xsl:apply-templates select="optional.title"/>
			</fo:block>

			<fo:block>
				<xsl:call-template name="addStyle">
					<xsl:with-param name="name">titlepage.title</xsl:with-param>
				</xsl:call-template>
				<xsl:apply-templates select="title"/>
			</fo:block>
		</xsl:if>
	</xsl:template>

	<xsl:template match="InfoPar" mode="text">
		<xsl:apply-templates/>
	</xsl:template>


	<xsl:template name="addStyle">
		<xsl:param name="name"/>
		<xsl:param name="attributeNamesList"/>
		<xsl:param name="currentElement" select="current()"/>
		<xsl:param name="altCurrentElement"/>
		<xsl:param name="writeTranslationHelperStyle" select="true()"/>

		<xsl:call-template name="addFormat">
			<xsl:with-param name="name" select="$name"/>
			<xsl:with-param name="attributeNamesList" select="$attributeNamesList"/>
			<xsl:with-param name="currentElement" select="$currentElement"/>
			<xsl:with-param name="altCurrentElement" select="$altCurrentElement"/>
		</xsl:call-template>

		<xsl:if test="$isTranslationHelper and $writeTranslationHelperStyle">
			<xsl:apply-templates select="$currentElement" mode="setTranslationHelperStyle"/>
		</xsl:if>
		<xsl:apply-templates select="$currentElement" mode="setDiffStyle"/>
		<xsl:apply-templates select="$currentElement" mode="setCustomStyle"/>
	</xsl:template>

	<xsl:template match="*" mode="setCustomStyle"/>

	<xsl:template match="*" mode="setTranslationHelperStyle">
		<xsl:variable name="translate">
			<xsl:choose>
				<xsl:when test="name() = 'Headline.content'">
					<xsl:value-of select="parent::*/@translate"/>
				</xsl:when>
				<xsl:when test="name() = 'Block' and not(@translate)">
					<xsl:value-of select="parent::*/@translate"/>
				</xsl:when>
				<xsl:otherwise>
					<xsl:value-of select="current()/@translate"/>
				</xsl:otherwise>
			</xsl:choose>
		</xsl:variable>

		<xsl:variable name="ancestorId" select="generate-id(ancestor-or-self::InfoMap[1])"/>
		<xsl:variable name="isAncestorDiff" select="ancestor-or-self::InfoMap[1]/@status-diff = 'DIFF'"/>

		<xsl:if test="($isAncestorDiff and ancestor-or-self::*[generate-id(ancestor-or-self::InfoMap[1]) = $ancestorId and string-length(@Changed) &gt; 0 and @Changed != 'DELETED' and not(starts-with(name(), 'Include.') and @Changed = 'UPDATED')])
			or ($translate = 'true' and not($isAncestorDiff)) or @translate = 'true'">
			<xsl:attribute name="color">blue</xsl:attribute>
		</xsl:if>
	</xsl:template>

	<xsl:variable name="PAGE_HEIGHT">
		<xsl:choose>
			<xsl:when test="string-length($formatElements/PageGeometry/@height) &gt; 0">
				<xsl:value-of select="concat($formatElements/PageGeometry/@height, $formatElements/PageGeometry/@unit)"/>
			</xsl:when>
			<xsl:otherwise>
				<xsl:call-template name="getTemplateVariableValue">
					<xsl:with-param name="name">PAGE_HEIGHT</xsl:with-param>
					<xsl:with-param name="defaultValue">297mm</xsl:with-param>
				</xsl:call-template>
			</xsl:otherwise>
		</xsl:choose>
	</xsl:variable>
	<xsl:variable name="PAGE_WIDTH">
		<xsl:choose>
			<xsl:when test="string-length($formatElements/PageGeometry/@width) &gt; 0">
				<xsl:value-of select="concat($formatElements/PageGeometry/@width, $formatElements/PageGeometry/@unit)"/>
			</xsl:when>
			<xsl:otherwise>
				<xsl:call-template name="getTemplateVariableValue">
					<xsl:with-param name="name">PAGE_WIDTH</xsl:with-param>
					<xsl:with-param name="defaultValue">210mm</xsl:with-param>
				</xsl:call-template>
			</xsl:otherwise>
		</xsl:choose>
	</xsl:variable>

	<xsl:variable name="OUTPUT_RESOLUTION" select="72"/>
	<xsl:variable name="COL_DISTANCE_DEFAULT_VALUE" select="2.64"/>
	<xsl:variable name="TEXTTEXT_COL_DEFAULT_VALUE" select="32"/>
	<xsl:variable name="TEXTBILD_COL_DEFAULT_VALUE" select="35"/>
	<xsl:variable name="BILDTABELLE_COL_DEFAULT_VALUE" select="64"/>

</xsl:stylesheet>
