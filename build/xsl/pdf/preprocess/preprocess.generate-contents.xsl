<?xml version="1.0" encoding="utf-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" version = "1.0">

	<xsl:param name="mode"/>
	<xsl:param name="IMAGE_LISTING_COLUMN_LENGTH" select="16"/>
	<xsl:param name="TABLE_LISTING_COLUMN_LENGTH" select="14"/>
	<xsl:param name="GENERATE_LIST_BLOCKS"/>
	<xsl:param name="GENERATE_HIERARCHICAL"/>
	<xsl:param name="preserveGenerateLink"/>

	<xsl:variable name="imageListingWidth">
		<xsl:call-template name="getFormatVariableValue">
			<xsl:with-param name="name">GENERATE_IMAGE_LISTING_COL1</xsl:with-param>
			<xsl:with-param name="defaultValue" select="$IMAGE_LISTING_COLUMN_LENGTH"/>
		</xsl:call-template>
	</xsl:variable>

	<xsl:variable name="tableListingWidth">
		<xsl:call-template name="getFormatVariableValue">
			<xsl:with-param name="name">GENERATE_TABLE_LISTING_COL1</xsl:with-param>
			<xsl:with-param name="defaultValue" select="$TABLE_LISTING_COLUMN_LENGTH"/>
		</xsl:call-template>
	</xsl:variable>

	<xsl:variable name="allowTitleFallback">
		<xsl:call-template name="getFormatVariableValue">
			<xsl:with-param name="name">GENERATE_CONTENT_ALLOW_TITLE_FALLBACK</xsl:with-param>
		</xsl:call-template>
	</xsl:variable>

	<xsl:variable name="includeSubsectionsGlobal">
		<xsl:call-template name="getFormatVariableValue">
			<xsl:with-param name="name">GENERATE_CONTENT_INCLUDE_SUBSECTIONS</xsl:with-param>
		</xsl:call-template>
	</xsl:variable>

	<xsl:template match="generate">
		<xsl:choose>
			<xsl:when test="starts-with(@type, 'Contents') and Originals">
				<xsl:call-template name="generateContentsFromMediaDB"/>
			</xsl:when>
			<xsl:when test="starts-with(@type, 'Contents')">
				<xsl:call-template name="generateContents"/>
			</xsl:when>
			<xsl:when test="@type = 'Index'">
				<generate.index index_type="{@index_type}">
					<xsl:copy-of select="ancestor-or-self::*[(name() = 'section' or name() = 'Start') and @defaultLanguage][1]/@defaultLanguage"/>
					<xsl:apply-templates select="current()" mode="copyDiffAttributes"/>
					<xsl:apply-templates select="current()" mode="copyCharacterizationAttributes"/>
				</generate.index>
			</xsl:when>
			<xsl:when test="@type = 'Glossary'">
				<xsl:call-template name="generateGlossary"/>
			</xsl:when>
			<xsl:when test="@type = 'TableListing'">
				<xsl:call-template name="generateTableListing"/>
			</xsl:when>
			<xsl:when test="@type = 'ImgListing'">
				<xsl:call-template name="generateImgListing"/>
			</xsl:when>
			<xsl:when test="@type = 'StaticSearch'">
				<generate.staticsearch>
					<xsl:apply-templates select="current()" mode="copyDiffAttributes"/>
					<xsl:apply-templates select="current()" mode="copyCharacterizationAttributes"/>
					<List>
						<xsl:apply-templates select="staticSearch/List/ListDef"/>
					</List>
					<xsl:apply-templates select="GotThemes" mode="StaticSearch"/>
				</generate.staticsearch>
			</xsl:when>
			<xsl:when test="@type = 'SearchForm'">
				<generate.searchform>
					<xsl:apply-templates select="current()" mode="copyDiffAttributes"/>
					<xsl:apply-templates select="current()" mode="copyCharacterizationAttributes"/>
					<xsl:apply-templates select="Form"/>
				</generate.searchform>
			</xsl:when>
			<xsl:otherwise>
				<xsl:copy>
					<xsl:copy-of select="@*"/>
					<xsl:apply-templates/>
				</xsl:copy>
			</xsl:otherwise>
		</xsl:choose>
	</xsl:template>

	<xsl:template match="generate.content">
		<generate.content/>
	</xsl:template>

	<xsl:template match="GotThemes" mode="StaticSearch">
		<xsl:variable name="serverURL" select="@server-uri"/>
		<xsl:copy>
			<xsl:copy-of select="@*"/>
			<xsl:for-each select="Theme[Properties/Property[@name = 'SMC:objType' and (starts-with(@value, 'doc') or @value = 'file')]]">
				<xsl:variable name="isStandard" select="Properties/Property[@name = 'SMCDOCINFO:IsStandard' and @value = 'true']"/>
				<xsl:variable name="IsDesignIn" select="Properties/Property[@name = 'SMCDOCINFO:IsDesignIn' and @value = 'true']"/>

				<xsl:variable name="modeCurrent">
					<xsl:choose>
						<xsl:when test="$IsDesignIn">
							<xsl:text>designin</xsl:text>
						</xsl:when>
						<xsl:when test="$isStandard">
							<xsl:text>standard</xsl:text>
						</xsl:when>
					</xsl:choose>
				</xsl:variable>

				<xsl:if test="$mode = 'news' or $mode = $modeCurrent or ($IsDesignIn and $isStandard)">
					<xsl:copy>
						<xsl:copy-of select="@*"/>
						<xsl:if test="Original">
							<xsl:attribute name="originalURL">
								<xsl:value-of select="Original/Properties/Property[@name = 'uri']/@value"/>
							</xsl:attribute>
							<xsl:attribute name="serverURL">
								<xsl:value-of select="$serverURL"/>
							</xsl:attribute>
						</xsl:if>
						<xsl:apply-templates select="*[name() != 'Original']"/>
					</xsl:copy>
				</xsl:if>

			</xsl:for-each>
		</xsl:copy>
	</xsl:template>

	<xsl:template name="generateContentsFromMediaDB">

		<InfoItem.Overviewall>
			<xsl:copy-of select="@type
				| @contents_levels
				| @defaultLanguage[string-length(.) &gt; 0]"/>
			<xsl:apply-templates select="current()" mode="copyDiffAttributes"/>
			<xsl:apply-templates select="current()" mode="copyCharacterizationAttributes"/>
			<xsl:for-each select="Originals//Original[Properties/Property[@name = 'SMC:objType' and (starts-with(@value, 'doc') or @value = 'book.doc')]]">
				<xsl:variable name="isStandard" select="Properties/Property[@name = 'SMCDOCINFO:IsStandard' and @value = 'true']"/>
				<xsl:variable name="IsDesignIn" select="Properties/Property[@name = 'SMCDOCINFO:IsDesignIn' and @value = 'true']"/>

				<xsl:variable name="modeCurrent">
					<xsl:choose>
						<xsl:when test="$IsDesignIn">
							<xsl:text>designin</xsl:text>
						</xsl:when>
						<xsl:when test="$isStandard">
							<xsl:text>standard</xsl:text>
						</xsl:when>
					</xsl:choose>
				</xsl:variable>

				<xsl:if test="$CLIENT != 'megatron' or $mode = 'news' or $mode = $modeCurrent or ($IsDesignIn and $isStandard)">
					<InfoItem.Overview>
						<xsl:copy-of select="@*"/>
						<xsl:attribute name="abs_level">
							<xsl:value-of select="count(ancestor::Original)"/>
						</xsl:attribute>
						<xsl:attribute name="rel_level">
							<xsl:value-of select="count(ancestor::Original)"/>
						</xsl:attribute>
						<xsl:attribute name="abs_position">
							<xsl:for-each select="ancestor-or-self::Original">
								<xsl:value-of select="count(preceding-sibling::Original[not(Properties/Property[@name = 'hide']/@value = 'true')]) + 1"/>
								<xsl:if test="position() != last()">
									<xsl:text>.</xsl:text>
								</xsl:if>
							</xsl:for-each>
						</xsl:attribute>

						<xsl:attribute name="objType">
							<xsl:value-of select="Properties/Property[@name = 'SMC:objType']/@value"/>
						</xsl:attribute>
						<xsl:if test="Properties/Property[@name = 'hide']/@value = 'true'">
							<xsl:attribute name="HideInNavigation">true</xsl:attribute>
						</xsl:if>
						<Link.ShortDesc IDRef="{Properties/Property[@name = 'SMC:id']/@value}" MasterID="{@MasterID}" ServerID="{@ServerID}" objType="{Properties/Property[@name = 'SMC:objType']/@value}">
							<InfoChunk.Link>
								<xsl:attribute name="navigation-title">
									<xsl:value-of select="Properties/Property[@name = 'navigation-title']/@value"/>
								</xsl:attribute>
								<xsl:choose>								
									<xsl:when test="Properties/Property[@name = 'title']">
										<xsl:value-of select="Properties/Property[@name = 'title']/@value"/>
									</xsl:when>
									<xsl:otherwise>
										<xsl:value-of select="Properties/Property[@name = 'SMC:name']/@value"/>
									</xsl:otherwise>
								</xsl:choose>
							</InfoChunk.Link>
							<xsl:variable name="block-abstract-body" select="Properties/Property[@name = 'block-abstract-body']/@value"/>
							<xsl:variable name="block-abstract-icon" select="Properties/Property[@name = 'block-abstract-icon']/*"/>
							<xsl:if test="string-length($block-abstract-body) &gt; 0">
								<InfoPar>
									<xsl:value-of select="$block-abstract-body"/>
								</InfoPar>
							</xsl:if>
							<xsl:if test="$block-abstract-icon">
								<MediaContainer.Icon Source="{Properties/Property[@name = 'block-abstract-icon']/*/RefControl/substitute[1]/@subURL}">
									<xsl:for-each select="Properties/Property[@name = 'block-abstract-icon']/*/RefControl/substitute[1]">
										<xsl:attribute name="Source">
											<xsl:value-of select="@subURL"/>
										</xsl:attribute>
										<xsl:attribute name="serverURL">
											<xsl:value-of select="@serverURL"/>
										</xsl:attribute>
										<xsl:attribute name="height">
											<xsl:value-of select="@height"/>
										</xsl:attribute>
										<xsl:attribute name="width">
											<xsl:value-of select="@width"/>
										</xsl:attribute>
									</xsl:for-each>
									<xsl:apply-templates select="Properties/Property[@name = 'block-abstract-icon']/*"/>
								</MediaContainer.Icon>
							</xsl:if>
						</Link.ShortDesc>
					</InfoItem.Overview>
				</xsl:if>
			</xsl:for-each>
		</InfoItem.Overviewall>
	</xsl:template>

	<xsl:template match="generate.contents" name="generateContents">
		<xsl:variable name="genNode" select="current()"/>


		<xsl:choose>
			<xsl:when test="$Offline = 'Offline' or (/Start and /Start/section)">
				<xsl:variable name="currentLanguage" select="ancestor-or-self::*[(name() = 'section' or name() = 'Start') and @defaultLanguage][1]/@defaultLanguage"/>
				<xsl:variable name="type" select="@type"/>
				<xsl:variable name="includeSubsections" select="@includeSubsections = 'true' or $includeSubsectionsGlobal = 'true'"/>
				<xsl:choose>
					<xsl:when test="@from_root='true'">
						<xsl:for-each select="/section | /Start">
							<xsl:call-template name="DoGenerateContents">
								<xsl:with-param name="GenNode" select="$genNode"/>
								<xsl:with-param name="currentLanguage" select="$currentLanguage"/>
								<xsl:with-param name="type" select="$type"/>
								<xsl:with-param name="includeSubsections" select="$includeSubsections"/>
							</xsl:call-template>
						</xsl:for-each>
					</xsl:when>
					<xsl:when test="link.xref/link.xref.controller/RefControl[string-length(@webdavID) &gt; 0]">
						<xsl:variable name="objID" select="link.xref/link.xref.controller/RefControl/@webdavID"/>
						<xsl:for-each select="//section[@ID = $objID]">
							<xsl:call-template name="DoGenerateContents">
								<xsl:with-param name="GenNode" select="$genNode"/>
								<xsl:with-param name="currentLanguage" select="$currentLanguage"/>
								<xsl:with-param name="type" select="$type"/>
								<xsl:with-param name="includeSubsections" select="$includeSubsections"/>
							</xsl:call-template>
						</xsl:for-each>
					</xsl:when>

					<xsl:otherwise>

						<xsl:call-template name="DoGenerateContents">
							<xsl:with-param name="GenNode" select="$genNode"/>
							<xsl:with-param name="currentLanguage" select="$currentLanguage"/>
							<xsl:with-param name="type" select="$type"/>
							<xsl:with-param name="includeSubsections" select="$includeSubsections"/>
						</xsl:call-template>
					</xsl:otherwise>
				</xsl:choose>
			</xsl:when>
			<xsl:otherwise>
				<InfoItem.Overviewall>
					<xsl:copy-of select="@type
						| @contents_levels
						| @defaultLanguage[string-length(.) &gt; 0]"/>
					<xsl:apply-templates select="current()" mode="copyDiffAttributes"/>
					<xsl:apply-templates select="current()" mode="copyCharacterizationAttributes"/>
					<xsl:for-each select="Originals/Original">
						<InfoItem.Overview>
							<Link.ShortDesc IDRef="{Properties/Property[@name = 'SMC:id']/@value}">
								<InfoChunk.Link>
									<xsl:value-of select="Properties/Property[@name = 'title']/@value"/>
								</InfoChunk.Link>
								<xsl:variable name="block-abstract-body" select="Properties/Property[@name = 'block-abstract-body']/@value"/>
								<xsl:variable name="block-abstract-icon" select="Properties/Property[@name = 'block-abstract-icon']/*"/>
								<xsl:if test="string-length($block-abstract-body) &gt; 0">
									<InfoPar>
										<xsl:value-of select="$block-abstract-body"/>
									</InfoPar>
								</xsl:if>
								<xsl:if test="$block-abstract-icon">
									<MediaContainer.Icon>
										<xsl:apply-templates select="Properties/Property[@name = 'block-abstract-icon']/*"/>
									</MediaContainer.Icon>
								</xsl:if>
							</Link.ShortDesc>
						</InfoItem.Overview>
					</xsl:for-each>
					<xsl:if test="$preserveGenerateLink = 'true'">
						<xsl:apply-templates select="link.xref"/>
					</xsl:if>
				</InfoItem.Overviewall>
			</xsl:otherwise>
		</xsl:choose>
	</xsl:template>

	<xsl:template name="DoGenerateContents">
		<xsl:param name="GenNode"/>
		<xsl:param name="currentLanguage" select="ancestor-or-self::*[(name() = 'section' or name() = 'Start') and @defaultLanguage][1]/@defaultLanguage"/>
		<xsl:param name="type" select="@type"/>
		<xsl:param name="includeSubsections"/>

		<xsl:variable name="poslevel" select="count(ancestor-or-self::*[name() = 'section' or 
					  (name() = 'Start' and (headline.content or *[starts-with(name(), 'block.')]))
					  ])"/>

		<xsl:variable name="difflevel">
			<xsl:choose>
				<xsl:when test="string-length($GenNode/@contents_levels) &gt; 0">
					<xsl:value-of select="number($GenNode/@contents_levels)"/>
				</xsl:when>
				<xsl:when test="string-length($GenNode/@levels) &gt; 0">
					<xsl:value-of select="number($GenNode/@levels)"/>
				</xsl:when>
				<xsl:otherwise>
					<xsl:value-of select="3"/>
				</xsl:otherwise>
			</xsl:choose>
		</xsl:variable>

		<xsl:variable name="generateListBlocks">
			<xsl:choose>
				<xsl:when test="string-length($GENERATE_LIST_BLOCKS) &gt; 0">
					<xsl:value-of select="$GENERATE_LIST_BLOCKS"/>
				</xsl:when>
				<xsl:otherwise>
					<xsl:value-of select="/*/Format/ParamConfig/ElementGroup/Element[@name = 'label']/smc_properties/smc_pagination/@auto-number"/>
				</xsl:otherwise>
			</xsl:choose>
		</xsl:variable>

		<InfoItem.Overviewall currName = "{name()}">
		
			<xsl:copy-of select="$GenNode/@filter | $GenNode/@metafilter"/>

			<xsl:variable name="generateContentDisplayType">
				<xsl:call-template name="getFormatVariableValue">
					<xsl:with-param name="name" select="'GENERATE_CONTENT_DISPLAY_TYPE'"/>
					<xsl:with-param name="defaultValue">list</xsl:with-param>
				</xsl:call-template>
			</xsl:variable>

			<xsl:apply-templates select="$GenNode" mode="copyDiffAttributes"/>
			<xsl:apply-templates select="$GenNode" mode="copyCharacterizationAttributes"/>
			<xsl:variable name="generateContentHierarchical">
				<xsl:choose>
					<xsl:when test="string-length($GENERATE_HIERARCHICAL) &gt; 0">
						<xsl:value-of select="$GENERATE_HIERARCHICAL"/>
					</xsl:when>
					<xsl:when test="$generateContentDisplayType = 'table-hierarchical'">true</xsl:when>
					<xsl:otherwise>false</xsl:otherwise>
				</xsl:choose>
			</xsl:variable>

			<xsl:if test="string-length($type) &gt; 0">
				<xsl:attribute name="type">
					<xsl:value-of select="$type"/>
				</xsl:attribute>
			</xsl:if>
			
			<xsl:copy-of select="$GenNode/@contents_levels[string-length(.) &gt; 0]
				| $GenNode/@defaultLanguage[string-length(.) &gt; 0]"/>
					
			<xsl:for-each select="ancestor-or-self::*[name() = 'section' or name() = 'Start'][1]">
				<xsl:choose>
					<xsl:when test="$generateContentHierarchical = 'true'">
						<xsl:apply-templates select="current()[name() = 'section'] | current()[name() = 'Start']/section" mode="generate-overview-item">
							<xsl:with-param name="poslevel" select="$poslevel"/>
							<xsl:with-param name="difflevel" select="$difflevel"/>
							<xsl:with-param name="applyChildren" select="true()"/>
							<xsl:with-param name="applyBlockChildren" select="$generateListBlocks = 'true'"/>
							<xsl:with-param name="currentLanguage" select="$currentLanguage"/>
							<xsl:with-param name="type" select="$type"/>
						</xsl:apply-templates>
					</xsl:when>
					<xsl:when test="$generateListBlocks = 'true'">
						<xsl:apply-templates select="descendant::section[not(@Lexdoc= 'true') and (@defaultLanguage = $currentLanguage or $type = 'ContentsMultilanguage')]
								| descendant::*[starts-with(name(), 'block.') and name() != 'block.titlepage' and string-length(label) &gt; 0]" mode="generate-overview-item">
							<xsl:with-param name="poslevel" select="$poslevel"/>
							<xsl:with-param name="difflevel" select="$difflevel"/>
							<xsl:with-param name="currentLanguage" select="$currentLanguage"/>
							<xsl:with-param name="type" select="$type"/>
						</xsl:apply-templates>
					</xsl:when>
					<xsl:when test="$includeSubsections">
						<xsl:apply-templates select="descendant::section[not(@Lexdoc= 'true') and (@defaultLanguage = $currentLanguage or $type = 'ContentsMultilanguage')]
											 | descendant::section[not(@Lexdoc= 'true') and (@defaultLanguage = $currentLanguage or $type = 'ContentsMultilanguage')]//subsection[string-length(headline.content) &gt; 0]" mode="generate-overview-item">
							<xsl:with-param name="poslevel" select="$poslevel"/>
							<xsl:with-param name="difflevel" select="$difflevel"/>
							<xsl:with-param name="currentLanguage" select="$currentLanguage"/>
							<xsl:with-param name="type" select="$type"/>
						</xsl:apply-templates>
					</xsl:when>
					<xsl:otherwise>
						<xsl:apply-templates select="descendant::section[not(@Lexdoc= 'true') and not(parent::include.document) and (@defaultLanguage = $currentLanguage or $type = 'ContentsMultilanguage')]" mode="generate-overview-item">
							<xsl:with-param name="poslevel" select="$poslevel"/>
							<xsl:with-param name="difflevel" select="$difflevel"/>
							<xsl:with-param name="currentLanguage" select="$currentLanguage"/>
							<xsl:with-param name="type" select="$type"/>
						</xsl:apply-templates>
					</xsl:otherwise>
				</xsl:choose>
			</xsl:for-each>
		</InfoItem.Overviewall>
	</xsl:template>

	<xsl:template match="section | Start | subsection" mode="generate-overview-item">
		<xsl:param name="poslevel"/>
		<xsl:param name="difflevel"/>
		<xsl:param name="currentLanguage"/>
		<xsl:param name="type"/>
		<xsl:param name="applyChildren" select="false()"/>
		<xsl:param name="applyBlockChildren" select="false()"/>

		<xsl:variable name="abslevel" select="count(ancestor::*[
								  name() = 'section' or 
								  (name() = 'Start' and (headline.content or *[starts-with(name(), 'block.')]))
								  ])"/>
		<xsl:if test="$abslevel - $poslevel &lt; $difflevel">
			<InfoItem.Overview abs_level="{$abslevel}" rel_level="{$abslevel - $poslevel}" pos="{$poslevel}"  diff="{$difflevel}" >
				<xsl:copy-of select="WebInfo/@HideInNavigation | @objType | @type | @inheritedCharTitles"/>
				<xsl:if test="name() = 'subsection'">
					<xsl:copy-of select="ancestor::section[1]/WebInfo/@HideInNavigation"/>
				</xsl:if>
				<Link.ShortDesc IDRef="{@ID}">
					<xsl:if test="name() = 'subsection'">
						<xsl:attribute name="fileID">
							<xsl:value-of select="ancestor::section[1]/@ID"/>
						</xsl:attribute>
						<xsl:attribute name="isSubSection"/>
					</xsl:if>
					<xsl:variable name="headline">
						<xsl:apply-templates select="headline.content" mode="printText"/>
					</xsl:variable>
					<InfoChunk.Link headline="{$headline}">
						<xsl:choose>
							<xsl:when test="string-length(headline.content) &gt; 0">
								<!--<xsl:apply-templates select="headline.content/node()[not(name() = 'index.entry' and @notVisible = 'true')]"/>-->
								<xsl:apply-templates select="headline.content" mode="innercontent"/>
							</xsl:when>
							<xsl:when test="$allowTitleFallback = 'true'">
								<xsl:value-of select ="@Title"/>
							</xsl:when>
						</xsl:choose>
					</InfoChunk.Link>
					<xsl:for-each select="block.abstract">
						<InfoPar>
							<xsl:apply-templates select="content/par/node()"/>
						</InfoPar>
						<xsl:for-each select="media.theme/RefControl/substitute[1]">
							<MediaContainer.Icon serverURL="{@serverURL}" height="{@height}" width="{@width}">
								<xsl:attribute name="Source">
									<xsl:choose>
										<xsl:when test="starts-with(@subURL, '/')">
											<xsl:value-of select="concat('media', @subURL)"/>
										</xsl:when>
										<xsl:otherwise>
											<xsl:value-of select="concat('media/', @subURL)"/>
										</xsl:otherwise>
									</xsl:choose>
								</xsl:attribute>
							</MediaContainer.Icon>
						</xsl:for-each>
					</xsl:for-each>
				</Link.ShortDesc>

				<xsl:if test="$applyBlockChildren">
					<xsl:apply-templates select="*[starts-with(name(), 'block.') and name() != 'block.titlepage' and string-length(label) &gt; 0]" mode="generate-overview-item">
						<xsl:with-param name="poslevel" select="$poslevel"/>
						<xsl:with-param name="difflevel" select="$difflevel"/>
						<xsl:with-param name="applyChildren" select="$applyChildren"/>
						<xsl:with-param name="applyBlockChildren" select="$applyBlockChildren"/>
						<xsl:with-param name="currentLanguage" select="$currentLanguage"/>
						<xsl:with-param name="type" select="$type"/>
					</xsl:apply-templates>
				</xsl:if>

				<xsl:if test="$applyChildren">
					<xsl:apply-templates select="section[not(@Lexdoc= 'true') and (@defaultLanguage = $currentLanguage or $type = 'ContentsMultilanguage')]" mode="generate-overview-item">
						<xsl:with-param name="poslevel" select="$poslevel"/>
						<xsl:with-param name="difflevel" select="$difflevel"/>
						<xsl:with-param name="applyChildren" select="$applyChildren"/>
						<xsl:with-param name="applyBlockChildren" select="$applyBlockChildren"/>
						<xsl:with-param name="currentLanguage" select="$currentLanguage"/>
						<xsl:with-param name="type" select="$type"/>
					</xsl:apply-templates>
				</xsl:if>

			</InfoItem.Overview>
		</xsl:if>
	</xsl:template>


	<xsl:template match="*" mode="innercontent">
		<xsl:apply-templates mode="innercontent"/>
	</xsl:template>	 

	<xsl:template match="dialog | invalid | italics | no.linebreak | linebreak | inverted | subscript | superscript | symbol | symb | formula | include.text" mode="innercontent">
		<xsl:apply-templates select="current()"/>
	</xsl:template>

	<xsl:template match="index.entry[@notVisible = 'true'] | notes | footnote" mode="innercontent"/>

	<xsl:template match="*[starts-with(name(), 'block.') and name() != 'block.titlepage' and string-length(label) &gt; 0]" mode="generate-overview-item">
		<xsl:param name="poslevel"/>
		<xsl:param name="difflevel"/>
		<xsl:param name="type"/>

		<xsl:variable name="abslevel" select="count(ancestor::*[
								  name() = 'section' or 
								  (name() = 'Start' and (headline.content or *[starts-with(name(), 'block.')]))
								  ])"/>
		<xsl:if test="$abslevel - $poslevel &lt; $difflevel">
			<InfoItem.Overview abs_level="{$abslevel}" rel_level="{$abslevel - $poslevel}" pos="{$poslevel}"  diff="{$difflevel}" >
				<xsl:choose>
					<xsl:when test="starts-with(name(), 'block.')">
						<xsl:for-each select="ancestor::*[name() = 'section' or name() = 'Start'][1]">
							<xsl:copy-of select="WebInfo/@HideInNavigation | @objType | @type"/>
						</xsl:for-each>
						<xsl:attribute name="isBlock">true</xsl:attribute>
					</xsl:when>
					<xsl:otherwise>
						<xsl:copy-of select="WebInfo/@HideInNavigation | @objType | @type"/>
					</xsl:otherwise>
				</xsl:choose>
				<Link.ShortDesc IDRef="{@ID}">
					<xsl:variable name="headline">
						<xsl:choose>
							<xsl:when test="name() = 'section' or name() = 'Start'">
								<xsl:apply-templates select="headline.content" mode="printText"/>
							</xsl:when>
							<xsl:otherwise>
								<xsl:apply-templates select="label" mode="printText"/>
							</xsl:otherwise>
						</xsl:choose>
					</xsl:variable>
					<InfoChunk.Link headline="{$headline}">
						<xsl:choose>
							<xsl:when test="name() = 'section' or name() = 'Start'">
								<!--<xsl:apply-templates select="headline.content/node()[not(name() = 'index.entry' and @notVisible = 'true')]"/>-->
								<xsl:value-of select="$headline"/>
							</xsl:when>
							<xsl:otherwise>
								<!--<xsl:apply-templates select="label/node()"/>-->
								<xsl:value-of select="$headline"/>
							</xsl:otherwise>
						</xsl:choose>
					</InfoChunk.Link>
					<xsl:for-each select="block.abstract">
						<InfoPar>
							<xsl:apply-templates select="content/par/node()"/>
						</InfoPar>
						<xsl:for-each select="media.theme/RefControl/substitute[1]">
							<MediaContainer.Icon serverURL="{@serverURL}" height="{@height}" width="{@width}">
								<xsl:attribute name="Source">
									<xsl:choose>
										<xsl:when test="starts-with(@subURL, '/')">
											<xsl:value-of select="concat('media', @subURL)"/>
										</xsl:when>
										<xsl:otherwise>
											<xsl:value-of select="concat('media/', @subURL)"/>
										</xsl:otherwise>
									</xsl:choose>
								</xsl:attribute>
							</MediaContainer.Icon>
						</xsl:for-each>
					</xsl:for-each>
				</Link.ShortDesc>
			</InfoItem.Overview>
		</xsl:if>
	</xsl:template>

	<xsl:template match="generate.glossary" name="generateGlossary">
		<xsl:variable name="lexSections" select="//section[@Lexdoc = 'true']"/>
		<xsl:if test="count($lexSections) &gt; 0">
			<table typ="" glossary="true">
				<xsl:apply-templates select="current()" mode="copyDiffAttributes"/>
				<xsl:apply-templates select="current()" mode="copyCharacterizationAttributes"/>
				<title></title>
				<colspec colname="spycolgen1" colnum="1" colwidth="30" />
				<colspec colname="spycolgen2" colnum="2" colwidth="70" />
				<tableStandard>
					<xsl:for-each select="$lexSections">
						<xsl:sort select="headline.content" order="ascending" data-type="text" />
						<tableRow>
							<tableCell valign="top">
								<InfoPar>
									<InfoChunk.Important ID="{@ID}">
										<xsl:apply-templates select="headline.content" mode="printText"/>
									</InfoChunk.Important>
								</InfoPar>
							</tableCell>
							<tableCell notApplyTableFontSize="true">
								<xsl:apply-templates select="*[name() != 'headline.content']"/>
							</tableCell>
						</tableRow>
					</xsl:for-each>
				</tableStandard>
			</table>
			<TableDesc Typ="" glossary="true">
				<TableColSpec width="30" />
				<TableColSpec width="70" />
			</TableDesc>
		</xsl:if>
	</xsl:template>

	<xsl:template name="generateTableListing">
		<xsl:variable name="tables" select="//Table[TableDesc[@type != 'MenuInst' and @type != 'Nolines']
				and (table/title[string-length(.) &gt; 0 and . != 'Title'] or parent::*[name() = 'content' or name() = 'include.table']/ancestor::include[1]/title[string-length(.) &gt; 0])]"/>
		<xsl:if test="count($tables) &gt; 0">
			<table.NoBorder typ="" target = "table.listing">
				<xsl:apply-templates select="current()" mode="copyDiffAttributes"/>
				<xsl:apply-templates select="current()" mode="copyCharacterizationAttributes"/>
				<title></title>
				<colspec colname="spycolgen1" colnum="1" colwidth="{$tableListingWidth}" />
				<colspec colname="spycolgen2" colnum="2">
					<xsl:attribute name="colwidth">
						<xsl:choose>
							<xsl:when test="string(number($tableListingWidth)) != 'NaN'">
								<xsl:value-of select="100 - $tableListingWidth"/>
							</xsl:when>
							<xsl:otherwise>*</xsl:otherwise>
						</xsl:choose>
					</xsl:attribute>
				</colspec>
				<tableStandard>
					<xsl:for-each select="$tables">
						<tableRow>
							<tableCell notApplyTableFontSize="true">
								<InfoPar format="table.listing">
									<generate.listing.nr type="Table" nr="{position()}" RefID="{@ID}"/>
								</InfoPar>
							</tableCell>
							<tableCell notApplyTableFontSize="true">
								<InfoPar format="table.listing">
									<link.element fileID="{ancestor::*[name() = 'section' or name() = 'Start'][1]/@ID}" RefID="{@ID}" origin="Listing">
										<InfoChunk.Link>
											<xsl:choose>
												<xsl:when test="parent::*[name() = 'content' or name() = 'include.table' or name() = 'include.metatable' or name() = 'include.technicalData']/ancestor::include[1]/title[string-length(.) &gt; 0]">
													<xsl:apply-templates select="parent::*[name() = 'content' or name() = 'include.table' or name() = 'include.metatable' or name() = 'include.technicalData']/ancestor::include[1]/title[string-length(.) &gt; 0]/node()" mode="listing-title"/>
												</xsl:when>
												<xsl:otherwise>
													<xsl:apply-templates select="table/title/node()" mode="listing-title"/>
												</xsl:otherwise>
											</xsl:choose>
										</InfoChunk.Link>
									</link.element>
								</InfoPar>
							</tableCell>
						</tableRow>
					</xsl:for-each>
				</tableStandard>
			</table.NoBorder>
			<TableDesc Typ="Nolines" glossary="true">
				<TableColSpec width="{$tableListingWidth}" />
				<TableColSpec>
					<xsl:attribute name="width">
						<xsl:choose>
							<xsl:when test="string(number($tableListingWidth)) != 'NaN'">
								<xsl:value-of select="100 - $tableListingWidth"/>
							</xsl:when>
							<xsl:otherwise>*</xsl:otherwise>
						</xsl:choose>
					</xsl:attribute>
				</TableColSpec>
			</TableDesc>
		</xsl:if>
	</xsl:template>

	<xsl:template match="*" mode="listing-title">
		<xsl:apply-templates select="current()"/>
	</xsl:template>

	<xsl:template match="index.entry[@notVisible = 'true'] | notes" mode="listing-title"/>

	<xsl:template name="generateImgListing">
		<xsl:variable name="medias" select="//media/media.theme[1][../media.caption != '' or string-length(RefControl/@defaultTitle) &gt; 0]"/>
		<xsl:if test="count($medias) &gt; 0">
			<table.NoBorder typ="" target = "image.listing">
				<xsl:apply-templates select="current()" mode="copyDiffAttributes"/>
				<xsl:apply-templates select="current()" mode="copyCharacterizationAttributes"/>
				<title></title>
				<colspec colname="spycolgen1" colnum="1" colwidth="{$imageListingWidth}" />
				<colspec colname="spycolgen2" colnum="2">
					<xsl:attribute name="colwidth">
						<xsl:choose>
							<xsl:when test="string(number($imageListingWidth)) != 'NaN'">
								<xsl:value-of select="100 - $imageListingWidth"/>
							</xsl:when>
							<xsl:otherwise>*</xsl:otherwise>
						</xsl:choose>
					</xsl:attribute>
				</colspec>
				<tableStandard>
					<xsl:for-each select="$medias">
						<tableRow>
							<tableCell notApplyTableFontSize="true">
								<InfoPar format="image.listing">
									<generate.listing.nr type="Image" nr="{position()}" RefID="{@ID}"/>
								</InfoPar>
							</tableCell>
							<tableCell notApplyTableFontSize="true">
								<InfoPar format="image.listing">
									<link.element fileID="{ancestor::*[name() = 'section' or name() = 'Start'][1]/@ID}" RefID="{@ID}" origin="Listing">
										<InfoChunk.Link>
											<xsl:choose>
												<xsl:when test="string-length(../media.caption) &gt; 0">
													<xsl:apply-templates select="../media.caption/node()" mode="listing-title"/>
												</xsl:when>
												<xsl:when test="string-length(legendcontent/*/SubTitle) &gt; 0">
													<xsl:apply-templates select="legendcontent/*/SubTitle" mode="listing-title"/>
												</xsl:when>
												<xsl:when test="string-length(RefControl/@defaultTitle) &gt; 0">
													<xsl:value-of select="RefControl/@defaultTitle"/>
												</xsl:when>
												<xsl:otherwise>
													<xsl:text>[No media caption]</xsl:text>
												</xsl:otherwise>
											</xsl:choose>
										</InfoChunk.Link>
									</link.element>
								</InfoPar>
							</tableCell>
						</tableRow>
					</xsl:for-each>
				</tableStandard>
			</table.NoBorder>
			<TableDesc Typ="Nolines" glossary="true">
				<TableColSpec width="{$imageListingWidth}" />
				<TableColSpec>
					<xsl:attribute name="width">
						<xsl:choose>
							<xsl:when test="string(number($imageListingWidth)) != 'NaN'">
								<xsl:value-of select="100 - $imageListingWidth"/>
							</xsl:when>
							<xsl:otherwise>*</xsl:otherwise>
						</xsl:choose>
					</xsl:attribute>
				</TableColSpec>
			</TableDesc>
		</xsl:if>
	</xsl:template>

	

	
	
	
</xsl:stylesheet>
