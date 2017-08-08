<?xml version="1.0" encoding="utf-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" version="1.0">
        
        <xsl:param name="safety-information" select="1" />
        <xsl:param name="tables" select="1" />
        <xsl:param name="page-width" select="297" />
        <xsl:param name="page-height" select="210" />
        <xsl:param name="number-of-columns" select="2" />
        <xsl:param name="headeroutside" select="logo" />
        <xsl:param name="headermiddle" select="main-title" />
        <xsl:param name="headerinside" select="publish-date" />
        <xsl:param name="footeroutside" select="product-name" />
        <xsl:param name="footermiddle" select="version-number" />
        <xsl:param name="footerinside" select="page-number" />
        <xsl:param name="personalizationimage" select="''" />
        <xsl:param name="img-width" select="591" />
        <xsl:param name="img-height" select="473" />
        <xsl:param name="personalizationlogo" select="''" />
        <xsl:param name="logo-width" select="''" />
        <xsl:param name="logo-height" select="''" />
        <xsl:param name="basePath" select="'.'" />

        <xsl:variable name="logo">
                <xsl:choose>
                        <xsl:when test="$personalizationlogo != ''">
                                <media.theme>
                                        <RefControl PickerElement="media.theme" TargetTitle="2W_Logo_K" defaultTitle="" language="de">
                                                <File>
                                                        <xsl:attribute name="isUploaded" select="'true'" />
                                                        <xsl:attribute name="itemName" select="'original'" />
                                                        <xsl:attribute name="language" select="'de'" />
                                                        <xsl:attribute name="basePath" select="$basePath" />
                                                        <xsl:attribute name="url" select="$personalizationlogo" />
                                                        <MetaProperties>
                                                                <MetaProperty>
                                                                    <xsl:attribute name="name" select="'SMCIMG:height'" />
                                                                    <xsl:attribute name="value" select="$logo-height" />
                                                                </MetaProperty>
                                                                <MetaProperty>
                                                                    <xsl:attribute name="name" select="'SMCIMG:width'" />
                                                                    <xsl:attribute name="value" select="$logo-width" />
                                                                </MetaProperty>
                                                        </MetaProperties>
                                                </File>
                                        </RefControl>
                                </media.theme>
                        </xsl:when>
                        <xsl:otherwise>
                                <media.theme>
                                        <RefControl PickerElement="media.theme" TargetTitle="halftone-with-highlighting" defaultTitle="" language="de" lastModificationDate="2015-06-30 22:21:15 +0200" location="/framework/css/images" objType="mediaset" resolvedLanguage="de" serverID="JACKRABBIT" versionLabel="1.0" webdavID="1429399381185">
                                                <File>
                                                        <xsl:attribute name="isTypeOfImage" select="'true'" />
                                                        <xsl:attribute name="itemName" select="'original'" />
                                                        <xsl:attribute name="language" select="'de'" />
                                                        <xsl:attribute name="basePath" select="$basePath" />
                                                        <xsl:choose>
                                                            <xsl:when test="(($page-width = '210') and (number($page-width) &gt; number($page-height))) or (($page-height = '210') and number($page-height) &gt; number($page-width))"> <!-- A5 -->
                                                                <xsl:attribute name="url" select="'logo-pdf-a5.png'" />
                                                            </xsl:when>
                                                            <xsl:otherwise>
                                                                <xsl:attribute name="url" select="'logo-pdf.png'" />
                                                            </xsl:otherwise>
                                                        </xsl:choose>
                                                </File>
                                        </RefControl>
                                </media.theme>
                        </xsl:otherwise>
                </xsl:choose>
        </xsl:variable>
        
        <xsl:template match="/*">
                <Result>
                        <xsl:apply-templates select="(/*/Branch/Object/RefControl[starts-with(@TargetTitle, '2W MainService_A4vertical_2colums')]/Format)[1]"/>
                        <xsl:copy-of select="(/*/Branch/Object/RefControl/Strings)[1]"/>
                </Result>
        </xsl:template>
        
        <xsl:template match="Element[@name='PageMargins']/smc_properties/smc_columns">
                <smc_columns>
                        <xsl:attribute name="column-count" select="$number-of-columns" />
                        <xsl:attribute name="column-gap" select="'20'" />
                        <xsl:attribute name="dummy" />
                        <xsl:attribute name="span" />
                        <xsl:attribute name="visible" select="'false'" />
                        <xsl:attribute name="visibleButton" select="'fixed'" />
                </smc_columns>
        </xsl:template>
        
        <xsl:template match="Element[@name='WaterMark']" />
        
        <xsl:template match="PageGeometry">
                <PageGeometry>
                        <xsl:attribute name="height" select="$page-height" />
                        <xsl:attribute name="unit" select="'mm'" />
                        <xsl:attribute name="visible" select="'true'" />
                        <xsl:attribute name="visibleButton" select="'fixed'" />
                        <xsl:attribute name="width" select="$page-width" />
                        <xsl:apply-templates />
                </PageGeometry>
        </xsl:template>
        
        <xsl:template match="StandardPageRegion">
                <StandardPageRegion>
                        <xsl:choose>
                                <xsl:when test="position() > 1">
                                        <xsl:attribute name="formatRef" select="'PageMargins'" />
                                        <xsl:choose>
                                                <xsl:when test="position() mod 2 = 0">
                                                        <xsl:attribute name="type" select="'odd'" />
                                                </xsl:when>
                                                <xsl:otherwise>
                                                        <xsl:attribute name="type" select="'even'" />
                                                </xsl:otherwise>
                                        </xsl:choose>
                                </xsl:when>
                                <xsl:otherwise>
                                        <xsl:attribute name="formatRef" select="'PageMarginsFirst'" />
                                        <xsl:attribute name="type" select="'first'" />
                                </xsl:otherwise>
                        </xsl:choose>
                        <xsl:attribute name="height" select="$page-height" />
                        <xsl:attribute name="inherit" />
                        <xsl:attribute name="sectionType" />
                        <xsl:attribute name="width" select="$page-width" />
                        <xsl:apply-templates />
                </StandardPageRegion>
        </xsl:template>
        
        <xsl:template name="renderHeadlineContentOutside">
                <xsl:choose>
                        <xsl:when test="$headeroutside = 'main-title'">
                                <variable name="title2"/>
                        </xsl:when>
                        <xsl:when test="$headeroutside = 'chapter-title'">
                                <variable name="title"/>
                        </xsl:when>
                        <xsl:when test="$headeroutside = 'main-title-and-chapter-title'">
                                <variable name="title"/>
                                <variable name="title2WithPrefix" />
                        </xsl:when>
                        <xsl:when test="$headeroutside = 'logo'">
                                <xsl:copy-of select="$logo" />
                        </xsl:when>
                        <xsl:when test="$headeroutside = 'publish-date'">
                                <variable name="titlepage.date"/>
                        </xsl:when>
                        <xsl:when test="$headeroutside = 'product-name'">
                                <variable name="titlepage.title"/>
                        </xsl:when>
                        <xsl:when test="$headeroutside = 'version-number'">
                                <variable name="titlepage.version"/>
                        </xsl:when>
                        <xsl:when test="$headeroutside = 'document-name'">
                                <variable name="titlepage.title.theme"/>
                        </xsl:when>
                </xsl:choose>
        </xsl:template>
        
        <xsl:template name="renderHeadlineContentInside">
                <xsl:choose>
                        <xsl:when test="$headerinside = 'main-title'">
                                <variable name="title2"/>
                        </xsl:when>
                        <xsl:when test="$headerinside = 'chapter-title'">
                                <variable name="title"/>
                        </xsl:when>
                        <xsl:when test="$headerinside = 'main-title-and-chapter-title'">
                                <variable name="title"/>
                                <variable name="title2WithPrefix" />
                        </xsl:when>
                        <xsl:when test="$headerinside = 'logo'">
                                <xsl:copy-of select="$logo" />
                        </xsl:when>
                        <xsl:when test="$headerinside = 'publish-date'">
                                <variable name="titlepage.date"/>
                        </xsl:when>
                        <xsl:when test="$headerinside = 'product-name'">
                                <variable name="titlepage.title"/>
                        </xsl:when>
                        <xsl:when test="$headerinside = 'version-number'">
                                <variable name="titlepage.version"/>
                        </xsl:when>
                        <xsl:when test="$headerinside = 'document-name'">
                                <variable name="titlepage.title.theme"/>
                        </xsl:when>
                </xsl:choose>
        </xsl:template>
        
        <xsl:template match="Element[@name='headernote-top-text-odd']/smc_properties">
            <xsl:choose>
                <xsl:when test="(($page-width = '210') and (number($page-width) &gt; number($page-height))) or (($page-height = '210') and number($page-height) &gt; number($page-width))"> <!-- A5 -->
                    <smc_properties>
                        <smc_font dummy="" font-size="10" font-size-unit="pt" font-weight="" reference-orientation="" text-align="" visible="false" visibleButton="fixed"/>
                        <smc_indent dummy="" start-indent="" start-indent-unit="" text-indent="" text-indent-unit="" visible="false" visibleButton="fixed"/>
                        <smc_border border-bottom-style="" border-bottom-width="" border-left-width="" border-right-width="0" border-style="" border-top-width="" border-width="0" dummy="" unit="pt" visible="false" visibleButton="fixed"/>
                        <smc_spacing dummy="" margin-bottom="" margin-left="" margin-right="" margin-top="" padding-bottom="0.5" padding-left="0" padding-right="0" padding-top="0" space-after="" space-after-unit="mm" space-before="" space-before-unit="mm" unit="mm" visible="false" visibleButton="fixed"/>
                        <smc_color dummy="" visible="false" visibleButton="fixed"/>
                        <smc_pagination dummy="" visible="false" visibleButton="fixed"/>
                        <smc_position bottom="" dummy="" height="" height-unit="" left="" position="" position-unit="mm" right="" top="" visible="false" visibleButton="fixed" width="" width-unit=""/>
                        <smc_layout clear="" dummy="" float="" visible="false" visibleButton="fixed"/>
                    </smc_properties>
                </xsl:when>
                <xsl:otherwise>
                    <smc_properties>
                        <smc_font dummy="" font-size="12" font-size-unit="pt" font-weight="" reference-orientation="" text-align="" visible="false" visibleButton="fixed"/>
                        <smc_indent dummy="" start-indent="" start-indent-unit="" text-indent="" text-indent-unit="" visible="false" visibleButton="fixed"/>
                        <smc_border border-bottom-style="" border-bottom-width="" border-left-width="" border-right-width="0" border-style="" border-top-width="" border-width="0" dummy="" unit="pt" visible="false" visibleButton="fixed"/>
                        <smc_spacing dummy="" margin-bottom="" margin-left="" margin-right="" margin-top="" padding-bottom="0.5" padding-left="0" padding-right="0" padding-top="0" space-after="" space-after-unit="mm" space-before="" space-before-unit="mm" unit="mm" visible="false" visibleButton="fixed"/>
                        <smc_color dummy="" visible="false" visibleButton="fixed"/>
                        <smc_pagination dummy="" visible="false" visibleButton="fixed"/>
                        <smc_position bottom="" dummy="" height="" height-unit="" left="" position="" position-unit="mm" right="" top="" visible="false" visibleButton="fixed" width="" width-unit=""/>
                        <smc_layout clear="" dummy="" float="" visible="false" visibleButton="fixed"/>
                    </smc_properties>
                </xsl:otherwise>
            </xsl:choose>
        </xsl:template>
        
        <xsl:template match="Element[@name='headernote-top-text-even']/smc_properties">
            <xsl:choose>
                <xsl:when test="(($page-width = '210') and (number($page-width) &gt; number($page-height))) or (($page-height = '210') and number($page-height) &gt; number($page-width))"> <!-- A5 -->
                    <smc_properties>
                        <smc_font dummy="" font-size="10" font-size-unit="pt" vertical-align="" visible="false" visibleButton="fixed"/>
                        <smc_indent dummy="" visible="false" visibleButton="fixed"/>
                        <smc_border border-bottom-style="" border-bottom-width="" border-left-width="" border-right-width="0" border-style="" border-top-width="" border-width="0" dummy="" unit="pt" visible="false" visibleButton="fixed"/>
                        <smc_spacing dummy="" margin-right="" margin-top="" padding-bottom="0.5" padding-left="0" padding-right="0" padding-top="0" space-before="" unit="mm" visible="false" visibleButton="fixed"/>
                        <smc_color dummy="" visible="false" visibleButton="fixed"/>
                        <smc_pagination dummy="" visible="false" visibleButton="fixed"/>
                        <smc_position bottom="" dummy="" height="" height-unit="" left="" position="" position-unit="mm" right="" top="" visible="false" visibleButton="fixed" width="" width-unit=""/>
                    </smc_properties>
                </xsl:when>
                <xsl:otherwise>
                    <smc_properties>
                        <smc_font dummy="" font-size="12" font-size-unit="pt" vertical-align="" visible="false" visibleButton="fixed"/>
                        <smc_indent dummy="" visible="false" visibleButton="fixed"/>
                        <smc_border border-bottom-style="" border-bottom-width="" border-left-width="" border-right-width="0" border-style="" border-top-width="" border-width="0" dummy="" unit="pt" visible="false" visibleButton="fixed"/>
                        <smc_spacing dummy="" margin-right="" margin-top="" padding-bottom="0.5" padding-left="0" padding-right="0" padding-top="0" space-before="" unit="mm" visible="false" visibleButton="fixed"/>
                        <smc_color dummy="" visible="false" visibleButton="fixed"/>
                        <smc_pagination dummy="" visible="false" visibleButton="fixed"/>
                        <smc_position bottom="" dummy="" height="" height-unit="" left="" position="" position-unit="mm" right="" top="" visible="false" visibleButton="fixed" width="" width-unit=""/>
                    </smc_properties>
                </xsl:otherwise>
            </xsl:choose>
        </xsl:template>
        
        <xsl:template match="Element[@name='headernote-top']/smc_properties">
            <xsl:choose>
                <xsl:when test="(($page-width = '210') and (number($page-width) &gt; number($page-height))) or (($page-height = '210') and number($page-height) &gt; number($page-width))"> <!-- A5 -->
                    <smc_properties>
                        <smc_font dummy="" font-size="10" font-size-unit="pt" font-weight="" reference-orientation="" text-align="" visible="false" visibleButton="fixed"/>
                        <smc_indent dummy="" start-indent="" start-indent-unit="" text-indent="" text-indent-unit="" visible="false" visibleButton="fixed"/>
                        <smc_border border-bottom-style="" border-bottom-width="" border-left-width="" border-right-width="0" border-style="" border-top-width="" border-width="0" dummy="" unit="pt" visible="false" visibleButton="fixed"/>
                        <smc_spacing dummy="" margin-bottom="" margin-left="" margin-right="" margin-top="" padding-bottom="1" padding-left="0" padding-right="0" padding-top="0" space-after="" space-after-unit="mm" space-before="" space-before-unit="mm" unit="mm" visible="false" visibleButton="fixed"/>
                        <smc_color dummy="" visible="false" visibleButton="fixed"/>
                        <smc_pagination dummy="" visible="false" visibleButton="fixed"/>
                        <smc_position bottom="" dummy="" height="" height-unit="" left="" position="" position-unit="mm" right="" top="" visible="false" visibleButton="fixed" width="" width-unit=""/>
                        <smc_layout clear="" dummy="" float="" visible="false" visibleButton="fixed"/>
                    </smc_properties>
                </xsl:when>
                <xsl:otherwise>
                    <smc_properties>
                        <smc_font dummy="" font-size="12" font-size-unit="pt" vertical-align="" visible="false" visibleButton="fixed"/>
                        <smc_indent dummy="" visible="false" visibleButton="fixed"/>
                        <smc_border border-bottom-style="" border-bottom-width="" border-left-width="" border-right-width="0" border-style="" border-top-width="" border-width="0" dummy="" unit="pt" visible="false" visibleButton="fixed"/>
                        <smc_spacing dummy="" margin-right="" margin-top="" padding-bottom="0.5" padding-left="0" padding-right="0" padding-top="0" space-before="" unit="mm" visible="false" visibleButton="fixed"/>
                        <smc_color dummy="" visible="false" visibleButton="fixed"/>
                        <smc_pagination dummy="" visible="false" visibleButton="fixed"/>
                        <smc_position bottom="" dummy="" height="" height-unit="" left="" position="" position-unit="mm" right="" top="" visible="false" visibleButton="fixed" width="" width-unit=""/>
                    </smc_properties>
                </xsl:otherwise>
            </xsl:choose>
        </xsl:template>
        
        <xsl:template name="renderHeadlineContentMiddle">
                <xsl:choose>
                        <xsl:when test="$headermiddle = 'main-title'">
                                <variable name="title2"/>
                        </xsl:when>
                        <xsl:when test="$headermiddle = 'chapter-title'">
                                <variable name="title"/>
                        </xsl:when>
                        <xsl:when test="$headermiddle = 'main-title-and-chapter-title'">
                                <variable name="title"/>
                                <variable name="title2WithPrefix" />
                        </xsl:when>
                        <xsl:when test="$headermiddle = 'logo'">
                                <xsl:copy-of select="$logo" />
                        </xsl:when>
                        <xsl:when test="$headermiddle = 'publish-date'">
                                <variable name="titlepage.date"/>
                        </xsl:when>
                        <xsl:when test="$headermiddle = 'product-name'">
                                <variable name="titlepage.title"/>
                        </xsl:when>
                        <xsl:when test="$headermiddle = 'version-number'">
                                <variable name="titlepage.version"/>
                        </xsl:when>
                        <xsl:when test="$headermiddle = 'document-name'">
                                <variable name="titlepage.title.theme"/>
                        </xsl:when>
                </xsl:choose>
        </xsl:template>
        
        <xsl:template name="renderSublineContentOutside">
                <xsl:choose>
                        <xsl:when test="$footeroutside = 'main-title'">
                                <variable name="title2"/>
                        </xsl:when>
                        <xsl:when test="$footeroutside = 'chapter-title'">
                                <variable name="title"/>
                        </xsl:when>
                        <xsl:when test="$footeroutside = 'main-title-and-chapter-title'">
                                <variable name="title"/>
                                <variable name="title2WithPrefix" />
                        </xsl:when>
                        <xsl:when test="$footeroutside = 'logo'">
                                <xsl:copy-of select="$logo" />
                        </xsl:when>
                        <xsl:when test="$footeroutside = 'publish-date'">
                                <variable name="titlepage.date"/>
                        </xsl:when>
                        <xsl:when test="$footeroutside = 'product-name'">
                                <variable name="titlepage.title"/>
                        </xsl:when>
                        <xsl:when test="$footeroutside = 'version-number'">
                                <variable name="titlepage.version"/>
                        </xsl:when>
                        <xsl:when test="$footeroutside = 'document-name'">
                                <variable name="titlepage.title.theme"/>
                        </xsl:when>
                        <xsl:when test="$footeroutside = 'page-number'">
                                <variable name="pageName"/>
                        </xsl:when>
                </xsl:choose>
        </xsl:template>
        
        <xsl:template name="renderSublineContentInside">
                <xsl:choose>
                        <xsl:when test="$footerinside = 'main-title'">
                                <variable name="title2"/>
                        </xsl:when>
                        <xsl:when test="$footerinside = 'chapter-title'">
                                <variable name="title"/>
                        </xsl:when>
                        <xsl:when test="$footerinside = 'main-title-and-chapter-title'">
                                <variable name="title"/>
                                <variable name="title2WithPrefix" />
                        </xsl:when>
                        <xsl:when test="$footerinside = 'logo'">
                                <xsl:copy-of select="$logo" />
                        </xsl:when>
                        <xsl:when test="$footerinside = 'publish-date'">
                                <variable name="titlepage.date"/>
                        </xsl:when>
                        <xsl:when test="$footerinside = 'product-name'">
                                <variable name="titlepage.title"/>
                        </xsl:when>
                        <xsl:when test="$footerinside = 'version-number'">
                                <variable name="titlepage.version"/>
                        </xsl:when>
                        <xsl:when test="$footerinside = 'document-name'">
                                <variable name="titlepage.title.theme"/>
                        </xsl:when>
                        <xsl:when test="$footerinside = 'page-number'">
                                <variable name="pageName"/>
                        </xsl:when>
                </xsl:choose>
        </xsl:template>
        
        <xsl:template name="renderSublineContentMiddle">
                <xsl:choose>
                        <xsl:when test="$footermiddle = 'main-title'">
                                <variable name="title2"/>
                        </xsl:when>
                        <xsl:when test="$footermiddle = 'chapter-title'">
                                <variable name="title"/>
                        </xsl:when>
                        <xsl:when test="$footermiddle = 'main-title-and-chapter-title'">
                                <variable name="title"/>
                                <variable name="title2WithPrefix" />
                        </xsl:when>
                        <xsl:when test="$footermiddle = 'logo'">
                                <xsl:copy-of select="$logo" />
                        </xsl:when>
                        <xsl:when test="$footermiddle = 'publish-date'">
                                <variable name="titlepage.date"/>
                        </xsl:when>
                        <xsl:when test="$footermiddle = 'product-name'">
                                <variable name="titlepage.title"/>
                        </xsl:when>
                        <xsl:when test="$footermiddle = 'version-number'">
                                <variable name="titlepage.version"/>
                        </xsl:when>
                        <xsl:when test="$footermiddle = 'document-name'">
                                <variable name="titlepage.title.theme"/>
                        </xsl:when>
                        <xsl:when test="$footermiddle = 'page-number'">
                                <variable name="pageName"/>
                        </xsl:when>
                </xsl:choose>
        </xsl:template>
        
        <xsl:template match="Subline">
            <Subline height="8">
                <par>
                    <formatRef formatRef="WaterMark"/>
                </par>
                <xsl:apply-templates />
            </Subline>
        </xsl:template>
        
        <xsl:template match="StandardPageRegion[@formatRef='PageMargins'][@type='odd']/Headline/par/formatRef[@formatRef='WaterMark']" />
        
        <xsl:template match="StandardPageRegion[@formatRef='PageMargins'][@type='odd']/Headline">
            <Headline deltaHeightSign="" height="20">
                <xsl:apply-templates />
            </Headline>
        </xsl:template>
        
        <!-- ODD -->
        <xsl:template match="StandardPageRegion[@formatRef='PageMargins'][@type='odd']/Headline//entry">
                <xsl:choose>
                        <xsl:when test="@align='center'">
                                <entry align="center" valign="bottom">
                                        <formatRef formatRef="headernote-top-text-odd"/>
                                        <par>
                                                <xsl:call-template name="renderHeadlineContentMiddle" />
                                        </par>
                                </entry>
                        </xsl:when>
                        <xsl:when test="@align='right'">
                                <entry align="right" valign="bottom">
                                        <formatRef formatRef="headernote-top-text-odd"/>
                                        <par>
                                                <xsl:call-template name="renderHeadlineContentInside" />
                                        </par>
                                </entry>
                        </xsl:when>
                        <xsl:otherwise>
                                <entry valign="bottom">
                                        <formatRef formatRef="headernote-top"/>
                                        <par>
                                                <xsl:call-template name="renderHeadlineContentOutside" />
                                        </par>
                                </entry>
                        </xsl:otherwise>
                </xsl:choose>
        </xsl:template>
        
        <xsl:template match="StandardPageRegion[@formatRef='PageMargins'][@type='odd']/Subline//entry">
                <xsl:choose>
                        <xsl:when test="@align='center'">
                                <entry align="center">
                                        <formatRef formatRef="footer"/>
                                        <par>
                                                <xsl:call-template name="renderSublineContentMiddle" />
                                        </par>
                                </entry>
                        </xsl:when>
                        <xsl:when test="@align='right'">
                                <entry align="right">
                                        <formatRef formatRef="footer"/>
                                        <par>
                                                <xsl:call-template name="renderSublineContentInside" />
                                        </par>
                                </entry>
                        </xsl:when>
                        <xsl:otherwise>
                                <entry align="left">
                                        <formatRef formatRef="footer"/>
                                        <par>
                                                <xsl:call-template name="renderSublineContentOutside" />
                                        </par>
                                </entry>
                        </xsl:otherwise>
                </xsl:choose>
        </xsl:template>
        
        <xsl:template match="StandardPageRegion[@formatRef='PageMarginsFirst']/Headline">
        </xsl:template>
        
        <xsl:template match="StandardPageRegion[@formatRef='PageMarginsFirst']/Subline/Table">
                <Table addTableButton="" delButton="" dummy="" firstTime="-" vector="">
                </Table>
        </xsl:template>
        
        <!-- EVEN -->
        <xsl:template match="StandardPageRegion[@formatRef='PageMargins'][@type='even']/Headline/par/formatRef[@formatRef='WaterMark']" />
        
        <xsl:template match="StandardPageRegion[@formatRef='PageMargins'][@type='even']/Headline">
            <Headline deltaHeightSign="" height="20">
                <xsl:apply-templates />
            </Headline>
        </xsl:template>
        
        <xsl:template match="StandardPageRegion[@formatRef='PageMargins'][@type='even']/Headline//entry">
                <xsl:choose>
                        <xsl:when test="@align='center'">
                                <entry align="center" valign="bottom">
                                        <formatRef formatRef="headernote-top-text-even"/>
                                        <par>
                                                <xsl:call-template name="renderHeadlineContentMiddle" />
                                        </par>
                                </entry>
                        </xsl:when>
                        <xsl:when test="@align='right'">
                                <entry align="right" valign="bottom">
                                        <formatRef formatRef="headernote-top-text-even"/>
                                        <par>
                                                <xsl:call-template name="renderHeadlineContentOutside" />
                                        </par>
                                </entry>
                        </xsl:when>
                        <xsl:otherwise>
                                <entry valign="bottom">
                                        <formatRef formatRef="headernote-top"/>
                                        <par>
                                                <xsl:call-template name="renderHeadlineContentInside" />
                                        </par>
                                </entry>
                        </xsl:otherwise>
                </xsl:choose>
        </xsl:template>
        
        <xsl:template match="StandardPageRegion[@formatRef='PageMargins'][@type='even']/Subline//entry">
                <xsl:choose>
                        <xsl:when test="@align='center'">
                                <entry align="center">
                                        <formatRef formatRef="footer"/>
                                        <par>
                                                <xsl:call-template name="renderSublineContentMiddle" />
                                        </par>
                                </entry>
                        </xsl:when>
                        <xsl:when test="@align='right'">
                                <entry align="right">
                                        <formatRef formatRef="footer"/>
                                        <par>
                                                <xsl:call-template name="renderSublineContentOutside" />
                                        </par>
                                </entry>
                        </xsl:when>
                        <xsl:otherwise>
                                <entry align="left">
                                        <formatRef formatRef="footer"/>
                                        <par>
                                                <xsl:call-template name="renderSublineContentInside" />
                                        </par>
                                </entry>
                        </xsl:otherwise>
                </xsl:choose>
        </xsl:template>
        
        <xsl:template name="writeWaterMarkElement">
            <Element addMe="Fixed" class="" delButton="Fixed" description="watermark" dummy="" filter="" idApplyFor="All" idCharacterFormat="" idParagraphFormat="" inheritFrom="" isBlockType="true" isCharFormat="" metafilter="" name="WaterMark" readableFilter="" readableMetaFilter="" visible="false" visibleButton="fixed">
                    <if/>
                    <smc_properties>
                            <smc_font dummy="" font-family="" font-family2="" font-size="" font-size-unit="" font-style="" font-variant="" font-weight="" letter-spacing="" letter-spacing-unit="" line-height="" line-height-unit="" reference-orientation="" text-align="" text-decoration="" text-transform="" vertical-align="" visible="false" visibleButton="fixed" white-space="" word-spacing="" word-spacing-unit="" writing-mode=""/>
                            <smc_indent dummy="" end-indent="" end-indent-unit="" start-indent="" start-indent-unit="" text-indent="" text-indent-unit="" visible="false" visibleButton="fixed"/>
                            <smc_border border-bottom-color="" border-bottom-style="" border-bottom-width="" border-collapse="" border-color="" border-left-color="" border-left-style="" border-left-width="" border-right-color="" border-right-style="" border-right-width="" border-style="" border-top-color="" border-top-style="" border-top-width="" border-width="" dummy="" unit="" visible="false" visibleButton="fixed"/>
                            <smc_spacing deltaMarginBottomSign="" deltaMarginBotton="" deltaMarginLeft="" deltaMarginLeftSign="" deltaMarginRight="" deltaMarginRightSign="" deltaMarginTop="" deltaMarginTopSign="" dummy="" margin-bottom="" margin-left="" margin-right="" margin-top="" padding-bottom="" padding-left="" padding-right="" padding-top="" space-after="" space-after-unit="" space-before="" space-before-unit="" space-before.conditionality="" unit="" visible="false" visibleButton="fixed"/>
                            <smc_color>
                                <xsl:attribute name="background-color" />
                                <xsl:attribute name="background-image" select="'watermark.logo'" />
                                <xsl:attribute name="background-position" select="'50% 50%'" />
                                <xsl:attribute name="background-repeat" select="'no-repeat'" />
                                <xsl:attribute name="color" />
                                <xsl:attribute name="dummy" />
                                <xsl:attribute name="visible" select="'false'" />
                                <xsl:attribute name="visibleButton" select="'fixed'" />
                            </smc_color>
                            <smc_pagination auto-number="" dummy="" force-page-count="" format="" initial-page-number="" keep-together="" keep-together.within-column="" keep-together.within-line="" keep-together.within-page="" keep-with-next="" keep-with-previous="" number-prefix="" number-text-separator="" orphans="" page-break-after="" page-break-before="" visible="false" visibleButton="fixed" widows=""/>
                            <smc_position>
                                <xsl:attribute name="bottom" />
                                <xsl:attribute name="dummy" />
                                <xsl:attribute name="height" select="$page-height" />
                                <xsl:attribute name="height-unit" select="'mm'" />
                                <xsl:attribute name="left" />
                                <xsl:attribute name="position" select="'fixed'" />
                                <xsl:attribute name="position-unit" select="'mm'" />
                                <xsl:attribute name="right" />
                                <xsl:attribute name="top" select="'8'" />
                                <xsl:attribute name="visible" select="'false'" />
                                <xsl:attribute name="visibleButton" select="'fixed'" />
                                <xsl:attribute name="width" select="$page-width" />
                                <xsl:attribute name="width-unit" select="'mm'" />
                            </smc_position>
                            <smc_layout clear="" dummy="" float="" visibility="" visible="false" visibleButton="fixed"/>
                            <smc_columns column-count="" column-gap="" dummy="" span="" visible="false" visibleButton="fixed"/>
                            <smc_hyphenation dummy="" hyphenate="" hyphenation-push-character-count="" hyphenation-remain-character-count="" visible="false" visibleButton="fixed"/>
                    </smc_properties>
            </Element>
        </xsl:template>
        
        <xsl:template match="Asset[@name='watermark.logo']" />
        
        <xsl:template name="writeWaterMarkAsset">
            <Asset addMe="Fixed" delButton="Fixed" description="watermark.logo" name="watermark.logo">
                <url button="Fixed" delButton="Fixed">
                    <RefControl PickerElement="url" TargetTitle="logo" language="de" objType="mediaset" serverID="JACKRABBIT" webdavID="1446492492508">
                        <File>
                            <xsl:choose>
                                <xsl:when test="(($page-width = '210') and (number($page-width) &gt; number($page-height))) or (($page-height = '210') and number($page-height) &gt; number($page-width))"> <!-- A5 -->
                                    <xsl:attribute name="isWaterMark" select="'true'" />
                                    <xsl:attribute name="itemName" select="'original'" />
                                    <xsl:attribute name="language" select="'de'" />
                                    <xsl:attribute name="basePath" select="$basePath" />
                                    <xsl:attribute name="url" select="'watermark-a5.png'" />
                                </xsl:when>
                                <xsl:otherwise>
                                    <xsl:attribute name="isWaterMark" select="'true'" />
                                    <xsl:attribute name="itemName" select="'original'" />
                                    <xsl:attribute name="language" select="'de'" />
                                    <xsl:attribute name="basePath" select="$basePath" />
                                    <xsl:attribute name="url" select="'watermark-a4.png'" />
                                </xsl:otherwise>
                            </xsl:choose>
                        </File>
                    </RefControl>
                </url>
            </Asset>
        </xsl:template>
        
        <xsl:template match="*">
                <xsl:copy>
                        <xsl:copy-of select="@*"/>
                        <xsl:choose>
                            <xsl:when test="local-name() = 'ElementGroup'">
                                <xsl:call-template name="writeWaterMarkElement" />
                            </xsl:when>
                            <xsl:when test="local-name() = 'AssetGroup'">
                                <xsl:call-template name="writeWaterMarkAsset" />
                            </xsl:when>
                        </xsl:choose>
                        <xsl:apply-templates/>
                </xsl:copy>
        </xsl:template>
        
        <xsl:template match="StyleRefs">
                <xsl:copy>
                        <xsl:copy-of select="@*"/>
                        <xsl:choose>
                            <xsl:when test="(($page-width = '210') and (number($page-width) &gt; number($page-height))) or (($page-height = '210') and number($page-height) &gt; number($page-width))"> <!-- A5 -->
                                <xsl:apply-templates select="(/*/Branch/Object/RefControl[starts-with(@TargetTitle, concat('2W notice ', $safety-information, ' A5'))])[1]" mode="copyStyleRef"/>
                            </xsl:when>
                            <xsl:otherwise>
                                <xsl:apply-templates select="(/*/Branch/Object/RefControl[starts-with(@TargetTitle, concat('2W notice ', $safety-information, ' A4'))])[1]" mode="copyStyleRef"/>
                            </xsl:otherwise>
                        </xsl:choose>
                        <xsl:apply-templates select="(/*/Branch/Object/RefControl[starts-with(@TargetTitle, concat('2W table ', $tables))])[1]" mode="copyStyleRef"/>
                </xsl:copy>
        </xsl:template>

        <xsl:template match="RefControl" mode="copyStyleRef">
                <StyleRef>
                        <xsl:copy-of select="Format"/>
                        <xsl:copy>
                                <xsl:copy-of select="@*"/>
                        </xsl:copy>
                </StyleRef>
        </xsl:template>

		<xsl:template match="Region[@name='Titelbild']/Box">
			<xsl:choose>
				<xsl:when test="($page-height = '210') and number($page-height) &gt; number($page-width)"> <!-- a5 portrait -->
					<Box align="center" float="" height="120" visible="false" width="110" x="16" y="95"/>
				</xsl:when>
				<xsl:when test="($page-width = '210') and number($page-width) &gt; number($page-height)"> <!-- a5 landscape -->
					<Box align="center" float="" height="60" visible="false" width="50" x="16" y="95"/>
				</xsl:when>
				<xsl:when test="$page-width = '297'">
					<Box align="center" float="" height="140" visible="false" width="130" x="16" y="95"/>
				</xsl:when>
				<xsl:otherwise>
					<Box align="center" float="" height="170" visible="false" width="160" x="16" y="95"/>
				</xsl:otherwise>
			</xsl:choose>
		</xsl:template>
		
        <!-- IMAGE PAGE 1 -->
        <xsl:template match="Region//media.theme">
                <xsl:choose>
                        <xsl:when test="$personalizationimage != ''">
                                <media.theme>
                                        <RefControl PickerElement="media.theme" TargetTitle="halftone-with-highlighting" defaultTitle="" language="de" lastModificationDate="2015-06-30 22:21:15 +0200" location="/framework/css/images" objType="mediaset" resolvedLanguage="de" serverID="JACKRABBIT" versionLabel="1.0" webdavID="1429399381185">
                                                <File>
                                                        <xsl:attribute name="isUploaded" select="'true'" />
                                                        <xsl:attribute name="itemName" select="'original'" />
                                                        <xsl:attribute name="language" select="'de'" />
                                                        <xsl:attribute name="basePath" select="$basePath" />
                                                        <xsl:attribute name="url" select="$personalizationimage" />
                                                        <MetaProperties>
                                                                <MetaProperty>
                                                                    <xsl:attribute name="name" select="'SMCIMG:height'" />
                                                                    <xsl:attribute name="value" select="$img-height" />
                                                                </MetaProperty>
                                                                <MetaProperty>
                                                                    <xsl:attribute name="name" select="'SMCIMG:width'" />
                                                                    <xsl:attribute name="value" select="$img-width" />
                                                                </MetaProperty>
                                                        </MetaProperties>
                                                </File>
                                        </RefControl>
                                </media.theme>
                        </xsl:when>
                        <xsl:otherwise>
                                <media.theme>
                                        <RefControl PickerElement="media.theme" TargetTitle="halftone-with-highlighting" defaultTitle="" language="de" lastModificationDate="2015-06-30 22:21:15 +0200" location="/framework/css/images" objType="mediaset" resolvedLanguage="de" serverID="JACKRABBIT" versionLabel="1.0" webdavID="1429399381185">
                                                <File>
                                                        <xsl:attribute name="isTypeOfImage" select="'true'" />
                                                        <xsl:attribute name="itemName" select="'original'" />
                                                        <xsl:attribute name="language" select="'de'" />
                                                        <xsl:attribute name="basePath" select="$basePath" />
                                                        <xsl:attribute name="url" select="'halftone-with-highlighting.png'" />
                                                        <MetaProperties>
                                                                <MetaProperty>
                                                                    <xsl:attribute name="name" select="'SMCIMG:height'" />
                                                                    <xsl:attribute name="value" select="$img-height" />
                                                                </MetaProperty>
                                                                <MetaProperty>
                                                                    <xsl:attribute name="name" select="'SMCIMG:width'" />
                                                                    <xsl:attribute name="value" select="$img-width" />
                                                                </MetaProperty>
                                                        </MetaProperties>
                                                </File>
                                        </RefControl>
                                </media.theme>
                        </xsl:otherwise>
                </xsl:choose>
        </xsl:template>
        
</xsl:stylesheet>