<?xml version="1.0" encoding="utf-8"?>
<xsl:stylesheet version="1.0"
				xmlns:fo="http://www.w3.org/1999/XSL/Format"
				xmlns:xsl="http://www.w3.org/1999/XSL/Transform">

	<xsl:template match="generate"/>
	
	<xsl:template match="generate.listing.nr">
		<xsl:variable name="type">
			<xsl:choose>
				<xsl:when test="@type = 'Image'">IMAGE</xsl:when>
				<xsl:otherwise>TABLE</xsl:otherwise>
			</xsl:choose>
		</xsl:variable>
		<xsl:variable name="displayType">
			<xsl:call-template name="getTemplateVariableValue">
				<xsl:with-param name="name" select="concat('GENERATE_', $type, '_LISTING_NR_DISPLAY_TYPE')"/>
				<xsl:with-param name="defaultValue">nr</xsl:with-param>
			</xsl:call-template>
		</xsl:variable>
		<xsl:choose>
			<xsl:when test="$displayType = 'nr-only'">
				<xsl:apply-templates select="current()" mode="NrOnly">
					<xsl:with-param name="type" select="$type"/>
				</xsl:apply-templates>
			</xsl:when>
			<xsl:when test="$displayType = 'nr-with-chapter'">
				<xsl:apply-templates select="current()" mode="NrWithChapter">
					<xsl:with-param name="type" select="$type"/>
				</xsl:apply-templates>
			</xsl:when>
			<xsl:otherwise>
				<xsl:apply-templates select="current()" mode="Nr">
					<xsl:with-param name="type" select="$type"/>
				</xsl:apply-templates>
			</xsl:otherwise>
		</xsl:choose>
	</xsl:template>

	<xsl:template match="generate.listing.nr" mode="Nr">
		<xsl:param name="translateSuffix">.Abbreviation</xsl:param>
		<xsl:param name="type"/>

		<xsl:call-template name="translate">
			<xsl:with-param name="ID">
				<xsl:call-template name="getTemplateVariableValue">
					<xsl:with-param name="name" select="concat('GENERATE_', $type, '_LISTING_NR_STRING_ID')"/>
					<xsl:with-param name="defaultValue" select="concat(@type, $translateSuffix)"/>
				</xsl:call-template>
			</xsl:with-param>
		</xsl:call-template>
		<xsl:text> </xsl:text>
		<xsl:apply-templates select="current()" mode="NrOnly"/>
	</xsl:template>

	<xsl:template match="generate.listing.nr" mode="NrOnly">

		<xsl:value-of select="@nr"/>

		<xsl:call-template name="getTemplateVariableValue">
			<xsl:with-param name="name">
				<xsl:text>GENERATE_</xsl:text>
				<xsl:choose>
					<xsl:when test="@type = 'Image'">IMAGE</xsl:when>
					<xsl:otherwise>TABLE</xsl:otherwise>
				</xsl:choose>
				<xsl:text>_LISTING_NR_SUFFIX</xsl:text>
			</xsl:with-param>
			<xsl:with-param name="defaultValue">
				<xsl:choose>
					<xsl:when test="$language = 'fr'"> :</xsl:when>
					<xsl:otherwise>:</xsl:otherwise>
				</xsl:choose>
			</xsl:with-param>
		</xsl:call-template>
	</xsl:template>

	<xsl:template match="generate.listing.nr" mode="NrWithChapter">
		<xsl:param name="translateSuffix">.Abbreviation</xsl:param>

		<xsl:apply-templates select="current()" mode="getLinkBaseTextWithChapter">
			<xsl:with-param name="printTitle" select="false()"/>
			<xsl:with-param name="translateSuffix" select="$translateSuffix"/>
		</xsl:apply-templates>
		
		<xsl:choose>
			<xsl:when test="$language = 'fr'"> :</xsl:when>
			<xsl:otherwise>:</xsl:otherwise>
		</xsl:choose>

	</xsl:template>

	<xsl:template match="InfoItem.Overviewall" mode="getDefaultDisplayType">simple</xsl:template>

	<xsl:template match="InfoItem.Overviewall">
		<xsl:variable name="displayType">
			<xsl:call-template name="getTemplateVariableValue">
				<xsl:with-param name="name">GENERATE_CONTENT_DISPLAY_TYPE</xsl:with-param>
				<xsl:with-param name="defaultValue">
					<xsl:apply-templates select="current()" mode="getDefaultDisplayType"/>
				</xsl:with-param>
			</xsl:call-template>
		</xsl:variable>
		<xsl:variable name="pageNumberColumn">
			<xsl:call-template name="getTemplateVariableValue">
				<xsl:with-param name="name" select="'GENERATE_CONTENT_PAGE_NUMBER_COLUMN'"/>
				<xsl:with-param name="defaultValue">false</xsl:with-param>
			</xsl:call-template>
		</xsl:variable>
		<xsl:variable name="pageNumberColumnOnLeft">
			<xsl:call-template name="getTemplateVariableValue">
				<xsl:with-param name="name">GENERATE_CONTENT_PAGE_NUMBER_COLUMN_ON_LEFT</xsl:with-param>
				<xsl:with-param name="defaultValue">false</xsl:with-param>
			</xsl:call-template>
		</xsl:variable>
		<xsl:choose>
			<xsl:when test="$displayType = 'table'">
				<xsl:variable name="showHeader">
					<xsl:call-template name="getTemplateVariableValue">
						<xsl:with-param name="name" select="'GENERATE_CONTENT_SHOW_HEADER'"/>
						<xsl:with-param name="defaultValue">false</xsl:with-param>
					</xsl:call-template>
				</xsl:variable>
				<xsl:variable name="showChapterColumnTitle">
					<xsl:call-template name="getTemplateVariableValue">
						<xsl:with-param name="name" select="'GENERATE_CONTENT_SHOW_CHAPTER_COLUMN_TITLE'"/>
						<xsl:with-param name="defaultValue">true</xsl:with-param>
					</xsl:call-template>
				</xsl:variable>
				<xsl:apply-templates select="current()" mode="table">
					<xsl:with-param name="dontShowHeader" select="not($showHeader = 'true')"/>
					<xsl:with-param name="usePageNumberColumn" select="$pageNumberColumn = 'true' or $isRightToLeftLanguage"/>
					<xsl:with-param name="showChapterColumnTitle" select="not($showChapterColumnTitle = 'false')"/>
				</xsl:apply-templates>
			</xsl:when>
			<xsl:when test="$displayType = 'multi-table'">
				<xsl:apply-templates select="current()" mode="multi-table">
					<xsl:with-param name="usePageNumberColumn" select="$pageNumberColumn = 'true' or $isRightToLeftLanguage"/>
					<xsl:with-param name="pageNumberColumnOnLeft" select="$pageNumberColumnOnLeft = 'true'"/>
				</xsl:apply-templates>
			</xsl:when>
			<xsl:when test="$displayType = 'table-hierarchical'">
				<xsl:apply-templates select="current()" mode="table-hierarchical">
					<xsl:with-param name="usePageNumberColumn" select="$pageNumberColumn = 'true' or $isRightToLeftLanguage"/>
				</xsl:apply-templates>
			</xsl:when>
			<xsl:otherwise>
				<xsl:apply-templates select="current()" mode="list"/>
			</xsl:otherwise>
		</xsl:choose>
	</xsl:template>

	<xsl:template match="InfoItem.Overview" mode="printTargetPageTitle">
		<xsl:apply-templates select="Link.ShortDesc/InfoChunk.Link"/>
	</xsl:template>

	<xsl:template match="InfoItem.Overviewall" mode="list">
		<xsl:param name="filterHideInNavigation" select="true()"/>
		<xsl:param name="listBlocks" select="true()"/>
		<xsl:param name="leaderType">
			<xsl:call-template name="getTemplateVariableValue">
				<xsl:with-param name="name">GENERATE_CONTENT_LEADER_TYPE</xsl:with-param>
				<xsl:with-param name="defaultValue">dots</xsl:with-param>
			</xsl:call-template>
		</xsl:param>

		<xsl:for-each select=".//InfoItem.Overview[not(@HideInNavigation = 'true' and $filterHideInNavigation) and ($listBlocks or not(@isBlock))]">

			<xsl:variable name="currentChapterNr">
				<xsl:choose>
					<xsl:when test="$isChapterWise">
						<xsl:apply-templates select="current()" mode="getLinkChapterNr">
							<xsl:with-param name="RefID" select="ancestor::InfoMap[1]/@ID"/>
						</xsl:apply-templates>
					</xsl:when>
					<xsl:otherwise>1</xsl:otherwise>
				</xsl:choose>
			</xsl:variable>

			<xsl:variable name="linkChapterNr">
				<xsl:choose>
					<xsl:when test="$isChapterWise">
						<xsl:apply-templates select="current()" mode="getLinkChapterNr">
							<xsl:with-param name="RefID" select="Link.ShortDesc/@IDRef"/>
						</xsl:apply-templates>
					</xsl:when>
					<xsl:otherwise>1</xsl:otherwise>
				</xsl:choose>
			</xsl:variable>

			<xsl:variable name="isSameChapter">
				<xsl:choose>
					<xsl:when test="$isChapterWise">
						<xsl:value-of select="$currentChapterNr = $linkChapterNr"/>
					</xsl:when>
					<xsl:otherwise>
						<xsl:value-of select="true()"/>
					</xsl:otherwise>
				</xsl:choose>
			</xsl:variable>

			<xsl:variable name="linkTargetType">
				<xsl:choose>
					<xsl:when test="@isBlock">
						<xsl:value-of select="key('BlockKey',Link.ShortDesc/@IDRef)[1]/@Typ"/>
					</xsl:when>
					<xsl:otherwise>
						<xsl:value-of select="key('InfoMapKey',Link.ShortDesc/@IDRef)[1]/@Typ"/>
					</xsl:otherwise>
				</xsl:choose>
			</xsl:variable>

			<xsl:variable name="currentElement" select="key('InfoMapKey',Link.ShortDesc/@IDRef)[1]"/>

			<fo:table table-layout="fixed" width="100%">
				<xsl:choose>
					<xsl:when test="@HideInNavigation = 'true'">
						<xsl:call-template name="addStyle">
							<xsl:with-param name="name">toc_hideinnavigation</xsl:with-param>
						</xsl:call-template>
						<xsl:if test="$currentElement">
							<xsl:call-template name="addStyle">
								<xsl:with-param name="name">toc_hideinnavigation</xsl:with-param>
								<xsl:with-param name="currentElement" select="$currentElement"/>
							</xsl:call-template>
						</xsl:if>
					</xsl:when>
					<xsl:otherwise>
						<xsl:call-template name="addStyle">
							<xsl:with-param name="name" select="concat('toc_', @abs_level)"/>
						</xsl:call-template>
						<xsl:if test="position() = 1">
							<xsl:call-template name="addStyle">
								<xsl:with-param name="name" select="concat('toc_', @abs_level, '.first')"/>
							</xsl:call-template>
						</xsl:if>
						<xsl:if test="$currentElement">
							<xsl:call-template name="addStyle">
								<xsl:with-param name="name" select="concat('toc_', @abs_level)"/>
								<xsl:with-param name="currentElement" select="$currentElement"/>
							</xsl:call-template>
						</xsl:if>
						<xsl:variable name="startIndent">
							<xsl:call-template name="getFormat">
								<xsl:with-param name="name" select="concat('toc_', @abs_level)"/>
								<xsl:with-param name="attributeName">start-indent</xsl:with-param>
							</xsl:call-template>
						</xsl:variable>
						<xsl:if test="string-length($startIndent) &gt; 0">
							<xsl:attribute name="width">
								<xsl:value-of select="concat('100%-', $startIndent)"/>
							</xsl:attribute>
						</xsl:if>
					</xsl:otherwise>
				</xsl:choose>
				<xsl:if test="string-length($linkTargetType) &gt; 0">
					<xsl:call-template name="addStyle">
						<xsl:with-param name="name" select="concat('toc_', $linkTargetType)"/>
					</xsl:call-template>
					<xsl:call-template name="addStyle">
						<xsl:with-param name="name" select="concat('toc_', $linkTargetType)"/>
						<xsl:with-param name="currentElement" select="$currentElement"/>
					</xsl:call-template>
					<xsl:call-template name="addStyle">
						<xsl:with-param name="name" select="concat('toc_', $linkTargetType, '_', @abs_level)"/>
					</xsl:call-template>
					<xsl:call-template name="addStyle">
						<xsl:with-param name="name" select="concat('toc_', $linkTargetType, '_', @abs_level)"/>
						<xsl:with-param name="currentElement" select="$currentElement"/>
					</xsl:call-template>
				</xsl:if>

				<xsl:variable name="showPageNr" select="not(string-length(Link.ShortDesc/@IDRef) = 0 or ($isChapterWise and not($isSameChapter)))"/>

				<fo:table-column column-width="proportional-column-width(1)"/>
				<fo:table-body start-indent="0">
					<fo:table-row>
						<fo:table-cell>
							<fo:block>
								<xsl:if test="$showPageNr">
									<xsl:attribute name="text-align-last">justify</xsl:attribute>
								</xsl:if>
								<xsl:choose>
									<xsl:when test="@isBlock">
										<xsl:apply-templates select="(key('BlockKey',Link.ShortDesc/@IDRef))[1]/*[1]" mode="getContentsChapterNr"/>
									</xsl:when>
									<xsl:otherwise>
										<xsl:apply-templates select="(key('InfoMapKey',Link.ShortDesc/@IDRef))[1]" mode="getContentsChapterNr"/>
									</xsl:otherwise>
								</xsl:choose>
								
								<xsl:call-template name="getTemplateVariableValue">
									<xsl:with-param name="name" select="concat('GENERATE_CONTENT_NR_TEXT_SEPARATOR_', @abs_level)"/>
									<xsl:with-param name="defaultValue">
										<xsl:call-template name="getFormat">
											<xsl:with-param name="name" select="concat('headline.content.', @abs_level + 1)"/>
											<xsl:with-param name="attributeName">number-text-separator</xsl:with-param>
											<xsl:with-param name="currentElement" select="$currentElement/Headline.content"/>
											<xsl:with-param name="defaultValue">
												<xsl:text> </xsl:text>
											</xsl:with-param>
										</xsl:call-template>
									</xsl:with-param>
								</xsl:call-template>

								<xsl:choose>
									<xsl:when test="string-length(Link.ShortDesc/@IDRef) = 0 or $isPDFXMODE">
										<xsl:apply-templates select="current()" mode="printTargetPageTitle"/>
									</xsl:when>
									<xsl:when test="$isChapterWise and not($isSameChapter)">
										<fo:basic-link external-destination="./{$linkChapterNr}.pdf#dest={Link.ShortDesc/@IDRef}" show-destination="new">
											<xsl:apply-templates select="current()" mode="printTargetPageTitle"/>
										</fo:basic-link>
									</xsl:when>
									<xsl:otherwise>
										<fo:basic-link internal-destination="{Link.ShortDesc/@IDRef}">
											<xsl:apply-templates select="current()" mode="printTargetPageTitle"/>
										</fo:basic-link>
									</xsl:otherwise>
								</xsl:choose>

								<xsl:if test="$showPageNr">
									<fo:leader leader-pattern="{$leaderType}"/>
									<xsl:apply-templates select="current()" mode="writePageReferenceNumber">
										<xsl:with-param name="RefID" select="Link.ShortDesc/@IDRef"/>
									</xsl:apply-templates>
								</xsl:if>
							</fo:block>
						</fo:table-cell>
					</fo:table-row>
				</fo:table-body>
			</fo:table>

		</xsl:for-each>

	</xsl:template>

	<xsl:template match="InfoItem.Overviewall" mode="table">
		<xsl:param name="dontShowHeader" select="false()"/>
		<xsl:param name="showPageNumbers" select="true()"/>
		<xsl:param name="leaderType">
			<xsl:call-template name="getTemplateVariableValue">
				<xsl:with-param name="name">GENERATE_CONTENT_LEADER_TYPE</xsl:with-param>
				<xsl:with-param name="defaultValue">dots</xsl:with-param>
			</xsl:call-template>
		</xsl:param>
		<xsl:param name="leaderPatternWidth">use-font-metrics</xsl:param>
		<xsl:param name="filterHideInNavigation" select="true()"/>
		<xsl:param name="listBlocks" select="true()"/>
		<xsl:param name="usePageNumberColumn" select="false()"/>
		<xsl:param name="showChapterColumnTitle" select="true()"/>

		<xsl:variable name="hasType" select="@type and @type != 'Contents'"/>

		<xsl:variable name="repeatTableHeader">
			<xsl:call-template name="getTemplateVariableValue">
				<xsl:with-param name="name">GENERATE_CONTENT_REPEAT_HEADER</xsl:with-param>
				<xsl:with-param name="defaultValue">true</xsl:with-param>
			</xsl:call-template>
		</xsl:variable>

		<fo:table width="100%" table-layout="fixed">
			<xsl:call-template name="addStyle">
				<xsl:with-param name="name">toc</xsl:with-param>
			</xsl:call-template>
			<xsl:if test="$hasType">
				<xsl:call-template name="addStyle">
					<xsl:with-param name="name" select="concat('toc', '.', @type)"/>
				</xsl:call-template>
			</xsl:if>
			<xsl:if test="$repeatTableHeader = 'false'">
				<xsl:attribute name="table-omit-header-at-break">true</xsl:attribute>
			</xsl:if>
			<fo:table-column>
				<xsl:attribute name="column-width">
					<xsl:call-template name="getTemplateVariableValue">
						<xsl:with-param name="name" select="'TOC_COL1'"/>
						<xsl:with-param name="defaultValue">6mm</xsl:with-param>
					</xsl:call-template>
				</xsl:attribute>
			</fo:table-column>
			<fo:table-column column-width="proportional-column-width(1)"/>
			<fo:table-column>
				<xsl:attribute name="column-width">
					<xsl:call-template name="getTemplateVariableValue">
						<xsl:with-param name="name" select="'TOC_COL3'"/>
						<xsl:with-param name="defaultValue">
							<xsl:choose>
								<xsl:when test="$isRightToLeftLanguage">12mm</xsl:when>
								<xsl:otherwise>6mm</xsl:otherwise>
							</xsl:choose>
						</xsl:with-param>
					</xsl:call-template>
				</xsl:attribute>
			</fo:table-column>
			<xsl:if test="not($dontShowHeader)">
				<fo:table-header start-indent="0">
					<fo:table-row>
						<xsl:if test="$showChapterColumnTitle">
							<fo:table-cell number-columns-spanned="2">
								<xsl:call-template name="addStyle">
									<xsl:with-param name="name">toc.title.cell.1</xsl:with-param>
								</xsl:call-template>
								<fo:block>
									<xsl:call-template name="addStyle">
										<xsl:with-param name="name">toc.title</xsl:with-param>
									</xsl:call-template>
									<xsl:call-template name="translate">
										<xsl:with-param name="ID">TOC</xsl:with-param>
									</xsl:call-template>
								</fo:block>
							</fo:table-cell>
						</xsl:if>
						<fo:table-cell>
							<xsl:if test="not($isRightToLeftLanguage)">
								<xsl:attribute name="text-align">right</xsl:attribute>
							</xsl:if>
							<xsl:call-template name="addStyle">
								<xsl:with-param name="name">toc.title.cell.2</xsl:with-param>
							</xsl:call-template>
							<xsl:if test="not($showChapterColumnTitle)">
								<xsl:attribute name="number-columns-spanned">3</xsl:attribute>
							</xsl:if>
							<fo:block hyphenate="false" keep-together="always">
								<xsl:call-template name="addStyle">
									<xsl:with-param name="name">toc.title</xsl:with-param>
								</xsl:call-template>
								<xsl:call-template name="translate">
									<xsl:with-param name="ID">Page2</xsl:with-param>
								</xsl:call-template>
							</fo:block>
						</fo:table-cell>
					</fo:table-row>
				</fo:table-header>
			</xsl:if>
			<fo:table-body start-indent="0">
				<xsl:for-each select=".//InfoItem.Overview[not(@HideInNavigation = 'true' and $filterHideInNavigation) and ($listBlocks or not(@isBlock))]">

					<xsl:variable name="currentChapterNr">
						<xsl:choose>
							<xsl:when test="$isChapterWise">
								<xsl:apply-templates select="current()" mode="getLinkChapterNr">
									<xsl:with-param name="RefID" select="ancestor::InfoMap[1]/@ID"/>
								</xsl:apply-templates>
							</xsl:when>
							<xsl:otherwise>1</xsl:otherwise>
						</xsl:choose>
					</xsl:variable>

					<xsl:variable name="linkChapterNr">
						<xsl:choose>
							<xsl:when test="$isChapterWise">
								<xsl:apply-templates select="current()" mode="getLinkChapterNr">
									<xsl:with-param name="RefID" select="Link.ShortDesc/@IDRef"/>
								</xsl:apply-templates>
							</xsl:when>
							<xsl:otherwise>1</xsl:otherwise>
						</xsl:choose>
					</xsl:variable>

					<xsl:variable name="isSameChapter" select="($isChapterWise and ($currentChapterNr = $linkChapterNr)) or not($isChapterWise)"/>
					<xsl:variable name="showPageNr" select="$showPageNumbers and not(string-length(Link.ShortDesc/@IDRef) = 0 or ($isChapterWise and not($isSameChapter)))"/>
					
					<fo:table-row start-indent="0">
						<fo:table-cell>
							<fo:block>
								<xsl:call-template name="addStyle">
									<xsl:with-param name="name" select="concat('toc_', @abs_level)"/>
								</xsl:call-template>
								<xsl:if test="position() = 1">
									<xsl:call-template name="addStyle">
										<xsl:with-param name="name" select="concat('toc_', @abs_level, '.first')"/>
									</xsl:call-template>
								</xsl:if>
								<xsl:if test="$hasType">
									<xsl:call-template name="addStyle">
										<xsl:with-param name="name" select="concat('toc_', @abs_level, '.', ../@type)"/>
									</xsl:call-template>
								</xsl:if>
								<xsl:call-template name="addStyle">
									<xsl:with-param name="name" select="concat('toc_', @abs_level, '.nr')"/>
								</xsl:call-template>
								<xsl:if test="position() = last()">
									<xsl:call-template name="addStyle">
										<xsl:with-param name="name">toc.item.last</xsl:with-param>
									</xsl:call-template>
								</xsl:if>
								<xsl:choose>
									<xsl:when test="@isBlock">
										<xsl:apply-templates select="(key('BlockKey',Link.ShortDesc/@IDRef))[1]/*[1]" mode="getContentsChapterNr"/>
									</xsl:when>
									<xsl:otherwise>
										<xsl:apply-templates select="(key('InfoMapKey',Link.ShortDesc/@IDRef))[1]" mode="getContentsChapterNr"/>
									</xsl:otherwise>
								</xsl:choose>
							</fo:block>
						</fo:table-cell>
						<fo:table-cell>
							<xsl:if test="not($usePageNumberColumn)">
								<xsl:attribute name="number-columns-spanned">2</xsl:attribute>
							</xsl:if>
							<fo:block>
								<xsl:call-template name="addStyle">
									<xsl:with-param name="name" select="concat('toc_', @abs_level)"/>
								</xsl:call-template>
								<xsl:if test="position() = 1">
									<xsl:call-template name="addStyle">
										<xsl:with-param name="name" select="concat('toc_', @abs_level, '.first')"/>
									</xsl:call-template>
								</xsl:if>
								<xsl:if test="$hasType">
									<xsl:call-template name="addStyle">
										<xsl:with-param name="name" select="concat('toc_', @abs_level, '.', ../@type)"/>
									</xsl:call-template>
								</xsl:if>
								<xsl:call-template name="addStyle">
									<xsl:with-param name="name" select="concat('toc_', @abs_level, '.text')"/>
								</xsl:call-template>
								<xsl:if test="$showPageNr">
									<xsl:attribute name="text-align-last">justify</xsl:attribute>
								</xsl:if>
								<xsl:choose>
									<xsl:when test="string-length(Link.ShortDesc/@IDRef) = 0 or $isPDFXMODE">
										<xsl:apply-templates select="current()" mode="printTargetPageTitle"/>
									</xsl:when>
									<xsl:when test="$isChapterWise and not($isSameChapter)">
										<fo:basic-link external-destination="./{$linkChapterNr}.pdf#dest={Link.ShortDesc/@IDRef}" show-destination="new">
											<xsl:apply-templates select="current()" mode="printTargetPageTitle"/>
										</fo:basic-link>
									</xsl:when>
									<xsl:otherwise>
										<fo:basic-link internal-destination="{Link.ShortDesc/@IDRef}">
											<xsl:apply-templates select="current()" mode="printTargetPageTitle"/>
										</fo:basic-link>
									</xsl:otherwise>
								</xsl:choose>

								<xsl:if test="$showPageNr">
									<fo:leader leader-pattern="{$leaderType}" leader-pattern-width="{$leaderPatternWidth}">
										<xsl:if test="$leaderPatternWidth != 'use-font-metrics' and string(number(substring($leaderPatternWidth, 1, 1))) != 'NaN'">
											<xsl:attribute name="padding-left">
												<xsl:value-of select="$leaderPatternWidth"/>
											</xsl:attribute>
										</xsl:if>
									</fo:leader>
									<xsl:if test="not($usePageNumberColumn)">
										<xsl:apply-templates select="current()" mode="writePageReferenceNumber">
											<xsl:with-param name="RefID" select="Link.ShortDesc/@IDRef"/>
										</xsl:apply-templates>
									</xsl:if>
								</xsl:if>
							</fo:block>
						</fo:table-cell>
						<xsl:if test="$usePageNumberColumn">
							<fo:table-cell display-align="after">
								<fo:block>
									<xsl:if test="not($isRightToLeftLanguage)">
										<xsl:attribute name="text-align">right</xsl:attribute>
									</xsl:if>
									<xsl:call-template name="addStyle">
										<xsl:with-param name="name" select="concat('toc_', @abs_level)"/>
									</xsl:call-template>
									<xsl:if test="position() = 1">
										<xsl:call-template name="addStyle">
											<xsl:with-param name="name" select="concat('toc_', @abs_level, '.first')"/>
										</xsl:call-template>
									</xsl:if>
									<xsl:if test="$hasType">
										<xsl:call-template name="addStyle">
											<xsl:with-param name="name" select="concat('toc_', @abs_level, '.', ../@type)"/>
										</xsl:call-template>
									</xsl:if>
									<xsl:call-template name="addStyle">
										<xsl:with-param name="name" select="concat('toc_', @abs_level, '.page')"/>
									</xsl:call-template>
									<xsl:if test="$showPageNr">
										<xsl:apply-templates select="current()" mode="writePageReferenceNumber">
											<xsl:with-param name="RefID" select="Link.ShortDesc/@IDRef"/>
										</xsl:apply-templates>
									</xsl:if>
								</fo:block>
							</fo:table-cell>
						</xsl:if>
					</fo:table-row>
				</xsl:for-each>

				<xsl:if test="not(.//InfoItem.Overview[not(@HideInNavigation = 'true' and $filterHideInNavigation) and ($listBlocks or not(@isBlock))])">
					<fo:table-row>
						<fo:table-cell>
							<fo:block/>
						</fo:table-cell>
						<fo:table-cell>
							<fo:block/>
						</fo:table-cell>
						<fo:table-cell>
							<fo:block/>
						</fo:table-cell>
					</fo:table-row>
				</xsl:if>

			</fo:table-body>
		</fo:table>

	</xsl:template>

	<xsl:template match="InfoItem.Overviewall" mode="multi-table">
		<xsl:param name="showPageNumbers" select="true()"/>
		<xsl:param name="leaderType">
			<xsl:call-template name="getTemplateVariableValue">
				<xsl:with-param name="name">GENERATE_CONTENT_LEADER_TYPE</xsl:with-param>
				<xsl:with-param name="defaultValue">dots</xsl:with-param>
			</xsl:call-template>
		</xsl:param>
		<xsl:param name="filterHideInNavigation" select="true()"/>
		<xsl:param name="listBlocks" select="true()"/>
		<xsl:param name="usePageNumberColumn" select="false()"/>
		<xsl:param name="showBlockAbstractContent" select="false()"/>
		<xsl:param name="pageNumberColumnOnLeft" select="false()"/>

		<xsl:variable name="hasType" select="@type and @type != 'Contents'"/>

		<xsl:variable name="colDefaultWidth">
			<xsl:call-template name="getTemplateVariableValue">
				<xsl:with-param name="name" select="'TOC_COL'"/>
				<xsl:with-param name="defaultValue">6mm</xsl:with-param>
			</xsl:call-template>
		</xsl:variable>

		<xsl:variable name="useSuffixAfterLastNumber">
			<xsl:call-template name="getTemplateVariableValue">
				<xsl:with-param name="name">HEADLINE_CONTENT_NR_REMOVE_POINT_SUFFIX</xsl:with-param>
				<xsl:with-param name="defaultValue">true</xsl:with-param>
			</xsl:call-template>
		</xsl:variable>

		<fo:block>
			<xsl:call-template name="addStyle">
				<xsl:with-param name="name">toc</xsl:with-param>
			</xsl:call-template>
			<xsl:if test="$hasType">
				<xsl:call-template name="addStyle">
					<xsl:with-param name="name" select="concat('toc', '.', @type)"/>
				</xsl:call-template>
			</xsl:if>
			<xsl:for-each select=".//InfoItem.Overview[not(@HideInNavigation = 'true' and $filterHideInNavigation) and ($listBlocks or not(@isBlock))]">
				<xsl:variable name="currentElement" select="key('InfoMapKey',Link.ShortDesc/@IDRef)[1]"/>
				<xsl:variable name="currentChapterNr">
					<xsl:choose>
						<xsl:when test="$isChapterWise">
							<xsl:apply-templates select="current()" mode="getLinkChapterNr">
								<xsl:with-param name="RefID" select="ancestor::InfoMap[1]/@ID"/>
							</xsl:apply-templates>
						</xsl:when>
						<xsl:otherwise>1</xsl:otherwise>
					</xsl:choose>
				</xsl:variable>

				<xsl:variable name="linkChapterNr">
					<xsl:choose>
						<xsl:when test="$isChapterWise">
							<xsl:apply-templates select="current()" mode="getLinkChapterNr">
								<xsl:with-param name="RefID" select="Link.ShortDesc/@IDRef"/>
							</xsl:apply-templates>
						</xsl:when>
						<xsl:otherwise>1</xsl:otherwise>
					</xsl:choose>
				</xsl:variable>

				<xsl:variable name="isSameChapter" select="($isChapterWise and $currentChapterNr = $linkChapterNr) or not($isChapterWise)"/>

				<xsl:variable name="linkTargetType">
					<xsl:choose>
						<xsl:when test="@isBlock">
							<xsl:value-of select="key('BlockKey',Link.ShortDesc/@IDRef)[1]/@Typ"/>
						</xsl:when>
						<xsl:otherwise>
							<xsl:value-of select="key('InfoMapKey',Link.ShortDesc/@IDRef)[1]/@Typ"/>
						</xsl:otherwise>
					</xsl:choose>
				</xsl:variable>

				<fo:table table-layout="fixed" width="100%">
					<xsl:choose>
						<xsl:when test="@HideInNavigation = 'true'">
							<xsl:call-template name="addStyle">
								<xsl:with-param name="name">toc_hideinnavigation</xsl:with-param>
							</xsl:call-template>
						</xsl:when>
						<xsl:otherwise>
							<xsl:call-template name="addStyle">
								<xsl:with-param name="name" select="concat('toc_', @abs_level)"/>
								<xsl:with-param name="altCurrentElement" select="$currentElement"/>
							</xsl:call-template>
							<xsl:if test="position() = 1">
								<xsl:call-template name="addStyle">
									<xsl:with-param name="name" select="concat('toc_', @abs_level, '.first')"/>
									<xsl:with-param name="altCurrentElement" select="$currentElement"/>
								</xsl:call-template>
							</xsl:if>
							<xsl:variable name="startIndent">
								<xsl:call-template name="getFormat">
									<xsl:with-param name="name" select="concat('toc_', @abs_level)"/>
									<xsl:with-param name="attributeName">start-indent</xsl:with-param>
								</xsl:call-template>
							</xsl:variable>
							<xsl:if test="string-length($startIndent) &gt; 0">
								<xsl:attribute name="width">
									<xsl:value-of select="concat('100%-', $startIndent)"/>
								</xsl:attribute>
							</xsl:if>
						</xsl:otherwise>
					</xsl:choose>
					<xsl:if test="string-length($linkTargetType) &gt; 0">
						<xsl:call-template name="addStyle">
							<xsl:with-param name="name" select="concat('toc_', $linkTargetType)"/>
						</xsl:call-template>
					</xsl:if>

					<xsl:variable name="showPageNr" select="not(string-length(Link.ShortDesc/@IDRef) = 0 or ($isChapterWise and not($isSameChapter)))"/>
					<fo:table-column>
						<xsl:attribute name="column-width">
							<xsl:call-template name="getTemplateVariableValue">
								<xsl:with-param name="name" select="concat('TOC_COL_', @abs_level)"/>
								<xsl:with-param name="defaultValue" select="$colDefaultWidth"/>
							</xsl:call-template>
						</xsl:attribute>
					</fo:table-column>
					<fo:table-column>
						<xsl:attribute name="column-width">
							<xsl:call-template name="getTemplateVariableValue">
								<xsl:with-param name="name">TOC_COL2</xsl:with-param>
								<xsl:with-param name="defaultValue">proportional-column-width(1)</xsl:with-param>
							</xsl:call-template>
						</xsl:attribute>
					</fo:table-column>
					<fo:table-column>
						<xsl:attribute name="column-width">
							<xsl:call-template name="getTemplateVariableValue">
								<xsl:with-param name="name" select="'TOC_COL3'"/>
								<xsl:with-param name="defaultValue">6mm</xsl:with-param>
							</xsl:call-template>
						</xsl:attribute>
					</fo:table-column>
					<fo:table-body start-indent="0">
						<fo:table-row>
							<xsl:if test="$pageNumberColumnOnLeft and $usePageNumberColumn and $showPageNr">
								<xsl:apply-templates select="current()" mode="writePageNumberColumnn"/>
							</xsl:if>
							<fo:table-cell>
								<xsl:call-template name="addStyle">
									<xsl:with-param name="name" select="concat('toc_', @abs_level, '.nr.cell')"/>
								</xsl:call-template>							
								<fo:block>
									<xsl:call-template name="addStyle">
										<xsl:with-param name="name" select="concat('toc_', @abs_level, '.nr')"/>
									</xsl:call-template>							
									<xsl:choose>
										<xsl:when test="@isBlock">
											<xsl:apply-templates select="(key('BlockKey',Link.ShortDesc/@IDRef))[1]/*[1]" mode="getContentsChapterNr">
												<xsl:with-param name="removePointSuffix" select="$useSuffixAfterLastNumber"/>
											</xsl:apply-templates>
										</xsl:when>
										<xsl:otherwise>
											<xsl:apply-templates select="(key('InfoMapKey',Link.ShortDesc/@IDRef))[1]" mode="getContentsChapterNr">
												<xsl:with-param name="removePointSuffix" select="$useSuffixAfterLastNumber"/>
											</xsl:apply-templates>
										</xsl:otherwise>
									</xsl:choose>
								</fo:block>
							</fo:table-cell>
							<fo:table-cell>
								<xsl:call-template name="addStyle">
									<xsl:with-param name="name" select="concat('toc_', @abs_level, '.text')"/>
								</xsl:call-template>
								<xsl:if test="not($usePageNumberColumn)">
									<xsl:attribute name="number-columns-spanned">2</xsl:attribute>
								</xsl:if>
								<fo:block>
									<xsl:if test="$showPageNr and not($leaderType = 'none')">
										<xsl:attribute name="text-align-last">justify</xsl:attribute>
									</xsl:if>
									<xsl:choose>
										<xsl:when test="string-length(Link.ShortDesc/@IDRef) = 0 or $isPDFXMODE">
											<xsl:apply-templates select="current()" mode="printTargetPageTitle"/>
										</xsl:when>
										<xsl:when test="$isChapterWise and not($isSameChapter)">
											<fo:basic-link external-destination="./{$linkChapterNr}.pdf#dest={Link.ShortDesc/@IDRef}" show-destination="new">
												<xsl:apply-templates select="current()" mode="printTargetPageTitle"/>
											</fo:basic-link>
										</xsl:when>
										<xsl:otherwise>
											<fo:basic-link internal-destination="{Link.ShortDesc/@IDRef}">
												<xsl:apply-templates select="current()" mode="printTargetPageTitle"/>
											</fo:basic-link>
										</xsl:otherwise>
									</xsl:choose>

									<xsl:if test="$showPageNr and not($leaderType = 'none')">
										<fo:leader leader-pattern="{$leaderType}"/>
										<xsl:if test="not($usePageNumberColumn)">
											<xsl:apply-templates select="current()" mode="writePageReferenceNumber">
												<xsl:with-param name="RefID" select="Link.ShortDesc/@IDRef"/>
											</xsl:apply-templates>
										</xsl:if>
									</xsl:if>
								</fo:block>

								<xsl:if test="$showBlockAbstractContent and $currentElement/Block[@Function = 'block.abstract']/*">
									<fo:block>
										<xsl:call-template name="addStyle">
											<xsl:with-param name="name" select="concat('toc_', @abs_level, '.text.abstract')"/>
										</xsl:call-template>
										<xsl:apply-templates select="$currentElement/Block[@Function = 'block.abstract']/*"/>
									</fo:block>
								</xsl:if>
							</fo:table-cell>
							<xsl:if test="not($pageNumberColumnOnLeft) and $usePageNumberColumn and $showPageNr">
								<xsl:apply-templates select="current()" mode="writePageNumberColumnn"/>
							</xsl:if>
						</fo:table-row>

						<xsl:variable name="headlineThemeInGenerateContents">
							<xsl:call-template name="getTemplateVariableValue">
								<xsl:with-param name="name" select="concat('HEADLINE_THEME_IN_GENERATE_CONTENTS.', @abs_level)"/>
								<xsl:with-param name="defaultValue">
									<xsl:call-template name="getTemplateVariableValue">
										<xsl:with-param name="name" select="'HEADLINE_THEME_IN_GENERATE_CONTENTS'"/>
									</xsl:call-template>
								</xsl:with-param>
							</xsl:call-template>
						</xsl:variable>

						<xsl:variable name="IDRef" select="Link.ShortDesc[1]/@IDRef"/>

						<xsl:if test="$headlineThemeInGenerateContents = 'true'">
							<fo:table-row>
								<fo:table-cell><fo:block/></fo:table-cell>
								<fo:table-cell>
									<xsl:if test="not($pageNumberColumnOnLeft) and $usePageNumberColumn and $showPageNr">
										<xsl:attribute name="number-columns-spanned">2</xsl:attribute>
									</xsl:if>
							    	<fo:block>
							    		<xsl:call-template name="addStyle">
											<xsl:with-param name="name">toc_headlinetheme</xsl:with-param>
										</xsl:call-template>
										<xsl:call-template name="addStyle">
											<xsl:with-param name="name" select="concat('toc_', @abs_level, '.headlinetheme')"/>
										</xsl:call-template>
							    		<fo:inline><xsl:apply-templates select="(key('InfoMapKey',$IDRef))[1]/Headline.theme"/></fo:inline>
							    	</fo:block>
							    </fo:table-cell>
							</fo:table-row>
						</xsl:if>
					</fo:table-body>
				</fo:table>
			</xsl:for-each>
		</fo:block>

	</xsl:template>

	<xsl:template match="InfoItem.Overview" mode="writePageNumberColumnn">
		<fo:table-cell display-align="after">
			<xsl:call-template name="addStyle">
				<xsl:with-param name="name" select="concat('toc_', @abs_level, '.page')"/>
			</xsl:call-template>
			<fo:block>
				<xsl:if test="not($isRightToLeftLanguage)">
					<xsl:attribute name="text-align">right</xsl:attribute>
				</xsl:if>
				<xsl:apply-templates select="current()" mode="writePageReferenceNumber">
					<xsl:with-param name="RefID" select="Link.ShortDesc/@IDRef"/>
				</xsl:apply-templates>
			</fo:block>
		</fo:table-cell>
	</xsl:template>

	<xsl:template match="InfoItem.Overviewall" mode="table-hierarchical">
		<xsl:param name="showBlockAbstractContent" select="false()"/>
		<xsl:param name="usePageNumberColumn" select="false()"/>

		<xsl:for-each select="InfoItem.Overview[not(@HideInNavigation = 'true')]">
			<fo:table width="100%" table-layout="fixed">
				<xsl:call-template name="addStyle">
					<xsl:with-param name="name">toc.item</xsl:with-param>
				</xsl:call-template>
				<fo:table-column>
					<xsl:attribute name="column-width">
						<xsl:call-template name="getTemplateVariableValue">
							<xsl:with-param name="name" select="'TOC_COL1'"/>
							<xsl:with-param name="defaultValue">6mm</xsl:with-param>
						</xsl:call-template>
					</xsl:attribute>
				</fo:table-column>
				<fo:table-column column-width="proportional-column-width(1)"/>
				<fo:table-column column-width="2cm"/>
				<fo:table-body start-indent="0">
					<xsl:apply-templates select="current()" mode="table-hierarchical-item">
						<xsl:with-param name="showBlockAbstractContent" select="$showBlockAbstractContent"/>
						<xsl:with-param name="usePageNumberColumn" select="$usePageNumberColumn"/>
						<xsl:with-param name="relativeLevel" select="0"/>
					</xsl:apply-templates>
				</fo:table-body>
			</fo:table>
		</xsl:for-each>
	</xsl:template>

	<xsl:template match="InfoItem.Overview" mode="table-hierarchical">
		<xsl:param name="showBlockAbstractContent"/>
		<xsl:param name="usePageNumberColumn"/>
		<xsl:param name="relativeLevel"/>

		<xsl:if test="InfoItem.Overview[not(@HideInNavigation = 'true')]">
			<fo:table width="100%" table-layout="fixed">
				<xsl:call-template name="addStyle">
					<xsl:with-param name="name">toc.subitem</xsl:with-param>
				</xsl:call-template>
				<fo:table-column>
					<xsl:attribute name="column-width">
						<xsl:call-template name="getTemplateVariableValue">
							<xsl:with-param name="name" select="'TOC_COL1'"/>
							<xsl:with-param name="defaultValue">6mm</xsl:with-param>
						</xsl:call-template>
					</xsl:attribute>
				</fo:table-column>
				<fo:table-column column-width="proportional-column-width(1)"/>
				<fo:table-column column-width="2cm"/>
				<fo:table-body start-indent="0">
					<xsl:apply-templates select="InfoItem.Overview[not(@HideInNavigation = 'true')]" mode="table-hierarchical-item">
						<xsl:with-param name="showBlockAbstractContent" select="$showBlockAbstractContent"/>
						<xsl:with-param name="usePageNumberColumn" select="$usePageNumberColumn"/>
						<xsl:with-param name="relativeLevel" select="$relativeLevel"/>
					</xsl:apply-templates>
				</fo:table-body>
			</fo:table>
		</xsl:if>
	</xsl:template>

	<xsl:template match="InfoItem.Overview" mode="table-hierarchical-item">
		<xsl:param name="showBlockAbstractContent"/>
		<xsl:param name="usePageNumberColumn"/>
		<xsl:param name="relativeLevel"/>

		<xsl:variable name="currentChapterNr">
			<xsl:choose>
				<xsl:when test="$isChapterWise">
					<xsl:apply-templates select="current()" mode="getLinkChapterNr">
						<xsl:with-param name="RefID" select="ancestor::InfoMap[1]/@ID"/>
					</xsl:apply-templates>
				</xsl:when>
				<xsl:otherwise>1</xsl:otherwise>
			</xsl:choose>
		</xsl:variable>

		<xsl:variable name="linkChapterNr">
			<xsl:choose>
				<xsl:when test="$isChapterWise">
					<xsl:apply-templates select="current()" mode="getLinkChapterNr">
						<xsl:with-param name="RefID" select="Link.ShortDesc/@IDRef"/>
					</xsl:apply-templates>
				</xsl:when>
				<xsl:otherwise>1</xsl:otherwise>
			</xsl:choose>
		</xsl:variable>

		<xsl:variable name="currentElement" select="key('InfoMapKey',Link.ShortDesc/@IDRef)[1]"/>

		<xsl:variable name="isSameChapter" select="($isChapterWise and ($currentChapterNr = $linkChapterNr)) or not($isChapterWise)"/>

		<xsl:variable name="chapterNumber">
			<xsl:choose>
				<xsl:when test="@isBlock">
					<xsl:apply-templates select="(key('BlockKey',Link.ShortDesc/@IDRef))[1]" mode="getContentsChapterNr"/>
				</xsl:when>
				<xsl:otherwise>
					<xsl:apply-templates select="$currentElement" mode="getContentsChapterNr"/>
				</xsl:otherwise>
			</xsl:choose>
		</xsl:variable>
		<xsl:variable name="hasChapterNr" select="string-length($chapterNumber) &gt; 0"/>

		<fo:table-row start-indent="0">
			<xsl:call-template name="addStyle">
				<xsl:with-param name="name" select="concat('toc_', @abs_level, '.row')"/>
			</xsl:call-template>
			<xsl:call-template name="addStyle">
				<xsl:with-param name="name" select="concat('toc_', @abs_level, '.row')"/>
				<xsl:with-param name="currentElement" select="$currentElement"/>
			</xsl:call-template>
			<xsl:call-template name="addStyle">
				<xsl:with-param name="name" select="concat('toc_', @abs_level, '_', $relativeLevel, '.row')"/>
			</xsl:call-template>
			<xsl:call-template name="addStyle">
				<xsl:with-param name="name" select="concat('toc_', @abs_level, '_', $relativeLevel, '.row')"/>
				<xsl:with-param name="currentElement" select="$currentElement"/>
			</xsl:call-template>
			<xsl:if test="$hasChapterNr">
				<fo:table-cell>
					<xsl:call-template name="addStyle">
						<xsl:with-param name="name" select="concat('toc_', @abs_level)"/>
					</xsl:call-template>
					<xsl:call-template name="addStyle">
						<xsl:with-param name="name" select="concat('toc_', @abs_level, '.nr')"/>
						<xsl:with-param name="currentElement" select="$currentElement"/>
					</xsl:call-template>
					<xsl:call-template name="addStyle">
						<xsl:with-param name="name" select="concat('toc_', @abs_level, '.nr')"/>
					</xsl:call-template>
					<fo:block>
						<xsl:call-template name="addStyle">
							<xsl:with-param name="name" select="concat('toc_', @abs_level, '.nr.inline')"/>
						</xsl:call-template>
						<xsl:value-of select="$chapterNumber"/>
					</fo:block>
				</fo:table-cell>
			</xsl:if>
			<xsl:variable name="showPageNr" select="not(string-length(Link.ShortDesc/@IDRef) = 0 or ($isChapterWise and not($isSameChapter)))"/>
			<fo:table-cell>
				<xsl:choose>
					<xsl:when test="not($hasChapterNr)">
						<xsl:attribute name="number-columns-spanned">3</xsl:attribute>
					</xsl:when>
					<xsl:otherwise>
						<xsl:attribute name="number-columns-spanned">2</xsl:attribute>
					</xsl:otherwise>
				</xsl:choose>
				<xsl:call-template name="addStyle">
					<xsl:with-param name="name" select="concat('toc_', @abs_level)"/>
				</xsl:call-template>
				<xsl:call-template name="addStyle">
					<xsl:with-param name="name" select="concat('toc_', @abs_level, '.text')"/>
					<xsl:with-param name="currentElement" select="$currentElement"/>
				</xsl:call-template>
				<xsl:call-template name="addStyle">
					<xsl:with-param name="name" select="concat('toc_', @abs_level, '.text')"/>
				</xsl:call-template>
				<xsl:if test="string-length(Link.ShortDesc/InfoChunk.Link) &gt; 0">
					<xsl:choose>
						<xsl:when test="$usePageNumberColumn">
							<fo:table table-layout="fixed" width="100%">
								<fo:table-column column-width="proportional-column-width(1)"/>
								<fo:table-column>
									<xsl:attribute name="column-width">
										<xsl:call-template name="getTemplateVariableValue">
											<xsl:with-param name="name" select="'TOC_COL3'"/>
											<xsl:with-param name="defaultValue">6mm</xsl:with-param>
										</xsl:call-template>
									</xsl:attribute>
								</fo:table-column>
								<fo:table-body start-indent="0">
									<fo:table-row>
										<fo:table-cell>
											<fo:block>
												<xsl:call-template name="addStyle">
													<xsl:with-param name="name" select="concat('toc_', @abs_level, '.text.inline')"/>
												</xsl:call-template>
												<xsl:call-template name="addStyle">
													<xsl:with-param name="name" select="concat('toc_', @abs_level, '.text.inline')"/>
													<xsl:with-param name="currentElement" select="$currentElement"/>
												</xsl:call-template>
												<xsl:choose>
													<xsl:when test="string-length(Link.ShortDesc/@IDRef) = 0 or $isPDFXMODE">
														<xsl:apply-templates select="current()" mode="printTargetPageTitle"/>
													</xsl:when>
													<xsl:when test="$isChapterWise and not($isSameChapter)">
														<fo:basic-link external-destination="./{$linkChapterNr}.pdf#dest={Link.ShortDesc/@IDRef}" show-destination="new">
															<xsl:apply-templates select="current()" mode="printTargetPageTitle"/>
														</fo:basic-link>
													</xsl:when>
													<xsl:otherwise>
														<fo:basic-link internal-destination="{Link.ShortDesc/@IDRef}">
															<xsl:apply-templates select="current()" mode="printTargetPageTitle"/>
														</fo:basic-link>
													</xsl:otherwise>
												</xsl:choose>
											</fo:block>
										</fo:table-cell>
										<fo:table-cell display-align="after">
											<fo:block>
												<xsl:if test="not($isRightToLeftLanguage)">
													<xsl:attribute name="text-align">right</xsl:attribute>
												</xsl:if>
												<xsl:if test="$showPageNr">
													<xsl:call-template name="addStyle">
														<xsl:with-param name="name" select="concat('toc_', @abs_level, '.page')"/>
													</xsl:call-template>
													<xsl:apply-templates select="current()" mode="writePageReferenceNumber">
														<xsl:with-param name="RefID" select="Link.ShortDesc/@IDRef"/>
													</xsl:apply-templates>
												</xsl:if>
											</fo:block>
										</fo:table-cell>
									</fo:table-row>
								</fo:table-body>
							</fo:table>
						</xsl:when>
						<xsl:otherwise>
							<fo:block>
								<xsl:if test="$showPageNr">
									<xsl:attribute name="text-align-last">justify</xsl:attribute>
								</xsl:if>
								<xsl:call-template name="addStyle">
									<xsl:with-param name="name" select="concat('toc_', @abs_level, '.text.inline')"/>
								</xsl:call-template>
								<xsl:call-template name="addStyle">
									<xsl:with-param name="name" select="concat('toc_', @abs_level, '.text.inline')"/>
									<xsl:with-param name="currentElement" select="$currentElement"/>
								</xsl:call-template>
								<xsl:choose>
									<xsl:when test="string-length(Link.ShortDesc/@IDRef) = 0 or $isPDFXMODE">
										<xsl:apply-templates select="current()" mode="printTargetPageTitle"/>
									</xsl:when>
									<xsl:when test="$isChapterWise and not($isSameChapter)">
										<fo:basic-link external-destination="./{$linkChapterNr}.pdf#dest={Link.ShortDesc/@IDRef}" show-destination="new">
											<xsl:apply-templates select="current()" mode="printTargetPageTitle"/>
										</fo:basic-link>
									</xsl:when>
									<xsl:otherwise>
										<fo:basic-link internal-destination="{Link.ShortDesc/@IDRef}">
											<xsl:apply-templates select="current()" mode="printTargetPageTitle"/>
										</fo:basic-link>
									</xsl:otherwise>
								</xsl:choose>
								<xsl:if test="$showPageNr">
									<fo:leader leader-pattern="space"/>
									<fo:wrapper>
										<xsl:call-template name="addStyle">
											<xsl:with-param name="name" select="concat('toc_', @abs_level, '.page')"/>
										</xsl:call-template>
										<xsl:apply-templates select="current()" mode="writePageReferenceNumber">
											<xsl:with-param name="RefID" select="Link.ShortDesc/@IDRef"/>
										</xsl:apply-templates>
									</fo:wrapper>
								</xsl:if>
							</fo:block>
						</xsl:otherwise>
					</xsl:choose>
				</xsl:if>
				<xsl:if test="$showBlockAbstractContent and $currentElement/Block[@Function = 'block.abstract']/*">
					<fo:block>
						<xsl:call-template name="addStyle">
							<xsl:with-param name="name" select="concat('toc_', @abs_level, '.text.abstract')"/>
						</xsl:call-template>
						<xsl:apply-templates select="$currentElement/Block[@Function = 'block.abstract']/*"/>
					</fo:block>
				</xsl:if>
				<xsl:apply-templates select="current()" mode="table-hierarchical">
					<xsl:with-param name="showBlockAbstractContent" select="$showBlockAbstractContent"/>
					<xsl:with-param name="usePageNumberColumn" select="$usePageNumberColumn"/>
					<xsl:with-param name="relativeLevel" select="$relativeLevel + 1"/>
				</xsl:apply-templates>
			</fo:table-cell>
		</fo:table-row>
	</xsl:template>

	<xsl:template match="*" mode="getContentsChapterNr">
		<xsl:param name="removePointSuffix">
			<xsl:call-template name="getTemplateVariableValue">
				<xsl:with-param name="name">GENERATE_CONTENT_NR_REMOVE_POINT_SUFFIX</xsl:with-param>
				<xsl:with-param name="defaultValue">true</xsl:with-param>
			</xsl:call-template>
		</xsl:param>
		<xsl:apply-templates select="current()" mode="getChapterNr">
			<xsl:with-param name="removePointSuffix" select="$removePointSuffix"/>
		</xsl:apply-templates>
	</xsl:template>

	<xsl:template match="generate[@type = 'catalog.generate.overview']">
		<fo:block>
			<xsl:call-template name="addStyle">
				<xsl:with-param name="name">generate.catalog</xsl:with-param>
			</xsl:call-template>
			<xsl:for-each select="link.catalog/link.catalog.controller/Structure//Object/RefControl">
				<xsl:sort select="Properties/Property[@name = 'title']/@value"/>
				<fo:block>
					<xsl:call-template name="addStyle">
						<xsl:with-param name="name">generate.catalog.item</xsl:with-param>
					</xsl:call-template>
					<xsl:value-of select="Properties/Property[@name = 'title']/@value"/>
				</fo:block>
			</xsl:for-each>
		</fo:block>
	</xsl:template>

</xsl:stylesheet>
