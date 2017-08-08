<?xml version="1.0" encoding="utf-8"?>
<xsl:stylesheet
	xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
	version="1.0">
	
	<xsl:template name="replace">
		<xsl:param name="string" select="''"/>
		<xsl:param name="pattern" select="''"/>
		<xsl:param name="replacement" select="''"/>
		<xsl:choose>
			<xsl:when test="$pattern != '' and $string != '' and contains($string, $pattern)">
				<xsl:value-of select="substring-before($string, $pattern)"/>
				<!--
				Use "xsl:copy-of" instead of "xsl:value-of" so that users
				may substitute nodes as well as strings for $replacement.
				-->
				<xsl:copy-of select="$replacement"/>
				<xsl:call-template name="replace">
					<xsl:with-param name="string" select="substring-after($string, $pattern)"/>
					<xsl:with-param name="pattern" select="$pattern"/>
					<xsl:with-param name="replacement" select="$replacement"/>
				</xsl:call-template>
			</xsl:when>
			<xsl:otherwise>
				<xsl:value-of select="$string"/>
			</xsl:otherwise>
		</xsl:choose>
	</xsl:template>

	<xsl:template name="encodeToUTF8">
		<xsl:param name="string"/>
		<xsl:call-template name="replace">
			<xsl:with-param name="string">
				<xsl:call-template name="replace">
					<xsl:with-param name="string">
						<xsl:call-template name="replace">
							<xsl:with-param name="string">
								<xsl:call-template name="replace">
									<xsl:with-param name="string">
										<xsl:call-template name="replace">
											<xsl:with-param name="string">
												<xsl:call-template name="replace">
													<xsl:with-param name="string">
														<xsl:call-template name="replace">
															<xsl:with-param name="string">
																<xsl:call-template name="replace">
																	<xsl:with-param name="string" select="$string"/>
																	<xsl:with-param name="pattern" select="' '"/>
																	<xsl:with-param name="replacement" select="'+'"/>
																</xsl:call-template>
															</xsl:with-param>
															<xsl:with-param name="pattern" select="'ü'"/>
															<xsl:with-param name="replacement" select="'%C3%BC'"/>
														</xsl:call-template>
													</xsl:with-param>
													<xsl:with-param name="pattern" select="'Ö'"/>
													<xsl:with-param name="replacement" select="'%C3%96'"/>
												</xsl:call-template>
											</xsl:with-param>
											<xsl:with-param name="pattern" select="'Ä'"/>
											<xsl:with-param name="replacement" select="'%C3%84'"/>
										</xsl:call-template>
									</xsl:with-param>
									<xsl:with-param name="pattern" select="'Ü'"/>
									<xsl:with-param name="replacement" select="'%C3%9C'"/>
								</xsl:call-template>
							</xsl:with-param>
							<xsl:with-param name="pattern" select="'ö'"/>
							<xsl:with-param name="replacement" select="'%C3%B6'"/>
						</xsl:call-template>
					</xsl:with-param>
					<xsl:with-param name="pattern" select="'ä'"/>
					<xsl:with-param name="replacement" select="'%C3%A4'"/>
				</xsl:call-template>
			</xsl:with-param>
			<xsl:with-param name="pattern" select="'ü'"/>
			<xsl:with-param name="replacement" select="'%C3%BC'"/>
		</xsl:call-template>
	</xsl:template>
	
</xsl:stylesheet>