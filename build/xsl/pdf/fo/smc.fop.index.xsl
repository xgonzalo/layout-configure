<?xml version="1.0" encoding="UTF-8" standalone="no"?>
<xsl:stylesheet version="1.0" xmlns:fo="http://www.w3.org/1999/XSL/Format" xmlns:xsl="http://www.w3.org/1999/XSL/Transform">

	<xsl:template match="generate.index">
		<xsl:variable name="displayType">
			<xsl:call-template name="getTemplateVariableValue">
				<xsl:with-param name="name" select="'GENERATE_INDEX_DISPLAY_TYPE'"/>
				<xsl:with-param name="defaultValue">
					<xsl:apply-templates select="current()" mode="getDefaultDisplayType"/>
				</xsl:with-param>
			</xsl:call-template>
		</xsl:variable>
		<xsl:variable name="linkTextToFirstOccurrence">
			<xsl:call-template name="getTemplateVariableValue">
				<xsl:with-param name="name" select="'GENERATE_INDEX_LINK_TEXT_TO_FIRST_OCCURRENCE'"/>
				<xsl:with-param name="defaultValue">false</xsl:with-param>
			</xsl:call-template>
		</xsl:variable>

		<xsl:choose>
			<xsl:when test="$displayType = 'letters'">
				<xsl:apply-templates select="current()" mode="complex">
					<xsl:with-param name="linkTextToFirstOccurrence" select="$linkTextToFirstOccurrence = 'true'"/>
				</xsl:apply-templates>
			</xsl:when>
			<xsl:when test="$displayType = 'letters-table'">
				<xsl:apply-templates select="current()" mode="complex-table">
					<xsl:with-param name="linkTextToFirstOccurrence" select="$linkTextToFirstOccurrence = 'true'"/>
				</xsl:apply-templates>
			</xsl:when>
			<xsl:otherwise>
				<xsl:apply-templates select="current()" mode="simple">
					<xsl:with-param name="linkTextToFirstOccurrence" select="$linkTextToFirstOccurrence = 'true'"/>
				</xsl:apply-templates>
			</xsl:otherwise>
		</xsl:choose>
	</xsl:template>

	<xsl:template match="generate.index" mode="getDefaultDisplayType">simple</xsl:template>

	<xsl:template match="generate.index" mode="simple">
		<xsl:param name="linkTextToFirstOccurrence" select="false()"/>
		<fo:block>
			<xsl:call-template name="addStyle">
				<xsl:with-param name="name">index</xsl:with-param>
			</xsl:call-template>
			
			<xsl:for-each select="indexEntry">
				<xsl:if test="not(preceding-sibling::indexEntry[1][@text]) or preceding-sibling::indexEntry[1]/@text != @text">
					<fo:block space-before="6pt">
						<xsl:call-template name="addStyle">
							<xsl:with-param name="name" select="concat('generate.index.entry.', @level)"/>
						</xsl:call-template>
						<xsl:apply-templates select="current()" mode="writeCategoryText">
							<xsl:with-param name="linkTextToFirstOccurrence" select="$linkTextToFirstOccurrence"/>
						</xsl:apply-templates>
						<xsl:if test="string-length(@text2) = 0">
							<xsl:apply-templates select="current()" mode="writePageNumbers"/>
						</xsl:if>
					</fo:block>
				</xsl:if>

				<xsl:if test="string-length(@text2) &gt; 0">
					<xsl:apply-templates select="current()">
						<xsl:with-param name="linkTextToFirstOccurrence" select="$linkTextToFirstOccurrence"/>
					</xsl:apply-templates>
				</xsl:if>
			</xsl:for-each>
			
		</fo:block>
	</xsl:template>

	<xsl:template match="generate.index" mode="complex">
		<xsl:param name="linkTextToFirstOccurrence" select="false()"/>
		<xsl:param name="useLeader" select="true()"/>
		<xsl:param name="leaderType">dots</xsl:param>

		
		<xsl:for-each select="indexEntry">

			<xsl:variable name = "level">
				<xsl:value-of select = "@level"/>
			</xsl:variable>

			<xsl:if test="not(preceding-sibling::indexEntry[1][@text]) or preceding-sibling::indexEntry[1]/@text != @text">

				<xsl:variable name="capFirstChar" select="@letter"/>

				<xsl:if test="not(preceding-sibling::indexEntry[@letter = $capFirstChar])">
					<fo:block keep-with-next="always">
						<xsl:call-template name="addStyle">
							<xsl:with-param name="name">generate.index.letter</xsl:with-param>
						</xsl:call-template>
						<xsl:value-of select="$capFirstChar"/>
					</fo:block>
				</xsl:if>
				<fo:block>
					<xsl:if test="$useLeader and string-length(@text2) = 0 and string-length(id/@indexId) &gt; 0">
						<xsl:attribute name="text-align-last">justify</xsl:attribute>
					</xsl:if>
					<xsl:call-template name="addStyle">
						<xsl:with-param name="name">generate.index.category</xsl:with-param>
					</xsl:call-template>

					<xsl:call-template name="addStyle">
						<xsl:with-param name="name" select="concat('generate.index.entry.', $level)"/>
					</xsl:call-template>

					<xsl:apply-templates select="current()" mode="writeCategoryText">
						<xsl:with-param name="linkTextToFirstOccurrence" select="$linkTextToFirstOccurrence"/>
					</xsl:apply-templates>
					
					<xsl:if test="string-length(@text2) = 0">
						<xsl:if test="$useLeader and string-length(id/@indexId) &gt; 0  and not(@hidePageNr='true')">
							<fo:leader leader-pattern="{$leaderType}"/>
						</xsl:if>
						<xsl:apply-templates select="current()" mode="writePageNumbers"/>
					</xsl:if>
				</fo:block>
			</xsl:if>

			<xsl:if test="string-length(@text2) &gt; 0">
				<xsl:apply-templates select="current()">
					<xsl:with-param name="useLeader" select="$useLeader"/>
					<xsl:with-param name="leaderType" select="$leaderType"/>
					<xsl:with-param name="linkTextToFirstOccurrence" select="$linkTextToFirstOccurrence"/>
				</xsl:apply-templates>
			</xsl:if>
		</xsl:for-each>

	</xsl:template>

	<xsl:template match="generate.index" mode="complex-table">
		<xsl:param name="linkTextToFirstOccurrence" select="false()"/>

		<xsl:for-each select="indexEntry">
			<xsl:variable name = "level">
				<xsl:value-of select = "@level"/>
			</xsl:variable>

			<xsl:variable name="colWidth">
				<xsl:call-template name="getTemplateVariableValue">
					<xsl:with-param name="name" select="'GENERATE_INDEX_COL2'"/>
					<xsl:with-param name="defaultValue">10mm</xsl:with-param>
				</xsl:call-template>
			</xsl:variable>
			<xsl:if test="not(preceding-sibling::indexEntry[1][@text]) or preceding-sibling::indexEntry[1]/@text != @text">
				<xsl:variable name="capFirstChar" select="@letter"/>
				<xsl:if test="not(preceding-sibling::indexEntry[@letter = $capFirstChar])">
					<fo:block>
						<xsl:call-template name="addStyle">
							<xsl:with-param name="name">generate.index.letter</xsl:with-param>
						</xsl:call-template>
						<xsl:value-of select="$capFirstChar"/>
					</fo:block>
				</xsl:if>
				<fo:table table-layout="fixed" width="100%">
					<xsl:call-template name="addStyle">
						<xsl:with-param name="name">generate.index.category</xsl:with-param>
					</xsl:call-template>
					<fo:table-column column-width="proportional-column-width(1)"/>
					<fo:table-column column-width="{$colWidth}"/>
					<fo:table-body start-indent="0">
						<fo:table-row start-indent="0">
							<fo:table-cell>
								<fo:block>
									<xsl:apply-templates select="current()" mode="writeCategoryText">
										<xsl:with-param name="linkTextToFirstOccurrence" select="$linkTextToFirstOccurrence"/>
									</xsl:apply-templates>
								</fo:block>
							</fo:table-cell>
							<fo:table-cell text-align="right" display-align="after">
								<fo:block>
									<xsl:if test="string-length(@text2) = 0">
										<xsl:apply-templates select="current()" mode="writePageNumbers"/>
									</xsl:if>
								</fo:block>
							</fo:table-cell>
						</fo:table-row>
					</fo:table-body>
				</fo:table>
			</xsl:if>

			<xsl:if test="string-length(@text2) &gt; 0">
				<fo:table table-layout="fixed" width="100%">
					<xsl:call-template name="addStyle">
						<xsl:with-param name="name">generate.index.entry</xsl:with-param>
					</xsl:call-template>
					<xsl:call-template name="addStyle">
						<xsl:with-param name="name" select="concat('generate.index.entry.', $level)"/>
					</xsl:call-template>
					<fo:table-column column-width="proportional-column-width(1)"/>
					<fo:table-column column-width="{$colWidth}"/>
					<fo:table-body start-indent="0">
						<fo:table-row start-indent="0">
							<fo:table-cell>
								<fo:block margin-left="12pt">
									<xsl:apply-templates select="current()" mode="writeIndexEntryWord">
										<xsl:with-param name="linkTextToFirstOccurrence" select="$linkTextToFirstOccurrence"/>
									</xsl:apply-templates>
								</fo:block>
							</fo:table-cell>
							<fo:table-cell text-align="right" display-align="after">
								<fo:block>
									<xsl:apply-templates select="current()" mode="writePageNumbers"/>
								</fo:block>
							</fo:table-cell>
						</fo:table-row>
					</fo:table-body>
				</fo:table>
			</xsl:if>
		</xsl:for-each>
	
	</xsl:template>

	<xsl:template match="indexEntry">
		<xsl:param name="useLeader" select="1 = 2"/>
		<xsl:param name="leaderType">dots</xsl:param>
		<xsl:param name="linkTextToFirstOccurrence" select="false()"/>

		<fo:block margin-left="12pt">
			<xsl:call-template name="addStyle">
				<xsl:with-param name="name">indexEntry</xsl:with-param>
			</xsl:call-template>
			<xsl:call-template name="addStyle">
				<xsl:with-param name="name">generate.index.entry</xsl:with-param>
			</xsl:call-template>

			<xsl:call-template name="addStyle">
				<xsl:with-param name="name" select="concat('generate.index.entry.', @level)"/>
			</xsl:call-template>

			<xsl:if test="$useLeader">
				<xsl:attribute name="text-align-last">justify</xsl:attribute>
			</xsl:if>
			<fo:inline>
				<xsl:call-template name="addStyle">
					<xsl:with-param name="name">indexText</xsl:with-param>
				</xsl:call-template>
				<xsl:apply-templates select="current()" mode="writeIndexEntryWord">
					<xsl:with-param name="linkTextToFirstOccurrence" select="$linkTextToFirstOccurrence"/>
				</xsl:apply-templates>
			</fo:inline>
			<xsl:if test="$useLeader and string-length(id/@indexId) &gt; 0 and not(@hidePageNr='true')">
				<fo:leader leader-pattern="{$leaderType}"/>
			</xsl:if>
			<xsl:apply-templates select="current()" mode="writePageNumbers"/>
		</fo:block>
	</xsl:template>

	<xsl:template name="writePageNumbers">
		<xsl:apply-templates select="current()" mode="writePageNumbers"/>
	</xsl:template>

	<xsl:template match="indexEntry" mode="writePageNumbers">
		<xsl:if test="not(@hidePageNr='true')">
			<xsl:for-each select="id[string-length(@indexId) &gt; 0]">
				<fo:inline>
					<xsl:call-template name="addStyle">
						<xsl:with-param name="name">indexPageref</xsl:with-param>
					</xsl:call-template>
					<xsl:if test="position() != 1">
						<xsl:text>,</xsl:text>
					</xsl:if>
					<xsl:text> </xsl:text>
					<xsl:variable name="linkId">
						<xsl:choose>
							<xsl:when test="@indexId">
								<xsl:value-of select="@indexId"/>
							</xsl:when>
							<xsl:otherwise>
								<xsl:value-of select="text()"/>
							</xsl:otherwise>
						</xsl:choose>
					</xsl:variable>
					<xsl:choose>
						<xsl:when test="$isPDFXMODE">
						<xsl:apply-templates select="current()" mode="writePageReferenceNumber">
							<xsl:with-param name="RefID" select="$linkId"/>
							<xsl:with-param name="chapterRefID" select="key('IndexEntryKey', $linkId)/ancestor-or-self::InfoMap[1]/@ID"/>
						</xsl:apply-templates>
						</xsl:when>
						<xsl:otherwise>
							<fo:basic-link internal-destination="{$linkId}">
							<xsl:apply-templates select="current()" mode="writePageReferenceNumber">
								<xsl:with-param name="RefID" select="$linkId"/>
								<xsl:with-param name="chapterRefID" select="key('IndexEntryKey', $linkId)/ancestor-or-self::InfoMap[1]/@ID"/>
							</xsl:apply-templates>
							</fo:basic-link>
						</xsl:otherwise>
					</xsl:choose>
				</fo:inline>
			</xsl:for-each>
		</xsl:if>
	</xsl:template>

	<xsl:template match="indexEntry" mode="writeCategoryText">
		<xsl:param name="linkTextToFirstOccurrence" select="false()"/>
		<xsl:choose>
			<xsl:when test="$linkTextToFirstOccurrence and string-length(@text2) = 0 and id[string-length(@indexId) &gt; 0]">
				<fo:basic-link internal-destination="{id[string-length(@indexId) &gt; 0][1]/@indexId}">
					<xsl:choose>
						<xsl:when test="text">
							<xsl:apply-templates select="text/node()"/>
						</xsl:when>
						<xsl:otherwise>
							<xsl:value-of select="@text"/>
						</xsl:otherwise>
					</xsl:choose>
				</fo:basic-link>
			</xsl:when>
			<xsl:otherwise>
				<xsl:choose>
					<xsl:when test="text">
						<xsl:apply-templates select="text/node()"/>
					</xsl:when>
					<xsl:otherwise>
						<xsl:value-of select="@text"/>
					</xsl:otherwise>
				</xsl:choose>
			</xsl:otherwise>
		</xsl:choose>
	</xsl:template>

	<xsl:template match="indexEntry" mode="writeIndexEntryWord">
		<xsl:param name="linkTextToFirstOccurrence" select="false()"/>
		<xsl:choose>
			<xsl:when test="$linkTextToFirstOccurrence and id[string-length(@indexId) &gt; 0]">
				<fo:basic-link internal-destination="{id[string-length(@indexId) &gt; 0][1]/@indexId}">
					<xsl:choose>
						<xsl:when test="text2">
							<xsl:apply-templates select="text2/node()"/>
						</xsl:when>
						<xsl:otherwise>
							<xsl:value-of select="@text2"/>
						</xsl:otherwise>
					</xsl:choose>
				</fo:basic-link>
			</xsl:when>
			<xsl:otherwise>
				<xsl:choose>
					<xsl:when test="text2">
						<xsl:apply-templates select="text2/node()"/>
					</xsl:when>
					<xsl:otherwise>
						<xsl:value-of select="@text2"/>
					</xsl:otherwise>
				</xsl:choose>
			</xsl:otherwise>
		</xsl:choose>
	</xsl:template>

</xsl:stylesheet>
