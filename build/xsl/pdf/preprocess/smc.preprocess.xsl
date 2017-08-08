<?xml version="1.0" encoding="utf-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" version="1.0"
				xmlns:smc="http://www.expert-communication.de/smc">

	<xsl:param name="PickerElement"/>

	<xsl:param name="BlockFilter"/>

	<xsl:param name="CLIENT"/>
	<xsl:param name="Offline"/>
	<xsl:variable name="isOffline" select="$Offline = 'Offline'"/>
	<xsl:param name="Online"/>

	<xsl:param name="Blockwise"/>
	<xsl:param name="LexDoc"/>
	<xsl:param name="showAbstract"/>
	<xsl:param name="showBlockRemark"/>
	<xsl:param name="language"/>
	<xsl:param name="versionLabel"/>
	<xsl:param name="objType"/>
	<xsl:param name="tp_compareVersionID"/>
	<xsl:param name="tp_nodeID"/>
	<xsl:param name="appendMediaPathPrefix">true</xsl:param>

	<xsl:param name="generate_translation_helper"/>

	<xsl:param name="ShowAllBlocks"/>

	<xsl:param name="HTMLHelp"/>
	<xsl:param name="OnlineHelp"/>
	<xsl:param name="JavaHelp"/>
	<xsl:param name="WebHelp"/>
	<xsl:param name="FOP"/>
	<xsl:param name="brokerServerURL"/>
	<xsl:param name="tp_brokerServerURL"/>
	<xsl:param name="Typo3Sync"/>

	<xsl:param name="TRANSLATE_LEGEND"/>
	<xsl:param name="ID_OVERWRITE"/>

	<xsl:param name="DISABLE_STEP_ATTRIBUTES_WRITING">false</xsl:param>
	<xsl:param name="GENERATE_FLAT_PATH">false</xsl:param>
	<xsl:param name="GENERATE_FLAT_PATH2">false</xsl:param>
	<xsl:param name="GENERATE_LANGUAGE_DEPENDENT_PATH">false</xsl:param>
	<xsl:param name="GENERATE_NO_CONTENT_FOLDERS">false</xsl:param>
	<xsl:param name="CONTENT_FOLDERS_PREFIX"/>
	<xsl:param name="CONTENT_FOLDERS_ROOPATH_PREFIX"/>
	<xsl:param name="INHERIT_SECTION_TYPES">true</xsl:param>
	<xsl:param name="MEDIA_PATH_PREFIX">/media</xsl:param>
	<xsl:param name="trafo"/>

	<xsl:param name="LINKFILE_PDF_PreviewWidth"/>

	<xsl:include href="smc.preprocess.common.xsl"/>
	<xsl:include href="preprocess.table.xsl"/>
	<xsl:include href="preprocess.general.xsl"/>
	<xsl:include href="preprocess.generate-contents.xsl"/>
	<xsl:include href="smc.metadata.xsl"/>

	<xsl:include href="../common/smc.encoder.xsl"/>

	<xsl:variable name="LANGUAGE_CODE">
		<xsl:choose>
			<xsl:when test="string-length($language) &gt; 0">
				<xsl:value-of select="$language"/>
			</xsl:when>
			<xsl:otherwise>de</xsl:otherwise>
		</xsl:choose>
	</xsl:variable>

	<xsl:variable name="firstBlockTitlePage" select="(//block.titlepage)[1]"/>

	<xsl:template match="Receiver" mode="Mail">
		<smc:Receiver name="{@name}">
			<xsl:if test="string-length(@name) = 0 or @name = '-'">
				<xsl:attribute name="name">
					<xsl:value-of select="@customName"/>
				</xsl:attribute>
			</xsl:if>
			<xsl:copy-of select="@displayName"/>
		</smc:Receiver>
	</xsl:template>


	<xsl:template match="/">

		<xsl:choose>
			<!-- For mail send please nest -->
			<xsl:when test="/MailEnvelope">
				<smc:MailEnvelope>
					<smc:From>
						<xsl:copy-of select="/MailEnvelope/From/@*"/>
					</smc:From>
					<smc:To>
						<xsl:for-each select="/MailEnvelope/To/Receiver">
							<xsl:apply-templates select="current()" mode="Mail"/>
						</xsl:for-each>
					</smc:To>
					<smc:CC>
						<xsl:for-each select="/MailEnvelope/CC/Receiver">
							<xsl:apply-templates select="current()" mode="Mail"/>
						</xsl:for-each>
					</smc:CC>
					<smc:BCC>
						<xsl:for-each select="/MailEnvelope/BCC/Receiver">
							<xsl:apply-templates select="current()" mode="Mail"/>
						</xsl:for-each>
					</smc:BCC>
					<smc:Subject content = "{/MailEnvelope/Subject/@content}"/>
					<xsl:if test="/MailEnvelope/Attachments/Attachment">
						<smc:Attachments>
							<xsl:for-each select="/MailEnvelope/Attachments/Attachment">
								<smc:Attachment>
									<xsl:copy-of select="@*"/>
									<xsl:copy-of select="*"/>
								</smc:Attachment>
							</xsl:for-each>
						</smc:Attachments>
					</xsl:if>
					<smc:Content>
						<xsl:apply-templates select="/MailEnvelope/Content/MMFramework.Container/section"/>
						<xsl:if test="not(/MailEnvelope/Content/MMFramework.Container) and not(/MailEnvelope/Content/Note) and /MailEnvelope/Body/ControlBody">
							<InfoMap>
								<xsl:apply-templates select="/MailEnvelope/Body"/>
							</InfoMap>
						</xsl:if>
						<xsl:apply-templates select="/MailEnvelope/Content/Note" mode="note-mail"/>
					</smc:Content>
				</smc:MailEnvelope>
			</xsl:when>

			<xsl:when test="Format/PageGeometry and not(MMFramework.Container)">
				<xsl:apply-templates select="Format" mode="geo"/>
			</xsl:when>

			<xsl:when test="GotFolderInfo">
				<xsl:apply-templates select="GotFolderInfo/MMFramework.Container[1]/section[1]"/>
			</xsl:when>
			<xsl:when test="/Start">
				<xsl:apply-templates select="/Start"/>
			</xsl:when>
			<xsl:when test="/MMFramework.Container/section">
				<xsl:apply-templates select="/MMFramework.Container/section"/>
			</xsl:when>
			<xsl:otherwise>
				<xsl:apply-templates/>
			</xsl:otherwise>
		</xsl:choose>
	</xsl:template>

	<xsl:template match="include">
		<xsl:apply-templates/>
	</xsl:template>
	
	<xsl:template match="include/title | include/TableDesc"/>


	<xsl:template match="include.block/block">
		<xsl:apply-templates/>
	</xsl:template>

	<xsl:template match="include.table">
		<xsl:choose>
			<xsl:when test="content/Table">
				<xsl:apply-templates select="content/Table"/>
			</xsl:when>
			<xsl:when test="Table">
				<xsl:apply-templates select="Table"/>
			</xsl:when>
			<xsl:otherwise>
				<xsl:copy-of select="current()"/>
			</xsl:otherwise>
		</xsl:choose>
	</xsl:template>

	<xsl:template match="include.text">
		<xsl:copy>
			<xsl:copy-of select="@*"/>
			<xsl:copy-of select="RefControl/@defaultLanguage[string-length(.) &gt; 0]"/>
			<xsl:apply-templates/>
		</xsl:copy>
	</xsl:template>

	<xsl:template match="Body">
		<xsl:copy>
			<xsl:apply-templates/>
		</xsl:copy>
	</xsl:template>



	<xsl:template name="writeFormResponses">



		<xsl:for-each select="//block.form">

			<xsl:variable name="path">
				<xsl:for-each select="ancestor-or-self::*[name() = 'section' or name() = 'Start']">
					<xsl:value-of select="concat(@ID, '/')"/>
				</xsl:for-each>
			</xsl:variable>

			<xsl:variable name="rootPath">
				<xsl:for-each select="ancestor-or-self::*[name() = 'section' or name() = 'Start']">../</xsl:for-each>
			</xsl:variable>

			<xsl:variable name="ID">
				<xsl:value-of select="parent::section/@ID"/>
			</xsl:variable>

			<xsl:for-each select="content/form.sendError | content/form.sendOK">
				<xsl:variable name="suffix">
					<xsl:choose>
						<xsl:when test="name()='form.sendError'">ERROR</xsl:when>
						<xsl:otherwise>CORRECT</xsl:otherwise>
					</xsl:choose>
				</xsl:variable>
				<InfoMap Level = "1" MasterID = "{$ID}_{$suffix}" ID = "{$ID}_{$suffix}" NavigationsBez="" ParentTitle="" Title="" Typ="" level="1" objType="doc" path="{$path}" rootPath="{$rootPath}" webdavID="{$ID}_{$suffix}" HideInNavigation="true">
					<Headline.content></Headline.content>
					<Block>
						<InfoPar>
							<xsl:apply-templates/>
						</InfoPar>
					</Block>
				</InfoMap>
			</xsl:for-each>
		</xsl:for-each>
	</xsl:template>

	<xsl:variable name="HeadlineThemeDefaultContent">
		<xsl:call-template name="getFormatVariableValue">
			<xsl:with-param name="name">HEADLINE_THEME_DEFAULT_CONTENT</xsl:with-param>
		</xsl:call-template>
	</xsl:variable>

	<xsl:template match="section | subsection | Start">


		<xsl:variable name="replace">"„</xsl:variable>
		<xsl:variable name="replaceWith"></xsl:variable>

		<xsl:if test="$LexDoc='true' or not(@Lexdoc= 'true')">

			<xsl:variable name="propertiesElem" select="Properties[$isOffline] | ancestor-or-self::MMFramework.Container[not($isOffline)][1]/Properties"/>

			<InfoMap>
				<xsl:attribute name="webdavID">
					<xsl:value-of select="$propertiesElem/Property[@name = 'SMC:id']/@value"/>
				</xsl:attribute>
				<xsl:if test="name() = 'subsection'">
					<xsl:attribute name="isSubSection"/>
				</xsl:if>
				<xsl:if test="parent::include.document">
					<xsl:attribute name="isSubSection"/>
					<xsl:copy-of select="parent::*/@*[name() = 'cols' or name() = 'clear' or name() = 'startcol' or name() = 'align']"/>
				</xsl:if>

				<xsl:choose>
					<xsl:when test="$isOffline and WebInfo/@HideInNavigation='true'">
						<xsl:attribute name="HideInNavigation">true</xsl:attribute>
					</xsl:when>
					<xsl:when test="not($isOffline) and ../WebInfo/@HideInNavigation='true'">
						<xsl:attribute name="HideInNavigation">true</xsl:attribute>
					</xsl:when>
					<xsl:when test="not($isOffline) and WebInfo/@HideInNavigation='true'">
						<xsl:attribute name="HideInNavigation">true</xsl:attribute>
					</xsl:when>
				</xsl:choose>

				<xsl:if test="name() = 'subsection'">
					<xsl:choose>
						<xsl:when test="$isOffline">
							<xsl:copy-of select="ancestor::section[1]/WebInfo/@HideInNavigation"/>
						</xsl:when>
						<xsl:otherwise>
							<xsl:copy-of select="ancestor::section[1]/../WebInfo/@HideInNavigation"/>
						</xsl:otherwise>
					</xsl:choose>
				</xsl:if>
				<xsl:if test="blocks/block.titlepage or block.titlepage">
					<xsl:attribute name="titlepage"></xsl:attribute>
				</xsl:if>

				<xsl:copy-of select="@translate | @objType
							 | @containerObjType | @bookURL | @defaultLanguage | @attachments | @status-diff
							 | @isPlaceHolder | @hasPartialContent
							 | @fileSectionExtension | @versionLabel | @guid | @cols | @clear | @startcol | @align | @AttributesChanged
							 | @inheritedCharTitles | @bookVersionLabel"/>
				<xsl:apply-templates select="current()" mode="copyCharacterizationAttributes"/>
				<xsl:if test="@Changed">
					<xsl:if test="@Changed != 'UPDATED'">
						<xsl:copy-of select="@Changed"/>
					</xsl:if>
					<xsl:attribute name="ChangedState">
						<xsl:value-of select="@Changed"/>
					</xsl:attribute>
				</xsl:if>

				<xsl:if test="/*/Navigation">
					<xsl:variable name="filter" select="@filter"/>
					<xsl:for-each select="/*/Navigation//InfoMap[@ID = current()/@ID or (string-length(current()/@ID) = 0 and @MasterID = $tp_nodeID)]">
						<xsl:variable name="inheritedFilter">
							<xsl:for-each select="ancestor::InfoMap[string-length(@filter) &gt; 0 and ancestor::Navigation]">
								<xsl:value-of select="@filter"/>
								<xsl:if test="position() != last()">,</xsl:if>
							</xsl:for-each>
						</xsl:variable>
						<xsl:if test="string-length($inheritedFilter) &gt; 0">
							<xsl:attribute name="inheritedFilter">
								<xsl:value-of select="$inheritedFilter"/>
							</xsl:attribute>
						</xsl:if>
						<xsl:if test="string-length(@filter) &gt; 0">
							<xsl:attribute name="filter">
								<xsl:if test="string-length($filter) &gt; 0">
									<xsl:value-of select="$filter"/>
									<xsl:text>,</xsl:text>
								</xsl:if>
								<xsl:value-of select="@filter"/>
							</xsl:attribute>
						</xsl:if>
					</xsl:for-each>
				</xsl:if>

				<xsl:attribute name="Title">
					<xsl:choose>
						<xsl:when test="string-length(headline.content) &gt; 0">
							<xsl:apply-templates select="headline.content" mode="printText"/>
						</xsl:when>
						<xsl:when test="string-length(@Title) &gt; 0">
							<xsl:value-of select="translate(@Title,$replace,$replaceWith)"/>
						</xsl:when>
						<xsl:otherwise>
							<xsl:value-of select="translate(headline.content/text() | headline.content/*[not(name() = 'index.entry' and @notVisible = 'true')],$replace,$replaceWith)"/>
						</xsl:otherwise>
					</xsl:choose>
				</xsl:attribute>

				<xsl:attribute name="Lang">
					<xsl:choose>
						<xsl:when test="string-length(@defaultLanguage) &gt; 0">
							<xsl:value-of select="@defaultLanguage"/>
						</xsl:when>
						<xsl:otherwise>
							<xsl:value-of select="$LANGUAGE_CODE"/>
						</xsl:otherwise>
					</xsl:choose>
				</xsl:attribute>

				<xsl:attribute name="ParentTitle">
					<xsl:value-of select="translate(parent::*/headline.content, $replace, $replaceWith)"/>
				</xsl:attribute>

				<xsl:attribute name="NavigationsBez">
					<xsl:choose>
						<xsl:when test="WebInfo">
							<xsl:value-of select="normalize-space(WebInfo/@SystemName)"/>
						</xsl:when>
						<xsl:when test="not($isOffline)">
							<xsl:value-of select="normalize-space(../WebInfo/@SystemName)"/>
						</xsl:when>
					</xsl:choose>
				</xsl:attribute>

				<xsl:if test="@Lexdoc= 'true' and $LexDoc = 'true'">
					<xsl:attribute name="LexDoc">true</xsl:attribute>
				</xsl:if>

				<xsl:attribute name="Typ">
					<xsl:choose>
						<xsl:when test="$Blockwise = 'true' and @type='MultimediaSonder'">Multimedia</xsl:when>
						<xsl:otherwise>
							<xsl:value-of select="@type"/>
						</xsl:otherwise>
					</xsl:choose>
				</xsl:attribute>

				<xsl:attribute name="ID">
					<xsl:choose>
						<xsl:when test="string-length(@ID) = 0">
							<xsl:value-of select="$propertiesElem/Property[@name = 'SMC:id']/@value"/>
						</xsl:when>
						<xsl:otherwise>
							<xsl:value-of select="@ID"/>
						</xsl:otherwise>
					</xsl:choose>
				</xsl:attribute>

				<xsl:attribute name="MasterID">
					<xsl:value-of select="@ID"/>
				</xsl:attribute>

				<xsl:if test="$ID_OVERWRITE = 'true' and string-length(normalize-space(WebInfo/@SystemName)) &gt; 0">
					<xsl:attribute name="SystemName">
						<xsl:value-of select="WebInfo/@SystemName"/>
					</xsl:attribute>
				</xsl:if>

				<xsl:attribute name="path">
					<xsl:value-of select="$CONTENT_FOLDERS_PREFIX"/>
					<xsl:if test="not($GENERATE_NO_CONTENT_FOLDERS = 'true')">
						<xsl:if test="$GENERATE_LANGUAGE_DEPENDENT_PATH = 'true' and ancestor-or-self::section[@defaultLanguage]">
							<xsl:value-of select="concat(ancestor-or-self::section[@defaultLanguage][1]/@defaultLanguage, '/')"/>
						</xsl:if>
						<xsl:for-each select="ancestor-or-self::*[name() = 'section' or name() = 'Start']">
							<xsl:choose>
								<xsl:when test="$ID_OVERWRITE='true' and string-length(normalize-space(WebInfo/@SystemName)) &gt; 0">
									<xsl:value-of select="concat(WebInfo/@SystemName, '/')"/>
								</xsl:when>
								<xsl:when test="$GENERATE_FLAT_PATH = 'true'">
									<xsl:if test="section and @ID != 'index'">
										<xsl:value-of select="concat(@ID, '/')"/>
									</xsl:if>
								</xsl:when>
								<xsl:when test="$OnlineHelp = 'OnlineHelp' or $GENERATE_FLAT_PATH2 = 'true'">
									<!-- add own ID only to path if there are child sections -->
									<xsl:if test="section">
										<xsl:value-of select="concat(@ID, '/')"/>
									</xsl:if>
								</xsl:when>
								<xsl:otherwise>
									<xsl:value-of select="concat(@ID, '/')"/>
								</xsl:otherwise>
							</xsl:choose>
						</xsl:for-each>
					</xsl:if>
				</xsl:attribute>

				<xsl:attribute name="rootPath">
					<xsl:value-of select="$CONTENT_FOLDERS_ROOPATH_PREFIX"/>
					<xsl:if test="not($GENERATE_NO_CONTENT_FOLDERS = 'true')">
						<xsl:if test="$GENERATE_LANGUAGE_DEPENDENT_PATH = 'true' and ancestor-or-self::section[@defaultLanguage]">../</xsl:if>
						<xsl:for-each select="ancestor-or-self::*[name() = 'section' or name() = 'Start']">
							<xsl:choose>
								<xsl:when test="$GENERATE_FLAT_PATH = 'true'">
									<xsl:if test="section"></xsl:if>
									<xsl:if test="section and @ID != 'index'">../</xsl:if>
								</xsl:when>
								<xsl:when test="$OnlineHelp = 'OnlineHelp' or $GENERATE_FLAT_PATH2 = 'true'">
									<xsl:if test="section">../</xsl:if>
								</xsl:when>
								<xsl:otherwise>../</xsl:otherwise>
							</xsl:choose>
						</xsl:for-each>
					</xsl:if>
				</xsl:attribute>


				<xsl:variable name="level">
					<xsl:choose>
						<xsl:when test="/*/Navigation">
							<xsl:choose>
								<xsl:when test="string-length($tp_nodeID) &gt; 0">
									<xsl:value-of select="/*/Navigation//InfoMap[@MasterID = $tp_nodeID]/@Level + count(ancestor::*[name() = 'section' or name() = 'Start' or name() = 'subsection'])"/>
								</xsl:when>
								<xsl:otherwise>
									<xsl:variable name="id" select="@ID"/>
									<xsl:value-of select="/*/Navigation//InfoMap[@ID = $id]/@Level + count(ancestor::*[name() = 'section' or name() = 'Start' or name() = 'subsection'])"/>
								</xsl:otherwise>
							</xsl:choose>
						</xsl:when>
						<xsl:otherwise>
							<xsl:value-of select="count(ancestor::*[name() = 'section' or name() = 'Start' or name() = 'subsection'])"/>
						</xsl:otherwise>
					</xsl:choose>
				</xsl:variable>

				<xsl:attribute name="level">
					<xsl:value-of select="$level"/>
				</xsl:attribute>

				<xsl:attribute name="Level">
					<xsl:choose>
						<xsl:when test="string-length(@Level) &gt; 0">
							<xsl:value-of select="@Level"/>
						</xsl:when>
						<xsl:otherwise>
							<xsl:value-of select="$level"/>
						</xsl:otherwise>
					</xsl:choose>
				</xsl:attribute>

				<xsl:if test="name() = 'Start' and $generate_translation_helper = 'true'">
					<xsl:choose>
						<xsl:when test="headline.content or *[starts-with(name(), 'block')]">
							<xsl:call-template name="writeTranslationHelperToc"/>
						</xsl:when>
						<xsl:otherwise>
							<InfoMap level="1" HideInNavigation="true">
								<xsl:call-template name="writeTranslationHelperToc"/>
							</InfoMap>
						</xsl:otherwise>
					</xsl:choose>
				</xsl:if>

				<xsl:if test="not($isOffline) and name() != 'subsection' and not(/Start/Navigation)">
					<xsl:apply-templates select="//*/Navigation">
						<xsl:with-param name="mergeSubSections" select="boolean(blocks/subsection)"/>
					</xsl:apply-templates>
				</xsl:if>

				<xsl:if test="parent::MMFramework.Container/parent::Content/parent::MailEnvelope">
					<xsl:apply-templates select="//Body"/>
				</xsl:if>

				<xsl:if test="not($isOffline)">
					<xsl:apply-templates select="following-sibling::Properties[1] | following-sibling::Originals[1] | preceding-sibling::WebInfo[1] | following-sibling::SearchResult"/>
				</xsl:if>

				<!--<xsl:if test="not(headline.theme) and count(exslt:node-set($HeadlineThemeDefaultContent)) &gt; 0">
					<Headline.theme>
						<xsl:attribute name = "Level">
							<xsl:value-of select = "count(ancestor::*) + 1"/>
						</xsl:attribute>
						<xsl:apply-templates select="exslt:node-set($HeadlineThemeDefaultContent)"/>
					</Headline.theme>
				</xsl:if>-->

				<xsl:apply-templates/>
				
				<xsl:choose>
					<xsl:when test="/Start and name() = 'Start' and not(section or subsection) and Format/PageGeometry">
						<xsl:apply-templates select="Format" mode="geo"/>
						<xsl:apply-templates select="Strings" mode="copyme"/>
					</xsl:when>
					<xsl:when test="/Start and name() = 'Start'">
						<xsl:apply-templates select="Format[1]" mode="format"/>
						<xsl:apply-templates select="Strings | User" mode="copyme"/>
					</xsl:when>
					<xsl:when test="not(/Start)">
						<xsl:apply-templates select="following-sibling::Format[1]" mode="format"/>
						<xsl:apply-templates select="following-sibling::Strings | following-sibling::User" mode="copyme"/>
					</xsl:when>
					<xsl:when test="/Start and name() = 'section' and string-length(@styleID) &gt; 0 and not(@styleID = ancestor::section[@styleID][1]/@styleID)">
						<xsl:apply-templates select="/*/Format[@styleID = current()/@styleID][1]" mode="format"/>
					</xsl:when>
				</xsl:choose>

				<xsl:if test="name() = 'Start'">
					<xsl:call-template name="writeFormResponses"/>
					<xsl:if test="$OnlineHelp = 'OnlineHelp' or $JavaHelp = 'JavaHelp'">
						<!-- force index generation -->
						<HelpIndex>
							<generate.index/>
						</HelpIndex>
					</xsl:if>
				</xsl:if>

			</InfoMap>
		</xsl:if>
	</xsl:template>

	<xsl:template name="writeTranslationHelperToc">
		<xsl:variable name="hasHC" select="boolean(headline.content)"/>
		<xsl:if test="not($hasHC)">
			<xsl:attribute name="Title">Translation Helper TOC</xsl:attribute>
			<Headline.content translate="false">Translation Helper</Headline.content>
		</xsl:if>
		<Block translate="false">
			<xsl:if test="$hasHC">
				<Label>Translation Helper</Label>
			</xsl:if>
			<InfoItem.Overviewall type="translationHelper">
				<xsl:for-each select="//*[@Changed or @AttributesChanged]/ancestor-or-self::section[1] | //*[(name() = 'section' or name() = 'Start') and @translate = 'true']">
					<InfoItem.Overview abs_level="1">
						<Link.ShortDesc IDRef="{@ID}">
							<InfoChunk.Link>
								<xsl:for-each select="headline.content/text() | headline.content/*">
									<xsl:if test="not(name() = 'index.entry' and @notVisible = 'true')">
										<xsl:value-of select="."/>
									</xsl:if>
								</xsl:for-each>
							</InfoChunk.Link>
						</Link.ShortDesc>
					</InfoItem.Overview>
				</xsl:for-each>
			</InfoItem.Overviewall>
		</Block>
	</xsl:template>

	<xsl:template match="Format" mode="geo">
		<xsl:copy>
			<xsl:copy-of select="@*"/>
			<xsl:apply-templates/>
		</xsl:copy>
	</xsl:template>

	<xsl:template match="Format | Strings[not(parent::material)]"/>

	<!-- Navigation -->
	<xsl:template match="Navigation">
		<xsl:param name="mergeSubSections" select="false()"/>
		<Navigation>
			<xsl:copy-of select="@*"/>
			<xsl:apply-templates select="InfoMap | Block" mode="Navigation">
				<xsl:with-param name="mergeSubSections" select="$mergeSubSections"/>
			</xsl:apply-templates>
			<xsl:apply-templates select="Folder | Theme | Properties"/>
		</Navigation>
	</xsl:template>

	<xsl:template match="InfoMap"  mode="Navigation">
		<xsl:param name="mergeSubSections"/>
		<InfoMap level="{@Level - 1}" Level="{@Level - 1}">
			<xsl:copy-of select="@* | ancestor-or-self::Navigation[1]/@bookID"/>
			<xsl:if test="$mergeSubSections and ancestor::Navigation[1]/@currentNodeID = @MasterID">
				<xsl:apply-templates select="/*/section/blocks/subsection" mode="Navigation">
					<xsl:with-param name="level" select="@Level"/>
				</xsl:apply-templates>
			</xsl:if>
			<xsl:apply-templates mode="Navigation">
				<xsl:with-param name="mergeSubSections" select="$mergeSubSections"/>
			</xsl:apply-templates>
		</InfoMap>
	</xsl:template>

	<xsl:template match="subsection" mode="Navigation">
		<xsl:param name="level"/>
		<InfoMap MasterID="{@ID}" Level="{$level}" level="{$level}">
			<xsl:copy-of select="@ID | @Title"/>
			<xsl:apply-templates select="blocks/subsection" mode="Navigation">
				<xsl:with-param name="level" select="$level + 1"/>
			</xsl:apply-templates>
		</InfoMap>
	</xsl:template>

	<xsl:template match="Block"  mode="Navigation">
		<Block/>
	</xsl:template>

	<xsl:template match="Folder">
		<xsl:choose>
			<xsl:when test="parent::Folder">
				<xsl:copy>
					<xsl:copy-of select="@*"/>
					<xsl:attribute name="Level">
						<xsl:value-of select="count(ancestor::Folder)"/>
					</xsl:attribute>
					<xsl:attribute name="webdavID">
						<xsl:value-of select="Properties/Property[@name = 'SMC:id']/@value"/>
					</xsl:attribute>
					<xsl:attribute name="navWeight">
						<xsl:choose>
							<xsl:when test="Properties/Property[@name = 'SMCDOCINFO:navposition']/@value">
								<xsl:value-of select="Properties/Property[@name = 'SMCDOCINFO:navposition']/@value"/>
							</xsl:when>
							<xsl:otherwise>
								<xsl:value-of select="0"/>
							</xsl:otherwise>
						</xsl:choose>
					</xsl:attribute>
					<xsl:apply-templates/>
				</xsl:copy>
			</xsl:when>
			<xsl:otherwise>
				<xsl:apply-templates/>
			</xsl:otherwise>
		</xsl:choose>
	</xsl:template>

	<xsl:template match="Theme">
		<xsl:copy>
			<xsl:copy-of select="@*"/>
			<xsl:attribute name="Level">
				<xsl:value-of select="count(ancestor::Folder)"/>
			</xsl:attribute>
			<xsl:attribute name="webdavID">
				<xsl:value-of select="Properties/Property[@name = 'SMC:id']/@value"/>
			</xsl:attribute>
			<xsl:if test="../@server-uri">
				<xsl:attribute name="serverURL">
					<xsl:value-of select="../@server-uri"/>
				</xsl:attribute>
			</xsl:if>
			<xsl:if test="Original">
				<xsl:attribute name="originalURL">
					<xsl:value-of select="Original/Properties/Property[@name = 'uri']/@value"/>
				</xsl:attribute>
			</xsl:if>
			<xsl:attribute name="navWeight">
				<xsl:choose>
					<xsl:when test="Properties/Property[@name = 'SMCDOCINFO:navposition']/@value">
						<xsl:value-of select="Properties/Property[@name = 'SMCDOCINFO:navposition']/@value"/>
					</xsl:when>
					<xsl:otherwise>
						<xsl:value-of select="0"/>
					</xsl:otherwise>
				</xsl:choose>
			</xsl:attribute>
			<xsl:apply-templates select="Properties"/>
		</xsl:copy>
	</xsl:template>

	<!--	
********************************************************************************************** 
**
** Media Elements 
**
**********************************************************************************************
-->

	<xsl:template match="Asset/url" mode="format">
		<xsl:apply-templates select="current()"/>
	</xsl:template>

	<xsl:template match="Asset/url" mode="geo">
		<xsl:apply-templates select="current()"/>
	</xsl:template>

	<xsl:template match="media.theme | formula | Asset/url">
		<Media.theme>
			<xsl:copy-of select="@*"/>

			<xsl:variable name="fileType" select="string(RefControl/substitute[1]/@fileType)"/>
			<xsl:variable name="isEdgeFile" select="$fileType = 'zip'"/>
			<xsl:if test="$isEdgeFile">
				<xsl:copy-of select="RefControl/substitute[1]/@*[starts-with(name(), 'edge')]"/>
			</xsl:if>

			<xsl:apply-templates select="RefControl/substitute[1]" mode="setSubstituteAttributes"/>

			<xsl:if test="(name() = 'media.theme' and not(parent::media)) or (name() = 'formula' and not(parent::content or parent::entry))">
				<xsl:attribute name="isIcon">true</xsl:attribute>
				<xsl:attribute name="inline">true</xsl:attribute>
			</xsl:if>

			<xsl:if test="parent::media">
				<xsl:apply-templates select="current()" mode="copyDiffAttributesFromParent"/>
				<xsl:apply-templates select="parent::*" mode="copyCharacterizationAttributes"/>
			</xsl:if>

			

			<xsl:copy-of select="RefControl/substitute[1]/@width | 
						 RefControl/substitute[1]/@height | 
						 RefControl/substitute[1]/@origWidth | 
						 RefControl/substitute[1]/@origHeight |
						 RefControl/substitute[1]/@align | 
						 RefControl/substitute[1]/@rotation | 
						 RefControl/substitute[1]/@contentLength | 
						 RefControl/substitute[1]/@resolution | 
						 RefControl/substitute[1]/@themeURL | 
						 RefControl/substitute[1]/@serverURL | 
						 RefControl/substitute[1]/@converter |
						 RefControl/substitute[1]/@content-size-modification | 
						 RefControl/substitute[1]/@fixedWidth | 
						 RefControl/substitute[1]/@fixedHeight | 
						 RefControl/substitute[1]/@fileType | 
						 RefControl/substitute[1]/@size-unit"/>
			
			<xsl:copy-of select="mediacontent/Animation/@Buehne"/>

			<xsl:if test="parent::media">
				<xsl:apply-templates select="../link.xref | ../link.mailTo | ../link.file | ../link.url | ../link.detail"/>

				<xsl:if test="not(preceding-sibling::media.theme)">
					<xsl:choose>
						<xsl:when test="string-length(../media.caption) &gt; 0">
							<xsl:apply-templates select="../media.caption"/>
						</xsl:when>
						<xsl:when test="string-length(legendcontent/*/SubTitle) &gt; 0">
							<InfoPar.Subtitle>
								<xsl:apply-templates select="legendcontent/*/SubTitle/node()"/>
							</InfoPar.Subtitle>
						</xsl:when>
						<xsl:when test="string-length(RefControl/@defaultTitle) &gt; 0">
							<InfoPar.Subtitle>
								<xsl:value-of select="RefControl/@defaultTitle"/>
							</InfoPar.Subtitle>
						</xsl:when>
					</xsl:choose>
				</xsl:if>
			</xsl:if>

			<xsl:if test="legendcontent/*/TextFields and (not(parent::media/@notShowLegend='true') or $PickerElement='link.element.controller')">
				<legend>
					<xsl:copy-of select="legendcontent/@*"/>
					<xsl:for-each select="legendcontent/*/TextFields/TextField">
						<legend.row>
							<xsl:apply-templates select="current()" mode="copyDiffAttributes"/>
							<xsl:apply-templates select="current()" mode="copyCharacterizationAttributes"/>
							
							<legend.term>
								<!-- Compatibility with old structure -->
								<xsl:choose>
									<xsl:when test="TextFieldID">
										<xsl:apply-templates select="TextFieldID"/>
									</xsl:when>
									<xsl:otherwise>
								<xsl:value-of select="@ID"/>
									</xsl:otherwise>	
								</xsl:choose>
							</legend.term>
							<legend.def>
								<!-- Compatibility with old structure -->
								<xsl:choose>
									<xsl:when test="TextFieldContent">
										<xsl:for-each select = "TextFieldContent">
											<xsl:call-template name = "writeLegendDef"/>
											</xsl:for-each>
									</xsl:when>
									<xsl:otherwise>
										<xsl:call-template name = "writeLegendDef"/>
									</xsl:otherwise>
								</xsl:choose>
							</legend.def>
						</legend.row>
					</xsl:for-each>
				</legend>
				<xsl:if test="string-length(legendcontent/*/Description) &gt; 0">
					<media.description>
						<xsl:apply-templates select="legendcontent/*/Description/node()" mode="media-description"/>
					</media.description>
				</xsl:if>
				<xsl:if test="string-length(legendcontent/*/ImageCode) &gt; 0">
					<media.code>
						<xsl:apply-templates select="legendcontent/*/ImageCode/node()"/>
					</media.code>
				</xsl:if>
			</xsl:if>

			<xsl:if test="legendcontent/*/LegendMediaset">
				<LegendMediaset/>
			</xsl:if>

			<xsl:if test="hotspotcontent/*/area">
				<xsl:apply-templates select="hotspotcontent/map"/>
			</xsl:if>

			<xsl:apply-templates select="mediacontent"/>

			<xsl:apply-templates select="RefControl" mode="copySubst"/>

			<xsl:apply-templates select="notes"/>

		</Media.theme>
	</xsl:template>

	<xsl:template match="substitute" mode="setSubstituteAttributes">
		
		<xsl:variable name="offlinePrefix">
			<xsl:if test="$isOffline and $appendMediaPathPrefix = 'true'">
				<xsl:value-of select="$MEDIA_PATH_PREFIX"/>
			</xsl:if>
		</xsl:variable>

		<xsl:variable name="svgUrl" select="@svgURL"/>
		<xsl:variable name="escapedSvgUrl" select="@escapedSvgURL"/>

		<xsl:variable name="isSVG" select="boolean($svgUrl)"/>
		<xsl:variable name="subUrl" select="@subURL"/>
		<xsl:variable name="escapedSubUrl" select="@escapedSubURL"/>
		<xsl:variable name="previewSubUrl" select="@previewSubURL"/>
		
		<xsl:variable name="fileType" select="string(@fileType)"/>
		<xsl:variable name="isSWF" select="$fileType = 'swf'"/>
		<xsl:variable name="isFilm" select="$fileType = 'mp4' or $fileType = 'flv'"/>
		<xsl:variable name="isAudio" select="$fileType = 'mp3'"/>

		<xsl:attribute name="subURL">
			<xsl:value-of select="$offlinePrefix"/>
			<xsl:choose>
				<xsl:when test="$isSVG and not($isOffline)">
					<xsl:if test="string-length($svgUrl) &gt; 0 and not(starts-with($svgUrl, '/'))">/</xsl:if>
					<xsl:value-of select="$svgUrl"/>
				</xsl:when>
				<xsl:otherwise>
					<xsl:if test="string-length($subUrl) &gt; 0 and not(starts-with($subUrl, '/'))">/</xsl:if>
					<xsl:value-of select="$subUrl"/>
				</xsl:otherwise>
			</xsl:choose>
		</xsl:attribute>

		<xsl:if test="$previewSubUrl">
			<xsl:variable name="escapedPreviewSubUrl" select="@escapedPreviewSubURL"/>

			<xsl:attribute name="previewSubURL">
				<xsl:value-of select="$offlinePrefix"/>
				<xsl:if test="string-length($previewSubUrl) &gt; 0 and not(starts-with($previewSubUrl, '/'))">/</xsl:if>
				<xsl:value-of select="$previewSubUrl"/>
			</xsl:attribute>
			<xsl:attribute name="escapedPreviewSubURL">
				<xsl:call-template name="replace">
					<xsl:with-param name="string">
						<xsl:value-of select="$offlinePrefix"/>
						<xsl:if test="string-length($escapedPreviewSubUrl) &gt; 0 and not(starts-with($escapedPreviewSubUrl, '/'))">/</xsl:if>
						<xsl:value-of select="$escapedPreviewSubUrl"/>
					</xsl:with-param>
					<xsl:with-param name="pattern" select="'+'"/>
					<xsl:with-param name="replacement">%20</xsl:with-param>
				</xsl:call-template>
			</xsl:attribute>

			<xsl:copy-of select="@previewWidth | @previewHeight"/>
		</xsl:if>

		<xsl:attribute name="escapedSubURL">
			<xsl:call-template name="replace">
				<xsl:with-param name="string">
					<xsl:choose>
						<xsl:when test="$isSVG and not($isOffline)">
							<xsl:value-of select="$offlinePrefix"/>
							<xsl:if test="string-length($escapedSvgUrl) &gt; 0 and not(starts-with($escapedSvgUrl, '/'))">/</xsl:if>
							<xsl:value-of select="$escapedSvgUrl"/>
						</xsl:when>
						<xsl:otherwise>
							<xsl:choose>
								<xsl:when test="$HTMLHelp = 'HTMLHelp'">
									<xsl:value-of select="$offlinePrefix"/>
									<xsl:if test="string-length($subUrl) &gt; 0 and not(starts-with($subUrl, '/'))">/</xsl:if>
									<xsl:value-of select="$subUrl"/>
								</xsl:when>
								<xsl:otherwise>
									<xsl:value-of select="$offlinePrefix"/>
									<xsl:if test="string-length($escapedSubUrl) &gt; 0 and not(starts-with($escapedSubUrl, '/'))">/</xsl:if>
									<xsl:value-of select="$escapedSubUrl"/>
								</xsl:otherwise>
							</xsl:choose>
						</xsl:otherwise>
					</xsl:choose>
				</xsl:with-param>
				<xsl:with-param name="pattern" select="'+'"/>
				<xsl:with-param name="replacement">
					<xsl:choose>
						<xsl:when test="$HTMLHelp = 'HTMLHelp'">
							<xsl:text> </xsl:text>
						</xsl:when>
						<xsl:otherwise>
							<xsl:text>%20</xsl:text>
						</xsl:otherwise>
					</xsl:choose>
				</xsl:with-param>
			</xsl:call-template>
		</xsl:attribute>

		<xsl:if test="$isFilm">
			<xsl:attribute name="isFilm">true</xsl:attribute>
		</xsl:if>
		<xsl:if test="$isAudio">
			<xsl:attribute name="isAudio">true</xsl:attribute>
		</xsl:if>
		<xsl:if test="$isSVG">
			<xsl:attribute name="isSVG">true</xsl:attribute>
		</xsl:if>
		<xsl:if test="name(parent::RefControl/parent::*) = 'formula'">
			<xsl:attribute name="isFormula">true</xsl:attribute>
		</xsl:if>
		<xsl:if test="$isSWF or $isFilm">
			<xsl:variable name="aniContent">
				<xsl:choose>
					<xsl:when test="$Offline = 'Offline' and string-length(@targetPath) &gt; 0">
						<xsl:value-of select="@targetPath"/>
					</xsl:when>
					<xsl:otherwise>
						<xsl:value-of select="@aniContent"/>
					</xsl:otherwise>
				</xsl:choose>
			</xsl:variable>
			<xsl:variable name="escapedAniContent" select="@escapedAniContent"/>

			<xsl:variable name="swfUrl" select="@swfURL"/>
			<xsl:attribute name="isSWF">true</xsl:attribute>
			<xsl:if test="string-length($swfUrl) &gt; 0">
				<xsl:attribute name="swfContentLoaderURL">
					<xsl:value-of select="$offlinePrefix"/>
					<xsl:if test="string-length($swfUrl) &gt; 0 and not(starts-with($swfUrl, '/'))">/</xsl:if>
					<xsl:value-of select="$swfUrl"/>
				</xsl:attribute>
			</xsl:if>
			<xsl:if test="string-length($aniContent) &gt; 0">
				<xsl:attribute name="swfContentFileURL">
					<xsl:value-of select="$offlinePrefix"/>
					<xsl:if test="not(starts-with($aniContent, '/'))">/</xsl:if>
					<xsl:value-of select="$aniContent"/>
				</xsl:attribute>
				<xsl:attribute name="escapedSwfContentFileURL">
					<xsl:value-of select="$offlinePrefix"/>
					<xsl:if test="string-length($escapedAniContent) &gt; 0 and not(starts-with($escapedAniContent, '/'))">/</xsl:if>
					<xsl:value-of select="$escapedAniContent"/>
				</xsl:attribute>
			</xsl:if>
		</xsl:if>

		<xsl:if test="string-length(@edgePath) &gt; 0">
			<xsl:apply-templates select="current()" mode="setSubsitituteURLAttribute">
				<xsl:with-param name="offlinePrefix" select="$offlinePrefix"/>
				<xsl:with-param name="attrName">edgePath</xsl:with-param>
				<xsl:with-param name="escapedAttrName">edgePathEscaped</xsl:with-param>
			</xsl:apply-templates>
		</xsl:if>
	</xsl:template>

	<xsl:template match="substitute" mode="setSubsitituteURLAttribute">
		<xsl:param name="offlinePrefix"/>
		<xsl:param name="attrName"/>
		<xsl:param name="escapedAttrName"/>

		<xsl:variable name="subUrl" select="@*[name() = $attrName]"/>
		<xsl:variable name="escapedSubUrl" select="@*[name() = $escapedAttrName]"/>

		<xsl:attribute name="{$attrName}">
			<xsl:value-of select="$offlinePrefix"/>
			<xsl:if test="string-length($subUrl) &gt; 0 and not(starts-with($subUrl, '/'))">/</xsl:if>
			<xsl:value-of select="$subUrl"/>
		</xsl:attribute>

		<xsl:attribute name="{$escapedAttrName}">
			<xsl:call-template name="replace">
				<xsl:with-param name="string">
					<xsl:choose>
						<xsl:when test="$HTMLHelp = 'HTMLHelp'">
							<xsl:value-of select="$offlinePrefix"/>
							<xsl:if test="string-length($subUrl) &gt; 0 and not(starts-with($subUrl, '/'))">/</xsl:if>
							<xsl:value-of select="$subUrl"/>
						</xsl:when>
						<xsl:otherwise>
							<xsl:value-of select="$offlinePrefix"/>
							<xsl:if test="string-length($escapedSubUrl) &gt; 0 and not(starts-with($escapedSubUrl, '/'))">/</xsl:if>
							<xsl:value-of select="$escapedSubUrl"/>
						</xsl:otherwise>
					</xsl:choose>
				</xsl:with-param>
				<xsl:with-param name="pattern" select="'+'"/>
				<xsl:with-param name="replacement">
					<xsl:choose>
						<xsl:when test="$HTMLHelp = 'HTMLHelp'">
							<xsl:text> </xsl:text>
						</xsl:when>
						<xsl:otherwise>
							<xsl:text>%20</xsl:text>
						</xsl:otherwise>
					</xsl:choose>
				</xsl:with-param>
			</xsl:call-template>
		</xsl:attribute>
	</xsl:template>

	<xsl:template match="paragraph | label.element" mode="media-description">
		<InfoPar>
			<xsl:copy-of select="@Changed"/>
			<xsl:apply-templates/>
		</InfoPar>
	</xsl:template>

	<xsl:template match="list.element" mode="media-description">
		<Enum type="Media">
			<EnumElement>
				<xsl:apply-templates/>
			</EnumElement>
		</Enum>
	</xsl:template>


	<xsl:template match="TextFieldID">
		<xsl:apply-templates/>	
	</xsl:template>	

	<xsl:template name = "writeLegendDef">
		<xsl:choose>
			<xsl:when test="list.element">
				<Enum type="Media">
					<xsl:for-each select="list.element">
						<EnumElement>
							<xsl:apply-templates/>
						</EnumElement>
					</xsl:for-each>
				</Enum>
			</xsl:when>
			<xsl:when test="count(list.element | paragraph | label.element) &gt; 1">
				<xsl:apply-templates mode="media-description"/>
			</xsl:when>
			<xsl:otherwise>
				<InfoPar>
					<xsl:copy-of select="*/@Changed"/>
					<xsl:apply-templates/>
				</InfoPar>
			</xsl:otherwise>
		</xsl:choose>		
	</xsl:template>

	<xsl:template match="*" mode="copySubst">
		<xsl:copy>
			<xsl:copy-of select="@*"/>
			<xsl:apply-templates mode="copySubst"/>
		</xsl:copy>
	</xsl:template>

	<xsl:template match="substitute" mode="copySubst">
		<xsl:copy>
			<xsl:copy-of select="@*"/>
			<xsl:apply-templates select="current()" mode="setSubstituteAttributes"/>
			<xsl:apply-templates mode="copySubst"/>
		</xsl:copy>
	</xsl:template>

	<xsl:template match="math" mode="copySubst">
		<xsl:element name="m:{local-name()}" xmlns:m="http://www.w3.org/1998/Math/MathML">
			<xsl:copy-of select="@*"/>
			<xsl:apply-templates mode="copy-math"/>
		</xsl:element>
	</xsl:template>

	<xsl:template match="*" mode="copy-math">
		<xsl:element name="m:{local-name()}" xmlns:m="http://www.w3.org/1998/Math/MathML">
			<xsl:copy-of select="@*"/>
			<xsl:apply-templates mode="copy-math"/>
		</xsl:element>
	</xsl:template>


	<xsl:template match="media | Media">
		<Media>
			<xsl:copy-of select="@*"/>
			<xsl:apply-templates select="*[name() != 'media.caption' and name() != 'link.file'
								 and name() != 'link.xref' and name() != 'link.mailTo'
								 and name() != 'link.url' and name() != 'link.detail']"/>
		</Media>
	</xsl:template>

	<xsl:template match="media.caption">
		<InfoPar.Subtitle>
			<xsl:copy-of select="@*"/>
			<xsl:apply-templates/>
		</InfoPar.Subtitle>
	</xsl:template>


	<xsl:template match="*" mode="copyme">
		<xsl:copy>
			<xsl:copy-of select="@*"/>
			<xsl:choose>
				<xsl:when test="name() = 'legend.def' or name() = 'legend.term'">
					<xsl:apply-templates/>
				</xsl:when>
				<xsl:otherwise>
					<xsl:apply-templates mode="copyme"/>
				</xsl:otherwise>
			</xsl:choose>
		</xsl:copy>
	</xsl:template>

	<xsl:template match="*" mode="format">
		<xsl:copy>
			<xsl:copy-of select="@*"/>
			<xsl:apply-templates mode="format"/>
		</xsl:copy>
	</xsl:template>

	<!--	
********************************************************************************************** 
**
** Links 
**
**********************************************************************************************
-->

	<xsl:template match = "link.xpath">
		<Link.XPath>
			<xsl:copy-of select="@*"/>
		</Link.XPath>
	</xsl:template>

	<xsl:template match = "link.xref">
		<Link.XRef>
			<xsl:copy-of select="@*"/>
			<xsl:copy-of select="link.xref.controller/@*"/>
			<xsl:copy-of select="link.xref.controller/RefControl/@*"/>
			
			
			
			
			<xsl:if test="link.xref.controller/RefControl/@fileID and string-length(link.xref.controller/RefControl/@RefID) = 0">
				<xsl:attribute name="RefID">
					<xsl:value-of select="link.xref.controller/RefControl/@fileID"/>
				</xsl:attribute>
			</xsl:if>
			<InfoChunk.Link>
				<xsl:choose>
					<xsl:when test="string-length(normalize-space(linktext)) &gt; 0">
						<xsl:attribute name="isCustomLinktext"/>
						<xsl:copy-of select="linktext/@*"/>
						<xsl:apply-templates select="linktext/node()"/>
					</xsl:when>
					<xsl:when test="string-length(normalize-space(link.xref.controller/RefControl/linktext)) &gt; 0">
						<xsl:copy-of select="link.xref.controller/RefControl/linktext/@*"/>
						<xsl:apply-templates select="link.xref.controller/RefControl/linktext/node()"/>
					</xsl:when>
					<xsl:otherwise>
						<xsl:value-of select="link.xref.controller/RefControl/@TargetTitle"/>
					</xsl:otherwise>
				</xsl:choose>
			</InfoChunk.Link>
			
			<xsl:if test = "link.xref.controller/RefControl/RefDetail/props">
				<xsl:apply-templates select = "link.xref.controller/RefControl/RefDetail"/>
			</xsl:if>
			
		</Link.XRef>
	</xsl:template>

	<xsl:template match = "Reference">
		<Link.XRef>
			<xsl:copy-of select="@*"/>
			<xsl:copy-of select="Reference.controller/RefControl/@*"/>
			<xsl:if test="Reference.controller/RefControl/@fileID">
				<xsl:attribute name="RefID">
					<xsl:value-of select="Reference.controller/RefControl/@fileID"/>
				</xsl:attribute>
			</xsl:if>
			<InfoChunk.Link>
				<xsl:value-of select="Reference.controller/RefControl/@TargetTitle"/>
			</InfoChunk.Link>
			<xsl:apply-templates select="Reference.controller/RefControl/*"/>
		</Link.XRef>
	</xsl:template>

	<xsl:template match="link.detail">
		<Link.Detail>
			<xsl:copy-of select="@*"/>
			<xsl:copy-of select="link.detail.controller/@*"/>
			<xsl:copy-of select="link.detail.controller/RefControl/@*"/>
			<InfoChunk.Link>
				<xsl:value-of select="link.detail.controller/RefControl/@TargetTitle"/>
			</InfoChunk.Link>
		</Link.Detail>
	</xsl:template>

	<xsl:template match="link.element">
		<xsl:copy>
			<xsl:copy-of select="@* | link.element.controller/@* | link.element.controller/RefControl/@*"/>
			<InfoChunk.Link>
				<xsl:choose>
					<xsl:when test="string-length(normalize-space(linktext)) &gt; 0">
						<xsl:attribute name="isCustomLinktext"/>
						<xsl:copy-of select="linktext/@*"/>
						<xsl:apply-templates select="linktext/node()"/>
					</xsl:when>
					<xsl:when test="string-length(link.element.controller/RefControl/linktext) &gt; 0">
						<xsl:copy-of select="link.element.controller/RefControl/linktext/@*"/>
						<xsl:apply-templates select="link.element.controller/RefControl/linktext/node()"/>
					</xsl:when>
					<xsl:otherwise>
						<xsl:value-of select="link.element.controller/RefControl/@TargetTitle"/>
					</xsl:otherwise>
				</xsl:choose>
			</InfoChunk.Link>
		</xsl:copy>
	</xsl:template>

	<xsl:template match="link.anchor">
		<xsl:copy>
			<xsl:apply-templates select="link.anchor.controller" mode="copyDiffAttributes"/>
			<xsl:copy-of select="@* | link.anchor.controller/RefControl/@* | link.anchor.controller/RefControl/RefDetail/@*"/>
			<InfoChunk.Link>
				<xsl:choose>
					<xsl:when test="string-length(normalize-space(linktext/node())) &gt; 0">
						<xsl:apply-templates select="linktext/node()"/>
					</xsl:when>
					<xsl:otherwise>
						<xsl:value-of select="link.anchor.controller/RefControl/@TargetTitle"/>
					</xsl:otherwise>
				</xsl:choose>
			</InfoChunk.Link>
		</xsl:copy>
	</xsl:template>

	<xsl:template match="link.mailTo">
		<Link.MailTo mailTo="{normalize-space(URIDefinition/URI)}">
			<xsl:copy-of select="@*"/>
			<xsl:copy-of select="RefControl/@hasError"/>
			<InfoChunk.Link>
				<xsl:choose>
					<xsl:when test="RefControl/@RefID = 'alt' and string-length(URIDefinition/AltLinktext) &gt; 0">
						<xsl:apply-templates select="URIDefinition/AltLinktext/node()"/>
					</xsl:when>
					<xsl:otherwise>
						<xsl:apply-templates select="URIDefinition/Linktext/node()"/>
					</xsl:otherwise>
				</xsl:choose>
			</InfoChunk.Link>
		</Link.MailTo>
	</xsl:template>

	<xsl:template match="link.url">
		<Link.URL URL="{normalize-space(URIDefinition/URI)}">
			<xsl:copy-of select="@*"/>
			<xsl:copy-of select="URIDefinition/@*"/>
			<xsl:copy-of select="RefControl/@hasError"/>
			<InfoChunk.Link>
				<xsl:choose>
					<xsl:when test="RefControl/@RefID = 'alt' and string-length(URIDefinition/AltLinktext) &gt; 0">
						<xsl:apply-templates select="URIDefinition/AltLinktext/node()"/>
					</xsl:when>
					<xsl:otherwise>
						<xsl:apply-templates select="URIDefinition/Linktext/node()"/>
					</xsl:otherwise>
				</xsl:choose>
			</InfoChunk.Link>
		</Link.URL>
	</xsl:template>

	<xsl:template match="link.file | FileAssetReference">
		<xsl:variable name="elemName">
			<xsl:choose>
				<xsl:when test="name() = 'link.file'">Link.File</xsl:when>
				<xsl:otherwise>
					<xsl:value-of select="name()"/>
				</xsl:otherwise>
			</xsl:choose>
		</xsl:variable>
	   <xsl:choose>
	    	<xsl:when test="string-length(@showPreviewImage) &gt; 0">
	    		<xsl:variable name="serverURL"><xsl:value-of select="RefControl/@serverURL"/></xsl:variable>
	    		<xsl:variable name="subURL"><xsl:value-of select="concat('/repository/default',RefControl/@previewImgURL)"/></xsl:variable>
	    		    
	    		<xsl:variable name="escapedSubURL">    		    	
	    		    <xsl:choose>
	    		    	<xsl:when test="$isOffline">
	    		    		<xsl:value-of select="concat('/media/',RefControl/@previewImgURL)"/>
	    		    	</xsl:when>
	    		    	<xsl:otherwise>
	    		    		<xsl:value-of select="concat('',RefControl/@previewImgURL)"/>
	    		    	</xsl:otherwise>
	    		    </xsl:choose>    		    		    
	    		</xsl:variable>


	    		<xsl:variable name="escapedOriginalURL">    		    	
	    		    <xsl:choose>
	    		    	<xsl:when test="$isOffline">
	    		    		<xsl:value-of select="concat('/media/',RefControl/@escapedOriginalURL)"/>
	    		    	</xsl:when>
	    		    	<xsl:otherwise>
	    		    		<xsl:value-of select="RefControl/@escapedOriginalURL"/>
	    		    	</xsl:otherwise>
	    		    </xsl:choose>    		    		    
	    		</xsl:variable>

	    		<xsl:variable name="originalURL">    		    	
	    		    <xsl:choose>
	    		    	<xsl:when test="$isOffline">
	    		    		<xsl:value-of select="concat('/media/',RefControl/@originalURL)"/>
	    		    	</xsl:when>
	    		    	<xsl:otherwise>
	    		    		<xsl:value-of select="RefControl/@originalURL"/>
	    		    	</xsl:otherwise>
	    		    </xsl:choose>    		    		    
	    		</xsl:variable>				
				
	    		<xsl:variable name="previewImgURL"><xsl:value-of select="RefControl/@previewImgURL"/></xsl:variable>
	    		<xsl:variable name="width">
					<xsl:choose>
						<xsl:when test="string-length($LINKFILE_PDF_PreviewWidth) &gt; 0">
							<xsl:value-of select="$LINKFILE_PDF_PreviewWidth"/>
						</xsl:when>
						<xsl:otherwise>
							<xsl:value-of select="RefControl/@imgWidth"/>
						</xsl:otherwise>
					</xsl:choose>
				</xsl:variable>
	    		<xsl:variable name="height">
					<xsl:if test="string-length(RefControl/@imgHeight) &gt; 0 and string-length(RefControl/@imgWidth) &gt; 0">
						<xsl:choose>
							<xsl:when test="string-length($LINKFILE_PDF_PreviewWidth) &gt; 0">
								<xsl:value-of select="RefControl/@imgHeight * ($LINKFILE_PDF_PreviewWidth div RefControl/@imgWidth)"/>
							</xsl:when>
							<xsl:otherwise>
								<xsl:value-of select="RefControl/@imgHeight"/>
							</xsl:otherwise>
						</xsl:choose>
					</xsl:if>
				</xsl:variable>
	    		<xsl:variable name="resolution"><xsl:value-of select="RefControl/@imgResolution"/></xsl:variable>
	    		    
		    		    	    
		    	    <Media.theme addMe="Fixed" align="" button="Fixed" converter="1. JPG - Fotos" delButton="Fixed" fileType="png" filter="" firstTime="-" fixedHeight="" fixedWidth="" size-unit="px" updateAction="update">
		    	    	<xsl:attribute name="subURL"><xsl:value-of select="$subURL"/></xsl:attribute>
		    	    	<xsl:attribute name="escapedSubURL"><xsl:value-of select="$escapedSubURL"/></xsl:attribute>		    	    	    
		    	    	<xsl:attribute name="serverURL"><xsl:value-of select="$serverURL"/></xsl:attribute>
		    	    	<xsl:attribute name="width">
							<xsl:value-of select="$width"/>
						</xsl:attribute>
		    	    	<xsl:attribute name="height"><xsl:value-of select="$height"/></xsl:attribute>
		    	    	<xsl:attribute name="resolution"><xsl:value-of select="$resolution"/></xsl:attribute>
	    	    			
	    	    		<Link.File PickerElement="link.file" PDFLinkType="none" PDFLinkValue = "" extension="pdf"  button="Fixed" delButton="Fixed" firstTime="-" format="" objType="file"  visible="false" visibleButton="Fixed">
	    	    			<xsl:attribute name="Linktext"><xsl:value-of select="concat(' ', @Linktext , ' ')"/></xsl:attribute> 
		    	    		<xsl:attribute name="escapedOriginalURL"><xsl:value-of select="$escapedOriginalURL"/></xsl:attribute>
		    	    		<xsl:attribute name="originalURL"><xsl:value-of select="$originalURL"/></xsl:attribute>
		    	    		<xsl:attribute name="serverURL"><xsl:value-of select="$serverURL"/></xsl:attribute>	  
		    	    		
							<xsl:attribute name="resolvedLanguage"><xsl:value-of select="RefControl/@resolvedLanguage"/></xsl:attribute>			
		    	    		<xsl:attribute name="serverID"><xsl:value-of select="RefControl/@serverID"/></xsl:attribute>
		    	    		<xsl:attribute name="webdavID"><xsl:value-of select="RefControl/@webdavID"/></xsl:attribute>
		    	    		<xsl:attribute name="TargetTitle"><xsl:value-of select="RefControl/@TargetTitle"/></xsl:attribute>
		    	    		<xsl:attribute name="versionLabel"><xsl:value-of select="RefControl/@versionLabel"/></xsl:attribute>
							<xsl:attribute name="extension">pdf</xsl:attribute>
		    	    		  	    			
	    	    		</Link.File>
	    	    			
	    	    			
	    	    		<RefControl PickerElement="media.theme" TargetTitle="title" defaultTitle="" location="/Content" objType="mediaset" webdavID="{RefControl/@previewID}" resolvedLanguage="{RefControl/@resolvedLanguage}"  serverID="{RefControl/@serverID}" versionLabel="{RefControl/@versionLabel}">	    	    							
                            <substitute align="" converter="1. JPG - Fotos" decisionType="" fileType="png" fixedHeight="" fixedWidth="" resunit="px" size-unit="px" type="original">                                                        
	                            <xsl:attribute name="subURL"><xsl:value-of select="$subURL"/></xsl:attribute>
			    	    	    <xsl:attribute name="escapedSubURL"><xsl:value-of select="$escapedSubURL"/></xsl:attribute>
	                            <xsl:attribute name="serverURL"><xsl:value-of select="$serverURL"/></xsl:attribute>
	                            <xsl:attribute name="width"><xsl:value-of select="$width"/></xsl:attribute>
		    	    	    	<xsl:attribute name="height"><xsl:value-of select="$height"/></xsl:attribute>
		    	    	    	<xsl:attribute name="resolution"><xsl:value-of select="$resolution"/></xsl:attribute>
		    	    	    	<xsl:attribute name="previewImgURL"><xsl:value-of select="$previewImgURL"/></xsl:attribute>
		    	    	    	<xsl:attribute name="previewThemeURL"><xsl:value-of select="@previewThemeURL"/></xsl:attribute>
		    	    	    	<xsl:attribute name="type">preview</xsl:attribute>
		    	    	    	<xsl:attribute name="fileType">png</xsl:attribute>
                            </substitute>
							
							<xsl:apply-templates select = "RefControl/Properties"/>
							<!--
							<Properties>
								<Property name = "SMCDOCINFO:t3_sync_hash" value = "124">124</Property>
							</Properties>
							-->

                        </RefControl>	               			
		    	    </Media.theme>
		    	
	    	</xsl:when>
			<xsl:otherwise>
				<xsl:element name="{$elemName}">
					<xsl:copy-of select="@*"/>
					<xsl:if test="string-length(@Linktext) = 0">
						<xsl:attribute name="Linktext">
							<xsl:value-of select="RefControl/@TargetTitle"/>
						</xsl:attribute>
					</xsl:if>
					<xsl:copy-of select="RefControl/@*"/>
					<xsl:if test="$isOffline and RefControl/@originalURL">
						<xsl:variable name="prefix">
							<xsl:if test="not(parent::includefile) and $appendMediaPathPrefix = 'true'">/media</xsl:if>
						</xsl:variable>
						<xsl:attribute name="originalURL">
							<xsl:choose>
								<xsl:when test="starts-with(RefControl/@originalURL, '/')">
									<xsl:value-of select="concat($prefix, RefControl/@originalURL)"/>
								</xsl:when>
								<xsl:otherwise>
									<xsl:value-of select="concat($prefix, '/', RefControl/@originalURL)"/>
								</xsl:otherwise>
							</xsl:choose>
						</xsl:attribute>
					</xsl:if>
					<xsl:if test="RefControl/@escapedOriginalURL">
						<xsl:attribute name="escapedOriginalURL">
							<xsl:call-template name="replace">
								<xsl:with-param name="string" select="RefControl/@escapedOriginalURL"/>
								<xsl:with-param name="pattern" select="'+'"/>
								<xsl:with-param name="replacement">%20</xsl:with-param>
							</xsl:call-template>
						</xsl:attribute>
					</xsl:if>
				</xsl:element>
			</xsl:otherwise>  
	    </xsl:choose>				
	</xsl:template>

	<xsl:template match="*[starts-with(name(), 'block.') and name() != 'block.titlepage']">
		<xsl:choose>
			<xsl:when test="@Changed = 'INSERTED'">
				<!--<INSERTED>-->
				<xsl:call-template name="writeBlocks"/>
				<!--</INSERTED>-->
			</xsl:when>
			<xsl:when test="@Changed = 'UPDATED'">
				<!--<UPDATED>-->
				<xsl:call-template name="writeBlocks"/>
				<!--</UPDATED>-->
			</xsl:when>
			<xsl:when test="@Changed = 'DELETED'">
				<!--<DELETED>-->
				<xsl:call-template name="writeBlocks"/>
				<!--</DELETED>-->
			</xsl:when>
			<xsl:otherwise>
				<xsl:choose>
					<xsl:when test="not($ShowAllBlocks='true') and ($Blockwise='true' or starts-with(ancestor::*[name() = 'section' or name() = 'Start'][1]/@type,'Multimedia'))">
						<xsl:choose>
							<xsl:when test="name()='block.abstract'">
								<xsl:if test="not($Online='Online')">
									<xsl:call-template name="writeBlocks"/>
								</xsl:if>
							</xsl:when>
							<xsl:when test="count(preceding-sibling::*[starts-with(name(),'block') and not(name() = 'block.abstract') and not(@visible='false')]) &gt; 0 and string-length($BlockFilter) = 0">
								<xsl:call-template name="writeMapWrapper"/>
							</xsl:when>
							<xsl:otherwise>
								<xsl:call-template name="writeBlocks"/>
							</xsl:otherwise>
						</xsl:choose>
					</xsl:when>
					<xsl:otherwise>
						<xsl:call-template name="writeBlocks"/>
					</xsl:otherwise>
				</xsl:choose>
			</xsl:otherwise>
		</xsl:choose>
	</xsl:template>

	<xsl:template match="block.titlepage">
		<xsl:copy>
			<xsl:copy-of select="@*"/>
			<xsl:attribute name="Typ">
				<xsl:value-of select="TypControl/@type"/>
			</xsl:attribute>
			<xsl:attribute name="Function">block.titlepage</xsl:attribute>
			<xsl:variable name="lang" select="ancestor::*[name() = 'section' or name() = 'Start'][@defaultLanguage][1]/@defaultLanguage"/>
			<xsl:choose>
				<xsl:when test="string-length($lang) &gt; 0">
					<xsl:attribute name="defaultLanguage">
						<xsl:value-of select="$lang"/>
					</xsl:attribute>
				</xsl:when>
				<xsl:otherwise>
					<xsl:attribute name="defaultLanguage">
						<xsl:value-of select="$language"/>
					</xsl:attribute>
				</xsl:otherwise>
			</xsl:choose>
			<xsl:apply-templates/>
		</xsl:copy>
	</xsl:template>

	<xsl:template name="writeMapWrapper">
		<InfoMap ID="{@ID}" NavigationsBez="" Title="{ancestor-or-self::*[name() = 'section' or name() = 'Start'][1]/@Title}" collectionID="" fileID="{@ID}.html" HideInNavigation="true" Lang="{$LANGUAGE_CODE}">
			<xsl:choose>
				<xsl:when test="ancestor::section[1]/@type = 'Multimedia'">
					<xsl:attribute name="Typ">
						<xsl:value-of select="ancestor-or-self::*[name() = 'section' or name() = 'Start'][1]/@type"/>
					</xsl:attribute>
				</xsl:when>
				<xsl:when test="string-length(TypControl/@type) &gt; 0 and TypControl/@visible = 'true'">
					<xsl:attribute name="Typ">
						<xsl:value-of select="TypControl/@type"/>
					</xsl:attribute>
				</xsl:when>
				<xsl:otherwise>
					<xsl:if test="string-length(@type) = 0">
						<xsl:attribute name = "Typ">
							<xsl:if test="not($INHERIT_SECTION_TYPES = 'false')">
								<xsl:value-of select="ancestor-or-self::*[name() = 'section' or name() = 'Start'][1]/@type"/>
							</xsl:if>
						</xsl:attribute>
					</xsl:if>
				</xsl:otherwise>
			</xsl:choose>

			<xsl:attribute name="path">
				<xsl:for-each select="ancestor-or-self::*[name() = 'section' or name() = 'Start']">
					<xsl:value-of select="concat(@ID, '/')"/>
				</xsl:for-each>
			</xsl:attribute>

			<xsl:attribute name="rootPath">
				<xsl:for-each select="ancestor-or-self::*[name() = 'section' or name() = 'Start']">../</xsl:for-each>
			</xsl:attribute>
			<xsl:for-each select="ancestor::*[name() = 'section' or name() = 'Start'][1]/headline.content">
				<Headline.content>
					<xsl:apply-templates/>
				</Headline.content>
			</xsl:for-each>
			<xsl:call-template name="writeBlocks"/>
		</InfoMap>
	</xsl:template>

	<xsl:template name="writeBlocks">

		<xsl:variable name="ID">
			<xsl:choose>
				<xsl:when test="ancestor::section[1][@Lexdoc = 'true']">
					<xsl:value-of select="generate-id()"/>
				</xsl:when>
				<xsl:otherwise>
					<xsl:value-of select="@ID"/>
				</xsl:otherwise>
			</xsl:choose>
		</xsl:variable>

		<xsl:if test="string-length(@visible) = 0 or @visible = 'true'">
			<xsl:choose>
				<!-- Only if called from picker window -->
				<xsl:when test="$PickerElement = 'link.detail.controller'">
					<Block Function="{name()}">
						<xsl:apply-templates select="current()" mode="copyDiffAttributes"/>
						<xsl:apply-templates select="current()" mode="copyCharacterizationAttributes"/>
						<xsl:attribute name="ID">
							<xsl:value-of select="$ID"/>
						</xsl:attribute>
						<xsl:call-template name="writeBlockContents"/>
						<xsl:apply-templates/>
					</Block>
				</xsl:when>
				<!-- If called from a link.detail -->
				<xsl:when test="string-length($BlockFilter) &gt; 0">

					<xsl:choose>
						<xsl:when test="$BlockFilter = $ID">
							<Block Function="{name()}">
								<xsl:apply-templates select="current()" mode="copyDiffAttributes"/>
								<xsl:apply-templates select="current()" mode="copyCharacterizationAttributes"/>
								<xsl:attribute name="ID">
									<xsl:value-of select="$ID"/>
								</xsl:attribute>
								<xsl:call-template name="writeStepAttributes"/>
								<xsl:call-template name="writeBlockContents"/>
								<xsl:apply-templates/>
							</Block>
						</xsl:when>
						<xsl:when test="$BlockFilter = 'start' ">
							<xsl:if test="parent::blocks and not(@visible='false') and count(preceding-sibling::*[starts-with(name(),'block.') and not(@visible='false')])=0">
								<Block Function="{name()}">
									<xsl:apply-templates select="current()" mode="copyDiffAttributes"/>
									<xsl:apply-templates select="current()" mode="copyCharacterizationAttributes"/>
									<xsl:attribute name="ID">
										<xsl:value-of select="$ID"/>
									</xsl:attribute>
									<xsl:call-template name="writeStepAttributes"/>
									<xsl:call-template name="writeBlockContents"/>
									<xsl:apply-templates/>
								</Block>
							</xsl:if>
						</xsl:when>
						<xsl:when test="$BlockFilter = 'end' ">
							<xsl:if test="parent::blocks and not(@visible='false') and count(following-sibling::*[starts-with(name(),'block.') and not(@visible='false')])=0">
								<Block Function="{name()}">
									<xsl:apply-templates select="current()" mode="copyDiffAttributes"/>
									<xsl:apply-templates select="current()" mode="copyCharacterizationAttributes"/>
									<xsl:attribute name="ID">
										<xsl:value-of select="$ID"/>
									</xsl:attribute>
									<xsl:call-template name="writeStepAttributes"/>
									<xsl:call-template name="writeBlockContents"/>
									<xsl:apply-templates/>
								</Block>
							</xsl:if>
						</xsl:when>
					</xsl:choose>
				</xsl:when>
				<xsl:when test="name() = 'block.abstract'">
					<xsl:apply-templates select="current()" mode="writeBlockAbstract">
						<xsl:with-param name="ID" select="$ID" />
						<xsl:with-param name="HTMLHelp" select="$HTMLHelp" />
						<xsl:with-param name="WebHelp" select="$WebHelp" />
					</xsl:apply-templates>
				</xsl:when>
				<xsl:when test="name() = 'block.remark'">
					<xsl:if test="not($HTMLHelp = 'HTMLHelp' or $WebHelp = 'WebHelp' or $Offline='Offline') or $showBlockRemark = 'true'">
						<Block.remark Function="{name()}">
							<xsl:copy-of select="@translate"/>
							<xsl:apply-templates select="current()" mode="copyDiffAttributes"/>
							<xsl:apply-templates select="current()" mode="copyCharacterizationAttributes"/>
							<xsl:attribute name="ID">
								<xsl:value-of select="$ID"/>
							</xsl:attribute>
							<xsl:apply-templates/>
						</Block.remark>
					</xsl:if>
				</xsl:when>
				<xsl:when test="name() = 'block.test'">
					<Block.test Function="{name()}">
						<xsl:copy-of select="@*"/>
						<xsl:call-template name="writeStepAttributes"/>

						<xsl:call-template name="writeBlockContents"/>
						<smc-TestFunctions/>
						<xsl:apply-templates/>
						<smc-TestEnd/>
					</Block.test>
				</xsl:when>
				<xsl:otherwise>
					<Block Function="{name()}">
						<xsl:apply-templates select="current()" mode="copyDiffAttributes"/>
						<xsl:apply-templates select="current()" mode="copyCharacterizationAttributes"/>
						<xsl:attribute name="ID">
							<xsl:value-of select="$ID"/>
						</xsl:attribute>
						<xsl:if test="not(@Changed)">
							<xsl:copy-of select="parent::blocks/@Changed"/>
						</xsl:if>
						<xsl:copy-of select="@translate | @url | @height | @width | @originalID"/>
						<xsl:copy-of select="@defaultLanguage"/>
						<xsl:call-template name="writeStepAttributes"/>
						<xsl:call-template name="writeBlockContents"/>
						<!--<xsl:if test="descendant::media.animation">
							<smc-TestFunctions/>
						</xsl:if>-->
						<xsl:apply-templates/>
					</Block>
				</xsl:otherwise>
			</xsl:choose>
		</xsl:if>

		<xsl:if test="@visible='false' and not($Offline='Offline' or $Typo3Sync = 'Typo3Sync')">
			<Block.invisible>
				
				<xsl:value-of select="label"/>
			</Block.invisible>
		</xsl:if>

	</xsl:template>

	<xsl:template match="block.abstract" mode="writeBlockAbstract">
		<xsl:param name="ID" />
		<xsl:param name="HTMLHelp" />
		<xsl:param name="WebHelp" />
		
		<xsl:choose>
			<xsl:when test="$showAbstract='false'"></xsl:when>
			<xsl:when test="not($HTMLHelp = 'HTMLHelp' or $WebHelp = 'WebHelp')">
				<Block ID="{$ID}" Function="{name()}" Typ="TextBild">
					<xsl:copy-of select="@translate"/>
					<xsl:apply-templates select="current()" mode="copyDiffAttributes"/>
					<xsl:apply-templates select="current()" mode="copyCharacterizationAttributes"/>
					<xsl:apply-templates/>
				</Block>
			</xsl:when>
		</xsl:choose>
	</xsl:template>

	<xsl:template name="writeBlockContents">
		<xsl:copy-of select="@topic_num | @topicID | TypControl/@cols | TypControl/@clear | TypControl/@startcol | TypControl/@align | ancestor::*[string-length(@defaultLanguage) &gt; 0][1]/@defaultLanguage"/>

		<xsl:choose>
			<xsl:when test="string-length(TypControl/@type) &gt; 0">
				<xsl:attribute name="Typ">
					<xsl:value-of select="TypControl/@type"/>
				</xsl:attribute>
			</xsl:when>
			<xsl:otherwise>
				<xsl:attribute name="Typ">
					<xsl:if test="not($INHERIT_SECTION_TYPES = 'false')">
						<xsl:value-of select="ancestor-or-self::*[name() = 'section' or name() = 'Start'][1]/@type"/>
					</xsl:if>
				</xsl:attribute>
			</xsl:otherwise>
		</xsl:choose>

	</xsl:template>

	<xsl:template name="writeStepAttributes">
		<xsl:if test="not($DISABLE_STEP_ATTRIBUTES_WRITING = 'true')">
			<xsl:variable name="previousBlockPrep">
				<xsl:value-of select="preceding-sibling::*[starts-with(name(),'block.') and not(@visible='false' or name() = 'block.detail')][1]/@ID"/>
			</xsl:variable>
			<xsl:variable name="followingBlockPrep">
				<xsl:value-of select="following-sibling::*[starts-with(name(),'block.') and not(@visible='false' or name() = 'block.detail')][1]/@ID"/>
			</xsl:variable>
			<xsl:attribute name="previousBlock">
				<xsl:if test="string-length($previousBlockPrep) = 0">end</xsl:if>
				<xsl:value-of select="$previousBlockPrep"/>
			</xsl:attribute>
			<xsl:attribute name="followingBlock">
				<xsl:if test="string-length($followingBlockPrep) = 0">start</xsl:if>
				<xsl:value-of select="$followingBlockPrep"/>
			</xsl:attribute>
			<xsl:attribute name="blockCount">
				<xsl:value-of select="count(preceding-sibling::*[starts-with(name(),'block.') and not(@visible='false'  or name() = 'block.detail') and not(name()='block.abstract')])+1"/>
			</xsl:attribute>

			<xsl:attribute name="blockCountMax">
				<xsl:value-of select="count(parent::*/*[starts-with(name(),'block.') and not(@visible='false' or name() = 'block.detail') and not(name()='block.abstract')])"/>
			</xsl:attribute>

			<xsl:attribute name="previousMap">
				<xsl:for-each select="//InfoMap[ancestor::Navigation][@current='yes']">
					<xsl:choose>
						<xsl:when test="ancestor::InfoMap and not (preceding-sibling::InfoMap)">
							<xsl:value-of select="ancestor::InfoMap[1]/@ID"/>
						</xsl:when>
						<xsl:otherwise>
							<xsl:value-of select="preceding::InfoMap[1]/@ID"/>
						</xsl:otherwise>
					</xsl:choose>
				</xsl:for-each>
			</xsl:attribute>

			<xsl:attribute name="followingMap">
				<xsl:for-each select="//InfoMap[ancestor::Navigation][@current='yes']">
					<xsl:choose>
						<xsl:when test="InfoMap">
							<xsl:value-of select="InfoMap[1]/@ID"/>
						</xsl:when>
						<xsl:otherwise>
							<xsl:value-of select="following::InfoMap[1]/@ID"/>
						</xsl:otherwise>
					</xsl:choose>
				</xsl:for-each>
			</xsl:attribute>
		</xsl:if>
	</xsl:template>

	<xsl:template match="TypControl"/>

	<xsl:template match="form.answer.explanation">
		<xsl:if test="not($FOP='FOP')">
			<xsl:copy>
				<xsl:copy-of select="@*"/>
				<xsl:apply-templates/>
			</xsl:copy>
		</xsl:if>
	</xsl:template>

	<xsl:template match="Note" mode="note-mail">
		<InfoMap>
			<xsl:apply-templates select="//Body"/>
			<Headline.content>
				<xsl:value-of select="Field[@name = 'title']"/>
			</Headline.content>
			<Block Function="block.description">
				<xsl:for-each select="Field[@name != 'title'
							  and @name != 'id'
							  and @name != 'referenceObjectID'
							  and string-length(.) &gt; 0]">
					<InfoPar>
						<InfoChunk.Important>
							<xsl:value-of select="@name"/>
							<xsl:text>: </xsl:text>
						</InfoChunk.Important>
						<xsl:value-of select="."/>
					</InfoPar>
				</xsl:for-each>
			</Block>
		</InfoMap>
	</xsl:template>

	<xsl:template match="*" mode="copyDiffAttributes">
		<xsl:copy-of select="@Changed[string-length(.) &gt; 0] | @AttributesChanged[string-length(.) &gt; 0] | @ID[string-length(.) &gt; 0] | @mergeConflict[string-length(.) &gt; 0]"/>
	</xsl:template>

	<xsl:template match="*" mode="copyDiffAttributesFromParent">
		<xsl:apply-templates select="parent::*" mode="copyDiffAttributes"/>
		<xsl:apply-templates select="current()" mode="copyDiffAttributes"/>
	</xsl:template>

	<xsl:template match="*" mode="copyCharacterizationAttributes">
		<xsl:copy-of select="@filter | @metafilter | @readableFilter | @charCategoryColor | @charPropertyColor | @cssClassName | @translated | @translate"/>
	</xsl:template>


	<xsl:template match="MMFramework.Container[parent::RefControl]"/>


</xsl:stylesheet>
