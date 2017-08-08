<?xml version="1.0" encoding="utf-8"?>
<xsl:stylesheet
	xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
	xmlns:fo="http://www.w3.org/1999/XSL/Format"
	version="1.0">

	<xsl:template match="InfoMap" mode="TOC">
		<xsl:param name="filterHideInNavigation">
			<xsl:call-template name="getTemplateVariableValue">
				<xsl:with-param name="name" select="'PDF_TOC_FILTER_HIDDEN_ENTRIES'"/>
				<xsl:with-param name="defaultValue">false</xsl:with-param>
			</xsl:call-template>
		</xsl:param>
		<xsl:param name="isRoot" select="true()"/>
		<xsl:param name="isChapterWise"/>
		<!-- DO_COUNT_LABELS is defined in smc.fop.headline.xsl -->
		<xsl:param name="listBlocks" select="$DO_COUNT_LABELS"/>
		<xsl:param name="allowSystemNameFallback" select="false()"/>
		<xsl:param name="levels">
			<xsl:call-template name="getTemplateVariableValue">
				<xsl:with-param name="name" select="'PDF_TOC_MAX_LEVELS'"/>
				<xsl:with-param name="defaultValue" select="10"/>
			</xsl:call-template>
		</xsl:param>

		<xsl:variable name="allowTitleFallback">
			<xsl:call-template name="getTemplateVariableValue">
				<xsl:with-param name="name">GENERATE_CONTENT_ALLOW_TITLE_FALLBACK</xsl:with-param>
			</xsl:call-template>
		</xsl:variable>

		<xsl:apply-templates select="current()" mode="writeTOC">
			<xsl:with-param name="filterHideInNavigation" select="$filterHideInNavigation"/>
			<xsl:with-param name="isRoot" select="$isRoot"/>
			<xsl:with-param name="isChapterWise" select="$isChapterWise"/>
			<xsl:with-param name="listBlocks" select="$listBlocks"/>
			<xsl:with-param name="allowSystemNameFallback" select="$allowSystemNameFallback"/>
			<xsl:with-param name="allowTitleFallback" select="$allowTitleFallback = 'true'"/>
			<xsl:with-param name="levels" select="$levels"/>
		</xsl:apply-templates>
	</xsl:template>

	<xsl:template match="InfoMap | Block" mode="writeTOCTitleText">
		<xsl:param name="number"/>
		<xsl:param name="separator"/>
		<xsl:param name="title"/>
		
		<xsl:if test="@ChangedState">
			<xsl:value-of select="concat('[', @ChangedState, '] ')"/>
		</xsl:if>
		<xsl:choose>
			<xsl:when test="not(@HideInNavigation = 'true') and string-length($number) &gt; 0 and string-length($title) &gt; 0">
				<xsl:value-of select="concat($number, $separator, $title)"/>
			</xsl:when>
			<xsl:otherwise>
				<xsl:value-of select="$title"/>
			</xsl:otherwise>
		</xsl:choose>
	</xsl:template>

	<xsl:template match="Block[string-length(Label) = 0]" mode="writeTOC"/>

	<xsl:template match="InfoMap | Block[string-length(Label) &gt; 0]" mode="writeTOC">
		<xsl:param name="filterHideInNavigation">false</xsl:param>
		<xsl:param name="isRoot" select="true()"/>
		<xsl:param name="isChapterWise"/>
		<xsl:param name="listBlocks" select="false()"/>
		<xsl:param name="allowSystemNameFallback" select="false()"/>
		<xsl:param name="starting-state-hide-from-level" select="20"/>
		<xsl:param name="allowTitleFallback" select="false()"/>
		<xsl:param name="levels" select="10"/>

		<xsl:variable name="level">
			<xsl:apply-templates select="current()" mode="getCurrentLevel"/>
		</xsl:variable>

		<xsl:if test="$level &lt;= $levels">
			<xsl:variable name="useSuffixAfterLastNumber">
				<xsl:call-template name="getTemplateVariableValue">
					<xsl:with-param name="name">HEADLINE_CONTENT_NR_REMOVE_POINT_SUFFIX</xsl:with-param>
					<xsl:with-param name="defaultValue">true</xsl:with-param>
				</xsl:call-template>
			</xsl:variable>

			<xsl:variable name="Number">
				<xsl:apply-templates select="current()" mode="getChapterNr">
					<xsl:with-param name="isTOC" select="true()"/>
					<xsl:with-param name="level" select="$level"/>
					<xsl:with-param name="removePointSuffix" select="$useSuffixAfterLastNumber"/>
				</xsl:apply-templates>
			</xsl:variable>

			<xsl:variable name="ID">
				<xsl:choose>
					<xsl:when test="string-length(@ID) &gt; 0">
						<xsl:value-of select="@ID"/>
					</xsl:when>
					<xsl:otherwise>
						<xsl:value-of select="generate-id()"/>
					</xsl:otherwise>
				</xsl:choose>
			</xsl:variable>

			<xsl:variable name="headline">
				<xsl:choose>
					<xsl:when test="name() = 'Block'">
						<xsl:apply-templates select="Label" mode="printText"/>
					</xsl:when>
					<xsl:when test="$allowSystemNameFallback and string-length(normalize-space(Headline.content)) = 0">
						<xsl:value-of select="@NavigationsBez"/>
					</xsl:when>
					<xsl:otherwise>
						<xsl:apply-templates select="Headline.content" mode="printText"/>
					</xsl:otherwise>
				</xsl:choose>
			</xsl:variable>

			<xsl:variable name="pre_title">
				<xsl:choose>
					<xsl:when test="string-length(normalize-space($headline)) &gt; 0">
						<xsl:value-of select="normalize-space($headline)"/>
					</xsl:when>
					<xsl:when test="$allowTitleFallback">
						<xsl:value-of select="normalize-space(ancestor-or-self::InfoMap[1]/@Title)"/>
					</xsl:when>
					<!--<xsl:otherwise>
					<xsl:value-of select="normalize-space(ancestor-or-self::InfoMap[1]/@Title)"/>
				</xsl:otherwise>-->
				</xsl:choose>
			</xsl:variable>

			<xsl:variable name="separator">
				<xsl:call-template name="getFormat">
					<xsl:with-param name="name" select="concat('headline.content.', $level)"/>
					<xsl:with-param name="attributeName">number-text-separator</xsl:with-param>
					<xsl:with-param name="defaultValue">
						<xsl:text> </xsl:text>
					</xsl:with-param>
				</xsl:call-template>
			</xsl:variable>

			<xsl:variable name="startingState">
				<xsl:call-template name="getTemplateVariableValue">
					<xsl:with-param name="name" select="concat('PDF_TOC_STARTING_STATE_', $level)"/>
					<xsl:with-param name="defaultValue">
						<xsl:call-template name="getTemplateVariableValue">
							<xsl:with-param name="name" select="'PDF_TOC_STARTING_STATE'"/>
							<xsl:with-param name="defaultValue">show</xsl:with-param>
						</xsl:call-template>
					</xsl:with-param>
				</xsl:call-template>
			</xsl:variable>

			<xsl:variable name="title">
				<xsl:apply-templates select="current()" mode="writeTOCTitleText">
					<xsl:with-param name="number" select="$Number"/>
					<xsl:with-param name="title" select="$pre_title"/>
					<xsl:with-param name="separator" select="$separator"/>
				</xsl:apply-templates>
			</xsl:variable>

			<xsl:variable name="linkDestSuffix">
				<xsl:call-template name="getTemplateVariableValue">
					<xsl:with-param name="name">LINK_DESTINATION_SUFFIX</xsl:with-param>
				</xsl:call-template>
			</xsl:variable>

			<xsl:choose>
				<xsl:when test="not($isRoot) and (key('InfoMapKey', $ID) or key('BlockKey', $ID))">
					<xsl:if test="$filterHideInNavigation = 'false' or ($filterHideInNavigation = 'true' and not(@HideInNavigation = 'true'))">
						<xsl:choose>
							<xsl:when test="string-length(normalize-space($title)) &gt; 0">
								<fo:bookmark internal-destination="{$ID}{$linkDestSuffix}" starting-state="{$startingState}">
									<xsl:if test="$starting-state-hide-from-level &gt; 0 and $level &gt;= $starting-state-hide-from-level">
										<xsl:attribute name="starting-state">hide</xsl:attribute>
									</xsl:if>
									<fo:bookmark-title>
										<xsl:value-of select="$title"/>
									</fo:bookmark-title>
									<xsl:apply-templates select="InfoMap | Block[$listBlocks] | include.document/InfoMap" mode="writeTOC">
										<xsl:with-param name="filterHideInNavigation" select="$filterHideInNavigation"/>
										<xsl:with-param name="isRoot" select="false()"/>
										<xsl:with-param name="listBlocks" select="$listBlocks"/>
										<xsl:with-param name="allowSystemNameFallback" select="$allowSystemNameFallback"/>
										<xsl:with-param name="starting-state-hide-from-level" select="$starting-state-hide-from-level"/>
										<xsl:with-param name="allowTitleFallback" select="$allowTitleFallback"/>
										<xsl:with-param name="levels" select="$levels"/>
									</xsl:apply-templates>
								</fo:bookmark>
							</xsl:when>
							<xsl:otherwise>
								<xsl:apply-templates select="InfoMap | Block[$listBlocks] | include.document/InfoMap" mode="writeTOC">
									<xsl:with-param name="filterHideInNavigation" select="$filterHideInNavigation"/>
									<xsl:with-param name="isRoot" select="false()"/>
									<xsl:with-param name="listBlocks" select="$listBlocks"/>
									<xsl:with-param name="allowSystemNameFallback" select="$allowSystemNameFallback"/>
									<xsl:with-param name="starting-state-hide-from-level" select="$starting-state-hide-from-level"/>
									<xsl:with-param name="allowTitleFallback" select="$allowTitleFallback"/>
									<xsl:with-param name="levels" select="$levels"/>
								</xsl:apply-templates>
							</xsl:otherwise>
						</xsl:choose>
					</xsl:if>
				</xsl:when>
				<xsl:when test="(key('InfoMapKey', $ID) or key('BlockKey', $ID))">
					<fo:bookmark-tree>
						<xsl:choose>
							<xsl:when test="$isChapterWise">
								<xsl:choose>
									<xsl:when test="string-length(normalize-space($title)) &gt; 0">
										<fo:bookmark internal-destination="{$ID}{$linkDestSuffix}">
											<xsl:if test="$starting-state-hide-from-level &gt; 0 and $level &gt;= $starting-state-hide-from-level">
												<xsl:attribute name="starting-state">hide</xsl:attribute>
											</xsl:if>
											<fo:bookmark-title>
												<xsl:value-of select="$title"/>
											</fo:bookmark-title>
											<xsl:apply-templates select="InfoMap | Block[$listBlocks] | include.document/InfoMap" mode="writeTOC">
												<xsl:with-param name="filterHideInNavigation" select="$filterHideInNavigation"/>
												<xsl:with-param name="isRoot" select="false()"/>
												<xsl:with-param name="listBlocks" select="$listBlocks"/>
												<xsl:with-param name="allowSystemNameFallback" select="$allowSystemNameFallback"/>
												<xsl:with-param name="starting-state-hide-from-level" select="$starting-state-hide-from-level"/>
												<xsl:with-param name="allowTitleFallback" select="$allowTitleFallback"/>
												<xsl:with-param name="levels" select="$levels"/>
											</xsl:apply-templates>
										</fo:bookmark>
									</xsl:when>
									<xsl:otherwise>
										<xsl:apply-templates select="InfoMap | Block[$listBlocks] | include.document/InfoMap" mode="writeTOC">
											<xsl:with-param name="filterHideInNavigation" select="$filterHideInNavigation"/>
											<xsl:with-param name="isRoot" select="false()"/>
											<xsl:with-param name="listBlocks" select="$listBlocks"/>
											<xsl:with-param name="allowSystemNameFallback" select="$allowSystemNameFallback"/>
											<xsl:with-param name="starting-state-hide-from-level" select="$starting-state-hide-from-level"/>
											<xsl:with-param name="allowTitleFallback" select="$allowTitleFallback"/>
											<xsl:with-param name="levels" select="$levels"/>
										</xsl:apply-templates>
									</xsl:otherwise>
								</xsl:choose>
							</xsl:when>
							<xsl:otherwise>
								<xsl:variable name="regroupPdfTocRoot">
									<xsl:call-template name="getTemplateVariableValue">
										<xsl:with-param name="name">PDF_TOC_REGROUP_ROOT</xsl:with-param>
									</xsl:call-template>
								</xsl:variable>
								<xsl:choose>
									<xsl:when test="key('InfoMapKey', $ID)/block.titlepage and not($regroupPdfTocRoot = 'false')">
										<xsl:if test="string-length(normalize-space($title)) &gt; 0">
											<fo:bookmark internal-destination="{$ID}{$linkDestSuffix}">
												<xsl:if test="$starting-state-hide-from-level &gt; 0 and $level &gt;= $starting-state-hide-from-level">
													<xsl:attribute name="starting-state">hide</xsl:attribute>
												</xsl:if>
												<fo:bookmark-title>
													<xsl:value-of select="$title"/>
												</fo:bookmark-title>
											</fo:bookmark>
										</xsl:if>
										<xsl:apply-templates select="InfoMap | Block[$listBlocks] | include.document/InfoMap" mode="writeTOC">
											<xsl:with-param name="filterHideInNavigation" select="$filterHideInNavigation"/>
											<xsl:with-param name="isRoot" select="false()"/>
											<xsl:with-param name="listBlocks" select="$listBlocks"/>
											<xsl:with-param name="allowSystemNameFallback" select="$allowSystemNameFallback"/>
											<xsl:with-param name="starting-state-hide-from-level" select="$starting-state-hide-from-level"/>
											<xsl:with-param name="allowTitleFallback" select="$allowTitleFallback"/>
											<xsl:with-param name="levels" select="$levels"/>
										</xsl:apply-templates>

									</xsl:when>
									<xsl:when test="string-length(normalize-space($title)) &gt; 0">
										<fo:bookmark internal-destination="{$ID}{$linkDestSuffix}">
											<xsl:if test="$starting-state-hide-from-level &gt; 0 and $level &gt;= $starting-state-hide-from-level">
												<xsl:attribute name="starting-state">hide</xsl:attribute>
											</xsl:if>
											<fo:bookmark-title>
												<xsl:value-of select="$title"/>
											</fo:bookmark-title>
											<xsl:apply-templates select="InfoMap | Block[$listBlocks] | include.document/InfoMap" mode="writeTOC">
												<xsl:with-param name="filterHideInNavigation" select="$filterHideInNavigation"/>
												<xsl:with-param name="isRoot" select="false()"/>
												<xsl:with-param name="listBlocks" select="$listBlocks"/>
												<xsl:with-param name="allowSystemNameFallback" select="$allowSystemNameFallback"/>
												<xsl:with-param name="starting-state-hide-from-level" select="$starting-state-hide-from-level"/>
												<xsl:with-param name="allowTitleFallback" select="$allowTitleFallback"/>
												<xsl:with-param name="levels" select="$levels"/>
											</xsl:apply-templates>
										</fo:bookmark>
									</xsl:when>
									<xsl:otherwise>
										<xsl:apply-templates select="InfoMap | Block[$listBlocks] | include.document/InfoMap" mode="writeTOC">
											<xsl:with-param name="filterHideInNavigation" select="$filterHideInNavigation"/>
											<xsl:with-param name="isRoot" select="false()"/>
											<xsl:with-param name="listBlocks" select="$listBlocks"/>
											<xsl:with-param name="allowSystemNameFallback" select="$allowSystemNameFallback"/>
											<xsl:with-param name="starting-state-hide-from-level" select="$starting-state-hide-from-level"/>
											<xsl:with-param name="allowTitleFallback" select="$allowTitleFallback"/>
											<xsl:with-param name="levels" select="$levels"/>
										</xsl:apply-templates>
									</xsl:otherwise>
								</xsl:choose>
							</xsl:otherwise>
						</xsl:choose>
					</fo:bookmark-tree>
				</xsl:when>
			</xsl:choose>
		</xsl:if>

	</xsl:template>
	
</xsl:stylesheet>
