<?xml version="1.0" encoding="utf-8"?>
<xsl:stylesheet
	xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
	xmlns:fo="http://www.w3.org/1999/XSL/Format"
	version="1.0">

	<xsl:template match="*" mode="writePageReferenceNumber">
		<xsl:param name="RefID"/>

		<xsl:variable name="customRestartNumbering">
			<xsl:call-template name="getFormat">
				<xsl:with-param name="name">headline.content.1</xsl:with-param>
				<xsl:with-param name="attributeName">initial-page-number</xsl:with-param>
			</xsl:call-template>
		</xsl:variable>

		<xsl:variable name="customPageBreakBefore">
			<xsl:call-template name="getFormat">
				<xsl:with-param name="name">headline.content.1</xsl:with-param>
				<xsl:with-param name="attributeName">page-break-before</xsl:with-param>
			</xsl:call-template>
		</xsl:variable>

		<xsl:variable name="doCustomPageBreakBefore" select="$customPageBreakBefore = 'always' or $customPageBreakBefore = 'left' or $customPageBreakBefore = 'right'"/>

		<xsl:if test="string(number($customRestartNumbering)) != 'NaN' and $doCustomPageBreakBefore">
			<xsl:variable name="chapterNr">
				<xsl:for-each select="key('InfoMapKey', $RefID)/ancestor-or-self::InfoMap[@level = $BASE_LEVEL]">
					<xsl:apply-templates select="current()" mode="getChapterNr">
						<xsl:with-param name="removePointSuffix">true</xsl:with-param>
					</xsl:apply-templates>
				</xsl:for-each>
			</xsl:variable>
			<xsl:if test="string-length($chapterNr) &gt; 0">
				<xsl:value-of select="$chapterNr"/>
				<xsl:text>-</xsl:text>
			</xsl:if>
		</xsl:if>

		<fo:page-number-citation ref-id="{$RefID}"/>
	</xsl:template>

	<xsl:template match="*" mode="getSectionNr">
		<xsl:param name="RefID" select="@RefID"/>
		<xsl:param name="useNrPrefix" select="true()"/>
		<xsl:apply-templates select="(key('InfoMapKey', $RefID))[1]" mode="getChapterNr">
			<xsl:with-param name="useNrPrefix" select="$useNrPrefix"/>
		</xsl:apply-templates>
	</xsl:template>

	<xsl:template match="*" mode="getLinkText">
		<xsl:param name="base"/>
		<xsl:param name="applyBaseText"/>
		<xsl:param name="defaultFormat"/>
		<xsl:param name="previewFormat"/>
		<xsl:apply-templates select="current()" mode="getLinkTextSimple">
			<xsl:with-param name="base" select="$base"/>
			<xsl:with-param name="defaultFormat" select="$defaultFormat"/>
			<xsl:with-param name="previewFormat" select="$previewFormat"/>
			<xsl:with-param name="skipCorruptLinks" select="false()"/>
			<xsl:with-param name="useAlternativeNrTitleFormat" select="false()"/>
			<xsl:with-param name="applyBaseText" select="$applyBaseText"/>
		</xsl:apply-templates>
	</xsl:template>

	<xsl:template match="*" mode="getLinkTextOpeningQuotationMarks">
		<xsl:param name="format"/>
		<xsl:variable name="val">
			<xsl:call-template name="getTemplateVariableValue">
				<xsl:with-param name="name" select="concat('LINK_TEXT_OPENING_QUOTATION_MARKS_', $format, '_', $language)"/>
				<xsl:with-param name="defaultValue">
					<xsl:call-template name="getTemplateVariableValue">
						<xsl:with-param name="name" select="concat('LINK_TEXT_OPENING_QUOTATION_MARKS_', $format)"/>
						<xsl:with-param name="defaultValue">
							<xsl:call-template name="getTemplateVariableValue">
								<xsl:with-param name="name" select="concat('LINK_TEXT_OPENING_QUOTATION_MARKS_', $language)"/>
								<xsl:with-param name="defaultValue">
									<xsl:call-template name="getTemplateVariableValue">
										<xsl:with-param name="name">LINK_TEXT_OPENING_QUOTATION_MARKS</xsl:with-param>
										<xsl:with-param name="defaultValue">"</xsl:with-param>
									</xsl:call-template>
								</xsl:with-param>
							</xsl:call-template>
						</xsl:with-param>
					</xsl:call-template>
				</xsl:with-param>
			</xsl:call-template>
		</xsl:variable>
		<xsl:if test="$val != 'none'">
			<xsl:value-of select="$val"/>
		</xsl:if>
	</xsl:template>

	<xsl:template match="*" mode="getLinkTextClosingQuotationMarks">
		<xsl:param name="format"/>
		<xsl:variable name="val">
			<xsl:call-template name="getTemplateVariableValue">
				<xsl:with-param name="name" select="concat('LINK_TEXT_CLOSING_QUOTATION_MARKS_', $format, '_', $language)"/>
				<xsl:with-param name="defaultValue">
					<xsl:call-template name="getTemplateVariableValue">
						<xsl:with-param name="name" select="concat('LINK_TEXT_CLOSING_QUOTATION_MARKS_', $format)"/>
						<xsl:with-param name="defaultValue">
							<xsl:call-template name="getTemplateVariableValue">
								<xsl:with-param name="name" select="concat('LINK_TEXT_CLOSING_QUOTATION_MARKS_', $language)"/>
								<xsl:with-param name="defaultValue">
									<xsl:call-template name="getTemplateVariableValue">
										<xsl:with-param name="name">LINK_TEXT_CLOSING_QUOTATION_MARKS</xsl:with-param>
										<xsl:with-param name="defaultValue">"</xsl:with-param>
									</xsl:call-template>
								</xsl:with-param>
							</xsl:call-template>
						</xsl:with-param>
					</xsl:call-template>
				</xsl:with-param>
			</xsl:call-template>
		</xsl:variable>
		<xsl:if test="$val != 'none'">
			<xsl:value-of select="$val"/>
		</xsl:if>
	</xsl:template>

	<xsl:template match="*" mode="writePageReference">
		<xsl:param name="existsTarget"/>
		<xsl:param name="RefID"/>
		<xsl:param name="doPreviewFormat"/>

		<xsl:variable name="isAsian" select="$language = 'ja' or starts-with($language, 'zh')"/>

		<fo:inline keep-together="always">
			<xsl:if test="not($isAsian)">
				<xsl:call-template name="translate">
					<xsl:with-param name="ID">Page</xsl:with-param>
				</xsl:call-template>
				<xsl:text> </xsl:text>
			</xsl:if>
			<xsl:choose>
				<xsl:when test="$existsTarget">
					<xsl:apply-templates select="current()" mode="writePageReferenceNumber">
						<xsl:with-param name="RefID" select="$RefID"/>
					</xsl:apply-templates>
				</xsl:when>
				<xsl:when test="$doPreviewFormat">X</xsl:when>
			</xsl:choose>
			<xsl:if test="$isAsian">
				<xsl:text> </xsl:text>
				<xsl:call-template name="translate">
					<xsl:with-param name="ID">Page</xsl:with-param>
				</xsl:call-template>
			</xsl:if>
		</fo:inline>
	</xsl:template>

	<xsl:template match="*" mode="writeLinkBaseText">
		<xsl:param name="base"/>
		<xsl:param name="applyBaseText"/>
		<xsl:choose>
			<xsl:when test="$applyBaseText">
				<xsl:apply-templates select="current()" mode="getLinkBaseText"/>
			</xsl:when>
			<xsl:otherwise>
				<xsl:value-of select="$base"/>
			</xsl:otherwise>
		</xsl:choose>
	</xsl:template>

	<xsl:template match="*" mode="getLinkTextSimple">
		<xsl:param name="base"/>
		<xsl:param name="defaultFormat"/>
		<xsl:param name="previewFormat"/>
		<xsl:param name="skipCorruptLinks" select="false()"/>
		<xsl:param name="useAlternativeNrTitleFormat" select="false()"/>
		<xsl:param name="applyBaseText"/>

		<xsl:variable name="RefID" select="string(@RefID)"/>

		<xsl:variable name="linkElemName">
			<xsl:choose>
				<xsl:when test="name() = 'link.element'">ELEMENT</xsl:when>
				<xsl:when test="name() = 'Link.Detail'">DETAIL</xsl:when>
				<xsl:otherwise>XREF</xsl:otherwise>
			</xsl:choose>
		</xsl:variable>
		
		<xsl:variable name="format">
			<xsl:choose>
				<xsl:when test="string-length(@format) &gt; 0">
					<xsl:call-template name="getTemplateVariableValue">
						<xsl:with-param name="name" select="concat('LINK_', $linkElemName, '_', @format, '_FORMAT')"/>
						<xsl:with-param name="defaultValue" select="@format"/>
					</xsl:call-template>
				</xsl:when>
				<xsl:when test="string-length($defaultFormat) &gt; 0">
					<xsl:value-of select="$defaultFormat"/>
				</xsl:when>
			</xsl:choose>
		</xsl:variable>

		<xsl:variable name="linkXrefTarget" select="(key('InfoMapKey', $RefID))[1]"/>

		<xsl:variable name="existsTarget" select="string-length($RefID) &gt; 0 and (
					  (name() = 'Link.XRef' and boolean($linkXrefTarget))
					  or (name() = 'Link.Detail' and boolean(key('BlockKey', $RefID)))
					  or (name() = 'link.element' and boolean(key('LinkElementKey', $RefID)))
					  )"/>

		<xsl:variable name="doPreviewFormat" select="$previewFormat = 'true' and not($Offline = 'Offline')"/>

		<xsl:variable name="targetLevel">
			<xsl:apply-templates select="$linkXrefTarget" mode="getCurrentLevel"/>
		</xsl:variable>
		
		<xsl:variable name="chapterStringId">
			<xsl:call-template name="getTemplateVariableValue">
				<xsl:with-param name="name" select="concat('LINK_', $linkElemName, '_CHAPTER_STRING_ID_', $targetLevel)"/>
				<xsl:with-param name="defaultValue">
					<xsl:call-template name="getTemplateVariableValue">
						<xsl:with-param name="name" select="concat('LINK_', $linkElemName, '_CHAPTER_STRING_ID')"/>
						<xsl:with-param name="defaultValue">Chapter</xsl:with-param>
					</xsl:call-template>
				</xsl:with-param>
			</xsl:call-template>
		</xsl:variable>

		<xsl:variable name="linkTextSeparatorPre">
			<xsl:choose>
				<xsl:when test="string-length(@format) &gt; 0">
					<xsl:call-template name="getTemplateVariableValue">
						<xsl:with-param name="name" select="concat('LINK_', $linkElemName, '_', @format, '_TEXT_ITEM_SEPARATOR')"/>
						<xsl:with-param name="defaultValue">
							<xsl:call-template name="getTemplateVariableValue">
								<xsl:with-param name="name" select="concat('LINK_', $linkElemName, '_TEXT_ITEM_SEPARATOR')"/>
								<xsl:with-param name="defaultValue">,</xsl:with-param>
							</xsl:call-template>
						</xsl:with-param>
					</xsl:call-template>
				</xsl:when>
				<xsl:otherwise>
					<xsl:call-template name="getTemplateVariableValue">
						<xsl:with-param name="name" select="concat('LINK_', $linkElemName, '_TEXT_ITEM_SEPARATOR')"/>
						<xsl:with-param name="defaultValue">,</xsl:with-param>
					</xsl:call-template>
				</xsl:otherwise>
			</xsl:choose>
		</xsl:variable>

		<xsl:variable name="linkTextSeparator">
			<xsl:if test="not($linkTextSeparatorPre = 'none')">
				<xsl:value-of select="$linkTextSeparatorPre"/>
			</xsl:if>
		</xsl:variable>

		<xsl:choose>
			<xsl:when test="$format = 'PageFF' or $format = 'Page ff'">
				<xsl:value-of select="$base"/>
				<xsl:text> </xsl:text>
				<xsl:call-template name="translate">
					<xsl:with-param name="ID">AndFollowing</xsl:with-param>
				</xsl:call-template>
				<xsl:if test="$existsTarget or $doPreviewFormat">
					<xsl:text> </xsl:text>
					<xsl:call-template name="translate">
						<xsl:with-param name="ID">From</xsl:with-param>
					</xsl:call-template>
					<xsl:text> </xsl:text>
					<xsl:apply-templates select="current()" mode="writePageReference">
						<xsl:with-param name="doPreviewFormat" select="$doPreviewFormat"/>
						<xsl:with-param name="existsTarget" select="$existsTarget"/>
						<xsl:with-param name="RefID" select="$RefID"/>
					</xsl:apply-templates>
				</xsl:if>
			</xsl:when>
			<xsl:when test="$format = 'SeePageSection'">
				<xsl:call-template name="translate">
					<xsl:with-param name="ID">See</xsl:with-param>
				</xsl:call-template>
				<xsl:text> </xsl:text>
				<xsl:apply-templates select="current()" mode="writeLinkBaseText">
					<xsl:with-param name="base" select="$base"/>
					<xsl:with-param name="applyBaseText" select="$applyBaseText"/>
				</xsl:apply-templates>
				<xsl:text> </xsl:text>
				<xsl:call-template name="translate">
					<xsl:with-param name="ID">In</xsl:with-param>
				</xsl:call-template>
				<xsl:call-template name="translate">
					<xsl:with-param name="ID">Section</xsl:with-param>
				</xsl:call-template>
				<xsl:text> </xsl:text>
				<xsl:apply-templates select="current()" mode="getSectionNr"/>
				<xsl:text> </xsl:text>
				<xsl:value-of select="@TargetTitle"/>
				<xsl:if test="$existsTarget or $doPreviewFormat">
					<xsl:value-of select="$linkTextSeparator"/>
					<xsl:text> </xsl:text>
					<xsl:apply-templates select="current()" mode="writePageReference">
						<xsl:with-param name="doPreviewFormat" select="$doPreviewFormat"/>
						<xsl:with-param name="existsTarget" select="$existsTarget"/>
						<xsl:with-param name="RefID" select="$RefID"/>
					</xsl:apply-templates>
				</xsl:if>
			</xsl:when>
			<xsl:when test="$format = 'Page' and ($existsTarget or $doPreviewFormat)">
				<xsl:apply-templates select="current()" mode="getLinkTextOpeningQuotationMarks">
					<xsl:with-param name="format" select="$format"/>
				</xsl:apply-templates>
				<xsl:apply-templates select="current()" mode="writeLinkBaseText">
					<xsl:with-param name="base" select="$base"/>
					<xsl:with-param name="applyBaseText" select="$applyBaseText"/>
				</xsl:apply-templates>
				<xsl:apply-templates select="current()" mode="getLinkTextClosingQuotationMarks">
					<xsl:with-param name="format" select="$format"/>
				</xsl:apply-templates>
				<xsl:value-of select="$linkTextSeparator"/>
				<xsl:text> </xsl:text>
				<xsl:apply-templates select="current()" mode="writePageReference">
					<xsl:with-param name="doPreviewFormat" select="$doPreviewFormat"/>
					<xsl:with-param name="existsTarget" select="$existsTarget"/>
					<xsl:with-param name="RefID" select="$RefID"/>
				</xsl:apply-templates>
			</xsl:when>
			<xsl:when test="$format = 'PageNr' and ($existsTarget or $doPreviewFormat or $skipCorruptLinks)">
				<xsl:choose>
					<xsl:when test="$existsTarget">
						<xsl:apply-templates select="current()" mode="writePageReferenceNumber">
							<xsl:with-param name="RefID" select="$RefID"/>
						</xsl:apply-templates>
					</xsl:when>
					<xsl:when test="$doPreviewFormat">X</xsl:when>
				</xsl:choose>
			</xsl:when>
			<xsl:when test="$format = 'PagePageNr' and ($existsTarget or $doPreviewFormat)">
				<xsl:apply-templates select="current()" mode="writePageReference">
					<xsl:with-param name="doPreviewFormat" select="$doPreviewFormat"/>
					<xsl:with-param name="existsTarget" select="$existsTarget"/>
					<xsl:with-param name="RefID" select="$RefID"/>
				</xsl:apply-templates>
			</xsl:when>
			<xsl:when test="$format = 'SeePagePageNr' and ($existsTarget or $doPreviewFormat)">
				<xsl:call-template name="translate">
					<xsl:with-param name="ID">See</xsl:with-param>
				</xsl:call-template>
				<xsl:text> </xsl:text>
				<xsl:apply-templates select="current()" mode="writePageReference">
					<xsl:with-param name="doPreviewFormat" select="$doPreviewFormat"/>
					<xsl:with-param name="existsTarget" select="$existsTarget"/>
					<xsl:with-param name="RefID" select="$RefID"/>
				</xsl:apply-templates>
			</xsl:when>
			<xsl:when test="$format = 'Section'">
				<xsl:apply-templates select="current()" mode="writeLinkBaseText">
					<xsl:with-param name="base" select="$base"/>
					<xsl:with-param name="applyBaseText" select="$applyBaseText"/>
				</xsl:apply-templates>
				<xsl:text> </xsl:text>
				<xsl:call-template name="translate">
					<xsl:with-param name="ID">In</xsl:with-param>
				</xsl:call-template>
				<xsl:call-template name="translate">
					<xsl:with-param name="ID">Section</xsl:with-param>
				</xsl:call-template>
				<xsl:text> </xsl:text>
				<xsl:apply-templates select="current()" mode="getSectionNr"/>
				<xsl:text> </xsl:text>
				<xsl:value-of select="@TargetTitle"/>
			</xsl:when>
			<xsl:when test="$format = 'SeePage' and ($existsTarget or $doPreviewFormat)">
				<xsl:call-template name="translate">
					<xsl:with-param name="ID">See</xsl:with-param>
				</xsl:call-template>
				<xsl:text> </xsl:text>
				<xsl:apply-templates select="current()" mode="getLinkTextOpeningQuotationMarks">
					<xsl:with-param name="format" select="$format"/>
				</xsl:apply-templates>
				<xsl:apply-templates select="current()" mode="writeLinkBaseText">
					<xsl:with-param name="base" select="$base"/>
					<xsl:with-param name="applyBaseText" select="$applyBaseText"/>
				</xsl:apply-templates>
				<xsl:apply-templates select="current()" mode="getLinkTextClosingQuotationMarks">
					<xsl:with-param name="format" select="$format"/>
				</xsl:apply-templates>
				<xsl:value-of select="$linkTextSeparator"/>
				<xsl:text> </xsl:text>
				<xsl:apply-templates select="current()" mode="writePageReference">
					<xsl:with-param name="doPreviewFormat" select="$doPreviewFormat"/>
					<xsl:with-param name="existsTarget" select="$existsTarget"/>
					<xsl:with-param name="RefID" select="$RefID"/>
				</xsl:apply-templates>
			</xsl:when>
			<xsl:when test="$format = 'SeeNrPagePageNr' and ($existsTarget or $doPreviewFormat)">
				<xsl:call-template name="translate">
					<xsl:with-param name="ID">See</xsl:with-param>
				</xsl:call-template>
				<xsl:text> </xsl:text>
				<xsl:value-of select="$base"/>
				<xsl:value-of select="$linkTextSeparator"/>
				<xsl:text> </xsl:text>
				<xsl:apply-templates select="current()" mode="writePageReference">
					<xsl:with-param name="doPreviewFormat" select="$doPreviewFormat"/>
					<xsl:with-param name="existsTarget" select="$existsTarget"/>
					<xsl:with-param name="RefID" select="$RefID"/>
				</xsl:apply-templates>
			</xsl:when>
			<xsl:when test="$format = 'Title'">
				<xsl:apply-templates select="current()" mode="writeLinkBaseText">
					<xsl:with-param name="base" select="$base"/>
					<xsl:with-param name="applyBaseText" select="$applyBaseText"/>
				</xsl:apply-templates>
			</xsl:when>
			<xsl:when test="$format = 'Nr' and name() = 'Link.XRef'">
				<fo:inline keep-together="always">
					<xsl:call-template name="translate">
						<xsl:with-param name="ID" select="$chapterStringId"/>
					</xsl:call-template>
					<xsl:text> </xsl:text>
					<xsl:apply-templates select="current()" mode="getSectionNr"/>
				</fo:inline>
			</xsl:when>
			<xsl:when test="$format = 'NrOnly' and name() = 'Link.XRef'">
				<xsl:apply-templates select="current()" mode="getSectionNr"/>
			</xsl:when>
			<xsl:when test="$format = 'ChapterNrTitle' and name() = 'Link.XRef'">
				<fo:inline keep-together="always">
					<xsl:call-template name="translate">
						<xsl:with-param name="ID" select="$chapterStringId"/>
					</xsl:call-template>
					<xsl:text> </xsl:text>
					<xsl:apply-templates select="current()" mode="getSectionNr"/>
				</fo:inline>
				<xsl:value-of select="$linkTextSeparator"/>
				<xsl:text> </xsl:text>
				<xsl:apply-templates select="current()" mode="getLinkTextOpeningQuotationMarks">
					<xsl:with-param name="format" select="$format"/>
				</xsl:apply-templates>
				<xsl:apply-templates select="current()" mode="writeLinkBaseText">
					<xsl:with-param name="base" select="$base"/>
					<xsl:with-param name="applyBaseText" select="$applyBaseText"/>
				</xsl:apply-templates>
				<xsl:apply-templates select="current()" mode="getLinkTextClosingQuotationMarks">
					<xsl:with-param name="format" select="$format"/>
				</xsl:apply-templates>
			</xsl:when>
			<xsl:when test="$format = 'SeeChapterNrTitlePagePageNr' and name() = 'Link.XRef'">
				<xsl:call-template name="translate">
					<xsl:with-param name="ID">See</xsl:with-param>
				</xsl:call-template>
				<xsl:text> </xsl:text>
				<fo:inline keep-together="always">
					<xsl:call-template name="translate">
						<xsl:with-param name="ID" select="$chapterStringId"/>
					</xsl:call-template>
					<xsl:text> </xsl:text>
					<xsl:apply-templates select="current()" mode="getSectionNr"/>
				</fo:inline>
				<xsl:value-of select="$linkTextSeparator"/>
				<xsl:text> </xsl:text>
				<xsl:apply-templates select="current()" mode="getLinkTextOpeningQuotationMarks">
					<xsl:with-param name="format" select="$format"/>
				</xsl:apply-templates>
				<xsl:apply-templates select="current()" mode="writeLinkBaseText">
					<xsl:with-param name="base" select="$base"/>
					<xsl:with-param name="applyBaseText" select="$applyBaseText"/>
				</xsl:apply-templates>
				<xsl:apply-templates select="current()" mode="getLinkTextClosingQuotationMarks">
					<xsl:with-param name="format" select="$format"/>
				</xsl:apply-templates>
				<xsl:if test="$existsTarget or $doPreviewFormat">
					<xsl:value-of select="$linkTextSeparator"/>
					<xsl:text> </xsl:text>
					<xsl:apply-templates select="current()" mode="writePageReference">
						<xsl:with-param name="doPreviewFormat" select="$doPreviewFormat"/>
						<xsl:with-param name="existsTarget" select="$existsTarget"/>
						<xsl:with-param name="RefID" select="$RefID"/>
					</xsl:apply-templates>
				</xsl:if>
			</xsl:when>
			<xsl:when test="$format = 'Nr'">
				<xsl:apply-templates select="current()" mode="writeLinkBaseText">
					<xsl:with-param name="base" select="$base"/>
					<xsl:with-param name="applyBaseText" select="$applyBaseText"/>
				</xsl:apply-templates>
			</xsl:when>
			<xsl:when test="$format = 'SeeNr' and name() = 'Link.XRef'">
				<xsl:call-template name="translate">
					<xsl:with-param name="ID">See</xsl:with-param>
				</xsl:call-template>
				<xsl:text> </xsl:text>
				<fo:inline keep-together="always">
					<xsl:call-template name="translate">
						<xsl:with-param name="ID" select="$chapterStringId"/>
					</xsl:call-template>
					<xsl:text> </xsl:text>
					<xsl:apply-templates select="current()" mode="getSectionNr"/>
				</fo:inline>
			</xsl:when>
			<xsl:when test="$format = 'SeeNr'">
				<xsl:call-template name="translate">
					<xsl:with-param name="ID">See</xsl:with-param>
				</xsl:call-template>
				<xsl:text> </xsl:text>
				<xsl:apply-templates select="current()" mode="writeLinkBaseText">
					<xsl:with-param name="base" select="$base"/>
					<xsl:with-param name="applyBaseText" select="$applyBaseText"/>
				</xsl:apply-templates>
			</xsl:when>
			<xsl:when test="$format = 'NrTitle'">
				<xsl:choose>
					<xsl:when test="$useAlternativeNrTitleFormat">
						<xsl:apply-templates select="current()" mode="getSectionNr"/>
						<xsl:value-of select="$linkTextSeparator"/>
						<xsl:text> </xsl:text>
						<xsl:apply-templates select="current()" mode="writeLinkBaseText">
							<xsl:with-param name="base" select="$base"/>
							<xsl:with-param name="applyBaseText" select="$applyBaseText"/>
						</xsl:apply-templates>
					</xsl:when>
					<xsl:otherwise>
						<xsl:apply-templates select="current()" mode="getSectionNr"/>
						<xsl:text> </xsl:text>
						<xsl:apply-templates select="current()" mode="getLinkTextOpeningQuotationMarks">
							<xsl:with-param name="format" select="$format"/>
						</xsl:apply-templates>
						<xsl:apply-templates select="current()" mode="writeLinkBaseText">
							<xsl:with-param name="base" select="$base"/>
							<xsl:with-param name="applyBaseText" select="$applyBaseText"/>
						</xsl:apply-templates>
						<xsl:apply-templates select="current()" mode="getLinkTextClosingQuotationMarks">
							<xsl:with-param name="format" select="$format"/>
						</xsl:apply-templates>
					</xsl:otherwise>
				</xsl:choose>
			</xsl:when>
			<xsl:when test="$format = 'NrTitlePage' and ($existsTarget or $doPreviewFormat)">
				<xsl:apply-templates select="current()" mode="getSectionNr"/>
				<xsl:text> </xsl:text>
				<xsl:apply-templates select="current()" mode="getLinkTextOpeningQuotationMarks">
					<xsl:with-param name="format" select="$format"/>
				</xsl:apply-templates>
				<xsl:apply-templates select="current()" mode="writeLinkBaseText">
					<xsl:with-param name="base" select="$base"/>
					<xsl:with-param name="applyBaseText" select="$applyBaseText"/>
				</xsl:apply-templates>
				<xsl:apply-templates select="current()" mode="getLinkTextClosingQuotationMarks">
					<xsl:with-param name="format" select="$format"/>
				</xsl:apply-templates>
				<xsl:value-of select="$linkTextSeparator"/>
				<xsl:text> </xsl:text>
				<xsl:apply-templates select="current()" mode="writePageReference">
					<xsl:with-param name="doPreviewFormat" select="$doPreviewFormat"/>
					<xsl:with-param name="existsTarget" select="$existsTarget"/>
					<xsl:with-param name="RefID" select="$RefID"/>
				</xsl:apply-templates>
			</xsl:when>

			<xsl:when test="$format = 'See' or $format = 'SeePage'">
				<xsl:call-template name="translate">
					<xsl:with-param name="ID">See</xsl:with-param>
				</xsl:call-template>
				<xsl:text> </xsl:text>
				<xsl:apply-templates select="current()" mode="getLinkTextOpeningQuotationMarks">
					<xsl:with-param name="format" select="$format"/>
				</xsl:apply-templates>
				<xsl:apply-templates select="current()" mode="writeLinkBaseText">
					<xsl:with-param name="base" select="$base"/>
					<xsl:with-param name="applyBaseText" select="$applyBaseText"/>
				</xsl:apply-templates>
				<xsl:apply-templates select="current()" mode="getLinkTextClosingQuotationMarks">
					<xsl:with-param name="format" select="$format"/>
				</xsl:apply-templates>
			</xsl:when>

			<xsl:otherwise>
				<xsl:apply-templates select="current()" mode="getLinkTextOpeningQuotationMarks">
					<xsl:with-param name="format" select="$format"/>
				</xsl:apply-templates>
				<!--<xsl:choose>
					<xsl:when test="exslt:node-set($base)/node()">
						<xsl:apply-templates select="current()" mode="writeLinkBaseText">
							<xsl:with-param name="base" select="exslt:node-set($base)/node()"/>
							<xsl:with-param name="applyBaseText" select="$applyBaseText"/>
						</xsl:apply-templates>
					</xsl:when>
					<xsl:otherwise>-->
						<xsl:apply-templates select="current()" mode="writeLinkBaseText">
							<xsl:with-param name="base" select="$base"/>
							<xsl:with-param name="applyBaseText" select="$applyBaseText"/>
						</xsl:apply-templates>
					<!--</xsl:otherwise>
				</xsl:choose>-->
				<xsl:apply-templates select="current()" mode="getLinkTextClosingQuotationMarks">
					<xsl:with-param name="format" select="$format"/>
				</xsl:apply-templates>
			</xsl:otherwise>
		</xsl:choose>
	</xsl:template>

	<xsl:template match = "*" mode = "base">
		<xsl:apply-templates/>
	</xsl:template>

	<xsl:template match = "text()" mode = "base">
		<xsl:value-of select="."/>
	</xsl:template>




	<xsl:template match="*" mode="getLinkChapterNr">
		<xsl:param name="RefID"/>
		<xsl:apply-templates select="(key('InfoMapKey', $RefID))[1]" mode="getChapterWiseFileName"/>
	</xsl:template>

	<xsl:template match="InfoMap" mode="getChapterWiseFileName">
		<xsl:apply-templates select="current()" mode="getChapterWiseFileNameInternal"/>
	</xsl:template>

	<xsl:template match="InfoMap" mode="getChapterWiseFileNameInternal">
		<xsl:param name="useNrPrefix" select="false()"/>
		<xsl:param name="addLanguageSuffix" select="false()"/>

		<xsl:variable name="rootId" select="generate-id(/InfoMap)"/>

		<xsl:variable name="chapterNr">
			<xsl:choose>
				<xsl:when test="generate-id() = $rootId">
					<xsl:if test="$useNrPrefix">
						<xsl:value-of select="concat(1, '-')"/>
					</xsl:if>
					<xsl:value-of select="/InfoMap/Properties/Property[@name = 'SMC:name']/@value"/>
				</xsl:when>
				<xsl:otherwise>
					<xsl:if test="$useNrPrefix">
						<xsl:value-of select="concat(count(ancestor-or-self::InfoMap[@level = '1']/preceding-sibling::InfoMap | /InfoMap[Headline.content or Block or block.titlepage]) + 1, '-')"/>
					</xsl:if>
					<xsl:value-of select="ancestor-or-self::InfoMap[generate-id(parent::*) = $rootId]/Properties/Property[@name = 'SMC:name']/@value"/>
				</xsl:otherwise>
			</xsl:choose>
		</xsl:variable>
		<xsl:choose>
			<xsl:when test="$useNrPrefix and string-length(substring-before($chapterNr, '-')) = 1">
				<xsl:value-of select="concat('0', $chapterNr)"/>
			</xsl:when>
			<xsl:otherwise>
				<xsl:value-of select="$chapterNr"/>
			</xsl:otherwise>
		</xsl:choose>
		<xsl:if test="$addLanguageSuffix">
			<xsl:value-of select="concat('-', $language)"/>
		</xsl:if>
	</xsl:template>

	<xsl:template match="link.anchor">
		<fo:inline>
			<xsl:call-template name="addStyle">
				<xsl:with-param name="name">link</xsl:with-param>
			</xsl:call-template>
			<xsl:call-template name="addStyle">
				<xsl:with-param name="name">link.anchor</xsl:with-param>
			</xsl:call-template>
			<xsl:apply-templates select="current()" mode="writeCharacterizationInfo">
				<xsl:with-param name="isInline" select="true()"/>
			</xsl:apply-templates>
			<xsl:choose>
				<xsl:when test="$isPDFXMODE">
					<xsl:apply-templates select="current()" mode="getLinkText">
						<xsl:with-param name="customLinktext" select="linktext"/>
						<xsl:with-param name="base" select="InfoChunk.Link"/>
					</xsl:apply-templates>
				</xsl:when>
				<xsl:otherwise>
					<xsl:variable name="linkDestSuffix">
						<xsl:call-template name="getTemplateVariableValue">
							<xsl:with-param name="name">LINK_DESTINATION_SUFFIX</xsl:with-param>
						</xsl:call-template>
					</xsl:variable>
					<fo:basic-link internal-destination="{@RefID}{$linkDestSuffix}">
						<xsl:apply-templates select="current()" mode="getLinkText">
							<xsl:with-param name="customLinktext" select="linktext"/>
							<xsl:with-param name="base" select="InfoChunk.Link"/>
						</xsl:apply-templates>
					</fo:basic-link>
				</xsl:otherwise>
			</xsl:choose>
		</fo:inline>
	</xsl:template>

	<xsl:template match="Link.XRef">
		<xsl:apply-templates select="current()" mode="simple"/>
	</xsl:template>

	<xsl:template match="Link.XRef" mode="simple">
		<xsl:param name="autoLookupLinktext" select="true()"/>
		<xsl:param name="customLinktext"/>
		<xsl:param name="customLinktextElem"/>
		<xsl:param name="format"/>
		<xsl:param name="isExternalLink"/>
		<xsl:param name="linkDestination"/>

		<fo:inline>
			<xsl:call-template name="addStyle">
				<xsl:with-param name="name">link</xsl:with-param>
			</xsl:call-template>
			<xsl:call-template name="addStyle">
				<xsl:with-param name="name">link.xref</xsl:with-param>
			</xsl:call-template>
			<xsl:if test="string-length($format) &gt; 0">
				<xsl:call-template name="addStyle">
					<xsl:with-param name="name" select="concat('link.xref.', $format)"/>
				</xsl:call-template>
			</xsl:if>
			<xsl:if test="string-length(@format) &gt; 0">
				<xsl:call-template name="addStyle">
					<xsl:with-param name="name" select="concat('link.xref.', @format)"/>
				</xsl:call-template>
			</xsl:if>
			<xsl:apply-templates select="current()" mode="writeCharacterizationInfo">
				<xsl:with-param name="isInline" select="true()"/>
			</xsl:apply-templates>
			<xsl:variable name="asset">
				<xsl:call-template name="getTemplateGraphicURL">
					<xsl:with-param name="name" select="concat('link.xref.', @format)"/>
					<xsl:with-param name="defaultValue">
						<xsl:call-template name="getTemplateGraphicURL">
							<xsl:with-param name="name">link.xref</xsl:with-param>
						</xsl:call-template>
					</xsl:with-param>
				</xsl:call-template>
			</xsl:variable>

			<xsl:if test="string-length($asset) &gt; 0">
				<fo:external-graphic src="url('{$asset}')"/>
			</xsl:if>

			<xsl:variable name="linkDestSuffix">
				<xsl:call-template name="getTemplateVariableValue">
					<xsl:with-param name="name">LINK_DESTINATION_SUFFIX</xsl:with-param>
				</xsl:call-template>
			</xsl:variable>

			<xsl:choose>
				<xsl:when test="not($isPDFXMODE) and $isChapterWise and string-length(@RefID) &gt; 0">
					<xsl:variable name="currentChapterNr">
						<xsl:apply-templates select="current()" mode="getLinkChapterNr">
							<xsl:with-param name="RefID" select="ancestor::InfoMap[1]/@ID"/>
						</xsl:apply-templates>
					</xsl:variable>
					<xsl:variable name="linkChapterNr">
						<xsl:apply-templates select="current()" mode="getLinkChapterNr">
							<xsl:with-param name="RefID" select="@RefID"/>
						</xsl:apply-templates>
					</xsl:variable>
					<xsl:choose>
						<xsl:when test="$currentChapterNr != $linkChapterNr">
							<fo:basic-link external-destination="./{$linkChapterNr}.pdf#dest={@RefID}" show-destination="new">
								<xsl:apply-templates select="current()" mode="writeLinkText">
									<xsl:with-param name="autoLookupLinktext" select="$autoLookupLinktext"/>
									<xsl:with-param name="customLinktext" select="$customLinktext"/>
									<xsl:with-param name="customLinktextElem" select="$customLinktextElem"/>
								</xsl:apply-templates>
							</fo:basic-link>
						</xsl:when>
						<xsl:otherwise>
							<xsl:variable name="linkDestSuffix">
								<xsl:call-template name="getTemplateVariableValue">
									<xsl:with-param name="name">LINK_DESTINATION_SUFFIX</xsl:with-param>
								</xsl:call-template>
							</xsl:variable>
							<fo:basic-link internal-destination="{@RefID}{$linkDestSuffix}">
								<xsl:apply-templates select="current()" mode="writeLinkText">
									<xsl:with-param name="autoLookupLinktext" select="$autoLookupLinktext"/>
									<xsl:with-param name="customLinktext" select="$customLinktext"/>
									<xsl:with-param name="customLinktextElem" select="$customLinktextElem"/>
								</xsl:apply-templates>
							</fo:basic-link>
						</xsl:otherwise>
					</xsl:choose>
				</xsl:when>
				<xsl:when test="not($isPDFXMODE) and string-length($linkDestination) &gt; 0">
					<fo:basic-link>
						<xsl:choose>
							<xsl:when test="$isExternalLink">
								<xsl:attribute name="show-destination">new</xsl:attribute>
								<xsl:attribute name="external-destination">
									<xsl:value-of select="$linkDestination"/>
								</xsl:attribute>
							</xsl:when>
							<xsl:otherwise>
								<xsl:attribute name="internal-destination">
									<xsl:value-of select="$linkDestination"/>
									<xsl:value-of select="$linkDestSuffix"/>
								</xsl:attribute>
							</xsl:otherwise>
						</xsl:choose>
						<xsl:apply-templates select="current()" mode="writeLinkText">
							<xsl:with-param name="autoLookupLinktext" select="$autoLookupLinktext"/>
							<xsl:with-param name="customLinktext" select="$customLinktext"/>
							<xsl:with-param name="customLinktextElem" select="$customLinktextElem"/>
						</xsl:apply-templates>
					</fo:basic-link>
				</xsl:when>
				<xsl:when test="not($isPDFXMODE) and string-length(@RefID) &gt; 0">
					<fo:basic-link internal-destination="{@RefID}{$linkDestSuffix}">
						<xsl:apply-templates select="current()" mode="writeLinkText">
							<xsl:with-param name="autoLookupLinktext" select="$autoLookupLinktext"/>
							<xsl:with-param name="customLinktext" select="$customLinktext"/>
							<xsl:with-param name="customLinktextElem" select="$customLinktextElem"/>
						</xsl:apply-templates>
					</fo:basic-link>
				</xsl:when>
				<xsl:otherwise>
					<xsl:apply-templates select="current()" mode="writeLinkText">
						<xsl:with-param name="autoLookupLinktext" select="$autoLookupLinktext"/>
						<xsl:with-param name="customLinktext" select="$customLinktext"/>
						<xsl:with-param name="customLinktextElem" select="$customLinktextElem"/>
					</xsl:apply-templates>
				</xsl:otherwise>
			</xsl:choose>
		</fo:inline>

		<xsl:apply-templates select="current()" mode="writeLinkSuffix"/>

	</xsl:template>

	<xsl:template match="Link.XRef" mode="writeLinkText">
		<xsl:param name="autoLookupLinktext"/>
		<xsl:param name="customLinktextElem"/>
		<xsl:param name="customLinktext"/>

		<xsl:variable name="defaultLinkTextFormat">
			<xsl:call-template name="getTemplateVariableValue">
				<xsl:with-param name="name">LINK_XREF_DEFAULT_FORMAT</xsl:with-param>
			</xsl:call-template>
		</xsl:variable>

		<xsl:choose>
			<xsl:when test="$customLinktextElem">
				<xsl:apply-templates select="current()" mode="getLinkText">
					<xsl:with-param name="base" select="$customLinktextElem"/>
					<xsl:with-param name="defaultFormat" select="$defaultLinkTextFormat"/>
				</xsl:apply-templates>
			</xsl:when>
			<xsl:otherwise>
				<xsl:apply-templates select="current()" mode="getLinkText">
					<xsl:with-param name="base">
						<xsl:choose>
							<xsl:when test="InfoChunk.Link/@isCustomLinktext">
								<xsl:apply-templates select="InfoChunk.Link/node()"/>
							</xsl:when>
							<xsl:when test="$autoLookupLinktext and key('InfoMapKey', @RefID)/Headline.content">
								<xsl:apply-templates select="key('InfoMapKey', @RefID)/Headline.content" mode="printText"/>
							</xsl:when>
							<xsl:when test="string-length($customLinktext) &gt; 0">
								<xsl:value-of select="$customLinktext"/>
							</xsl:when>
							<xsl:otherwise>
								<xsl:apply-templates select="InfoChunk.Link/node()"/>
							</xsl:otherwise>
						</xsl:choose>
					</xsl:with-param>
					<xsl:with-param name="defaultFormat" select="$defaultLinkTextFormat"/>
				</xsl:apply-templates>
			</xsl:otherwise>
		</xsl:choose>
	</xsl:template>

	<xsl:template match="Link.Detail">
		<xsl:variable name="linkDestSuffix">
			<xsl:call-template name="getTemplateVariableValue">
				<xsl:with-param name="name">LINK_DESTINATION_SUFFIX</xsl:with-param>
			</xsl:call-template>
		</xsl:variable>
		<xsl:choose>
			<xsl:when test="@origin = 'Listing'">
				<fo:block text-align-last="justify">
					<xsl:apply-templates select="current()" mode="writeCharacterizationInfo"/>
					<xsl:choose>
						<xsl:when test="not($isPDFXMODE) and string-length(@RefID) &gt; 0">
							<fo:basic-link internal-destination="{@RefID}{$linkDestSuffix}">
								<xsl:value-of select="InfoChunk.Link"/>
							</fo:basic-link>
						</xsl:when>
						<xsl:otherwise>
							<xsl:value-of select="InfoChunk.Link"/>
						</xsl:otherwise>
					</xsl:choose>
					<fo:leader leader-pattern="dots"/>
					<xsl:apply-templates select="current()" mode="writePageReferenceNumber">
						<xsl:with-param name="RefID" select="@RefID"/>
					</xsl:apply-templates>
				</fo:block>
			</xsl:when>
			<xsl:otherwise>
				<xsl:variable name="defaultLinkTextFormat">
					<xsl:call-template name="getTemplateVariableValue">
						<xsl:with-param name="name">LINK_DETAIL_DEFAULT_FORMAT</xsl:with-param>
					</xsl:call-template>
				</xsl:variable>
				<fo:inline>
					<xsl:call-template name="addStyle">
						<xsl:with-param name="name">link</xsl:with-param>
					</xsl:call-template>
					<xsl:call-template name="addStyle">
						<xsl:with-param name="name">link.detail</xsl:with-param>
					</xsl:call-template>
					<xsl:if test="string-length(@format) &gt; 0">
						<xsl:call-template name="addStyle">
							<xsl:with-param name="name" select="concat('link.detail.', @format)"/>
						</xsl:call-template>
					</xsl:if>
					<xsl:apply-templates select="current()" mode="writeCharacterizationInfo">
						<xsl:with-param name="isInline" select="true()"/>
					</xsl:apply-templates>
					<xsl:if test="string-length(@format) &gt; 0">
						<xsl:variable name="asset">
							<xsl:call-template name="getTemplateGraphicURL">
								<xsl:with-param name="name" select="concat('link.xref.', @format)"/>
							</xsl:call-template>
						</xsl:variable>
						<xsl:if test="string-length($asset) &gt; 0">
							<fo:external-graphic src="url('{$asset}')"/>
						</xsl:if>
					</xsl:if>
					<xsl:choose>
						<xsl:when test="not($isPDFXMODE) and $isChapterWise and string-length(@RefID) &gt; 0">
							<xsl:variable name="currentChapterNr">
								<xsl:apply-templates select="current()" mode="getLinkChapterNr">
									<xsl:with-param name="RefID" select="ancestor::InfoMap[1]/@ID"/>
								</xsl:apply-templates>
							</xsl:variable>
							<xsl:variable name="linkChapterNr">
								<xsl:apply-templates select="current()" mode="getLinkChapterNr">
									<xsl:with-param name="RefID" select="@fileID"/>
								</xsl:apply-templates>
							</xsl:variable>
							<xsl:choose>
								<xsl:when test="$currentChapterNr != $linkChapterNr">
									<fo:basic-link external-destination="./{$linkChapterNr}.pdf#dest={@RefID}" show-destination="new">
										<xsl:apply-templates select="current()" mode="getLinkText">
											<xsl:with-param name="base" select="InfoChunk.Link"/>
											<xsl:with-param name="defaultFormat" select="$defaultLinkTextFormat"/>
										</xsl:apply-templates>
									</fo:basic-link>
								</xsl:when>
								<xsl:otherwise>
									<fo:basic-link internal-destination="{@RefID}{$linkDestSuffix}">
										<xsl:apply-templates select="current()" mode="getLinkText">
											<xsl:with-param name="base" select="InfoChunk.Link"/>
											<xsl:with-param name="defaultFormat" select="$defaultLinkTextFormat"/>
										</xsl:apply-templates>
									</fo:basic-link>
								</xsl:otherwise>
							</xsl:choose>
						</xsl:when>
						<xsl:when test="not($isPDFXMODE) and string-length(@RefID) &gt; 0">
							<fo:basic-link internal-destination="{@RefID}{$linkDestSuffix}">
								<xsl:apply-templates select="current()" mode="getLinkText">
									<xsl:with-param name="base" select="InfoChunk.Link"/>
									<xsl:with-param name="defaultFormat" select="$defaultLinkTextFormat"/>
								</xsl:apply-templates>
							</fo:basic-link>
						</xsl:when>
						<xsl:otherwise>
							<xsl:apply-templates select="current()" mode="getLinkText">
								<xsl:with-param name="base" select="InfoChunk.Link"/>
								<xsl:with-param name="defaultFormat" select="$defaultLinkTextFormat"/>
							</xsl:apply-templates>
						</xsl:otherwise>
					</xsl:choose>
				</fo:inline>

				<xsl:apply-templates select="current()" mode="writeLinkSuffix"/>
			</xsl:otherwise>
		</xsl:choose>

	</xsl:template>

	<!--<xsl:variable name="MEDIA_THEME_LINK_NR_INITIALIZED" select="list:new()"/>
	<xsl:variable name="MEDIA_THEME_LINK_NR_MAP" select="map:new()"/>

	<xsl:variable name="TABLE_LINK_NR_INITIALIZED" select="list:new()"/>
	<xsl:variable name="TABLE_LINK_NR_LIST" select="list:new()"/>-->

	<xsl:template match="link.element" mode="getLinkBaseText">
		<xsl:param name="RefID" select="@RefID"/>
		<xsl:param name="defaultFormat"/>

		<xsl:variable name="linkedElement" select="key('LinkElementKey', $RefID)[1]"/>
		<xsl:variable name="linkedElementName" select="string(name($linkedElement))"/>
		<xsl:variable name="isTable" select="$linkedElementName = 'table'"/>

		<xsl:variable name="displayType">
			<xsl:call-template name="getTemplateVariableValue">
				<xsl:with-param name="name">
					<xsl:choose>
						<xsl:when test="$isTable">TABLE_TITLE_DISPLAY_TYPE</xsl:when>
						<xsl:otherwise>MEDIA_CAPTION_DISPLAY_TYPE</xsl:otherwise>
					</xsl:choose>
				</xsl:with-param>
				<xsl:with-param name="defaultValue">simple</xsl:with-param>
			</xsl:call-template>
		</xsl:variable>

		<xsl:choose>
			<xsl:when test="$displayType = 'numbered-with-chapter'">
				<xsl:apply-templates select="current()" mode="getLinkBaseTextWithChapter">
					<xsl:with-param name="linkedElement" select="$linkedElement"/>
					<xsl:with-param name="defaultFormat" select="$defaultFormat"/>
				</xsl:apply-templates>
			</xsl:when>
			<xsl:otherwise>
				<xsl:apply-templates select="current()" mode="getLinkBaseTextSimple">
					<xsl:with-param name="linkedElement" select="$linkedElement"/>
					<xsl:with-param name="defaultFormat" select="$defaultFormat"/>
				</xsl:apply-templates>
			</xsl:otherwise>
		</xsl:choose>
	</xsl:template>

	<xsl:template match="link.element" mode="getLinkBaseTextSimple">
		<xsl:param name="linkedElement" select="key('LinkElementKey', @RefID)[1]"/>
		<xsl:param name="translateSuffix">.Abbreviation</xsl:param>
		<xsl:param name="defaultFormat"/>

		<xsl:variable name="linkedElementName" select="string(name($linkedElement))"/>
		<xsl:variable name="isMediaTheme" select="$linkedElementName = 'Media.theme'"/>
		<xsl:variable name="isTable" select="$linkedElementName = 'table'"/>

		<xsl:variable name="notAutoNumberDisplayType">
			<xsl:choose>
				<xsl:when test="$isTable">
					<xsl:call-template name="getTemplateVariableValue">
						<xsl:with-param name="name">TABLE_TITLE_NOT_AUTO_NUMBER_DISPLAY_TYPE</xsl:with-param>
					</xsl:call-template>
				</xsl:when>
				<xsl:when test="$isMediaTheme">
					<xsl:call-template name="getTemplateVariableValue">
						<xsl:with-param name="name">MEDIA_CAPTION_NOT_AUTO_NUMBER_DISPLAY_TYPE</xsl:with-param>
					</xsl:call-template>
				</xsl:when>
			</xsl:choose>
		</xsl:variable>

		<xsl:variable name="isNotAutNumber" select="($isMediaTheme and $linkedElement/parent::Media[@notAutoNumber = 'true'])
					  or ($isTable and $linkedElement/following-sibling::TableDesc[1][@notAutoNumber = 'true'])"/>
		
		<xsl:variable name="showPrefixAndNumber" select="not($isNotAutNumber) or string-length($notAutoNumberDisplayType) = 0
				or starts-with($notAutoNumberDisplayType, 'numbered') or $notAutoNumberDisplayType = 'fixtext'"/>

		<xsl:if test="$showPrefixAndNumber">
			<fo:inline keep-together="always">
				<xsl:call-template name="translate">
					<xsl:with-param name="ID">
						<xsl:choose>
							<xsl:when test="$isMediaTheme">
								<xsl:value-of select="concat('Image', $translateSuffix)"/>
							</xsl:when>
							<xsl:when test="$isTable">
								<xsl:value-of select="concat('Table', $translateSuffix)"/>
							</xsl:when>
							<xsl:otherwise>
								<xsl:value-of select="concat('Image', $translateSuffix)"/>
							</xsl:otherwise>
						</xsl:choose>
					</xsl:with-param>
				</xsl:call-template>

				<xsl:choose>
					<xsl:when test="$isMediaTheme">
						<xsl:if test="not($isNotAutNumber)">
							<xsl:text> </xsl:text>
							<!-- do iteration only once -->
							<xsl:variable name="restart">
								<xsl:call-template name="getTemplateVariableValue">
									<xsl:with-param name="name">MEDIA_NR_RESTART_WITH_LANGUAGE_CHANGE</xsl:with-param>
									<xsl:with-param name="defaultValue">false</xsl:with-param>
								</xsl:call-template>
							</xsl:variable>
							<xsl:variable name="key">
								<xsl:choose>
									<xsl:when test="$restart = 'true'">
										<xsl:for-each select="$linkedElement">
											<xsl:call-template name="getCurrentLanguage"/>
										</xsl:for-each>
									</xsl:when>
									<xsl:otherwise>neutral</xsl:otherwise>
								</xsl:choose>
							</xsl:variable>
							<xsl:variable name="alwaysShowMediaCaption">
								<xsl:call-template name="getTemplateVariableValue">
									<xsl:with-param name="name">MEDIA_CAPTION_SHOW_ALWAYS</xsl:with-param>
									<xsl:with-param name="defaultValue">false</xsl:with-param>
								</xsl:call-template>
							</xsl:variable>
							<!--<xsl:if test="string(map:containsKey($MEDIA_THEME_LINK_NR_MAP, string($key))) = 'false'">
								
								<xsl:for-each select="//Media.theme[($alwaysShowMediaCaption = 'true' or InfoPar.Subtitle != '') and not(parent::Media[@notAutoNumber = 'true'])]">
									
									<xsl:variable name="keyCurr">
										<xsl:choose>
											<xsl:when test="$restart = 'true'">
												<xsl:call-template name="getCurrentLanguage"/>
											</xsl:when>
											<xsl:otherwise>neutral</xsl:otherwise>
										</xsl:choose>
									</xsl:variable>

									<xsl:if test="string(map:containsKey($MEDIA_THEME_LINK_NR_MAP, string($keyCurr))) = 'false'">
										<xsl:variable name="addKey" select="map:put($MEDIA_THEME_LINK_NR_MAP, string($keyCurr), list:new())"/>
									</xsl:if>

									<xsl:variable name="MEDIA_THEME_LINK_NR_LIST" select="map:get($MEDIA_THEME_LINK_NR_MAP, string($keyCurr))"/>
									
									<xsl:variable name="add" select="list:add($MEDIA_THEME_LINK_NR_LIST, string(generate-id()))"/>
								</xsl:for-each>
							</xsl:if>
							<xsl:variable name="MEDIA_THEME_LINK_NR_LIST" select="map:get($MEDIA_THEME_LINK_NR_MAP, string($key))"/>
							<xsl:value-of select="number(list:indexOf($MEDIA_THEME_LINK_NR_LIST, string(generate-id($linkedElement)))) + 1"/>-->
							<xsl:value-of select="count($linkedElement/preceding::Media.theme[($alwaysShowMediaCaption = 'true' or InfoPar.Subtitle != '') and not(parent::Media[@notAutoNumber = 'true'])]) + 1"/>
						</xsl:if>
					</xsl:when>
					<xsl:when test="$isTable">
						<xsl:if test="not($isNotAutNumber)">
							<xsl:text> </xsl:text>
							<!--<xsl:if test="string(list:size($TABLE_LINK_NR_INITIALIZED)) = '0'">
								--><!-- do iteration only once --><!--
								<xsl:for-each select="//table[title != '' and title != 'Title' and @typ != 'MenuInst' and following-sibling::TableDesc[1][not(@glossary = 'true') and not(@notAutoNumber = 'true')]]">
									<xsl:variable name="add" select="list:add($TABLE_LINK_NR_LIST, string(generate-id()))"/>
								</xsl:for-each>
								<xsl:variable name="add" select="list:add($TABLE_LINK_NR_INITIALIZED, '1')"/>
							</xsl:if>
							<xsl:value-of select="number(list:indexOf($TABLE_LINK_NR_LIST, string(generate-id($linkedElement)))) + 1"/>-->
							<xsl:value-of select="count($linkedElement/preceding::table[title != '' and title != 'Title' and @typ != 'MenuInst' and following-sibling::TableDesc[1][not(@glossary = 'true') and not(@notAutoNumber = 'true')]]) + 1"/>
						</xsl:if>
					</xsl:when>
					<xsl:otherwise>
						<xsl:text> X</xsl:text>
					</xsl:otherwise>
				</xsl:choose>
			</fo:inline>
		</xsl:if>
		
		<xsl:variable name="format">
			<xsl:choose>
				<xsl:when test="string-length(@format) &gt; 0">
					<xsl:value-of select="@format"/>
				</xsl:when>
				<xsl:otherwise>
					<xsl:value-of select="$defaultFormat"/>
				</xsl:otherwise>
			</xsl:choose>
		</xsl:variable>

		<xsl:if test="not($format = 'Nr' or $format = 'SeeNr' or $format = 'SeeNrPagePageNr')">
			<xsl:choose>
				<xsl:when test="$isMediaTheme">
					<xsl:if test="$showPrefixAndNumber">: </xsl:if>
					<xsl:apply-templates select="$linkedElement/InfoPar.Subtitle/node()"/>
				</xsl:when>
				<xsl:when test="$isTable">
					<xsl:if test="$showPrefixAndNumber">: </xsl:if>
					<xsl:apply-templates select="$linkedElement/title/node()"/>
				</xsl:when>
				<xsl:otherwise>
					<xsl:if test="$showPrefixAndNumber">: </xsl:if>
					<xsl:value-of select="InfoChunk.Link"/>
				</xsl:otherwise>
			</xsl:choose>
		</xsl:if>

	</xsl:template>

	<!--<xsl:variable name="TABLE_LINK_NR_MAP" select="map:new()"/>
	<xsl:variable name="IMAGE_LINK_NR_MAP" select="map:new()"/>-->

	<xsl:template match="link.element | generate.listing.nr" mode="getLinkBaseTextWithChapter">
		<xsl:param name="RefID" select="@RefID"/>
		<xsl:param name="translateSuffix">.Abbreviation</xsl:param>
		<xsl:param name="printTitle" select="true()"/>
		<xsl:param name="quoteTitle" select="false()"/>
		<xsl:param name="linkedElement" select="key('LinkElementKey', $RefID)[1]"/>
		<xsl:param name="defaultFormat"/>

		<xsl:variable name="linkedElementName" select="string(name($linkedElement))"/>
		<xsl:variable name="isMediaTheme" select="$linkedElementName = 'Media.theme'"/>
		<xsl:variable name="isTable" select="$linkedElementName = 'table'"/>

		<xsl:variable name="notAutoNumberDisplayType">
			<xsl:choose>
				<xsl:when test="$isTable">
					<xsl:call-template name="getTemplateVariableValue">
						<xsl:with-param name="name">TABLE_TITLE_NOT_AUTO_NUMBER_DISPLAY_TYPE</xsl:with-param>
					</xsl:call-template>
				</xsl:when>
				<xsl:when test="$isMediaTheme">
					<xsl:call-template name="getTemplateVariableValue">
						<xsl:with-param name="name">MEDIA_CAPTION_NOT_AUTO_NUMBER_DISPLAY_TYPE</xsl:with-param>
					</xsl:call-template>
				</xsl:when>
			</xsl:choose>
		</xsl:variable>

		<xsl:variable name="isNotAutNumber" select="($isMediaTheme and $linkedElement/parent::Media[@notAutoNumber = 'true'])
					  or ($isTable and $linkedElement/following-sibling::TableDesc[1][@notAutoNumber = 'true'])"/>

		<xsl:variable name="showPrefixAndNumber" select="not($isNotAutNumber) or string-length($notAutoNumberDisplayType) = 0
				or starts-with($notAutoNumberDisplayType, 'numbered') or $notAutoNumberDisplayType = 'fixtext'"/>

		<xsl:if test="$showPrefixAndNumber">

			<xsl:call-template name="translate">
				<xsl:with-param name="ID">
					<xsl:choose>
						<xsl:when test="$isMediaTheme">
							<xsl:value-of select="concat('Image', $translateSuffix)"/>
						</xsl:when>
						<xsl:when test="$isTable">
							<xsl:value-of select="concat('Table', $translateSuffix)"/>
						</xsl:when>
						<xsl:otherwise>
							<xsl:value-of select="concat('Image', $translateSuffix)"/>
						</xsl:otherwise>
					</xsl:choose>
				</xsl:with-param>
			</xsl:call-template>

			<xsl:choose>
				<xsl:when test="$isMediaTheme">
					<xsl:if test="not($linkedElement/parent::Media[@notAutoNumber = 'true'])">
						<xsl:text> </xsl:text>
						<xsl:variable name="alwaysShowMediaCaption">
								<xsl:call-template name="getTemplateVariableValue">
									<xsl:with-param name="name">MEDIA_CAPTION_SHOW_ALWAYS</xsl:with-param>
									<xsl:with-param name="defaultValue">false</xsl:with-param>
								</xsl:call-template>
							</xsl:variable>
						<!--<xsl:if test="string(list:size($MEDIA_THEME_LINK_NR_INITIALIZED)) = '0'">
							--><!-- do iteration only once --><!--
							<xsl:for-each select="//Media.theme[($alwaysShowMediaCaption = 'true' or InfoPar.Subtitle != '') and not(parent::Media[@notAutoNumber = 'true'])]">

								<xsl:variable name="preChapterNr">
									<xsl:apply-templates select="current()" mode="getMainChapterNr"/>
								</xsl:variable>

								<xsl:variable name="chapterNr">
									<xsl:choose>
										<xsl:when test="string-length($preChapterNr) = 0">
											<xsl:value-of select="generate-id(/InfoMap)"/>
										</xsl:when>
										<xsl:otherwise>
											<xsl:value-of select="$preChapterNr"/>
										</xsl:otherwise>
									</xsl:choose>
								</xsl:variable>

								<xsl:variable name="list" select="map:get($IMAGE_LINK_NR_MAP, string($chapterNr))"/>

								<xsl:choose>
									<xsl:when test="string($list) = ''">

										<xsl:variable name="newList" select="list:new()"/>
										<xsl:variable name="put" select="map:put($IMAGE_LINK_NR_MAP, string($chapterNr), $newList)"/>
										<xsl:variable name="add" select="list:add($newList, string(generate-id()))"/>
									</xsl:when>
									<xsl:otherwise>
										<xsl:variable name="add" select="list:add($list, string(generate-id()))"/>
									</xsl:otherwise>
								</xsl:choose>

							</xsl:for-each>
							<xsl:variable name="add" select="list:add($MEDIA_THEME_LINK_NR_INITIALIZED, '1')"/>
						</xsl:if>-->

						<xsl:variable name="currentChapterNr">
							<xsl:apply-templates select="$linkedElement" mode="getMainChapterNr"/>
						</xsl:variable>

						<xsl:value-of select="count($linkedElement/preceding::Media.theme[($alwaysShowMediaCaption = 'true' or InfoPar.Subtitle != '') and not(parent::Media[@notAutoNumber = 'true'])]) + 1"/>

						<!--<xsl:choose>
							<xsl:when test="string-length($currentChapterNr) &gt; 0">
								<xsl:variable name="currentList" select="map:get($IMAGE_LINK_NR_MAP, string($currentChapterNr))"/>

								<xsl:value-of select="$currentChapterNr"/>
								<xsl:text>-</xsl:text>
								<xsl:value-of select="number(list:indexOf($currentList, string(generate-id($linkedElement)))) + 1"/>
							</xsl:when>
							<xsl:otherwise>
								<xsl:variable name="currentList" select="map:get($IMAGE_LINK_NR_MAP, string(generate-id(/InfoMap)))"/>

								<xsl:value-of select="number(list:indexOf($currentList, string(generate-id($linkedElement)))) + 1"/>
							</xsl:otherwise>
						</xsl:choose>-->
					</xsl:if>

				</xsl:when>
				<xsl:when test="$isTable">

					<xsl:if test="not($linkedElement/following-sibling::TableDesc[1][@glossary = 'true' or @notAutoNumber = 'true'])">
						<xsl:text> </xsl:text>
						<!--<xsl:if test="string(list:size($TABLE_LINK_NR_INITIALIZED)) = '0'">
							--><!-- do iteration only once --><!--
							<xsl:for-each select="//table[title != '' and title != 'Title' and @typ != 'MenuInst' and following-sibling::TableDesc[1][not(@glossary = 'true') and not(@notAutoNumber = 'true')]]">

								<xsl:variable name="preChapterNr">
									<xsl:apply-templates select="current()" mode="getMainChapterNr"/>
								</xsl:variable>

								<xsl:variable name="chapterNr">
									<xsl:choose>
										<xsl:when test="string-length($preChapterNr) = 0">
											<xsl:value-of select="generate-id(/InfoMap)"/>
										</xsl:when>
										<xsl:otherwise>
											<xsl:value-of select="$preChapterNr"/>
										</xsl:otherwise>
									</xsl:choose>
								</xsl:variable>

								<xsl:variable name="list" select="map:get($TABLE_LINK_NR_MAP, string($chapterNr))"/>

								<xsl:choose>
									<xsl:when test="string($list) = ''">
										<xsl:variable name="newList" select="list:new()"/>
										<xsl:variable name="put" select="map:put($TABLE_LINK_NR_MAP, string($chapterNr), $newList)"/>
										<xsl:variable name="add" select="list:add($newList, string(generate-id()))"/>
									</xsl:when>
									<xsl:otherwise>
										<xsl:variable name="add" select="list:add($list, string(generate-id()))"/>
									</xsl:otherwise>
								</xsl:choose>

							</xsl:for-each>
							<xsl:variable name="add" select="list:add($TABLE_LINK_NR_INITIALIZED, '1')"/>
						</xsl:if>-->

						<xsl:variable name="currentChapterNr">
							<xsl:apply-templates select="$linkedElement" mode="getMainChapterNr"/>
						</xsl:variable>

						<xsl:value-of select="count($linkedElement/preceding::table[title != '' and title != 'Title' and @typ != 'MenuInst' and following-sibling::TableDesc[1][not(@glossary = 'true') and not(@notAutoNumber = 'true')]]) + 1"/>

						<!--<xsl:choose>
							<xsl:when test="string-length($currentChapterNr) &gt; 0">
								<xsl:variable name="currentList" select="map:get($TABLE_LINK_NR_MAP, string($currentChapterNr))"/>
								<xsl:value-of select="$currentChapterNr"/>
								<xsl:text>-</xsl:text>
								<xsl:value-of select="number(list:indexOf($currentList, string(generate-id($linkedElement)))) + 1"/>
							</xsl:when>
							<xsl:otherwise>
								<xsl:variable name="currentList" select="map:get($TABLE_LINK_NR_MAP, string(generate-id(/InfoMap)))"/>

								<xsl:value-of select="number(list:indexOf($currentList, string(generate-id($linkedElement)))) + 1"/>
							</xsl:otherwise>
						</xsl:choose>-->
					</xsl:if>

				</xsl:when>
				<xsl:otherwise>
					<xsl:text> X</xsl:text>
				</xsl:otherwise>
			</xsl:choose>
		</xsl:if>

		<xsl:variable name="format">
			<xsl:choose>
				<xsl:when test="string-length(@format) &gt; 0">
					<xsl:value-of select="@format"/>
				</xsl:when>
				<xsl:otherwise>
					<xsl:value-of select="$defaultFormat"/>
				</xsl:otherwise>
			</xsl:choose>
		</xsl:variable>

		<xsl:if test="not($format = 'Nr' or $format = 'SeeNr' or $format = 'SeeNrPagePageNr') and $printTitle">
			<xsl:choose>
				<xsl:when test="$isMediaTheme">
					<xsl:if test="$showPrefixAndNumber">: </xsl:if>
					<xsl:if test="$quoteTitle">"</xsl:if>
					<xsl:apply-templates select="$linkedElement/InfoPar.Subtitle/node()"/>
					<xsl:if test="$quoteTitle">"</xsl:if>
				</xsl:when>
				<xsl:when test="$isTable">
					<xsl:if test="$showPrefixAndNumber">: </xsl:if>
					<xsl:if test="$quoteTitle">"</xsl:if>
					<xsl:apply-templates select="$linkedElement/title/node()"/>
					<xsl:if test="$quoteTitle">"</xsl:if>
				</xsl:when>
				<xsl:otherwise>
					<xsl:if test="$showPrefixAndNumber">: </xsl:if>
					<xsl:if test="$quoteTitle">"</xsl:if>
					<xsl:value-of select="InfoChunk.Link"/>
					<xsl:if test="$quoteTitle">"</xsl:if>
				</xsl:otherwise>
			</xsl:choose>
		</xsl:if>

	</xsl:template>

	<xsl:template match="link.element">
		<xsl:apply-templates select="current()" mode="simple"/>
	</xsl:template>

	<xsl:template match="link.element" mode="simple">
		<xsl:param name="customLinktext"/>
		<xsl:param name="customLinktextElem"/>
		<xsl:param name="format"/>
		<xsl:param name="isExternalLink"/>
		<xsl:param name="linkDestination"/>

		<xsl:variable name="RefID" select="@RefID"/>

		<xsl:variable name="linkDestSuffix">
			<xsl:call-template name="getTemplateVariableValue">
				<xsl:with-param name="name">LINK_DESTINATION_SUFFIX</xsl:with-param>
			</xsl:call-template>
		</xsl:variable>

		<xsl:choose>
			<xsl:when test="@origin = 'Listing'">
				<fo:block text-align-last="justify">
					<xsl:apply-templates select="current()" mode="writeCharacterizationInfo"/>
					<xsl:choose>
						<xsl:when test="not($isPDFXMODE) and string-length(@RefID) &gt; 0">
							<fo:basic-link internal-destination="{@RefID}{$linkDestSuffix}">
								<xsl:apply-templates select="InfoChunk.Link/node()"/>
								<fo:leader leader-pattern="dots"/>
								<xsl:apply-templates select="current()" mode="writePageReferenceNumber">
									<xsl:with-param name="RefID" select="@RefID"/>
								</xsl:apply-templates>
							</fo:basic-link>
						</xsl:when>
						<xsl:otherwise>
							<xsl:apply-templates select="InfoChunk.Link/node()"/>
							<fo:leader leader-pattern="dots"/>
							<xsl:apply-templates select="current()" mode="writePageReferenceNumber">
								<xsl:with-param name="RefID" select="@RefID"/>
							</xsl:apply-templates>
						</xsl:otherwise>
					</xsl:choose>
				</fo:block>
			</xsl:when>
			<xsl:otherwise>

				<fo:inline>
					<xsl:call-template name="addStyle">
						<xsl:with-param name="name">link</xsl:with-param>
					</xsl:call-template>
					<xsl:call-template name="addStyle">
						<xsl:with-param name="name">link.element</xsl:with-param>
					</xsl:call-template>
					<xsl:if test="string-length($format) &gt; 0">
						<xsl:call-template name="addStyle">
							<xsl:with-param name="name" select="concat('link.element.', $format)"/>
						</xsl:call-template>
					</xsl:if>
					<xsl:if test="string-length(@format) &gt; 0">
						<xsl:call-template name="addStyle">
							<xsl:with-param name="name" select="concat('link.element.', @format)"/>
						</xsl:call-template>
					</xsl:if>
					<xsl:apply-templates select="current()" mode="writeCharacterizationInfo">
						<xsl:with-param name="isInline" select="true()" />
					</xsl:apply-templates>
					<xsl:if test="string-length(@format) &gt; 0">
						<xsl:variable name="asset">
							<xsl:call-template name="getTemplateGraphicURL">
								<xsl:with-param name="name" select="concat('link.xref.', @format)"/>
							</xsl:call-template>
						</xsl:variable>
						<xsl:if test="string-length($asset) &gt; 0">
							<fo:external-graphic src="url('{$asset}')"/>
						</xsl:if>
					</xsl:if>

					<xsl:choose>
						<xsl:when test="not($isPDFXMODE) and $isChapterWise and string-length(@RefID) &gt; 0">
							<xsl:variable name="currentChapterNr">
								<xsl:apply-templates select="current()" mode="getLinkChapterNr">
									<xsl:with-param name="RefID" select="ancestor::InfoMap[1]/@ID"/>
								</xsl:apply-templates>
							</xsl:variable>
							<xsl:variable name="linkChapterNr">
								<xsl:apply-templates select="current()" mode="getLinkChapterNr">
									<xsl:with-param name="RefID" select="@fileID"/>
								</xsl:apply-templates>
							</xsl:variable>
							<xsl:choose>
								<xsl:when test="$currentChapterNr != $linkChapterNr">
									<fo:basic-link external-destination="./{$linkChapterNr}.pdf#dest={@RefID}" show-destination="new">
										<xsl:apply-templates select="current()" mode="writeLinkText">
											<xsl:with-param name="customLinktext" select="$customLinktext"/>
											<xsl:with-param name="customLinktextElem" select="$customLinktextElem"/>
										</xsl:apply-templates>
									</fo:basic-link>
								</xsl:when>
								<xsl:otherwise>
									<fo:basic-link internal-destination="{@RefID}{$linkDestSuffix}">
										<xsl:apply-templates select="current()" mode="writeLinkText">
											<xsl:with-param name="customLinktext" select="$customLinktext"/>
											<xsl:with-param name="customLinktextElem" select="$customLinktextElem"/>
										</xsl:apply-templates>
									</fo:basic-link>
								</xsl:otherwise>
							</xsl:choose>
						</xsl:when>
						<xsl:when test="not($isPDFXMODE) and string-length($linkDestination) &gt; 0">
							<fo:basic-link>
								<xsl:choose>
									<xsl:when test="$isExternalLink">
										<xsl:attribute name="show-destination">new</xsl:attribute>
										<xsl:attribute name="external-destination">
											<xsl:value-of select="$linkDestination"/>
										</xsl:attribute>
									</xsl:when>
									<xsl:otherwise>
										<xsl:attribute name="internal-destination">
											<xsl:value-of select="$linkDestination"/>
											<xsl:value-of select="$linkDestSuffix"/>
										</xsl:attribute>
									</xsl:otherwise>
								</xsl:choose>
								<xsl:apply-templates select="current()" mode="writeLinkText">
									<xsl:with-param name="customLinktext" select="$customLinktext"/>
									<xsl:with-param name="customLinktextElem" select="$customLinktextElem"/>
								</xsl:apply-templates>
							</fo:basic-link>
						</xsl:when>
						<xsl:when test="not($isPDFXMODE) and string-length(@RefID) &gt; 0">
							<fo:basic-link internal-destination="{@RefID}{$linkDestSuffix}">
								<xsl:apply-templates select="current()" mode="writeLinkText">
									<xsl:with-param name="customLinktext" select="$customLinktext"/>
									<xsl:with-param name="customLinktextElem" select="$customLinktextElem"/>
								</xsl:apply-templates>
							</fo:basic-link>
						</xsl:when>
						<xsl:otherwise>
							<xsl:apply-templates select="current()" mode="writeLinkText">
								<xsl:with-param name="customLinktext" select="$customLinktext"/>
								<xsl:with-param name="customLinktextElem" select="$customLinktextElem"/>
							</xsl:apply-templates>
						</xsl:otherwise>
					</xsl:choose>
				</fo:inline>

				<xsl:apply-templates select="current()" mode="writeLinkSuffix"/>
			</xsl:otherwise>
		</xsl:choose>
	</xsl:template>

	<xsl:template match="link.element" mode="writeLinkText">
		<xsl:param name="customLinktext"/>
		<xsl:param name="customLinktextElem"/>

		<xsl:variable name="defaultLinkTextFormat">
			<xsl:call-template name="getTemplateVariableValue">
				<xsl:with-param name="name">LINK_ELEMENT_DEFAULT_FORMAT</xsl:with-param>
			</xsl:call-template>
		</xsl:variable>

		<xsl:choose>
			<xsl:when test="$customLinktextElem">
				<xsl:apply-templates select="current()" mode="getLinkText">
					<xsl:with-param name="base" select="$customLinktextElem"/>
					<xsl:with-param name="defaultFormat" select="$defaultLinkTextFormat"/>
				</xsl:apply-templates>
			</xsl:when>
			<xsl:otherwise>
				<xsl:choose>
					<xsl:when test="string-length($customLinktext) &gt; 0">
						<xsl:apply-templates select="current()" mode="getLinkText">
							<xsl:with-param name="base" select="$customLinktext"/>
							<xsl:with-param name="defaultFormat" select="$defaultLinkTextFormat"/>
						</xsl:apply-templates>
					</xsl:when>
					<xsl:otherwise>
						<xsl:apply-templates select="current()" mode="getLinkText">
							<xsl:with-param name="applyBaseText" select="true()"/>
							<xsl:with-param name="base">
								<xsl:apply-templates select="current()" mode="getLinkBaseText">
									<xsl:with-param name="defaultFormat" select="$defaultLinkTextFormat"/>
								</xsl:apply-templates>
							</xsl:with-param>
							<xsl:with-param name="defaultFormat" select="$defaultLinkTextFormat"/>
						</xsl:apply-templates>
					</xsl:otherwise>
				</xsl:choose>
			</xsl:otherwise>
		</xsl:choose>

	</xsl:template>

	<xsl:template match="*" mode="writeLinkSuffix">
		<xsl:variable name="linkTextSuffix">
			<xsl:call-template name="getTemplateVariableValue">
				<xsl:with-param name="name">LINK_SUFFIX</xsl:with-param>
			</xsl:call-template>
		</xsl:variable>
		<xsl:if test="string-length($linkTextSuffix) &gt; 0">
			<fo:inline>
				<xsl:call-template name="addStyle">
					<xsl:with-param name="name">link.suffix</xsl:with-param>
				</xsl:call-template>
				<xsl:variable name="translated">
					<xsl:call-template name="translate">
						<xsl:with-param name="ID" select="$linkTextSuffix"/>
					</xsl:call-template>
				</xsl:variable>
				<xsl:choose>
					<xsl:when test="string-length($translated) &gt; 0">
						<xsl:value-of select="$translated"/>
					</xsl:when>
					<xsl:otherwise>
						<xsl:value-of select="$linkTextSuffix"/>
					</xsl:otherwise>
				</xsl:choose>
			</fo:inline>
		</xsl:if>
	</xsl:template>

	<xsl:template match="Link.MailTo">

		<fo:inline>
			<xsl:call-template name="addStyle">
				<xsl:with-param name="name">link</xsl:with-param>
			</xsl:call-template>
			<xsl:call-template name="addStyle">
				<xsl:with-param name="name">link.mailTo</xsl:with-param>
			</xsl:call-template>
			<xsl:apply-templates select="current()" mode="writeCharacterizationInfo">
				<xsl:with-param name="isInline" select="true()"/>
			</xsl:apply-templates>
			<xsl:choose>
				<xsl:when test="not($isPDFXMODE) and string-length(@mailTo) &gt; 0">
					<fo:basic-link external-destination="mailto:{@mailTo}">
						<xsl:apply-templates/>
					</fo:basic-link>
				</xsl:when>
				<xsl:otherwise>
					<xsl:apply-templates/>
				</xsl:otherwise>
			</xsl:choose>
		</fo:inline>

		<xsl:apply-templates select="current()" mode="writeLinkSuffix"/>

	</xsl:template>

	<xsl:template match="Link.URL">

		<fo:inline>
			<xsl:call-template name="addStyle">
				<xsl:with-param name="name">link</xsl:with-param>
			</xsl:call-template>
			<xsl:call-template name="addStyle">
				<xsl:with-param name="name">link.url</xsl:with-param>
			</xsl:call-template>
			<xsl:if test="string-length(@format) &gt; 0">
				<xsl:call-template name="addStyle">
					<xsl:with-param name="name" select="concat('link.url.', @format)"/>
				</xsl:call-template>
			</xsl:if>
			<xsl:apply-templates select="current()" mode="writeCharacterizationInfo">
				<xsl:with-param name="isInline" select="true()"/>
			</xsl:apply-templates>
			<xsl:choose>
				<xsl:when test="not($isPDFXMODE) and string-length(@URL) &gt; 0">
					<fo:basic-link  external-destination="{@URL}">
						<xsl:apply-templates/>
					</fo:basic-link>
				</xsl:when>
				<xsl:otherwise>
					<xsl:apply-templates/>
				</xsl:otherwise>
			</xsl:choose>
		</fo:inline>

		<xsl:apply-templates select="current()" mode="writeLinkSuffix"/>

	</xsl:template>

	<xsl:template match="Link.File">
		<fo:inline>
			<xsl:choose>
				<!--<xsl:when test="not($isPDFXMODE) and $Offline = 'Offline' and string-length(@originalURL) &gt; 0 and $USE_PDF_ATTACHMENT = 'true'">
					<xsl:apply-templates select="current()" mode="writeCharacterizationInfo">
						<xsl:with-param name="isInline" select="true()"/>
					</xsl:apply-templates>
					<xsl:variable name="attachmentName" select="string(map:get($ATTACHMENT_NAME_MAP, string(@originalURL)))"/>
					<xsl:choose>
						<xsl:when test="not($attachmentName = 'null' or $attachmentName = '')">
							<fo:basic-link external-destination="embedded-file:{$attachmentName}">
								<xsl:call-template name="addStyle">
									<xsl:with-param name="name">link</xsl:with-param>
								</xsl:call-template>
								<xsl:call-template name="addStyle">
									<xsl:with-param name="name">link.file</xsl:with-param>
								</xsl:call-template>
								<xsl:apply-templates select="current()" mode="getLinkText">
									<xsl:with-param name="attachmentName" select="$attachmentName"/>
								</xsl:apply-templates>
							</fo:basic-link>
						</xsl:when>
						<xsl:otherwise>
							<xsl:variable name="url">
								<xsl:value-of select="substring-after(@originalURL, '/')"/>
								<xsl:if test="(@PDFLinkType = 'nameddest' or @PDFLinkType ='page') and string-length(@PDFLinkValue) &gt; 0">
									<xsl:value-of select="concat('#', @PDFLinkType, '=', @PDFLinkValue)"/>
								</xsl:if>
							</xsl:variable>
							<fo:basic-link external-destination="{$url}">
								<xsl:call-template name="addStyle">
									<xsl:with-param name="name">link</xsl:with-param>
								</xsl:call-template>
								<xsl:call-template name="addStyle">
									<xsl:with-param name="name">link.file</xsl:with-param>
								</xsl:call-template>
								<xsl:apply-templates select="current()" mode="getLinkText"/>
							</fo:basic-link>
						</xsl:otherwise>
					</xsl:choose>
				</xsl:when>-->
				<xsl:when test="not($isPDFXMODE) and string-length(@originalURL) &gt; 0">
					<xsl:apply-templates select="current()" mode="writeCharacterizationInfo">
						<xsl:with-param name="isInline" select="true()"/>
					</xsl:apply-templates>
					<xsl:variable name="url">
						<xsl:choose>
							<xsl:when test="string-length($tp_brokerServerURL) &gt; 0">
								<xsl:value-of select="concat($tp_brokerServerURL, @originalURL)"/>
							</xsl:when>
							<xsl:when test="string-length($brokerServerURL) &gt; 0">
								<xsl:value-of select="concat($brokerServerURL, @originalURL)"/>
							</xsl:when>
							<xsl:otherwise>
								<xsl:value-of select="concat(@serverURL, @originalURL)"/>
							</xsl:otherwise>
						</xsl:choose>
						<xsl:if test="(@PDFLinkType = 'nameddest' or @PDFLinkType ='page') and string-length(@PDFLinkValue) &gt; 0">
							<xsl:value-of select="concat('#', @PDFLinkType, '=', @PDFLinkValue)"/>
						</xsl:if>
					</xsl:variable>
					<fo:basic-link external-destination="{$url}">
						<xsl:call-template name="addStyle">
							<xsl:with-param name="name">link</xsl:with-param>
						</xsl:call-template>
						<xsl:call-template name="addStyle">
							<xsl:with-param name="name">link.file</xsl:with-param>
						</xsl:call-template>
						<xsl:apply-templates select="current()" mode="getLinkText"/>
					</fo:basic-link>
				</xsl:when>
				<xsl:otherwise>
					<xsl:call-template name="addStyle">
						<xsl:with-param name="name">link</xsl:with-param>
					</xsl:call-template>
					<xsl:call-template name="addStyle">
						<xsl:with-param name="name">link.file</xsl:with-param>
					</xsl:call-template>
					<xsl:apply-templates select="current()" mode="writeCharacterizationInfo">
						<xsl:with-param name="isInline" select="true()"/>
					</xsl:apply-templates>
					<xsl:apply-templates select="current()" mode="getLinkText"/>
				</xsl:otherwise>
			</xsl:choose>
		</fo:inline>

		<xsl:apply-templates select="current()" mode="writeLinkSuffix"/>

	</xsl:template>

	<xsl:template match="Link.File" mode="getLinkText">
		<xsl:param name="attachmentName"/>
		<xsl:value-of select="@Linktext"/>
	</xsl:template>

	<xsl:template match="Link.XPath">
		<xsl:variable name="url">
			<xsl:choose>
				<xsl:when test="string-length($tp_brokerServerURL) &gt; 0">
					<xsl:value-of select="$tp_brokerServerURL"/>
				</xsl:when>
				<xsl:otherwise>
					<xsl:value-of select="$brokerServerURL"/>
				</xsl:otherwise>
			</xsl:choose>
			<xsl:text>?serverID=</xsl:text>
			<xsl:value-of select="@serverId"/>
			<xsl:text>&amp;objType=</xsl:text>
			<xsl:value-of select="@pluginType"/>
			<xsl:text>&amp;id=</xsl:text>
			<xsl:value-of select="@pluginId"/>
		</xsl:variable>
		<fo:basic-link external-destination="{$url}" show-destination="new">
			<xsl:call-template name="addStyle">
				<xsl:with-param name="name">link</xsl:with-param>
			</xsl:call-template>
			<xsl:call-template name="addStyle">
				<xsl:with-param name="name">link.xref</xsl:with-param>
			</xsl:call-template>
			<xsl:value-of select="@pluginName"/>
		</fo:basic-link>
	</xsl:template>

	<xsl:template match="InfoChunk.Link">
		<xsl:apply-templates/>
	</xsl:template>

	<xsl:template match="lexicon">
		<xsl:choose>
			<xsl:when test="not($isPDFXMODE) and string-length(@lexDoc) &gt; 0">
				<xsl:variable name="linkDestSuffix">
					<xsl:call-template name="getTemplateVariableValue">
						<xsl:with-param name="name">LINK_DESTINATION_SUFFIX</xsl:with-param>
					</xsl:call-template>
				</xsl:variable>
				<fo:basic-link internal-destination="{@lexDoc}{$linkDestSuffix}">
					<xsl:call-template name="addStyle">
						<xsl:with-param name="name">link</xsl:with-param>
					</xsl:call-template>
					<xsl:call-template name="addStyle">
						<xsl:with-param name="name">link.lexicon</xsl:with-param>
					</xsl:call-template>
					<xsl:apply-templates select="current()" mode="writeCharacterizationInfo"/>
					<xsl:apply-templates/>
				</fo:basic-link>
			</xsl:when>
			<xsl:otherwise>
				<fo:inline>
					<xsl:call-template name="addStyle">
						<xsl:with-param name="name">link</xsl:with-param>
					</xsl:call-template>
					<xsl:call-template name="addStyle">
						<xsl:with-param name="name">link.lexicon</xsl:with-param>
					</xsl:call-template>
					<xsl:apply-templates select="current()" mode="writeCharacterizationInfo">
						<xsl:with-param name="isInline" select="true()"/>
					</xsl:apply-templates>
					<xsl:apply-templates/>
				</fo:inline>
			</xsl:otherwise>
		</xsl:choose>
	</xsl:template>

</xsl:stylesheet>