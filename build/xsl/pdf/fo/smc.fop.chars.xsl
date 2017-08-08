<?xml version="1.0" encoding="utf-8"?>
<xsl:stylesheet
	xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
	xmlns:fo="http://www.w3.org/1999/XSL/Format"
	xmlns:axf="http://www.antennahouse.com/names/XSL/Extensions"
	version="1.0">

	<xsl:param name="previewMetadataElements"/>

	<!--<xsl:variable name="FOOTNOTE_LIST" select="list:new()"/>
	<xsl:variable name="FOOTNOTE_MAP" select="map:new()"/>-->

	<xsl:variable name="METADATA_PREVIEW">
		<xsl:call-template name="getTemplateVariableValue">
			<xsl:with-param name="name" select="'METADATA_PREVIEW'"/>
		</xsl:call-template>
	</xsl:variable>

	<!--<xsl:variable name="FOOTNOTE_CURRENT_CHAPTER" select="list:new()"/>-->


	<xsl:template match="*[name()='svg']" mode = "copyme">
		<xsl:copy>
			<xsl:copy-of select = "@*[not(name()='xmlns')]"/>
			<xsl:apply-templates mode  = "copyme"/>
		</xsl:copy>
	</xsl:template>


	<xsl:template match="*" mode = "copyme">
		<xsl:copy>
			<xsl:copy-of select = "@*"/>
			<xsl:apply-templates mode  = "copyme"/>
		</xsl:copy>
	</xsl:template>


	<xsl:template match="symb">

		<xsl:choose>
			<xsl:when test = "string-length(@svgID) &gt; 0 and *[name()='svg']">
				<fo:inline>
					<fo:instream-foreign-object content-width="scale-to-fit" height="1em" overflow="hidden">
						<xsl:apply-templates select = "*[name()='svg']" mode = "copyme"/>
					</fo:instream-foreign-object>
				</fo:inline>
			</xsl:when>
			<xsl:when test="@id = 'soft-hyphen'">
				<!-- doesn't work if wrapped in fo:inline -->
				<xsl:value-of select="@char"/>
			</xsl:when>
			<xsl:when test="string-length(@char) &gt; 0">
				<fo:inline>
					<xsl:if test="string-length(@font) &gt; 0">
						<xsl:attribute name="font-family">
							<xsl:value-of select="@font"/>
						</xsl:attribute>
					</xsl:if>
					<xsl:if test="string-length(@color) &gt; 0">
						<xsl:attribute name="color">
							<xsl:value-of select="@color"/>
						</xsl:attribute>
					</xsl:if>

					<xsl:if test="ancestor::InfoChunk.High">
						<xsl:attribute name="vertical-align">
							<xsl:value-of select="'top'"/>
						</xsl:attribute>
					</xsl:if>


					<xsl:value-of select="@char"/>
				</fo:inline>
			</xsl:when>


		</xsl:choose>

	</xsl:template>

	<xsl:template match="underline">
		<fo:inline>
			<xsl:call-template name="addStyle">
				<xsl:with-param name="name">underline</xsl:with-param>
			</xsl:call-template>
			<xsl:apply-templates/>
		</fo:inline>
	</xsl:template>

	<xsl:template match="METADATA">
		<xsl:choose>
			<!--<xsl:when test="@type = 'Date' and string-length(.) &gt; 0">
				<xsl:variable name="dateformatInstance" select="dateformat:new('yyyy-MM-dd HH:mm:ss')"/>
				<xsl:variable name="dateInstance" select="dateformat:parse($dateformatInstance, string(.))"/>
				<xsl:choose>
					<xsl:when test="starts-with($language, 'en')">
						<xsl:variable name="shortDateformatInstance" select="dateformat:new('MM.dd.yyyy')"/>
						<xsl:value-of select="dateformat:format($shortDateformatInstance, $dateInstance)"/>
					</xsl:when>
					<xsl:otherwise>
						<xsl:variable name="shortDateformatInstance" select="dateformat:new('dd.MM.yyyy')"/>
						<xsl:value-of select="dateformat:format($shortDateformatInstance, $dateInstance)"/>
					</xsl:otherwise>
				</xsl:choose>
			</xsl:when>-->
			<xsl:when test="@type = 'TextArea'">
				<xsl:value-of select="translate(., '&#10;', '&#x85;')"/>
			</xsl:when>
			<xsl:when test="string-length(.) &gt; 0">
				<xsl:apply-templates/>
			</xsl:when>
			<xsl:when test="$generate_translation_helper = 'true' or $CMS = 'CMS' or $METADATA_PREVIEW = 'true' or $previewMetadataElements = 'true'">
				<xsl:text>&lt;</xsl:text>
				<xsl:value-of select="@name"/>
				<xsl:text>&gt;</xsl:text>
			</xsl:when>
		</xsl:choose>
	</xsl:template>

	<xsl:template match="InfoChunk.High" mode="fix-vertical-align">
		<xsl:attribute name="vertical-align">top</xsl:attribute>
	</xsl:template>

	<xsl:template match="symbol">
		<xsl:choose>
			<xsl:when test="soft-hyphen">
				<xsl:apply-templates select="soft-hyphen" mode="symbol"/>
			</xsl:when>
			<xsl:otherwise>
				<fo:inline font-family="Arial">
					<xsl:apply-templates select="ancestor::InfoChunk.High" mode="fix-vertical-align"/>
					<xsl:call-template name="addStyle">
						<xsl:with-param name="name">symbol</xsl:with-param>
					</xsl:call-template>
					<xsl:apply-templates select="*" mode="symbol"/>
				</fo:inline>
			</xsl:otherwise>
		</xsl:choose>
	</xsl:template>

	<xsl:template match="Link.note">

		<xsl:if test="not(ancestor::*[name() = 'link.element' or name() = 'InfoChunk.Link']) and node()">
			<xsl:variable name="FOOTNOTE_SEPARATOR_TOKEN">
				<xsl:call-template name="getTemplateVariableValue">
					<xsl:with-param name="name" select="'FOOTNOTE_SEPARATOR_TOKEN'"/>
				</xsl:call-template>
			</xsl:variable>

			<xsl:variable name="FOOTNOTE_IDENT">
				<xsl:call-template name="getTemplateVariableValue">
					<xsl:with-param name="name" select="'FOOTNOTE_IDENT'"/>
					<xsl:with-param name="defaultValue" select="'0.4cm'"/>
				</xsl:call-template>
			</xsl:variable>

			<xsl:variable name="FOOTNOTE_RESTART_NUMBERING">
				<xsl:call-template name="getTemplateVariableValue">
					<xsl:with-param name="name" select="'FOOTNOTE_RESTART_NUMBERING'"/>
				</xsl:call-template>
			</xsl:variable>

			<xsl:choose>
				<xsl:when test="ancestor::Link.note">
					<xsl:apply-templates/>
				</xsl:when>
				<xsl:otherwise>
			<xsl:variable name="char" select="normalize-space(@character)"/>
			<xsl:variable name="isEmpty" select="$char = ''"/>

			<!--<xsl:if test="$FOOTNOTE_RESTART_NUMBERING = 'chapter' or $FOOTNOTE_RESTART_NUMBERING = 'main-chapter'">
				<xsl:variable name="currChapt">
					<xsl:choose>
						<xsl:when test="$FOOTNOTE_RESTART_NUMBERING = 'main-chapter'">
							<xsl:apply-templates select="current()" mode="getMainChapterNr"/>
						</xsl:when>
						<xsl:otherwise>
							<xsl:apply-templates select="current()" mode="getChapterNr"/>
						</xsl:otherwise>
					</xsl:choose>
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

				<xsl:if test="string(list:contains($FOOTNOTE_CURRENT_CHAPTER, string($internalCurrChapt))) = 'false'">
					<xsl:variable name="remove" select="list:removeAllElements($FOOTNOTE_LIST)"/>
					<xsl:variable name="remove2" select="list:removeAllElements($FOOTNOTE_CURRENT_CHAPTER)"/>
					<xsl:variable name="add" select="list:add($FOOTNOTE_CURRENT_CHAPTER, string($internalCurrChapt))"/>
				</xsl:if>
			</xsl:if>-->

			<!--<xsl:if test="$isEmpty">
				<xsl:if test="string-length(map:get($FOOTNOTE_MAP, generate-id())) = 0">
					<xsl:variable name="add" select="list:add($FOOTNOTE_LIST, '1')"/>
				</xsl:if>
				<xsl:variable name="put" select="map:put($FOOTNOTE_MAP, generate-id(), string(list:size($FOOTNOTE_LIST)))"/>
			</xsl:if>-->

			<xsl:variable name="genChar">
				<xsl:choose>
					<xsl:when test="$isEmpty">
						<!--<xsl:value-of select="map:get($FOOTNOTE_MAP, generate-id())"/>-->
						<xsl:value-of select="count(preceding::Link.note[string-length(normalize-space(@character)) = 0]) + 1"/>
					</xsl:when>
					<xsl:otherwise>
						<xsl:value-of select="$char"/>
					</xsl:otherwise>
				</xsl:choose>
			</xsl:variable>

			<xsl:variable name="columns">
				<xsl:call-template name="getColumnCount"/>
			</xsl:variable>

			<xsl:variable name="hasColumns" select="$columns &gt; 1"/>

			<fo:footnote>
				<xsl:if test="$isAHMode">
					<xsl:attribute name="axf:suppress-duplicate-footnote">true</xsl:attribute>
					<xsl:if test="$hasColumns">
						<xsl:attribute name="axf:footnote-position">column</xsl:attribute>
						<xsl:attribute name="axf:suppress-duplicate-footnote">true</xsl:attribute>
					</xsl:if>
				</xsl:if>
				<fo:inline font-size="60%" vertical-align="top">
					<xsl:call-template name="addStyle">
						<xsl:with-param name="name">footnote</xsl:with-param>
					</xsl:call-template>
					<xsl:choose>
						<xsl:when test="$isEmpty and $isAHMode">
							<axf:footnote-number id="{generate-id()}" vertical-align="top"/>
						</xsl:when>
						<xsl:otherwise>
							<xsl:value-of select="$genChar"/>
						</xsl:otherwise>
					</xsl:choose>
					<xsl:call-template name="getTemplateVariableValue">
						<xsl:with-param name="name" select="'FOOTNOTE_SUFFIX'"/>
					</xsl:call-template>
				</fo:inline>
				<fo:footnote-body>
					<fo:block>
						<xsl:call-template name="addStyle">
							<xsl:with-param name="name">footnote.text</xsl:with-param>
						</xsl:call-template>
						<fo:list-block>
							<fo:list-item>
								<fo:list-item-label start-indent="0" end-indent="label-end()">
									<fo:block>
										<fo:inline font-size="60%" vertical-align="top">
											<xsl:call-template name="addStyle">
												<xsl:with-param name="name">footnote</xsl:with-param>
											</xsl:call-template>
											<xsl:choose>
												<xsl:when test="$isEmpty and $isAHMode">
													<axf:footnote-number-citation ref-id="{generate-id()}" vertical-align="top"/>
													<xsl:value-of select="$FOOTNOTE_SEPARATOR_TOKEN"/>
												</xsl:when>
												<xsl:otherwise>
													<xsl:value-of select="concat($genChar, $FOOTNOTE_SEPARATOR_TOKEN)"/>
												</xsl:otherwise>
											</xsl:choose>
											<xsl:call-template name="getTemplateVariableValue">
												<xsl:with-param name="name" select="'FOOTNOTE_SUFFIX'"/>
											</xsl:call-template>
										</fo:inline>
									</fo:block>
								</fo:list-item-label>
								<fo:list-item-body start-indent="{$FOOTNOTE_IDENT}">
									<fo:block>
										<xsl:apply-templates>
											<xsl:with-param name="context" select="'footnote'"/>
										</xsl:apply-templates>
									</fo:block>
								</fo:list-item-body>
							</fo:list-item>
						</fo:list-block>
					</fo:block>
				</fo:footnote-body>
			</fo:footnote>
				</xsl:otherwise>
			</xsl:choose>
		</xsl:if>

	</xsl:template>

	<xsl:template match="InfoChunk.TableFootnote">
		<xsl:variable name="name" select="@name"/>
		<xsl:if test="ancestor::*[name()='table' or name()='table.NoBorder'][1]/following-sibling::*[not(name() = 'TableDesc')][1][name() = 'legend' and @isTableLegend]/legend.row[legend.term = $name]">
			<fo:inline font-size="60%" vertical-align="top">
				<xsl:call-template name="addStyle">
					<xsl:with-param name="name">tableFootnote</xsl:with-param>
				</xsl:call-template>
				<xsl:value-of select="@name"/>
				<xsl:call-template name="getTemplateVariableValue">
					<xsl:with-param name="name" select="'TABLEFOOTNOTE_SUFFIX'"/>
				</xsl:call-template>
			</fo:inline>
		</xsl:if>
	</xsl:template>

	<xsl:template match="InfoChunk.Invalid">
		<xsl:param name="doJoin" select="false()"/>
		<fo:inline>
			<xsl:call-template name="addStyle">
				<xsl:with-param name="name">invalid</xsl:with-param>
			</xsl:call-template>
			<xsl:choose>
				<xsl:when test="$doJoin">
					<xsl:apply-templates mode="join">
						<xsl:with-param name="isInline" select="true()"/>
					</xsl:apply-templates>
				</xsl:when>
				<xsl:otherwise>
					<xsl:apply-templates>
						<xsl:with-param name="isInline" select="true()"/>
					</xsl:apply-templates>
				</xsl:otherwise>
			</xsl:choose>
		</fo:inline>
	</xsl:template>

	<xsl:template match="page.break | break">
		<xsl:variable name="visible">
			<xsl:call-template name="getFormat">
				<xsl:with-param name="name">break</xsl:with-param>
				<xsl:with-param name="attributeName">visibility</xsl:with-param>
			</xsl:call-template>
		</xsl:variable>
		<xsl:apply-templates select="current()" mode="writeCharacterizationInfo"/>
		<xsl:if test="not($visible = 'hidden') and
					(not(@Changed = 'INSERTED') or not(following-sibling::*[1][name() = 'break' and not(@Changed)]))">
			<fo:block break-after="page" space-before="0pt" space-after="0pt" margin-top="0pt" margin-bottom="0pt" line-height="1pt">
				<xsl:choose>
					<xsl:when test="@type = 'column'">
						<xsl:attribute name="break-after">column</xsl:attribute>
					</xsl:when>
				</xsl:choose>
			</fo:block>
			<xsl:variable name="columns">
				<xsl:call-template name="getColumnCount"/>
			</xsl:variable>

			<xsl:variable name="hasColumns" select="$columns &gt; 1"/>
			<xsl:if test="not(following-sibling::*) and $hasColumns and not($isAHMode)">
				<!-- hacky workaround because of FOP bug: if break is the last element of a spanned block the next block isn't rendered with columns,
				by inserting an empty fo:block element, this error doesn't occur-->
				<xsl:for-each select="ancestor::*[starts-with(name(), 'Block')][1]">
					<xsl:variable name="span">
						<xsl:call-template name="getFormat">
							<xsl:with-param name="name">container-block</xsl:with-param>
							<xsl:with-param name="attributeName">span</xsl:with-param>
						</xsl:call-template>
					</xsl:variable>
					<xsl:choose>
						<xsl:when test="$span = 'all'">
							<fo:block/>
						</xsl:when>
						<xsl:otherwise>
							<xsl:for-each select="ancestor::InfoMap[1]">
								<xsl:variable name="spanSection">
									<xsl:call-template name="getFormat">
										<xsl:with-param name="name">section</xsl:with-param>
										<xsl:with-param name="attributeName">span</xsl:with-param>
									</xsl:call-template>
								</xsl:variable>
								<xsl:if test="$spanSection = 'all'">
									<fo:block/>
								</xsl:if>
							</xsl:for-each>
						</xsl:otherwise>
					</xsl:choose>
				</xsl:for-each>
			</xsl:if>
		</xsl:if>
	</xsl:template>

	<xsl:template match="InfoChunk.Break" name = "InfoChunk.Break">
		<xsl:choose>
			<xsl:when test="$isAHMode">
				<fo:block/>
				<fo:inline>
					<xsl:choose>
						<xsl:when test="$isPDFXMODE">
							<xsl:attribute name="font-family">Arial Unicode MS</xsl:attribute>
						</xsl:when>
						<xsl:otherwise>
							<xsl:attribute name="font-family">Helvetica</xsl:attribute>
						</xsl:otherwise>
					</xsl:choose>
					<xsl:text>&#8203;</xsl:text>
				</fo:inline>
			</xsl:when>
			<xsl:otherwise>&#x85;</xsl:otherwise>
		</xsl:choose>
		<xsl:if test="not(following-sibling::node()) and (not(starts-with(name(parent::*), 'InfoChunk.')) or not(parent::*/following-sibling::node()))">
			<xsl:choose>
				<xsl:when test="$isAHMode">
					<fo:block/>
					<fo:inline>
						<xsl:choose>
							<xsl:when test="$isPDFXMODE">
								<xsl:attribute name="font-family">Arial Unicode MS</xsl:attribute>
							</xsl:when>
							<xsl:otherwise>
								<xsl:attribute name="font-family">Helvetica</xsl:attribute>
							</xsl:otherwise>
						</xsl:choose>
						<xsl:text>&#8203;</xsl:text>
					</fo:inline>
				</xsl:when>
				<xsl:otherwise>&#x85;</xsl:otherwise>
			</xsl:choose>
		</xsl:if>
	</xsl:template>

	<xsl:template match="InfoChunk.Italics">
		<xsl:param name="doJoin" select="false()"/>
		<fo:inline>
			<xsl:call-template name="addStyle">
				<xsl:with-param name="name">italics</xsl:with-param>
			</xsl:call-template>
			<xsl:apply-templates select="current()" mode="writeCharacterizationInfo">
				<xsl:with-param name="isInline" select="true()" />
			</xsl:apply-templates>
			<xsl:choose>
				<xsl:when test="$doJoin">
					<xsl:apply-templates mode="join">
						<xsl:with-param name="isInline" select="true()"/>
					</xsl:apply-templates>
				</xsl:when>
				<xsl:otherwise>
					<xsl:apply-templates>
						<xsl:with-param name="isInline" select="true()"/>
					</xsl:apply-templates>
				</xsl:otherwise>
			</xsl:choose>
		</fo:inline>
	</xsl:template>

	<xsl:template match="space">
		<xsl:text> </xsl:text>
	</xsl:template>

	<xsl:template match="InfoChunk.Marked">
		<xsl:param name="doJoin" select="false()"/>
		<xsl:param name="isInsideMarker"/>
		<xsl:choose>
			<xsl:when test="@author-support and not($isInsideMarker)">
				<fo:inline color="{@bordercolor}" border="1px dotted {@bordercolor}">
					<xsl:call-template name="addStyle">
						<xsl:with-param name="name">marker.authorsupport</xsl:with-param>
					</xsl:call-template>
					<xsl:apply-templates select="current()" mode="writeCharacterizationInfo">
						<xsl:with-param name="isInline" select="true()" />
					</xsl:apply-templates>
					<xsl:choose>
						<xsl:when test="$doJoin">
							<xsl:apply-templates mode="join">
								<xsl:with-param name="isInline" select="true()"/>
							</xsl:apply-templates>
						</xsl:when>
						<xsl:otherwise>
							<xsl:apply-templates>
								<xsl:with-param name="isInline" select="true()"/>
							</xsl:apply-templates>
						</xsl:otherwise>
					</xsl:choose>
				</fo:inline>
				<fo:footnote color="{@bordercolor}">
					<fo:inline vertical-align="top" font-size="60%">
						<!--<xsl:variable name="add" select="list:add($FOOTNOTE_LIST, '1')"/>
						<xsl:value-of select="list:size($FOOTNOTE_LIST)"/>-->
					</fo:inline>
					<fo:footnote-body start-indent="0">
						<fo:block font-size="80%">
							<fo:inline vertical-align="top" font-size="70%">
								<!--<xsl:value-of select="list:size($FOOTNOTE_LIST)"/>-->
								<xsl:text>) </xsl:text>
							</fo:inline>
							<fo:inline font-weight="bold">
								<xsl:value-of select="@type"/>
								<xsl:text>: </xsl:text>
							</fo:inline>
							<xsl:variable name="description">
								<xsl:choose>
									<xsl:when test="@type = 'TERM' and contains(@description, '|Domains:')">
										<xsl:value-of select="substring-before(@description, '|Domains:')"/>
									</xsl:when>
									<xsl:otherwise>
										<xsl:value-of select="@description"/>
									</xsl:otherwise>
								</xsl:choose>
							</xsl:variable>
							<xsl:choose>
								<xsl:when test="starts-with(@help, 'http')">
									<fo:basic-link external-destination="{@help}" show-destination="new" text-decoration="underline">
										<xsl:value-of select="$description"/>
									</fo:basic-link>
								</xsl:when>
								<xsl:otherwise>
									<xsl:value-of select="$description"/>
								</xsl:otherwise>
							</xsl:choose>
							<xsl:if test="string-length(@suggestions) &gt; 0">
								<xsl:text> - </xsl:text>
								<xsl:value-of select="@suggestions"/>
							</xsl:if>
							<xsl:if test="string-length(@standards) &gt; 0">
								<xsl:text> - </xsl:text>
								<xsl:value-of select="@standards"/>
							</xsl:if>							
						</fo:block>
					</fo:footnote-body>
				</fo:footnote>
			</xsl:when>
			<xsl:otherwise>
				<xsl:variable name="position">
					<xsl:call-template name="getFormat">
						<xsl:with-param name="name">marker</xsl:with-param>
						<xsl:with-param name="attributeName">position</xsl:with-param>
					</xsl:call-template>
				</xsl:variable>
				<xsl:choose>
					<xsl:when test="string-length($position) &gt; 0 and $position != 'static'">
						<fo:block-container>
							<xsl:call-template name="addStyle">
								<xsl:with-param name="name">marker</xsl:with-param>
							</xsl:call-template>
							<xsl:apply-templates select="current()" mode="writeCharacterizationInfo"/>
							<fo:block>
								<xsl:choose>
									<xsl:when test="$doJoin">
										<xsl:apply-templates mode="join">
											<xsl:with-param name="isInline" select="true()"/>
										</xsl:apply-templates>
									</xsl:when>
									<xsl:otherwise>
										<xsl:apply-templates>
											<xsl:with-param name="isInline" select="true()"/>
										</xsl:apply-templates>
									</xsl:otherwise>
								</xsl:choose>
							</fo:block>
						</fo:block-container>
					</xsl:when>
					<xsl:otherwise>
						<fo:inline>
							<xsl:call-template name="addStyle">
								<xsl:with-param name="name">marker</xsl:with-param>
							</xsl:call-template>
							<xsl:apply-templates select="current()" mode="writeCharacterizationInfo">
								<xsl:with-param name="isInline" select="true()" />
							</xsl:apply-templates>
							<xsl:choose>
								<xsl:when test="$doJoin">
									<xsl:apply-templates mode="join">
										<xsl:with-param name="isInline" select="true()"/>
									</xsl:apply-templates>
								</xsl:when>
								<xsl:otherwise>
									<xsl:apply-templates>
										<xsl:with-param name="isInline" select="true()"/>
									</xsl:apply-templates>
								</xsl:otherwise>
							</xsl:choose>
						</fo:inline>
					</xsl:otherwise>
				</xsl:choose>
			</xsl:otherwise>
		</xsl:choose>
	</xsl:template>

	<xsl:template match="InfoChunk.Important">
		<xsl:param name="doJoin" select="false()"/>
		<fo:inline>
			<xsl:call-template name="addStyle">
				<xsl:with-param name="name">emphasis</xsl:with-param>
			</xsl:call-template>
			<xsl:if test="string-length(@ID) &gt; 0">
				<xsl:attribute name="id">
					<xsl:value-of select="@ID"/>
				</xsl:attribute>
			</xsl:if>
			<xsl:apply-templates select="current()" mode="writeCharacterizationInfo">
				<xsl:with-param name="isInline" select="true()"/>
			</xsl:apply-templates>
			<xsl:choose>
				<xsl:when test="$doJoin">
					<xsl:apply-templates mode="join">
						<xsl:with-param name="isInline" select="true()"/>
					</xsl:apply-templates>
				</xsl:when>
				<xsl:otherwise>
					<xsl:apply-templates>
						<xsl:with-param name="isInline" select="true()"/>
					</xsl:apply-templates>
				</xsl:otherwise>
			</xsl:choose>
		</fo:inline>
	</xsl:template>

	<xsl:template match="InfoChunk.High">
		<xsl:param name="doJoin" select="false()"/>
		<xsl:choose>
			<!-- necessary because of FOP bug -->
			<xsl:when test="InfoChunk.Low">
				<xsl:choose>
					<xsl:when test="$doJoin">
						<xsl:apply-templates mode="join">
							<xsl:with-param name="isInline" select="true()"/>
						</xsl:apply-templates>
					</xsl:when>
					<xsl:otherwise>
						<xsl:apply-templates>
							<xsl:with-param name="isInline" select="true()"/>
						</xsl:apply-templates>
					</xsl:otherwise>
				</xsl:choose>
			</xsl:when>
			<xsl:otherwise>
				<fo:inline font-size="60%" vertical-align="top">
					<xsl:call-template name="addStyle">
						<xsl:with-param name="name">superscript</xsl:with-param>
					</xsl:call-template>
					<xsl:apply-templates select="current()" mode="writeCharacterizationInfo">
						<xsl:with-param name="isInline" select="true()" />
					</xsl:apply-templates>
					<xsl:choose>
						<xsl:when test="$doJoin">
							<xsl:apply-templates mode="join">
								<xsl:with-param name="isInline" select="true()"/>
							</xsl:apply-templates>
						</xsl:when>
						<xsl:otherwise>
							<xsl:apply-templates>
								<xsl:with-param name="isInline" select="true()"/>
							</xsl:apply-templates>
						</xsl:otherwise>
					</xsl:choose>
				</fo:inline>
			</xsl:otherwise>
		</xsl:choose>
	</xsl:template>

	<xsl:template match="InfoChunk.Low">
		<xsl:param name="doJoin" select="false()"/>
		<fo:inline vertical-align="sub" font-size="60%">
			<xsl:call-template name="addStyle">
				<xsl:with-param name="name">subscript</xsl:with-param>
			</xsl:call-template>
			<xsl:apply-templates select="current()" mode="writeCharacterizationInfo">
				<xsl:with-param name="isInline" select="true()" />
			</xsl:apply-templates>
			<xsl:choose>
				<xsl:when test="$doJoin">
					<xsl:apply-templates mode="join">
						<xsl:with-param name="isInline" select="true()"/>
					</xsl:apply-templates>
				</xsl:when>
				<xsl:otherwise>
					<xsl:apply-templates>
						<xsl:with-param name="isInline" select="true()"/>
					</xsl:apply-templates>
				</xsl:otherwise>
			</xsl:choose>
		</fo:inline>
	</xsl:template>

	<xsl:template match="InfoChunk.Invers">
		<xsl:param name="doJoin" select="false()"/>
		<fo:inline>
			<xsl:call-template name="addStyle">
				<xsl:with-param name="name">invers</xsl:with-param>
			</xsl:call-template>
			<xsl:call-template name="addStyle">
				<xsl:with-param name="name">inverted</xsl:with-param>
			</xsl:call-template>
			<xsl:apply-templates select="current()" mode="writeCharacterizationInfo">
				<xsl:with-param name="isInline" select="false()" />
			</xsl:apply-templates>
			<xsl:choose>
				<xsl:when test="$doJoin">
					<xsl:apply-templates mode="join">
						<xsl:with-param name="isInline" select="true()"/>
					</xsl:apply-templates>
				</xsl:when>
				<xsl:otherwise>
					<xsl:apply-templates/>
				</xsl:otherwise>
			</xsl:choose>
		</fo:inline>
	</xsl:template>

	<xsl:template match="InfoChunk.Code">
		<xsl:param name="doJoin" select="false()"/>
		<fo:inline>
			<xsl:call-template name="addStyle">
				<xsl:with-param name="name">code.inline</xsl:with-param>
			</xsl:call-template>
			<xsl:apply-templates select="current()" mode="writeCharacterizationInfo">
				<xsl:with-param name="isInline" select="false()" />
			</xsl:apply-templates>
			<xsl:choose>
				<xsl:when test="$doJoin">
					<xsl:apply-templates mode="join">
						<xsl:with-param name="isInline" select="true()"/>
					</xsl:apply-templates>
				</xsl:when>
				<xsl:otherwise>
					<xsl:apply-templates>
						<xsl:with-param name="isInline" select="true()"/>
					</xsl:apply-templates>
				</xsl:otherwise>
			</xsl:choose>
		</fo:inline>
	</xsl:template>

	<xsl:template match="InfoChunk.Dialog">
		<fo:inline>
			<xsl:call-template name="addStyle">
				<xsl:with-param name="name">dialog</xsl:with-param>
			</xsl:call-template>
			<xsl:apply-templates select="current()" mode="writeCharacterizationInfo">
				<xsl:with-param name="isInline" select="false()" />
			</xsl:apply-templates>
			<xsl:apply-templates>
				<xsl:with-param name="isInline" select="true()"/>
			</xsl:apply-templates>
		</fo:inline>
	</xsl:template>

	<xsl:template match="InfoChunk.NoBreak">
		<fo:inline keep-together.within-line="always">
			<xsl:call-template name="addStyle">
				<xsl:with-param name="name">no.linebreak</xsl:with-param>
			</xsl:call-template>
			<!--<xsl:apply-templates mode="join">
				<xsl:with-param name="isInline" select="true()"/>
			</xsl:apply-templates>-->
			<xsl:apply-templates>
				<xsl:with-param name="isInline" select="true()"/>
			</xsl:apply-templates>
		</fo:inline>
	</xsl:template>


	<xsl:template match="InfoChunk">
		<fo:inline>
			<xsl:call-template name="addStyle">
				<xsl:with-param name="name">
					<xsl:value-of select="@style"/>
				</xsl:with-param>
			</xsl:call-template>
			<xsl:variable name="chunkPrefix">
				<xsl:call-template name="getTemplateVariableValue">
					<xsl:with-param name="name" select="concat(@style, '_PREFIX')"/>
				</xsl:call-template>
			</xsl:variable>
			<xsl:if test="string-length($chunkPrefix) &gt; 0">
				<xsl:value-of select="$chunkPrefix"/>
			</xsl:if>
			<xsl:apply-templates select="current()" mode="writeCharacterizationInfo">
				<xsl:with-param name="isInline" select="true()" />
			</xsl:apply-templates>
			<xsl:apply-templates>
				<xsl:with-param name="isInline" select="true()"/>
			</xsl:apply-templates>
			<xsl:variable name="chunkSuffix">
				<xsl:call-template name="getTemplateVariableValue">
					<xsl:with-param name="name" select="concat(@style, '_SUFFIX')"/>
				</xsl:call-template>
			</xsl:variable>
			<xsl:if test="string-length($chunkSuffix) &gt; 0">
				<xsl:value-of select="$chunkSuffix"/>
			</xsl:if>
		</fo:inline>
	</xsl:template>

	<xsl:template match="include.text">
		<xsl:choose>
			<!-- avoid formatting if possible, because FOP has layout issues, see http://mantis.ec-systems.de/view.php?id=5579 -->
			<xsl:when test="string-length(@Changed) &gt; 0 or string-length(@filter) &gt; 0 or string-length(@metafilter) &gt; 0">
				<fo:inline>
					<xsl:call-template name="addStyle">
						<xsl:with-param name="name">include.text</xsl:with-param>
					</xsl:call-template>
			<xsl:apply-templates select="current()" mode="writeCharacterizationInfo">
				<xsl:with-param name="isInline" select="true()" />
			</xsl:apply-templates>
					<xsl:apply-templates>
						<xsl:with-param name="isInline" select="true()"/>
					</xsl:apply-templates>
				</fo:inline>
			</xsl:when>
			<xsl:otherwise>
				<xsl:apply-templates>
					<xsl:with-param name="isInline" select="true()"/>
				</xsl:apply-templates>
			</xsl:otherwise>
		</xsl:choose>
	</xsl:template>

	<xsl:template match="*" mode="join">
		<xsl:apply-templates select="current()">
			<xsl:with-param name="doJoin" select="true()"/>
			<xsl:with-param name="isInline" select="true()"/>
		</xsl:apply-templates>
	</xsl:template>

	<xsl:template match="text()" mode="join">
		<xsl:call-template name="doJoin">
			<xsl:with-param name="text" select="string(.)"/>
		</xsl:call-template>
	</xsl:template>

	<xsl:template name="doJoin">
		<xsl:param name="text"/>
		<xsl:choose>
			<xsl:when test="string-length($text) &gt; 0 and not($isRightToLeftLanguage)">
				<xsl:variable name="char" select="substring($text, 1, 1)"/>
				<fo:character character="{$char}" hyphenate="false"/>
				<xsl:call-template name="doJoin">
					<xsl:with-param name="text" select="substring($text, 2)"/>
				</xsl:call-template>
			</xsl:when>
			<xsl:otherwise>
				<xsl:value-of select="$text"/>
			</xsl:otherwise>
		</xsl:choose>
	</xsl:template>

	<xsl:template match="Index">
		<xsl:param name="doJoin" select="false()"/>
		<xsl:param name="visible" select="not(index.entry/@notVisible = 'true')"/>
		<fo:inline>
			<xsl:if test="index.entry/@ID">
				<xsl:attribute name="id">
					<xsl:value-of select="index.entry/@ID"/>
				</xsl:attribute>
			</xsl:if>
			<xsl:apply-templates select="current()" mode="writeCharacterizationInfo">
				<xsl:with-param name="isInline" select="true()" />
			</xsl:apply-templates>
			<xsl:choose>
				<xsl:when test="$visible and string-length(.) &gt; 0">
					<xsl:choose>
						<xsl:when test="$doJoin">
							<xsl:apply-templates mode="join"/>
						</xsl:when>
						<xsl:otherwise>
							<xsl:apply-templates/>
						</xsl:otherwise>
					</xsl:choose>
				</xsl:when>
				<xsl:otherwise>
					<!-- inline must have content because otherwise FOP crashes-->
					<xsl:choose>
						<xsl:when test="$isPDFXMODE">
							<xsl:attribute name="font-family">Arial Unicode MS</xsl:attribute>
						</xsl:when>
						<xsl:otherwise>
							<xsl:attribute name="font-family">
								<xsl:apply-templates select="current()" mode="getDefaultFont"/>
							</xsl:attribute>
						</xsl:otherwise>
					</xsl:choose>
					<xsl:text>&#8203;</xsl:text>
				</xsl:otherwise>
			</xsl:choose>
		</fo:inline>
	</xsl:template>

	<xsl:template match="Index" mode="getDefaultFont">Helvetica</xsl:template>
		
	<xsl:template match="Index" mode="printText">
		<xsl:if test="not(index.entry/@notVisible = 'true')">
			<xsl:value-of select="."/>
		</xsl:if>
	</xsl:template>

	<xsl:template match="number">
		<fo:inline>
			<xsl:call-template name="addStyle">
				<xsl:with-param name="name">number</xsl:with-param>
			</xsl:call-template>
			<xsl:apply-templates select="current()" mode="writeCharacterizationInfo">
				<xsl:with-param name="isInline" select="false()" />
			</xsl:apply-templates>
			<xsl:call-template name="formatNumber"/>
		</fo:inline>
	</xsl:template>


</xsl:stylesheet>
