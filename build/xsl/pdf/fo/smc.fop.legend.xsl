<?xml version="1.0" encoding="utf-8"?>
<xsl:stylesheet
	xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
	xmlns:fo="http://www.w3.org/1999/XSL/Format"
	version="1.0">

	<xsl:template match="legend">
		<xsl:param name="forceRender" select="false()"/>
		<xsl:choose>
			<xsl:when test="@isTableLegend">
				<xsl:choose>
					<xsl:when test="$forceRender">
						<xsl:apply-templates select="current()" mode="table-simple"/>
					</xsl:when>
					<xsl:otherwise>
						<xsl:variable name="defaultTableLegendPosition">
							<xsl:call-template name="getTemplateVariableValue">
								<xsl:with-param name="name" select="'TABLE_LEGEND_POSITION'"/>
								<xsl:with-param name="defaultValue">bottom</xsl:with-param>
							</xsl:call-template>
						</xsl:variable>
						<xsl:if test="$defaultTableLegendPosition = 'bottom'">
							<xsl:apply-templates select="current()" mode="table-simple"/>
						</xsl:if>
					</xsl:otherwise>
				</xsl:choose>

			</xsl:when>
			<xsl:otherwise>
				<xsl:apply-templates select="current()" mode="simple"/>
			</xsl:otherwise>
		</xsl:choose>
	</xsl:template>

	<xsl:template match="legend" mode="simple">
		<fo:block>
			<xsl:call-template name="addStyle">
				<xsl:with-param name="name">block-level-element</xsl:with-param>
			</xsl:call-template>
			<xsl:call-template name="addStyle">
				<xsl:with-param name="name">legend</xsl:with-param>
			</xsl:call-template>
			<xsl:apply-templates select="current()" mode="writeCharacterizationInfo">
				<xsl:with-param name="bPadding" select="true()"/>
			</xsl:apply-templates>
			<xsl:variable name="preColumns">
				<xsl:choose>
					<xsl:when test="@type = 'Legend_2'">2</xsl:when>
					<xsl:otherwise>
						<xsl:call-template name="getFormat">
							<xsl:with-param name="name">legend</xsl:with-param>
							<xsl:with-param name="attributeName">column-count</xsl:with-param>
							<xsl:with-param name="defaultValue">1</xsl:with-param>
						</xsl:call-template>
					</xsl:otherwise>
				</xsl:choose>
			</xsl:variable>

			<xsl:variable name="columns">
				<xsl:choose>
					<xsl:when test="string(number($preColumns)) = 'NaN'">
						<xsl:value-of select="1"/>
					</xsl:when>
					<xsl:otherwise>
						<xsl:value-of select="number($preColumns)"/>
					</xsl:otherwise>
				</xsl:choose>
			</xsl:variable>

			<xsl:variable name="flow">
				<xsl:call-template name="getTemplateVariableValue">
					<xsl:with-param name="name">LEGEND_COLUMN_FLOW</xsl:with-param>
				</xsl:call-template>
			</xsl:variable>

			<xsl:variable name="type">
				<xsl:if test="@type != 'Standard' and @type != 'Legend'">
					<xsl:value-of select="@type"/>
				</xsl:if>
			</xsl:variable>

			<xsl:variable name="legendCol1">
				<xsl:choose>
					<xsl:when test="string-length($type) &gt; 0">
						<xsl:call-template name="getTemplateVariableValue">
							<xsl:with-param name="name" select="concat('LEGEND_', $type, '_COL1')"/>
							<xsl:with-param name="defaultValue">
								<xsl:call-template name="getTemplateVariableValue">
									<xsl:with-param name="name" select="'LEGEND_COL1'"/>
									<xsl:with-param name="defaultValue">10mm</xsl:with-param>
								</xsl:call-template>
							</xsl:with-param>
						</xsl:call-template>
					</xsl:when>
					<xsl:otherwise>
						<xsl:call-template name="getTemplateVariableValue">
							<xsl:with-param name="name" select="'LEGEND_COL1'"/>
							<xsl:with-param name="defaultValue">10mm</xsl:with-param>
						</xsl:call-template>
					</xsl:otherwise>
				</xsl:choose>
			</xsl:variable>
			<xsl:variable name="legendCol2">
				<xsl:choose>
					<xsl:when test="string-length($type) &gt; 0">
						<xsl:call-template name="getTemplateVariableValue">
							<xsl:with-param name="name" select="concat('LEGEND_', $type, '_COL2')"/>
							<xsl:with-param name="defaultValue">
								<xsl:call-template name="getTemplateVariableValue">
									<xsl:with-param name="name" select="'LEGEND_COL2'"/>
									<xsl:with-param name="defaultValue">4mm</xsl:with-param>
								</xsl:call-template>
							</xsl:with-param>
						</xsl:call-template>
					</xsl:when>
					<xsl:otherwise>
						<xsl:call-template name="getTemplateVariableValue">
							<xsl:with-param name="name" select="'LEGEND_COL2'"/>
							<xsl:with-param name="defaultValue">4mm</xsl:with-param>
						</xsl:call-template>
					</xsl:otherwise>
				</xsl:choose>
			</xsl:variable>
			<xsl:variable name="legendCol3">
				<xsl:choose>
					<xsl:when test="string-length($type) &gt; 0">
						<xsl:call-template name="getTemplateVariableValue">
							<xsl:with-param name="name" select="concat('LEGEND_', $type, '_COL3')"/>
							<xsl:with-param name="defaultValue">
								<xsl:call-template name="getTemplateVariableValue">
									<xsl:with-param name="name" select="'LEGEND_COL3'"/>
									<xsl:with-param name="defaultValue">*</xsl:with-param>
								</xsl:call-template>
							</xsl:with-param>
						</xsl:call-template>
					</xsl:when>
					<xsl:otherwise>
						<xsl:call-template name="getTemplateVariableValue">
							<xsl:with-param name="name" select="'LEGEND_COL3'"/>
							<xsl:with-param name="defaultValue">*</xsl:with-param>
						</xsl:call-template>
					</xsl:otherwise>
				</xsl:choose>
			</xsl:variable>

			<fo:table table-layout="fixed">
				<xsl:call-template name="addStyle">
					<xsl:with-param name="name">legend.table</xsl:with-param>
				</xsl:call-template>
				<xsl:if test="@isTableLegend">
					<xsl:attribute name="keep-with-previous">always</xsl:attribute>
				</xsl:if>
				<xsl:choose>
					<xsl:when test="string-length($type) &gt; 0">
						<xsl:call-template name="generateLegendColumns">
							<xsl:with-param name="colCount" select="$columns"/>
							<xsl:with-param name="legendCol1">
								<xsl:call-template name="getTemplateVariableValue">
									<xsl:with-param name="name" select="concat($type, '_LEGEND_COL1')"/>
									<xsl:with-param name="defaultValue" select="$legendCol1"/>
								</xsl:call-template>
							</xsl:with-param>
							<xsl:with-param name="legendCol2">
								<xsl:call-template name="getTemplateVariableValue">
									<xsl:with-param name="name" select="concat($type, '_LEGEND_COL2')"/>
									<xsl:with-param name="defaultValue" select="$legendCol2"/>
								</xsl:call-template>
							</xsl:with-param>
							<xsl:with-param name="legendCol3">
								<xsl:call-template name="getTemplateVariableValue">
									<xsl:with-param name="name" select="concat($type, '_LEGEND_COL3')"/>
									<xsl:with-param name="defaultValue" select="$legendCol3"/>
								</xsl:call-template>
							</xsl:with-param>
						</xsl:call-template>
					</xsl:when>
					<xsl:otherwise>
						<xsl:call-template name="generateLegendColumns">
							<xsl:with-param name="colCount" select="$columns"/>
							<xsl:with-param name="legendCol1" select="$legendCol1"/>
							<xsl:with-param name="legendCol2" select="$legendCol2"/>
							<xsl:with-param name="legendCol3" select="$legendCol3"/>
						</xsl:call-template>
					</xsl:otherwise>
				</xsl:choose>
				<fo:table-body>
					<xsl:variable name="rowCounter" select="count(legend.row)"/>
					<xsl:variable name="perColumn" select="ceiling($rowCounter div $columns)"/>
					<xsl:choose>
						<xsl:when test="$flow = 'ltr'">
							<xsl:for-each select="legend.row[(position() - 1) mod $columns = 0]">
								<fo:table-row>
									<xsl:call-template name="addStyle">
										<xsl:with-param name="name">legend.row</xsl:with-param>
									</xsl:call-template>

									<xsl:call-template name="generateLegendEntries">
										<xsl:with-param name="colCount" select="$columns"/>
										<xsl:with-param name="perColumn" select="1"/>
										<xsl:with-param name="stylePrefix" select="$type"/>
										<xsl:with-param name="fallbackToDefaultStyle" select="true()"/>
									</xsl:call-template>
								</fo:table-row>
							</xsl:for-each>
						</xsl:when>
						<xsl:otherwise>
							<xsl:for-each select="legend.row[position() &lt;= $perColumn]">
								<fo:table-row>
									<xsl:call-template name="addStyle">
										<xsl:with-param name="name">legend.row</xsl:with-param>
									</xsl:call-template>

									<xsl:call-template name="generateLegendEntries">
										<xsl:with-param name="colCount" select="$columns"/>
										<xsl:with-param name="perColumn" select="$perColumn"/>
										<xsl:with-param name="stylePrefix" select="$type"/>
										<xsl:with-param name="fallbackToDefaultStyle" select="true()"/>
									</xsl:call-template>
								</fo:table-row>
							</xsl:for-each>
						</xsl:otherwise>
					</xsl:choose>
				</fo:table-body>
			</fo:table>
		</fo:block>
	</xsl:template>

	<xsl:template match="legend" mode="table-simple">
		<fo:block>
			<xsl:call-template name="addStyle">
				<xsl:with-param name="name">block-level-element</xsl:with-param>
			</xsl:call-template>
			<xsl:call-template name="addStyle">
				<xsl:with-param name="name">table.legend</xsl:with-param>
			</xsl:call-template>
			<xsl:apply-templates select="current()" mode="writeCharacterizationInfo">
				<xsl:with-param name="bPadding" select="true()"/>
			</xsl:apply-templates>
			<xsl:variable name="preColumns">
				<xsl:call-template name="getFormat">
					<xsl:with-param name="name">table.legend</xsl:with-param>
					<xsl:with-param name="attributeName">column-count</xsl:with-param>
					<xsl:with-param name="defaultValue" select="1"/>
				</xsl:call-template>
			</xsl:variable>

			<xsl:variable name="columns">
				<xsl:choose>
					<xsl:when test="string(number($preColumns)) = 'NaN'">
						<xsl:value-of select="1"/>
					</xsl:when>
					<xsl:otherwise>
						<xsl:value-of select="number($preColumns)"/>
					</xsl:otherwise>
				</xsl:choose>
			</xsl:variable>

			<fo:table table-layout="fixed">
				<xsl:attribute name="keep-with-previous">always</xsl:attribute>
				<xsl:call-template name="addStyle">
					<xsl:with-param name="name">table.legend.table</xsl:with-param>
				</xsl:call-template>
				<xsl:apply-templates select="current()" mode="applyWidowOrphans">
					<xsl:with-param name="name">table.legend.table</xsl:with-param>
					<xsl:with-param name="orphansDefault" select="2"/>
					<xsl:with-param name="widowsDefault" select="2"/>
				</xsl:apply-templates>
				<xsl:call-template name="generateLegendColumns">
					<xsl:with-param name="colCount" select="$columns"/>
					<xsl:with-param name="legendCol1">
						<xsl:call-template name="getTemplateVariableValue">
							<xsl:with-param name="name" select="'TABLE_LEGEND_COL1'"/>
							<xsl:with-param name="defaultValue" select="'10mm'"/>
						</xsl:call-template>
					</xsl:with-param>
					<xsl:with-param name="legendCol2">
						<xsl:call-template name="getTemplateVariableValue">
							<xsl:with-param name="name" select="'TABLE_LEGEND_COL2'"/>
							<xsl:with-param name="defaultValue" select="'2mm'"/>
						</xsl:call-template>
					</xsl:with-param>
					<xsl:with-param name="legendCol3">
						<xsl:call-template name="getTemplateVariableValue">
							<xsl:with-param name="name" select="'TABLE_LEGEND_COL3'"/>
							<xsl:with-param name="defaultValue" select="'*'"/>
						</xsl:call-template>
					</xsl:with-param>
				</xsl:call-template>
				<fo:table-body>
					<xsl:variable name="rowCounter" select="count(legend.row)"/>
					<xsl:variable name="perColumn" select="ceiling($rowCounter div $columns)"/>

					<xsl:for-each select="legend.row[position() &lt;= $perColumn]">
						<fo:table-row>
							<xsl:call-template name="addStyle">
								<xsl:with-param name="name">table.legend.row</xsl:with-param>
							</xsl:call-template>

							<xsl:call-template name="generateLegendEntries">
								<xsl:with-param name="colCount" select="$columns"/>
								<xsl:with-param name="perColumn" select="$perColumn"/>
								<xsl:with-param name="stylePrefix">table.</xsl:with-param>
								<xsl:with-param name="useTableMode" select="true()"/>
							</xsl:call-template>
						</fo:table-row>
					</xsl:for-each>

				</fo:table-body>
			</fo:table>
		</fo:block>
	</xsl:template>

	<xsl:template match="legend.row" mode="legend-separator-column"/>

	<xsl:template name="generateLegendEntries">
		<xsl:param name="colCount"/>
		<xsl:param name="stylePrefix"/>
		<xsl:param name="fallbackToDefaultStyle" select="false()"/>
		<xsl:param name="useMediaMode" select="1 = 2"/>
		<xsl:param name="useTableMode" select="false()"/>
		<xsl:param name="perColumn" select="1"/>

		<xsl:variable name="isFirst" select="position() = 1"/>

		<xsl:if test="$colCount &gt; 0">
			<xsl:variable name="doStyleFallback" select="$fallbackToDefaultStyle and string-length($stylePrefix) &gt; 0"/>
			<fo:table-cell>
				<xsl:if test="$doStyleFallback">
					<xsl:call-template name="addStyle">
						<xsl:with-param name="name">legend.term.cell</xsl:with-param>
					</xsl:call-template>
				</xsl:if>
				<xsl:call-template name="addStyle">
					<xsl:with-param name="name" select="concat($stylePrefix, 'legend.term.cell')"/>
				</xsl:call-template>
				<xsl:if test="$isFirst">
					<xsl:if test="$doStyleFallback">
						<xsl:call-template name="addStyle">
							<xsl:with-param name="name">legend.term.cell.first</xsl:with-param>
						</xsl:call-template>
					</xsl:if>
					<xsl:call-template name="addStyle">
						<xsl:with-param name="name" select="concat($stylePrefix, 'legend.term.cell.first')"/>
					</xsl:call-template>
				</xsl:if>
				<fo:block>
					<xsl:if test="$doStyleFallback">
						<xsl:call-template name="addStyle">
							<xsl:with-param name="name">legend.term</xsl:with-param>
						</xsl:call-template>
					</xsl:if>
					<xsl:call-template name="addStyle">
						<xsl:with-param name="name" select="concat($stylePrefix, 'legend.term')"/>
					</xsl:call-template>
					<xsl:choose>
						<xsl:when test="$useMediaMode">
							<xsl:apply-templates select="legend.term" mode="media"/>
						</xsl:when>
						<xsl:when test="$useTableMode">
							<xsl:apply-templates select="legend.term" mode="table"/>
						</xsl:when>
						<xsl:otherwise>
							<xsl:apply-templates select="legend.term"/>
						</xsl:otherwise>
					</xsl:choose>
				</fo:block>
			</fo:table-cell>
			<fo:table-cell>
				<fo:block>
					<xsl:apply-templates select="current()" mode="legend-separator-column"/>
				</fo:block>
			</fo:table-cell>
			<fo:table-cell>
				<xsl:if test="$doStyleFallback">
					<xsl:call-template name="addStyle">
						<xsl:with-param name="name">legend.def.cell</xsl:with-param>
					</xsl:call-template>
				</xsl:if>
				<xsl:call-template name="addStyle">
					<xsl:with-param name="name" select="concat($stylePrefix, 'legend.def.cell')"/>
				</xsl:call-template>
				<xsl:if test="$isFirst">
					<xsl:if test="$doStyleFallback">
						<xsl:call-template name="addStyle">
							<xsl:with-param name="name">legend.def.cell.first</xsl:with-param>
						</xsl:call-template>
					</xsl:if>
					<xsl:call-template name="addStyle">
						<xsl:with-param name="name" select="concat($stylePrefix, 'legend.def.cell.first')"/>
					</xsl:call-template>
				</xsl:if>
				<fo:block>
					<xsl:if test="$doStyleFallback">
						<xsl:call-template name="addStyle">
							<xsl:with-param name="name">legend.def</xsl:with-param>
						</xsl:call-template>
					</xsl:if>
					<xsl:call-template name="addStyle">
						<xsl:with-param name="name" select="concat($stylePrefix, 'legend.def')"/>
					</xsl:call-template>

					<xsl:choose>
						<xsl:when test="$useMediaMode">
							<xsl:apply-templates select="legend.def" mode="media"/>
						</xsl:when>
						<xsl:when test="$useTableMode">
							<xsl:apply-templates select="legend.def" mode="table"/>
						</xsl:when>
						<xsl:otherwise>
							<xsl:apply-templates select="legend.def"/>
						</xsl:otherwise>
					</xsl:choose>
				</fo:block>
			</fo:table-cell>
			<xsl:if test="$colCount &gt; 1">
				<xsl:for-each select="following-sibling::legend.row[$perColumn]">
					<xsl:call-template name="generateLegendEntries">
						<xsl:with-param name="colCount" select="$colCount - 1"/>
						<xsl:with-param name="stylePrefix" select="$stylePrefix"/>
						<xsl:with-param name="fallbackToDefaultStyle" select="$fallbackToDefaultStyle"/>
						<xsl:with-param name="useMediaMode" select="$useMediaMode"/>
						<xsl:with-param name="useTableMode" select="$useTableMode"/>
						<xsl:with-param name="perColumn" select="$perColumn"/>
					</xsl:call-template>
				</xsl:for-each>
			</xsl:if>
		</xsl:if>
	</xsl:template>

	<xsl:template name="generateLegendColumns">
		<xsl:param name="colCount"/>
		<xsl:param name="legendCol1"/>
		<xsl:param name="legendCol2"/>
		<xsl:param name="legendCol3"/>

		<xsl:if test="$colCount &gt; 0">
			<fo:table-column column-width="{$legendCol1}" />
			<fo:table-column column-width="{$legendCol2}" />
			<fo:table-column column-width="{$legendCol3}">
				<xsl:choose>
					<xsl:when test="$legendCol3 = '*' or $legendCol3 = '' or $legendCol3 = 'mm' or $legendCol3 = 'cm' or $legendCol3 = '*mm' or $legendCol3 = '*cm'">
						<xsl:attribute name="column-width">proportional-column-width(1)</xsl:attribute>
					</xsl:when>
				</xsl:choose>
			</fo:table-column>
			<xsl:call-template name="generateLegendColumns">
				<xsl:with-param name="colCount" select="$colCount - 1"/>
				<xsl:with-param name="legendCol1" select="$legendCol1"/>
				<xsl:with-param name="legendCol2" select="$legendCol2"/>
				<xsl:with-param name="legendCol3" select="$legendCol3"/>
			</xsl:call-template>
		</xsl:if>
	</xsl:template>

	<xsl:template name="generateDistributedLegendColumns">
		<xsl:param name="colCount"/>
		<xsl:param name="legendColWidth"/>

		<xsl:if test="$colCount &gt; 0">
			<fo:table-column column-width="{$legendColWidth}" />
			<xsl:call-template name="generateDistributedLegendColumns">
				<xsl:with-param name="colCount" select="$colCount - 1"/>
				<xsl:with-param name="legendColWidth" select="$legendColWidth"/>
			</xsl:call-template>
		</xsl:if>
	</xsl:template>

	<xsl:template match="legend.term">
		<xsl:variable name="termPrefix">
			<xsl:call-template name="getTemplateVariableValue">
				<xsl:with-param name="name">LEGEND_TERM_PREFIX</xsl:with-param>
			</xsl:call-template>
		</xsl:variable>
		<xsl:variable name="termSuffix">
			<xsl:call-template name="getTemplateVariableValue">
				<xsl:with-param name="name">LEGEND_TERM_SUFFIX</xsl:with-param>
			</xsl:call-template>
		</xsl:variable>
		<xsl:value-of select="$termPrefix"/>
		<xsl:apply-templates>
			<xsl:with-param name="isInline" select="true()"/>
		</xsl:apply-templates>
		<xsl:value-of select="$termSuffix"/>
	</xsl:template>

	<xsl:template match="legend.def">
		<xsl:apply-templates/>
	</xsl:template>

	<xsl:template match="legend" mode="media">
		<xsl:apply-templates select="current()" mode="media-simple"/>
	</xsl:template>

	<xsl:template match="legend" mode="media-simple">
		<xsl:param name="renderSpacerColumn" select="1 = 1"/>

		<fo:block>
			<xsl:call-template name="addStyle">
				<xsl:with-param name="name">block-level-element</xsl:with-param>
			</xsl:call-template>
			<xsl:call-template name="addStyle">
				<xsl:with-param name="name">media.legend</xsl:with-param>
			</xsl:call-template>

			<xsl:variable name="preColumns">
				<xsl:call-template name="getFormat">
					<xsl:with-param name="name">media.legend</xsl:with-param>
					<xsl:with-param name="attributeName">column-count</xsl:with-param>
					<xsl:with-param name="defaultValue" select="1"/>
				</xsl:call-template>
			</xsl:variable>

			<xsl:variable name="columns">
				<xsl:choose>
					<xsl:when test="string(number($preColumns)) = 'NaN'">
						<xsl:value-of select="1"/>
					</xsl:when>
					<xsl:otherwise>
						<xsl:value-of select="number($preColumns)"/>
					</xsl:otherwise>
				</xsl:choose>
			</xsl:variable>

			<xsl:variable name="flow">
				<xsl:call-template name="getTemplateVariableValue">
					<xsl:with-param name="name">MEDIA_LEGEND_COLUMN_FLOW</xsl:with-param>
				</xsl:call-template>
			</xsl:variable>

			<xsl:variable name="col1Default">10mm</xsl:variable>
			<xsl:variable name="col2Default">4mm</xsl:variable>
			<xsl:variable name="col3Default">*</xsl:variable>

			<fo:table table-layout="fixed">
				<xsl:call-template name="addStyle">
					<xsl:with-param name="name">media.legend.table</xsl:with-param>
				</xsl:call-template>
				<xsl:apply-templates select="current()" mode="applyWidowOrphans">
					<xsl:with-param name="name">media.legend.table</xsl:with-param>
					<xsl:with-param name="orphansDefault" select="2"/>
					<xsl:with-param name="widowsDefault" select="2"/>
				</xsl:apply-templates>

				<!--<xsl:choose>
					<xsl:when test="starts-with($flow, 'table-per-column') and $columns &gt; 1">
						<xsl:variable name="cols">
							<xsl:call-template name="generateDistributedLegendColumns">
								<xsl:with-param name="colCount" select="$columns"/>
								<xsl:with-param name="legendColWidth" select="concat(100 div $columns, '%')"/>
							</xsl:call-template>
						</xsl:variable>
						<xsl:variable name="colElems" select="exslt:node-set($cols)/fo:table-column"/>
						<xsl:for-each select="$colElems">
							<xsl:copy-of select="current()"/>
						</xsl:for-each>
						<fo:table-body start-indent="0">
							<fo:table-row>
								<xsl:variable name="curr" select="current()"/>
								<xsl:for-each select="$colElems">
									<xsl:variable name="colPos" select="position()"/>
									<xsl:for-each select="$curr">
										<fo:table-cell>
											<fo:table table-layout="fixed">
												<xsl:call-template name="generateLegendColumns">
													<xsl:with-param name="colCount" select="1"/>
													<xsl:with-param name="legendCol1">
														<xsl:call-template name="getTemplateVariableValue">
															<xsl:with-param name="name" select="'MEDIA_LEGEND_COL1'"/>
															<xsl:with-param name="defaultValue" select="$col1Default"/>
														</xsl:call-template>
													</xsl:with-param>
													<xsl:with-param name="legendCol2">
														<xsl:call-template name="getTemplateVariableValue">
															<xsl:with-param name="name" select="'MEDIA_LEGEND_COL2'"/>
															<xsl:with-param name="defaultValue" select="$col2Default"/>
														</xsl:call-template>
													</xsl:with-param>
													<xsl:with-param name="legendCol3">
														<xsl:call-template name="getTemplateVariableValue">
															<xsl:with-param name="name" select="'MEDIA_LEGEND_COL3'"/>
															<xsl:with-param name="defaultValue" select="$col3Default"/>
														</xsl:call-template>
													</xsl:with-param>
												</xsl:call-template>
												<fo:table-body start-indent="0">
													<xsl:variable name="rowCounter" select="count(legend.row)"/>
													<xsl:variable name="perColumn" select="ceiling($rowCounter div $columns)"/>
													<xsl:choose>
														<xsl:when test="$flow = 'table-per-column-ltr'">
															<xsl:for-each select="legend.row[(position() - 1) mod $columns = $colPos - 1]">
																<fo:table-row>
																	<xsl:call-template name="addStyle">
																		<xsl:with-param name="name">media.legend.row</xsl:with-param>
																	</xsl:call-template>

																	<xsl:call-template name="generateLegendEntries">
																		<xsl:with-param name="colCount" select="1"/>
																		<xsl:with-param name="stylePrefix">media.</xsl:with-param>
																		<xsl:with-param name="useMediaMode" select="1 = 1"/>
																		<xsl:with-param name="perColumn" select="1"/>
																	</xsl:call-template>
																</fo:table-row>
															</xsl:for-each>
														</xsl:when>
														<xsl:otherwise>
															<xsl:for-each select="legend.row[position() &gt; ($perColumn * ($colPos - 1)) and position() &lt;= ($perColumn * $colPos)]">
																<fo:table-row>
																	<xsl:call-template name="addStyle">
																		<xsl:with-param name="name">media.legend.row</xsl:with-param>
																	</xsl:call-template>

																	<xsl:call-template name="generateLegendEntries">
																		<xsl:with-param name="colCount" select="1"/>
																		<xsl:with-param name="stylePrefix">media.</xsl:with-param>
																		<xsl:with-param name="useMediaMode" select="1 = 1"/>
																		<xsl:with-param name="perColumn" select="1"/>
																	</xsl:call-template>
																</fo:table-row>
															</xsl:for-each>
														</xsl:otherwise>
													</xsl:choose>
												</fo:table-body>
											</fo:table>
										</fo:table-cell>
									</xsl:for-each>
								</xsl:for-each>
							</fo:table-row>
						</fo:table-body>
					</xsl:when>
					<xsl:otherwise>-->
						<xsl:call-template name="generateLegendColumns">
							<xsl:with-param name="colCount" select="$columns"/>
							<xsl:with-param name="legendCol1">
								<xsl:call-template name="getTemplateVariableValue">
									<xsl:with-param name="name" select="'MEDIA_LEGEND_COL1'"/>
									<xsl:with-param name="defaultValue" select="$col1Default"/>
								</xsl:call-template>
							</xsl:with-param>
							<xsl:with-param name="legendCol2">
								<xsl:call-template name="getTemplateVariableValue">
									<xsl:with-param name="name" select="'MEDIA_LEGEND_COL2'"/>
									<xsl:with-param name="defaultValue" select="$col2Default"/>
								</xsl:call-template>
							</xsl:with-param>
							<xsl:with-param name="legendCol3">
								<xsl:call-template name="getTemplateVariableValue">
									<xsl:with-param name="name" select="'MEDIA_LEGEND_COL3'"/>
									<xsl:with-param name="defaultValue" select="$col3Default"/>
								</xsl:call-template>
							</xsl:with-param>
						</xsl:call-template>
						<fo:table-body start-indent="0">
							<xsl:variable name="rowCounter" select="count(legend.row)"/>
							<xsl:variable name="perColumn" select="ceiling($rowCounter div $columns)"/>

							<xsl:choose>
								<xsl:when test="$flow = 'ltr'">
									<xsl:for-each select="legend.row[(position() - 1) mod $columns = 0]">
										<fo:table-row>
											<xsl:call-template name="addStyle">
												<xsl:with-param name="name">media.legend.row</xsl:with-param>
											</xsl:call-template>

											<xsl:call-template name="generateLegendEntries">
												<xsl:with-param name="colCount" select="$columns"/>
												<xsl:with-param name="stylePrefix">media.</xsl:with-param>
												<xsl:with-param name="useMediaMode" select="1 = 1"/>
												<xsl:with-param name="perColumn" select="1"/>
											</xsl:call-template>
										</fo:table-row>
									</xsl:for-each>
								</xsl:when>
								<xsl:otherwise>
									<xsl:for-each select="legend.row[position() &lt;= $perColumn]">
										<fo:table-row>
											<xsl:call-template name="addStyle">
												<xsl:with-param name="name">media.legend.row</xsl:with-param>
											</xsl:call-template>

											<xsl:call-template name="generateLegendEntries">
												<xsl:with-param name="colCount" select="$columns"/>
												<xsl:with-param name="stylePrefix">media.</xsl:with-param>
												<xsl:with-param name="useMediaMode" select="1 = 1"/>
												<xsl:with-param name="perColumn" select="$perColumn"/>
											</xsl:call-template>
										</fo:table-row>
									</xsl:for-each>
								</xsl:otherwise>
							</xsl:choose>
						</fo:table-body>
					<!--</xsl:otherwise>
				</xsl:choose>-->
				
			</fo:table>
		</fo:block>
	</xsl:template>

	<xsl:template match="legend.def" mode="media">
		<xsl:apply-templates/>
	</xsl:template>

	<xsl:template match="legend.term" mode="media">
		<xsl:variable name="termPrefix">
			<xsl:call-template name="getTemplateVariableValue">
				<xsl:with-param name="name">MEDIA_LEGEND_TERM_PREFIX</xsl:with-param>
			</xsl:call-template>
		</xsl:variable>
		<xsl:variable name="termSuffix">
			<xsl:call-template name="getTemplateVariableValue">
				<xsl:with-param name="name">MEDIA_LEGEND_TERM_SUFFIX</xsl:with-param>
			</xsl:call-template>
		</xsl:variable>
		<xsl:value-of select="$termPrefix"/>
		<xsl:apply-templates>
			<xsl:with-param name="isInline" select="true()"/>
		</xsl:apply-templates>
		<xsl:value-of select="$termSuffix"/>
	</xsl:template>

	<xsl:template match="legend.def" mode="table">
		<xsl:apply-templates/>
	</xsl:template>

	<xsl:template match="legend.term" mode="table">
		<xsl:variable name="termPrefix">
			<xsl:call-template name="getTemplateVariableValue">
				<xsl:with-param name="name">TABLE_LEGEND_TERM_PREFIX</xsl:with-param>
			</xsl:call-template>
		</xsl:variable>
		<xsl:variable name="termSuffix">
			<xsl:call-template name="getTemplateVariableValue">
				<xsl:with-param name="name">TABLE_LEGEND_TERM_SUFFIX</xsl:with-param>
			</xsl:call-template>
		</xsl:variable>
		<xsl:value-of select="$termPrefix"/>
		<xsl:apply-templates>
			<xsl:with-param name="isInline" select="true()"/>
		</xsl:apply-templates>
		<xsl:value-of select="$termSuffix"/>
	</xsl:template>

</xsl:stylesheet>
