<?xml version="1.0" encoding="utf-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:fo="http://www.w3.org/1999/XSL/Format" version="1.0">

	<xsl:param name="showColorBars">false</xsl:param>
	<xsl:param name="pageWidth">84mm</xsl:param>
	<xsl:param name="pageHeight">53mm</xsl:param>
	<xsl:param name="bleed">3</xsl:param>
	<xsl:param name="cropOffset">10</xsl:param>
	<xsl:param name="dimension"/>

	<xsl:template match="/">

		<xsl:variable name="pageWidthMM">
			<xsl:choose>
				<xsl:when test="number(substring-before($pageWidth, 'mm'))">
					<xsl:value-of select="substring-before($pageWidth, 'mm')"/>
				</xsl:when>
				<xsl:when test="number(substring-before($pageWidth, 'cm'))">
					<xsl:value-of select="substring-before($pageWidth, 'cm')"/>
				</xsl:when>
			</xsl:choose>
		</xsl:variable>

		<xsl:variable name="newPageWidth" select="concat($pageWidthMM, 'mm')"/>

		<xsl:variable name="pageHeightMM">
			<xsl:choose>
				<xsl:when test="number(substring-before($pageHeight, 'mm'))">
					<xsl:value-of select="substring-before($pageHeight, 'mm')"/>
				</xsl:when>
				<xsl:when test="number(substring-before($pageHeight, 'cm'))">
					<xsl:value-of select="substring-before($pageHeight, 'cm')"/>
				</xsl:when>
			</xsl:choose>
		</xsl:variable>

		<xsl:variable name="newPageHeight" select="concat($pageHeightMM, 'mm')"/>

		<fo:root xmlns:fo="http://www.w3.org/1999/XSL/Format" xmlns:fox="http://xmlgraphics.apache.org/fop/extensions">
			<fo:layout-master-set>
				<fo:simple-page-master fox:bleed="{$bleed}mm" fox:crop-box="media-box" fox:crop-offset="{$cropOffset}mm" master-name="odd" page-width="{$pageWidth}" page-height="{$pageHeight}">
					<fo:region-body/>
					<fo:region-before extent="15mm" region-name="before-odd"/>
				</fo:simple-page-master>
			</fo:layout-master-set>
			<fo:page-sequence master-reference="odd">
				<fo:static-content flow-name="before-odd">
					<fo:block-container absolute-position="fixed">
						<fo:block line-height="1" font-size="0pt">
							<fo:instream-foreign-object>
								<svg xmlns="http://www.w3.org/2000/svg" version="1.1"
									xmlns:xlink="http://www.w3.org/1999/xlink"
									width="{$newPageWidth}" height="{$newPageHeight}" viewBox="0 0 {$pageWidthMM} {$pageHeightMM}" overflow="visible">
									<style type="text/css"><![CDATA[
    .line { fill:none; stroke:black; stroke-width:0.1 }
    .colorbox { stroke:black; stroke-width:0.1 }
]]></style>

									<xsl:if test="not($showColorBars = 'false')">
										<defs>
											<rect id="box" class="colorbox" width="5" height="4"/>
										</defs>
									</xsl:if>
									<g id="cut-marks">
										<polyline class="line" points="0,-{$bleed} 0,-{$cropOffset}" />
										<polyline class="line" points="{$pageWidthMM},-{$bleed} {$pageWidthMM},-{$cropOffset}" />

										<polyline class="line" points="-{$bleed},0 -{$cropOffset},0" />
										<polyline class="line" points="-{$bleed},{$pageHeightMM} -{$cropOffset},{$pageHeightMM}" />

										<polyline class="line" points="0,{$pageHeightMM + $bleed} 0,{$pageHeightMM + $cropOffset}" />
										<polyline class="line" points="{$pageWidthMM},{$pageHeightMM + $bleed} {$pageWidthMM},{$pageHeightMM + $cropOffset}" />

										<polyline class="line" points="{$pageWidthMM + $bleed},0 {$pageWidthMM + $cropOffset},0" />
										<polyline class="line" points="{$pageWidthMM + $bleed},{$pageHeightMM} {$pageWidthMM + $cropOffset},{$pageHeightMM}" />

										<xsl:if test="string-length($dimension) &gt; 0 and contains($dimension, 'x')">
											<xsl:call-template name="writePageCutLines">
												<xsl:with-param name="dimension" select="$dimension"/>
												<xsl:with-param name="pageWidthMM" select="$pageWidthMM"/>
												<xsl:with-param name="pageHeightMM" select="$pageHeightMM"/>
											</xsl:call-template>
										</xsl:if>
									</g>

									<xsl:if test="not($showColorBars = 'false')">
										<g id="grays" transform="translate({$pageWidthMM + 4},4)">
											<use xlink:href="#box" y="0" style="fill:rgb(0%,0%,0%)"/>
											<use xlink:href="#box" y="4" style="fill:rgb(10%,10%,10%)"/>
											<use xlink:href="#box" y="8" style="fill:rgb(20%,20%,20%)"/>
											<use xlink:href="#box" y="12" style="fill:rgb(30%,30%,30%)"/>
											<use xlink:href="#box" y="16" style="fill:rgb(40%,40%,40%)"/>
											<use xlink:href="#box" y="20" style="fill:rgb(50%,50%,50%)"/>
											<use xlink:href="#box" y="24" style="fill:rgb(60%,60%,60%)"/>
											<use xlink:href="#box" y="28" style="fill:rgb(70%,70%,70%)"/>
											<use xlink:href="#box" y="32" style="fill:rgb(80%,80%,80%)"/>
											<use xlink:href="#box" y="36" style="fill:rgb(90%,90%,90%)"/>
											<use xlink:href="#box" y="40" style="fill:rgb(100%,100%,100%)"/>
										</g>
										<!--<g id="cyan" transform="translate(4,-9)">
								<use xlink:href="#box" x="0" style="fill:rgb(0%,100%,100%)"/>
								<use xlink:href="#box" x="5" style="fill:rgb(5%,100%,100%)"/>
								<use xlink:href="#box" x="10" style="fill:rgb(25%,100%,100%)"/>
								<use xlink:href="#box" x="15" style="fill:rgb(50%,100%,100%)"/>
								<use xlink:href="#box" x="20" style="fill:rgb(75%,100%,100%)"/>
								<use xlink:href="#box" x="25" style="fill:rgb(95%,100%,100%)"/>
							</g>
							<g id="magenta" transform="translate(50,-9)">
								<use xlink:href="#box" x="0" style="fill:rgb(100%,0%,100%)"/>
								<use xlink:href="#box" x="5" style="fill:rgb(100%,5%,100%)"/>
								<use xlink:href="#box" x="10" style="fill:rgb(100%,25%,100%)"/>
								<use xlink:href="#box" x="15" style="fill:rgb(100%,50%,100%)"/>
								<use xlink:href="#box" x="20" style="fill:rgb(100%,75%,100%)"/>
								<use xlink:href="#box" x="25" style="fill:rgb(100%,95%,100%)"/>
							</g>
							<g id="yellow" transform="translate(4, {$pageHeightMM + 5})">
								<use xlink:href="#box" x="0" style="fill:rgb(100%,100%,0%)"/>
								<use xlink:href="#box" x="5" style="fill:rgb(100%,100%,5%)"/>
								<use xlink:href="#box" x="10" style="fill:rgb(100%,100%,25%)"/>
								<use xlink:href="#box" x="15" style="fill:rgb(100%,100%,50%)"/>
								<use xlink:href="#box" x="20" style="fill:rgb(100%,100%,75%)"/>
								<use xlink:href="#box" x="25" style="fill:rgb(100%,100%,95%)"/>
							</g>-->
										<g id="base-colors" transform="translate({$pageWidthMM - 34},{$pageHeightMM + 5})">
											<use xlink:href="#box" x="0" style="fill:red"/>
											<use xlink:href="#box" x="5" style="fill:green"/>
											<use xlink:href="#box" x="10" style="fill:blue"/>
											<use xlink:href="#box" x="15" style="fill:cyan"/>
											<use xlink:href="#box" x="20" style="fill:magenta"/>
											<use xlink:href="#box" x="25" style="fill:yellow"/>
										</g>
									</xsl:if>
								</svg>
							</fo:instream-foreign-object>
						</fo:block>
					</fo:block-container>
				</fo:static-content>
				<fo:flow flow-name="xsl-region-body">
					<fo:block/>
				</fo:flow>
			</fo:page-sequence>
		</fo:root>

	</xsl:template>

	<xsl:template name="writePageCutLines">
		<xsl:param name="dimension"/>
		<xsl:param name="pageWidthMM"/>
		<xsl:param name="pageHeightMM"/>

		<xsl:variable name="horizontal" select="substring-before($dimension, 'x')"/>
		<xsl:variable name="vertical" select="substring-after($dimension, 'x')"/>

		<xsl:call-template name="writePageXCutLines">
			<xsl:with-param name="times" select="$horizontal - 1"/>
			<xsl:with-param name="posx" select="$pageWidthMM div $horizontal"/>
			<xsl:with-param name="pageHeightMM" select="$pageHeightMM"/>
		</xsl:call-template>

		<xsl:call-template name="writePageYCutLines">
			<xsl:with-param name="times" select="$vertical - 1"/>
			<xsl:with-param name="posy" select="$pageHeightMM div $vertical"/>
			<xsl:with-param name="pageWidthMM" select="$pageWidthMM"/>
		</xsl:call-template>
	</xsl:template>

	<xsl:template name="writePageXCutLines" xmlns="http://www.w3.org/2000/svg">
		<xsl:param name="times"/>
		<xsl:param name="current" select="1"/>
		<xsl:param name="posx" select="1"/>
		<xsl:param name="pageHeightMM"/>

		<xsl:if test="$current &lt;= $times">
			<line class="line" y1="-{$bleed}" x1="{$posx * $current}" y2="-{$cropOffset}" x2="{$posx * $current}"/>
			<line class="line" y1="{$pageHeightMM + $bleed}" x1="{$posx * $current}" y2="{$pageHeightMM + $cropOffset}" x2="{$posx * $current}"/>
			<xsl:call-template name="writePageXCutLines">
				<xsl:with-param name="current" select="$current + 1"/>
				<xsl:with-param name="times" select="$times"/>
				<xsl:with-param name="posx" select="$posx"/>
				<xsl:with-param name="pageHeightMM" select="$pageHeightMM"/>
			</xsl:call-template>
		</xsl:if>
	</xsl:template>

	<xsl:template name="writePageYCutLines" xmlns="http://www.w3.org/2000/svg">
		<xsl:param name="times"/>
		<xsl:param name="current" select="1"/>
		<xsl:param name="posy" select="1"/>
		<xsl:param name="pageWidthMM"/>

		<xsl:if test="$current &lt;= $times">
			<line class="line" y1="{$posy * $current}" x1="-{$bleed}" y2="{$posy * $current}" x2="-{$cropOffset}"/>
			<line class="line" y1="{$posy * $current}" x1="{$pageWidthMM + $bleed}" y2="{$posy * $current}" x2="{$pageWidthMM + $cropOffset}"/>
			<xsl:call-template name="writePageYCutLines">
				<xsl:with-param name="current" select="$current + 1"/>
				<xsl:with-param name="times" select="$times"/>
				<xsl:with-param name="posy" select="$posy"/>
				<xsl:with-param name="pageWidthMM" select="$pageWidthMM"/>
			</xsl:call-template>
		</xsl:if>
	</xsl:template>
	
</xsl:stylesheet>
