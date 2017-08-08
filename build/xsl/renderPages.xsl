<?xml version="1.0" encoding="UTF-8" ?>
<xsl:stylesheet version="2.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform">
    <xsl:output method="html" version="4.0" encoding="UTF-8" indent="yes"/>
    <xsl:template match="/Structure">
        <xsl:variable name="totalPages" select="count(Branch/Branch) + count(Branch)"/>
        <xsl:for-each select="Branch">
            <xsl:apply-templates select="current()">
                <xsl:with-param name="position" select="position()" />
            </xsl:apply-templates>
        </xsl:for-each>
    </xsl:template>
    
    <xsl:template match="block.description">
        <label class="block-label">
            <xsl:if test="label">
                <xsl:value-of select="label" />
            </xsl:if>
        </label>
        <xsl:apply-templates select="content/*">
            <xsl:with-param name="className" select="'block-description'" />
        </xsl:apply-templates>
    </xsl:template>
    
    <xsl:template match="notice">
        <xsl:param name="className" />
    
        <div>
            <xsl:attribute name="class" select="concat('notice ', @type, ' notice-1 ', $className)" />
            <div class="pull-left icon staticWidth">
                <div>
                    <xsl:attribute name="class">
                        <xsl:text>noticeImage </xsl:text>
                        <xsl:value-of select="@type" />
                    </xsl:attribute>
                </div>
            </div>
            <div>
                <xsl:attribute name="class">
                    <xsl:text>pull-left noticeContent </xsl:text>
                    <xsl:value-of select="@type" />
                </xsl:attribute>
                <xsl:choose>
                    <xsl:when test="@type='Danger'">
                        <label class="noticeTitle">Gefahr</label>
                    </xsl:when>
                    <xsl:when test="@type='Warning'">
                        <label class="noticeTitle">Warnung</label>
                    </xsl:when>
                    <xsl:when test="@type='Caution'">
                        <label class="noticeTitle">Vorsicht</label>
                    </xsl:when>
                    <xsl:when test="@type='Advice'">
                        <label class="noticeTitle">Hinweis</label>
                    </xsl:when>
                    <xsl:when test="@type='Attention'">
                        <label class="noticeTitle">Achtung</label> 
                    </xsl:when>
                    <xsl:when test="@type='Elektrik'">
                        <label class="noticeTitle">Elektrik</label> 
                    </xsl:when>
                </xsl:choose>
                <xsl:apply-templates select="notice.container/*" />
            </div>
        </div>
    </xsl:template>
    
    <xsl:template match="par">
        <xsl:param name="className" />
    
        <p class="par">
            <xsl:attribute name="class">
                <xsl:text>par </xsl:text>
                <xsl:value-of select="$className" />
            </xsl:attribute>
            <xsl:value-of select="current()" />
        </p>
    </xsl:template>
    
    <xsl:template name="renderHeader">
        <xsl:param name="position" />
    
        <xsl:variable name="chapterTitle" select="Branch[1]/Object//section/headline.content" />
    
        <div class="header">
            <div class="content">
                <div>
                    <xsl:attribute name="class">
                        <xsl:text>pull-left </xsl:text>
                        <xsl:text>logo </xsl:text>
                        <xsl:choose>
                            <xsl:when test="($position mod 2) != 1">
                                <xsl:text>inside</xsl:text>
                            </xsl:when>
                            <xsl:otherwise>
                                <xsl:text>outside</xsl:text>
                            </xsl:otherwise>
                        </xsl:choose>
                    </xsl:attribute>
                    <div class="title">
                        <xsl:value-of select="Object/RefControl/MMFramework.Container/section/headline.content" />
                    </div>
                    <div class="chapter">
                        <xsl:choose>
                            <xsl:when test="$chapterTitle != ''">
                                <xsl:value-of select="$chapterTitle" />
                            </xsl:when>
                            <xsl:otherwise>
                                <xsl:value-of select="Object/RefControl/MMFramework.Container/section/headline.content" />
                            </xsl:otherwise>
                        </xsl:choose>
                    </div>
                    <div class="title-chapter">
                        <xsl:choose>
                            <xsl:when test="$chapterTitle != ''">
                                <xsl:value-of select="concat(Object/RefControl/MMFramework.Container/section/headline.content, ' - ', $chapterTitle)" />
                            </xsl:when>
                            <xsl:otherwise>
                                <xsl:value-of select="Object/RefControl/MMFramework.Container/section/headline.content" />
                            </xsl:otherwise>
                        </xsl:choose>
                    </div>
                    <div class="logo">
                        <img src="framework/css/images/logo.gif" width="139" />
                    </div>
                    <div class="date">
                        <xsl:variable name="dateNow" select="current-dateTime()"/>
                        <xsl:value-of select="format-dateTime($dateNow, '[D01].[M01].[Y0001]')" />
                    </div>
                    <div class="productName">
                        <xsl:value-of select="/Structure/Branch[1]/Object/RefControl/MMFramework.Container/section/blocks/block.titlepage/title" />
                    </div>
                    <div class="version">
                        <xsl:value-of select="/Structure/Branch[1]/Object/RefControl/MMFramework.Container/section/blocks/block.titlepage/version" />
                    </div>
                    <div class="documentName">
                        <xsl:value-of select="/Structure/Branch[1]/Object/RefControl/MMFramework.Container/section/blocks/block.titlepage/title.theme" />
                    </div>
                </div>
                <div class="pull-left middle document-name">
                    <div class="title">
                        <xsl:value-of select="Object/RefControl/MMFramework.Container/section/headline.content" />
                    </div>
                    <div class="chapter">
                        <xsl:choose>
                            <xsl:when test="$chapterTitle != ''">
                                <xsl:value-of select="$chapterTitle" />
                            </xsl:when>
                            <xsl:otherwise>
                                <xsl:value-of select="Object/RefControl/MMFramework.Container/section/headline.content" />
                            </xsl:otherwise>
                        </xsl:choose>
                    </div>
                    <div class="title-chapter">
                        <xsl:choose>
                            <xsl:when test="$chapterTitle != ''">
                                <xsl:value-of select="concat(Object/RefControl/MMFramework.Container/section/headline.content, ' - ', $chapterTitle)" />
                            </xsl:when>
                            <xsl:otherwise>
                                <xsl:value-of select="Object/RefControl/MMFramework.Container/section/headline.content" />
                            </xsl:otherwise>
                        </xsl:choose>
                    </div>
                    <div class="logo">
                        <img src="framework/css/images/logo.gif" width="139" />
                    </div>
                    <div class="date">
                        <xsl:variable name="dateNow" select="current-dateTime()"/>
                        <xsl:value-of select="format-dateTime($dateNow, '[D01].[M01].[Y0001]')" />
                    </div>
                    <div class="productName">
                        <xsl:value-of select="/Structure/Branch[1]/Object/RefControl/MMFramework.Container/section/blocks/block.titlepage/title" />
                    </div>
                    <div class="version">
                        <xsl:value-of select="/Structure/Branch[1]/Object/RefControl/MMFramework.Container/section/blocks/block.titlepage/version" />
                    </div>
                    <div class="documentName">
                        <xsl:value-of select="/Structure/Branch[1]/Object/RefControl/MMFramework.Container/section/blocks/block.titlepage/title.theme" />
                    </div>
                </div>
                <div class="pull-right outside publish-date">
                    <xsl:attribute name="class">
                        <xsl:text>pull-right </xsl:text>
                        <xsl:text>publish-date </xsl:text>
                        <xsl:choose>
                            <xsl:when test="($position mod 2) != 1">
                                <xsl:text>outside</xsl:text>
                            </xsl:when>
                            <xsl:otherwise>
                                <xsl:text>inside</xsl:text>
                            </xsl:otherwise>
                        </xsl:choose>
                    </xsl:attribute>
                    <div class="title">
                        <xsl:value-of select="Object/RefControl/MMFramework.Container/section/headline.content" />
                    </div>
                    <div class="chapter">
                        <xsl:choose>
                            <xsl:when test="$chapterTitle != ''">
                                <xsl:value-of select="$chapterTitle" />
                            </xsl:when>
                            <xsl:otherwise>
                                <xsl:value-of select="Object/RefControl/MMFramework.Container/section/headline.content" />
                            </xsl:otherwise>
                        </xsl:choose>
                    </div>
                    <div class="title-chapter">
                        <xsl:choose>
                            <xsl:when test="$chapterTitle != ''">
                                <xsl:value-of select="concat(Object/RefControl/MMFramework.Container/section/headline.content, ' - ', $chapterTitle)" />
                            </xsl:when>
                            <xsl:otherwise>
                                <xsl:value-of select="Object/RefControl/MMFramework.Container/section/headline.content" />
                            </xsl:otherwise>
                        </xsl:choose>
                    </div>                    <div class="logo">
                        <img src="framework/css/images/logo.gif" width="139" />
                    </div>
                    <div class="date">
                        <xsl:variable name="dateNow" select="current-dateTime()"/>
                        <xsl:value-of select="format-dateTime($dateNow, '[D01].[M01].[Y0001]')" />
                    </div>
                    <div class="productName">
                        <xsl:value-of select="/Structure/Branch[1]/Object/RefControl/MMFramework.Container/section/blocks/block.titlepage/title" />
                    </div>
                    <div class="version">
                        <xsl:value-of select="/Structure/Branch[1]/Object/RefControl/MMFramework.Container/section/blocks/block.titlepage/version" />
                    </div>
                    <div class="documentName">
                        <xsl:value-of select="/Structure/Branch[1]/Object/RefControl/MMFramework.Container/section/blocks/block.titlepage/title.theme" />
                    </div>
                </div>
            </div>
        </div>
    </xsl:template>
    
    <xsl:template name="renderFooter">
        <xsl:param name="position" />
    
        <xsl:variable name="chapterTitle" select="Branch[1]/Object//section/headline.content" />
    
        <div class="footer">
            <div class="content">
                <div>
                    <xsl:attribute name="class">
                        <xsl:text>pull-left </xsl:text>
                        <xsl:text>logo </xsl:text>
                        <xsl:choose>
                            <xsl:when test="($position mod 2) != 1">
                                <xsl:text>inside</xsl:text>
                            </xsl:when>
                            <xsl:otherwise>
                                <xsl:text>outside</xsl:text>
                            </xsl:otherwise>
                        </xsl:choose>
                    </xsl:attribute>
                    <div class="title">
                        <xsl:value-of select="Object/RefControl/MMFramework.Container/section/headline.content" />
                    </div>
                    <div class="chapter">
                        <xsl:choose>
                            <xsl:when test="$chapterTitle != ''">
                                <xsl:value-of select="$chapterTitle" />
                            </xsl:when>
                            <xsl:otherwise>
                                <xsl:value-of select="Object/RefControl/MMFramework.Container/section/headline.content" />
                            </xsl:otherwise>
                        </xsl:choose>
                    </div>
                    <div class="title-chapter">
                        <xsl:choose>
                            <xsl:when test="$chapterTitle != ''">
                                <xsl:value-of select="concat(Object/RefControl/MMFramework.Container/section/headline.content, ' - ', $chapterTitle)" />
                            </xsl:when>
                            <xsl:otherwise>
                                <xsl:value-of select="Object/RefControl/MMFramework.Container/section/headline.content" />
                            </xsl:otherwise>
                        </xsl:choose>
                    </div>  
                    <div class="logo">
                        <img src="framework/css/images/logo.gif" width="139" />
                    </div>
                    <div class="date">
                        <xsl:variable name="dateNow" select="current-dateTime()"/>
                        <xsl:value-of select="format-dateTime($dateNow, '[D01].[M01].[Y0001]')" />
                    </div>
                    <div class="productName">
                        <xsl:value-of select="/Structure/Branch[1]/Object/RefControl/MMFramework.Container/section/blocks/block.titlepage/title" />
                    </div>
                    <div class="version">
                        <xsl:value-of select="/Structure/Branch[1]/Object/RefControl/MMFramework.Container/section/blocks/block.titlepage/version" />
                    </div>
                    <div class="documentName">
                        <xsl:value-of select="/Structure/Branch[1]/Object/RefControl/MMFramework.Container/section/blocks/block.titlepage/title.theme" />
                    </div>
                    <div class="pageNumber">
                        <xsl:text>#</xsl:text>
                    </div>
                </div>
                <div class="pull-left middle document-name">
                    <div class="title">
                        <xsl:value-of select="Object/RefControl/MMFramework.Container/section/headline.content" />
                    </div>
                    <div class="chapter">
                        <xsl:choose>
                            <xsl:when test="$chapterTitle != ''">
                                <xsl:value-of select="$chapterTitle" />
                            </xsl:when>
                            <xsl:otherwise>
                                <xsl:value-of select="Object/RefControl/MMFramework.Container/section/headline.content" />
                            </xsl:otherwise>
                        </xsl:choose>
                    </div>
                    <div class="title-chapter">
                        <xsl:choose>
                            <xsl:when test="$chapterTitle != ''">
                                <xsl:value-of select="concat(Object/RefControl/MMFramework.Container/section/headline.content, ' - ', $chapterTitle)" />
                            </xsl:when>
                            <xsl:otherwise>
                                <xsl:value-of select="Object/RefControl/MMFramework.Container/section/headline.content" />
                            </xsl:otherwise>
                        </xsl:choose>
                    </div>  
                    <div class="logo">
                        <img src="framework/css/images/logo.gif" width="139" />
                    </div>
                    <div class="date">
                        <xsl:variable name="dateNow" select="current-dateTime()"/>
                        <xsl:value-of select="format-dateTime($dateNow, '[D01].[M01].[Y0001]')" />
                    </div>
                    <div class="productName">
                        <xsl:value-of select="/Structure/Branch[1]/Object/RefControl/MMFramework.Container/section/blocks/block.titlepage/title" />
                    </div>
                    <div class="version">
                        <xsl:value-of select="/Structure/Branch[1]/Object/RefControl/MMFramework.Container/section/blocks/block.titlepage/version" />
                    </div>
                    <div class="documentName">
                        <xsl:value-of select="/Structure/Branch[1]/Object/RefControl/MMFramework.Container/section/blocks/block.titlepage/title.theme" />
                    </div>
                    <div class="pageNumber">
                        <xsl:text>#</xsl:text>
                    </div>
                </div>
                <div class="pull-right outside publish-date">
                    <xsl:attribute name="class">
                        <xsl:text>pull-right </xsl:text>
                        <xsl:text>publish-date </xsl:text>
                        <xsl:choose>
                            <xsl:when test="($position mod 2) != 1">
                                <xsl:text>outside</xsl:text>
                            </xsl:when>
                            <xsl:otherwise>
                                <xsl:text>inside</xsl:text>
                            </xsl:otherwise>
                        </xsl:choose>
                    </xsl:attribute>
                    <div class="title">
                        <xsl:value-of select="Object/RefControl/MMFramework.Container/section/headline.content" />
                    </div>
                    <div class="chapter">
                        <xsl:choose>
                            <xsl:when test="$chapterTitle != ''">
                                <xsl:value-of select="$chapterTitle" />
                            </xsl:when>
                            <xsl:otherwise>
                                <xsl:value-of select="Object/RefControl/MMFramework.Container/section/headline.content" />
                            </xsl:otherwise>
                        </xsl:choose>
                    </div>
                    <div class="title-chapter">
                        <xsl:choose>
                            <xsl:when test="$chapterTitle != ''">
                                <xsl:value-of select="concat(Object/RefControl/MMFramework.Container/section/headline.content, ' - ', $chapterTitle)" />
                            </xsl:when>
                            <xsl:otherwise>
                                <xsl:value-of select="Object/RefControl/MMFramework.Container/section/headline.content" />
                            </xsl:otherwise>
                        </xsl:choose>
                    </div>  
                    <div class="logo">
                        <img src="framework/css/images/logo.gif" width="139" />
                    </div>
                    <div class="date">
                        <xsl:variable name="dateNow" select="current-dateTime()"/>
                        <xsl:value-of select="format-dateTime($dateNow, '[D01].[M01].[Y0001]')" />
                    </div>
                    <div class="productName">
                        <xsl:value-of select="/Structure/Branch[1]/Object/RefControl/MMFramework.Container/section/blocks/block.titlepage/title" />
                    </div>
                    <div class="version">
                        <xsl:value-of select="/Structure/Branch[1]/Object/RefControl/MMFramework.Container/section/blocks/block.titlepage/version" />
                    </div>
                    <div class="documentName">
                        <xsl:value-of select="/Structure/Branch[1]/Object/RefControl/MMFramework.Container/section/blocks/block.titlepage/title.theme" />
                    </div>
                    <div class="pageNumber">
                        <xsl:text>#</xsl:text>
                    </div>
                </div>
            </div>
        </div>
    </xsl:template>
    
    <xsl:template match="Table">
        <xsl:param name="className" />
    
        <table class="table">
            <xsl:attribute name="class">
                <xsl:text>table </xsl:text>
                <xsl:value-of select="concat($className, ' ')" />
                <xsl:choose>
                    <xsl:when test="TableDesc/@type = 'Nolines'">
                        <xsl:text>borderless</xsl:text>
                    </xsl:when>
                    <xsl:otherwise>
                        <xsl:text>table-bordered</xsl:text>
                    </xsl:otherwise>
                </xsl:choose>
            </xsl:attribute>
            <colgroup>
                <xsl:for-each select="table/tgroup/colspec">
                    <col>
                        <xsl:attribute name="width" select="concat(substring-before(@colwidth, '*'), '%')" />
                    </col>
                </xsl:for-each>
            </colgroup>
            <thead>
                <tr>
                    <xsl:for-each select="table/tgroup/thead/row/entry">
                        <td>
                            <xsl:attribute name="class">
                                <xsl:text>top</xsl:text>
                                <xsl:choose>
                                    <xsl:when test="position() = 1">
                                        <xsl:text> first</xsl:text>
                                    </xsl:when>
                                </xsl:choose>
                            </xsl:attribute>
                            <xsl:apply-templates select="*" />
                        </td>
                    </xsl:for-each>
                </tr>
            </thead>
            <tbody>
                <xsl:for-each select="table/tgroup/tbody/row">
                    <tr>
                        <xsl:attribute name="class">
                            <xsl:choose>
                                <xsl:when test="(count(current()/../../thead/row/entry) = 0) and position() = 1">
                                    <xsl:text>top</xsl:text>
                                </xsl:when>
                                <xsl:when test="position() = count(current()/../row)">
                                    <xsl:text>bottom</xsl:text>
                                </xsl:when>
                            </xsl:choose>
                        </xsl:attribute>
                        <xsl:for-each select="entry">
                            <td>
                                <xsl:attribute name="class">
                                    <xsl:choose>
                                        <xsl:when test="position() = 1">
                                            <xsl:text>left</xsl:text>
                                        </xsl:when>
                                        <xsl:when test="position() = count(current()/../entry)">
                                            <xsl:text>right</xsl:text>
                                        </xsl:when>
                                    </xsl:choose>
                                </xsl:attribute>
                                <xsl:apply-templates />
                            </td>
                        </xsl:for-each>
                    </tr>
                </xsl:for-each>
            </tbody>
        </table>
    </xsl:template>
    
    <xsl:template match="instruction">
        <xsl:param name="className" />
    
        <ol class="instruction">
            <xsl:attribute name="class">
                <xsl:text>instruction</xsl:text>
                <xsl:value-of select="concat(' ', $className)" />
            </xsl:attribute>
            <xsl:for-each select="step">
                <li>
                    <xsl:apply-templates select="current()" />
                </li>
            </xsl:for-each>
        </ol>
    </xsl:template>
    
    <xsl:template match="media">
        <xsl:param name="className" />
        <div class="image halftone-with-highlighting">
            <xsl:attribute name="class">
                <xsl:text>image halftone-with-highlighting </xsl:text>
                <xsl:value-of select="$className" />
            </xsl:attribute>
            <img class="halftone-with-highlighting" src="framework/css/images/halftone-with-highlighting.png" />
            <img class="halftone-on-black-white" src="framework/css/images/halftone-on-black-white.png" />
            <img class="knitted-black-white" src="framework/css/images/knitted-black-white.png" />
            <img class="stroke-color" src="framework/css/images/stroke-color.png" />
        </div>
    </xsl:template>
    
    <xsl:template name="renderIndexChilds">
        <xsl:param name="position" />
        <xsl:param name="level" />
        
        <xsl:for-each select="Branch">
            <xsl:variable name="newPosition" select="concat($position, '.', position())" />
            <div>
                <xsl:attribute name="class" select="concat('menuItem level', $level)" />
                <span class="chapter">
                    <xsl:value-of select="$newPosition" />
                </span>
                <span class="title">
                    <xsl:value-of select="Object/RefControl/@TargetTitle" />
                </span>
                <span class="pageNumber">#</span>
            </div>
            <xsl:call-template name="renderIndexChilds">
                <xsl:with-param name="position" select="$newPosition" />
                <xsl:with-param name="level" select="$level + 1" />
            </xsl:call-template>
        </xsl:for-each>
    </xsl:template>
    
    <xsl:template name="renderIndex">
        <xsl:for-each select="/Structure/Branch">
            <xsl:if test="position() > 2">
                <div class="menuItem level1">
                    <span class="chapter">
                        <xsl:value-of select="position() - 2" />
                    </span>
                    <span class="title">
                        <xsl:value-of select="Object/RefControl/@TargetTitle" />
                    </span>
                    <span class="pageNumber">#</span>
                </div>
                <xsl:call-template name="renderIndexChilds">
                    <xsl:with-param name="position" select="(position() - 2)" />
                    <xsl:with-param name="level" select="2" />
                </xsl:call-template>
            </xsl:if>
        </xsl:for-each>
    </xsl:template>
    
    <xsl:template name="renderBranchContent">
        <xsl:param name="position" />
        <xsl:param name="subpositions" select="''" />
        <xsl:param name="time" select="'1'" />
        <xsl:param name="firstLevel" select="false()" />
        <xsl:param name="firstContent" select="false()" />
    
        <xsl:choose>
            <xsl:when test="$position = 1">
                <div class="documentContent">
                    <h1>
                        <xsl:value-of select="Object/RefControl/MMFramework.Container/section/blocks/block.titlepage/title" />
                    </h1>
                    <h4>
                        <xsl:value-of select="Object/RefControl/MMFramework.Container/section/blocks/block.titlepage/title.theme" />
                    </h4>
                    <div class="image-front halftone-with-highlighting personalizable">
                        <img class="halftone-with-highlighting" src="framework/css/images/halftone-with-highlighting.png" />
                        <img class="halftone-on-black-white" src="framework/css/images/halftone-on-black-white.png" />
                        <img class="knitted-black-white" src="framework/css/images/knitted-black-white.png" />
                        <img class="stroke-color" src="framework/css/images/stroke-color.png" />
                    </div>
                </div>
            </xsl:when>
            <xsl:when test="$position = 2">
                <h2 class="mainTitle">
                    <span class="title" style="padding: 0px; margin: 0px;">Inhaltsverzeichnis</span>
                </h2>
                <div class="documentContent">
                    <xsl:call-template name="renderIndex" />
                </div>
            </xsl:when>
            <xsl:otherwise>
                <xsl:choose>
                    <xsl:when test="$firstLevel">
                        <h2 class="mainTitle">
                            <label class="titleNumber">
                                <xsl:value-of select="concat($position - 2, $subpositions)" />
                            </label>
                            <span class="title">
                                <xsl:value-of select="Object/RefControl/MMFramework.Container/section/headline.content" />
                            </span>
                        </h2>
                        <div class="documentContent">
                            <xsl:apply-templates select="Object/RefControl/MMFramework.Container/section/blocks/*" />
                            <xsl:for-each select="Branch">
                                <xsl:apply-templates select="current()">
                                    <xsl:with-param name="position" select="$position" />
                                    <xsl:with-param name="subpositions" select="concat($subpositions, '.', position())" />
                                    <xsl:with-param name="firstLevel" select="false()" />
                                    <xsl:with-param name="firstContent" select="true()" />
                                </xsl:apply-templates>
                            </xsl:for-each>
                        </div>
                    </xsl:when>
                    <xsl:otherwise>
                        <xsl:for-each select="Object/RefControl/MMFramework.Container/section/blocks/block.description/content/*">
                            <xsl:choose>
                                <xsl:when test="position() = 1 and $firstContent = true() and local-name() != 'Table'">
                                    <div class="blockContent">
                                        <h2>
                                            <label class="titleNumber">
                                                <xsl:value-of select="concat($position - 2, $subpositions)" />
                                            </label>
                                            <span class="title">
                                                <xsl:value-of select="../../../../headline.content" />
                                            </span>
                                        </h2>
                                        <xsl:apply-templates select="current()">
                                            <xsl:with-param name="className" select="'block-description'" />
                                        </xsl:apply-templates>
                                    </div>
                                </xsl:when>
                                <xsl:when test="position() = 1">
                                    <h2>
                                        <label class="titleNumber">
                                            <xsl:value-of select="concat($position - 2, $subpositions)" />
                                        </label>
                                        <span class="title">
                                            <xsl:value-of select="../../../../headline.content" />
                                        </span>
                                    </h2>
                                    <xsl:apply-templates select="current()">
                                            <xsl:with-param name="className" select="'block-description'" />
                                        </xsl:apply-templates>
                                </xsl:when>
                                <xsl:otherwise>
                                    <xsl:apply-templates select="current()">
                                        <xsl:with-param name="className" select="'block-description'" />
                                    </xsl:apply-templates>
                                </xsl:otherwise>
                            </xsl:choose>
                        </xsl:for-each>
                        <xsl:for-each select="Branch">
                            <xsl:apply-templates select="current()">
                                <xsl:with-param name="position" select="$position" />
                                <xsl:with-param name="subpositions" select="concat($subpositions, '.', position())" />
                                <xsl:with-param name="firstLevel" select="false()" />
                            </xsl:apply-templates>
                        </xsl:for-each>
                    </xsl:otherwise>
                </xsl:choose>
            </xsl:otherwise>
        </xsl:choose>
        <div class="spacerBottom"></div>
    </xsl:template>
    
    <xsl:template match="Branch">
        <xsl:param name="position" />
        <xsl:param name="subpositions" select="''" />
        <xsl:param name="firstLevel" select="true()" />
        <xsl:param name="firstContent" select="false()" />
    
        <xsl:choose>
            <xsl:when test="$firstLevel">
                <div>
                    <xsl:attribute name="class">
                        <xsl:text>page</xsl:text>
                        <xsl:if test="$position = 1">
                            <xsl:text> page-1</xsl:text>
                        </xsl:if>
                        <xsl:choose>
                            <xsl:when test="$position mod 2 = 0">
                                <xsl:text> even</xsl:text>
                            </xsl:when>
                            <xsl:otherwise>
                                <xsl:text> odd</xsl:text>
                            </xsl:otherwise>
                        </xsl:choose>
                    </xsl:attribute>
                    <div>
                        <xsl:if test="$firstLevel">
                            <xsl:attribute name="class">
                                <xsl:text>pageResize</xsl:text>
                                <xsl:if test="Object/RefControl/MMFramework.Container/section/@type != 'GanzeBreite'">
                                    <xsl:text> columnizable</xsl:text>
                                </xsl:if>
                            </xsl:attribute>
                        </xsl:if>
                        
                        <xsl:call-template name="renderHeader">
                            <xsl:with-param name="position" select="$position" />
                        </xsl:call-template>
                        
                        <div class="bodyContent">
                            <xsl:call-template name="renderBranchContent">
                                <xsl:with-param name="position" select="$position" />
                                <xsl:with-param name="firstLevel" select="true()" />
                            </xsl:call-template>
                        </div>
                        <xsl:if test="$firstLevel">
                            <xsl:call-template name="renderFooter">
                                <xsl:with-param name="position" select="$position" />
                            </xsl:call-template>
                        </xsl:if>
                    </div>
                </div>
            </xsl:when>
            <xsl:otherwise>
                <xsl:call-template name="renderBranchContent">
                    <xsl:with-param name="position" select="$position" />
                    <xsl:with-param name="subpositions" select="$subpositions" />
                    <xsl:with-param name="firstContent" select="$firstContent" />
                </xsl:call-template>
            </xsl:otherwise>
        </xsl:choose>
        
    </xsl:template>
</xsl:stylesheet>
