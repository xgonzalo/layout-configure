<?xml version="1.0" encoding="utf-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" version = "1.0">

	<xsl:param name="useFormatOverwrite">false</xsl:param>

	<xsl:template name="setFormatOverwrite">
		<xsl:if test="$useFormatOverwrite = 'true'">
			<xsl:attribute name="formatOverwrite">
				<xsl:value-of select="name()"/>
			</xsl:attribute>
		</xsl:if>
	</xsl:template>

	<xsl:variable name="tableNoliensPreserveTableHead">
		<xsl:call-template name="getFormatVariableValue">
			<xsl:with-param name="name">TABLE_NOLINES_PRESERVE_TABLE_HEAD</xsl:with-param>
			<xsl:with-param name="defaultValue">false</xsl:with-param>
		</xsl:call-template>
	</xsl:variable>

	<xsl:template name="writeTableTitle">
		<xsl:param name="include"/>
		<title>
			<xsl:choose>
				<xsl:when test="$include/title[string-length(.) &gt; 0]">
					<xsl:apply-templates select="$include/title/node()"/>
				</xsl:when>
				<xsl:otherwise>
					<xsl:apply-templates select="title/* | title/text()"/>
				</xsl:otherwise>
			</xsl:choose>
		</title>
	</xsl:template>

	<xsl:template name="writeTableAttributes">
		<xsl:param name="TableDesc"/>
		<xsl:param name="includeTableDesc"/>
		<xsl:param name="preserveTableHead" select="true()"/>
		<xsl:param name="tableType"/>
		<xsl:attribute name="typ">
			<xsl:value-of select="$tableType"/>
		</xsl:attribute>
		<xsl:call-template name="setFormatOverwrite"/>
		<xsl:copy-of select="$TableDesc/@fontSizeModifier[string-length(.) &gt; 0 and . != '0']"/>
		<xsl:copy-of select="$includeTableDesc/@fontSizeModifier[string-length(.) &gt; 0 and . != '0']"/>
		<xsl:if test="$preserveTableHead">
			<xsl:copy-of select="$TableDesc/@headColumns"/>
			<xsl:copy-of select="$includeTableDesc/@headColumns[string-length(.) &gt; 0]"/>
		</xsl:if>
		<xsl:copy-of select="parent::*/@*"/>
	</xsl:template>

	<xsl:template name="Table">
		<xsl:variable name="TableDesc" select="following-sibling::TableDesc[1]"/>
		<xsl:variable name="include" select="ancestor::include[1]"/>
		<xsl:variable name="includeTableDesc" select="$include[@overwriteTableDesc = 'true']/TableDesc"/>
		<xsl:variable name="tableType" select="$includeTableDesc/@type[string-length(.) &gt; 0] | $TableDesc/@type"/>
		
		<xsl:variable name="includeMetafilter">
			<xsl:value-of select="ancestor::include[1]/@metafilter"/>
		</xsl:variable>
		<xsl:variable name="includeFilter">
			<xsl:value-of select="ancestor::include[1]/@filter"/>
		</xsl:variable>
		
		<xsl:variable name="tableMetafilter">
			<xsl:choose>
				<xsl:when test="string-length($includeMetafilter) &gt; 0 and string-length(@metafilter) &gt; 0">
					<xsl:value-of select="$includeMetafilter"/><xsl:text>,</xsl:text><xsl:value-of select="@metafilter"/>
				</xsl:when>
				<xsl:when test="string-length($includeMetafilter) &gt; 0 and not(string-length(@metafilter) &gt; 0)">
					<xsl:value-of select="$includeMetafilter"/>
				</xsl:when>
			</xsl:choose>
		</xsl:variable>

		<xsl:variable name="tableFilter">
			<xsl:choose>
				<xsl:when test="string-length($includeFilter) &gt; 0 and string-length(@filter) &gt; 0">
					<xsl:value-of select="$includeFilter"/><xsl:text>,</xsl:text><xsl:value-of select="@filter"/>
				</xsl:when>
				<xsl:when test="string-length($includeFilter) &gt; 0 and not(string-length(@filter) &gt; 0)">
					<xsl:value-of select="$includeFilter"/>
				</xsl:when>
			</xsl:choose>
		</xsl:variable>

		<xsl:if test="tgroup/*/row[entry]">
			<xsl:choose>
				<xsl:when test="$tableType='Nolines'">
					<table.NoBorder>
						<xsl:call-template name="writeTableAttributes">
							<xsl:with-param name="TableDesc" select="$TableDesc"/>
							<xsl:with-param name="includeTableDesc" select="$includeTableDesc"/>
							<xsl:with-param name="tableType" select="$tableType"/>
							<xsl:with-param name="preserveTableHead" select="$tableNoliensPreserveTableHead = 'true'"/>
						</xsl:call-template>

						<xsl:if test="string-length($tableFilter) &gt; 0">
							<xsl:attribute name="filter">
								<xsl:value-of select="$tableFilter"/>
							</xsl:attribute>
						</xsl:if>

						<xsl:if test="string-length($tableMetafilter) &gt; 0">
							<xsl:attribute name="metafilter">
								<xsl:value-of select="$tableMetafilter"/>
							</xsl:attribute>
						</xsl:if>
						<xsl:call-template name="writeTableTitle">
							<xsl:with-param name="include" select="$include"/>
						</xsl:call-template>
						<xsl:choose>
							<xsl:when test="$tableNoliensPreserveTableHead = 'true'">
								<xsl:apply-templates select="tgroup/*" mode="XpertAuthor">
									<xsl:with-param name="TableDesc" select="$TableDesc"/>
									<xsl:with-param name="includeTableDesc" select="$includeTableDesc"/>
								</xsl:apply-templates>
							</xsl:when>
							<xsl:otherwise>
								<xsl:apply-templates select="tgroup/*" mode="noHead"/>
							</xsl:otherwise>
						</xsl:choose>
					</table.NoBorder>
				</xsl:when>

				<xsl:when test="$tableType='List' or $tableType='API'">
					<table>
						<xsl:call-template name="writeTableAttributes">
							<xsl:with-param name="TableDesc" select="$TableDesc"/>
							<xsl:with-param name="includeTableDesc" select="$includeTableDesc"/>
							<xsl:with-param name="tableType" select="$tableType"/>
							<xsl:with-param name="preserveTableHead" select="false()"/>
						</xsl:call-template>
						<xsl:if test="string-length($tableFilter) &gt; 0">
							<xsl:attribute name="filter">
								<xsl:value-of select="$tableFilter"/>
							</xsl:attribute>
						</xsl:if>
						<xsl:if test="string-length($tableMetafilter) &gt; 0">
							<xsl:attribute name="metafilter">
								<xsl:value-of select="$tableMetafilter"/>
							</xsl:attribute>
						</xsl:if>
						<xsl:call-template name="writeTableTitle">
							<xsl:with-param name="include" select="$include"/>
						</xsl:call-template>
						<xsl:apply-templates select = "tgroup/*"  mode="noHead"/>
					</table>
				</xsl:when>

				<xsl:otherwise>
					<table>
						<xsl:call-template name="writeTableAttributes">
							<xsl:with-param name="TableDesc" select="$TableDesc"/>
							<xsl:with-param name="includeTableDesc" select="$includeTableDesc"/>
							<xsl:with-param name="tableType" select="$tableType"/>
						</xsl:call-template>
						<xsl:if test="string-length($tableFilter) &gt; 0">
							<xsl:attribute name="filter">
								<xsl:value-of select="$tableFilter"/>
							</xsl:attribute>
						</xsl:if>
						<xsl:if test="string-length($tableMetafilter) &gt; 0">
							<xsl:attribute name="metafilter">
								<xsl:value-of select="$tableMetafilter"/>
							</xsl:attribute>
						</xsl:if>
						<xsl:call-template name="writeTableTitle">
							<xsl:with-param name="include" select="$include"/>
						</xsl:call-template>
						<xsl:apply-templates select="tgroup/*" mode="XpertAuthor"/>
					</table>
				</xsl:otherwise>
			</xsl:choose>
		</xsl:if>
	</xsl:template>

	<xsl:template match="TableDesc">
		<xsl:copy>
			<xsl:copy-of select="@*"/>
			<xsl:variable name="includeTableDesc" select="ancestor::include[1][@overwriteTableDesc = 'true']/TableDesc"/>
			<xsl:copy-of select="$includeTableDesc/@*[string-length(.) &gt; 0]"/>
			<xsl:choose>
				<xsl:when test="$includeTableDesc/TableColSpec">
					<xsl:for-each select="TableColSpec">
						<xsl:copy>
							<xsl:copy-of select="@*"/>
							<xsl:variable name="pos" select="position()"/>
							<xsl:copy-of select="$includeTableDesc/TableColSpec[$pos]/@*[string-length(.) &gt; 0]"/>
						</xsl:copy>
					</xsl:for-each>
					<xsl:apply-templates select="*[name() != 'TableColSpec']"/>
				</xsl:when>
				<xsl:otherwise>
					<xsl:apply-templates/>
				</xsl:otherwise>
			</xsl:choose>
		</xsl:copy>
	</xsl:template>

	<xsl:template match="table">
		<xsl:choose>
			<xsl:when test="parent::Table">
				<xsl:call-template name="Table"/>
			</xsl:when>
			<xsl:otherwise>
				<xsl:apply-templates/>
			</xsl:otherwise>
		</xsl:choose>
	</xsl:template>

	<xsl:template match="Table">
		<xsl:choose>
			<xsl:when test="table">
				<xsl:apply-templates/>
			</xsl:when>
			<xsl:otherwise>
				<xsl:call-template name="Table"/>
			</xsl:otherwise>
		</xsl:choose>
	</xsl:template>


	<xsl:template match="thead | tfoot" mode="noHead"/>
	
	<xsl:template match="tbody" mode="noHead">
		<xsl:apply-templates select="../colspec" mode="XpertAuthor"/>
		<tableStandard>
			<xsl:apply-templates select="../thead/row"  mode="XpertAuthor"/>
			<xsl:apply-templates select="row"  mode="XpertAuthor"/>
			<xsl:apply-templates select="../tfoot/row"  mode="XpertAuthor"/>
		</tableStandard>
	</xsl:template>

	<xsl:template match="thead | tfoot" mode="XpertAuthor"/>

	<xsl:template match="tbody" mode="XpertAuthor">
		<xsl:param name="TableDesc" select="parent::tgroup/../../TableDesc"/>
		<xsl:param name="includeTableDesc" select="ancestor::include[1][@overwriteTableDesc = 'true']/TableDesc"/>

		<xsl:variable name="headRows_pre">
			<xsl:choose>
				<xsl:when test="$includeTableDesc/@headRows[string-length(.) &gt; 0]">
					<xsl:value-of select="$includeTableDesc/@headRows"/>
				</xsl:when>
				<xsl:otherwise>
					<xsl:value-of select="$TableDesc/@headRows"/>
				</xsl:otherwise>
			</xsl:choose>
		</xsl:variable>

		
		<xsl:variable name="hiddeHeader">
			<xsl:value-of select="$TableDesc/@hiddeHeader"/>
		</xsl:variable>

		<xsl:variable name="headRows">
			<xsl:choose>
				<xsl:when test="string-length($headRows_pre) &gt; 0">
					<xsl:value-of select="$headRows_pre"/>
				</xsl:when>
				<xsl:otherwise>
					<xsl:text>1</xsl:text>
				</xsl:otherwise>
			</xsl:choose>
		</xsl:variable>

		<xsl:variable name="rows" select="(../thead/row | row)"/>

		<xsl:if test="$headRows &gt; 0">
			<tableHead>
				<xsl:apply-templates select="$rows[position() &lt;= $headRows]" mode="XpertAuthor"/>
			</tableHead>
		</xsl:if>

		<tableStandard>
			<xsl:apply-templates select="$rows[position() &gt; $headRows]" mode="XpertAuthor"/>
			<xsl:apply-templates select="../tfoot/row" mode="XpertAuthor"/>
		</tableStandard>

	</xsl:template>

	<xsl:template match = "row"  mode="XpertAuthor">
		<tableRow>
			<xsl:copy-of select="@*"/>
			<!-- the nested row call is needed for br typo3 sync, see also #6512 -->
			<xsl:apply-templates select="entry | row" mode="XpertAuthor"/>
			<xsl:apply-templates select="notes"/>
		</tableRow>
	</xsl:template>

	<xsl:template match = "colspec"  mode="XpertAuthor">
		<xsl:copy>
			<xsl:copy-of select="@colname | @colnum"/>
			<xsl:attribute name="colwidth">
				<xsl:choose>
					<xsl:when test="contains(@colwidth, '*')">
						<xsl:value-of select="substring-before(@colwidth, '*')"/>
					</xsl:when>
					<xsl:otherwise>
						<xsl:value-of select="@colwidth"/>
					</xsl:otherwise>
				</xsl:choose>
			</xsl:attribute>
		</xsl:copy>
	</xsl:template>


	<xsl:template match = "entry"  mode="XpertAuthor">

		<xsl:variable name="namest" select="@namest"/>
		<xsl:variable name="nameend" select="@nameend"/>

		<xsl:variable name="pos1">
			<xsl:for-each select = "../../../colspec">
				<xsl:if test="@colname = $namest">
					<xsl:value-of select = "position()"/>
				</xsl:if>
			</xsl:for-each>
		</xsl:variable>

		<xsl:variable name="pos2">
			<xsl:for-each select = "../../../colspec">
				<xsl:if test = "@colname = $nameend">
					<xsl:value-of select = "position()"/>
				</xsl:if>
			</xsl:for-each>
		</xsl:variable>

		<xsl:element name="tableCell">

			<xsl:copy-of select="@*"/>

			<xsl:if test = "$pos1 + $pos2 &gt; 0">
				<xsl:attribute name = "hstraddle">
					<xsl:value-of select = "number($pos2) - number($pos1) + 1"/>
				</xsl:attribute>
			</xsl:if>
			<xsl:if test="@morerows &gt; 0">
				<xsl:attribute name = "vstraddle">
					<xsl:value-of select = "number(@morerows) + 1"/>
				</xsl:attribute>
			</xsl:if>

			<xsl:if test="parent::row/@Changed or @Changed">
				<xsl:attribute name="style">
					<xsl:text>background-color:</xsl:text>
					<xsl:choose>
						<xsl:when test="parent::row/@Changed = 'UPDATED' or @Changed = 'UPDATED'">#fdf636</xsl:when>
						<xsl:when test="parent::row/@Changed = 'INSERTED' or @Changed = 'INSERTED'">#8efe5d</xsl:when>
						<xsl:when test="parent::row/@Changed = 'DELETED' or @Changed = 'DELETED'">#f35555</xsl:when>
						<xsl:otherwise>#FFFFFF</xsl:otherwise>
					</xsl:choose>
				</xsl:attribute>
				<xsl:if test="string-length() = 0 and not(*)">
					<xsl:text>&#160;</xsl:text>
				</xsl:if>
			</xsl:if>

			<xsl:apply-templates/>
		</xsl:element>

	</xsl:template>


</xsl:stylesheet>
