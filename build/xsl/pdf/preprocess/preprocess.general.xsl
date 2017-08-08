<?xml version="1.0" encoding="utf-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" version="1.0">

	<xsl:param name="review-markdraft"/>
	<xsl:param name="maintain-include-block-element"/>

	<xsl:template match="form.answer">
		<xsl:variable name="position" select="count(preceding-sibling::form.answer)"/>

		<form.answer answerID="{translate($position,'0123456789','ABCDEFGHIJK')}">
			<xsl:copy-of select="@*"/>
			<xsl:apply-templates/>
		</form.answer>
	</xsl:template>


	<xsl:template match="hierarchy_item">
		<xsl:choose>
			<xsl:when test="parent::hierarchy_item">
				<Enum type = "Menu">
					<EnumElement><xsl:apply-templates select="@menu_name"/></EnumElement>
					<xsl:apply-templates/>
				</Enum>
			</xsl:when>
			<xsl:otherwise>
				<Enum  type = "Menu">
					<enum.title><xsl:apply-templates select="@menu_name"/></enum.title>
					<xsl:for-each select="hierarchy_item">
						<EnumElement><xsl:apply-templates select="@menu_name"/></EnumElement>
						<xsl:apply-templates/>
					</xsl:for-each>
				</Enum>	
			</xsl:otherwise>	
		</xsl:choose>	
	</xsl:template>


	<xsl:template match="VARIABLE">
		<xsl:value-of select="@value"/>
	</xsl:template>

	<xsl:template match="tableFootnote">
		<InfoChunk.TableFootnote>
			<xsl:copy-of select="@*"/>
			<xsl:apply-templates/>
		</InfoChunk.TableFootnote>
	</xsl:template>

	<xsl:template match="marker">
		<InfoChunk.Marked>
			<xsl:apply-templates select="current()" mode="copyCharacterizationAttributes"/>
			<xsl:if test="@author-support">
				<xsl:copy-of select="@*"/>
			</xsl:if>
			<xsl:apply-templates/>
		</InfoChunk.Marked>
	</xsl:template>

	<xsl:template match="code">
		<xsl:choose>
			<xsl:when test="name(preceding-sibling::*[1]) = 'code' "></xsl:when>
			<xsl:otherwise>
				<InfoPar.Code ID="{@ID}">
					<xsl:apply-templates select="current()" mode="copyDiffAttributes"/>
					<xsl:apply-templates select="current()" mode="copyCharacterizationAttributes"/>
					<xsl:apply-templates/>
					<xsl:if test="name(following-sibling::*[1]) = 'code'">
						<xsl:variable name="preNoneCode" select="count(preceding-sibling::*[name() != 'code'])"/>
						<xsl:for-each select="following-sibling::code[count(preceding-sibling::*[name() != 'code']) = $preNoneCode]">
							<InfoChunk.Break/>
							<xsl:apply-templates/>
						</xsl:for-each>
					</xsl:if>
				</InfoPar.Code>
			</xsl:otherwise>
		</xsl:choose>
	</xsl:template>

	<xsl:template match="invalid">
		<InfoChunk.Invalid>
			<xsl:apply-templates/>
		</InfoChunk.Invalid>
	</xsl:template>

	<xsl:template match="tnc.softkey">
		<InfoChunk.Capital>
			<xsl:apply-templates/>
		</InfoChunk.Capital>
	</xsl:template>

	<!-- italics for documents, italic for mediaset legendcontent -->
	<xsl:template match="italics | italic">
		<InfoChunk.Italics>
			<xsl:copy-of select="@filter | @readableFilter | @metafilter | @charCategoryColor | @charPropertyColor | @cssClassName | @translated"/>
			<xsl:apply-templates/>
		</InfoChunk.Italics>
	</xsl:template>

	<xsl:template match = "tnc.dialog">
		<InfoChunk.Important>
			<xsl:apply-templates/>
		</InfoChunk.Important>
	</xsl:template>

	<xsl:template match="blocks.optional | blocks">
		<xsl:apply-templates/>
	</xsl:template>

	<xsl:variable name="preserveIncludeElements">
		<xsl:call-template name="getFormatVariableValue">
			<xsl:with-param name="name">PRESERVE_INCLUDE_ELEMENTS</xsl:with-param>
		</xsl:call-template>
	</xsl:variable>

	<xsl:template match ="content | include.content">
		<xsl:choose>
			<xsl:when test="name() = 'include.content' and ($preserveIncludeElements = 'true' or $trafo = 'HTML'
					  or $generate_translation_helper = 'true' or $review-markdraft = 'true'
					  or string-length($tp_compareVersionID) &gt; 0 or string-length(@Changed) &gt; 0)">
				<Include.Content>
					<xsl:copy-of select="@*"/>
					<xsl:copy-of select="RefControl/@defaultLanguage[string-length(.) &gt; 0]"/>
					<xsl:apply-templates/>
				</Include.Content>
			</xsl:when>
			<xsl:when test="name() = 'include.content'">
				<xsl:apply-templates select="*[name() != 'RefControl']"/>
			</xsl:when>
			<xsl:when test="name() = 'content'">
				<xsl:apply-templates/>
			</xsl:when>
		</xsl:choose>

	</xsl:template>

	<xsl:template match ="include.block">
		<xsl:choose>
			<xsl:when test="$preserveIncludeElements = 'true' or $trafo = 'HTML' or $maintain-include-block-element = 'true'
					  or $review-markdraft = 'true' or string-length($tp_compareVersionID) &gt; 0 or parent::entry">
				<Include.Block>
					<xsl:copy-of select="@*"/>
					<xsl:copy-of select="RefControl/@defaultLanguage[string-length(.) &gt; 0]"/>
					<xsl:apply-templates/>
				</Include.Block>
			</xsl:when>
			<xsl:otherwise>
				<xsl:apply-templates select="*[name() != 'RefControl']"/>
			</xsl:otherwise>
		</xsl:choose>

	</xsl:template>


	<!-- **************************************************

															Unter InfoMap

************************************************** -->


	<!-- Ueberschrift -->
	<xsl:template match = "headline.content">
		<xsl:element name = "Headline.content">
			<xsl:attribute name = "Level">
				<xsl:value-of select = "count(ancestor::*)"/>
			</xsl:attribute>
			<xsl:copy-of select="@*"/>
			<xsl:apply-templates/>
		</xsl:element>

	</xsl:template>

	<xsl:template match = "headline.theme">
		<xsl:element name = "Headline.theme">
			<xsl:attribute name = "Level">
				<xsl:value-of select = "count(ancestor::*)"/>
			</xsl:attribute>
			<xsl:copy-of select="@*"/>
			<!--<xsl:choose>
				<xsl:when test="not(node()) and count(exslt:node-set($HeadlineThemeDefaultContent)) &gt; 0">
					<xsl:apply-templates select="exslt:node-set($HeadlineThemeDefaultContent)"/>
				</xsl:when>
				<xsl:otherwise>-->
					<xsl:apply-templates/>
				<!--</xsl:otherwise>
			</xsl:choose>-->
		</xsl:element>
	</xsl:template>

	<!-- Bloecke -->

	<xsl:template match="label">
		<Label ID="{@ID}">
			<xsl:apply-templates select="current()" mode="copyDiffAttributes"/>
			<xsl:apply-templates select="current()" mode="copyCharacterizationAttributes"/>
			<xsl:apply-templates/>
		</Label>
	</xsl:template>


	<xsl:template match="notice">
		<InfoItem.Warning>
			<xsl:attribute name="type">
				<xsl:value-of select="@type"/>
			</xsl:attribute>
			<xsl:copy-of select="@compact | ancestor-or-self::*[string-length(@defaultLanguage) &gt; 0][1]/@defaultLanguage"/>
			<xsl:if test="not(@defaultLanguage)">
				<xsl:for-each select="ancestor::include.content[1]">
					<xsl:copy-of select="@defaultLanguage | RefControl/@defaultLanguage[string-length(.) &gt; 0]"/>
				</xsl:for-each>
			</xsl:if>
			<xsl:apply-templates select="current()" mode="copyDiffAttributes"/>
			<xsl:apply-templates select="current()" mode="copyCharacterizationAttributes"/>
			<xsl:choose>
				<xsl:when test="notice.container">
					<InfoChunk.Warning>Note</InfoChunk.Warning>
					<xsl:apply-templates select="*[name() != 'notice.container']"/>
					<InfoPar.Warning>
						<xsl:apply-templates select="notice.container"/>
					</InfoPar.Warning>
				</xsl:when>
				<xsl:otherwise>
					<InfoChunk.Warning>Note</InfoChunk.Warning>
					<InfoPar.Warning>
						<xsl:apply-templates/>
					</InfoPar.Warning>
				</xsl:otherwise>
			</xsl:choose>
			<xsl:apply-templates select="notes"/>
		</InfoItem.Warning>
	</xsl:template>

	<xsl:template match="notice.container">
		<xsl:apply-templates select="current()" mode="copyDiffAttributes"/>
		<xsl:apply-templates select="current()" mode="copyCharacterizationAttributes"/>
		<xsl:apply-templates/>
	</xsl:template>

	<xsl:template match  = "par | par.table">
		<InfoPar>
			<xsl:copy-of select="@format | ancestor::*[string-length(@defaultLanguage) &gt; 0][1]/@defaultLanguage"/>
			<xsl:apply-templates select="current()" mode="copyDiffAttributes"/>
			<xsl:apply-templates select="current()" mode="copyCharacterizationAttributes"/>
			<xsl:apply-templates/>
		</InfoPar>
	</xsl:template>

	<xsl:template match="mathwrapper/par">
		<InfoPar isMath="true">
			<xsl:copy-of select="@*"/>
			<xsl:apply-templates/>
		</InfoPar>
	</xsl:template>

	<!-- Aufzaehlungstypen -->

	<xsl:template match = "instruction">
		<Enum.Instruction>
			<xsl:copy-of select="@type | @startNumber"/>
			<xsl:apply-templates select="current()" mode="copyDiffAttributes"/>
			<xsl:apply-templates select="current()" mode="copyCharacterizationAttributes"/>
			<xsl:apply-templates/>
		</Enum.Instruction>
	</xsl:template>

	<xsl:template match = "enum.standard">
		<Enum>
			<xsl:copy-of select="@type | @startNumber | @style"/>
			<xsl:apply-templates select="current()" mode="copyDiffAttributes"/>
			<xsl:apply-templates select="current()" mode="copyCharacterizationAttributes"/>
			<!-- workaround for editor bug -->
			<xsl:apply-templates select="node()[not(name() = 'emphasis' or name() = 'italics')]"/>
		</Enum>
	</xsl:template>

	<xsl:template match = "enum.element | step">
		<EnumElement>
			<xsl:apply-templates select="current()" mode="copyDiffAttributes"/>
			<xsl:apply-templates select="current()" mode="copyCharacterizationAttributes"/>
			<xsl:apply-templates/>
		</EnumElement>
	</xsl:template>

	<xsl:template match = "legend">
		<xsl:variable name="type" select="@type"/>

		<xsl:if test="legend.row">
			<xsl:choose>
				<xsl:when test="$TRANSLATE_LEGEND='false'">
					<legend>
						<xsl:copy-of select="@type"/>
						<xsl:apply-templates select="current()" mode="copyDiffAttributes"/>
						<xsl:apply-templates select="current()" mode="copyCharacterizationAttributes"/>
						<xsl:if test="parent::Table">
							<xsl:attribute name="isTableLegend"/>
						</xsl:if>
						<xsl:apply-templates mode="legend"/>
					</legend>
				</xsl:when>
				<xsl:otherwise>
					<table.NoBorder typ="Nolines" isTableLegend="">
						<xsl:copy-of select="@Changed | @AttributesChanged | @ID | @filter | @readableFilter | @metafilter | @type | @charCategoryColor | @charPropertyColor | @cssClassName | @translated | @translate"/>
						<xsl:choose>
							<xsl:when test="parent::Table and $type = 'Definition'">
								<colspec colname="1" colnum="1" colwidth="3"/>
								<colspec colname="1" colnum="2" colwidth="10"/>
								<colspec colname="1" colnum="3" colwidth="87"/>
							</xsl:when>
							<xsl:when test="parent::Table">
								<colspec colname="1" colnum="1" colwidth="3"/>
								<colspec colname="1" colnum="2" colwidth="97"/>
							</xsl:when>
							<xsl:when test="$type = 'Definition'">
								<colspec colname="1" colnum="1" colwidth="10"/>
								<colspec colname="1" colnum="2" colwidth="10"/>
								<colspec colname="1" colnum="3" colwidth="80"/>
							</xsl:when>
							<xsl:otherwise>
								<colspec colname="1" colnum="1" colwidth="10"/>
								<colspec colname="1" colnum="2" colwidth="90"/>
							</xsl:otherwise>
						</xsl:choose>
						<tableStandard>
							<xsl:apply-templates/>
						</tableStandard>
					</table.NoBorder>
					<TableDesc>
						<xsl:choose>
							<xsl:when test="parent::Table and $type = 'Definition'">
								<TableColSpec width="3"/>
								<TableColSpec width="10"/>
								<TableColSpec width="87"/>
							</xsl:when>
							<xsl:when test="parent::Table">
								<TableColSpec width="3"/>
								<TableColSpec width="97"/>
							</xsl:when>
							<xsl:when test="$type='Definition'">
								<TableColSpec width="10"/>
								<TableColSpec width="10"/>
								<TableColSpec width="80"/>
							</xsl:when>
							<xsl:otherwise>
								<TableColSpec width="10"/>
								<TableColSpec width="90"/>
							</xsl:otherwise>
						</xsl:choose>
					</TableDesc>
				</xsl:otherwise>
			</xsl:choose>
		</xsl:if>
	</xsl:template>

	<xsl:template match="*" mode="legend">
		<xsl:copy>
			<xsl:copy-of select="@*"/>
			<xsl:apply-templates mode="legend"/>
		</xsl:copy>
	</xsl:template>

	<xsl:template match="legend.def" mode="legend">
		<xsl:copy>
			<xsl:copy-of select="@*"/>
			<xsl:choose>
				<xsl:when test="par or enum.standard">
					<xsl:apply-templates/>
				</xsl:when>
				<xsl:when test="text() or emphasis or inverted or index.entry or invalid or subscript or superscript or starts-with(name(), 'link.')
     or no.linebreak or media.theme or marker or italics or symbol or symb or dialog or code.inline or METADATA or footnote or formula
     or tableFootnote or note">
					<InfoPar>
						<xsl:apply-templates/>
					</InfoPar>
				</xsl:when>
				<xsl:otherwise>
					<xsl:apply-templates/>
				</xsl:otherwise>
			</xsl:choose>
		</xsl:copy>
	</xsl:template>

	<xsl:template match="legend.term" mode="legend">
		<xsl:copy>
			<xsl:copy-of select="@*"/>
			<xsl:apply-templates/>
		</xsl:copy>
	</xsl:template>

	<xsl:template match="legend.row">

		<xsl:variable name="type" select="parent::legend/@type"/>

		<tableRow>
			<xsl:apply-templates select="current()" mode="copyDiffAttributes"/>
			<xsl:apply-templates select="current()" mode="copyCharacterizationAttributes"/>
			<tableCell colnum="1">
				<xsl:apply-templates select="current()" mode="setTableCellDiffStyle"/>
				<InfoPar>
					<xsl:attribute name="legendValue">
						<xsl:apply-templates select="legend.term"/>
					</xsl:attribute>
					<xsl:apply-templates select="legend.term"/>
					<xsl:call-template name="getFormatVariableValue">
						<xsl:with-param name="name" select="'TABLE_LEGEND_TERM_SUFFIX'"/>
					</xsl:call-template>
				</InfoPar>
			</tableCell>
			<tableCell colnum="2">
				<xsl:apply-templates select="current()" mode="setTableCellDiffStyle"/>
				<xsl:if test = "$type='Definition'">
					<xsl:attribute name = "colnum">3</xsl:attribute>
				</xsl:if>
				<xsl:for-each select="legend.def">
					<xsl:choose>
						<xsl:when test="par or enum.standard">
							<xsl:apply-templates select="current()"/>
						</xsl:when>
						<xsl:when test="text() or emphasis or inverted or index.entry or invalid or subscript or superscript or starts-with(name(), 'link.')
     or no.linebreak or media.theme or marker or italics or symbol or symb or dialog or code.inline or METADATA or footnote or formula
     or tableFootnote or note">
							<InfoPar>
								<xsl:apply-templates select="current()"/>
							</InfoPar>
						</xsl:when>
						<xsl:otherwise>
							<xsl:apply-templates select="current()"/>
						</xsl:otherwise>
					</xsl:choose>
				</xsl:for-each>
			</tableCell>
		</tableRow>
	</xsl:template>

	<xsl:template match="legend.row" mode="setTableCellDiffStyle">
		<xsl:if test="@Changed">
			<xsl:attribute name="style">
				<xsl:text>background-color:</xsl:text>
				<xsl:choose>
					<xsl:when test="@Changed = 'UPDATED'">#fdf636</xsl:when>
					<xsl:when test="@Changed = 'INSERTED'">#8efe5d</xsl:when>
					<xsl:when test="@Changed = 'DELETED'">#f35555</xsl:when>
				</xsl:choose>
			</xsl:attribute>
		</xsl:if>
	</xsl:template>

	<xsl:template match = "legend.term | legend.def">
		<xsl:apply-templates select="current()" mode="copyDiffAttributes"/>
		<xsl:apply-templates select="current()" mode="copyCharacterizationAttributes"/>
		<xsl:apply-templates/>
	</xsl:template>

	<!-- media legend paragraph -->
	<xsl:template match="paragraph">
		<xsl:apply-templates/>
	</xsl:template>


	<!-- *****************************************************************

											Unter Absatz (Zeichenformatierung)

***************************************************************** -->

	<xsl:template match = "no.linebreak">
		<InfoChunk.NoBreak>
			<xsl:copy-of select = "@*"/>
			<xsl:apply-templates/>
		</InfoChunk.NoBreak>
	</xsl:template>

	<xsl:template match = "superscript">
		<InfoChunk.High>
			<xsl:copy-of select="@*"/>
			<xsl:apply-templates/>
		</InfoChunk.High>
	</xsl:template>

	<xsl:template match = "subscript">
		<InfoChunk.Low>
			<xsl:copy-of select="@*"/>
			<xsl:apply-templates/>
		</InfoChunk.Low>
	</xsl:template>

	<xsl:template match = "emphasis">
		<InfoChunk.Important>
			<xsl:apply-templates select="current()" mode="copyCharacterizationAttributes"/>
			<xsl:apply-templates/>
		</InfoChunk.Important>
	</xsl:template>


	<xsl:template match = "emphasis2">
		<InfoChunk.Important2>
			<xsl:apply-templates/>
		</InfoChunk.Important2>
	</xsl:template>

	<xsl:template match = "emphasis3">
		<InfoChunk.Important3>
			<xsl:apply-templates/>
		</InfoChunk.Important3>
	</xsl:template>

	<xsl:template match = "inverted">
		<InfoChunk.Invers>
			<xsl:apply-templates/>
		</InfoChunk.Invers>
	</xsl:template>

	<xsl:template match = "code.inline">
		<InfoChunk.Code>
			<xsl:apply-templates/>
		</InfoChunk.Code>
	</xsl:template>

	<xsl:template match = "dialog">
		<InfoChunk.Dialog>
			<xsl:apply-templates/>
		</InfoChunk.Dialog>
	</xsl:template>
	<!--

	<xsl:template match = "invalid">
		<InfoChunk.Invalid>
			<xsl:apply-templates/>
		</InfoChunk.Invalid>
	</xsl:template>

	-->
	<xsl:template match = "index.entry">
		<Index>
			<!-- .//index.entry is because of Copy and Paste bug of altova -->
			<xsl:copy-of select="@* | .//index.entry/@*"/>
			<xsl:copy>
				<xsl:copy-of select="@* | .//index.entry/@* | ancestor-or-self::*[(name() = 'section' or name() = 'Start') and @defaultLanguage][1]/@defaultLanguage"/>
				<xsl:attribute name="ID">
					<xsl:value-of select="generate-id()"/>
				</xsl:attribute>
				<xsl:choose>
					<xsl:when test=".//MMFramework.Container">
						<xsl:apply-templates select=".//text()"/>
					</xsl:when>
					<xsl:otherwise>
						<xsl:apply-templates/>
					</xsl:otherwise>
				</xsl:choose>
			</xsl:copy>
		</Index>
	</xsl:template>

	<xsl:template match = "include.html">
			<xsl:copy>
				<xsl:copy-of select="@*"/>
				<xsl:copy-of select="content/*"/>
				<xsl:apply-templates select="RefControl"/>
			</xsl:copy>
	</xsl:template>
	

	<xsl:template match = "linebreak | line.break">
		<InfoChunk.Break/>
	</xsl:template>

	<xsl:template match = "footnote[not(parent::block.titlepage)]">
		<Link.note>
			<xsl:copy-of select="@*"/>
			<xsl:apply-templates/>
		</Link.note>
	</xsl:template>

	<xsl:template match="mathwrapper">
		<xsl:apply-templates/>
	</xsl:template>

	<xsl:template match="calc">
		<InfoPar isCalc="true">
			<xsl:value-of select="@result"/>
		</InfoPar>
	</xsl:template>

	<!-- Verwandte Themen -->

	<xsl:template match="related.themes">
		<InfoItem.RelatedLinks>
			<xsl:copy-of select="@type"/>
			<xsl:apply-templates select="current()" mode="copyDiffAttributes"/>
			<xsl:apply-templates select="current()" mode="copyCharacterizationAttributes"/>
			<xsl:apply-templates/>
		</InfoItem.RelatedLinks>
	</xsl:template>

	<xsl:template match="smc_font | smc_indent | smc_border | smc_spacing | smc_color | smc_pagination | smc_position | smc_layout | smc_columns | smc_hyphenation" mode="format">
		<xsl:if test="@*[. != '' and name() != 'visible' and name() != 'visibleButton' and name() != 'dummy']">
			<xsl:copy>
				<xsl:copy-of select="@*[. != '' and name() != 'visible' and name() != 'visibleButton' and name() != 'dummy']"/>
				<xsl:apply-templates/>
			</xsl:copy>
		</xsl:if>
	</xsl:template>

	<xsl:template match="smc_font | smc_indent | smc_border | smc_spacing | smc_color | smc_pagination | smc_position | smc_layout | smc_columns | smc_hyphenation">
		<xsl:apply-templates select="current()" mode="format"/>
	</xsl:template>

	<xsl:template match="smc_properties" mode="format">
		<xsl:apply-templates mode="format"/>
	</xsl:template>

	<xsl:template match="smc_properties">
		<xsl:apply-templates/>
	</xsl:template>

	<xsl:template match="Element">
		<xsl:copy>
			<xsl:copy-of select="@name | @isBlockType"/>
			<xsl:apply-templates/>
		</xsl:copy>
	</xsl:template>

	<xsl:template match="Element" mode="format">
		<xsl:copy>
			<xsl:copy-of select="@name | @isBlockType"/>
			<xsl:apply-templates mode="format"/>
		</xsl:copy>
	</xsl:template>

	<xsl:template match="link.file | Table | par | FileAssetReference" mode="format">
		<xsl:apply-templates select="current()"/>
	</xsl:template>

	<xsl:template match="Color" mode="format">
		<xsl:copy>
			<xsl:copy-of select="@*[name() != 'addMe' and name() != 'delButton' and string-length(.) &gt; 0]"/>
			<xsl:apply-templates mode="format"/>
		</xsl:copy>
	</xsl:template>

	<xsl:template match="Color">
		<xsl:copy>
			<xsl:copy-of select="@*[name() != 'addMe' and name() != 'delButton' and string-length(.) &gt; 0]"/>
			<xsl:apply-templates/>
		</xsl:copy>
	</xsl:template>

	<xsl:template match="if">
		<xsl:if test="*">
			<xsl:copy>
				<xsl:copy-of select="@*"/>
				<xsl:apply-templates/>
			</xsl:copy>
		</xsl:if>
	</xsl:template>

	<xsl:template match="if" mode="format">
		<xsl:if test="*">
			<xsl:copy>
				<xsl:copy-of select="@*"/>
				<xsl:apply-templates mode="format"/>
			</xsl:copy>
		</xsl:if>
	</xsl:template>

	<xsl:template match="index.entry" mode="printText">
		<xsl:if test="not(@notVisible = 'true')">
			<xsl:value-of select="."/>
		</xsl:if>
	</xsl:template>



	<xsl:template match="notes" mode="printText"/>
	<xsl:template match="footnote" mode="printText"/>

	<xsl:template match="euro" mode="printText">&#x20AC;</xsl:template>
	<xsl:template match="infinity" mode="printText">&#x221E;</xsl:template>
	<xsl:template match="copyright" mode="printText">©</xsl:template>
	<xsl:template match="right" mode="printText">&#xAE;</xsl:template>
	<xsl:template match="trademark" mode="printText">&#x2122;</xsl:template>
	<xsl:template match="diameter" mode="printText">&#x2205;</xsl:template>
	<xsl:template match="greater-equal" mode="printText">&#x2265;</xsl:template>
	<xsl:template match="smaller-equal" mode="printText">&#x2264;</xsl:template>
	<xsl:template match="not-equal" mode="printText">&#x2260;</xsl:template>
	<xsl:template match="per-mill" mode="printText">&#x2030;</xsl:template>
	<xsl:template match="rounding" mode="printText">&#x223C;</xsl:template>
	<xsl:template match="soft-hyphen" mode="printText">&#x00AD;</xsl:template>
	<xsl:template match="Delta" mode="printText">&#x2206;</xsl:template>
	<xsl:template match="Omega" mode="printText">&#x2126;</xsl:template>
	<xsl:template match="alpha" mode="printText">&#x03B1;</xsl:template>
	<xsl:template match="beta" mode="printText">&#x03B2;</xsl:template>
	<xsl:template match="gamma" mode="printText">&#x03B3;</xsl:template>
	<xsl:template match="delta" mode="printText">&#x03B4;</xsl:template>
	<xsl:template match="epsilon" mode="printText">&#x03B5;</xsl:template>
	<xsl:template match="theta" mode="printText">&#x03B8;</xsl:template>
	<xsl:template match="lambda" mode="printText">&#x03BB;</xsl:template>
	<xsl:template match="mu" mode="printText">&#xB5;</xsl:template>
	<xsl:template match="pi" mode="printText">&#x03C0;</xsl:template>
	<xsl:template match="plus-minus" mode="printText">&#xB1;</xsl:template>
	<xsl:template match="sqrt" mode="printText">&#x221A;</xsl:template>
	<xsl:template match="approx" mode="printText">&#x2248;</xsl:template>
	<xsl:template match="approx-equal" mode="printText">&#x2245;</xsl:template>
	<xsl:template match="times" mode="printText">&#xD7;</xsl:template>
	<xsl:template match="arrow-right" mode="printText">&#x2192;</xsl:template>
	<xsl:template match="arrow-down" mode="printText">&#x2193;</xsl:template>
	<xsl:template match="arrow-left" mode="printText">&#x2190;</xsl:template>
	<xsl:template match="arrow-up" mode="printText">&#x2191;</xsl:template>
	<xsl:template match="phi" mode="printText">&#x03C6;</xsl:template>
	<xsl:template match="eta" mode="printText">&#x03B7;</xsl:template>
	<xsl:template match="similar" mode="printText">&#x223C;</xsl:template>
	<xsl:template match="rho" mode="printText">&#x03C1;</xsl:template>
	<xsl:template match="tau" mode="printText">&#x03C4;</xsl:template>
	<xsl:template match="whitespace" mode="printText">&#160;</xsl:template>

	<xsl:template match="node()">
		<xsl:copy>
			<xsl:copy-of select="@*"/>
			<xsl:apply-templates/>
		</xsl:copy>
	</xsl:template>

</xsl:stylesheet>