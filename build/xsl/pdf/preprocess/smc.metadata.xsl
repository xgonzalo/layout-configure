<?xml version="1.0" encoding="utf-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" version="1.0"
				xmlns:smc="http://www.expert-communication.de/smc">

	<xsl:template name="formatDate">
		<xsl:param name="date"/>
		<xsl:param name="hasDate"/>
		<xsl:param name="dateString"/>
		<xsl:param name="showTime" select="false()"/>
		<xsl:param name="defaultPattern">
			<xsl:choose>
				<xsl:when test="$showTime">yyyy-MM-dd HH:mm:ss</xsl:when>
				<xsl:otherwise>yyyy-MM-dd</xsl:otherwise>
			</xsl:choose>
		</xsl:param>
		<xsl:variable name="varPrefix">
			<xsl:choose>
				<xsl:when test="$showTime">DATE_TIME_FORMAT</xsl:when>
				<xsl:otherwise>DATE_FORMAT</xsl:otherwise>
			</xsl:choose>
		</xsl:variable>
		<xsl:variable name="dateFormat">
			<xsl:call-template name="getFormatVariableValue">
				<xsl:with-param name="name" select="concat($varPrefix, '_', ancestor::*[string-length(@defaultLanguage) &gt; 0][1]/@defaultLanguage)"/>
				<xsl:with-param name="defaultValue">
					<xsl:call-template name="getFormatVariableValue">
						<xsl:with-param name="name" select="$varPrefix"/>
						<xsl:with-param name="defaultValue" select="$defaultPattern"/>
					</xsl:call-template>
				</xsl:with-param>
			</xsl:call-template>
		</xsl:variable>

		<!--<xsl:variable name="dateformatInstance" select="dateformat:new(string($dateFormat))"/>

		<xsl:choose>
			<xsl:when test="string-length($dateString) &gt; 0">
				<xsl:choose>
					<xsl:when test="string-length($dateString) = 20 and contains($dateString, '-') and contains($dateString, ':')">
						<xsl:variable name="defaultDateformatInstance" select="dateformat:new('yyyy-MM-dd HH:mm:ss')"/>
						<xsl:variable name="dateInstance" select="dateformat:parse($defaultDateformatInstance, string($dateString))"/>
						<xsl:value-of select="dateformat:format($dateformatInstance, $dateInstance)"/>
					</xsl:when>
					<xsl:when test="string-length($dateString) = 25 and contains($dateString, '-') and contains($dateString, ':')">
						<xsl:variable name="defaultDateformatInstance" select="dateformat:new('yyyy-MM-dd HH:mm:ss Z')"/>
						<xsl:variable name="dateInstance" select="dateformat:parse($defaultDateformatInstance, string($dateString))"/>
						<xsl:value-of select="dateformat:format($dateformatInstance, $dateInstance)"/>
					</xsl:when>
					<xsl:otherwise>
						--><!-- unknown date format --><!--
						<xsl:message>
							<xsl:text>Unknown date format: </xsl:text>
							<xsl:value-of select="$dateString"/>
						</xsl:message>
						<xsl:value-of select="$dateString"/>
					</xsl:otherwise>
				</xsl:choose>
			</xsl:when>
			<xsl:when test="$hasDate">
				<xsl:value-of select="dateformat:format($dateformatInstance, $date)"/>
			</xsl:when>
		</xsl:choose>-->
		<xsl:value-of select="$dateString"/>
	</xsl:template>

	<xsl:template match="CustomField" mode="metadata">
		<xsl:if test="(string-length(.) &gt; 0 and not(@languageneutral='true')) or string-length(@value) &gt; 0">
			<xsl:choose>
				<xsl:when test="not(@languageneutral='true')">
					<xsl:value-of select="."/>
				</xsl:when>
				<xsl:otherwise>
					<xsl:value-of select="@value"/>
				</xsl:otherwise>
			</xsl:choose>
		</xsl:if>
	</xsl:template>

	<xsl:template match="METADATA">
		<xsl:variable name="name">
			<xsl:choose>
				<xsl:when test="starts-with(@name, 'SYSTEM-') or string-length(@id) = 0">
					<xsl:value-of select="@name"/>
				</xsl:when>
				<xsl:otherwise>
					<xsl:value-of select="@id"/>
				</xsl:otherwise>
			</xsl:choose>
		</xsl:variable>

		<xsl:choose>
			<xsl:when test="starts-with(@name, 'CUSTOMFIELD-')">
				<xsl:variable name="customFields" select="$firstBlockTitlePage/CustomFields"/>
				<xsl:variable name="customFiledId" select="substring-after(@name, 'CUSTOMFIELD-')"/>
				<xsl:apply-templates select="$customFields/CustomField[@name=$customFiledId]" mode="metadata"/>
			</xsl:when>
			<xsl:when test="starts-with(@name, 'SYSTEM-')">
				<xsl:variable name="useClosestAncestorBook">
					<xsl:call-template name="getFormatVariableValue">
						<xsl:with-param name="name">METADATA_BOOK_USE_CLOSEST_ANCESTOR</xsl:with-param>
					</xsl:call-template>
				</xsl:variable>

				<xsl:variable name="structureProps" select="/*/StructureProperties[not($useClosestAncestorBook = 'true')] | ancestor::*[$useClosestAncestorBook = 'true' and StructureProperties][1]/StructureProperties"/>
				
				<xsl:choose>
					<xsl:when test="@name = 'SYSTEM-Year'">
						<!--<xsl:variable name="calendarInstance" select="calendar:getInstance()"/>
						<xsl:value-of select="calendar:get($calendarInstance, 1)"/>-->
						<xsl:text>2015</xsl:text>
					</xsl:when>
					<xsl:when test="@name = 'SYSTEM-Date'">
						<!--<xsl:variable name="calendarInstance" select="calendar:getInstance()"/>
						<xsl:variable name="dateInstance" select="calendar:getTime($calendarInstance)"/>
						
						<xsl:call-template name="formatDate">
							<xsl:with-param name="date" select="$dateInstance"/>
							<xsl:with-param name="hasDate" select="true()"/>
							<xsl:with-param name="defaultPattern">dd.MM.yyyy</xsl:with-param>
						</xsl:call-template>-->
						<xsl:text>15.10.2015</xsl:text>
					</xsl:when>
					<xsl:when test="@name = 'SYSTEM-Date-International'">
						<!--<xsl:variable name="calendarInstance" select="calendar:getInstance()"/>
						<xsl:variable name="dateInstance" select="calendar:getTime($calendarInstance)"/>

						<xsl:call-template name="formatDate">
							<xsl:with-param name="date" select="$dateInstance"/>
							<xsl:with-param name="hasDate" select="true()"/>
							<xsl:with-param name="defaultPattern">yyyy/MM/dd</xsl:with-param>
						</xsl:call-template>-->
						<xsl:text>2015/10/15</xsl:text>
					</xsl:when>
					<xsl:when test="@name = 'SYSTEM-Book-Version'">
						<xsl:choose>
							<xsl:when test="$useClosestAncestorBook = 'true' and name($structureProps/parent::*) = 'section'">
								<xsl:choose>
									<xsl:when test="string-length($structureProps/parent::*/@containerVersionLabel) = 0">Draft</xsl:when>
									<xsl:otherwise>
										<xsl:value-of select="$structureProps/parent::*/@containerVersionLabel"/>
									</xsl:otherwise>
								</xsl:choose>
							</xsl:when>
							<xsl:when test="starts-with($objType, 'book')">
								<xsl:choose>
									<xsl:when test="string-length($versionLabel) = 0">Draft</xsl:when>
									<xsl:otherwise>
										<xsl:value-of select="$versionLabel"/>
									</xsl:otherwise>
								</xsl:choose>
							</xsl:when>
						</xsl:choose>
					</xsl:when>
					<xsl:when test="@name = 'SYSTEM-Book-CreatedAt'">
						<xsl:call-template name="formatDate">
							<xsl:with-param name="dateString" select="$structureProps/StructureProperty[@name = 'SMC:creationDate']/@value"/>
							<xsl:with-param name="showTime" select="true()"/>
						</xsl:call-template>
					</xsl:when>
					<xsl:when test="@name = 'SYSTEM-Book-CreatedAt-DateOnly'">
						<xsl:call-template name="formatDate">
							<xsl:with-param name="dateString" select="$structureProps/StructureProperty[@name = 'SMC:creationDate']/@value"/>
						</xsl:call-template>
					</xsl:when>
					<xsl:when test="@name = 'SYSTEM-Book-CreatedBy'">
						<xsl:value-of select="$structureProps/StructureProperty[@name = 'SMC:createdBy']/@value"/>
					</xsl:when>
					<xsl:when test="@name = 'SYSTEM-Book-ModifiedAt'">
						<xsl:call-template name="formatDate">
							<xsl:with-param name="dateString" select="$structureProps/StructureProperty[@name = 'SMC:lastModificationDate']/@value"/>
							<xsl:with-param name="showTime" select="true()"/>
						</xsl:call-template>
					</xsl:when>
					<xsl:when test="@name = 'SYSTEM-Book-ModifiedAt-DateOnly'">
						<xsl:call-template name="formatDate">
							<xsl:with-param name="dateString" select="$structureProps/StructureProperty[@name = 'SMC:lastModificationDate']/@value"/>
						</xsl:call-template>
					</xsl:when>
					<xsl:when test="@name = 'SYSTEM-Book-ModifiedBy'">
						<xsl:value-of select="$structureProps/StructureProperty[@name = 'SMC:modifiedBy']/@value"/>
					</xsl:when>
					<xsl:when test="@name = 'SYSTEM-Book-WorkflowState'">
						<xsl:value-of select="$structureProps/StructureProperty[starts-with(@name, 'SMC:workflowstate-')]/@value"/>
					</xsl:when>
					<xsl:when test="@name = 'SYSTEM-Document-Version'">
						<xsl:choose>
							<xsl:when test="string-length(ancestor::section[1]/@versionLabel) &gt; 0">
								<xsl:value-of select="ancestor::section[1]/@versionLabel"/>
							</xsl:when>
							<xsl:when test="not(starts-with($objType, 'book')) and string-length($versionLabel) &gt; 0">
								<xsl:value-of select="$versionLabel"/>
							</xsl:when>
							<xsl:otherwise>Draft</xsl:otherwise>
						</xsl:choose>
					</xsl:when>
					<xsl:when test="@name = 'SYSTEM-Document-ModifiedAt-DateOnly'">
						<xsl:variable name="val">
							<xsl:choose>
								<xsl:when test="ancestor::section/Properties">
									<xsl:value-of select="ancestor::section[1]/Properties/Property[@name = 'SMC:lastModificationDate']/@value"/>
								</xsl:when>
								<xsl:otherwise>
									<xsl:value-of select="/*/Properties/Property[@name = 'SMC:lastModificationDate']/@value"/>
								</xsl:otherwise>
							</xsl:choose>
						</xsl:variable>
						<xsl:if test="string-length($val) &gt; 0">
							<xsl:value-of select="substring-before($val, ' ')"/>
						</xsl:if>
					</xsl:when>
					<xsl:when test="@name = 'SYSTEM-Document-ModifiedAt'">
						<xsl:variable name="val">
							<xsl:choose>
								<xsl:when test="ancestor::section/Properties">
									<xsl:value-of select="ancestor::section[1]/Properties/Property[@name = 'SMC:lastModificationDate']/@value"/>
								</xsl:when>
								<xsl:otherwise>
									<xsl:value-of select="/*/Properties/Property[@name = 'SMC:lastModificationDate']/@value"/>
								</xsl:otherwise>
							</xsl:choose>
						</xsl:variable>
						<xsl:if test="string-length($val) &gt; 0">
							<xsl:value-of select="substring-before($val, ' ')"/>
							<xsl:text> </xsl:text>
							<xsl:value-of select="substring-before(substring-after($val, ' '), ' ')"/>
						</xsl:if>
					</xsl:when>
					<xsl:when test="@name = 'SYSTEM-Document-Language'">
						<xsl:variable name="currLang">
							<xsl:choose>
								<xsl:when test="string-length(ancestor::section[1]/@defaultLanguage) &gt; 0">
									<xsl:value-of select="ancestor::section[1]/@defaultLanguage"/>
								</xsl:when>
								<xsl:otherwise>
									<xsl:value-of select="$LANGUAGE_CODE"/>
								</xsl:otherwise>
							</xsl:choose>
						</xsl:variable>
						<xsl:choose>
							<xsl:when test="string-length(/*/Strings/String[@id = concat('languagecode.', $currLang)]) &gt; 0">
								<xsl:value-of select="/*/Strings/String[@id = concat('languagecode.', $currLang)]"/>
							</xsl:when>
							<xsl:otherwise>
								<xsl:value-of select="$currLang"/>
							</xsl:otherwise>
						</xsl:choose>
					</xsl:when>
					<xsl:when test="@name = 'SYSTEM-Titelseite-Kategorie'">
						<xsl:apply-templates select="$firstBlockTitlePage/title.theme/node()"/>
					</xsl:when>
					<xsl:when test="@name = 'SYSTEM-Titelseite-Untertitel'">
						<xsl:apply-templates select="$firstBlockTitlePage/title/node()"/>
					</xsl:when>
					<xsl:when test="@name = 'SYSTEM-Titelseite-Version'">
						<xsl:apply-templates select="$firstBlockTitlePage/version/node()"/>
					</xsl:when>
					<xsl:when test="@name = 'SYSTEM-Titelseite-optionaler Titel'">
						<xsl:apply-templates select="$firstBlockTitlePage/optional.title/node()"/>
					</xsl:when>
					<xsl:when test="@name = 'SYSTEM-Titelseite-Datum'">
						<xsl:apply-templates select="$firstBlockTitlePage/date/node()"/>
					</xsl:when>
				</xsl:choose>
			</xsl:when>
			<xsl:when test="not(@hasValue) and ancestor::section[1]/Properties/Property[@name = concat('SMCDOCINFO:', $name)]">
					<xsl:for-each select="ancestor::section[1]/Properties/Property[@name = concat('SMCDOCINFO:', $name)]">
						<xsl:choose>
							<xsl:when test="@type = 'Date'">
								<METADATA name="{$name}" type="Date">
									<xsl:value-of select="@value"/>
								</METADATA>
							</xsl:when>
							<xsl:otherwise>
								<xsl:value-of select="@value"/>
							</xsl:otherwise>
						</xsl:choose>
					</xsl:for-each>				
			</xsl:when>				
			<xsl:when test="not(@hasValue) and /*/Properties/Property[@name = concat('SMCDOCINFO:', $name)]">
				<xsl:for-each select="(/*/Properties/Property[@name = concat('SMCDOCINFO:', $name)])[1]">
					<xsl:choose>
						<xsl:when test="@type = 'Date'">
							<METADATA name="{$name}" type="Date">
								<xsl:value-of select="@value"/>
							</METADATA>
						</xsl:when>
						<xsl:otherwise>
							<xsl:value-of select="@value"/>
						</xsl:otherwise>
					</xsl:choose>
				</xsl:for-each>
			</xsl:when>
			<xsl:when test="not(@hasValue) and /*/StructureProperties/StructureProperty[@name = concat('SMCDOCINFO:', $name)]">
				<xsl:for-each select="(/*/StructureProperties/StructureProperty[@name = concat('SMCDOCINFO:',$name)])[1]">
					<xsl:choose>
						<xsl:when test="@type = 'Date'">
							<METADATA name="{$name}" type="Date">
								<xsl:value-of select="@value"/>
							</METADATA>
						</xsl:when>
						<xsl:otherwise>
							<xsl:value-of select="@value"/>
						</xsl:otherwise>
					</xsl:choose>
				</xsl:for-each>
			</xsl:when>
			<xsl:when test="not(@hasValue) and ancestor::section[1]/StructureProperties/StructureProperty[@name = concat('SMCDOCINFO:', $name)]">
					<xsl:for-each select="ancestor::section[1]/StructureProperties/StructureProperty[@name = concat('SMCDOCINFO:', $name)]">
						<xsl:choose>
							<xsl:when test="@type = 'Date'">
								<METADATA name="{$name}" type="Date">
									<xsl:value-of select="@value"/>
								</METADATA>
							</xsl:when>
							<xsl:otherwise>
								<xsl:value-of select="@value"/>
							</xsl:otherwise>
						</xsl:choose>
					</xsl:for-each>				
			</xsl:when>			
			<xsl:when test="not(@hasValue) and /*/Navigation/StructureProperties/StructureProperty[@name = concat('SMCDOCINFO:', $name)]">
				<xsl:for-each select="(/*/Navigation/StructureProperties/StructureProperty[@name = concat('SMCDOCINFO:',$name)])[1]">
					<xsl:choose>
						<xsl:when test="@type = 'Date'">
							<METADATA name="{$name}" type="Date">
								<xsl:value-of select="@value"/>
							</METADATA>
						</xsl:when>
						<xsl:otherwise>
							<xsl:value-of select="@value"/>
						</xsl:otherwise>
					</xsl:choose>
				</xsl:for-each>
			</xsl:when>
			<xsl:otherwise>
				<xsl:copy>
					<xsl:copy-of select="@*"/>
					<xsl:apply-templates/>
				</xsl:copy>
			</xsl:otherwise>
		</xsl:choose>
	</xsl:template>
</xsl:stylesheet>