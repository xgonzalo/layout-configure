<?xml version="1.0" encoding="utf-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:fo="http://www.w3.org/1999/XSL/Format" version="1.0">

	<xsl:template match="Headline.content">
		<xsl:apply-templates select="current()" mode="internal"/>
	</xsl:template>

	<xsl:template match="Headline.content | Label" mode="getDefaultDisplayType">complex</xsl:template>
	
	<xsl:template match="Headline.content | Label" mode="internal">
		<xsl:variable name="level">
			<xsl:apply-templates select="current()" mode="getCurrentLevel"/>
		</xsl:variable>
		<xsl:variable name="mode">
			<xsl:call-template name="getTemplateVariableValue">
				<xsl:with-param name="name" select="concat('HEADLINE_CONTENT_', $level, '_DISPLAY_TYPE')"/>
				<xsl:with-param name="defaultValue">
					<xsl:call-template name="getTemplateVariableValue">
						<xsl:with-param name="name">HEADLINE_CONTENT_DISPLAY_TYPE</xsl:with-param>
						<xsl:with-param name="defaultValue">
							<xsl:apply-templates select="current()" mode="getDefaultDisplayType"/>
						</xsl:with-param>
					</xsl:call-template>
				</xsl:with-param>
			</xsl:call-template>
		</xsl:variable>
		<xsl:variable name="useSuffixAfterLastNumber">
			<xsl:call-template name="getTemplateVariableValue">
				<xsl:with-param name="name">HEADLINE_CONTENT_NR_REMOVE_POINT_SUFFIX</xsl:with-param>
				<xsl:with-param name="defaultValue">true</xsl:with-param>
			</xsl:call-template>
		</xsl:variable>
		<xsl:variable name="autoFixPageBreaks">
			<xsl:call-template name="getTemplateVariableValue">
				<xsl:with-param name="name">HEADLINE_CONTENT_AUTO_FIX_PAGE_BREAKS</xsl:with-param>
				<xsl:with-param name="defaultValue">false</xsl:with-param>
			</xsl:call-template>
		</xsl:variable>
		<xsl:variable name="alwaysShowChapterCol">
			<xsl:call-template name="getTemplateVariableValue">
				<xsl:with-param name="name">HEADLINE_CONTENT_ALWAYS_SHOW_CHAPTER_COLUMN</xsl:with-param>
				<xsl:with-param name="defaultValue">false</xsl:with-param>
			</xsl:call-template>
		</xsl:variable>
		<xsl:variable name="headlineThemeDisplayMode">
			<xsl:call-template name="getTemplateVariableValue">
				<xsl:with-param name="name">HEADLINE_THEME_DISPLAY_TYPE</xsl:with-param>
				<xsl:with-param name="defaultValue">complex</xsl:with-param>
			</xsl:call-template>
		</xsl:variable>
		<xsl:choose>
			<xsl:when test="$mode = 'simple'">
				<xsl:apply-templates select="current()" mode="simple">
					<xsl:with-param name="removePointSuffix" select="$useSuffixAfterLastNumber"/>
					<xsl:with-param name="autoFixPageBreaks" select="$autoFixPageBreaks = 'true'"/>
					<xsl:with-param name="level" select="$level"/>
					<xsl:with-param name="headlineThemeDisplayMode" select="$headlineThemeDisplayMode"/>
				</xsl:apply-templates>
			</xsl:when>
			<xsl:when test="$mode = 'complex-with-ct'">
				<xsl:apply-templates select="current()" mode="complex-with-ct">
					<xsl:with-param name="removePointSuffix" select="$useSuffixAfterLastNumber"/>
					<xsl:with-param name="autoFixPageBreaks" select="$autoFixPageBreaks = 'true'"/>
					<xsl:with-param name="level" select="$level"/>
					<xsl:with-param name="alwaysShowChapterCol" select="$alwaysShowChapterCol = 'true'"/>
					<xsl:with-param name="headlineThemeDisplayMode" select="$headlineThemeDisplayMode"/>
				</xsl:apply-templates>
			</xsl:when>
			<xsl:otherwise>
				<xsl:apply-templates select="current()" mode="complex">
					<xsl:with-param name="removePointSuffix" select="$useSuffixAfterLastNumber"/>
					<xsl:with-param name="autoFixPageBreaks" select="$autoFixPageBreaks = 'true'"/>
					<xsl:with-param name="level" select="$level"/>
					<xsl:with-param name="alwaysShowChapterCol" select="$alwaysShowChapterCol = 'true'"/>
					<xsl:with-param name="headlineThemeDisplayMode" select="$headlineThemeDisplayMode"/>
				</xsl:apply-templates>
			</xsl:otherwise>
		</xsl:choose>
	</xsl:template>

	<xsl:template match="Headline.content | Label" mode="simple">
		<xsl:param name="level">
			<xsl:apply-templates select="current()" mode="getCurrentLevel"/>
		</xsl:param>
		<xsl:param name="numberTextSeparator">
			<xsl:call-template name="getFormat">
				<xsl:with-param name="name" select="concat('headline.content.', $level)"/>
				<xsl:with-param name="attributeName">number-text-separator</xsl:with-param>
				<xsl:with-param name="defaultValue">
					<xsl:text> </xsl:text>
				</xsl:with-param>
			</xsl:call-template>
		</xsl:param>
		<xsl:param name="removePointSuffix">true</xsl:param>
		<xsl:param name="autoFixPageBreaks" select="false()"/>
		<xsl:param name="headlineThemeDisplayMode"/>
		<fo:block>
			<xsl:call-template name="addStyle">
				<xsl:with-param name="name">headline.content</xsl:with-param>
			</xsl:call-template>
			<xsl:call-template name="addStyle">
				<xsl:with-param name="name" select="concat('headline.content.', $level)"/>
			</xsl:call-template>
			<xsl:apply-templates select="current()" mode="writeCharacterizationInfo"/>
			<xsl:if test="string-length(@style) &gt; 0">
				<xsl:call-template name="addStyle">
					<xsl:with-param name="name" select="@style"/>
				</xsl:call-template>
				<xsl:call-template name="addStyle">
					<xsl:with-param name="name" select="concat(@style,'.', $level)"/>
				</xsl:call-template>
			</xsl:if>
			<xsl:apply-templates select="current()" mode="applyPageBreak">
				<xsl:with-param name="level" select="$level"/>
				<xsl:with-param name="autoFixPageBreaks" select="$autoFixPageBreaks"/>
			</xsl:apply-templates>

			<xsl:choose>
				<xsl:when test="$headlineThemeDisplayMode = 'inline' and string-length(../Headline.theme) &gt; 0">
					<xsl:apply-templates select="../Headline.theme" mode="writeHeadlineTheme">
						<xsl:with-param name="position">inline</xsl:with-param>
					</xsl:apply-templates>

					<fo:block>
						<xsl:if test="ancestor-or-self::InfoMap[1][not(@HideInNavigation = 'true')]">
							<xsl:variable name="chapterNr">
								<xsl:apply-templates select="current()" mode="getChapterNr">
									<xsl:with-param name="level" select="$level"/>
									<xsl:with-param name="removePointSuffix" select="$removePointSuffix"/>
								</xsl:apply-templates>
							</xsl:variable>
							<xsl:if test="string-length($chapterNr) &gt; 0">
								<xsl:value-of select="$chapterNr"/>
								<xsl:if test="string-length(.) &gt; 0">
									<xsl:value-of select="$numberTextSeparator"/>
								</xsl:if>
							</xsl:if>
						</xsl:if>
						<xsl:apply-templates/>
					</fo:block>
				</xsl:when>
				<xsl:otherwise>
					<xsl:if test="ancestor-or-self::InfoMap[1][not(@HideInNavigation = 'true')]">
						<xsl:variable name="chapterNr">
							<xsl:apply-templates select="current()" mode="getChapterNr">
								<xsl:with-param name="level" select="$level"/>
								<xsl:with-param name="removePointSuffix" select="$removePointSuffix"/>
							</xsl:apply-templates>
						</xsl:variable>
						<xsl:if test="string-length($chapterNr) &gt; 0">
							<xsl:value-of select="$chapterNr"/>
							<xsl:if test="string-length(.) &gt; 0">
								<xsl:value-of select="$numberTextSeparator"/>
							</xsl:if>
						</xsl:if>
					</xsl:if>
					<xsl:apply-templates/>
				</xsl:otherwise>
			</xsl:choose>
		</fo:block>
	</xsl:template>

	<xsl:template match="Headline.content | Label" mode="complex">
		<xsl:param name="alwaysShowChapterCol" select="false()"/>
		<xsl:param name="autoFixPageBreaks" select="false()"/>
		<xsl:param name="removePointSuffix">true</xsl:param>
		<xsl:param name="level">
			<xsl:apply-templates select="current()" mode="getCurrentLevel"/>
		</xsl:param>
		<xsl:param name="headlineThemeDisplayMode"/>
		
		<xsl:variable name="type" select="ancestor-or-self::InfoMap[1]/@Typ"/>

		<xsl:variable name="CHAPTER_NR_COL_WIDTHpre">
			<xsl:call-template name="getTemplateVariableValue">
				<xsl:with-param name="name" select="concat('CHAPTER_NR_COL_WIDTH.', $level)"/>
				<xsl:with-param name="defaultValue">
					<xsl:call-template name="getTemplateVariableValue">
						<xsl:with-param name="name">CHAPTER_NR_COL_WIDTH</xsl:with-param>
						<xsl:with-param name="defaultValue">2.5cm</xsl:with-param>
					</xsl:call-template>
				</xsl:with-param>
			</xsl:call-template>
		</xsl:variable>

		<xsl:variable name="CHAPTER_NR_COL_WIDTH">
			<xsl:choose>
				<xsl:when test="string-length($type) &gt; 0">
					<xsl:call-template name="getTemplateVariableValue">
						<xsl:with-param name="name" select="concat('CHAPTER_NR_COL_WIDTH.', $type)"/>
						<xsl:with-param name="defaultValue" select="$CHAPTER_NR_COL_WIDTHpre"/>
					</xsl:call-template>
				</xsl:when>
				<xsl:otherwise>
					<xsl:value-of select="$CHAPTER_NR_COL_WIDTHpre"/>
				</xsl:otherwise>
			</xsl:choose>
		</xsl:variable>

		<xsl:variable name="chapterNrPre">
			<xsl:if test="ancestor-or-self::InfoMap[1][not(@HideInNavigation = 'true')]">
				<xsl:apply-templates select="current()" mode="getChapterNr">
					<xsl:with-param name="level" select="$level"/>
					<xsl:with-param name="removePointSuffix" select="$removePointSuffix"/>
				</xsl:apply-templates>
			</xsl:if>
		</xsl:variable>

		<xsl:variable name="fallbackToParent">
			<xsl:call-template name="getTemplateVariableValue">
				<xsl:with-param name="name">CHAPTER_NR_FALLBACK_TO_PARENT</xsl:with-param>
			</xsl:call-template>
		</xsl:variable>

		<xsl:variable name="chapterNr">
			<xsl:choose>
				<xsl:when test="string-length($chapterNrPre) = 0 and $fallbackToParent = 'true'">
					<xsl:if test="ancestor-or-self::InfoMap[2][not(@HideInNavigation = 'true')]">
						<xsl:apply-templates select="ancestor-or-self::InfoMap[2]" mode="getChapterNr">
							<xsl:with-param name="removePointSuffix" select="$removePointSuffix"/>
						</xsl:apply-templates>
					</xsl:if>
				</xsl:when>
				<xsl:otherwise>
					<xsl:value-of select="$chapterNrPre"/>
				</xsl:otherwise>
			</xsl:choose>
		</xsl:variable>

		<xsl:variable name="startIndent">
			<xsl:call-template name="getFormat">
				<xsl:with-param name="name" select="concat('headline.content.', $level)"/>
				<xsl:with-param name="attributeName">start-indent</xsl:with-param>
				<xsl:with-param name="defaultValue">
					<xsl:call-template name="getFormat">
						<xsl:with-param name="name">headline.content</xsl:with-param>
						<xsl:with-param name="attributeName">start-indent</xsl:with-param>
					</xsl:call-template>
				</xsl:with-param>
			</xsl:call-template>
		</xsl:variable>

		<xsl:variable name="hasChapterNr" select="string-length($chapterNr) &gt; 0"/>

		<fo:table table-layout="fixed" width="100%">
			<xsl:call-template name="addStyle">
				<xsl:with-param name="name">headline.content</xsl:with-param>
			</xsl:call-template>
			<xsl:call-template name="addStyle">
				<xsl:with-param name="name" select="concat('headline.content.', $level)"/>
			</xsl:call-template>
			<xsl:if test="string-length(@style) &gt; 0">
				<xsl:call-template name="addStyle">
					<xsl:with-param name="name" select="@style"/>
				</xsl:call-template>
			</xsl:if>				
			<xsl:if test="string-length($startIndent) &gt; 0 and $startIndent != '0'">
				<xsl:attribute name="width">
					<xsl:value-of select="concat('100%-', $startIndent)"/>
				</xsl:attribute>
			</xsl:if>
			<xsl:if test="not($isOffline) and not($objType = 'book')">
				<xsl:call-template name="addStyle">
					<xsl:with-param name="name" select="'headline.content.cms'"/>
				</xsl:call-template>
			</xsl:if>

			<xsl:apply-templates select="current()" mode="writeCharacterizationInfo">
				<xsl:with-param name="showContent" select="false()"/>
			</xsl:apply-templates>

			<xsl:apply-templates select="current()" mode="applyPageBreak">
				<xsl:with-param name="level" select="$level"/>
				<xsl:with-param name="autoFixPageBreaks" select="$autoFixPageBreaks"/>
			</xsl:apply-templates>
			<xsl:if test="$hasChapterNr or $alwaysShowChapterCol">
				<fo:table-column column-width="{$CHAPTER_NR_COL_WIDTH}"/>
			</xsl:if>
			<fo:table-column column-width="proportional-column-width(1)"/>
			<fo:table-body start-indent="0">
				<xsl:apply-templates select="current()" mode="writeCharacterizationInfoRow">
					<xsl:with-param name="noBottom" select="true()"/>
				</xsl:apply-templates>
				<xsl:if test="$headlineThemeDisplayMode = 'inline' and string-length(../Headline.theme) &gt; 0">
					<fo:table-row>
						<fo:table-cell>
							<xsl:if test="$hasChapterNr or $alwaysShowChapterCol">
								<xsl:attribute name="number-columns-spanned">2</xsl:attribute>
							</xsl:if>
							<xsl:apply-templates select="../Headline.theme" mode="writeHeadlineTheme">
								<xsl:with-param name="position">inline</xsl:with-param>
							</xsl:apply-templates>
						</fo:table-cell>
					</fo:table-row>
				</xsl:if>
				<fo:table-row>
					<xsl:if test="$hasChapterNr or $alwaysShowChapterCol">
						<fo:table-cell>
							<xsl:call-template name="addStyle">
								<xsl:with-param name="name">headline.content.cell.1</xsl:with-param>
							</xsl:call-template>
							<xsl:call-template name="addStyle">
								<xsl:with-param name="name" select="concat('headline.content.cell.1.', $level)"/>
							</xsl:call-template>
							<fo:block>
								<xsl:value-of select="$chapterNr"/>
								<xsl:call-template name="getFormat">
									<xsl:with-param name="name" select="concat('headline.content.', $level)"/>
									<xsl:with-param name="attributeName">number-text-separator</xsl:with-param>
								</xsl:call-template>
							</fo:block>
						</fo:table-cell>
					</xsl:if>
					<fo:table-cell>
						<xsl:call-template name="addStyle">
							<xsl:with-param name="name">headline.content.cell.2</xsl:with-param>
						</xsl:call-template>
						<xsl:call-template name="addStyle">
								<xsl:with-param name="name" select="concat('headline.content.cell.2.', $level)"/>
							</xsl:call-template>
						<fo:block>
							<xsl:apply-templates/>
						</fo:block>
					</fo:table-cell>
				</fo:table-row>
			</fo:table-body>
		</fo:table>
	</xsl:template>

	<xsl:template match="Headline.content | Label | InfoMap" mode="applyPageBreak">
		<xsl:param name="level"/>
		<xsl:param name="autoFixPageBreaks"/>
		<xsl:if test="$autoFixPageBreaks and $level &gt; 1 and not(ancestor-or-self::InfoMap[1]/preceding-sibling::InfoMap) and not(ancestor-or-self::InfoMap[1]/parent::InfoMap[Block or block.titlepage])">
			<xsl:attribute name="break-before">auto</xsl:attribute>
		</xsl:if>
	</xsl:template>

	<xsl:template match="Headline.content | Label" mode="complex-with-ct">
		<xsl:param name="alwaysShowChapterCol" select="false()"/>
		<xsl:param name="autoFixPageBreaks" select="false()"/>
		<xsl:param name="removePointSuffix">true</xsl:param>
		<xsl:param name="level">
			<xsl:apply-templates select="current()" mode="getCurrentLevel"/>
		</xsl:param>
		<xsl:param name="headlineThemeDisplayMode"/>
		
		<fo:block-container>
			<xsl:call-template name="addStyle">
				<xsl:with-param name="name">headline.content.ct</xsl:with-param>
			</xsl:call-template>
			<xsl:call-template name="addStyle">
				<xsl:with-param name="name" select="concat('headline.content.ct.', $level)"/>
			</xsl:call-template>
			<xsl:apply-templates select="current()" mode="complex">
				<xsl:with-param name="alwaysShowChapterCol" select="$alwaysShowChapterCol"/>
				<xsl:with-param name="autoFixPageBreaks" select="$autoFixPageBreaks"/>
				<xsl:with-param name="removePointSuffix" select="$removePointSuffix"/>
				<xsl:with-param name="level" select="$level"/>
				<xsl:with-param name="headlineThemeDisplayMode" select="$headlineThemeDisplayMode"/>
			</xsl:apply-templates>
		</fo:block-container>

	</xsl:template>

	<xsl:template match="InfoMap" mode="getCurrentLevel">
		<xsl:choose>
			<xsl:when test="/*/Navigation">
				<xsl:choose>
					<xsl:when test="string-length($tp_nodeID) &gt; 0">
						<xsl:value-of select="/*/Navigation//InfoMap[@MasterID = $tp_nodeID]/@level + count(current()[not(ancestor::Navigation)]/ancestor::InfoMap[not(ancestor::Navigation)]) + 1"/>
					</xsl:when>
					<xsl:otherwise>
						<xsl:variable name="id" select="@ID"/>
						<xsl:value-of select="/*/Navigation//InfoMap[@ID = $id]/@level + count(current()[not(ancestor::Navigation)]/ancestor::InfoMap[not(ancestor::Navigation)]) + 1"/>
					</xsl:otherwise>
				</xsl:choose>
			</xsl:when>
			<xsl:when test="/InfoMap[(Headline.content or Block) and not(block.titlepage) and (InfoMap or include.document/InfoMap)]">
				<xsl:value-of select="@level + 1"/>
			</xsl:when>
			<xsl:otherwise>
				<xsl:value-of select="@level"/>
			</xsl:otherwise>
		</xsl:choose>
	</xsl:template>

	<xsl:template match="Headline.content" mode="getCurrentLevel">
		<xsl:apply-templates select="ancestor::InfoMap[1]" mode="getCurrentLevel"/>
	</xsl:template>

	<xsl:template match="Label" mode="getCurrentLevel">
		<xsl:variable name="level">
			<xsl:apply-templates select="ancestor::InfoMap[1]" mode="getCurrentLevel"/>
		</xsl:variable>
		<xsl:value-of select="$level + 1"/>
	</xsl:template>

	<xsl:variable name="CHAPTER_NR_RESTART_LEVEL">
		<xsl:call-template name="getTemplateVariableValue">
			<xsl:with-param name="name">CHAPTER_NR_RESTART_LEVEL</xsl:with-param>
			<xsl:with-param name="defaultValue" select="$BASE_LEVEL"/>
		</xsl:call-template>
	</xsl:variable>

	<xsl:variable name="CountLabelsInternal">
		<xsl:call-template name="getFormat">
			<xsl:with-param name="name">label</xsl:with-param>
			<xsl:with-param name="attributeName">auto-number</xsl:with-param>
		</xsl:call-template>
	</xsl:variable>

	<xsl:variable name="DO_COUNT_LABELS" select="$CountLabelsInternal = 'true'"/>

	<xsl:template match="*" mode="getChapterNr">
		<xsl:param name="removePointSuffix">true</xsl:param>
		<xsl:param name="level">
			<xsl:apply-templates select="current()" mode="getCurrentLevel"/>
		</xsl:param>
		<xsl:param name="useNrPrefix" select="true()"/>
		<xsl:param name="force" select="false()"/>
		<xsl:choose>
			<!-- for button support of filter conditions at Headline.content element -->
			<xsl:when test="self::InfoMap and Headline.content">
				<xsl:apply-templates select="Headline.content" mode="getChapterNr">
					<xsl:with-param name="removePointSuffix" select="$removePointSuffix"/>
					<xsl:with-param name="level" select="$level"/>
					<xsl:with-param name="useNrPrefix" select="$useNrPrefix"/>
					<xsl:with-param name="force" select="$force"/>
				</xsl:apply-templates>
			</xsl:when>
			<xsl:otherwise>
				<xsl:variable name="autoNumber">
					<xsl:choose>
						<xsl:when test="name() = 'Label'">
							<xsl:call-template name="getFormat">
								<xsl:with-param name="name">label</xsl:with-param>
								<xsl:with-param name="attributeName">auto-number</xsl:with-param>
							</xsl:call-template>
						</xsl:when>
						<xsl:otherwise>
							<xsl:call-template name="getFormat">
								<xsl:with-param name="name" select="concat('headline.content.', $level)"/>
								<xsl:with-param name="attributeName">auto-number</xsl:with-param>
							</xsl:call-template>
						</xsl:otherwise>
					</xsl:choose>
				</xsl:variable>
				<xsl:if test="not($autoNumber = 'false' or ancestor-or-self::InfoMap[1]/@HideInNavigation = 'true') or $force">
					<xsl:variable name="numberPrefix">
						<xsl:if test="$useNrPrefix">
							<xsl:call-template name="getFormat">
								<xsl:with-param name="name" select="concat('headline.content.', $level)"/>
								<xsl:with-param name="attributeName">number-prefix</xsl:with-param>
							</xsl:call-template>
						</xsl:if>
					</xsl:variable>
					<xsl:if test="string-length($numberPrefix) &gt; 0">
						<xsl:call-template name="translate">
							<xsl:with-param name="ID" select="$numberPrefix"/>
						</xsl:call-template>
						<xsl:call-template name="getTemplateVariableValue">
							<xsl:with-param name="name">PREFIX_NUMBER_SEPARATOR</xsl:with-param>
							<xsl:with-param name="defaultValue">
								<xsl:text> </xsl:text>
							</xsl:with-param>
						</xsl:call-template>
					</xsl:if>
					<xsl:variable name="id" select="ancestor-or-self::InfoMap[1]/@ID"/>
					<xsl:variable name="enum">
						<xsl:choose>
							<xsl:when test="/*/Navigation">
								<xsl:choose>
									<xsl:when test="$DO_COUNT_LABELS">
										<xsl:for-each select="/*/Navigation//InfoMap[(string-length($tp_nodeID) &gt; 0 and @MasterID = $tp_nodeID)
											  or (string-length($tp_nodeID) = 0 and @ID = $id)]/ancestor-or-self::InfoMap[ancestor::Navigation] | /*/Navigation//InfoMap[(string-length($tp_nodeID) &gt; 0 and @MasterID = $tp_nodeID)
											  or (string-length($tp_nodeID) = 0 and @ID = $id)]/ancestor-or-self::Block[1][not(parent::InfoMap[@HideInNavigation = 'true'])]">
											<xsl:if test="not(@Level &lt; $level and $CHAPTER_NR_RESTART_LEVEL &gt; @Level)">
												<xsl:apply-templates select="current()" mode="getPosition"/>
											</xsl:if>
										</xsl:for-each>
									</xsl:when>
									<xsl:otherwise>
										<xsl:for-each select="/*/Navigation//InfoMap[(string-length($tp_nodeID) &gt; 0 and @MasterID = $tp_nodeID)
											  or (string-length($tp_nodeID) = 0 and @ID = $id)]/ancestor-or-self::InfoMap[ancestor::Navigation]">
											<xsl:if test="not(@Level &lt; $level and $CHAPTER_NR_RESTART_LEVEL &gt; @Level)">
												<xsl:apply-templates select="current()" mode="getPosition"/>
											</xsl:if>
										</xsl:for-each>
										<xsl:if test="string-length($tp_nodeID) &gt; 0 and ancestor::InfoMap/parent::InfoMap">
											<xsl:for-each select="ancestor-or-self::InfoMap[parent::InfoMap and (@Level &gt; 0 or (not(block.titlepage) and (Block or Headline.content)))]">
												<xsl:if test="not(@Level &lt; $level and $CHAPTER_NR_RESTART_LEVEL &gt; @Level)">
													<xsl:apply-templates select="current()" mode="getPosition"/>
												</xsl:if>
											</xsl:for-each>
										</xsl:if>
									</xsl:otherwise>
								</xsl:choose>
							</xsl:when>
							<xsl:otherwise>
								<xsl:choose>
									<xsl:when test="$DO_COUNT_LABELS">
										<xsl:for-each select="ancestor-or-self::InfoMap[@Level &gt; 0 or (not(block.titlepage) and (Block or Headline.content))] | ancestor-or-self::Block[1][not(parent::InfoMap[@HideInNavigation = 'true'])]">
											<xsl:if test="not(@Level &lt; $level and $CHAPTER_NR_RESTART_LEVEL &gt; @Level)">
												<xsl:apply-templates select="current()" mode="getPosition"/>
											</xsl:if>
										</xsl:for-each>
									</xsl:when>
									<xsl:otherwise>
										<xsl:for-each select="ancestor-or-self::InfoMap[@Level &gt; 0 or (not(block.titlepage) and (Block or Headline.content))]">
											<xsl:if test="not(@Level &lt; $level and $CHAPTER_NR_RESTART_LEVEL &gt; @Level)">
												<xsl:apply-templates select="current()" mode="getPosition"/>
											</xsl:if>
										</xsl:for-each>
									</xsl:otherwise>
								</xsl:choose>
							</xsl:otherwise>
						</xsl:choose>
					</xsl:variable>
					<xsl:choose>
						<xsl:when test="$removePointSuffix = 'true'">
							<xsl:value-of select="substring($enum, 1, string-length($enum) - 1)"/>
						</xsl:when>
						<xsl:otherwise>
							<xsl:value-of select="$enum"/>
						</xsl:otherwise>
					</xsl:choose>
				</xsl:if>
			</xsl:otherwise>
		</xsl:choose>
	</xsl:template>

	<xsl:template match="InfoMap" mode="getPosition" name="getInfoMapPosition">
		<xsl:param name="suffix">.</xsl:param>
		<xsl:param name="level">
			<xsl:apply-templates select="current()" mode="getCurrentLevel"/>
		</xsl:param>
		<xsl:param name="isSideRegion"/>
		<xsl:variable name="autoNumber">
			<xsl:call-template name="getFormat">
				<xsl:with-param name="name" select="concat('headline.content.', $level)"/>
				<xsl:with-param name="attributeName">auto-number</xsl:with-param>
				<xsl:with-param name="altCurrentElement" select="Headline.content"/>
			</xsl:call-template>
		</xsl:variable>
		<xsl:variable name="initialChapterNumberStr">
			<xsl:call-template name="getTemplateVariableValue">
				<xsl:with-param name="name" select="concat('CHAPTER_NR_INITIAL_', $level)"/>
				<xsl:with-param name="defaultValue">
					<xsl:call-template name="getTemplateVariableValue">
						<xsl:with-param name="name">CHAPTER_NR_INITIAL</xsl:with-param>
						<xsl:with-param name="defaultValue">1</xsl:with-param>
					</xsl:call-template>
				</xsl:with-param>
			</xsl:call-template>
		</xsl:variable>
		<xsl:variable name="initialChapterNumber">
			<xsl:choose>
				<xsl:when test="string(number($initialChapterNumberStr)) != 'NaN'">
					<xsl:value-of select="$initialChapterNumberStr"/>
				</xsl:when>
				<xsl:otherwise>1</xsl:otherwise>
			</xsl:choose>
		</xsl:variable>
		<xsl:if test="not($autoNumber = 'false') or $isSideRegion">
			<xsl:variable name="numberFormatByLevel">
				<xsl:call-template name="getTemplateVariableValue">
					<xsl:with-param name="name" select="concat('CHAPTER_NR_FORMAT_', $level)"/>
					<xsl:with-param name="defaultValue">
						<xsl:call-template name="getTemplateVariableValue">
							<xsl:with-param name="name">CHAPTER_NR_FORMAT</xsl:with-param>
						</xsl:call-template>
					</xsl:with-param>
				</xsl:call-template>
			</xsl:variable>
			<xsl:variable name="numberFormat">
				<xsl:choose>
					<xsl:when test="string-length(@Typ) &gt; 0">
						<xsl:call-template name="getTemplateVariableValue">
							<xsl:with-param name="name" select="concat('CHAPTER_NR_FORMAT_', @Typ)"/>
							<xsl:with-param name="defaultValue" select="$numberFormatByLevel"/>
						</xsl:call-template>
					</xsl:when>
					<xsl:otherwise>
						<xsl:value-of select="$numberFormatByLevel"/>
					</xsl:otherwise>
				</xsl:choose>
			</xsl:variable>
			<xsl:variable name="type" select="@Typ"/>
			<xsl:variable name="lang" select="@Lang"/>
			<xsl:variable name="CHAPTER_NR_RESTART_WITH_LANGUAGE_CHANGE">
				<xsl:call-template name="getTemplateVariableValue">
					<xsl:with-param name="name">CHAPTER_NR_RESTART_WITH_LANGUAGE_CHANGE</xsl:with-param>
					<xsl:with-param name="defaultValue">false</xsl:with-param>
				</xsl:call-template>
			</xsl:variable>
			<xsl:variable name="languageNeutral" select="not($CHAPTER_NR_RESTART_WITH_LANGUAGE_CHANGE = 'true')"/>
			<!--<xsl:variable name="aiIns" select="ai:new()"/>
			<xsl:variable name="addInitial" select="ai:addAndGet($aiIns, number($initialChapterNumber))"/>-->
			<xsl:variable name="counter">
				<xsl:choose>
					<xsl:when test="string-length($type) &gt; 0 and $numberFormat != $numberFormatByLevel">
						<xsl:value-of select="count(preceding-sibling::InfoMap[@Typ = $type and not(@HideInNavigation = 'true') and ($languageNeutral or @Lang = $lang or $isSideRegion)]) + $initialChapterNumber"/>
					</xsl:when>
					<xsl:when test="$isSideRegion">
						<xsl:value-of select="count(preceding-sibling::InfoMap[not(@HideInNavigation = 'true') and ($languageNeutral or @Lang = $lang)]) + 1"/>
					</xsl:when>
					<xsl:otherwise>
						<!--<xsl:for-each select="preceding-sibling::InfoMap[not(@HideInNavigation = 'true') and ($languageNeutral or @Lang = $lang or $isSideRegion)]">
							<xsl:variable name="currAutoNumber">
								<xsl:call-template name="getFormat">
									<xsl:with-param name="name" select="concat('headline.content.', $level)"/>
									<xsl:with-param name="attributeName">auto-number</xsl:with-param>
									<xsl:with-param name="altCurrentElement" select="Headline.content"/>
								</xsl:call-template>
							</xsl:variable>
							<xsl:if test="not($currAutoNumber = 'false')">
								<xsl:variable name="addCurr" select="ai:addAndGet($aiIns, 1)"/>
							</xsl:if>
						</xsl:for-each>
						<xsl:value-of select="ai:get($aiIns)"/>-->
						<xsl:value-of select="count(preceding-sibling::InfoMap[not(@HideInNavigation = 'true') and ($languageNeutral or @Lang = $lang or $isSideRegion)]) + 1"/>
					</xsl:otherwise>
				</xsl:choose>
			</xsl:variable>
			<xsl:choose>
				<xsl:when test="string-length($numberFormat) = 0 or $isSideRegion">
					<xsl:value-of select="$counter"/>
				</xsl:when>
				<xsl:when test="$counter = 0 and $numberFormat = '01'">00</xsl:when>
				<xsl:when test="$numberFormat = 'I' or $numberFormat = 'i' or $numberFormat = '1'
						  or $numberFormat = '01' or $numberFormat = 'a' or $numberFormat = 'A'">
					<xsl:number value="$counter" format="{$numberFormat}"/>
				</xsl:when>
				<xsl:when test="$numberFormat = '010'">
					<xsl:number value="$counter" format="01"/>
					<xsl:text>0</xsl:text>
				</xsl:when>
				<xsl:otherwise>
					<xsl:value-of select="$counter"/>
				</xsl:otherwise>
			</xsl:choose>
			<xsl:value-of select="$suffix"/>
		</xsl:if>
	</xsl:template>

	<xsl:template match="Block" mode="getPosition">
		<xsl:param name="suffix">.</xsl:param>
		<xsl:variable name="autoNumber">
			<xsl:call-template name="getFormat">
				<xsl:with-param name="name">label</xsl:with-param>
				<xsl:with-param name="attributeName">auto-number</xsl:with-param>
			</xsl:call-template>
		</xsl:variable>
		<xsl:if test="not($autoNumber = 'false')">
			<xsl:value-of select="concat(count(preceding-sibling::InfoMap[not(@HideInNavigation = 'true')]) + count(preceding-sibling::Block[string-length(Label) &gt; 0 or Label/Media.theme]) + 1, $suffix)"/>
		</xsl:if>
	</xsl:template>

	<xsl:template match="*" mode="getMainChapterNr">
		<xsl:variable name="chapterNr">
			<xsl:apply-templates select="ancestor::InfoMap[not(@HideInNavigation = 'true')][1]" mode="getChapterNr">
				<xsl:with-param name="force" select="true()"/>
			</xsl:apply-templates>
		</xsl:variable>
		<xsl:choose>
			<xsl:when test="contains($chapterNr, '.')">
				<xsl:value-of select="substring-before($chapterNr, '.')"/>
			</xsl:when>
			<xsl:otherwise>
				<xsl:value-of select="$chapterNr"/>
			</xsl:otherwise>
		</xsl:choose>
	</xsl:template>

</xsl:stylesheet>
