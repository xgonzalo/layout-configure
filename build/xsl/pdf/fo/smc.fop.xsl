<?xml version="1.0" encoding="UTF-8" standalone="no"?>
<xsl:stylesheet version="1.0"
				xmlns:fo="http://www.w3.org/1999/XSL/Format"
				xmlns:fox="http://xmlgraphics.apache.org/fop/extensions"
				xmlns:xsl="http://www.w3.org/1999/XSL/Transform">

	<xsl:include href="smc.fop.chars.xsl"/>
	<xsl:include href="smc.fop.enum.xsl"/>
	<xsl:include href="smc.fop.overview.xsl"/>
	<xsl:include href="smc.fop.media.xsl"/>
	<xsl:include href="smc.fop.media_av.xsl"/>
	<xsl:include href="smc.fop.headline.xsl"/>
	<xsl:include href="smc.fop.links.xsl"/>
	<xsl:include href="smc.fop.label.xsl"/>
	<xsl:include href="smc.fop.toc.xsl"/>
	<xsl:include href="smc.fop.legend.xsl"/>
	<xsl:include href="smc.fop.index.xsl"/>
	<xsl:include href="smc.fop.symbols.xsl"/>
	<xsl:include href="smc.fop.related.xsl"/>
	<xsl:include href="smc.fop.table.xsl"/>
	<xsl:include href="smc.fop.format.xsl"/>
	<xsl:include href="smc.fop.form.xsl"/>
	<xsl:include href="smc.fop.diff-marker.xsl"/>
	<xsl:include href="smc.fop.printmarks.xsl"/>
	<xsl:include href="smc.fop.notice.xsl"/>
	<xsl:include href="smc.fop.im.xsl"/>
	<xsl:include href="../common/smc.urls.xsl"/>
	<xsl:include href="../common/smc.encoder.xsl"/>
	<xsl:include href="../common/smc.unit-converter.xsl"/>

	<xsl:param name="Offline"/>
	<xsl:variable name="isOffline" select="$Offline = 'Offline'"/>
	<xsl:param name="PDF_XMODE_ENABLED"/>
	<xsl:variable name="isPDFXMODE" select="$PDF_XMODE_ENABLED = 'true'"/>
	<xsl:variable name="isRightToLeftLanguage" select="$language = 'he' or $language = 'ar'"/>
	<xsl:param name="Online"/>
	<xsl:param name="imageAssetsPath"/>
	<xsl:param name="productionTempPath"/>
	<xsl:param name="CLIENT"/>
	<xsl:param name="AHMode"/>
	<xsl:variable name="isAHMode" select="$AHMode = 'AHMode'"/>
	<xsl:param name="showCharacterization"/>
	<xsl:param name="language"/>
	<xsl:param name="translation_target_language"/>
	<xsl:param name="versionLabel"/>
	<xsl:param name="objType"/>
	<xsl:param name="serverID"/>
	<xsl:param name="brokerServerURL"/>
	<xsl:param name="tp_subRulesID"/>
	<xsl:param name="tp_bookID"/>
	<xsl:param name="tp_nodeID"/>
	<xsl:param name="noticeTypes"/>
	<xsl:variable name="hasNoticeTypes" select="string-length($noticeTypes) &gt; 0"/>
	<xsl:param name="tp_brokerServerURL"/>

	<xsl:param name="CHAPTER_WISE"/>
	<xsl:param name="generate_translation_helper"/>
	<xsl:variable name="isTranslationHelper" select="$generate_translation_helper = 'true'"/>
	<xsl:param name="CMS"/>
	<xsl:variable name="isChapterWise" select="$CHAPTER_WISE = 'true'"/>

	<xsl:key name="InfoMapKey" match="//InfoMap" use="@ID"/>
	<xsl:key name="LinkElementKey" match="//Media.theme | //table" use="@ID"/>
	<xsl:key name="IndexEntryKey" match="//index.entry" use="@ID"/>
	<xsl:key name="BlockKey" match="//Block" use="@ID"/>
	<xsl:key name="BlockTitlepageLanguageKey" match="//block.titlepage" use="@defaultLanguage"/>

	<!--<xsl:variable name="ATTACHMENT_NAME_MAP" select="map:new()"/>-->
	<xsl:variable name="TIMESTAMP" select="'123456'"/>

	<xsl:variable name="productionImagePath" select="concat('file:///', translate($productionTempPath, '\', '/'))"/>
	
	<xsl:variable name="clientImageAssetsPath">
		<xsl:choose>
			<xsl:when test="$Offline = 'Offline'">
				<xsl:value-of select="concat('file:///', translate($productionTempPath, '\', '/'), '/')"/>
			</xsl:when>
			<xsl:when test="substring($imageAssetsPath, string-length($imageAssetsPath)) = '/'">
				<xsl:value-of select="concat('', $imageAssetsPath)"/>
			</xsl:when>
			<xsl:otherwise>
				<xsl:value-of select="concat('', $imageAssetsPath, '/')"/>
			</xsl:otherwise>
		</xsl:choose>
	</xsl:variable>

	<xsl:variable name="BASE_LEVEL">
		<xsl:choose>
			<xsl:when test="not(/InfoMap[not(block.titlepage and InfoMap) and (Block or Block.remark or Headline.content)])">
				<xsl:value-of select="1"/>
			</xsl:when>
			<xsl:when test="not($Offline = 'Offline')">
				<xsl:call-template name="getTemplateVariableValue">
					<xsl:with-param name="name">PREVIEW_DEFAULT_LEVEL</xsl:with-param>
					<xsl:with-param name="defaultValue" select="0"/>
				</xsl:call-template>
			</xsl:when>
			<xsl:otherwise>
				<xsl:value-of select="0"/>
			</xsl:otherwise>
		</xsl:choose>
	</xsl:variable>

	<xsl:variable name="strDISABLE_COLUMN_BALANCING">
		<xsl:call-template name="getTemplateVariableValue">
			<xsl:with-param name="name" select="'DISABLE_COLUMN_BALANCING'"/>
		</xsl:call-template>
	</xsl:variable>

	<xsl:variable name="DISABLE_COLUMN_BALANCING" select="$strDISABLE_COLUMN_BALANCING = 'true'"/>


	<xsl:variable name="isMultiMap" select="boolean(/InfoMap/*[name() = 'InfoMap' or (name() = 'include.document' and InfoMap)])"/>

	<xsl:template name="escapeFileSystemPath">
		<xsl:param name="path"/>
		<xsl:call-template name="replace">
			<xsl:with-param name="string">
				<xsl:call-template name="replace">
					<xsl:with-param name="string" select="$path"/>
					<xsl:with-param name="pattern">%</xsl:with-param>
					<xsl:with-param name="replacement">%25</xsl:with-param>
				</xsl:call-template>
			</xsl:with-param>
			<xsl:with-param name="pattern">#</xsl:with-param>
			<xsl:with-param name="replacement">%23</xsl:with-param>
		</xsl:call-template>
	</xsl:template>
	
	<xsl:template match="Format | StructureProperties"/>

	<xsl:variable name="printEmptyLines">
		<xsl:call-template name="getTemplateVariableValue">
			<xsl:with-param name="name" select="'PAR_PRINT_EMPTY_LINES'"/>
		</xsl:call-template>
	</xsl:variable>

	<xsl:template match="InfoPar">
		<xsl:param name="insideTableCell" select="string(boolean(parent::tableCell))"/>
		<xsl:param name="isInsideNotice"/>
		<xsl:param name="isInsideInstruction"/>

		<xsl:variable name="mainFormatName">
			<xsl:choose>
				<xsl:when test="string-length(formatRef/@formatRef) &gt; 0">
					<xsl:value-of select="formatRef/@formatRef"/>
				</xsl:when>
				<xsl:when test="$insideTableCell = 'true'">table.cell.par</xsl:when>
				<xsl:otherwise>par</xsl:otherwise>
			</xsl:choose>
		</xsl:variable>

		<xsl:variable name="position">
			<xsl:call-template name="getFormat">
				<xsl:with-param name="name" select="$mainFormatName"/>
				<xsl:with-param name="attributeName">position</xsl:with-param>
			</xsl:call-template>
		</xsl:variable>

		<xsl:choose>
			<xsl:when test="string-length($position) &gt; 0 and $position != 'static'">
				<!-- doubly nest for relative positioning -->
				<fo:block-container>
					<xsl:call-template name="addStyle">
						<xsl:with-param name="name">block-level-element</xsl:with-param>
					</xsl:call-template>
					<xsl:call-template name="addStyle">
						<xsl:with-param name="name" select="$mainFormatName"/>
						<xsl:with-param name="attributeNamesList">|keep-with-next|</xsl:with-param>
					</xsl:call-template>
					<fo:block-container>
						<xsl:call-template name="addStyle">
							<xsl:with-param name="name" select="$mainFormatName"/>
						</xsl:call-template>
						<xsl:apply-templates select="current()" mode="simple">
							<xsl:with-param name="insideTableCell" select="$insideTableCell"/>
							<xsl:with-param name="isInsideNotice" select="$isInsideNotice"/>
							<xsl:with-param name="isInsideInstruction" select="$isInsideInstruction"/>
							<xsl:with-param name="applyMainStyle" select="false()"/>
							<xsl:with-param name="mainFormatName" select="$mainFormatName"/>
						</xsl:apply-templates>
					</fo:block-container>
				</fo:block-container>
			</xsl:when>
			<xsl:otherwise>
				<xsl:apply-templates select="current()" mode="simple">
					<xsl:with-param name="insideTableCell" select="$insideTableCell"/>
					<xsl:with-param name="isInsideNotice" select="$isInsideNotice"/>
					<xsl:with-param name="isInsideInstruction" select="$isInsideInstruction"/>
					<xsl:with-param name="mainFormatName" select="$mainFormatName"/>
				</xsl:apply-templates>
			</xsl:otherwise>
		</xsl:choose>
	</xsl:template>

	<xsl:template match="InfoPar" mode="simple">
		<xsl:param name="insideTableCell"/>
		<xsl:param name="isInsideNotice"/>
		<xsl:param name="isInsideInstruction"/>
		<xsl:param name="mainFormatName"/>
		<xsl:param name="applyMainStyle" select="true()"/>
		
		<fo:block widows="2" orphans="2">
			<xsl:call-template name="addStyle">
				<xsl:with-param name="name">block-level-element</xsl:with-param>
			</xsl:call-template>
			<xsl:if test="$insideTableCell = 'true'">
				<xsl:call-template name="addStyle">
					<xsl:with-param name="name">cell.Normal</xsl:with-param>
				</xsl:call-template>
			</xsl:if>

			<xsl:if test="$applyMainStyle">
				<xsl:call-template name="addStyle">
					<xsl:with-param name="name" select="$mainFormatName"/>
				</xsl:call-template>
			</xsl:if>

			<xsl:if test="string-length(@style) &gt; 0">
				<xsl:call-template name="addStyle">
					<xsl:with-param name="name" select="@style"/>
				</xsl:call-template>
			</xsl:if>

			<xsl:if test="$isInsideNotice">
				<xsl:call-template name="addStyle">
					<xsl:with-param name="name">par.notice</xsl:with-param>
				</xsl:call-template>
			</xsl:if>
			<xsl:if test="$isInsideInstruction">
				<xsl:call-template name="addStyle">
					<xsl:with-param name="name">par.instruction</xsl:with-param>
				</xsl:call-template>
			</xsl:if>
			<xsl:if test="@isCalc">
				<xsl:call-template name="addStyle">
					<xsl:with-param name="name">calc</xsl:with-param>
				</xsl:call-template>
			</xsl:if>
			<xsl:if test="@format != ''">
				<xsl:call-template name="addStyle">
					<xsl:with-param name="name" select="concat('par.', @format)"/>
				</xsl:call-template>
			</xsl:if>
			<xsl:choose>
				<xsl:when test="@isMath">
					<xsl:variable name="mathFormat">
						<xsl:call-template name="getTemplateVariableValue">
							<xsl:with-param name="name">MATHWRAPPER_FORMAT</xsl:with-param>
						</xsl:call-template>
					</xsl:variable>
					<xsl:choose>
						<xsl:when test="$mathFormat = 'price' and string(number(.)) != 'NaN'">
							<!--<xsl:variable name="nfIns" select="nf:getInstance()"/>
							<xsl:variable name="sep" select="nf:setGroupingUsed($nfIns, true())"/>
							<xsl:variable name="minDi" select="nf:setMinimumFractionDigits($nfIns, 2)"/>
							<xsl:variable name="maxDi" select="nf:setMaximumFractionDigits($nfIns, 2)"/>
							<xsl:value-of select="nf:format($nfIns, number(.))"/>-->
						</xsl:when>
						<xsl:otherwise>
							<xsl:apply-templates/>
						</xsl:otherwise>
					</xsl:choose>
				</xsl:when>
				<xsl:otherwise>
					<xsl:apply-templates select="current()" mode="writeCharacterizationInfo"/>
					<xsl:apply-templates/>
				</xsl:otherwise>
			</xsl:choose>
			<xsl:if test="$printEmptyLines = 'true' and not(*) and string-length(.) = 0">&#x85;</xsl:if>
		</fo:block>
	</xsl:template>
	
	<xsl:template match="*" mode="writeCharacterizationInfo">
		<xsl:param name="isInline" select="false()"/>
		<xsl:param name="bPadding" select="false()"/>
		<xsl:param name="showContent" select="true()"/>
		<xsl:if test="(string-length(@metafilter) &gt; 0 or string-length(@readableFilter) &gt; 0) and $showCharacterization = 'true'">
        	<xsl:variable name="background">
				<xsl:choose>
					<xsl:when test="string-length(@readableFilter) &gt; 0 and string-length(@charCategoryColor) &gt; 0">
						<xsl:value-of select="@charCategoryColor"/>
					</xsl:when>
					<xsl:when test="string-length(@metafilter) &gt; 0 and string-length(@charPropertyColor) &gt; 0">
						<xsl:value-of select="@charPropertyColor"/>
					</xsl:when>
					<xsl:otherwise>
						<xsl:value-of select="'FFD700'"/>
					</xsl:otherwise>
				</xsl:choose>
			</xsl:variable>
			<xsl:apply-templates select="current()" mode="writeCharacterizationInfoAttributes">
				<xsl:with-param name="bPadding" select="$bPadding"/>
				<xsl:with-param name="background" select="$background"/>
			</xsl:apply-templates>
			<xsl:choose>
				<xsl:when test="name() = 'Enum' or name() = 'Enum.Instruction'">
					<xsl:apply-templates select="current()" mode="writeCharacterizationInfoEnum"/>
				</xsl:when>
				<xsl:otherwise>	
					<xsl:if test="$showContent">
						<xsl:apply-templates select="current()" mode="writeCharacterizationInfoText">
							<xsl:with-param name="isInline" select="$isInline"/>
							<xsl:with-param name="background" select="$background"/>
						</xsl:apply-templates>
					</xsl:if>
				</xsl:otherwise>
			</xsl:choose>
			
		</xsl:if>
	</xsl:template>

	<xsl:template match="*" mode="writeCharacterizationInfoAttributes">
		<xsl:param name="bPadding" select="false()"/>
		<xsl:param name="background"/>
		<xsl:attribute name="border-color">#<xsl:value-of select="$background"/></xsl:attribute>
		<xsl:attribute name="border"></xsl:attribute>
		<xsl:attribute name="border-style">solid</xsl:attribute>
    	<xsl:attribute name="border-width">medium</xsl:attribute>
    	<xsl:if test="$bPadding">
    		<xsl:attribute name="padding-left">2pt</xsl:attribute>
    		<xsl:attribute name="padding-right">2pt</xsl:attribute>
    		<xsl:attribute name="padding-after">2pt</xsl:attribute>
    		<xsl:attribute name="padding-before">0mm</xsl:attribute>
    		<xsl:attribute name="margin-left">0</xsl:attribute>
    		<xsl:attribute name="margin-right">0</xsl:attribute>
    	</xsl:if>
	</xsl:template>

	<xsl:template match="*" mode="writeCharacterizationInfoText">
		<xsl:param name="isInline" select="false()"/>
		<xsl:param name="background"/>
		<xsl:choose>
			<xsl:when test="$isInline">
				<fo:inline font-size="80%" font-weight="normal">
					<xsl:apply-templates select="current()" mode="writeCharacterizationInfoInternal"/>
				</fo:inline>
			</xsl:when>
			<xsl:otherwise>
				<fo:block keep-with-next="always" font-size="80%" font-weight="normal">
					<xsl:if test="name() = 'Headline.content'">
						<xsl:attribute name="font-size">8pt</xsl:attribute>
					</xsl:if>
					<xsl:if test="name() = 'break'">
						<xsl:attribute name="background-color">#<xsl:value-of select="$background"/></xsl:attribute>
					</xsl:if>
					<xsl:apply-templates select="current()" mode="writeCharacterizationInfoInternal"/>
				</fo:block>
			</xsl:otherwise>
		</xsl:choose>
	</xsl:template>

	<xsl:template match="*" mode="writeCharacterizationInfoEnum">
		<fo:list-item>
            <fo:list-item-label>
                <fo:block/>
            </fo:list-item-label>
            <fo:list-item-body>
                <fo:block keep-with-next="always" font-size="80%">
					<xsl:apply-templates select="current()" mode="writeCharacterizationInfoInternal"/>
				</fo:block>
            </fo:list-item-body>
        </fo:list-item>
	</xsl:template>


	<xsl:template match="*" mode="writeCharacterizationInfoRow">
		<xsl:param name="isInline" select="false()"/>
		<xsl:param name="bPadding" select="false()"/>
		<xsl:param name="noBottom" select="false()"/>
		<xsl:param name="colCount" select="1"/>


		<xsl:if test="(string-length(@metafilter) &gt; 0 or string-length(@readableFilter) &gt; 0) and $showCharacterization = 'true'">

        	<xsl:variable name="background">
				<xsl:choose>
					<xsl:when test="string-length(@readableFilter) &gt; 0 and string-length(@charCategoryColor) &gt; 0">
						<xsl:value-of select="@charCategoryColor"/>
					</xsl:when>
					<xsl:when test="string-length(@metafilter) &gt; 0 and string-length(@charPropertyColor) &gt; 0">
						<xsl:value-of select="@charPropertyColor"/>
					</xsl:when>
					<xsl:otherwise>
						<xsl:value-of select="'FFD700'"/>
					</xsl:otherwise>
				</xsl:choose>
			</xsl:variable>

			<fo:table-row border-color="#{$background}">
				<xsl:if test="$noBottom">
					<xsl:attribute name="border-bottom-width">0</xsl:attribute>
				</xsl:if>
				<xsl:apply-templates select="current()" mode="writeCharacterizationInfoAttributes">
					<xsl:with-param name="bPadding" select="$bPadding"/>
					<xsl:with-param name="background" select="$background"/>
				</xsl:apply-templates>
				<fo:table-cell number-columns-spanned="{$colCount}">
					<xsl:apply-templates select="current()" mode="writeCharacterizationInfoText">
						<xsl:with-param name="isInline" select="$isInline"/>
						<xsl:with-param name="background" select="$background"/>
					</xsl:apply-templates>
		    	</fo:table-cell>
		    </fo:table-row>
		</xsl:if>

	</xsl:template>

	<xsl:template match="*" mode="writeCharacterizationInfoInternal">
		<xsl:if test="string-length(@readableFilter) &gt; 0">
			<xsl:variable name="charCategoryColor">
				<xsl:choose>
					<xsl:when test="string-length(@charCategoryColor) &gt; 0">
						<xsl:value-of select="@charCategoryColor"/>
					</xsl:when>
					<xsl:otherwise>
						<xsl:value-of select="'FFD700'"/>
					</xsl:otherwise>
				</xsl:choose>
			</xsl:variable>
			<fo:inline font-style="italic" background-color="#{$charCategoryColor}" color="#000000">
				<xsl:value-of select="@readableFilter"/>
			</fo:inline>
			<xsl:text> </xsl:text>
		</xsl:if>
		<xsl:if test="string-length(@metafilter) &gt; 0 and string-length(@readableFilter) &gt; 0">
			<fo:inline color="#000000">
				<xsl:text>/ </xsl:text>
			</fo:inline>
		</xsl:if>
		<xsl:if test="string-length(@metafilter) &gt; 0">
			<xsl:variable name="charPropertyColor">
				<xsl:choose>
					<xsl:when test="string-length(@charPropertyColor) &gt; 0">
						<xsl:value-of select="@charPropertyColor"/>
					</xsl:when>
					<xsl:otherwise>
						<xsl:value-of select="'FFD700'"/>
					</xsl:otherwise>
				</xsl:choose>
			</xsl:variable>
			<fo:inline font-style="italic" background-color="#{$charPropertyColor}" color="#000000">
				<xsl:value-of select="@metafilter"/>
			</fo:inline>
			<xsl:text> </xsl:text>
		</xsl:if>
	</xsl:template>

	<xsl:template match="Startregion/InfoPar | Endregion/InfoPar | Subline/InfoPar | Headline/InfoPar | regioncontent/InfoPar">
		<fo:block-container>
			<xsl:if test="$isAHMode">
				<!-- AH for some reason puts region content on top of content flow -->
				<xsl:attribute name="z-index">-1</xsl:attribute>
			</xsl:if>
			<xsl:apply-templates select="formatRef"/>
			<fo:block>
				<xsl:apply-templates select="node()[not(name() = 'formatRef')]"/>
			</fo:block>
		</fo:block-container>
	</xsl:template>

	<xsl:template match="InfoPar.Code">
		<fo:block>
			<xsl:call-template name="addStyle">
				<xsl:with-param name="name">block-level-element</xsl:with-param>
			</xsl:call-template>
			<xsl:call-template name="addStyle">
				<xsl:with-param name="name">code</xsl:with-param>
			</xsl:call-template>
			<xsl:apply-templates select="current()" mode="writeCharacterizationInfo">
				<xsl:with-param name="bPadding" select="true()"/>
			</xsl:apply-templates>
			<xsl:apply-templates/>
		</fo:block>
	</xsl:template>
	
	<xsl:template match="code.example">
		<fo:block>
			<xsl:call-template name="addStyle">
				<xsl:with-param name="name">block-level-element</xsl:with-param>
			</xsl:call-template>
			<xsl:call-template name="addStyle">
				<xsl:with-param name="name">code</xsl:with-param>
			</xsl:call-template>
			<xsl:call-template name="addStyle">
				<xsl:with-param name="name">code.example</xsl:with-param>
			</xsl:call-template>
			<xsl:choose>
				<xsl:when test="pre">
					<xsl:apply-templates select="pre/node()" mode="html-to-fo">
						<xsl:with-param name="codeLanguage" select="@codeLanguage"/>
					</xsl:apply-templates>
				</xsl:when>
				<xsl:otherwise>
					<xsl:apply-templates/>
				</xsl:otherwise>
			</xsl:choose>
		</fo:block>
	</xsl:template>

	<xsl:template match="*" mode="html-to-fo"/>

	<xsl:template match="span" mode="html-to-fo">
		<xsl:param name="codeLanguage"/>
		<fo:inline>
			<xsl:copy-of select="@*[name() != 'class']"/>
			<xsl:apply-templates select="current()" mode="applyCodeClass"/>
			<xsl:apply-templates mode="html-to-fo">
				<xsl:with-param name="codeLanguage" select="$codeLanguage"/>
			</xsl:apply-templates>
		</fo:inline>
	</xsl:template>

	<xsl:template match="div" mode="html-to-fo">
		<xsl:param name="codeLanguage"/>
		<fo:block>
			<xsl:copy-of select="@*[name() != 'class']"/>
			<xsl:apply-templates select="current()" mode="applyCodeClass"/>
			<xsl:apply-templates mode="html-to-fo">
				<xsl:with-param name="codeLanguage" select="$codeLanguage"/>
			</xsl:apply-templates>
		</fo:block>
	</xsl:template>

	<xsl:template match="*" mode="applyCodeClass">
		<xsl:param name="class" select="@class"/>
		<xsl:if test="string-length($class) &gt; 0">
			<xsl:choose>
				<xsl:when test="contains($class, ' ')">
					<xsl:apply-templates select="current()" mode="applyCodeClass">
						<xsl:with-param name="class" select="substring-after($class, ' ')"/>
					</xsl:apply-templates>
					<xsl:call-template name="addStyle">
						<xsl:with-param name="name" select="substring-before($class, ' ')"/>
					</xsl:call-template>
				</xsl:when>
				<xsl:otherwise>
					<xsl:call-template name="addStyle">
						<xsl:with-param name="name" select="$class"/>
					</xsl:call-template>
				</xsl:otherwise>
			</xsl:choose>
		</xsl:if>
	</xsl:template>

	<xsl:template match="*" mode="printText">
		<xsl:apply-templates mode="printText"/>
	</xsl:template>

	<xsl:template match="space" mode="printText">
		<xsl:text> </xsl:text>
	</xsl:template>

	<xsl:template match="*" mode="applyChildren">
		<xsl:param name="isInsideMarker"/>
		<xsl:apply-templates>
			<xsl:with-param name="isInsideMarker" select="$isInsideMarker"/>
		</xsl:apply-templates>
	</xsl:template>

	<xsl:template match="topicID | production.details | note"/>

	<xsl:template match="Include.Block">
		<fo:block>
			<xsl:call-template name="addStyle">
				<xsl:with-param name="name">include.block</xsl:with-param>
			</xsl:call-template>
			<xsl:apply-templates select="current()" mode="writeCharacterizationInfo">
				<xsl:with-param name="bPadding" select="true()"/>
			</xsl:apply-templates>
			<xsl:apply-templates/>
		</fo:block>
	</xsl:template>
	
	<xsl:template match="Include.Content">
		<fo:block>
			<xsl:call-template name="addStyle">
				<xsl:with-param name="name">include.content</xsl:with-param>
			</xsl:call-template>
			<xsl:apply-templates/>
		</fo:block>
	</xsl:template>
	
	<xsl:template match="smc:translate" xmlns:smc="http://www.expert-communication.de/smc">
		<xsl:call-template name="translate">
			<xsl:with-param name="ID">
				<xsl:apply-templates />
			</xsl:with-param>
		</xsl:call-template>
	</xsl:template>

	<xsl:template match="*" mode="writeDestination">
		<xsl:param name="ID" select="@ID"/>
		<xsl:variable name="PDF_OUTPUT_NAMED_DESTINATIONS">
			<xsl:call-template name="getTemplateVariableValue">
				<xsl:with-param name="name">PDF_OUTPUT_NAMED_DESTINATIONS</xsl:with-param>
				<xsl:with-param name="defaultValue">false</xsl:with-param>
			</xsl:call-template>
		</xsl:variable>
		<xsl:if test="$PDF_OUTPUT_NAMED_DESTINATIONS = 'true'
				and not(ancestor::StandardPageRegion[1])">
			<fox:destination internal-destination="{$ID}"/>
			<!-- <xsl:apply-templates match="current()" mode="writeCustomDestination"/>-->
		</xsl:if>
	</xsl:template>

	<xsl:template match="anchor"/>

	<xsl:template match="*" mode="writeCustomDestination"/>

	<xsl:template match="InfoMap" mode="writeCustomDestination">
		<xsl:if test="WebInfo/topicID">
			<xsl:for-each select="WebInfo/topicID">
				<fox:destination internal-destination="{.}"/>
			</xsl:for-each>
		</xsl:if>
	</xsl:template>

	<xsl:template match="Block" mode="writeCustomDestination">
		<xsl:if test="topicID">
			<xsl:for-each select="topicID">
				<fox:destination internal-destination="{.}"/>
			</xsl:for-each>
		</xsl:if>
	</xsl:template>

	<xsl:template match="anchor" mode="id-attribute"/>

	<xsl:template match="notes">
		<xsl:if test="$hasNoticeTypes and note">
			<fo:block-container width="6cm" padding="6pt">
				<xsl:attribute name="background-color">
					<xsl:choose>
						<xsl:when test="note/Field[@name='state']='finished'">#B8FDBB</xsl:when>
						<xsl:when test="note/Field[@name='overdue']='1'">#FF9198</xsl:when>
						<xsl:otherwise>#FAF5A0</xsl:otherwise>
					</xsl:choose>
				</xsl:attribute>
				<fo:block border-bottom="1px solid #c04b00">
                    <xsl:if test="string-length(note/Field[@name = 'title']) &gt; 0">
                    	<xsl:value-of select="note/Field[@name = 'title']"/>
                    </xsl:if>
					<xsl:text> (</xsl:text>
					<xsl:value-of select="note/Field[@name = 'owner']"/>
					<xsl:text>)</xsl:text>
				</fo:block>
				<fo:block>
					<xsl:if test="string-length(note/Field[@name = 'description']) &gt; 0">
						<xsl:value-of select="note/Field[@name = 'description']"/>
					</xsl:if>
				</fo:block>
				<fo:block>
					<xsl:if test="note/Field[@name = 'isDefaultTemplate' and text() = 'false']">
						<xsl:for-each select="note/Field[string-length(@title) &gt; 0]">
							<fo:block>
								<xsl:value-of select="text()"/>
							</fo:block>
						</xsl:for-each>
					</xsl:if>
				</fo:block>
			</fo:block-container>
		</xsl:if>
	</xsl:template>

	<xsl:template match="notes" mode="printText"/>
	<xsl:template match="Link.note" mode="printText"/>

	<xsl:template name="getCurrentLanguage">
		<xsl:param name="currentElement" select="current()"/>
		<xsl:choose>
			<xsl:when test="string-length($translation_target_language) &gt; 0">
				<xsl:value-of select="$translation_target_language"/>
			</xsl:when>
			<xsl:when test="string-length($currentElement/ancestor-or-self::*[@defaultLanguage][1]/@defaultLanguage) &gt; 0">
				<xsl:value-of select="$currentElement/ancestor-or-self::*[@defaultLanguage][1]/@defaultLanguage"/>
			</xsl:when>
			<xsl:when test="$currentElement/ancestor-or-self::InfoMap[1]/@Lang">
				<xsl:value-of select="$currentElement/ancestor-or-self::InfoMap[1]/@Lang"/>
			</xsl:when>
			<xsl:when test="string-length($translation_target_language) &gt; 0">
				<xsl:value-of select="$translation_target_language"/>
			</xsl:when>
			<xsl:otherwise>
				<xsl:value-of select="$language"/>
			</xsl:otherwise>
		</xsl:choose>
	</xsl:template>

	<xsl:template name="applyPageSequenceAttribute">
		<xsl:param name="attributeName"/>
		<xsl:param name="level"/>
		<xsl:variable name="val">
			<xsl:call-template name="getFormat">
				<xsl:with-param name="name">
					<xsl:choose>
						<xsl:when test="@HideInNavigation = 'true'">headline.content</xsl:when>
						<xsl:otherwise>
							<xsl:value-of select="concat('headline.content.', $level)"/>
						</xsl:otherwise>
					</xsl:choose>
				</xsl:with-param>
				<xsl:with-param name="attributeName" select="$attributeName"/>
				<xsl:with-param name="defaultValue">
					<xsl:call-template name="getFormat">
						<xsl:with-param name="name" select="concat('section.', $level)"/>
						<xsl:with-param name="attributeName" select="$attributeName"/>
						<xsl:with-param name="defaultValue">
							<xsl:call-template name="getFormat">
								<xsl:with-param name="name">section</xsl:with-param>
								<xsl:with-param name="attributeName" select="$attributeName"/>
							</xsl:call-template>
						</xsl:with-param>
					</xsl:call-template>
				</xsl:with-param>
			</xsl:call-template>
		</xsl:variable>
		<xsl:if test="string-length($val) &gt; 0">
			<xsl:attribute name="{$attributeName}">
				<xsl:value-of select="$val"/>
			</xsl:attribute>
		</xsl:if>
	</xsl:template>

	<xsl:template name="getColumnCount">
		<xsl:call-template name="getStandardPageRegionFormat">
			<xsl:with-param name="pageRegionType">odd</xsl:with-param>
			<xsl:with-param name="name">column-count</xsl:with-param>
			<xsl:with-param name="defaultValue">
				<xsl:call-template name="getStandardPageRegionFormat">
					<xsl:with-param name="pageRegionType">even</xsl:with-param>
					<xsl:with-param name="name">column-count</xsl:with-param>
					<xsl:with-param name="defaultValue" select="1"/>
				</xsl:call-template>
			</xsl:with-param>
		</xsl:call-template>
	</xsl:template>

</xsl:stylesheet>
