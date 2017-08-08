<xsl:stylesheet version="2.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform">
<xsl:output method="xml" indent="no" omit-xml-declaration="yes" />
<xsl:strip-space elements="*"/>

    <xsl:template match="/Structure">
        <xsl:for-each select="Branch[1]/Object/RefControl/Format/ParamConfig/ElementGroup/Element">
            <xsl:apply-templates select="current()" />
        </xsl:for-each>
        
        <xsl:for-each select="Branch[1]/Object/RefControl/Format/StyleRefs/StyleRef">
            <xsl:variable name="webdavID" select="RefControl/@webdavID" />
            <xsl:apply-templates select="//RefControl[@webdavID = $webdavID and name(ancestor::Object) = 'Object']/Format/ParamConfig/ElementGroup/Element" />
        </xsl:for-each>
    </xsl:template>
    
<xsl:template name="readCssAttr">
        <!-- FONT CONFIGURATION -->
        <xsl:if test="smc_properties/smc_font/@font-family != '' and smc_properties/smc_font/@font-family2 != ''">
            <xsl:value-of select="concat('font-family:', smc_properties/smc_font/@font-family, ',', smc_properties/smc_font/@font-family2, ';')" />
        </xsl:if>
        <xsl:if test="smc_properties/smc_font/@font-family != '' and smc_properties/smc_font/@font-family2 = ''">
            <xsl:value-of select="concat('font-family:', smc_properties/smc_font/@font-family, ';')" />
        </xsl:if>
        <xsl:if test="smc_properties/smc_font/@font-style != ''">
            <xsl:value-of select="concat('font-style:', smc_properties/smc_font/@font-style, ';')" />
        </xsl:if>
        <xsl:if test="smc_properties/smc_font/@font-size!='' and smc_properties/smc_font/@font-size-unit!=''">
            <xsl:value-of select="concat('font-size:', smc_properties/smc_font/@font-size, smc_properties/smc_font/@font-size-unit, ';')" />
        </xsl:if>
        <xsl:if test="smc_properties/smc_font/@font-weight!=''">
            <xsl:value-of select="concat('font-weight:', smc_properties/smc_font/@font-weight, ';')" />
        </xsl:if>
        <xsl:if test="smc_properties/smc_font/@line-height!='' and smc_properties/smc_font/@line-height-unit!=''">
            <xsl:value-of select="concat('line-height:', smc_properties/smc_font/@line-height, smc_properties/smc_font/@line-height-unit, ';')" />
        </xsl:if>
        <xsl:if test="smc_properties/smc_font/@letter-spacing!='' and smc_properties/smc_font/@letter-spacing-unit!=''">
            <xsl:value-of select="concat('letter-spacing:', smc_properties/smc_font/@letter-spacing, smc_properties/smc_font/@letter-spacing-unit, ';')" />
        </xsl:if>
        <xsl:if test="smc_properties/smc_font/@word-spacing!='' and smc_properties/smc_font/@word-spacing-unit!=''">
            <xsl:value-of select="concat('word-spacing:', smc_properties/smc_font/@word-spacing, smc_properties/smc_font/@word-spacing-unit, ';')" />
        </xsl:if>
        <xsl:if test="smc_properties/smc_font/@text-align!=''">
            <xsl:value-of select="concat('text-align:', smc_properties/smc_font/@text-align, ';')" />
        </xsl:if>
        <xsl:if test="smc_properties/smc_font/@text-decoration!=''">
            <xsl:value-of select="concat('text-decoration:', smc_properties/smc_font/@text-decoration, ';')" />
        </xsl:if>
        <xsl:if test="smc_properties/smc_font/@text-transform!=''">
            <xsl:value-of select="concat('text-transform:', smc_properties/smc_font/@text-transform, ';')" />
        </xsl:if>
        <xsl:if test="smc_properties/smc_font/@vertical-align!=''">
            <xsl:value-of select="concat('vertical-align:', smc_properties/smc_font/@vertical-align, ';')" />
        </xsl:if>
        <xsl:if test="smc_properties/smc_font/@white-space!=''">
            <xsl:value-of select="concat('white-space:', smc_properties/smc_font/@white-space, ';')" />
        </xsl:if>
        <xsl:if test="smc_properties/smc_font/@writing-mode!=''">
            <xsl:value-of select="concat('writing-mode:', smc_properties/smc_font/@writing-mode, ';')" />
        </xsl:if>
        
        <!-- INDENT CONFIGURATION -->
        
        <!-- BORDER CONFIGURATION -->
        <xsl:if test="smc_properties/smc_border/@border-color!=''">
            <xsl:variable name="color" select="smc_properties/smc_border/@border-color" />
            <xsl:value-of select="concat('border-color: rgb(', /Structure/Branch[1]/Object/RefControl/Format/ParamConfig/ColorDefinition/Colors/Color[@name=$color]/@red, ',',  /Structure/Branch[1]/Object/RefControl/Format/ParamConfig/ColorDefinition/Colors/Color[@name=$color]/@green, ',', /Structure/Branch[1]/Object/RefControl/Format/ParamConfig/ColorDefinition/Colors/Color[@name=$color]/@blue, ')', ';')" />
        </xsl:if>
        <xsl:if test="smc_properties/smc_border/@border-style!=''">
            <xsl:value-of select="concat('border-style:', smc_properties/smc_border/@border-style, ';')" />
        </xsl:if>
        <xsl:if test="smc_properties/smc_border/@border-width!='' and smc_properties/smc_border/@unit!=''">
            <xsl:value-of select="concat('border-width:', smc_properties/smc_border/@border-width, smc_properties/smc_border/@unit , ';')" />
        </xsl:if>
        
        <xsl:if test="smc_properties/smc_border/@border-top-color!=''">
            <xsl:variable name="color" select="smc_properties/smc_border/@border-top-color" />
            <xsl:value-of select="concat('border-top-color: rgb(', /Structure/Branch[1]/Object/RefControl/Format/ParamConfig/ColorDefinition/Colors/Color[@name=$color]/@red, ',',  /Structure/Branch[1]/Object/RefControl/Format/ParamConfig/ColorDefinition/Colors/Color[@name=$color]/@green, ',', /Structure/Branch[1]/Object/RefControl/Format/ParamConfig/ColorDefinition/Colors/Color[@name=$color]/@blue, ')', ';')" />
        </xsl:if>
        <xsl:if test="smc_properties/smc_border/@border-top-style!=''">
            <xsl:value-of select="concat('border-top-style:', smc_properties/smc_border/@border-top-style, ';')" />
        </xsl:if>
        <xsl:if test="smc_properties/smc_border/@border-top-width!='' and smc_properties/smc_border/@unit!=''">
            <xsl:value-of select="concat('border-top-width:', smc_properties/smc_border/@border-top-width, smc_properties/smc_border/@unit , ';')" />
        </xsl:if>
        
        <xsl:if test="smc_properties/smc_border/@border-right-color!=''">
            <xsl:variable name="color" select="smc_properties/smc_border/@border-right-color" />
            <xsl:value-of select="concat('border-right-color: rgb(', /Structure/Branch[1]/Object/RefControl/Format/ParamConfig/ColorDefinition/Colors/Color[@name=$color]/@red, ',',  /Structure/Branch[1]/Object/RefControl/Format/ParamConfig/ColorDefinition/Colors/Color[@name=$color]/@green, ',', /Structure/Branch[1]/Object/RefControl/Format/ParamConfig/ColorDefinition/Colors/Color[@name=$color]/@blue, ')', ';')" />
        </xsl:if>
        <xsl:if test="smc_properties/smc_border/@border-right-style!=''">
            <xsl:value-of select="concat('border-right-style:', smc_properties/smc_border/@border-right-style, ';')" />
        </xsl:if>
        <xsl:if test="smc_properties/smc_border/@border-right-width!='' and smc_properties/smc_border/@unit!=''">
            <xsl:value-of select="concat('border-right-width:', smc_properties/smc_border/@border-right-width, smc_properties/smc_border/@unit , ';')" />
        </xsl:if>
        
        <xsl:if test="smc_properties/smc_border/@border-bottom-color!=''">
            <xsl:variable name="color" select="smc_properties/smc_border/@border-bottom-color" />
            <xsl:value-of select="concat('border-bottom-color: rgb(', /Structure/Branch[1]/Object/RefControl/Format/ParamConfig/ColorDefinition/Colors/Color[@name=$color]/@red, ',',  /Structure/Branch[1]/Object/RefControl/Format/ParamConfig/ColorDefinition/Colors/Color[@name=$color]/@green, ',', /Structure/Branch[1]/Object/RefControl/Format/ParamConfig/ColorDefinition/Colors/Color[@name=$color]/@blue, ')', ';')" />
        </xsl:if>
        <xsl:if test="smc_properties/smc_border/@border-bottom-style!=''">
            <xsl:value-of select="concat('border-bottom-style:', smc_properties/smc_border/@border-bottom-style, ';')" />
        </xsl:if>
        <xsl:if test="smc_properties/smc_border/@border-bottom-width!='' and smc_properties/smc_border/@unit!=''">
            <xsl:value-of select="concat('border-bottom-width:', smc_properties/smc_border/@border-bottom-width, smc_properties/smc_border/@unit , ';')" />
        </xsl:if>
        
        <xsl:if test="smc_properties/smc_border/@border-left-color!=''">
            <xsl:variable name="color" select="smc_properties/smc_border/@border-left-color" />
            <xsl:value-of select="concat('border-left-color: rgb(', /Structure/Branch[1]/Object/RefControl/Format/ParamConfig/ColorDefinition/Colors/Color[@name=$color]/@red, ',',  /Structure/Branch[1]/Object/RefControl/Format/ParamConfig/ColorDefinition/Colors/Color[@name=$color]/@green, ',', /Structure/Branch[1]/Object/RefControl/Format/ParamConfig/ColorDefinition/Colors/Color[@name=$color]/@blue, ')', ';')" />
        </xsl:if>
        <xsl:if test="smc_properties/smc_border/@border-left-style!=''">
            <xsl:value-of select="concat('border-left-style:', smc_properties/smc_border/@border-left-style, ';')" />
        </xsl:if>
        <xsl:if test="smc_properties/smc_border/@border-left-width!='' and smc_properties/smc_border/@unit!=''">
            <xsl:value-of select="concat('border-left-width:', smc_properties/smc_border/@border-left-width, smc_properties/smc_border/@unit , ';')" />
        </xsl:if>
        
        
        <!-- SPACING CONFIGURATION -->
        <xsl:if test="smc_properties/smc_spacing/@margin-bottom!='' and smc_properties/smc_spacing/@unit!=''">
            <xsl:value-of select="concat('margin-bottom:', smc_properties/smc_spacing/@deltaMarginBottomSign, smc_properties/smc_spacing/@margin-bottom, smc_properties/smc_spacing/@unit , ';')" />
        </xsl:if>
        <xsl:if test="smc_properties/smc_spacing/@margin-left!='' and smc_properties/smc_spacing/@unit!=''">
            <xsl:value-of select="concat('margin-left:', smc_properties/smc_spacing/@deltaMarginLeftSign, smc_properties/smc_spacing/@margin-left, smc_properties/smc_spacing/@unit , ';')" />
        </xsl:if>
        <xsl:if test="smc_properties/smc_spacing/@margin-top!='' and smc_properties/smc_spacing/@unit!=''">
            <xsl:value-of select="concat('margin-top:', smc_properties/smc_spacing/@deltaMarginTopSign, smc_properties/smc_spacing/@margin-top, smc_properties/smc_spacing/@unit , ';')" />
        </xsl:if>
        <xsl:if test="smc_properties/smc_spacing/@margin-right!='' and smc_properties/smc_spacing/@unit!=''">
            <xsl:value-of select="concat('margin-right:', smc_properties/smc_spacing/@deltaMarginRightSign, smc_properties/smc_spacing/@margin-right, smc_properties/smc_spacing/@unit , ';')" />
        </xsl:if>
        
        <xsl:if test="smc_properties/smc_spacing/@padding-bottom!='' and smc_properties/smc_spacing/@unit!=''">
            <xsl:value-of select="concat('padding-right:', smc_properties/smc_spacing/@padding-right, smc_properties/smc_spacing/@unit , ';')" />
        </xsl:if>
        <xsl:if test="smc_properties/smc_spacing/@padding-left!='' and smc_properties/smc_spacing/@unit!=''">
            <xsl:value-of select="concat('padding-left:', smc_properties/smc_spacing/@padding-left, smc_properties/smc_spacing/@unit , ';')" />
        </xsl:if>
        <xsl:if test="smc_properties/smc_spacing/@padding-top!='' and smc_properties/smc_spacing/@unit!=''">
            <xsl:value-of select="concat('padding-top:', smc_properties/smc_spacing/@padding-top, smc_properties/smc_spacing/@unit , ';')" />
        </xsl:if>
        <xsl:if test="smc_properties/smc_spacing/@padding-right!='' and smc_properties/smc_spacing/@unit!=''">
            <xsl:value-of select="concat('padding-right:', smc_properties/smc_spacing/@padding-right, smc_properties/smc_spacing/@unit , ';')" />
        </xsl:if>
        
        
        <!-- COLOR CONFIGURATION -->
        <xsl:if test="smc_properties/smc_color/@background-color != ''">
            <xsl:variable name="color" select="smc_properties/smc_color/@background-color" />
            <xsl:value-of select="concat('background-color: rgb(', /Structure/Branch[1]/Object/RefControl/Format/ParamConfig/ColorDefinition/Colors/Color[@name=$color]/@red, ',',  /Structure/Branch[1]/Object/RefControl/Format/ParamConfig/ColorDefinition/Colors/Color[@name=$color]/@green, ',', /Structure/Branch[1]/Object/RefControl/Format/ParamConfig/ColorDefinition/Colors/Color[@name=$color]/@blue, ')', ';')" />
        </xsl:if>
        <xsl:if test="smc_properties/smc_color/@color != ''">
            <xsl:variable name="color" select="smc_properties/smc_color/@color" />
            <xsl:value-of select="concat('color: rgb(', /Structure/Branch[1]/Object/RefControl/Format/ParamConfig/ColorDefinition/Colors/Color[@name=$color]/@red, ',',  /Structure/Branch[1]/Object/RefControl/Format/ParamConfig/ColorDefinition/Colors/Color[@name=$color]/@green, ',', /Structure/Branch[1]/Object/RefControl/Format/ParamConfig/ColorDefinition/Colors/Color[@name=$color]/@blue, ')', ';')" />
        </xsl:if>
        
        <!-- POSITION CONFIGURATION -->
        <xsl:if test="smc_properties/smc_position/@bottom!='' and smc_properties/smc_position/@position-unit!=''">
            <xsl:value-of select="concat('bottom:', smc_properties/smc_position/@bottom, smc_properties/smc_position/@position-unit , ';')" />
        </xsl:if>
        <xsl:if test="smc_properties/smc_position/@left!='' and smc_properties/smc_position/@position-unit!=''">
            <xsl:value-of select="concat('left:', smc_properties/smc_position/@left, smc_properties/smc_position/@position-unit , ';')" />
        </xsl:if>
        <xsl:if test="smc_properties/smc_position/@top!='' and smc_properties/smc_position/@position-unit!=''">
            <xsl:value-of select="concat('top:', smc_properties/smc_position/@top, smc_properties/smc_position/@position-unit , ';')" />
        </xsl:if>
        <xsl:if test="smc_properties/smc_position/@right!='' and smc_properties/smc_position/@position-unit!=''">
            <xsl:value-of select="concat('right:', smc_properties/smc_position/@right, smc_properties/smc_position/@position-unit , ';')" />
        </xsl:if>
        
        <xsl:if test="smc_properties/smc_position/@position!=''">
            <xsl:value-of select="concat('position:', smc_properties/smc_position/@position, ';')" />
        </xsl:if>
        
        <xsl:if test="smc_properties/smc_position/@height!='' and smc_properties/smc_position/@height-unit!=''">
            <xsl:value-of select="concat('height:', smc_properties/smc_position/@height, smc_properties/smc_position/@height-unit , ';')" />
        </xsl:if>
        <xsl:if test="smc_properties/smc_position/@width!='' and smc_properties/smc_position/@width-unit!=''">
            <xsl:value-of select="concat('width:', smc_properties/smc_position/@width, smc_properties/smc_position/@width-unit , ';')" />
        </xsl:if>
        
        <!-- LAYOUT CONFIGURATION -->
        <xsl:if test="smc_properties/smc_layout/@clear!=''">
            <xsl:value-of select="concat('clear:', smc_properties/smc_layout/@clear, ';')" />
        </xsl:if>
        <xsl:if test="smc_properties/smc_layout/@float!=''">
            <xsl:value-of select="concat('float:', smc_properties/smc_layout/@float, ';')" />
        </xsl:if>
        <xsl:if test="smc_properties/smc_layout/@visibility!=''">
            <xsl:value-of select="concat('visibility:', smc_properties/smc_layout/@visibility, ';')" />
        </xsl:if>
        
        <!-- COLUMNS CONFIGURATION -->
        <xsl:if test="smc_properties/smc_columns/@column-count!=''">
            <xsl:value-of select="concat('column-count:', smc_properties/smc_columns/@column-count, ';')" />
        </xsl:if>
        <xsl:if test="smc_properties/smc_columns/@column-gap!=''">
            <xsl:value-of select="concat('column-gap:', smc_properties/smc_columns/@column-gap, ';')" />
        </xsl:if>
    </xsl:template>
    
    <!-- Default style for all objects -->
    <xsl:template match="Element[@name='default']">
        <xsl:text>.page * {</xsl:text>
            <xsl:call-template name="readCssAttr" />
        <xsl:text>}</xsl:text>
    </xsl:template>
    
    <xsl:template match="Element[@name='headernote-top']">
        <xsl:text>.page .header .middle {</xsl:text>
            <xsl:call-template name="readCssAttr" />
        <xsl:text>}</xsl:text>
    </xsl:template>
    
    <xsl:template match="Element[@name='headernote-top-text-odd']">
        <xsl:text>.page .header .odd {</xsl:text>
            <xsl:call-template name="readCssAttr" />
        <xsl:text>}</xsl:text>
    </xsl:template>
    
    <xsl:template match="Element[@name='headernote-top-text-even']">
        <xsl:text>.page .header .even {</xsl:text>
            <xsl:call-template name="readCssAttr" />
        <xsl:text>}</xsl:text>
    </xsl:template>
    
    <xsl:template match="Element[@name='headernote.container']">
        <xsl:text>.page .header {</xsl:text>
            <xsl:call-template name="readCssAttr" />
            <xsl:text>float:left;</xsl:text>
            <xsl:text>width:100%;</xsl:text>
            <xsl:text>display:table-row;</xsl:text>
        <xsl:text>}</xsl:text>
    </xsl:template>
    
    <xsl:template match="Element[@name='footer']">
        <xsl:text>.page .footer {</xsl:text>
            <xsl:call-template name="readCssAttr" />
            <xsl:text>display:table-row</xsl:text>
        <xsl:text>}</xsl:text>
    </xsl:template>
    
    <xsl:template match="Element[@name='instruction']">
        <xsl:text>.page .instruction {</xsl:text>
            <xsl:call-template name="readCssAttr" />
        <xsl:text>}</xsl:text>
    </xsl:template>
    
    <xsl:template match="Element[@name='table.cell.par']">
        <xsl:text>.page .table td{</xsl:text>
            <xsl:call-template name="readCssAttr" />
        <xsl:text>}</xsl:text>
    </xsl:template>
    
    <xsl:template match="Element[@name='headline.content']">
            <xsl:text>.page .mainTitle {</xsl:text>
                <xsl:call-template name="readCssAttr" />
                <xsl:text>clear:both;</xsl:text>
                <xsl:text>margin-top:0 !important;</xsl:text>
            <xsl:text>}</xsl:text>
            
            <xsl:text>.page .mainTitle .title{</xsl:text>
                <xsl:call-template name="readCssAttr" />
            <xsl:text>}</xsl:text>
            
            <xsl:text>.page .mainTitle .titleNumber{</xsl:text>
                <xsl:call-template name="readCssAttr" />
                <xsl:text>margin-right:3%;</xsl:text>
            <xsl:text>}</xsl:text>
    </xsl:template>
    
    <xsl:template match="Element[@name='titlepage.title.theme']">
        <xsl:text>.page h4{</xsl:text>
            <xsl:call-template name="readCssAttr" />
        <xsl:text>}</xsl:text>
    </xsl:template>
    
    <xsl:template match="Element[@name='titlepage.title']">
        <xsl:text>.page h1{</xsl:text>
            <xsl:call-template name="readCssAttr" />
            <xsl:text>clear:both;</xsl:text>
            <xsl:text>margin-top:0 !important;</xsl:text>
        <xsl:text>}</xsl:text>
    </xsl:template>
    
    <xsl:template match="Element[@name='par']">
            <xsl:text>.page .par {</xsl:text>
                <xsl:call-template name="readCssAttr" />
            <xsl:text>}</xsl:text>
    </xsl:template>
    
    <xsl:template match="Element[@name='table.title']">
        <xsl:text>table thead * {</xsl:text>
            <xsl:call-template name="readCssAttr" />
        <xsl:text>}</xsl:text>
    </xsl:template>
    
    <xsl:template match="Element[@name='PageMarginsFirst']">
        <xsl:text>.page .pageResize {</xsl:text>
            <xsl:if test="smc_properties/smc_spacing/@margin-left != '' and smc_properties/smc_spacing/@unit != ''">
                <xsl:value-of select="concat('padding-left: ', smc_properties/smc_spacing/@margin-left, smc_properties/smc_spacing/@unit, ' !important;')" />
            </xsl:if>
            <xsl:if test="smc_properties/smc_spacing/@margin-top != '' and smc_properties/smc_spacing/@unit != ''">
                <xsl:value-of select="concat('padding-top: ', smc_properties/smc_spacing/@margin-top, smc_properties/smc_spacing/@unit, ' !important;')" />
            </xsl:if>
            <xsl:if test="smc_properties/smc_spacing/@margin-right != '' and smc_properties/smc_spacing/@unit != ''">
                <xsl:value-of select="concat('padding-right: ', smc_properties/smc_spacing/@margin-right, smc_properties/smc_spacing/@unit, ' !important;')" />
            </xsl:if>
            <xsl:if test="smc_properties/smc_spacing/@margin-bottom != '' and smc_properties/smc_spacing/@unit != ''">
                <xsl:value-of select="concat('padding-bottom: ', smc_properties/smc_spacing/@margin-bottom, smc_properties/smc_spacing/@unit, ' !important;')" />
            </xsl:if>
        <xsl:text>}</xsl:text>
        
        <xsl:text>.page .bodyContent .spacerBottom{</xsl:text>
            <xsl:if test="smc_properties/smc_spacing/@padding-bottom != '' and smc_properties/smc_spacing/@unit != ''">
                <xsl:value-of select="concat('height: ', smc_properties/smc_spacing/@padding-bottom, smc_properties/smc_spacing/@unit, ';')" />
            </xsl:if>
        <xsl:text>}</xsl:text>
    </xsl:template>
    
    <xsl:template match="Element[@name='table.header']">
        <xsl:text>table thead * {</xsl:text>
            <xsl:call-template name="readCssAttr" />
        <xsl:text>}</xsl:text>
    </xsl:template>
    
    <xsl:template match="Element[@name='table.row']">
        <xsl:text>table tr {</xsl:text>
            <xsl:call-template name="readCssAttr" />
        <xsl:text>}</xsl:text>
    </xsl:template>
</xsl:stylesheet>