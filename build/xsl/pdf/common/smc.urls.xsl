<?xml version="1.0" encoding="utf-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" version="1.0">

	<xsl:key name="IDFinder" match="//InfoMap" use="@ID"/>

	<xsl:param name="Mail"/>
	
	<xsl:param name="trafo"/>
	<xsl:param name="plugin"/>
	<xsl:param name="tp_bookServerID"/>
	
	<xsl:template name="getURL">
		<xsl:param name="fileID"/>
		<xsl:param name="masterID"/>
		<xsl:param name="rootPath"/>
		<xsl:param name="sourcePath"/>
		<xsl:param name="suffix"/>
		<xsl:param name="transformWith"/>
		<xsl:param name="bookID"/>
		<xsl:param name="versionLabel"/>
		<xsl:param name="linkServerID"/>

		<xsl:variable name="infomapElem" select="(key('IDFinder', $fileID))[1]/ancestor-or-self::InfoMap[not(@isSubSection)][1]"/>

		<xsl:variable name="name">
			<xsl:choose>
				<xsl:when test="$infomapElem">
					<xsl:apply-templates select="$infomapElem" mode="getHTMLFilename"/>
				</xsl:when>
				<xsl:otherwise>
					<xsl:value-of select="$fileID"/>
				</xsl:otherwise>
			</xsl:choose>
		</xsl:variable>

		<xsl:variable name="path">
			<xsl:choose>
				<xsl:when test="$infomapElem/@subSitePath">
					<xsl:value-of select="$infomapElem/@subSitePath"/>
				</xsl:when>
				<xsl:otherwise>
					<xsl:value-of select="$infomapElem/@path"/>
				</xsl:otherwise>
			</xsl:choose>
		</xsl:variable>

		<xsl:variable name="pObjType">
			<xsl:choose>
				<xsl:when test="string-length(@objType) &gt; 0">
					<xsl:value-of select="@objType"/>
				</xsl:when>
				<xsl:otherwise>
					<xsl:value-of select="$objType"/>
				</xsl:otherwise>
			</xsl:choose>
		</xsl:variable>

		<xsl:variable name="pBookID">
			<xsl:choose>
				<xsl:when test="string-length($bookID) &gt; 0">
					<xsl:value-of select="$bookID"/>
				</xsl:when>
				<xsl:otherwise>
					<xsl:value-of select="$tp_bookID"/>
				</xsl:otherwise>
			</xsl:choose>
		</xsl:variable>
		
		<!-- http://127.0.0.1:8082/SMC3.1/plugin-transformer?uri=%2FiTNC%20530%20de%2FiTNC%20530%2FZus%C3%A4tzliche%20Funktionen%2FZus%C3%A4tzliche%20Funktionen.theme&language=de&objType=doc&serverID=JH_SMC30&tp_subRulesID=1218727591407&tp_stylesID=&tp_characterizationIDs=&tp_metaCharacterizationIDs=&tp_propContextXML=&tp_bookID=1219355283332&tp_nodeID=1383525849&PickerElement=&imageAssetsPath=http%3A%2F%2F127.0.0.1%3A8082%2FSMC3.1%2Fclient%2Fplugins%2Fdoc%2Fcontent%2F&plugin=doc&trafo=HTML-TNC-Live&rnd=1227123280218 -->
		<xsl:choose>
			<xsl:when test="$Online = 'Online' or $Mail = 'Mail'">
				<xsl:variable name="transformer">
					<xsl:choose>
						<xsl:when test="$Mail = 'Mail'">HTML</xsl:when>
						<xsl:otherwise>
							<xsl:value-of select="$trafo"/>
						</xsl:otherwise>
					</xsl:choose>
				</xsl:variable>
				<xsl:variable name="plugin2">
					<xsl:choose>
						<xsl:when test="$Mail = 'Mail'">doc</xsl:when>
						<xsl:otherwise>
							<xsl:value-of select="$plugin"/>
						</xsl:otherwise>
					</xsl:choose>
				</xsl:variable>

				<xsl:variable name="currentServerID">
					<xsl:choose>
						<xsl:when test="string-length($linkServerID) &gt; 0">
							<xsl:value-of select="$linkServerID"/>
						</xsl:when>
						<xsl:otherwise>
							<xsl:value-of select="$serverID"/>
						</xsl:otherwise>
					</xsl:choose>
				</xsl:variable>
				
				<xsl:if test="$Mail = 'Mail'">
					<xsl:choose>
						<xsl:when test="string-length($brokerServerURL) &gt; 0">
							<xsl:value-of select="$brokerServerURL"/>
						</xsl:when>
						<xsl:otherwise>
							<xsl:value-of select="$tp_brokerServerURL"/>
						</xsl:otherwise>
					</xsl:choose>
					<xsl:text>/plugin-transformer</xsl:text>
				</xsl:if>
				<xsl:value-of select="concat('?', 'plugin=', $plugin2, '&amp;trafo=', $transformer, '&amp;language=', $language, '&amp;webdavID=', $fileID, '&amp;objType=', $pObjType, '&amp;serverID=', $currentServerID, 
							  '&amp;tp_subRulesID=', $tp_subRulesID, '&amp;tp_bookID=', $pBookID, '&amp;tp_nodeID=', $masterID)"/>
				<xsl:if test="string-length($tp_bookServerID) &gt; 0">
					<xsl:value-of select="concat('&amp;tp_bookServerID=', $tp_bookServerID)"/>
				</xsl:if>
				<xsl:if test="string-length($transformWith) &gt; 0">
					<xsl:value-of select="concat('&amp;transformWith=', $transformWith)"/>
				</xsl:if>
				<xsl:if test="string-length($versionLabel) &gt; 0">
					<xsl:value-of select="concat('&amp;versionLabel=', $versionLabel)"/>
				</xsl:if>
				<xsl:if test="$suffix = '_print'">
					<xsl:value-of select="'&amp;tp_PRINT=true'"/>
				</xsl:if>
			</xsl:when>
			<xsl:otherwise>
				<xsl:variable name="fixedPath1">
					<xsl:choose>
						<xsl:when test="substring($path, string-length($path)) = '/' or string-length($path) = 0">
							<xsl:value-of select="$path"/>
						</xsl:when>
						<xsl:otherwise>
							<xsl:value-of select="concat($path, '/')"/>
						</xsl:otherwise>
					</xsl:choose>
				</xsl:variable>
				<xsl:variable name="isBelow" select="string-length($sourcePath) &gt; 0 and string-length($fixedPath1) &gt; 0 and starts-with($fixedPath1, $sourcePath)"/>
				<xsl:variable name="fixedPath2">
					<xsl:choose>
						<xsl:when test="$isBelow">
							<xsl:value-of select="substring-after($fixedPath1, $sourcePath)"/>
						</xsl:when>
						<xsl:otherwise>
							<xsl:value-of select="$fixedPath1"/>
						</xsl:otherwise>
					</xsl:choose>
				</xsl:variable>
				<xsl:variable name="fixedPath">
					<xsl:choose>
						<xsl:when test="(string-length($rootPath) = 0 or $isBelow) and starts-with($fixedPath2, '/')">
							<xsl:value-of select="substring-after($fixedPath2, '/')"/>
						</xsl:when>
						<xsl:otherwise>
							<xsl:value-of select="$fixedPath2"/>
						</xsl:otherwise>
					</xsl:choose>
				</xsl:variable>
				<xsl:variable name="basePath">
					<xsl:choose>
						<xsl:when test="$isBelow">
							<xsl:value-of select="$fixedPath"/>
						</xsl:when>
						<xsl:otherwise>
							<xsl:value-of select="concat($rootPath, $fixedPath)"/>
						</xsl:otherwise>
					</xsl:choose>
				</xsl:variable>
				<xsl:apply-templates select="current()" mode="URLPathPrinter">
					<xsl:with-param name="basePath" select="$basePath"/>
					<xsl:with-param name="fileBaseName" select="$name"/>
					<xsl:with-param name="infomapElem" select="$infomapElem"/>
					<xsl:with-param name="suffix" select="$suffix"/>
					<xsl:with-param name="path" select="concat($basePath, $name, $suffix, '.html')"/>
				</xsl:apply-templates>
			</xsl:otherwise>
		</xsl:choose>
	</xsl:template>

	<xsl:template match="*" mode="URLPathPrinter">
		<xsl:param name="path"/>
		<xsl:param name="basePath"/>
		<xsl:param name="fileBaseName"/>
		<xsl:param name="infomapElem"/>
		<xsl:param name="suffix"/>
		<xsl:value-of select="$path"/>
	</xsl:template>

</xsl:stylesheet>