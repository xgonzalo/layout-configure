<?xml version="1.0" encoding="utf-8"?>
<xsl:stylesheet version="1.0"
				xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
				xmlns:axf="http://www.antennahouse.com/names/XSL/Extensions"
				xmlns:fo="http://www.w3.org/1999/XSL/Format">

	<xsl:template match="InfoMap" mode="writeImFoRoot">
		<fo:root hyphenate="true">
			<xsl:apply-templates select="current()" mode="writeFoRootAttributes"/>

			<xsl:variable name="pageElems" select="Format/PageGeometry/Page"/>
			<xsl:apply-templates select="current()" mode="writeImLayoutMasterset">
				<xsl:with-param name="pageElems" select="$pageElems"/>
			</xsl:apply-templates>

			<xsl:call-template name="writeFoDeclarations"/>

			<xsl:apply-templates select="current()" mode="TOC"/>

			<xsl:for-each select="$pageElems">
				<xsl:variable name="level" select="position()"/>
				<fo:page-sequence master-reference="basicPSM{$level}">
					<xsl:if test="position() = last()">
						<xsl:attribute name="id">lastpagesequence</xsl:attribute>
					</xsl:if>
					<xsl:if test="$isRightToLeftLanguage">
						<xsl:attribute name="writing-mode">rl-tb</xsl:attribute>
					</xsl:if>
					<xsl:call-template name="applyPageSequenceAttribute">
						<xsl:with-param name="attributeName">initial-page-number</xsl:with-param>
						<xsl:with-param name="level">0</xsl:with-param>
					</xsl:call-template>
					<xsl:call-template name="applyPageSequenceAttribute">
						<xsl:with-param name="attributeName">force-page-count</xsl:with-param>
						<xsl:with-param name="level">0</xsl:with-param>
					</xsl:call-template>

					<xsl:call-template name="writeStaticContent">
						<xsl:with-param name="level" select="$level"/>
					</xsl:call-template>

					<fo:flow flow-name="xsl-region-body">
						<!--<xsl:if test="$DISABLE_COLUMN_BALANCING">
							<xsl:attribute name="fox:disable-column-balancing">true</xsl:attribute>
						</xsl:if>-->
						<xsl:apply-templates/>
						<xsl:if test="position() = 1">
							<xsl:apply-templates select="../StandardPageRegion/Content/*[name() != 'Headline.content' or string-length(.) &gt; 0 or *]"/>
						</xsl:if>
					</fo:flow>
				</fo:page-sequence>
			</xsl:for-each>
			<xsl:if test="count($pageElems) = 0">
				<fo:page-sequence master-reference="basicPSM">
					<fo:flow flow-name="xsl-region-body">
						<fo:block text-align="center" margin-top="5cm" font-size="24pt">WARNING: No pages are defined!</fo:block>
					</fo:flow>
				</fo:page-sequence>
			</xsl:if>
		</fo:root>
	</xsl:template>

	<xsl:template match="InfoMap" mode="writeImLayoutMasterset">
		<xsl:param name="pageElems"/>
		
		<fo:layout-master-set>
			<xsl:for-each select="$pageElems">
				<xsl:variable name="level" select="position()"/>
				<xsl:choose>
					<xsl:when test="ancestor::Format[1]/PageGeometry/StandardPageRegion">

						<xsl:apply-templates select="ancestor::Format[1]/PageGeometry/StandardPageRegion" mode="writeSimplePageMaster">
							<xsl:with-param name="level" select="$level"/>
						</xsl:apply-templates>

						<fo:page-sequence-master master-name="basicPSM{$level}">
							<fo:repeatable-page-master-alternatives>
								<xsl:if test="ancestor::Format[1]/PageGeometry/StandardPageRegion[@type = 'first']">
									<fo:conditional-page-master-reference master-reference="first{$level}" page-position="first" odd-or-even="any"/>
								</xsl:if>
								<xsl:choose>
									<xsl:when test="ancestor::Format[1]/PageGeometry/StandardPageRegion[@type = 'odd'] and ancestor::Format[1]/PageGeometry/StandardPageRegion[@type = 'even']">
										<fo:conditional-page-master-reference master-reference="odd{$level}" page-position="any" odd-or-even="odd"/>
										<fo:conditional-page-master-reference master-reference="even{$level}" page-position="any" odd-or-even="even"/>
									</xsl:when>
									<xsl:when test="ancestor::Format[1]/PageGeometry/StandardPageRegion[@type = 'odd']">
										<fo:conditional-page-master-reference master-reference="odd{$level}" page-position="any" odd-or-even="any"/>
									</xsl:when>
									<xsl:when test="ancestor::Format[1]/PageGeometry/StandardPageRegion[@type = 'even']">
										<fo:conditional-page-master-reference master-reference="even{$level}" page-position="any" odd-or-even="any"/>
									</xsl:when>
									<xsl:when test="count(ancestor::Format[1]/PageGeometry/StandardPageRegion[@type = 'first']) = count(ancestor::Format[1]/PageGeometry/StandardPageRegion)">
										<fo:conditional-page-master-reference master-reference="first{$level}" page-position="any" odd-or-even="any"/>
									</xsl:when>
									<xsl:when test="ancestor::Format[1]/PageGeometry/StandardPageRegion[string-length(@type) = 0]">
										<fo:conditional-page-master-reference master-reference="odd{$level}" page-position="any" odd-or-even="any"/>
									</xsl:when>
								</xsl:choose>
							</fo:repeatable-page-master-alternatives>
						</fo:page-sequence-master>


					</xsl:when>
					<xsl:otherwise>
						<xsl:variable name="defaultUnit">
							<xsl:choose>
								<xsl:when test="string-length(ancestor::Format[1]/PageGeometry/@unit) &gt; 0">
									<xsl:value-of select="ancestor::Format[1]/PageGeometry/@unit"/>
								</xsl:when>
								<xsl:otherwise>mm</xsl:otherwise>
							</xsl:choose>
						</xsl:variable>
						<xsl:variable name="defaultPageWidth">
							<xsl:choose>
								<xsl:when test="string-length(ancestor::Format[1]/PageGeometry/@width) &gt; 0">
									<xsl:value-of select="concat(ancestor::Format[1]/PageGeometry/@width, $defaultUnit)"/>
								</xsl:when>
								<xsl:otherwise>mm</xsl:otherwise>
							</xsl:choose>
						</xsl:variable>
						<xsl:variable name="defaultPageHeight">
							<xsl:choose>
								<xsl:when test="string-length(ancestor::Format[1]/PageGeometry/@height) &gt; 0">
									<xsl:value-of select="concat(ancestor::Format[1]/PageGeometry/@height, $defaultUnit)"/>
								</xsl:when>
								<xsl:otherwise>mm</xsl:otherwise>
							</xsl:choose>
						</xsl:variable>
						<xsl:call-template name="writeSimplePageMaster">
							<xsl:with-param name="level" select="$level"/>
							<xsl:with-param name="pageWidth" select="$defaultPageWidth"/>
							<xsl:with-param name="pageHeight" select="$defaultPageHeight"/>
							<xsl:with-param name="type">odd</xsl:with-param>
						</xsl:call-template>
						<fo:page-sequence-master master-name="basicPSM{$level}">
							<fo:repeatable-page-master-alternatives>
								<fo:conditional-page-master-reference master-reference="odd{$level}" page-position="any" odd-or-even="any"/>
							</fo:repeatable-page-master-alternatives>
						</fo:page-sequence-master>
					</xsl:otherwise>
				</xsl:choose>
			</xsl:for-each>
		</fo:layout-master-set>
	</xsl:template>

	<xsl:template match="Region">

		<xsl:variable name="unit" select="ancestor::Format[1]/PageGeometry/@unit"/>
		<xsl:choose>
			<xsl:when test="Box/@float = 'true'">
				<xsl:variable name="columns">
					<xsl:call-template name="getStandardPageRegionFormat">
						<xsl:with-param name="pageRegionType">odd</xsl:with-param>
						<xsl:with-param name="name">column-count</xsl:with-param>
						<xsl:with-param name="defaultValue">
							<xsl:call-template name="getStandardPageRegionFormat">
								<xsl:with-param name="pageRegionType">even</xsl:with-param>
								<xsl:with-param name="name">column-count</xsl:with-param>
								<xsl:with-param name="defaultValue" select="1"/>
							</xsl:call-template>
						</xsl:with-param>
					</xsl:call-template>
				</xsl:variable>
				<xsl:variable name="xFloat">
					<xsl:choose>
						<xsl:when test="string-length(Box/@float-x) &gt; 0">
							<xsl:value-of select="Box/@float-x"/>
						</xsl:when>
						<xsl:otherwise>left</xsl:otherwise>
					</xsl:choose>
				</xsl:variable>
				<xsl:variable name="floatRef">
					<xsl:choose>
						<xsl:when test="$columns &gt; 1">multicol</xsl:when>
						<xsl:otherwise>page</xsl:otherwise>
					</xsl:choose>
				</xsl:variable>
				<fo:float axf:float-x="{$xFloat}" axf:float-y="top" axf:float-reference="{$floatRef}">
					<xsl:if test="string-length(Box/@y) &gt; 0">
						<xsl:attribute name="axf:float-offset-y">
							<xsl:value-of select="concat(Box/@y, $unit)"/>
						</xsl:attribute>
					</xsl:if>
					<xsl:if test="string-length(Box/@x) &gt; 0">
						<xsl:attribute name="axf:float-offset-x">
							<xsl:value-of select="concat(Box/@x, $unit)"/>
						</xsl:attribute>
					</xsl:if>
					<fo:block-container>
						<xsl:attribute name="width">
							<xsl:value-of select="concat(Box/@width, $unit)"/>
						</xsl:attribute>
						<xsl:attribute name="height">
							<xsl:value-of select="concat(number(Box/@height), $unit)"/>
						</xsl:attribute>
						<xsl:attribute name="overflow">hidden</xsl:attribute>
						<xsl:if test="not(@border) or @border != 'false'">
							<xsl:copy-of select="@border-top-width | @border-bottom-width | @border-left-width | @border-right-width"/>
							<xsl:attribute name="border-width">0pt</xsl:attribute>
							<xsl:attribute name="border-style">solid</xsl:attribute>
							<xsl:attribute name="border-color">#000000</xsl:attribute>
							<!--<xsl:attribute name="border-width">1pt</xsl:attribute>
							<xsl:attribute name="border-style">solid</xsl:attribute>
							<xsl:attribute name="border-color">red</xsl:attribute>-->
						</xsl:if>
						<xsl:copy-of select="@background-color"/>
						<xsl:choose>
							<xsl:when test="@vertical-align = 'bottom'">
								<xsl:attribute name="display-align">after</xsl:attribute>
							</xsl:when>
							<xsl:when test="@vertical-align = 'middle'">
								<xsl:attribute name="display-align">center</xsl:attribute>
							</xsl:when>
						</xsl:choose>
						<xsl:if test="string-length(@formatRef) &gt; 0">
							<xsl:call-template name="addStyle">
								<xsl:with-param name="name" select="@formatRef"/>
							</xsl:call-template>
						</xsl:if>
						<fo:block>
							<xsl:apply-templates select="*[name() != 'InfoPar' or string-length(.) &gt; 0 or Media.theme]"/>
						</fo:block>
					</fo:block-container>
				</fo:float>
			</xsl:when>
			<xsl:otherwise>
				<fo:block-container absolute-position="fixed">
					<xsl:attribute name="top">
						<xsl:value-of select="concat(Box/@y, $unit)"/>
					</xsl:attribute>
					<xsl:attribute name="left">
						<xsl:value-of select="concat(Box/@x, $unit)"/>
					</xsl:attribute>
					<xsl:attribute name="width">
						<xsl:value-of select="concat(Box/@width, $unit)"/>
					</xsl:attribute>
					<xsl:attribute name="height">
						<xsl:value-of select="concat(number(Box/@height) + 2, $unit)"/>
					</xsl:attribute>
					<xsl:attribute name="overflow">hidden</xsl:attribute>
					<xsl:if test="not(@border) or @border != 'false'">
						<xsl:copy-of select="@border-top-width | @border-bottom-width | @border-left-width | @border-right-width"/>
						<xsl:attribute name="border-width">0pt</xsl:attribute>
						<xsl:attribute name="border-style">solid</xsl:attribute>
						<xsl:attribute name="border-color">#000000</xsl:attribute>
					</xsl:if>
					<xsl:copy-of select="@background-color"/>
					<xsl:choose>
						<xsl:when test="@vertical-align = 'bottom'">
							<xsl:attribute name="display-align">after</xsl:attribute>
						</xsl:when>
						<xsl:when test="@vertical-align = 'middle'">
							<xsl:attribute name="display-align">center</xsl:attribute>
						</xsl:when>
					</xsl:choose>
					<xsl:if test="string-length(@formatRef) &gt; 0">
						<xsl:call-template name="addStyle">
							<xsl:with-param name="name" select="@formatRef"/>
						</xsl:call-template>
					</xsl:if>
					<fo:block>
						<xsl:apply-templates select="*[name() != 'InfoPar' or string-length(.) &gt; 0 or Media.theme]"/>
					</fo:block>
				</fo:block-container>
			</xsl:otherwise>
		</xsl:choose>
	</xsl:template>

</xsl:stylesheet>
