<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform">

	<xsl:key name="ObjectKey" match="Object/RefControl" use="@webdavID"/>
	<xsl:key name="IncludeKey" match="*[starts-with(name(), 'include.')]/RefControl" use="@webdavID"/>
	
	<xsl:param name="language"/>
	<xsl:param name="PRESERVE_BOOK_CONTAINER">false</xsl:param>
	<xsl:param name="useBranchBasedContext"/>
	<xsl:param name="useClosestLinkTarget">
		<xsl:if test="$useBranchBasedContext = 'true' and not(/*/Format/ParamConfig/VariableDefinitions/VariableDefinition[@name = 'PDF_OUTPUT_NAMED_DESTINATIONS' and @textValue = 'true'])">true</xsl:if>
	</xsl:param>
	<xsl:param name="brokerServerURL"/>
	<xsl:param name="generateUniqueLinkElementTargets"/>

	<xsl:param name="writeNewRootID" select="'true'"/>
	<xsl:param name="image-type" select="'halftone-with-highlighting'" />
	<xsl:param name="marginalia" select="'marginalia-no'" />
	<xsl:param name="basePath" select="'.'" />

	<xsl:variable name="hasSingleRoot" select="count(Structure/Branch[not(@isGlossary)]) = 1"/>
	<xsl:variable name="oldRootID" select="Structure/Branch[not(@isGlossary)]/Object/RefControl/@webdavID"/>

	<xsl:variable name="newRootID">
		<xsl:choose>
			<xsl:when test="$writeNewRootID='true'">index</xsl:when>
			<xsl:otherwise>
				<xsl:value-of select="descendant::RefControl[@objType='doc'][1]/@webdavID"/>
			</xsl:otherwise>	
		</xsl:choose>	
	
	
	</xsl:variable>

	<xsl:template name="setLexdocAttribute">
		<xsl:if test="ancestor::Branch[@isGlossary]">
			<xsl:attribute name="Lexdoc">true</xsl:attribute>
		</xsl:if>
	</xsl:template>

	<xsl:template name="writeFirstBranch">
		<xsl:param name="documentID"/>
		<xsl:variable name="hcElem" select="Branch[not(@isGlossary)]/Object/RefControl/MMFramework.Container/section/headline.content"/>
		<xsl:variable name="hc">
			<xsl:for-each select="$hcElem/text() | $hcElem/*[not(name() = 'index.entry' and @notVisible = 'true') and not(name() = 'notes')]">
				<xsl:value-of select="."/>
			</xsl:for-each>
		</xsl:variable>
		<xsl:attribute name="Title">
			<xsl:choose>
				<xsl:when test="string-length($hc) &gt; 0">
					<xsl:value-of select="normalize-space($hc)"/>
				</xsl:when>
				<xsl:otherwise>
					<xsl:value-of select="Branch[not(@isGlossary)]/Object/RefControl/@TargetTitle"/>
				</xsl:otherwise>
			</xsl:choose>
		</xsl:attribute>
		<xsl:for-each select="Branch[not(@isGlossary)]/Object/RefControl/MMFramework.Container/section">
			<xsl:call-template name="applyAttributes"/>
			<xsl:call-template name="setLexdocAttribute"/>
			<xsl:copy-of select="ancestor::Object[1]/@*[name() = 'translate' or name() = 'Changed' or name() = 'guid']"/>
			<xsl:copy-of select="ancestor::RefControl[1]/@status-diff | ancestor::RefControl[1]/@versionLabel"/>
			<xsl:apply-templates select="../WebInfo"/>
			<xsl:apply-templates select="current()">
				<xsl:with-param name="documentID" select="$documentID"/>
			</xsl:apply-templates>
			<xsl:apply-templates select="../Format"/>
			<xsl:apply-templates select="../following-sibling::Properties[1] | Properties"/>
		</xsl:for-each>
		<xsl:apply-templates select="Branch[not(@isGlossary)]/Branch"/>
		<xsl:apply-templates select="Branch[@isGlossary]"/>
	</xsl:template>

	<xsl:template match="Structure">
		<Start attachments="{@attachments}" ID="{$newRootID}" origID="{Branch[1]/Object/RefControl/@webdavID}" defaultLanguage="{$language}">
			<!-- characterizationFilterApplied is used by ApplyCharacterizationFilter.java -->
			<xsl:copy-of select="@bookURL | @hasPartialContent | Branch/Object/RefControl/MMFramework.Container/@styleID | @targetProductionPath | @objID | @dumpnames | @dumps | @characterizationFilterApplied
						 | @versionLabel | @objType"/>
			<xsl:attribute name = "version">
				<xsl:value-of select = "/Structure/Branch[1]/Object[1]/RefControl/@versionLabel"/>
			</xsl:attribute>
			<xsl:if test="@versionLabel">
				<!-- needs to be set again, because its overwritten when there is only one root node. -->
				<xsl:attribute name="bookVersionLabel">
					<xsl:value-of select="@versionLabel"/>
				</xsl:attribute>
			</xsl:if>
			<xsl:choose>
				<xsl:when test="not($PRESERVE_BOOK_CONTAINER='true') and (count(Branch[not(@isGlossary)]) = 1 and count(Branch[not(@isGlossary)]/Object/RefControl/IncludedObject/Structure/Branch[not(@isGlossary)]) = 1)">
					<xsl:for-each select="Branch[not(@isGlossary)]/Object/RefControl/IncludedObject/Structure">
						<xsl:call-template name="writeFirstBranch">
							<xsl:with-param name="documentID" select="$newRootID"/>
						</xsl:call-template>
					</xsl:for-each>
					<xsl:apply-templates select="Branch[@isGlossary]"/>
				</xsl:when>
				<xsl:when test="not($PRESERVE_BOOK_CONTAINER='true') and (count(Branch[not(@isGlossary)]) = 1 and Branch[not(@isGlossary)]/Object/RefControl/MMFramework.Container/section)">
					<xsl:call-template name="writeFirstBranch">
						<xsl:with-param name="documentID" select="$newRootID"/>
					</xsl:call-template>
				</xsl:when>
				<xsl:otherwise>
					<xsl:apply-templates select="Branch"/>
				</xsl:otherwise>
			</xsl:choose>
			<xsl:apply-templates select="Format | Strings | Navigation | ContextProperties"/>
			<xsl:apply-templates select="Properties" mode="structureProperties"/>
		</Start>
	</xsl:template>

	<xsl:template match="Properties" mode="structureProperties">
		<StructureProperties>
			<xsl:call-template name="applyAttributes"/>
			<xsl:apply-templates mode="structureProperties"/>
		</StructureProperties>
	</xsl:template>

	<xsl:template match="Property" mode="structureProperties">
		<StructureProperty>
			<xsl:call-template name="applyAttributes"/>
			<xsl:apply-templates/>
		</StructureProperty>
	</xsl:template>

	<xsl:template name="correctRootReferences">
		<xsl:if test="$hasSingleRoot and $oldRootID = @webdavID">
			<xsl:attribute name="webdavID">
				<xsl:value-of select="$newRootID"/>
			</xsl:attribute>
		</xsl:if>
	</xsl:template>

	<xsl:template match="RefControl">
		<xsl:copy>
			<xsl:call-template name="applyAttributes"/>
			<xsl:call-template name="correctRootReferences"/>
			<xsl:apply-templates/>
		</xsl:copy>
	</xsl:template>

	<xsl:template match="Branch">
		<xsl:choose>
			<xsl:when test="Object">
				<xsl:apply-templates select="Object"/>
			</xsl:when>
			<xsl:when test="ObjectResolved">
				<xsl:apply-templates select="ObjectResolved"/>
			</xsl:when>
			<xsl:otherwise>
				<xsl:apply-templates select="Branch"/>
			</xsl:otherwise>
		</xsl:choose>
	</xsl:template>

	<xsl:template match="Object | ObjectResolved">
		<xsl:choose>
			<xsl:when test="RefControl/MMFramework.Container">
				<xsl:apply-templates select="RefControl/MMFramework.Container"/>
			</xsl:when>
			<xsl:otherwise>
				<xsl:apply-templates select="parent::Branch/Branch"/>
			</xsl:otherwise>
		</xsl:choose>
	</xsl:template>
	
	<xsl:template match="content/media/media.theme|content/Table//media/media.theme">
		<media.theme addMe="Fixed" button="Fixed" delButton="Fixed" filter="" firstTime="-" formatRef="" markMe="" updateAction="update">
			<RefControl PickerElement="media.theme" defaultTitle="" language="de">
				<File>
					<xsl:attribute name="isTypeOfImage" select="'true'" />
					<xsl:attribute name="itemName" select="'original'" />
					<xsl:attribute name="language" select="'de'" />
					<xsl:attribute name="basePath" select="$basePath" />
					<xsl:attribute name="url" select="concat($image-type, '.png')" />
					<MetaProperties>
						<MetaProperty name='SMCIMG:height' value="473" />
						<MetaProperty name='SMCIMG:width' value="591" />
					</MetaProperties>
				</File>
			</RefControl>
		</media.theme>
	</xsl:template>
	
	<xsl:template match="Object[RefControl[@objType = 'file']]">
		<section fileSectionExtension="{RefControl/@extension}">
			<xsl:variable name="pre_ID">
				<xsl:choose>
					<xsl:when test="string-length(parent::RefControl/@defaultLanguage) &gt; 0">
						<xsl:value-of select="concat(parent::RefControl/@webdavID, '_', parent::RefControl/@defaultLanguage)"/>
					</xsl:when>
					<xsl:otherwise>
						<xsl:value-of select="parent::RefControl/@webdavID"/>
					</xsl:otherwise>
				</xsl:choose>
			</xsl:variable>
			<xsl:attribute name="ID">
				<xsl:choose>
					<xsl:when test="string-length($pre_ID) = 0">
						<xsl:value-of select="generate-id()"/>
					</xsl:when>
					<xsl:when test="parent::RefControl/preceding::Object[RefControl[@webdavID = $pre_ID]]">
						<xsl:value-of select="concat($pre_ID, '_', generate-id())"/>
					</xsl:when>
					<xsl:otherwise>
						<xsl:value-of select="$pre_ID"/>
					</xsl:otherwise>
				</xsl:choose>
			</xsl:attribute>
			<xsl:copy-of select="parent::RefControl/@versionLabel | ancestor::Branch[1]/@*[name() = 'filter' or name() = 'metafilter']"/>
			<xsl:choose>
				<xsl:when test="string-length(parent::RefControl/@defaultLanguage) &gt; 0">
					<xsl:copy-of select="parent::RefControl/@defaultLanguage"/>
				</xsl:when>
				<xsl:otherwise>
					<xsl:attribute name="defaultLanguage">
						<xsl:value-of select="$language"/>
					</xsl:attribute>
				</xsl:otherwise>
			</xsl:choose>

			<xsl:variable name="title">
				<xsl:choose>
					<xsl:when test="string-length(RefControl/Properties/Property[@name = 'SMCDOCINFO:title']/@value) &gt; 0">
						<xsl:value-of select="RefControl/Properties/Property[@name = 'SMCDOCINFO:title']/@value"/>
					</xsl:when>
					<xsl:otherwise>
						<xsl:value-of select="@Linktext"/>
					</xsl:otherwise>
				</xsl:choose>
			</xsl:variable>

			<xsl:attribute name="Title">
				<xsl:value-of select="$title"/>
			</xsl:attribute>

			<xsl:variable name="hideInNav">
				<xsl:choose>
					<xsl:when test="RefControl/Properties/Property[@name = 'SMCDOCINFO:hideinnavigation']/@value = 'true'">true</xsl:when>
					<xsl:otherwise>false</xsl:otherwise>
				</xsl:choose>
			</xsl:variable>

			<WebInfo HideInNavigation="{$hideInNav}" SystemName="" visible="false" visibleButton="Fixed">
				<MetaInfo Description="" Lang="" Name=""/>
			</WebInfo>
			<headline.content ID="{generate-id()}">
				<xsl:value-of select="$title"/>
			</headline.content>
			<block.description ID="{generate-id(RefControl)}">
				<TypControl type=""/>
				<content>
					<par>
						<link.file>
							<xsl:for-each select="RefControl">
								<xsl:copy>
									<xsl:call-template name="applyAttributes"/>
									<xsl:attribute name="PickerElement">link.file</xsl:attribute>
								</xsl:copy>
							</xsl:for-each>
						</link.file>
					</par>
				</content>
			</block.description>
			<xsl:apply-templates select="RefControl/Properties"/>
		</section>
	</xsl:template>

	<xsl:template match="Object[RefControl[@objType = 'mediaset']]">
		<section fileSectionExtension="{RefControl/substitute/@fileType}">
			<xsl:variable name="pre_ID">
				<xsl:choose>
					<xsl:when test="string-length(RefControl/@defaultLanguage) &gt; 0">
						<xsl:value-of select="concat(RefControl/@webdavID, '_', RefControl/@defaultLanguage)"/>
					</xsl:when>
					<xsl:otherwise>
						<xsl:value-of select="RefControl/@webdavID"/>
					</xsl:otherwise>
				</xsl:choose>
			</xsl:variable>
			<xsl:attribute name="ID">
				<xsl:choose>
					<xsl:when test="string-length($pre_ID) = 0">
						<xsl:value-of select="generate-id()"/>
					</xsl:when>
					<xsl:when test="RefControl/preceding::Object[RefControl[@webdavID = $pre_ID]]">
						<xsl:value-of select="concat($pre_ID, '_', generate-id())"/>
					</xsl:when>
					<xsl:otherwise>
						<xsl:value-of select="$pre_ID"/>
					</xsl:otherwise>
				</xsl:choose>
			</xsl:attribute>
			<xsl:copy-of select="RefControl/@versionLabel | ancestor::Branch[1]/@*[name() = 'filter' or name() = 'metafilter']"/>
			<xsl:choose>
				<xsl:when test="string-length(RefControl/@defaultLanguage) &gt; 0">
					<xsl:copy-of select="RefControl/@defaultLanguage"/>
				</xsl:when>
				<xsl:otherwise>
					<xsl:attribute name="defaultLanguage">
						<xsl:value-of select="$language"/>
					</xsl:attribute>
				</xsl:otherwise>
			</xsl:choose>

			<xsl:variable name="legendTitle" select=".//legendcontent/Animation/SubTitle"/>
						  

			<xsl:attribute name="Title">
				<xsl:choose>
					<xsl:when test="string-length($legendTitle) &gt; 0">
						<xsl:value-of select="$legendTitle"/>
					</xsl:when>
					<xsl:otherwise>
						<xsl:value-of select="RefControl/@TargetTitle"/>
					</xsl:otherwise>
				</xsl:choose>
			</xsl:attribute>

			<xsl:variable name="hideInNav">
				<xsl:choose>
					<xsl:when test="RefControl/Properties/Property[@name = 'SMCDOCINFO:hideinnavigation']/@value = 'true'">true</xsl:when>
					<xsl:otherwise>false</xsl:otherwise>
				</xsl:choose>
			</xsl:variable>

			<WebInfo HideInNavigation="{$hideInNav}" SystemName="" visible="false" visibleButton="Fixed">
				<MetaInfo Description="" Lang="" Name=""/>
			</WebInfo>
			<headline.content ID="{generate-id()}">
				<xsl:choose>
					<xsl:when test="string-length($legendTitle) &gt; 0">
						<xsl:apply-templates select="$legendTitle/node()"/>
					</xsl:when>
					<xsl:otherwise>
						<xsl:value-of select="@TargetTitle"/>
					</xsl:otherwise>
				</xsl:choose>
			</headline.content>
			<block.description ID="{generate-id(RefControl)}">
				<TypControl type=""/>
				<content>
					<media>
						<media.theme>
							<xsl:for-each select="RefControl">
								<xsl:copy>
									<xsl:call-template name="applyAttributes"/>
									<xsl:attribute name="PickerElement">media.theme</xsl:attribute>
									<xsl:apply-templates select="substitute"/>
								</xsl:copy>
							</xsl:for-each>
						</media.theme>
					</media>
				</content>
			</block.description>
			<xsl:apply-templates select="RefControl/Properties"/>
		</section>
	</xsl:template>

	<xsl:template match="Object[RefControl[@objType = 'urilink']]">
		<section>
			<xsl:copy-of select="RefControl/@objType"/>
			<xsl:apply-templates select="RefControl/URIDefinition"/>
		</section>
	</xsl:template>

	<xsl:template match="include.block">
		<xsl:param name="documentID"/>
		<include.block>
			<xsl:copy-of select="@translate | @Changed | RefControl/@versionLabel | @filter | @metafilter | RefControl/@defaultLanguage[string-length(.) &gt; 0]"/>
			<xsl:apply-templates select="block/*[starts-with(name(), 'block.') or name() = 'include.block'] | *[starts-with(name(), 'block.')] | include.block">
				<xsl:with-param name="documentID">
					<xsl:choose>
						<xsl:when test="string-length(RefControl/@webdavID) &gt; 0">
							<xsl:value-of select="RefControl/@webdavID"/>
						</xsl:when>
						<xsl:otherwise>
							<xsl:value-of select="$documentID"/>
						</xsl:otherwise>
					</xsl:choose>
				</xsl:with-param>
			</xsl:apply-templates>
		</include.block>
	</xsl:template>

	<xsl:template match="include.document">
		<xsl:param name="documentID"/>
		<include.document>
			<xsl:copy-of select="@*"/>
			<xsl:apply-templates select="RefControl/*">
				<xsl:with-param name="documentID">
					<xsl:choose>
						<xsl:when test="string-length(RefControl/@webdavID) &gt; 0">
							<xsl:value-of select="RefControl/@webdavID"/>
						</xsl:when>
						<xsl:otherwise>
							<xsl:value-of select="$documentID"/>
						</xsl:otherwise>
					</xsl:choose>
				</xsl:with-param>
			</xsl:apply-templates>
		</include.document>
	</xsl:template>

	<xsl:template match="*[starts-with(name(), 'include.') and string-length(RefControl/@webdavID) &gt; 0
				  and name() != 'include.block' and name() != 'include.document' and name() != 'include.content']">
		<xsl:param name="documentID"/>
		<xsl:copy>
			<xsl:copy-of select="@*"/>
			<xsl:apply-templates>
				<xsl:with-param name="documentID">
					<xsl:choose>
						<xsl:when test="string-length(RefControl/@webdavID) &gt; 0">
							<xsl:value-of select="RefControl/@webdavID"/>
						</xsl:when>
						<xsl:otherwise>
							<xsl:value-of select="$documentID"/>
						</xsl:otherwise>
					</xsl:choose>
				</xsl:with-param>
			</xsl:apply-templates>
		</xsl:copy>
	</xsl:template>

	<xsl:template match="*[starts-with(name(), 'block.')]">
		<xsl:param name="documentID"/>
		<xsl:copy>
			<xsl:call-template name="applyAttributes"/>
			<xsl:apply-templates select="current()" mode="setElemId">
				<xsl:with-param name="documentID" select="$documentID"/>
			</xsl:apply-templates>
			<xsl:copy-of select="parent::block/parent::include.block[not(@Changed = 'UPDATED')]/@*[name() = 'translate' or name() = 'Changed'] | parent::blocks/@Changed"/>
			<xsl:choose>
				<xsl:when test="ancestor::*[name()='section']/@type != 'GanzeBreite' and local-name() = 'block.description'">
					<xsl:apply-templates select="TypControl" />
					<xsl:choose>
						<xsl:when test="$marginalia='marginalia-yes'">
							<Table ID="N1009D" addTableButton="" delButton="Fixed" dummy="" filter="" firstTime="-" insertAfterButton="Fixed" insertBeforeButton="Fixed">
								<table>
									<title>Title</title>
									<tgroup cols="2">
										<colspec colname="colgen1" colnum="1" colwidth="30*"/>
										<colspec colname="colgen2" colnum="2" colwidth="70*"/>
										<tbody>
											<row>
												<entry>
													<par>
														<xsl:value-of select="label" />
													</par>
												</entry>
												<entry>
													<xsl:for-each select="*[not(local-name() = 'label') and not(local-name() = 'TypControl')]">
														<xsl:apply-templates select="current()" />
													</xsl:for-each>
												</entry>
											</row>
										</tbody>
									</tgroup>
								</table>
								<TableDesc autoModifCellAlign="" autoModifCellVAlign="" delButton="Fixed" fontSizeModifier="0" headColumns="" headRows="0" layout="" notAutoNumber="false" type="Nolines" visible="true" visibleButton="Fixed">
									<TableColSpec addMe="Fixed" colnum="1" delButton="Fixed" width="30"/>
									<TableColSpec addMe="Fixed" colnum="2" delButton="Fixed" width="70"/>
								</TableDesc>
								<legend ID="N100DA" delButton="Fixed" dummy="" filter="" insertAfterButton="Fixed" insertBeforeButton="Fixed" type="" vector="" visible="false" visibleButton="Fixed"/>
							</Table>
						</xsl:when>
						<xsl:otherwise>
							<xsl:for-each select="*[not(local-name() = 'label') and not(local-name() = 'TypControl')]">
								<xsl:apply-templates select="current()">
									<xsl:with-param name="documentID" select="$documentID"/>
								</xsl:apply-templates>
							</xsl:for-each>
						</xsl:otherwise>
					</xsl:choose>
				</xsl:when>
				<xsl:otherwise>
					<xsl:apply-templates>
						<xsl:with-param name="documentID" select="$documentID"/>
					</xsl:apply-templates>
				</xsl:otherwise>
			</xsl:choose>
		</xsl:copy>
	</xsl:template>

	<xsl:template match="subsection">
		<xsl:param name="documentID"/>
		<xsl:copy>
			<xsl:call-template name="applyAttributes"/>
			<xsl:apply-templates select="current()" mode="setElemId">
				<xsl:with-param name="documentID" select="$documentID"/>
			</xsl:apply-templates>
			<xsl:apply-templates>
				<xsl:with-param name="documentID" select="$documentID"/>
			</xsl:apply-templates>
		</xsl:copy>
	</xsl:template>

	<xsl:template match="*" mode="setElemId">
		<xsl:param name="documentID"/>
		<xsl:choose>
			<xsl:when test="@ID">
				<xsl:attribute name="ID">
					<xsl:value-of select="concat($documentID, '_')"/>
					<xsl:choose>
						<xsl:when test="$generateUniqueLinkElementTargets = 'true'">
							<xsl:value-of select="generate-id()"/>
						</xsl:when>
						<xsl:otherwise>
							<xsl:value-of select="@ID"/>
						</xsl:otherwise>
					</xsl:choose>
				</xsl:attribute>
				<xsl:if test="$useBranchBasedContext = 'true' or $generateUniqueLinkElementTargets = 'true'">
					<xsl:attribute name="originalID">
						<xsl:value-of select="@ID"/>
					</xsl:attribute>
				</xsl:if>
			</xsl:when>
			<xsl:otherwise>
				<xsl:attribute name="ID">
					<xsl:value-of select="generate-id()"/>
					<xsl:text>-123</xsl:text>
				</xsl:attribute>
			</xsl:otherwise>
		</xsl:choose>
	</xsl:template>

	<xsl:template match="RefControl[@PickerElement = 'link.detail.controller' or @PickerElement = 'link.element.controller' or @PickerElement = 'link.anchor.controller']">
		<xsl:copy>
			<xsl:call-template name="applyAttributes"/>

			<xsl:variable name="RefID">
				<xsl:choose>
					<!-- compound id -->
					<xsl:when test="contains(@RefID, '-')">
						<xsl:value-of select="substring-before(@RefID, '-')"/>
					</xsl:when>
					<xsl:otherwise>
						<xsl:value-of select="@RefID"/>
					</xsl:otherwise>
				</xsl:choose>
			</xsl:variable>
			<xsl:variable name="objElem" select="key('ObjectKey', @webdavID) | key('IncludeKey', @webdavID)/parent::*"/>
			<xsl:variable name="refElems" select="$objElem/.//*[(name() = 'Table'
							  or name() = 'media.theme' or starts-with(name(), 'block.'))
							 and @ID = $RefID]"/>
			<xsl:variable name="refElems2" select="key('ObjectKey', current()/@containerID)
							//*[starts-with(name(), 'include.')]/RefControl[@webdavID = current()/@webdavID]/..//*[(name() = 'Table'
         					or name() = 'media.theme' or starts-with(name(), 'block.')) and @ID = $RefID]"/>
			<xsl:variable name="includeElem" select="$refElems/ancestor::*[starts-with(name(), 'include.')]"/>
			<xsl:variable name="webdavID">
				<xsl:choose>
					<xsl:when test="not($refElems[not(ancestor::*[starts-with(name(), 'include.')])])
							  and $includeElem">
						<xsl:choose>
							<xsl:when test="$refElems/ancestor::*[starts-with(name(), 'include.')][1]/RefControl/@webdavID = @webdavID">
								<xsl:value-of select="$refElems/ancestor::*[starts-with(name(), 'include.')][1]/RefControl/@webdavID"/>
							</xsl:when>
							<xsl:otherwise>
								<xsl:value-of select="$includeElem/RefControl/@webdavID"/>
							</xsl:otherwise>
						</xsl:choose>
					</xsl:when>
					<xsl:otherwise>
						<xsl:value-of select="@webdavID"/>
					</xsl:otherwise>
				</xsl:choose>
			</xsl:variable>
			
			<xsl:variable name="fileId">
				<xsl:apply-templates select="current()" mode="getLinkFileId">
					<xsl:with-param name="webdavID" select="$webdavID"/>
				</xsl:apply-templates>
			</xsl:variable>

			<xsl:attribute name="fileID">
				<xsl:choose>
					<xsl:when test="$includeElem">
						<xsl:value-of select="$includeElem/ancestor::Object[1]/RefControl/@webdavID"/>
					</xsl:when>
					<xsl:otherwise>
						<xsl:value-of select="$fileId"/>
					</xsl:otherwise>
				</xsl:choose>
			</xsl:attribute>
			
			<xsl:if test="not(@PickerElement = 'link.anchor.controller')">
				<xsl:attribute name="RefID">
					<xsl:value-of select="concat($fileId, '_')"/>
					<xsl:choose>
						<xsl:when test="$generateUniqueLinkElementTargets = 'true' and $refElems">
							<xsl:choose>
								<xsl:when test="$refElems2">
									<xsl:value-of select="generate-id($refElems2[1])"/>
								</xsl:when>
								<xsl:otherwise>
									<xsl:value-of select="generate-id($refElems[1])"/>
								</xsl:otherwise>
							</xsl:choose>
						</xsl:when>
						<xsl:otherwise>
							<xsl:value-of select="@RefID"/>
						</xsl:otherwise>
					</xsl:choose>
				</xsl:attribute>
			</xsl:if>
			<xsl:if test="string-length(@TargetSectionId) &gt; 0">
				<xsl:attribute name="TargetSectionId">
					<xsl:value-of select="concat($fileId, '_', @TargetSectionId)"/>
				</xsl:attribute>
			</xsl:if>

			<xsl:attribute name="OriginalRefID">
				<xsl:value-of select="@RefID"/>
			</xsl:attribute>

			<xsl:if test="$hasSingleRoot and $oldRootID = $webdavID and not($useClosestLinkTarget = 'true')">
				<xsl:attribute name="webdavID">
					<xsl:value-of select="$newRootID"/>
				</xsl:attribute>
				<xsl:choose>
					<xsl:when test="string-length(@defaultLanguage) &gt; 0">
						<xsl:attribute name="fileID">
							<xsl:value-of select="concat($newRootID, '_', @defaultLanguage)"/>
						</xsl:attribute>
						<xsl:attribute name="RefID">
							<xsl:value-of select="concat($newRootID, '_', @defaultLanguage, '_', @RefID)"/>
						</xsl:attribute>
					</xsl:when>
					<xsl:otherwise>
						<xsl:attribute name="fileID">
							<xsl:value-of select="$newRootID"/>
						</xsl:attribute>
						<xsl:attribute name="RefID">
							<xsl:value-of select="concat($newRootID, '_', @RefID)"/>
						</xsl:attribute>
					</xsl:otherwise>
				</xsl:choose>
			</xsl:if>
			<xsl:apply-templates/>
		</xsl:copy>
	</xsl:template>

	<xsl:template match="Branch" mode="findClosestLinkTarget">
		<xsl:param name="webdavID"/>
		<xsl:param name="defaultLanguage"/>
		<xsl:variable name="currentLinkTarget">
			<xsl:apply-templates select="(.//Object/RefControl[@webdavID = $webdavID and (string-length($defaultLanguage) = 0 or @defaultLanguage = $defaultLanguage)])[1]" mode="getId"/>
		</xsl:variable>
		<xsl:choose>
			<xsl:when test="string-length($currentLinkTarget) = 0">
				<xsl:variable name="followingLinkTarget">
					<xsl:apply-templates select="(following-sibling::Branch//Object/RefControl[@webdavID = $webdavID and (string-length($defaultLanguage) = 0 or @defaultLanguage = $defaultLanguage)])[1]" mode="getId"/>
				</xsl:variable>
				<xsl:choose>
					<xsl:when test="string-length($followingLinkTarget) = 0">
						<xsl:variable name="precedingLinkTarget">
							<xsl:apply-templates select="(preceding-sibling::Branch//Object/RefControl[@webdavID = $webdavID and (string-length($defaultLanguage) = 0 or @defaultLanguage = $defaultLanguage)])[1]" mode="getId"/>
						</xsl:variable>
						<xsl:choose>
							<xsl:when test="string-length($precedingLinkTarget) = 0">
								<xsl:apply-templates select="ancestor::Branch[1]" mode="findClosestLinkTarget">
									<xsl:with-param name="webdavID" select="$webdavID"/>
									<xsl:with-param name="defaultLanguage" select="$defaultLanguage"/>
								</xsl:apply-templates>
							</xsl:when>
							<xsl:otherwise>
								<xsl:value-of select="$precedingLinkTarget"/>
							</xsl:otherwise>
						</xsl:choose>
					</xsl:when>
					<xsl:otherwise>
						<xsl:value-of select="$followingLinkTarget"/>
					</xsl:otherwise>
				</xsl:choose>
			</xsl:when>
			<xsl:otherwise>
				<xsl:value-of select="$currentLinkTarget"/>
			</xsl:otherwise>
		</xsl:choose>
	</xsl:template>

	<xsl:template match="RefControl" mode="getLinkFileId">
		<xsl:param name="webdavID" select="@webdavID"/>

		<xsl:variable name="defaultLanguage" select="ancestor-or-self::*[string-length(@defaultLanguage) &gt; 0][1]/@defaultLanguage"/>

		<xsl:variable name="targetObjects" select="(key('ObjectKey', $webdavID))"/>
		
		<xsl:choose>
			<xsl:when test="string-length($defaultLanguage) &gt; 0 and $targetObjects[@defaultLanguage = $defaultLanguage]">
				<xsl:choose>
							<xsl:when test="$useClosestLinkTarget = 'true'">
						<xsl:apply-templates select="ancestor::Branch[1]" mode="findClosestLinkTarget">
							<xsl:with-param name="webdavID" select="$webdavID"/>
							<xsl:with-param name="defaultLanguage" select="$defaultLanguage"/>
						</xsl:apply-templates>
					</xsl:when>
					<xsl:otherwise>
						<xsl:apply-templates select="($targetObjects[@defaultLanguage = $defaultLanguage])[1]" mode="getId"/>
					</xsl:otherwise>
				</xsl:choose>
			</xsl:when>
			<xsl:otherwise>
				<xsl:variable name="targetObject" select="$targetObjects[1]"/>
				<xsl:choose>
					<xsl:when test="$targetObject">
						<xsl:choose>
							<xsl:when test="$useClosestLinkTarget = 'true'">
								<xsl:apply-templates select="ancestor::Branch[1]" mode="findClosestLinkTarget">
									<xsl:with-param name="webdavID" select="$webdavID"/>
								</xsl:apply-templates>
							</xsl:when>
							<xsl:otherwise>
								<xsl:apply-templates select="$targetObject" mode="getId"/>
							</xsl:otherwise>
						</xsl:choose>
					</xsl:when>
					<xsl:otherwise>
						<xsl:value-of select="$webdavID"/>
					</xsl:otherwise>
				</xsl:choose>
			</xsl:otherwise>
		</xsl:choose>
	</xsl:template>

	<xsl:template match="RefControl[@PickerElement = 'link.xref.controller' or name(parent::*) = 'Reference.controller']">
		<xsl:copy>
			<xsl:call-template name="applyAttributes"/>

			<xsl:variable name="fileId">
				<xsl:apply-templates select="current()" mode="getLinkFileId"/>
			</xsl:variable>

			<xsl:attribute name="fileID">
				<xsl:value-of select="$fileId"/>
			</xsl:attribute>

			<xsl:if test="string-length(@RefID)">
				<xsl:attribute name="RefID">
					<xsl:value-of select="concat($fileId, '_', @RefID)"/>
				</xsl:attribute>
			</xsl:if>

			<xsl:apply-templates/>
		</xsl:copy>
	</xsl:template>

	<xsl:template match="Object[RefControl[not(@objType = 'mediaset')]/IncludedObject/Structure]">
		<xsl:choose>
			<xsl:when test="$PRESERVE_BOOK_CONTAINER = 'true'">
				<Structure>
					<xsl:copy-of select="RefControl/IncludedObject/Structure/@*"/>
					<xsl:apply-templates select="RefControl/IncludedObject/Structure/*[name() != 'Properties']"/>
				</Structure>
			</xsl:when>
			<xsl:otherwise>
				<xsl:apply-templates select="RefControl/IncludedObject/Structure/*[name() != 'Properties']"/>
			</xsl:otherwise>
		</xsl:choose>
	</xsl:template>

	<xsl:template match="include.content">
		<xsl:param name="documentID"/>
		<include.content>
			<xsl:copy-of select="@ID | @translate | @Changed | RefControl/@versionLabel | RefControl/@defaultLanguage[string-length(.) &gt; 0] | @filter"/>
			<xsl:apply-templates select="*[name() != 'RefControl']">
				<xsl:with-param name="documentID">
					<xsl:choose>
						<xsl:when test="string-length(RefControl/@webdavID) &gt; 0">
							<xsl:value-of select="RefControl/@webdavID"/>
						</xsl:when>
						<xsl:otherwise>
							<xsl:value-of select="$documentID"/>
						</xsl:otherwise>
					</xsl:choose>
				</xsl:with-param>
			</xsl:apply-templates>
		</include.content>
	</xsl:template>

	<xsl:template match="media.caption">
		<xsl:param name="documentID"/>
		<xsl:if test="string-length(.) &gt; 0">
			<xsl:copy>
				<xsl:copy-of select="@*"/>
				<xsl:apply-templates>
					<xsl:with-param name="documentID" select="$documentID"/>
				</xsl:apply-templates>
			</xsl:copy>
		</xsl:if>
	</xsl:template>

	<xsl:template match="media.theme">
		<xsl:param name="documentID"/>
		<xsl:copy>
			<xsl:call-template name="applyAttributes"/>
			<xsl:apply-templates select="current()" mode="setElemId">
				<xsl:with-param name="documentID" select="$documentID"/>
			</xsl:apply-templates>
			<xsl:apply-templates>
				<xsl:with-param name="documentID" select="$documentID"/>
			</xsl:apply-templates>
		</xsl:copy>
	</xsl:template>

	<xsl:template match="RefControl" mode="getId">
		<xsl:choose>
			<xsl:when test="$useClosestLinkTarget = 'true'">
				<xsl:value-of select="generate-id()"/>
			</xsl:when>
			<xsl:otherwise>
				<xsl:choose>
					<xsl:when test="string-length(@defaultLanguage) &gt; 0">
						<xsl:value-of select="concat(@webdavID, '_', @defaultLanguage)"/>
					</xsl:when>
					<xsl:otherwise>
						<xsl:value-of select="@webdavID"/>
					</xsl:otherwise>
				</xsl:choose>
			</xsl:otherwise>
		</xsl:choose>
	</xsl:template>

	<xsl:template match="MMFramework.Container">
		<xsl:variable name="pre_ID">
			<xsl:apply-templates select="parent::RefControl" mode="getId"/>
		</xsl:variable>

		<xsl:variable name="ID">
			<xsl:choose>
				<xsl:when test="string-length($pre_ID) = 0">
					<xsl:value-of select="generate-id()"/>
				</xsl:when>
				<xsl:when test="not($useClosestLinkTarget = 'true') and parent::RefControl/preceding::Object[RefControl[@webdavID = $pre_ID]]">
					<xsl:value-of select="concat($pre_ID, '_', generate-id())"/>
				</xsl:when>
				<xsl:otherwise>
					<xsl:value-of select="$pre_ID"/>
				</xsl:otherwise>
			</xsl:choose>
		</xsl:variable>
		<xsl:variable name="hcElem" select="section/headline.content"/>
		<xsl:variable name="hc">
			<xsl:for-each select="$hcElem/text() | $hcElem/*[not(name() = 'index.entry' and @notVisible = 'true') and not(name() = 'notes')]">
				<xsl:value-of select="."/>
			</xsl:for-each>
		</xsl:variable>
		<xsl:if test="section">
			<section ID="{$ID}">
				<xsl:copy-of select="section/@type | section/@Typ | ancestor::Branch[1]/@*[name() = 'filter' or name() = 'metafilter'] | @styleID | @datasheet | parent::RefControl/@catalogID
						 | ancestor::Branch[1]/@level | parent::RefControl/@serverID | parent::RefControl/@versionLabel | ancestor::Object[1]/@guid"/>
				<!-- copy characterization of book node -->
				<xsl:variable name="firstChild" select="ancestor::Branch[1][not(preceding-sibling::Branch)]"/>
				<xsl:if test="$firstChild and ($firstChild/parent::Structure/parent::IncludedObject or $firstChild/parent::Branch[Object/RefControl[starts-with(@objType, 'book')]])">
					<xsl:variable name="filter">
						<xsl:choose>
							<xsl:when test="ancestor::IncludedObject[1]">
								<xsl:value-of select="ancestor::IncludedObject[1]/ancestor::Branch[1]/@filter"/>
							</xsl:when>
							<xsl:otherwise>
								<xsl:value-of select="ancestor::Branch[1]/parent::Branch[Object/RefControl[starts-with(@objType, 'book')]]/@filter"/>
							</xsl:otherwise>
						</xsl:choose>
					</xsl:variable>
					<xsl:if test="string-length($filter) &gt; 0">
						<xsl:attribute name="filter">
							<xsl:if test="string-length(ancestor::Branch[1]/@filter) &gt; 0">
								<xsl:value-of select="concat(ancestor::Branch[1]/@filter, ',')"/>
							</xsl:if>
							<xsl:value-of select="$filter"/>
						</xsl:attribute>
					</xsl:if>
					<xsl:variable name="metafilter">
						<xsl:choose>
							<xsl:when test="ancestor::IncludedObject[1]">
								<xsl:value-of select="ancestor::IncludedObject[1]/ancestor::Branch[1]/@metafilter"/>
							</xsl:when>
							<xsl:otherwise>
								<xsl:value-of select="ancestor::Branch[1]/parent::Branch[Object/RefControl[starts-with(@objType, 'book')]]/@metafilter"/>
							</xsl:otherwise>
						</xsl:choose>
					</xsl:variable>
					<xsl:if test="string-length($metafilter) &gt; 0">
						<xsl:attribute name="metafilter">
							<xsl:if test="string-length(ancestor::Branch[1]/@metafilter) &gt; 0">
								<xsl:value-of select="concat(ancestor::Branch[1]/@metafilter, ',')"/>
							</xsl:if>
							<xsl:value-of select="$metafilter"/>
						</xsl:attribute>
					</xsl:if>
				</xsl:if>
				<xsl:choose>
					<xsl:when test="string-length(ancestor::Branch[1]/@filter) = 0">
						<xsl:copy-of select="section/@filter"/>
					</xsl:when>
					<xsl:when test="string-length(section/@filter) &gt; 0">
						<xsl:attribute name="filter">
							<xsl:value-of select="concat(ancestor::Branch[1]/@filter, ',', section/@filter)"/>
						</xsl:attribute>
					</xsl:when>
				</xsl:choose>
				<xsl:choose>
					<xsl:when test="string-length(ancestor::Branch[1]/@metafilter) = 0">
						<xsl:copy-of select="section/@metafilter"/>
					</xsl:when>
					<xsl:when test="string-length(section/@metafilter) &gt; 0">
						<xsl:attribute name="metafilter">
							<xsl:value-of select="concat(ancestor::Branch[1]/@metafilter, ',', section/@metafilter)"/>
						</xsl:attribute>
					</xsl:when>
				</xsl:choose>

				<xsl:call-template name="setLexdocAttribute"/>
				<xsl:for-each select="ancestor::Structure[1]/ancestor::RefControl[1]">
					<xsl:if test="@objType">
						<xsl:attribute name="containerObjType">
							<xsl:value-of select="@objType"/>
						</xsl:attribute>
					</xsl:if>
					<xsl:if test="string-length(@versionLabel) &gt; 0">
						<xsl:attribute name="containerVersionLabel">
							<xsl:value-of select="@versionLabel"/>
						</xsl:attribute>
					</xsl:if>
				</xsl:for-each>

				<xsl:copy-of select="ancestor::RefControl[1]/@*[name() = 'objType' or name() = 'status-diff']"/>

				<xsl:choose>
					<xsl:when test="string-length(ancestor::RefControl[1]/@defaultLanguage) &gt; 0">
						<xsl:copy-of select="ancestor::RefControl[1]/@defaultLanguage"/>
					</xsl:when>
					<xsl:otherwise>
						<xsl:attribute name="defaultLanguage">
							<xsl:value-of select="$language"/>
						</xsl:attribute>
					</xsl:otherwise>
				</xsl:choose>

				<xsl:attribute name="Title">
					<xsl:choose>
						<xsl:when test="string-length($hc) &gt; 0">
							<xsl:value-of select="normalize-space($hc)"/>
						</xsl:when>
						<xsl:otherwise>
							<xsl:value-of select="parent::RefControl/@TargetTitle"/>
						</xsl:otherwise>
					</xsl:choose>
				</xsl:attribute>

				<xsl:attribute name="BookTitle">
					<xsl:value-of select="ancestor::Structure[1]/Branch/Object/RefControl/MMFramework.Container/section/headline.content"/>
				</xsl:attribute>

				<xsl:copy-of select="parent::RefControl/parent::Object/@*[name() = 'translate' or name() = 'Changed' or name() = 'inheritedCharTitles']"/>

				<xsl:apply-templates select="*[name() != 'Properties']">
					<xsl:with-param name="documentID" select="$ID"/>
				</xsl:apply-templates>
				<xsl:apply-templates select="following-sibling::Properties[1] | Properties"/>
				
				<xsl:for-each select="parent::RefControl/parent::*/parent::Branch">
					<xsl:if test="not(preceding-sibling::Branch) and parent::Structure/parent::IncludedObject">
						<xsl:apply-templates select="parent::Structure/Properties" mode="structureProperties"/>
					</xsl:if>
					<xsl:apply-templates select="Branch"/>
				</xsl:for-each>
			</section>
		</xsl:if>

	</xsl:template>

	<xsl:template match="section">
		<xsl:param name="documentID"/>
		<xsl:apply-templates>
			<xsl:with-param name="documentID" select="$documentID"/>
		</xsl:apply-templates>
	</xsl:template>

	<xsl:template match="blocks.optional | blocks">
		<xsl:param name="documentID"/>
		<xsl:apply-templates select="*[string-length(@visible) = 0 or @visible = 'true' or name() = 'subsection']">
			<xsl:with-param name="documentID" select="$documentID"/>
		</xsl:apply-templates>
	</xsl:template>

	<xsl:template match="WebInfo/MetaInfo[string-length(@Name) = 0]"/>

	<xsl:template match="node()">
		<xsl:param name="documentID"/>
		<xsl:copy>
			<xsl:call-template name="applyAttributes"/>
			<xsl:apply-templates>
				<xsl:with-param name="documentID" select="$documentID"/>
			</xsl:apply-templates>
		</xsl:copy>
	</xsl:template>

	<xsl:template name="applyAttributes">
		<!-- remove editor related attributes -->
		<xsl:copy-of select="@*[name() != 'delButton'
					and not(. = '' and (name() = 'filter' or name() = 'metafilter' or name() = 'readableFilter' or name() = 'readableMetaFilter'))
					and name() != 'dummy'
					and name() != 'addMe'
					and name() != 'button'
					and name() != 'vector'
					and name() != 'locked'
					and name() != 'visibleTop'
					and name() != 'insertAfterButton'
					and name() != 'insertBeforeButton'
					and name() != 'lockedButton'
					and name() != 'insertButton'
					and name() != 'insertButton'
					and name() != 'visibleButton'
					and name() != 'visibleTopButton'
					and name() != 'copyButton']"/>
	</xsl:template>

	<xsl:template match="substitute">
		<substitute>
			<xsl:call-template name="applyAttributes"/>
			<xsl:if test="@fileType='swf' and ../../mediacontent/Animation and string-length(@aniContent) = 0">
				<xsl:attribute name="aniContent">
					<xsl:value-of select="concat(@subURL,'/../de.mediacontent.xml')"/>
				</xsl:attribute>
			</xsl:if>
			<xsl:apply-templates/>
		</substitute>
	</xsl:template>

	<xsl:template match="block.description[XchangeInfo]"/>

	<xsl:template match="link.catalog.controller/content">
		<xsl:copy>
			<xsl:copy-of select="@*"/>
			<xsl:copy-of select="node()"/>
		</xsl:copy>
	</xsl:template>

	<!-- Check if legend is not empty -->
	<xsl:template match="legend">
		<xsl:param name="documentID"/>
		<xsl:if test="legend.row">
			<xsl:copy>
				<xsl:call-template name="applyAttributes"/>
				<xsl:apply-templates>
					<xsl:with-param name="documentID" select="$documentID"/>
				</xsl:apply-templates>
			</xsl:copy>
		</xsl:if>
	</xsl:template>

	<!-- Check if Table is not empty -->
	<xsl:template match="Table">
		<xsl:param name="documentID"/>
		<xsl:if test="table">
			<xsl:copy>
				<xsl:call-template name="applyAttributes"/>
				<xsl:apply-templates select="current()" mode="setElemId">
					<xsl:with-param name="documentID" select="$documentID"/>
				</xsl:apply-templates>
				<xsl:apply-templates>
					<xsl:with-param name="documentID" select="$documentID"/>
				</xsl:apply-templates>
			</xsl:copy>
		</xsl:if>
	</xsl:template>	
	
</xsl:stylesheet>
