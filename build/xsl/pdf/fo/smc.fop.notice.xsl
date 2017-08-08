<?xml version="1.0" encoding="utf-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:fo="http://www.w3.org/1999/XSL/Format" version="1.0">

	<xsl:template match="InfoItem.Warning">
		<xsl:param name="insideTableCell"/>
		<xsl:apply-templates select="current()" mode="simple">
			<xsl:with-param name="insideTableCell" select="$insideTableCell"/>
		</xsl:apply-templates>
	</xsl:template>

	<xsl:template match="InfoItem.Warning" mode="simple">
		<xsl:param name="insideTableCell"/>
		<xsl:param name="defaultType">
			<xsl:call-template name="getTemplateVariableValue">
				<xsl:with-param name="name" select="'NOTICE_DEFAULT_TYPE'"/>
				<xsl:with-param name="defaultValue">Warning</xsl:with-param>
			</xsl:call-template>
		</xsl:param>
		<xsl:param name="dontBreakAfterTitle">false</xsl:param>
		<xsl:param name="titlePosition">
			<xsl:choose>
				<xsl:when test="string-length(@type) = 0">
					<xsl:call-template name="getTemplateVariableValue">
						<xsl:with-param name="name" select="concat('NOTICE_', $defaultType, '_TITLE_POSITION')"/>
						<xsl:with-param name="defaultValue">
							<xsl:call-template name="getTemplateVariableValue">
								<xsl:with-param name="name" select="'NOTICE_TITLE_POSITION'"/>
								<xsl:with-param name="defaultValue">top</xsl:with-param>
							</xsl:call-template>
						</xsl:with-param>
					</xsl:call-template>
				</xsl:when>
				<xsl:otherwise>
					<xsl:call-template name="getTemplateVariableValue">
						<xsl:with-param name="name" select="concat('NOTICE_', @type, '_TITLE_POSITION')"/>
						<xsl:with-param name="defaultValue">
							<xsl:call-template name="getTemplateVariableValue">
								<xsl:with-param name="name" select="'NOTICE_TITLE_POSITION'"/>
								<xsl:with-param name="defaultValue">top</xsl:with-param>
							</xsl:call-template>
						</xsl:with-param>
					</xsl:call-template>
				</xsl:otherwise>
			</xsl:choose>
		</xsl:param>
		<xsl:param name="iconFileExtension">jpg</xsl:param>
		<xsl:param name="defaultIconType" select="$defaultType"/>
		<xsl:param name="noticeCol1">
			<xsl:call-template name="getTemplateVariableValue">
				<xsl:with-param name="name">
					<xsl:text>NOTICE_</xsl:text>
					<xsl:call-template name="getCurrentLanguage"/>
					<xsl:text>_</xsl:text>
					<xsl:value-of select="@type"/>
					<xsl:text>_COL1</xsl:text>
				</xsl:with-param>
				<xsl:with-param name="defaultValue">
					<xsl:call-template name="getTemplateVariableValue">
						<xsl:with-param name="name" select="concat('NOTICE_', @type, '_COL1')"/>
						<xsl:with-param name="defaultValue">
							<xsl:call-template name="getTemplateVariableValue">
								<xsl:with-param name="name">
									<xsl:text>NOTICE_</xsl:text>
									<xsl:call-template name="getCurrentLanguage"/>
									<xsl:text>_COL1</xsl:text>
								</xsl:with-param>
								<xsl:with-param name="defaultValue">
									<xsl:call-template name="getTemplateVariableValue">
										<xsl:with-param name="name">NOTICE_COL1</xsl:with-param>
										<xsl:with-param name="defaultValue">20mm</xsl:with-param>
									</xsl:call-template>
								</xsl:with-param>
							</xsl:call-template>
						</xsl:with-param>
					</xsl:call-template>
				</xsl:with-param>
			</xsl:call-template>
		</xsl:param>
		<xsl:param name="noticeCol2">
			<xsl:call-template name="getTemplateVariableValue">
				<xsl:with-param name="name" select="concat('NOTICE_', @type, '_COL2')"/>
				<xsl:with-param name="defaultValue">
					<xsl:call-template name="getTemplateVariableValue">
						<xsl:with-param name="name" select="'NOTICE_COL2'"/>
						<xsl:with-param name="defaultValue">*</xsl:with-param>
					</xsl:call-template>
				</xsl:with-param>
			</xsl:call-template>
		</xsl:param>

		<xsl:variable name="iconType">
			<xsl:choose>
				<xsl:when test="string-length(@type) = 0">
					<xsl:value-of select="$defaultIconType"/>
				</xsl:when>
				<xsl:otherwise>
					<xsl:value-of select="@type"/>
				</xsl:otherwise>
			</xsl:choose>
		</xsl:variable>

		<xsl:variable name="type">
			<xsl:choose>
				<xsl:when test="string-length(@type) = 0">
					<xsl:value-of select="$defaultType"/>
				</xsl:when>
				<xsl:otherwise>
					<xsl:value-of select="@type"/>
				</xsl:otherwise>
			</xsl:choose>
		</xsl:variable>

		<xsl:variable name="useDefaultIcon">
			<xsl:call-template name="getTemplateVariableValue">
				<xsl:with-param name="name" select="'NOTICE_USE_DEFAULT_ICONS'"/>
				<xsl:with-param name="defaultValue">true</xsl:with-param>
			</xsl:call-template>
		</xsl:variable>

		<xsl:variable name="useAlternativeIcon">
			<xsl:call-template name="getTemplateVariableValue">
				<xsl:with-param name="name" select="concat('NOTICE_', $type, '_ALTERNATIVE_ICONS')"/>
				<xsl:with-param name="defaultValue">
					<xsl:call-template name="getTemplateVariableValue">
						<xsl:with-param name="name" select="'NOTICE_USE_ALTERNATIVE_ICONS'"/>
						<xsl:with-param name="defaultValue">true</xsl:with-param>
					</xsl:call-template>
				</xsl:with-param>
			</xsl:call-template>
		</xsl:variable>

		<xsl:variable name="iconname">
			<xsl:apply-templates select="current()" mode="getIcon">
				<xsl:with-param name="type" select="$iconType"/>
				<xsl:with-param name="iconFileExtension">
					<xsl:if test="not($useDefaultIcon = 'false')">
						<xsl:value-of select="$iconFileExtension"/>
					</xsl:if>
				</xsl:with-param>
				<xsl:with-param name="useAlternativeIcon" select="not($useAlternativeIcon = 'false')"/>
			</xsl:apply-templates>
		</xsl:variable>

		<xsl:variable name="noticeIconWidth">
			<xsl:call-template name="getTemplateVariableValue">
				<xsl:with-param name="name" select="concat('NOTICE.', $type, '.ICON.WIDTH')"/>
				<xsl:with-param name="defaultValue">
					<xsl:call-template name="getTemplateVariableValue">
						<xsl:with-param name="name" select="'NOTICE.ICON.WIDTH'"/>
						<xsl:with-param name="defaultValue">18mm</xsl:with-param>
					</xsl:call-template>
				</xsl:with-param>
			</xsl:call-template>
		</xsl:variable>

		<xsl:variable name="isCompact" select="@compact = 'true'"/>

		<xsl:variable name="startIndent">
			<xsl:choose>
				<xsl:when test="$isCompact">
					<xsl:call-template name="getFormat">
						<xsl:with-param name="name">notice.compact</xsl:with-param>
						<xsl:with-param name="attributeName">start-indent</xsl:with-param>
					</xsl:call-template>
				</xsl:when>
				<xsl:when test="$insideTableCell = 'true'">
					<xsl:call-template name="getFormat">
						<xsl:with-param name="name">table.cell.notice</xsl:with-param>
						<xsl:with-param name="attributeName">start-indent</xsl:with-param>
						<xsl:with-param name="defaultValue">
							<xsl:call-template name="getFormat">
								<xsl:with-param name="name">notice</xsl:with-param>
								<xsl:with-param name="attributeName">start-indent</xsl:with-param>
							</xsl:call-template>
						</xsl:with-param>
					</xsl:call-template>
				</xsl:when>
				<xsl:otherwise>
					<xsl:call-template name="getFormat">
						<xsl:with-param name="name">notice</xsl:with-param>
						<xsl:with-param name="attributeName">start-indent</xsl:with-param>
					</xsl:call-template>
				</xsl:otherwise>
			</xsl:choose>
		</xsl:variable>

		<fo:table keep-together.within-page="20" table-layout="fixed" width="100%">
			<xsl:call-template name="addStyle">
				<xsl:with-param name="name">block-level-element</xsl:with-param>
			</xsl:call-template>
			<xsl:choose>
				<xsl:when test="$isCompact">
					<xsl:call-template name="addStyle">
						<xsl:with-param name="name">notice.compact</xsl:with-param>
					</xsl:call-template>
				</xsl:when>
				<xsl:otherwise>
					<xsl:call-template name="addStyle">
						<xsl:with-param name="name">notice</xsl:with-param>
					</xsl:call-template>
					<xsl:if test="$insideTableCell = 'true'">
						<xsl:call-template name="addStyle">
							<xsl:with-param name="name">table.cell.notice</xsl:with-param>
						</xsl:call-template>
					</xsl:if>
				</xsl:otherwise>
			</xsl:choose>
			<xsl:if test="string-length($startIndent) &gt; 0 and $startIndent != '0'">
				<xsl:variable name="currWidth">
					<xsl:call-template name="getFormat">
						<xsl:with-param name="attributeName">width</xsl:with-param>
						<xsl:with-param name="name">
							<xsl:choose>
								<xsl:when test="$isCompact">notice.compact</xsl:when>
								<xsl:otherwise>notice</xsl:otherwise>
							</xsl:choose>
						</xsl:with-param>
						<xsl:with-param name="defaultValue">100%</xsl:with-param>
					</xsl:call-template>
				</xsl:variable>
				<xsl:attribute name="width">
					<xsl:value-of select="concat($currWidth, '-', $startIndent)"/>
				</xsl:attribute>
			</xsl:if>
			<xsl:apply-templates select="current()" mode="writeCharacterizationInfo">
				<xsl:with-param name="showContent" select="false()"/>
			</xsl:apply-templates>
			<xsl:variable name="useIconCol" select="not(starts-with($noticeCol1, '0') or $isCompact) and (not($useDefaultIcon = 'false') or string-length($iconname) &gt; 0 or $titlePosition = 'left' or $titlePosition = 'fixed-top-row')"/>
			<xsl:if test="$useIconCol">
				<fo:table-column column-width="{$noticeCol1}"/>
			</xsl:if>
			<fo:table-column column-width="{$noticeCol2}">
				<xsl:choose>
					<xsl:when test="$noticeCol2 = '*' or $noticeCol2 = ''">
						<xsl:attribute name="column-width">proportional-column-width(1)</xsl:attribute>
					</xsl:when>
				</xsl:choose>
			</fo:table-column>
			<xsl:variable name="colCount">
				<xsl:choose>
					<xsl:when test="$useIconCol">2</xsl:when>
					<xsl:otherwise>1</xsl:otherwise>
				</xsl:choose>
			</xsl:variable>

			<xsl:if test="$titlePosition = 'fixed-top-row'">
				<fo:table-header>
					<xsl:apply-templates select="current()" mode="writeFixedTopTitle">
						<xsl:with-param name="type" select="$type"/>
						<xsl:with-param name="useIconCol" select="$useIconCol"/>
						<xsl:with-param name="titlePosition" select="$titlePosition"/>
						<xsl:with-param name="useAlternativeIcon" select="$useAlternativeIcon"/>
						<xsl:with-param name="noticeIconWidth" select="$noticeIconWidth"/>
						<xsl:with-param name="iconname" select="$iconname"/>
					</xsl:apply-templates>
				</fo:table-header>
			</xsl:if>

			<fo:table-body start-indent="0">
				<xsl:apply-templates select="current()" mode="writeCharacterizationInfoRow">
					<xsl:with-param name="noBottom" select="true()"/>
					<xsl:with-param name="colCount" select="$colCount"/>
				</xsl:apply-templates>
				<xsl:if test="$titlePosition = 'top-row'">
					<xsl:apply-templates select="current()" mode="writeTopTitle">
						<xsl:with-param name="type" select="$type"/>
						<xsl:with-param name="useIconCol" select="$useIconCol"/>
					</xsl:apply-templates>
				</xsl:if>
				<fo:table-row>
					<xsl:if test="$useIconCol and not($titlePosition = 'fixed-top-row')">
						<xsl:apply-templates select="current()" mode="writeIconCell">
							<xsl:with-param name="type" select="$type"/>
							<xsl:with-param name="useIconCol" select="$useIconCol"/>
							<xsl:with-param name="titlePosition" select="$titlePosition"/>
							<xsl:with-param name="useAlternativeIcon" select="$useAlternativeIcon"/>
							<xsl:with-param name="noticeIconWidth" select="$noticeIconWidth"/>
							<xsl:with-param name="iconname" select="$iconname"/>
						</xsl:apply-templates>
					</xsl:if>
					<fo:table-cell>
						<xsl:choose>
							<xsl:when test="$isCompact">
								<xsl:call-template name="addStyle">
									<xsl:with-param name="name">notice.compact.cell.2</xsl:with-param>
								</xsl:call-template>
							</xsl:when>
							<xsl:otherwise>
								<xsl:call-template name="addStyle">
									<xsl:with-param name="name">notice.cell.2</xsl:with-param>
								</xsl:call-template>
							</xsl:otherwise>
						</xsl:choose>
						<xsl:if test="$useIconCol and $titlePosition = 'fixed-top-row'">
							<xsl:attribute name="number-columns-spanned">2</xsl:attribute>
						</xsl:if>
						<xsl:choose>
							<xsl:when test="($dontBreakAfterTitle = 'true' and $titlePosition = 'top') or $isCompact">
								<fo:block>
									<fo:inline>
										<xsl:choose>
											<xsl:when test="$isCompact">
												<xsl:call-template name="addStyle">
													<xsl:with-param name="name">notice.compact.title</xsl:with-param>
												</xsl:call-template>
											</xsl:when>
											<xsl:otherwise>
												<xsl:call-template name="addStyle">
													<xsl:with-param name="name">notice.title</xsl:with-param>
												</xsl:call-template>
											</xsl:otherwise>
										</xsl:choose>
										<xsl:variable name="compactTitle">
											<xsl:if test="$isCompact">
												<xsl:call-template name="translate">
													<xsl:with-param name="ID" select="concat($type, '.compact')"/>
												</xsl:call-template>
											</xsl:if>
										</xsl:variable>
										<xsl:choose>
											<xsl:when test="string-length($compactTitle) &gt; 0">
												<xsl:value-of select="$compactTitle"/>
											</xsl:when>
											<xsl:otherwise>
												<xsl:call-template name="translate">
													<xsl:with-param name="ID" select="$type"/>
												</xsl:call-template>
											</xsl:otherwise>
										</xsl:choose>
									</fo:inline>
									<xsl:text> </xsl:text>
									<fo:inline>
										<xsl:choose>
											<xsl:when test="$isCompact">
												<xsl:call-template name="addStyle">
													<xsl:with-param name="name">notice.compact.text</xsl:with-param>
												</xsl:call-template>
											</xsl:when>
											<xsl:otherwise>
												<xsl:call-template name="addStyle">
													<xsl:with-param name="name">notice.text</xsl:with-param>
												</xsl:call-template>
											</xsl:otherwise>
										</xsl:choose>
										<xsl:if test="string-length(cause) &gt; 0">
											<xsl:apply-templates select="cause/node()"/>
											<xsl:text> </xsl:text>
										</xsl:if>
										<xsl:if test="string-length(consequence) &gt; 0">
											<xsl:apply-templates select="consequence/node()"/>
											<xsl:text> </xsl:text>
										</xsl:if>
										<xsl:if test="string-length(measure) &gt; 0">
											<xsl:apply-templates select="measure/node()"/>
											<xsl:text> </xsl:text>
										</xsl:if>
										<xsl:apply-templates select="InfoPar.Warning/*" mode="inline-notice"/>
									</fo:inline>
								</fo:block>
							</xsl:when>
							<xsl:otherwise>
								<xsl:if test="$titlePosition = 'top'">
									<xsl:apply-templates select="current()" mode="writeNoticeTitle">
										<xsl:with-param name="type" select="$type"/>
									</xsl:apply-templates>
								</xsl:if>
								<fo:block>
									<xsl:call-template name="addStyle">
										<xsl:with-param name="name">notice.text</xsl:with-param>
									</xsl:call-template>
									<xsl:apply-templates select="cause" mode="notice"/>
									<xsl:apply-templates select="consequence" mode="notice"/>
									<xsl:apply-templates select="measure" mode="notice"/>
									<xsl:apply-templates select="InfoPar.Warning"/>
								</fo:block>
							</xsl:otherwise>
						</xsl:choose>
					</fo:table-cell>
				</fo:table-row>
			</fo:table-body>
		</fo:table>
	</xsl:template>

	<xsl:template match="InfoItem.Warning" mode="writeIconCell">
		<xsl:param name="type"/>
		<xsl:param name="titlePosition"/>
		<xsl:param name="useAlternativeIcon"/>
		<xsl:param name="noticeIconWidth"/>
		<xsl:param name="iconname"/>
		<fo:table-cell>
			<xsl:call-template name="addStyle">
				<xsl:with-param name="name">notice.cell.1</xsl:with-param>
			</xsl:call-template>
			<xsl:choose>
				<xsl:when test="$titlePosition = 'left'">
					<xsl:apply-templates select="current()" mode="writeNoticeTitle">
						<xsl:with-param name="type" select="$type"/>
					</xsl:apply-templates>
				</xsl:when>
				<xsl:when test="not($useAlternativeIcon = 'false') and count(Media.theme) &gt; 0">
					<xsl:apply-templates select="current()" mode="writeLanguageCode"/>
					<xsl:for-each select="Media.theme">
						<xsl:variable name="iconUri">
							<xsl:call-template name="getPicURL"/>
						</xsl:variable>
						<xsl:variable name="customNoticeIconWidth">
							<xsl:call-template name="getTemplateVariableValue">
								<xsl:with-param name="name" select="concat('NOTICE.', $type, '.CUSTOM.ICON.WIDTH')"/>
								<xsl:with-param name="defaultValue">
									<xsl:call-template name="getTemplateVariableValue">
										<xsl:with-param name="name" select="'NOTICE.CUSTOM.ICON.WIDTH'"/>
										<xsl:with-param name="defaultValue" select="$noticeIconWidth"/>
									</xsl:call-template>
								</xsl:with-param>
							</xsl:call-template>
						</xsl:variable>
						<xsl:variable name="customNoticeIconHeight">
							<xsl:call-template name="getTemplateVariableValue">
								<xsl:with-param name="name" select="concat('NOTICE.', $type, '.CUSTOM.ICON.HEIGHT')"/>
								<xsl:with-param name="defaultValue">
									<xsl:call-template name="getTemplateVariableValue">
										<xsl:with-param name="name" select="'NOTICE.CUSTOM.ICON.HEIGHT'"/>
									</xsl:call-template>
								</xsl:with-param>
							</xsl:call-template>
						</xsl:variable>
						<fo:block>
							<xsl:call-template name="addStyle">
								<xsl:with-param name="name">notice.icon</xsl:with-param>
							</xsl:call-template>
							<fo:external-graphic src="url('{$iconUri}')">
								<xsl:if test="$customNoticeIconWidth != 'auto'">
									<xsl:attribute name="width">
										<xsl:value-of select="$customNoticeIconWidth"/>
									</xsl:attribute>
									<xsl:attribute name="content-width">scale-to-fit</xsl:attribute>
								</xsl:if>
								<xsl:if test="string-length($customNoticeIconHeight) &gt; 0">
									<xsl:attribute name="height">
										<xsl:value-of select="$customNoticeIconHeight"/>
									</xsl:attribute>
									<xsl:attribute name="content-height">scale-to-fit</xsl:attribute>
								</xsl:if>
							</fo:external-graphic>
						</fo:block>
						<xsl:if test="$titlePosition = 'after-first-icon' and position() = 1">
							<xsl:apply-templates select="parent::*" mode="writeNoticeTitle">
								<xsl:with-param name="type" select="$type"/>
							</xsl:apply-templates>
						</xsl:if>
					</xsl:for-each>
				</xsl:when>
				<xsl:when test="string-length($iconname) &gt; 0">
					<xsl:apply-templates select="current()" mode="writeLanguageCode"/>
					<fo:block>
						<xsl:call-template name="addStyle">
							<xsl:with-param name="name">notice.icon</xsl:with-param>
						</xsl:call-template>
						<fo:external-graphic src="url('{$iconname}')" content-width="scale-to-fit" width="{$noticeIconWidth}"/>
					</fo:block>
					<xsl:if test="$titlePosition = 'after-first-icon'">
						<xsl:apply-templates select="current()" mode="writeNoticeTitle">
							<xsl:with-param name="type" select="$type"/>
						</xsl:apply-templates>
					</xsl:if>
				</xsl:when>
				<xsl:when test="$titlePosition = 'after-first-icon'">
					<xsl:apply-templates select="current()" mode="writeNoticeTitle">
						<xsl:with-param name="type" select="$type"/>
					</xsl:apply-templates>
				</xsl:when>
			</xsl:choose>
		</fo:table-cell>
	</xsl:template>

	<xsl:template match="InfoItem.Warning" mode="writeTopTitle">
		<xsl:param name="type"/>
		<xsl:param name="useIconCol"/>
		<fo:table-row>
			<fo:table-cell>
				<xsl:if test="$useIconCol">
					<xsl:attribute name="number-columns-spanned">2</xsl:attribute>
				</xsl:if>
				<xsl:call-template name="addStyle">
					<xsl:with-param name="name">notice.cell.title</xsl:with-param>
				</xsl:call-template>
				<xsl:apply-templates select="current()" mode="writeNoticeTitle">
					<xsl:with-param name="type" select="$type"/>
				</xsl:apply-templates>
			</fo:table-cell>
		</fo:table-row>
	</xsl:template>

	<xsl:template match="InfoItem.Warning" mode="writeFixedTopTitle">
		<xsl:param name="type"/>
		<xsl:param name="useIconCol"/>
		<xsl:param name="titlePosition"/>
		<xsl:param name="useAlternativeIcon"/>
		<xsl:param name="noticeIconWidth"/>
		<xsl:param name="iconname"/>
		<fo:table-row>
				<xsl:if test="$useIconCol">
					<xsl:apply-templates select="current()" mode="writeIconCell">
						<xsl:with-param name="type" select="$type"/>
						<xsl:with-param name="useIconCol" select="$useIconCol"/>
						<xsl:with-param name="titlePosition" select="$titlePosition"/>
						<xsl:with-param name="useAlternativeIcon" select="$useAlternativeIcon"/>
						<xsl:with-param name="noticeIconWidth" select="$noticeIconWidth"/>
						<xsl:with-param name="iconname" select="$iconname"/>
					</xsl:apply-templates>
				</xsl:if>
			<fo:table-cell>
				<xsl:call-template name="addStyle">
					<xsl:with-param name="name">notice.cell.title</xsl:with-param>
				</xsl:call-template>
				<xsl:apply-templates select="current()" mode="writeNoticeTitle">
					<xsl:with-param name="type" select="$type"/>
				</xsl:apply-templates>
			</fo:table-cell>
		</fo:table-row>
	</xsl:template>

	<xsl:template match="InfoItem.Warning" mode="writeLanguageCode">
		<xsl:variable name="showLanguageCode">
			<xsl:call-template name="getTemplateVariableValue">
				<xsl:with-param name="name">NOTICE_SHOW_LANGUAGE_CODE</xsl:with-param>
			</xsl:call-template>
		</xsl:variable>
		<xsl:if test="$showLanguageCode = 'true'">
			<fo:block>
				<xsl:call-template name="addStyle">
					<xsl:with-param name="name">notice.languagecode</xsl:with-param>
				</xsl:call-template>
				<xsl:value-of select="ancestor-or-self::*[@defaultLanguage or @Lang][1]/@*[name() = 'defaultLanguage' or name() = 'Lang']"/>
			</fo:block>
		</xsl:if>
	</xsl:template>

	<xsl:template match="cause | consequence | measure" mode="notice">
		<xsl:if test="string-length(.) &gt; 0">
			<fo:block>
				<xsl:call-template name="addStyle">
					<xsl:with-param name="name" select="concat('notice.', name())"/>
				</xsl:call-template>
				<xsl:apply-templates/>
			</fo:block>
		</xsl:if>
	</xsl:template>

	<xsl:template match="InfoItem.Warning" mode="writeNoticeTitle">
		<xsl:param name="type"/>
		<fo:block>
			<xsl:call-template name="addStyle">
				<xsl:with-param name="name">notice.title</xsl:with-param>
			</xsl:call-template>
			<fo:inline>
				<xsl:call-template name="addStyle">
					<xsl:with-param name="name">notice.title.text</xsl:with-param>
				</xsl:call-template>
				<xsl:call-template name="translate">
					<xsl:with-param name="ID" select="$type"/>
				</xsl:call-template>
			</fo:inline>
		</fo:block>
	</xsl:template>

	<xsl:template match="*" mode="inline-notice">
		<xsl:apply-templates select="current()"/>
	</xsl:template>

	<xsl:template match="InfoPar" mode="inline-notice">
		<xsl:apply-templates/>
	</xsl:template>

	<xsl:template match="InfoItem.Warning" mode="single-block">
		<xsl:param name="defaultType">Warning</xsl:param>

		<xsl:variable name="type">
			<xsl:choose>
				<xsl:when test="string-length(@type) = 0">
					<xsl:value-of select="$defaultType"/>
				</xsl:when>
				<xsl:otherwise>
					<xsl:value-of select="@type"/>
				</xsl:otherwise>
			</xsl:choose>
		</xsl:variable>

		<fo:block>
			<xsl:call-template name="addStyle">
				<xsl:with-param name="name">notice</xsl:with-param>
			</xsl:call-template>
			<fo:block>
				<fo:inline>
					<xsl:call-template name="addStyle">
						<xsl:with-param name="name">notice.title</xsl:with-param>
					</xsl:call-template>
					<xsl:call-template name="translate">
						<xsl:with-param name="ID" select="$type"/>
					</xsl:call-template>
					<xsl:text> </xsl:text>
				</fo:inline>
				<fo:inline>
					<xsl:call-template name="addStyle">
						<xsl:with-param name="name">notice.text</xsl:with-param>
					</xsl:call-template>
					<xsl:apply-templates select="InfoPar.Warning"/>
				</fo:inline>
			</fo:block>
		</fo:block>
	</xsl:template>

	<xsl:template match="InfoPar.Warning">
		<xsl:apply-templates>
			<xsl:with-param name="isInsideNotice" select="1 = 1"/>
		</xsl:apply-templates>
	</xsl:template>

	<xsl:template match="InfoItem.Warning" mode="getIcon">
		<xsl:param name="type"/>
		<xsl:param name="iconFileExtension"/>
		<xsl:param name="useAlternativeIcon" select="true()"/>

		<xsl:variable name="pic_url">
			<xsl:call-template name="getTemplateGraphicURL">
				<xsl:with-param name="name" select="concat('notice.', $type)"/>
				<xsl:with-param name="language" select="ancestor::InfoMap[1]/@Lang"/>
			</xsl:call-template>
		</xsl:variable>

		<xsl:choose>
			<xsl:when test="$useAlternativeIcon and Media.theme">
				<xsl:for-each select="Media.theme[1]">
					<xsl:call-template name="getPicURL"/>
				</xsl:for-each>
			</xsl:when>
			<xsl:when test="string-length($pic_url) &gt; 0">
				<xsl:value-of select="$pic_url"/>
			</xsl:when>
			<xsl:when test="string-length($iconFileExtension) &gt; 0">
				<xsl:value-of select="concat($clientImageAssetsPath, 'fopassets/', $type, '.', $iconFileExtension)"/>
			</xsl:when>
		</xsl:choose>
	</xsl:template>

</xsl:stylesheet>