<?xml version="1.0" encoding="utf-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
				xmlns:fo="http://www.w3.org/1999/XSL/Format"
				xmlns:fox="http://xmlgraphics.apache.org/fop/extensions"
				version="1.0">

	<xsl:template match="table | table.NoBorder" mode="getTableTitleDefaultPosition">bottom</xsl:template>

	<xsl:template match="table | table.NoBorder" mode="writeTableTitle">
		<xsl:param name="position">bottom</xsl:param>
		<xsl:param name="isCentered"/>
		<xsl:param name="isRight"/>
		<xsl:param name="isFormatTable"/>

		<xsl:variable name="defaultTableLegendPosition">
			<xsl:call-template name="getTemplateVariableValue">
				<xsl:with-param name="name" select="'TABLE_LEGEND_POSITION'"/>
				<xsl:with-param name="defaultValue">bottom</xsl:with-param>
			</xsl:call-template>
		</xsl:variable>

		<xsl:variable name="renderBottomLegend" select="$defaultTableLegendPosition = 'footer' and $position = 'bottom'
					  and following-sibling::*[name() != 'TableDesc'][1][name() = 'legend' and @isTableLegend and legend.row]"/>

		<xsl:variable name="alwaysShowTableTitle">
			<xsl:call-template name="getTemplateVariableValue">
				<xsl:with-param name="name" select="'TABLE_TITLE_SHOW_ALWAYS'"/>
				<xsl:with-param name="defaultValue">false</xsl:with-param>
			</xsl:call-template>
		</xsl:variable>

		<xsl:variable name="renderTableTitle" select="(title != 'Title' and string-length(title) &gt; 0 and not(@glossary)) or ($alwaysShowTableTitle = 'true' and not(name() = 'table.NoBorder' or $isFormatTable))"/>

		<xsl:variable name="visible">
			<xsl:call-template name="getFormat">
				<xsl:with-param name="name">table.title</xsl:with-param>
				<xsl:with-param name="attributeName">visibility</xsl:with-param>
			</xsl:call-template>
		</xsl:variable>

		<xsl:if test="($renderTableTitle or $renderBottomLegend) and not($visible = 'hidden')">

			<xsl:variable name="defaultTablePosition">
				<xsl:call-template name="getTemplateVariableValue">
					<xsl:with-param name="name" select="concat('TABLE_TITLE_POSITION.', @typ)"/>
					<xsl:with-param name="defaultValue">
						<xsl:call-template name="getTemplateVariableValue">
							<xsl:with-param name="name" select="'TABLE_TITLE_POSITION'"/>
							<xsl:with-param name="defaultValue">
								<xsl:apply-templates select="current()" mode="getTableTitleDefaultPosition"/>
							</xsl:with-param>
						</xsl:call-template>
					</xsl:with-param>
				</xsl:call-template>
			</xsl:variable>

			<xsl:variable name="isBottomTitle" select="$defaultTablePosition = $position and $position = 'bottom' and $renderTableTitle"/>

			<xsl:choose>
				<xsl:when test="$isBottomTitle or $renderBottomLegend">
					<fo:table-footer>
						<xsl:variable name="span" select="count(following-sibling::TableDesc[1]/TableColSpec)"/>
						<fo:table-row>
							<xsl:if test="$isCentered or $isRight">
								<fo:table-cell>
									<fo:block></fo:block>
								</fo:table-cell>
							</xsl:if>
							<fo:table-cell number-columns-spanned="{$span}">
								<xsl:call-template name="addStyle">
									<xsl:with-param name="name">table.cell.footer</xsl:with-param>
								</xsl:call-template>
								<xsl:if test="$isBottomTitle">
									<fo:block>
										<xsl:call-template name="addStyle">
											<xsl:with-param name="name">table.title</xsl:with-param>
										</xsl:call-template>
										<xsl:apply-templates select="current()" mode="writeTableTitleText"/>
									</fo:block>
								</xsl:if>
								<xsl:if test="$renderBottomLegend">
									<xsl:apply-templates select="following-sibling::*[name() != 'TableDesc'][1][name() = 'legend' and @isTableLegend]">
										<xsl:with-param name="forceRender" select="true()"/>
									</xsl:apply-templates>
								</xsl:if>
							</fo:table-cell>
							<xsl:if test="$isCentered">
								<fo:table-cell>
									<fo:block></fo:block>
								</fo:table-cell>
							</xsl:if>
						</fo:table-row>
					</fo:table-footer>
				</xsl:when>
				<xsl:when test="$defaultTablePosition = $position and $position = 'top'">
					<fo:block>
						<xsl:call-template name="addStyle">
							<xsl:with-param name="name">table.title</xsl:with-param>
						</xsl:call-template>
						<xsl:apply-templates select="current()" mode="writeTableTitleText">
							<xsl:with-param name="hasTitle" select="title != 'Title' and string-length(title) &gt; 0"/>
						</xsl:apply-templates>
					</fo:block>
				</xsl:when>
			</xsl:choose>
		</xsl:if>
	</xsl:template>

	<xsl:template match="table | table.NoBorder" mode="writeTableTitleText">
		<xsl:param name="hasTitle" select="title != 'Title' and string-length(title) &gt; 0"/>

		<xsl:variable name="displayTypePre">
			<xsl:call-template name="getTemplateVariableValue">
				<xsl:with-param name="name" select="'TABLE_TITLE_DISPLAY_TYPE'"/>
				<xsl:with-param name="defaultValue">
					<xsl:apply-templates select="current()" mode="getDefaultDisplayType"/>
				</xsl:with-param>
			</xsl:call-template>
		</xsl:variable>
		<xsl:variable name="autoNumber" select="not(following-sibling::TableDesc[1][@notAutoNumber = 'true'])"/>
		<xsl:variable name="displayType">
			<xsl:choose>
				<xsl:when test="not($autoNumber)">
					<xsl:call-template name="getTemplateVariableValue">
						<xsl:with-param name="name" select="'TABLE_TITLE_NOT_AUTO_NUMBER_DISPLAY_TYPE'"/>
						<xsl:with-param name="defaultValue" select="$displayTypePre"/>
					</xsl:call-template>
				</xsl:when>
				<xsl:otherwise>
					<xsl:value-of select="$displayTypePre"/>
				</xsl:otherwise>
			</xsl:choose>
		</xsl:variable>

		<xsl:variable name="tableTitlePrefix">
			<xsl:call-template name="getTemplateVariableValue">
				<xsl:with-param name="name" select="concat('TABLE_TITLE_PREFIX.', @typ)"/>
				<xsl:with-param name="defaultValue">
					<xsl:call-template name="getTemplateVariableValue">
						<xsl:with-param name="name" select="'TABLE_TITLE_PREFIX'"/>
						<xsl:with-param name="defaultValue">Table</xsl:with-param>
					</xsl:call-template>
				</xsl:with-param>
			</xsl:call-template>
		</xsl:variable>

		<xsl:choose>
			<xsl:when test="$displayType = 'numbered'">
				<xsl:apply-templates select="current()" mode="writeTableTitleNumbered">
					<xsl:with-param name="hasTitle" select="$hasTitle"/>
					<xsl:with-param name="autoNumber" select="$autoNumber"/>
					<xsl:with-param name="tableTitlePrefix" select="$tableTitlePrefix"/>
				</xsl:apply-templates>
			</xsl:when>
			<xsl:when test="$displayType = 'numbered-and-indent'">
				<xsl:apply-templates select="current()" mode="writeTableTitleNumbered">
					<xsl:with-param name="useListBlock" select="true()"/>
					<xsl:with-param name="hasTitle" select="$hasTitle"/>
					<xsl:with-param name="autoNumber" select="$autoNumber"/>
					<xsl:with-param name="tableTitlePrefix" select="$tableTitlePrefix"/>
				</xsl:apply-templates>
			</xsl:when>
			<xsl:when test="$displayType = 'numbered-with-chapter'">
				<xsl:apply-templates select="current()" mode="writeTableTitleNumberedChapter">
					<xsl:with-param name="hasTitle" select="$hasTitle"/>
					<xsl:with-param name="autoNumber" select="$autoNumber"/>
					<xsl:with-param name="tableTitlePrefix" select="$tableTitlePrefix"/>
				</xsl:apply-templates>
			</xsl:when>
			<xsl:when test="$displayType = 'fixtext'">
				<xsl:apply-templates select="current()" mode="writeTableTitleSimple">
					<xsl:with-param name="hasTitle" select="$hasTitle"/>
					<xsl:with-param name="autoNumber" select="$autoNumber"/>
					<xsl:with-param name="showFixText" select="true()"/>
					<xsl:with-param name="tableTitlePrefix" select="$tableTitlePrefix"/>
				</xsl:apply-templates>
			</xsl:when>
			<xsl:otherwise>
				<xsl:apply-templates select="current()" mode="writeTableTitleSimple">
					<xsl:with-param name="hasTitle" select="$hasTitle"/>
					<xsl:with-param name="autoNumber" select="$autoNumber"/>
					<xsl:with-param name="tableTitlePrefix" select="$tableTitlePrefix"/>
				</xsl:apply-templates>
			</xsl:otherwise>
		</xsl:choose>
	</xsl:template>

	<xsl:template match="table | table.NoBorder" mode="getDefaultDisplayType">simple</xsl:template>

	<xsl:template match="table | table.NoBorder" mode="writeTableTitleSimple">
		<xsl:param name="hasTitle" select="title != 'Title' and string-length(title) &gt; 0"/>
		<xsl:param name="showFixText" select="false()"/>
		<xsl:param name="tableTitlePrefix">Table</xsl:param>

		<xsl:variable name="showPrefix" select="$showFixText and not($tableTitlePrefix = 'NONE' or $tableTitlePrefix = 'none')"/>
		
		<xsl:if test="$showPrefix">
			<xsl:variable name="tablePrefix">
				<xsl:call-template name="translate">
					<xsl:with-param name="ID" select="$tableTitlePrefix"/>
				</xsl:call-template>
			</xsl:variable>

			<xsl:value-of select="$tablePrefix"/>
		</xsl:if>
		
		<xsl:if test="$hasTitle">
			<xsl:if test="$showPrefix">
				<xsl:text>: </xsl:text>
			</xsl:if>
			<xsl:apply-templates select="title"/>
		</xsl:if>
		
	</xsl:template>

	<!--<xsl:variable name="TABLE_COUNTER" select="list:new()"/>-->

	<xsl:template match="table | table.NoBorder" mode="writeTableTitleNumbered">
		<xsl:param name="useListBlock" select="false()"/>
		<xsl:param name="listSeparator">
			<xsl:if test="$language = 'fr'">
				<xsl:text> </xsl:text>
			</xsl:if>
			<xsl:call-template name="getTemplateVariableValue">
				<xsl:with-param name="name" select="'TABLE_TITLE_SEPARATOR'"/>
				<xsl:with-param name="defaultValue">:</xsl:with-param>
			</xsl:call-template>
		</xsl:param>
		<xsl:param name="nrPrefix"/>
		<xsl:param name="hasTitle" select="title != 'Title' and string-length(title) &gt; 0"/>
		<xsl:param name="autoNumber" select="not(following-sibling::TableDesc[1][@notAutoNumber = 'true'])"/>
		<xsl:param name="tableTitlePrefix">Table</xsl:param>

		<xsl:variable name="baseCounter" select="number(/*/Navigation/@incrementalTableCount)"/>

		<xsl:variable name="showPrefix" select="not($tableTitlePrefix = 'none')"/>
		
		<!--<xsl:if test="$autoNumber and $showPrefix">
			<xsl:variable name="add" select="list:add($TABLE_COUNTER, '1')"/>
		</xsl:if>-->
		<xsl:variable name="tableCount">
			<!--<xsl:choose>
				<xsl:when test="string($baseCounter) != 'NaN'">
					<xsl:value-of select="list:size($TABLE_COUNTER) + $baseCounter"/>
				</xsl:when>
				<xsl:otherwise>
					<xsl:value-of select="list:size($TABLE_COUNTER)"/>
				</xsl:otherwise>
			</xsl:choose>-->
			<xsl:value-of select="count(preceding::table[title != '' and title != 'Title' and @typ != 'MenuInst' and following-sibling::TableDesc[1][not(@glossary = 'true') and not(@notAutoNumber = 'true')]]) + 1"/>
		</xsl:variable>

		<xsl:choose>
			<xsl:when test="$useListBlock and $showPrefix">
				<xsl:variable name="TABLE_TITLE_INDENT">
					<xsl:call-template name="getTemplateVariableValue">
						<xsl:with-param name="name" select="concat('TABLE_TITLE_INDENT_', $language)"/>
						<xsl:with-param name="defaultValue">
							<xsl:call-template name="getTemplateVariableValue">
								<xsl:with-param name="name" select="'TABLE_TITLE_INDENT'"/>
								<xsl:with-param name="defaultValue">20mm</xsl:with-param>
							</xsl:call-template>
						</xsl:with-param>
					</xsl:call-template>
				</xsl:variable>
				<fo:list-block provisional-distance-between-starts="{$TABLE_TITLE_INDENT}">
					<fo:list-item>
						<fo:list-item-label end-indent="label-end()">
							<fo:block>
								<xsl:call-template name="translate">
									<xsl:with-param name="ID" select="$tableTitlePrefix"/>
								</xsl:call-template>
								<xsl:if test="$autoNumber">
									<xsl:value-of select="concat(' ', $nrPrefix, $tableCount)"/>
								</xsl:if>
								<xsl:if test="$hasTitle">
									<xsl:value-of select="$listSeparator"/>
								</xsl:if>
							</fo:block>
						</fo:list-item-label>
						<fo:list-item-body start-indent="body-start()">
							<fo:block>
								<xsl:if test="$hasTitle">
									<xsl:apply-templates select="title"/>
								</xsl:if>
							</fo:block>
						</fo:list-item-body>
					</fo:list-item>
				</fo:list-block>
			</xsl:when>
			<xsl:otherwise>
				<xsl:if test="$showPrefix">
					<xsl:call-template name="translate">
						<xsl:with-param name="ID" select="$tableTitlePrefix"/>
					</xsl:call-template>

					<xsl:if test="$autoNumber">
						<xsl:text> </xsl:text>
						<xsl:value-of select="concat($nrPrefix, $tableCount)"/>
					</xsl:if>
				</xsl:if>

				<xsl:if test="$hasTitle">
					<xsl:if test="$showPrefix">
						<xsl:value-of select="concat($listSeparator, ' ')"/>
					</xsl:if>
					<xsl:apply-templates select="title"/>
				</xsl:if>
			</xsl:otherwise>
		</xsl:choose>
	</xsl:template>

	<!--<xsl:variable name="CURRENT_TABLE_CHAPTER" select="list:new()"/>-->

	<xsl:template match="table | table.NoBorder" mode="getMainChapterNr">
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

	<xsl:template match="table | table.NoBorder" mode="writeTableTitleNumberedChapter">
		<xsl:param name="useListBlock" select="false()"/>
		<xsl:param name="separator">-</xsl:param>
		<xsl:param name="listSeparator">
			<xsl:if test="$language = 'fr'">
				<xsl:text> </xsl:text>
			</xsl:if>
			<xsl:call-template name="getTemplateVariableValue">
				<xsl:with-param name="name" select="'TABLE_TITLE_SEPARATOR'"/>
				<xsl:with-param name="defaultValue">:</xsl:with-param>
			</xsl:call-template>
		</xsl:param>
		<xsl:param name="hasTitle" select="title != 'Title' and string-length(title) &gt; 0"/>
		<xsl:param name="autoNumber" select="not(following-sibling::TableDesc[1][@notAutoNumber = 'true'])"/>
		<xsl:param name="tableTitlePrefix">Table</xsl:param>

		<xsl:variable name="showPrefix" select="not($tableTitlePrefix = 'none')"/>

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

		<!--<xsl:if test="$autoNumber and $showPrefix and string(list:contains($CURRENT_TABLE_CHAPTER, string($internalCurrChapt))) = 'false'">
			<xsl:variable name="remove" select="list:removeAllElements($TABLE_COUNTER)"/>
			<xsl:variable name="remove2" select="list:removeAllElements($CURRENT_TABLE_CHAPTER)"/>
			<xsl:variable name="add" select="list:add($CURRENT_TABLE_CHAPTER, string($internalCurrChapt))"/>
		</xsl:if>-->

		<xsl:choose>
			<xsl:when test="$useListBlock and $showPrefix">
				<xsl:variable name="TABLE_TITLE_INDENT">
					<xsl:call-template name="getTemplateVariableValue">
						<xsl:with-param name="name" select="concat('TABLE_TITLE_INDENT_', $language)"/>
						<xsl:with-param name="defaultValue">
							<xsl:call-template name="getTemplateVariableValue">
								<xsl:with-param name="name" select="'TABLE_TITLE_INDENT'"/>
								<xsl:with-param name="defaultValue">20mm</xsl:with-param>
							</xsl:call-template>
						</xsl:with-param>
					</xsl:call-template>
				</xsl:variable>
				<fo:list-block provisional-distance-between-starts="{$TABLE_TITLE_INDENT}">
					<fo:list-item>
						<fo:list-item-label end-indent="label-end()">
							<fo:block>
								<xsl:call-template name="translate">
									<xsl:with-param name="ID" select="$tableTitlePrefix"/>
								</xsl:call-template>
								<xsl:if test="$autoNumber">
									<xsl:text> </xsl:text>
									<xsl:if test="string-length($currChapt) &gt; 0">
										<xsl:value-of select="concat($currChapt, $separator)"/>
									</xsl:if>
									<!--<xsl:variable name="add" select="list:add($TABLE_COUNTER, '1')"/>
									<xsl:value-of select="list:size($TABLE_COUNTER)"/>-->
									<xsl:value-of select="count(preceding::table[title != '' and title != 'Title' and @typ != 'MenuInst' and following-sibling::TableDesc[1][not(@glossary = 'true') and not(@notAutoNumber = 'true')]]) + 1"/>
								</xsl:if>
								<xsl:if test="$hasTitle">
									<xsl:value-of select="concat($listSeparator, ' ')"/>
								</xsl:if>
							</fo:block>
						</fo:list-item-label>
						<fo:list-item-body start-indent="body-start()">
							<fo:block>
								<xsl:apply-templates select="title"/>
							</fo:block>
						</fo:list-item-body>
					</fo:list-item>
				</fo:list-block>
			</xsl:when>
			<xsl:otherwise>
				<xsl:if test="$showPrefix">
					<xsl:call-template name="translate">
						<xsl:with-param name="ID" select="$tableTitlePrefix"/>
					</xsl:call-template>

					<xsl:if test="$autoNumber">
						<xsl:text> </xsl:text>
						<xsl:if test="string-length($currChapt) &gt; 0">
							<xsl:value-of select="concat($currChapt, $separator)"/>
						</xsl:if>
						<!--<xsl:variable name="add" select="list:add($TABLE_COUNTER, '1')"/>
						<xsl:value-of select="list:size($TABLE_COUNTER)"/>-->
						<xsl:value-of select="count(preceding::table[title != '' and title != 'Title' and @typ != 'MenuInst' and following-sibling::TableDesc[1][not(@glossary = 'true') and not(@notAutoNumber = 'true')]]) + 1"/>
					</xsl:if>
				</xsl:if>

				<xsl:if test="$hasTitle">
					<xsl:if test="$showPrefix">
						<xsl:value-of select="concat($listSeparator, ' ')"/>
					</xsl:if>
					<xsl:apply-templates select="title"/>
				</xsl:if>
			</xsl:otherwise>
		</xsl:choose>
	</xsl:template>

	<xsl:template match="table | table.NoBorder">
		<xsl:param name="isInsideStartregion" select="false()"/>
		<xsl:param name="isInsideEndregion" select="false()"/>
		<xsl:param name="currentElement" select="current()"/>
		<xsl:apply-templates select="current()" mode="normal">
			<xsl:with-param name="isInsideStartregion" select="$isInsideStartregion"/>
			<xsl:with-param name="isInsideEndregion" select="$isInsideEndregion"/>
			<xsl:with-param name="currentElement" select="$currentElement"/>
		</xsl:apply-templates>
	</xsl:template>

	<xsl:template match="table | table.NoBorder" mode="normal">
		<xsl:param name="defaultType"/>
		<xsl:param name="isInsideStartregion"/>
		<xsl:param name="isInsideEndregion"/>
		<xsl:param name="currentElement"/>

		<xsl:variable name="tableAlign">
			<xsl:call-template name="getFormat">
				<xsl:with-param name="name">table</xsl:with-param>
				<xsl:with-param name="attributeName">text-align</xsl:with-param>
			</xsl:call-template>
		</xsl:variable>

		<xsl:variable name="isCentered" select="$tableAlign = 'center'"/>
		<xsl:variable name="isRight" select="$tableAlign = 'right'"/>

		<xsl:variable name="headColumns">
			<xsl:choose>
				<xsl:when test="number(@headColumns)">
					<xsl:value-of select="number(@headColumns)"/>
				</xsl:when>
				<xsl:otherwise>
					<xsl:value-of select="0"/>
				</xsl:otherwise>
			</xsl:choose>
		</xsl:variable>

		<xsl:variable name="tableType">
			<xsl:choose>
				<xsl:when test="name() = 'table.NoBorder'">NoBorder</xsl:when>
				<xsl:when test="string-length(@typ) = 0">
					<xsl:value-of select="$defaultType"/>
				</xsl:when>
				<xsl:when test="@typ = 'Normal' and string-length($defaultType) &gt; 0">
					<xsl:value-of select="$defaultType"/>
				</xsl:when>
				<xsl:otherwise>
					<xsl:value-of select="string(@typ)"/>
				</xsl:otherwise>
			</xsl:choose>
		</xsl:variable>

		<xsl:variable name="legacyFontSizeCalculation">
			<xsl:call-template name="getTemplateVariableValue">
				<xsl:with-param name="name">TABLE_LEGACY_FONT_SIZE_CALCULATION</xsl:with-param>
				<xsl:with-param name="defaultValue">false</xsl:with-param>
			</xsl:call-template>
		</xsl:variable>

		<xsl:variable name="tableFontSize">
			<xsl:choose>
				<xsl:when test="name() = 'table.NoBorder' and not($legacyFontSizeCalculation = 'true')">
					<xsl:call-template name="getFormat">
						<xsl:with-param name="name">table.nolines.cell</xsl:with-param>
						<xsl:with-param name="attributeName">font-size</xsl:with-param>
						<xsl:with-param name="defaultValue">
							<xsl:call-template name="getFormat">
								<xsl:with-param name="name">default</xsl:with-param>
								<xsl:with-param name="attributeName">font-size</xsl:with-param>
								<xsl:with-param name="defaultValue">9pt</xsl:with-param>
							</xsl:call-template>
						</xsl:with-param>
					</xsl:call-template>
				</xsl:when>
				<xsl:otherwise>
					<xsl:call-template name="getFormat">
						<xsl:with-param name="name">table.cell</xsl:with-param>
						<xsl:with-param name="attributeName">font-size</xsl:with-param>
						<xsl:with-param name="defaultValue">
							<xsl:call-template name="getFormat">
								<xsl:with-param name="name">default</xsl:with-param>
								<xsl:with-param name="attributeName">font-size</xsl:with-param>
								<xsl:with-param name="defaultValue">9pt</xsl:with-param>
							</xsl:call-template>
						</xsl:with-param>
					</xsl:call-template>
				</xsl:otherwise>
			</xsl:choose>
		</xsl:variable>

		<xsl:variable name="isHeadlineTable" select="parent::Headline"/>
		<xsl:variable name="isSublineTable" select="parent::Subline"/>
		<xsl:variable name="isFormatTable" select="$isHeadlineTable or $isSublineTable or $isInsideStartregion or $isInsideEndregion"/>

		<xsl:variable name="applyExcelTableFormat">
			<xsl:call-template name="getTemplateVariableValue">
				<xsl:with-param name="name" select="'APPLY_EXCEL_TABLE_FORMAT'"/>
				<xsl:with-param name="defaultValue">true</xsl:with-param>
			</xsl:call-template>
		</xsl:variable>

		<fo:block>
			<xsl:call-template name="addStyle">
				<xsl:with-param name="name">block-level-element</xsl:with-param>
			</xsl:call-template>
			<xsl:call-template name="addStyle">
				<xsl:with-param name="name">table.container</xsl:with-param>
			</xsl:call-template>
			<xsl:apply-templates select="current()" mode="writeCharacterizationInfo"/>
			<xsl:apply-templates select="current()" mode="writeTableTitle">
				<xsl:with-param name="position">top</xsl:with-param>
				<xsl:with-param name="isCentered" select="$isCentered"/>
				<xsl:with-param name="isRight" select="$isRight"/>
				<xsl:with-param name="isFormatTable" select="$isFormatTable"/>
			</xsl:apply-templates>

			<xsl:variable name="hasID" select="string-length(@ID) &gt; 0 and not($isHeadlineTable or $isSublineTable or $isInsideStartregion or $isInsideEndregion)"/>
			<xsl:if test="$hasID">
				<xsl:apply-templates select="current()" mode="writeDestination"/>
			</xsl:if>

			<fo:table table-layout="fixed" border-collapse="collapse" width="100%">
				<xsl:apply-templates select="current()" mode="applyWidowOrphans">
					<xsl:with-param name="name">table</xsl:with-param>
				</xsl:apply-templates>
				<xsl:call-template name="addStyle">
					<xsl:with-param name="name">table</xsl:with-param>
				</xsl:call-template>
				<xsl:variable name="orphans">
					<xsl:call-template name="getFormat">
						<xsl:with-param name="name">table</xsl:with-param>
						<xsl:with-param name="attributeName">orphans</xsl:with-param>
					</xsl:call-template>
				</xsl:variable>
				<xsl:if test="string(number($orphans)) != 'NaN'">
					<xsl:attribute name="fox:orphan-content-limit">
						<xsl:value-of select="concat($orphans, 'em')"/>
					</xsl:attribute>
				</xsl:if>
				<xsl:variable name="widows">
					<xsl:call-template name="getFormat">
						<xsl:with-param name="name">table</xsl:with-param>
						<xsl:with-param name="attributeName">widows</xsl:with-param>
					</xsl:call-template>
				</xsl:variable>
				<xsl:if test="string(number($widows)) != 'NaN'">
					<xsl:attribute name="fox:widow-content-limit">
						<xsl:value-of select="concat($widows, 'em')"/>
					</xsl:attribute>
				</xsl:if>
				<xsl:if test="parent::tableCell">
					<xsl:call-template name="addStyle">
						<xsl:with-param name="name">table.cell.table</xsl:with-param>
					</xsl:call-template>
				</xsl:if>
				<xsl:if test="$isHeadlineTable">
					<xsl:call-template name="addStyle">
						<xsl:with-param name="name">table.headernote</xsl:with-param>
					</xsl:call-template>
					<xsl:call-template name="addStyle">
						<xsl:with-param name="name" select="concat('table.headernote.', ancestor::StandardPageRegion[1]/@type)"/>
					</xsl:call-template>
				</xsl:if>
				<xsl:if test="$isSublineTable">
					<xsl:call-template name="addStyle">
						<xsl:with-param name="name">table.footer</xsl:with-param>
					</xsl:call-template>
					<xsl:call-template name="addStyle">
						<xsl:with-param name="name" select="concat('table.footer.', ancestor::StandardPageRegion[1]/@type)"/>
					</xsl:call-template>
				</xsl:if>
				<xsl:if test="$isInsideStartregion">
					<xsl:call-template name="addStyle">
						<xsl:with-param name="name">table.startregion</xsl:with-param>
						<xsl:with-param name="currentElement" select="$currentElement"/>
					</xsl:call-template>
					<xsl:call-template name="addStyle">
						<xsl:with-param name="name" select="concat('table.startregion.', ancestor::StandardPageRegion[1]/@type)"/>
					</xsl:call-template>
				</xsl:if>
				<xsl:if test="$isInsideEndregion">
					<xsl:call-template name="addStyle">
						<xsl:with-param name="name">table.endregion</xsl:with-param>
						<xsl:with-param name="currentElement" select="$currentElement"/>
					</xsl:call-template>
					<xsl:call-template name="addStyle">
						<xsl:with-param name="name" select="concat('table.endregion.', ancestor::StandardPageRegion[1]/@type)"/>
					</xsl:call-template>
				</xsl:if>
				<xsl:if test="$hasID">
					<xsl:attribute name="id">
						<xsl:value-of select="@ID"/>
					</xsl:attribute>
				</xsl:if>
				<xsl:if test="string-length(following-sibling::TableDesc[1]/@formatRef) &gt; 0">
					<xsl:call-template name="addStyle">
						<xsl:with-param name="name" select="following-sibling::TableDesc[1]/@formatRef"/>
					</xsl:call-template>
				</xsl:if>
				<xsl:if test="following-sibling::TableDesc[1]/@format">
					<xsl:call-template name="addStyle">
						<xsl:with-param name="name" select="concat('table.', following-sibling::TableDesc[1]/@format)"/>
					</xsl:call-template>
				</xsl:if>

				<xsl:variable name="repeatTableFooter">
					<xsl:call-template name="getTemplateVariableValue">
						<xsl:with-param name="name" select="'REPEAT_TABLE_FOOTER'"/>
						<xsl:with-param name="defaultValue">true</xsl:with-param>
					</xsl:call-template>
				</xsl:variable>
				<xsl:if test="$repeatTableFooter = 'false'">
					<xsl:attribute name="table-omit-footer-at-break">true</xsl:attribute>
				</xsl:if>

				<xsl:if test="$isCentered or $isRight">
					<xsl:attribute name="text-align">left</xsl:attribute>
					<fo:table-column column-width="proportional-column-width(1)"/>
				</xsl:if>

				<xsl:variable name="colCount" select="count(following-sibling::TableDesc[1]/TableColSpec)"/>

				<xsl:variable name="deletedCorrection" select="sum(following-sibling::TableDesc[1]/TableColSpec[@Changed = 'DELETED']/@width)"/>
				<xsl:for-each select="following-sibling::TableDesc[1]/TableColSpec">
					<fo:table-column>
						<xsl:attribute name="column-width">
							<xsl:choose>
								<xsl:when test="@width = '*'">proportional-column-width(1)</xsl:when>
								<xsl:when test="string(number(@width)) = 'NaN'">
									<xsl:value-of select="translate(@width, ',', '.')"/>
								</xsl:when>
								<xsl:when test="$deletedCorrection &gt; 0">
									<xsl:value-of select="concat(@width - (@width div sum(parent::*/TableColSpec/@width[string(number(.)) != 'NaN'])) * $deletedCorrection, '%')"/>
								</xsl:when>
								<xsl:otherwise>
									<xsl:value-of select="concat(@width, '%')"/>
								</xsl:otherwise>
							</xsl:choose>
						</xsl:attribute>
					</fo:table-column>
				</xsl:for-each>

				<xsl:if test="$isCentered">
					<fo:table-column column-width="proportional-column-width(1)"/>
				</xsl:if>

				<xsl:apply-templates select="tableHead">
					<xsl:with-param name="fontSizeModifier" select="string(@fontSizeModifier)"/>
					<xsl:with-param name="typ" select="$tableType"/>
					<xsl:with-param name="headColumns" select="$headColumns"/>
					<xsl:with-param name="isCentered" select="$isCentered"/>
					<xsl:with-param name="isRight" select="$isRight"/>
					<xsl:with-param name="colCount" select="$colCount"/>
					<xsl:with-param name="tableFontSize" select="$tableFontSize"/>
					<xsl:with-param name="orphans" select="$orphans"/>
					<xsl:with-param name="widows" select="$widows"/>
					<xsl:with-param name="rowCountInclHeader" select="count(tableHead/tableRow | tableStandard/tableRow)"/>
					<xsl:with-param name="doApplyExcelTableFormat" select="not($applyExcelTableFormat = 'false')"/>
				</xsl:apply-templates>

				<xsl:apply-templates select="tableStandard">
					<xsl:with-param name="fontSizeModifier" select="string(@fontSizeModifier)"/>
					<xsl:with-param name="typ" select="$tableType"/>
					<xsl:with-param name="headColumns" select="$headColumns"/>
					<xsl:with-param name="isCentered" select="$isCentered"/>
					<xsl:with-param name="isRight" select="$isRight"/>
					<xsl:with-param name="colCount" select="$colCount"/>
					<xsl:with-param name="tableFontSize" select="$tableFontSize"/>
					<xsl:with-param name="orphans" select="$orphans"/>
					<xsl:with-param name="widows" select="$widows"/>
					<xsl:with-param name="rowCountInclHeader" select="count(tableHead/tableRow | tableStandard/tableRow)"/>
					<xsl:with-param name="doApplyExcelTableFormat" select="not($applyExcelTableFormat = 'false')"/>
				</xsl:apply-templates>
				
				<xsl:apply-templates select="current()" mode="writeTableTitle">
					<xsl:with-param name="position">bottom</xsl:with-param>
					<xsl:with-param name="isCentered" select="$isCentered"/>
					<xsl:with-param name="isRight" select="$isRight"/>
					<xsl:with-param name="isFormatTable" select="$isFormatTable"/>
				</xsl:apply-templates>
			</fo:table>
		</fo:block>

		<xsl:apply-templates select="current()" mode="writeTableTitle">
			<xsl:with-param name="position">below</xsl:with-param>
			<xsl:with-param name="isCentered" select="$isCentered"/>
			<xsl:with-param name="isRight" select="$isRight"/>
			<xsl:with-param name="isFormatTable" select="$isFormatTable"/>
		</xsl:apply-templates>

	</xsl:template>

	<xsl:template match="tableHead">
		<xsl:param name="fontSizeModifier"/>
		<xsl:param name="typ"/>
		<xsl:param name="headColumns"/>
		<xsl:param name="isCentered"/>
		<xsl:param name="isRight"/>
		<xsl:param name="colCount"/>
		<xsl:param name="tableFontSize"/>
		<xsl:param name="orphans"/>
		<xsl:param name="widows"/>
		<xsl:param name="rowCountInclHeader"/>
		<xsl:param name="doApplyExcelTableFormat"/>

		<xsl:variable name="visible">
			<xsl:call-template name="getFormat">
				<xsl:with-param name="name">table.header.container</xsl:with-param>
				<xsl:with-param name="attributeName">visibility</xsl:with-param>
			</xsl:call-template>
		</xsl:variable>

		<xsl:if test="not($visible = 'hidden')">
			<fo:table-header>
				<xsl:call-template name="addStyle">
					<xsl:with-param name="name">table.header.container</xsl:with-param>
				</xsl:call-template>
				<xsl:apply-templates>
					<xsl:with-param name="fontSizeModifier" select="$fontSizeModifier"/>
					<xsl:with-param name="typ" select="$typ"/>
					<xsl:with-param name="headColumns" select="$headColumns"/>
					<xsl:with-param name="isTableHead" select="1 = 1"/>
					<xsl:with-param name="isCentered" select="$isCentered"/>
					<xsl:with-param name="isRight" select="$isRight"/>
					<xsl:with-param name="rowCount" select="count(tableRow)"/>
					<xsl:with-param name="colCount" select="$colCount"/>
					<xsl:with-param name="tableFontSize" select="$tableFontSize"/>
					<xsl:with-param name="orphans" select="$orphans"/>
					<xsl:with-param name="widows" select="$widows"/>
					<xsl:with-param name="rowCountInclHeader" select="$rowCountInclHeader"/>
					<xsl:with-param name="doApplyExcelTableFormat" select="$doApplyExcelTableFormat"/>
				</xsl:apply-templates>
			</fo:table-header>
		</xsl:if>
	</xsl:template>

	<xsl:template match="tableStandard">
		<xsl:param name="fontSizeModifier"/>
		<xsl:param name="typ"/>
		<xsl:param name="headColumns"/>
		<xsl:param name="isCentered"/>
		<xsl:param name="isRight"/>
		<xsl:param name="colCount"/>
		<xsl:param name="tableFontSize"/>
		<xsl:param name="orphans"/>
		<xsl:param name="widows"/>
		<xsl:param name="rowCountInclHeader"/>
		<xsl:param name="doApplyExcelTableFormat"/>

		<fo:table-body>
			<xsl:call-template name="addStyle">
				<xsl:with-param name="name">table.body</xsl:with-param>
			</xsl:call-template>
			<xsl:apply-templates>
				<xsl:with-param name="fontSizeModifier" select="$fontSizeModifier"/>
				<xsl:with-param name="typ" select="$typ"/>
				<xsl:with-param name="headColumns" select="$headColumns"/>
				<xsl:with-param name="isCentered" select="$isCentered"/>
				<xsl:with-param name="isRight" select="$isRight"/>
				<xsl:with-param name="rowCount" select="count(tableRow)"/>
				<xsl:with-param name="colCount" select="$colCount"/>
				<xsl:with-param name="tableFontSize" select="$tableFontSize"/>
				<xsl:with-param name="orphans" select="$orphans"/>
				<xsl:with-param name="widows" select="$widows"/>
				<xsl:with-param name="rowCountInclHeader" select="$rowCountInclHeader"/>
				<xsl:with-param name="doApplyExcelTableFormat" select="$doApplyExcelTableFormat"/>
			</xsl:apply-templates>
		</fo:table-body>
	</xsl:template>

	<xsl:template match="tableRow">
		<xsl:param name="fontSizeModifier"/>
		<xsl:param name="typ"/>
		<xsl:param name="headColumns"/>
		<xsl:param name="isTableHead"/>
		<xsl:param name="isCentered"/>
		<xsl:param name="isRight"/>
		<xsl:param name="rowCount"/>
		<xsl:param name="rowCountInclHeader"/>
		<xsl:param name="colCount"/>
		<xsl:param name="tableFontSize"/>
		<xsl:param name="orphans"/>
		<xsl:param name="widows"/>
		<xsl:param name="doApplyExcelTableFormat"/>

		<xsl:variable name="rowHeight">
			<xsl:call-template name="getFormat">
				<xsl:with-param name="name">table.row</xsl:with-param>
				<xsl:with-param name="attributeName">height</xsl:with-param>
				<xsl:with-param name="defaultValue" select="$tableFontSize"/>
			</xsl:call-template>
		</xsl:variable>

		<xsl:variable name="currentRow" select="count(preceding-sibling::tableRow)"/>
		<xsl:variable name="currentRowInclHeader" select="$currentRow + count(parent::tableStandard/preceding-sibling::tableHead/tableRow)"/>

		<xsl:apply-templates select="current()" mode="writeCharacterizationInfoRow">
			<xsl:with-param name="colCount" select="$colCount"/>
		</xsl:apply-templates>
		
		<fo:table-row>
			<xsl:if test="string(number($orphans)) != 'NaN' and $orphans &gt; $currentRowInclHeader">
				<!-- don't set keep-with-previous on first row in table body because 
				this causes a keep condition with the content previous to the table (seems to a FOP bug) -->
				<xsl:if test="$currentRowInclHeader &gt; 0 and $currentRow &gt; 0">
					<xsl:attribute name="keep-with-previous">always</xsl:attribute>
				</xsl:if>
				<xsl:attribute name="keep-together.within-page">20</xsl:attribute>
				<xsl:attribute name="keep-together.within-column">20</xsl:attribute>
			</xsl:if>
			<xsl:if test="string(number($widows)) != 'NaN' and $widows &gt; ($rowCountInclHeader - ($currentRowInclHeader + 1))">
				<xsl:if test="not($rowCountInclHeader = ($currentRowInclHeader + 1))">
					<xsl:attribute name="keep-with-next">always</xsl:attribute>
				</xsl:if>
				<xsl:attribute name="keep-together.within-page">20</xsl:attribute>
				<xsl:attribute name="keep-together.within-column">20</xsl:attribute>
			</xsl:if>
			<xsl:call-template name="addStyle">
				<xsl:with-param name="name">table.row</xsl:with-param>
			</xsl:call-template>
			<xsl:choose>
				<xsl:when test="string-length($fontSizeModifier) &gt; 0">
					<xsl:attribute name="height">
						<xsl:value-of select="concat($rowHeight, '+', $fontSizeModifier, 'pt')"/>
					</xsl:attribute>
				</xsl:when>
				<xsl:otherwise>
					<xsl:attribute name="height">
						<xsl:value-of select="$rowHeight"/>
					</xsl:attribute>
				</xsl:otherwise>
			</xsl:choose>

			<xsl:if test="$doApplyExcelTableFormat and @height">
				<xsl:attribute name="height">
					<xsl:value-of select="concat(@height * 0.9, 'pt')"/>
				</xsl:attribute>
			</xsl:if>
			<xsl:if test="string-length(@level) &gt; 0">
				<xsl:call-template name="addStyle">
					<xsl:with-param name="name" select="concat('table.row.level', @level)"/>
				</xsl:call-template>
			</xsl:if>
			<xsl:if test="string-length(@format) &gt; 0">
				<xsl:call-template name="addStyle">
					<xsl:with-param name="name" select="@format"/>
				</xsl:call-template>
			</xsl:if>
			<xsl:apply-templates select="current()" mode="setCustomTableAttributes"/>

			<xsl:apply-templates select="current()" mode="writeCharacterizationInfo">
				<xsl:with-param name="showContent" select="false()"/>
			</xsl:apply-templates>

			<xsl:if test="$isCentered or $isRight">
				<fo:table-cell>
					<fo:block></fo:block>
				</fo:table-cell>
			</xsl:if>

			<xsl:apply-templates>
				<xsl:with-param name="fontSizeModifier" select="$fontSizeModifier"/>
				<xsl:with-param name="typ" select="$typ"/>
				<xsl:with-param name="currentRow" select="$currentRow"/>
				<xsl:with-param name="currentRowInclHeader" select="$currentRowInclHeader"/>
				<xsl:with-param name="headColumns" select="$headColumns"/>
				<xsl:with-param name="isTableHead" select="$isTableHead"/>
				<xsl:with-param name="rowCount" select="$rowCount"/>
				<xsl:with-param name="colCount" select="$colCount"/>
				<xsl:with-param name="isLastRow" select="not(following-sibling::tableRow) and not($isTableHead)"/>
				<xsl:with-param name="isFirstRow" select="$currentRow = 0 and ($isTableHead or not(parent::tableStandard/preceding-sibling::tableHead/tableRow))"/>
				<xsl:with-param name="tableFontSize" select="$tableFontSize"/>
				<xsl:with-param name="doApplyExcelTableFormat" select="$doApplyExcelTableFormat"/>
			</xsl:apply-templates>
			<xsl:if test="$isCentered">
				<fo:table-cell>
					<fo:block></fo:block>
				</fo:table-cell>
			</xsl:if>
		</fo:table-row>
	</xsl:template>

	<xsl:template match="*" mode="setCustomTableAttributes"/>

	<xsl:template match="tableCell">
		<xsl:param name="fontSizeModifier"/>
		<xsl:param name="typ"/>
		<xsl:param name="currentRow"/>
		<xsl:param name="currentRowInclHeader"/>
		<xsl:param name="headColumns"/>
		<xsl:param name="isTableHead"/>
		<xsl:param name="rowCount"/>
		<xsl:param name="colCount"/>
		<xsl:param name="isLastRow"/>
		<xsl:param name="isFirstRow"/>
		<xsl:param name="tableFontSize"/>
		<xsl:param name="doApplyExcelTableFormat"/>

		<xsl:variable name="headerRowsCount" select="$currentRowInclHeader - $currentRow"/>

		<xsl:if test="not(@Changed = 'DELETED')
				or (string-length(@idx) &gt; 0 and not(parent::tableRow/parent::*/tableRow/tableCell[@idx = current()/@idx and not(@Changed = 'DELETED')])
					and not(count(preceding-sibling::tableCell[not(@hstraddle)]) + sum(preceding-sibling::tableCell/@hstraddle) &gt;= $colCount))">
			<xsl:variable name="currentColPre" select="count(preceding-sibling::tableCell[not(@hstraddle)]) + sum(preceding-sibling::tableCell/@hstraddle) + 1"/>
			<xsl:variable name="currentCol">
				<xsl:choose>
					<xsl:when test="@idx">
						<xsl:value-of select="@idx"/>
					</xsl:when>
					<xsl:when test="parent::tableRow/preceding-sibling::tableRow
							  [tableCell[position() &lt;= $currentColPre]/@morerows + count(preceding-sibling::tableRow) &gt;= $currentRow]">
						<xsl:value-of select="$currentColPre - 1 + count(parent::tableRow/preceding-sibling::tableRow
							  [tableCell[position() &lt;= $currentColPre]/@morerows + count(preceding-sibling::tableRow) &gt;= $currentRow]/tableCell[position() &lt;= $currentColPre and @morerows and not(@hstraddle)])
									   + sum(parent::tableRow/preceding-sibling::tableRow
							  [tableCell[position() &lt;= $currentColPre]/@morerows + count(preceding-sibling::tableRow) &gt;= $currentRow]/tableCell[position() &lt;= $currentColPre and @morerows]/@hstraddle)"/>
					</xsl:when>
					<xsl:otherwise>
						<xsl:value-of select="$currentColPre - 1"/>
					</xsl:otherwise>
				</xsl:choose>
			</xsl:variable>

			<xsl:variable name="currentColAndMerge">
				<xsl:choose>
					<xsl:when test="@hstraddle">
						<xsl:value-of select="$currentCol + @hstraddle"/>
					</xsl:when>
					<xsl:otherwise>
						<xsl:value-of select="$currentCol + 1"/>
					</xsl:otherwise>
				</xsl:choose>
			</xsl:variable>
			<xsl:variable name="isLastCol" select="$currentColAndMerge = $colCount"/>
			<xsl:variable name="isFirstCol" select="$currentCol = 0"/>

			<fo:table-cell>
				<xsl:apply-templates select="current()" mode="setCustomTableAttributes">
					<xsl:with-param name="defaultAttributes" select="true()"/>
					<xsl:with-param name="currentCol" select="$currentCol"/>
				</xsl:apply-templates>

				<xsl:if test="@hstraddle">
					<xsl:attribute name="number-columns-spanned">
						<xsl:value-of select="@hstraddle"/>
					</xsl:attribute>
				</xsl:if>

				<xsl:if test="@vstraddle">
					<xsl:attribute name="number-rows-spanned">
						<xsl:value-of select="@vstraddle"/>
					</xsl:attribute>
				</xsl:if>

				<xsl:choose>
					<xsl:when test="@valign='top'">
						<xsl:attribute name="display-align">before</xsl:attribute>
					</xsl:when>
					<xsl:when test="@valign='middle'">
						<xsl:attribute name="display-align">center</xsl:attribute>
					</xsl:when>
					<xsl:when test="@valign='bottom'">
						<xsl:attribute name="display-align">after</xsl:attribute>
					</xsl:when>
				</xsl:choose>

				<xsl:variable name="level" select="string(parent::*/@level | @level)"/>

				<xsl:choose>
					<xsl:when test="not($typ = 'NoBorder')">
						<xsl:call-template name="addStyle">
							<xsl:with-param name="name">table.cell</xsl:with-param>
						</xsl:call-template>

						<xsl:if test="string-length($level) &gt; 0">
							<xsl:call-template name="addStyle">
								<xsl:with-param name="name" select="concat('table.cell.level', $level)"/>
							</xsl:call-template>
							<xsl:if test="$isFirstCol">
								<xsl:call-template name="addStyle">
									<xsl:with-param name="name" select="concat('table.cell.firstcolumn.level', $level)"/>
								</xsl:call-template>
							</xsl:if>
						</xsl:if>

						<xsl:if test="$isFirstCol">
							<xsl:call-template name="addStyle">
								<xsl:with-param name="name">table.cell.firstcolumn</xsl:with-param>
							</xsl:call-template>
						</xsl:if>
						<xsl:if test="$isFirstRow">
							<xsl:call-template name="addStyle">
								<xsl:with-param name="name">table.cell.firstrow</xsl:with-param>
							</xsl:call-template>
						</xsl:if>
						<xsl:if test="$isLastRow or (@morerows and ($rowCount - ($currentRow + 1)) = @morerows)">
							<xsl:call-template name="addStyle">
								<xsl:with-param name="name">table.cell.lastrow</xsl:with-param>
							</xsl:call-template>
						</xsl:if>
						<xsl:if test="$isLastCol">
							<xsl:call-template name="addStyle">
								<xsl:with-param name="name">table.cell.lastcolumn</xsl:with-param>
							</xsl:call-template>
						</xsl:if>
						<xsl:choose>
							<xsl:when test="$currentRowInclHeader mod 2 = 1">
								<xsl:call-template name="addStyle">
									<xsl:with-param name="name">table.cell.even</xsl:with-param>
								</xsl:call-template>
							</xsl:when>
							<xsl:otherwise>
								<xsl:call-template name="addStyle">
									<xsl:with-param name="name">table.cell.odd</xsl:with-param>
								</xsl:call-template>
							</xsl:otherwise>
						</xsl:choose>
						<xsl:choose>
							<xsl:when test="$currentCol mod 2 = 1">
								<xsl:call-template name="addStyle">
									<xsl:with-param name="name">table.cell.evencolumn</xsl:with-param>
								</xsl:call-template>
							</xsl:when>
							<xsl:otherwise>
								<xsl:call-template name="addStyle">
									<xsl:with-param name="name">table.cell.oddcolumn</xsl:with-param>
								</xsl:call-template>
							</xsl:otherwise>
						</xsl:choose>
						<xsl:variable name="isVerticalTableHeader" select="($headColumns &gt; $currentCol) 
									  or ($typ = 'Pmg' and $currentCol = 0)
									  or ($currentCol = 0 and $typ = 'Matrix')"/>
						<xsl:choose>
							<xsl:when test="$isTableHead and not($typ = 'Pmg')">
								<xsl:call-template name="addStyle">
									<xsl:with-param name="name">table.header</xsl:with-param>
								</xsl:call-template>
								<xsl:call-template name="addStyle">
									<xsl:with-param name="name">table.header.horizontal</xsl:with-param>
								</xsl:call-template>
								<xsl:if test="$isFirstCol and $isFirstRow and $isVerticalTableHeader">
									<xsl:call-template name="addStyle">
										<xsl:with-param name="name">table.header.firstcell</xsl:with-param>
									</xsl:call-template>
								</xsl:if>
							</xsl:when>
							<xsl:otherwise>
								<xsl:choose>
									<xsl:when test="$isVerticalTableHeader">

										<xsl:call-template name="addStyle">
											<xsl:with-param name="name">table.header</xsl:with-param>
										</xsl:call-template>
										<xsl:call-template name="addStyle">
											<xsl:with-param name="name">table.header.vertical</xsl:with-param>
										</xsl:call-template>
									</xsl:when>
									<xsl:when test="starts-with($typ, 'Alternate1')
											  and (($headerRowsCount &gt; 0 and $currentRow mod 2 = 0) or ($headerRowsCount = 0 and $currentRow mod 2 = 1))">
										<xsl:call-template name="addStyle">
											<xsl:with-param name="name">table.cell.alternate</xsl:with-param>
										</xsl:call-template>
									</xsl:when>
									<xsl:when test="starts-with($typ, 'Alternate2')
											  and (($headerRowsCount &gt; 0 and $currentRow mod 2 = 1) or ($headerRowsCount = 0 and $currentRow mod 2 = 0))">
										<xsl:call-template name="addStyle">
											<xsl:with-param name="name">table.cell.alternate</xsl:with-param>
										</xsl:call-template>
									</xsl:when>
								</xsl:choose>
							</xsl:otherwise>
						</xsl:choose>
					</xsl:when>
					<xsl:otherwise>
						<xsl:call-template name="addStyle">
							<xsl:with-param name="name">table.nolines.cell</xsl:with-param>
						</xsl:call-template>
						<xsl:if test="string-length($level) &gt; 0">
							<xsl:call-template name="addStyle">
								<xsl:with-param name="name" select="concat('table.nolines.level', $level)"/>
							</xsl:call-template>
						</xsl:if>
						<xsl:if test="$isFirstRow">
							<xsl:call-template name="addStyle">
								<xsl:with-param name="name">table.nolines.cell.firstrow</xsl:with-param>
							</xsl:call-template>
						</xsl:if>
						<xsl:if test="$isLastRow or (@morerows and ($rowCount - ($currentRow + 1)) = @morerows)">
							<xsl:call-template name="addStyle">
								<xsl:with-param name="name">table.nolines.cell.lastrow</xsl:with-param>
							</xsl:call-template>
						</xsl:if>
						<xsl:if test="$isFirstCol">
							<xsl:call-template name="addStyle">
								<xsl:with-param name="name">table.nolines.cell.firstcolumn</xsl:with-param>
							</xsl:call-template>
						</xsl:if>
						<xsl:if test="$isLastCol and string-length(@hstraddle) = 0">
							<xsl:call-template name="addStyle">
								<xsl:with-param name="name">table.nolines.cell.lastcolumn</xsl:with-param>
							</xsl:call-template>
						</xsl:if>
						<xsl:choose>
							<xsl:when test="$currentRowInclHeader mod 2 = 1">
								<xsl:call-template name="addStyle">
									<xsl:with-param name="name">table.nolines.cell.even</xsl:with-param>
								</xsl:call-template>
							</xsl:when>
							<xsl:otherwise>
								<xsl:call-template name="addStyle">
									<xsl:with-param name="name">table.nolines.cell.odd</xsl:with-param>
								</xsl:call-template>
							</xsl:otherwise>
						</xsl:choose>
						<xsl:choose>
							<xsl:when test="$currentCol mod 2 = 1">
								<xsl:call-template name="addStyle">
									<xsl:with-param name="name">table.nolines.cell.oddcolumn</xsl:with-param>
								</xsl:call-template>
							</xsl:when>
							<xsl:otherwise>
								<xsl:call-template name="addStyle">
									<xsl:with-param name="name">table.nolines.cell.evencolumn</xsl:with-param>
								</xsl:call-template>
							</xsl:otherwise>
						</xsl:choose>
						<xsl:choose>
							<xsl:when test="$isTableHead">
								<xsl:call-template name="addStyle">
									<xsl:with-param name="name">table.nolines.header</xsl:with-param>
								</xsl:call-template>
								<xsl:call-template name="addStyle">
									<xsl:with-param name="name">table.nolines.header.horizontal</xsl:with-param>
								</xsl:call-template>
							</xsl:when>
							<xsl:when test="$headColumns &gt; $currentCol">
								<xsl:call-template name="addStyle">
									<xsl:with-param name="name">table.nolines.header</xsl:with-param>
								</xsl:call-template>
								<xsl:call-template name="addStyle">
									<xsl:with-param name="name">table.nolines.header.vertical</xsl:with-param>
								</xsl:call-template>
							</xsl:when>
						</xsl:choose>
					</xsl:otherwise>
				</xsl:choose>

				<xsl:if test="not($isFirstRow) and not($isLastRow)">
					<xsl:call-template name="addStyle">
						<xsl:with-param name="name">table.cell.innerrow</xsl:with-param>
					</xsl:call-template>
				</xsl:if>

				<xsl:if test="not($isFirstCol) and not($isLastCol)">
					<xsl:call-template name="addStyle">
						<xsl:with-param name="name">table.cell.innercol</xsl:with-param>
					</xsl:call-template>
				</xsl:if>

				<xsl:if test="string-length(@align) &gt; 0">
					<xsl:attribute name="text-align">
						<xsl:value-of select="@align"/>
					</xsl:attribute>
				</xsl:if>

				<xsl:if test="$doApplyExcelTableFormat">
					<xsl:copy-of select="@*[starts-with(name(), 'border')] | @font-weight | @color"/>

					<xsl:if test="@bgColor">
						<xsl:attribute name="background-color">
							<xsl:value-of select="@bgColor"/>
						</xsl:attribute>
					</xsl:if>
				</xsl:if>

				<xsl:if test="parent::tableRow/@Changed and not(@Changed)">
					<xsl:attribute name="background-color">
						<xsl:choose>
							<xsl:when test="parent::tableRow/@Changed = 'UPDATED'">#fdf636</xsl:when>
							<xsl:when test="parent::tableRow/@Changed = 'INSERTED'">#8efe5d</xsl:when>
							<xsl:when test="parent::tableRow/@Changed = 'DELETED'">#f35555</xsl:when>
							<xsl:otherwise>#FFFFFF</xsl:otherwise>
						</xsl:choose>
					</xsl:attribute>
				</xsl:if>

				<xsl:apply-templates select="current()" mode="setCustomTableAttributes">
					<xsl:with-param name="currentCol" select="$currentCol"/>
				</xsl:apply-templates>

				<xsl:variable name="hasFormatRef" select="string-length(formatRef/@formatRef) &gt; 0"/>

				<xsl:variable name="refOrient">
					<xsl:apply-templates select="current()" mode="getCellFormat">
						<xsl:with-param name="attributeName">reference-orientation</xsl:with-param>
						<xsl:with-param name="hasFormatRef" select="$hasFormatRef"/>
						<xsl:with-param name="isTableHead" select="$isTableHead"/>
						<xsl:with-param name="typ" select="$typ"/>
					</xsl:apply-templates>
				</xsl:variable>

				<xsl:variable name="writingMode">
					<xsl:apply-templates select="current()" mode="getCellFormat">
						<xsl:with-param name="attributeName">writing-mode</xsl:with-param>
						<xsl:with-param name="hasFormatRef" select="$hasFormatRef"/>
						<xsl:with-param name="isTableHead" select="$isTableHead"/>
						<xsl:with-param name="typ" select="$typ"/>
					</xsl:apply-templates>
				</xsl:variable>

				<xsl:if test="@format">
					<xsl:call-template name="addStyle">
						<xsl:with-param name="name" select="concat('table.cell.', @format)"/>
					</xsl:call-template>
				</xsl:if>

				<xsl:if test="not(@notApplyTableFontSize) and string-length($fontSizeModifier) &gt; 0 and number($fontSizeModifier)">
					<xsl:attribute name="font-size">
						<xsl:value-of select="concat($tableFontSize, '+', $fontSizeModifier, 'pt')"/>
					</xsl:attribute>
				</xsl:if>

				<xsl:if test="$doApplyExcelTableFormat">
					<xsl:copy-of select="@font-size"/>
				</xsl:if>

				<xsl:choose>
					<xsl:when test="@rotate = '90' or @rotate = '-90'">
						<fo:block-container reference-orientation="{number(@rotate)}">
							<xsl:choose>
								<xsl:when test="@vstraddle &gt; 1">
									<xsl:variable name="vstraddle" select="@vstraddle"/>
									<xsl:variable name="rowHeightSum" select="parent::tableRow/@height + sum(parent::tableRow/following-sibling::tableRow[position() &lt; $vstraddle]/@height)"/>
									<xsl:variable name="cellMergeAutoHeight" select="@vstraddle * 10"/>
									<xsl:attribute name="width">
										<xsl:choose>
											<xsl:when test="$rowHeightSum &gt; $cellMergeAutoHeight">
												<xsl:value-of select="concat($rowHeightSum, 'pt')"/>
											</xsl:when>
											<xsl:otherwise>
												<xsl:value-of select="concat($cellMergeAutoHeight, 'pt')"/>
											</xsl:otherwise>
										</xsl:choose>
									</xsl:attribute>
								</xsl:when>
								<xsl:when test="parent::tableRow/@height">
									<xsl:attribute name="width">
										<xsl:value-of select="concat(parent::tableRow/@height * 0.8, 'pt')"/>
									</xsl:attribute>
								</xsl:when>
							</xsl:choose>
							<xsl:apply-templates>
								<xsl:with-param name="insideTableCell">true</xsl:with-param>
							</xsl:apply-templates>
						</fo:block-container>
					</xsl:when>
					<xsl:when test="number($refOrient)">
						<xsl:apply-templates select="formatRef"/>
						<fo:block-container reference-orientation="{$refOrient}">
							<xsl:variable name="refHeight">
								<xsl:apply-templates select="current()" mode="getCellFormat">
									<xsl:with-param name="attributeName">height</xsl:with-param>
									<xsl:with-param name="hasFormatRef" select="$hasFormatRef"/>
									<xsl:with-param name="isTableHead" select="$isTableHead"/>
									<xsl:with-param name="typ" select="$typ"/>
								</xsl:apply-templates>
							</xsl:variable>
							<xsl:variable name="valign">
								<xsl:apply-templates select="current()" mode="getCellFormat">
									<xsl:with-param name="attributeName">vertical-align</xsl:with-param>
									<xsl:with-param name="hasFormatRef" select="$hasFormatRef"/>
									<xsl:with-param name="isTableHead" select="$isTableHead"/>
									<xsl:with-param name="typ" select="$typ"/>
								</xsl:apply-templates>
							</xsl:variable>
							<xsl:if test="string-length($refHeight) &gt; 0">
								<xsl:attribute name="width">
									<xsl:value-of select="$refHeight"/>
								</xsl:attribute>
							</xsl:if>
							<xsl:if test="string-length($valign) &gt; 0">
								<xsl:attribute name="display-align">
									<xsl:value-of select="$valign"/>
								</xsl:attribute>
							</xsl:if>
							<xsl:apply-templates select="*[name() != 'formatRef']">
								<xsl:with-param name="insideTableCell">true</xsl:with-param>
							</xsl:apply-templates>
							<xsl:if test="not(*[name() != 'formatRef'])">
								<fo:block/>
							</xsl:if>
						</fo:block-container>
					</xsl:when>
					<xsl:when test="string-length($writingMode) &gt; 0">
						<xsl:apply-templates select="formatRef"/>
						<xsl:variable name="align">
							<xsl:apply-templates select="current()" mode="getCellFormat">
								<xsl:with-param name="attributeName">text-align</xsl:with-param>
								<xsl:with-param name="hasFormatRef" select="$hasFormatRef"/>
								<xsl:with-param name="isTableHead" select="$isTableHead"/>
								<xsl:with-param name="typ" select="$typ"/>
							</xsl:apply-templates>
						</xsl:variable>
						<fo:block-container writing-mode="{$writingMode}">
							<fo:block>
								<fo:bidi-override unicode-bidi="bidi-override">
									<xsl:apply-templates select="*[name() != 'formatRef']">
										<xsl:with-param name="insideTableCell">true</xsl:with-param>
									</xsl:apply-templates>
								</fo:bidi-override>
							</fo:block>
						</fo:block-container>
					</xsl:when>
					<xsl:otherwise>
						<xsl:apply-templates select="current()" mode="writeCharacterizationInfo"/>
						<xsl:apply-templates>
							<xsl:with-param name="insideTableCell">true</xsl:with-param>
						</xsl:apply-templates>
						<xsl:if test="not(*[name() != 'formatRef'])">
							<fo:block/>
						</xsl:if>
					</xsl:otherwise>
				</xsl:choose>
			</fo:table-cell>
		</xsl:if>
	</xsl:template>

	<xsl:template match="tableCell" mode="getCellFormat">
		<xsl:param name="typ"/>
		<xsl:param name="isTableHead"/>
		<xsl:param name="attributeName"/>
		<xsl:param name="hasFormatRef"/>

		<xsl:variable name="useHeader" select="$isTableHead and not($typ = 'Pmg')"/>

		<xsl:variable name="attrValue">
			<xsl:choose>
				<xsl:when test="$useHeader">
					<xsl:call-template name="getFormat">
						<xsl:with-param name="name">table.header.horizontal</xsl:with-param>
						<xsl:with-param name="attributeName" select="$attributeName"/>
						<xsl:with-param name="defaultValue">
							<xsl:call-template name="getFormat">
								<xsl:with-param name="name">table.header</xsl:with-param>
								<xsl:with-param name="attributeName" select="$attributeName"/>
								<xsl:with-param name="defaultValue">
									<xsl:call-template name="getFormat">
										<xsl:with-param name="name">table.cell</xsl:with-param>
										<xsl:with-param name="attributeName" select="$attributeName"/>
									</xsl:call-template>
								</xsl:with-param>
							</xsl:call-template>
						</xsl:with-param>
					</xsl:call-template>
				</xsl:when>
				<xsl:otherwise>
					<xsl:call-template name="getFormat">
						<xsl:with-param name="name">table.cell</xsl:with-param>
						<xsl:with-param name="attributeName" select="$attributeName"/>
					</xsl:call-template>
				</xsl:otherwise>
			</xsl:choose>
		</xsl:variable>

		<xsl:choose>
			<xsl:when test="$hasFormatRef">
				<xsl:call-template name="getFormat">
					<xsl:with-param name="name" select="formatRef/@formatRef"/>
					<xsl:with-param name="attributeName" select="$attributeName"/>
					<xsl:with-param name="defaultValue" select="$attrValue"/>
				</xsl:call-template>
			</xsl:when>
			<xsl:otherwise>
				<xsl:value-of select="$attrValue"/>
			</xsl:otherwise>
		</xsl:choose>
	</xsl:template>

</xsl:stylesheet>