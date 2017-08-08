<?xml version="1.0" encoding="utf-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:fo="http://www.w3.org/1999/XSL/Format" xmlns:fox="http://xmlgraphics.apache.org/fop/extensions" version="1.0">

	<xsl:template match="EnumElement">
		<xsl:param name="type" select="string(parent::Enum/@type)"/>
		<xsl:param name="level"/>
		<xsl:param name="secondLevelDefaultChar">&#xB0;</xsl:param>
		<xsl:param name="widows"/>
		<xsl:param name="orphans"/>
		<xsl:param name="enumCount"/>
		<xsl:param name="currentEnum" select="count(preceding-sibling::*[name() != 'enum.title'])"/>

		<fo:list-item>
			<xsl:variable name="useKeepsForWidowsOrphans">
				<xsl:call-template name="getTemplateVariableValue">
					<xsl:with-param name="name">ENUM_USE_KEEPS_FOR_WIDOWS_ORPHANS</xsl:with-param>
				</xsl:call-template>
			</xsl:variable>
			<xsl:if test="not($useKeepsForWidowsOrphans = 'false')">
				<xsl:if test="string(number($orphans)) != 'NaN' and $orphans &gt; $currentEnum">
					<xsl:if test="$currentEnum &gt; 0">
						<xsl:attribute name="keep-with-previous">always</xsl:attribute>
					</xsl:if>
					<xsl:attribute name="keep-together.within-page">20</xsl:attribute>
					<xsl:attribute name="keep-together.within-column">20</xsl:attribute>
				</xsl:if>
				<xsl:if test="string(number($widows)) != 'NaN' and $widows &gt; ($enumCount - ($currentEnum + 1))">
					<xsl:if test="not($enumCount = ($currentEnum + 1)) and (string-length(following-sibling::*) &gt; 0 or following-sibling::*[*])">
						<xsl:attribute name="keep-with-next">always</xsl:attribute>
					</xsl:if>
					<xsl:attribute name="keep-together.within-page">20</xsl:attribute>
					<xsl:attribute name="keep-together.within-column">20</xsl:attribute>
				</xsl:if>
			</xsl:if>
			<xsl:call-template name="addStyle">
				<xsl:with-param name="name">enum.element</xsl:with-param>
			</xsl:call-template>
			<xsl:call-template name="addStyle">
				<xsl:with-param name="name" select="concat('enum.element.', $level)"/>
			</xsl:call-template>
			<xsl:if test="not(preceding-sibling::EnumElement)">
				<xsl:call-template name="addStyle">
					<xsl:with-param name="name">enum.element.first</xsl:with-param>
				</xsl:call-template>
				<xsl:call-template name="addStyle">
					<xsl:with-param name="name" select="concat('enum.element.first.', $level)"/>
				</xsl:call-template>
			</xsl:if>
			<xsl:if test="name(preceding-sibling::*[1]) = 'enum.title' and string-length(../enum.title) &gt; 0">
				<xsl:attribute name="space-before">0pt</xsl:attribute>
			</xsl:if>

			<fo:list-item-label end-indent="label-end()">
				<fo:block id="list-item-label-{generate-id()}">
					<xsl:call-template name="addStyle">
						<xsl:with-param name="name">enum.element.label</xsl:with-param>
					</xsl:call-template>
					<xsl:call-template name="addStyle">
						<xsl:with-param name="name" select="concat('enum.element.label.', $level)"/>
					</xsl:call-template>
					<xsl:call-template name="addStyle">
						<xsl:with-param name="name" select="concat('enum.element.label.', $type)"/>
					</xsl:call-template>
					<xsl:choose>
						<xsl:when test="$type = 'NoSymbol'"></xsl:when>
						<xsl:when test="starts-with($type, 'Alpha')">
							<xsl:apply-templates select="current()" mode="alpha">
								<xsl:with-param name="type" select="$type"/>
							</xsl:apply-templates>
						</xsl:when>
						<xsl:when test="starts-with($type, 'Numeric')">
							<xsl:apply-templates select="current()" mode="numeric">
								<xsl:with-param name="type" select="$type"/>
							</xsl:apply-templates>
						</xsl:when>
						<xsl:when test="starts-with($type, 'Line')">
							<xsl:text>–</xsl:text>
						</xsl:when>
						<xsl:when test="$type = 'Bullet'">
							<xsl:variable name="pic_url">
								<xsl:call-template name="getTemplateGraphicURL">
									<xsl:with-param name="name">enum.element.Bullet</xsl:with-param>
								</xsl:call-template>
							</xsl:variable>
							<xsl:choose>
								<xsl:when test="string-length($pic_url) &gt; 0">
									<fo:inline>
										<fo:external-graphic src="url('{$pic_url}')"/>
									</fo:inline>
								</xsl:when>
								<xsl:otherwise>
									<xsl:apply-templates select="current()" mode="bullet">
										<xsl:with-param name="level" select="$level"/>
										<xsl:with-param name="type" select="$type"/>
									</xsl:apply-templates>
								</xsl:otherwise>
							</xsl:choose>
						</xsl:when>
						<xsl:when test="$type = 'Arrow'">
							<xsl:variable name="pic_url">
								<xsl:call-template name="getTemplateGraphicURL">
									<xsl:with-param name="name">enum.element.Arrow</xsl:with-param>
								</xsl:call-template>
							</xsl:variable>
							<xsl:choose>
								<xsl:when test="string-length($pic_url) &gt; 0">
									<fo:inline>
										<fo:external-graphic src="url('{$pic_url}')"/>
									</fo:inline>
								</xsl:when>
								<xsl:otherwise>
									<xsl:apply-templates select="current()" mode="arrow">
										<xsl:with-param name="level" select="$level"/>
										<xsl:with-param name="type" select="$type"/>
									</xsl:apply-templates>
								</xsl:otherwise>
							</xsl:choose>
						</xsl:when>
						<xsl:otherwise>
							<xsl:variable name="pic_url">
								<xsl:call-template name="getTemplateGraphicURL">
									<xsl:with-param name="name" select="concat('enum.element.', $type)"/>
								</xsl:call-template>
							</xsl:variable>
							<xsl:choose>
								<xsl:when test="string-length($pic_url) &gt; 0">
									<fo:inline>
										<fo:external-graphic src="url('{$pic_url}')"/>
									</fo:inline>
								</xsl:when>
								<xsl:otherwise>
									<xsl:apply-templates select="current()" mode="default">
										<xsl:with-param name="level" select="$level"/>
										<xsl:with-param name="secondLevelDefaultChar" select="$secondLevelDefaultChar"/>
										<xsl:with-param name="type" select="$type"/>
									</xsl:apply-templates>
								</xsl:otherwise>
							</xsl:choose>
						</xsl:otherwise>
					</xsl:choose>
				</fo:block>
			</fo:list-item-label>

			<fo:list-item-body start-indent="body-start()">
				<fo:block widows="2" orphans="2">
					<xsl:call-template name="addStyle">
						<xsl:with-param name="name">enum.element.text</xsl:with-param>
					</xsl:call-template>
					<xsl:apply-templates select="current()" mode="writeCharacterizationInfo">
						<xsl:with-param name="bPadding" select="true()"/>
					</xsl:apply-templates>
					<xsl:apply-templates>
						<xsl:with-param name="level" select="$level"/>
					</xsl:apply-templates>
					<xsl:apply-templates select="current()" mode="end"/>
				</fo:block>
			</fo:list-item-body>

		</fo:list-item>
	</xsl:template>

	<xsl:template match="EnumElement" mode="end"/>

	<xsl:template match="EnumElement" mode="numeric">
		<xsl:param name="type"/>

		<xsl:variable name="ENUM_NR_PREFIX">
			<xsl:call-template name="getTemplateVariableValue">
				<xsl:with-param name="name" select="concat('ENUM_PREFIX_', $type)"/>
			</xsl:call-template>
		</xsl:variable>
		<xsl:variable name="ENUM_NR_SUFFIX">
			<xsl:call-template name="getTemplateVariableValue">
				<xsl:with-param name="name" select="concat('ENUM_SUFFIX_', $type)"/>
			</xsl:call-template>
		</xsl:variable>

		<xsl:variable name="counter">
			<xsl:choose>
				<xsl:when test="parent::Enum/@type = 'NumericContinue'">
					<xsl:apply-templates select="parent::Enum" mode="calculateStart">
						<xsl:with-param name="childCount" select="count(preceding-sibling::EnumElement)"/>
						<xsl:with-param name="numericType">Numeric</xsl:with-param>
						<xsl:with-param name="numericContinueType">NumericContinue</xsl:with-param>
					</xsl:apply-templates>
				</xsl:when>
				<xsl:when test="string-length(parent::Enum/@startNumber) &gt; 0 and string(number(parent::Enum/@startNumber)) != 'NaN'">
					<xsl:value-of select="parent::Enum/@startNumber + count(preceding-sibling::EnumElement)"/>
				</xsl:when>
				<xsl:otherwise>
					<xsl:value-of select="count(preceding-sibling::EnumElement) + 1"/>
				</xsl:otherwise>
			</xsl:choose>
		</xsl:variable>

		<xsl:value-of select="concat($ENUM_NR_PREFIX, $counter, $ENUM_NR_SUFFIX)"/>
	</xsl:template>

	<xsl:template match="EnumElement" mode="alpha">
		<xsl:param name="type"/>
		<xsl:variable name="counter">
			<xsl:choose>
				<xsl:when test="string-length(parent::Enum/@startNumber) &gt; 0 and string(number(parent::Enum/@startNumber)) != 'NaN'">
					<xsl:value-of select="parent::Enum/@startNumber + count(preceding-sibling::EnumElement)"/>
				</xsl:when>
				<xsl:otherwise>
					<xsl:value-of select="count(preceding-sibling::EnumElement) + 1"/>
				</xsl:otherwise>
			</xsl:choose>
		</xsl:variable>
		<xsl:variable name="ENUM_NR_SUFFIX">
			<xsl:call-template name="getTemplateVariableValue">
				<xsl:with-param name="name" select="concat('ENUM_SUFFIX_', $type)"/>
				<xsl:with-param name="defaultValue">)</xsl:with-param>
			</xsl:call-template>
		</xsl:variable>
		<xsl:value-of select="concat(substring('abcdefghijklmnopqrstuvwxyz', $counter, 1), $ENUM_NR_SUFFIX)"/>
	</xsl:template>

	<xsl:template match="EnumElement" mode="default">
		<xsl:param name="secondLevelDefaultChar"/>
		<xsl:param name="level"/>
		<xsl:param name="type"/>

		<xsl:choose>
			<xsl:when test="$isPDFXMODE">
				<xsl:variable name="font">
					<xsl:call-template name="getFormat">
						<xsl:with-param name="name">enum.element.label.char</xsl:with-param>
						<xsl:with-param name="attributeName">font-family</xsl:with-param>
					</xsl:call-template>
				</xsl:variable>
				<xsl:choose>
					<xsl:when test="string-length($font) &gt; 0">
						<xsl:call-template name="addStyle">
							<xsl:with-param name="name" select="'enum.element.label.char'"/>
						</xsl:call-template>
					</xsl:when>
					<xsl:otherwise>
						<xsl:attribute name="font-family">Arial Unicode MS</xsl:attribute>
						<xsl:attribute name="font-size">150%</xsl:attribute>
					</xsl:otherwise>
				</xsl:choose>
			</xsl:when>
			<xsl:otherwise>
				<xsl:attribute name="font-family">Courier</xsl:attribute>
				<xsl:call-template name="addStyle">
					<xsl:with-param name="name" select="'enum.element.label.char'"/>
				</xsl:call-template>
			</xsl:otherwise>
		</xsl:choose>

		<xsl:variable name="firstLevelChar">
			<xsl:call-template name="getTemplateVariableValue">
				<xsl:with-param name="name" select="concat('ENUM_', $type, '_FIRST_LEVEL_DEFAULT_CHARACTER')"/>
				<xsl:with-param name="defaultValue">&#x2022;</xsl:with-param>
			</xsl:call-template>
		</xsl:variable>
		<xsl:choose>
			<xsl:when test="$level mod 2 = 0">
				<xsl:call-template name="getTemplateVariableValue">
					<xsl:with-param name="name" select="concat('ENUM_', $type, '_SECOND_LEVEL_DEFAULT_CHARACTER')"/>
					<xsl:with-param name="defaultValue" select="$secondLevelDefaultChar"/>
				</xsl:call-template>
			</xsl:when>
			<xsl:otherwise>
				<xsl:value-of select="$firstLevelChar"/>
			</xsl:otherwise>
		</xsl:choose>
	</xsl:template>

	<xsl:template match="EnumElement" mode="arrow">
		<xsl:param name="type"/>
		<xsl:param name="level"/>
		<fo:inline>
			<xsl:choose>
				<xsl:when test="$isPDFXMODE">
					<xsl:attribute name="font-family">Arial Unicode MS</xsl:attribute>
				</xsl:when>
				<xsl:otherwise>
					<xsl:attribute name="font-family">
						<xsl:apply-templates select="current()" mode="getArrowDefaultFont"/>
					</xsl:attribute>
				</xsl:otherwise>
			</xsl:choose>
			<xsl:attribute name="vertical-align">middle</xsl:attribute>
			<xsl:call-template name="addStyle">
				<xsl:with-param name="name" select="'enum.element.label.char'"/>
			</xsl:call-template>
			<xsl:call-template name="addStyle">
				<xsl:with-param name="name" select="concat('enum.element.label.char.', $level)"/>
			</xsl:call-template>
			<xsl:variable name="firstLevelChar">
				<xsl:call-template name="getTemplateVariableValue">
					<xsl:with-param name="name" select="concat('ENUM_', $type, '_FIRST_LEVEL_DEFAULT_CHARACTER')"/>
					<xsl:with-param name="defaultValue">&#x27AF;</xsl:with-param>
				</xsl:call-template>
			</xsl:variable>
			<xsl:choose>
				<xsl:when test="$level mod 2 = 0">
					<xsl:call-template name="getTemplateVariableValue">
						<xsl:with-param name="name" select="concat('ENUM_', $type, '_SECOND_LEVEL_DEFAULT_CHARACTER')"/>
						<xsl:with-param name="defaultValue" select="$firstLevelChar"/>
					</xsl:call-template>
				</xsl:when>
				<xsl:otherwise>
					<xsl:value-of select="$firstLevelChar"/>
				</xsl:otherwise>
			</xsl:choose>
		</fo:inline>
	</xsl:template>

	<xsl:template match="EnumElement" mode="getArrowDefaultFont">ZapfDingbats</xsl:template>

	<xsl:template match="EnumElement" mode="bullet">
		<xsl:param name="level"/>
		<xsl:param name="type"/>

		<xsl:variable name="defaultValue">&#x25A0;</xsl:variable>
		<xsl:variable name="firstLevelChar">
			<xsl:call-template name="getTemplateVariableValue">
				<xsl:with-param name="name" select="concat('ENUM_', $type, '_FIRST_LEVEL_DEFAULT_CHARACTER')"/>
				<xsl:with-param name="defaultValue" select="$defaultValue"/>
			</xsl:call-template>
		</xsl:variable>
		<xsl:variable name="secondLevelChar">
			<xsl:call-template name="getTemplateVariableValue">
				<xsl:with-param name="name" select="concat('ENUM_', $type, '_SECOND_LEVEL_DEFAULT_CHARACTER')"/>
				<xsl:with-param name="defaultValue" select="$firstLevelChar"/>
			</xsl:call-template>
		</xsl:variable>

		<fo:inline>
			<xsl:attribute name="vertical-align">middle</xsl:attribute>
			<xsl:choose>
				<xsl:when test="$level mod 2 = 1 or $secondLevelChar = $firstLevelChar">
					<xsl:choose>
						<xsl:when test="$isPDFXMODE">
							<xsl:attribute name="font-family">Arial Unicode MS</xsl:attribute>
							<xsl:attribute name="font-size">75%</xsl:attribute>
						</xsl:when>
						<xsl:otherwise>
							<xsl:attribute name="font-family">
								<xsl:apply-templates select="current()" mode="getBulletDefaultFont"/>
							</xsl:attribute>
							<xsl:attribute name="font-size">50%</xsl:attribute>
						</xsl:otherwise>
					</xsl:choose>
					<xsl:call-template name="addStyle">
						<xsl:with-param name="name" select="'enum.element.label.char'"/>
					</xsl:call-template>
					<xsl:value-of select="$firstLevelChar"/>
				</xsl:when>
				<xsl:otherwise>
					<xsl:call-template name="addStyle">
						<xsl:with-param name="name" select="'enum.element.label.char'"/>
					</xsl:call-template>
					<xsl:value-of select="$secondLevelChar"/>
				</xsl:otherwise>
			</xsl:choose>
		</fo:inline>
	</xsl:template>

	<xsl:template match="EnumElement" mode="getBulletDefaultFont">ZapfDingbats</xsl:template>

	<xsl:template match="Enum">
		<xsl:param name="level" select="1"/>
		<xsl:param name="isInsideNotice" select="false()"/>
		<xsl:param name="insideTableCell">false</xsl:param>

		<xsl:variable name="currLevel">
			<xsl:choose>
				<xsl:when test="parent::Enum or parent::Enum.Instruction">
					<xsl:value-of select="$level + 1"/>
				</xsl:when>
				<xsl:otherwise>
					<xsl:value-of select="$level"/>
				</xsl:otherwise>
			</xsl:choose>
		</xsl:variable>

		<xsl:variable name="defaultType">
			<xsl:call-template name="getTemplateVariableValue">
				<xsl:with-param name="name" select="concat('ENUM_', $currLevel, '_DEFAULT_TYPE')"/>
				<xsl:with-param name="defaultValue">
					<xsl:call-template name="getTemplateVariableValue">
						<xsl:with-param name="name" select="'ENUM_DEFAULT_TYPE'"/>
					</xsl:call-template>
				</xsl:with-param>
			</xsl:call-template>
		</xsl:variable>

		<xsl:variable name="type">
			<xsl:choose>
				<xsl:when test="string-length(@type) &gt; 0">
					<xsl:call-template name="getTemplateVariableValue">
						<xsl:with-param name="name" select="concat('ENUM_', @type, '_TYPE')"/>
						<xsl:with-param name="defaultValue" select="@type"/>
					</xsl:call-template>
				</xsl:when>
				<xsl:otherwise>
					<xsl:value-of select="$defaultType"/>
				</xsl:otherwise>
			</xsl:choose>
		</xsl:variable>

		<xsl:variable name="secondLevelDefaultChar">
			<xsl:call-template name="getTemplateVariableValue">
				<xsl:with-param name="name" select="'ENUM_SECOND_LEVEL_DEFAULT_CHARACTER'"/>
				<xsl:with-param name="defaultValue">&#xB0;</xsl:with-param>
			</xsl:call-template>
		</xsl:variable>

		<xsl:variable name="enumIndent">
			<xsl:choose>
				<xsl:when test="$insideTableCell = 'true'">
					<xsl:call-template name="getTemplateVariableValue">
						<xsl:with-param name="name" select="concat('TABLE_ENUM_INDENT.', $type)"/>
						<xsl:with-param name="defaultValue">
							<xsl:call-template name="getTemplateVariableValue">
								<xsl:with-param name="name" select="concat('ENUM_INDENT.', $type)"/>
								<xsl:with-param name="defaultValue">
									<xsl:call-template name="getTemplateVariableValue">
										<xsl:with-param name="name" select="'ENUM_INDENT'"/>
										<xsl:with-param name="defaultValue" select="5"/>
									</xsl:call-template>
								</xsl:with-param>
							</xsl:call-template>
						</xsl:with-param>
					</xsl:call-template>
				</xsl:when>
				<xsl:otherwise>
					<xsl:call-template name="getTemplateVariableValue">
						<xsl:with-param name="name" select="concat('ENUM_INDENT.', $type)"/>
						<xsl:with-param name="defaultValue">
							<xsl:call-template name="getTemplateVariableValue">
								<xsl:with-param name="name" select="'ENUM_INDENT'"/>
								<xsl:with-param name="defaultValue" select="5"/>
							</xsl:call-template>
						</xsl:with-param>
					</xsl:call-template>
				</xsl:otherwise>
			</xsl:choose>
		</xsl:variable>

		<xsl:variable name="hasChildren" select="descendant::enum.title[string-length(.) &gt; 0 or Media.theme] or descendant-or-self::Enum/*[name() != 'enum.title' and name() != 'Enum']"/>

		<xsl:variable name="orphans">
			<xsl:call-template name="getFormat">
				<xsl:with-param name="name">enum.standard</xsl:with-param>
				<xsl:with-param name="attributeName">orphans</xsl:with-param>
				<xsl:with-param name="defaultValue" select="2"/>
			</xsl:call-template>
		</xsl:variable>

		<xsl:variable name="widows">
			<xsl:call-template name="getFormat">
				<xsl:with-param name="name">enum.standard</xsl:with-param>
				<xsl:with-param name="attributeName">widows</xsl:with-param>
				<xsl:with-param name="defaultValue" select="2"/>
			</xsl:call-template>
		</xsl:variable>

		<xsl:variable name="enumCount">
			<xsl:value-of select="count(*[name() != 'enum.title'])"/>
		</xsl:variable>



		<xsl:choose>
			<xsl:when test="parent::Enum or parent::Enum.Instruction">
				<xsl:if test="$hasChildren">
					<fo:list-item>
						<xsl:call-template name="addStyle">
							<xsl:with-param name="name">enum.element</xsl:with-param>
						</xsl:call-template>
						<xsl:call-template name="addStyle">
							<xsl:with-param name="name">enum.standard</xsl:with-param>
							<xsl:with-param name="attributeNamesList">|space-after|space-before|keep-together.within-page|keep-together.within-column|</xsl:with-param>
						</xsl:call-template>
						<fo:list-item-label end-indent="label-end()">
							<fo:block></fo:block>
						</fo:list-item-label>
						<fo:list-item-body start-indent="body-start()">
							<fo:list-block provisional-distance-between-starts="{$enumIndent}mm">
								<xsl:call-template name="addStyle">
									<xsl:with-param name="name">enum.standard</xsl:with-param>
								</xsl:call-template>
								<xsl:apply-templates select="current()" mode="applyWidowOrphans">
									<xsl:with-param name="name">enum.standard</xsl:with-param>
								</xsl:apply-templates>
								<xsl:call-template name="addStyle">
									<xsl:with-param name="name" select="concat('enum.standard.', $level)"/>
								</xsl:call-template>
								<xsl:apply-templates select="current()" mode="writeCharacterizationInfo">
									<xsl:with-param name="bPadding" select="true()"/>
								</xsl:apply-templates>
								<xsl:apply-templates mode="Enum">
									<xsl:with-param name="type" select="$type"/>
									<xsl:with-param name="level" select="$currLevel"/>
									<xsl:with-param name="secondLevelDefaultChar" select="$secondLevelDefaultChar"/>
									<xsl:with-param name="orphans" select="$orphans"/>
									<xsl:with-param name="widows" select="$widows"/>
									<xsl:with-param name="enumCount" select="$enumCount"/>
								</xsl:apply-templates>
							</fo:list-block>
						</fo:list-item-body>
					</fo:list-item>
				</xsl:if>
			</xsl:when>
			<xsl:otherwise>
				<xsl:if test="$hasChildren">
					<fo:list-block provisional-distance-between-starts="{$enumIndent}mm">
						<xsl:call-template name="addStyle">
							<xsl:with-param name="name">block-level-element</xsl:with-param>
						</xsl:call-template>
						<xsl:call-template name="addStyle">
							<xsl:with-param name="name">enum.standard</xsl:with-param>
						</xsl:call-template>
						<xsl:call-template name="addStyle">
							<xsl:with-param name="name" select="concat('enum.standard.', $level)"/>
						</xsl:call-template>
						<xsl:if test="string-length(@style) &gt; 0">
							<xsl:call-template name="addStyle">
								<xsl:with-param name="name" select="@style"/>
							</xsl:call-template>
						</xsl:if>						
						<xsl:apply-templates select="current()" mode="applyWidowOrphans">
							<xsl:with-param name="name">enum.standard</xsl:with-param>
							<xsl:with-param name="orphansDefault" select="2"/>
							<xsl:with-param name="widowsDefault" select="2"/>
						</xsl:apply-templates>
						<xsl:if test="$isInsideNotice">
							<xsl:call-template name="addStyle">
								<xsl:with-param name="name">enum.standard.notice</xsl:with-param>
							</xsl:call-template>
						</xsl:if>
						<xsl:if test="$insideTableCell = 'true'">
							<xsl:call-template name="addStyle">
								<xsl:with-param name="name">table.cell.enum.standard</xsl:with-param>
							</xsl:call-template>
						</xsl:if>
						<xsl:apply-templates select="current()" mode="writeCharacterizationInfo">
							<xsl:with-param name="bPadding" select="true()"/>
						</xsl:apply-templates>
						<xsl:apply-templates mode="Enum">
							<xsl:with-param name="type" select="$type"/>
							<xsl:with-param name="level" select="$level"/>
							<xsl:with-param name="secondLevelDefaultChar" select="$secondLevelDefaultChar"/>
							<xsl:with-param name="orphans" select="$orphans"/>
							<xsl:with-param name="widows" select="$widows"/>
							<xsl:with-param name="enumCount" select="count(*[name() != 'enum.title'])"/>
						</xsl:apply-templates>
					</fo:list-block>
				</xsl:if>
			</xsl:otherwise>
		</xsl:choose>
	</xsl:template>

	<xsl:template match="*" mode="Enum">
		<xsl:param name="type" select="string(parent::Enum/@type)"/>
		<xsl:param name="level"/>
		<xsl:param name="orphans"/>
		<xsl:param name="widows"/>
		<xsl:param name="enumCount"/>
		<xsl:param name="secondLevelDefaultChar">&#xB0;</xsl:param>
		
		<xsl:apply-templates select="current()">
			<xsl:with-param name="type" select="$type"/>
			<xsl:with-param name="level" select="$level"/>
			<xsl:with-param name="orphans" select="$orphans"/>
			<xsl:with-param name="widows" select="$widows"/>	
			<xsl:with-param name="enumCount" select="$enumCount"/>	
			<xsl:with-param name="secondLevelDefaultChar" select="$secondLevelDefaultChar"/>
		</xsl:apply-templates>
	</xsl:template>

	<xsl:template match="Enum" mode="Enum.Instruction">
		<xsl:apply-templates select="current()"/>
	</xsl:template>

	<xsl:template match="Enum.Instruction">
		
		<xsl:variable name="blockType" select="string(ancestor::Block/@Function)"/>
		<xsl:variable name="isInsideBlockTask" select="$blockType = 'block.task' or @type = 'DontNumber'"/>

		<xsl:variable name="STEP_INDENT">
			<xsl:choose>
				<xsl:when test="$isInsideBlockTask">
					<xsl:call-template name="getTemplateVariableValue">
						<xsl:with-param name="name" select="'STEP_TASK_INDENT'"/>
						<xsl:with-param name="defaultValue">
							<xsl:call-template name="getTemplateVariableValue">
								<xsl:with-param name="name" select="'STEP_INDENT'"/>
								<xsl:with-param name="defaultValue">
									<xsl:call-template name="getTemplateVariableValue">
										<xsl:with-param name="name" select="'ENUM_INDENT'"/>
										<xsl:with-param name="defaultValue" select="5"/>
									</xsl:call-template>
								</xsl:with-param>
							</xsl:call-template>
						</xsl:with-param>
					</xsl:call-template>
				</xsl:when>
				<xsl:otherwise>
					<xsl:call-template name="getTemplateVariableValue">
						<xsl:with-param name="name" select="'STEP_INDENT'"/>
						<xsl:with-param name="defaultValue">
							<xsl:call-template name="getTemplateVariableValue">
								<xsl:with-param name="name" select="'ENUM_INDENT'"/>
								<xsl:with-param name="defaultValue" select="5"/>
							</xsl:call-template>
						</xsl:with-param>
					</xsl:call-template>
				</xsl:otherwise>
			</xsl:choose>
		</xsl:variable>

		<xsl:variable name="orphans">
			<xsl:call-template name="getFormat">
				<xsl:with-param name="name">instruction</xsl:with-param>
				<xsl:with-param name="attributeName">orphans</xsl:with-param>
				<xsl:with-param name="defaultValue" select="2"/>
			</xsl:call-template>
		</xsl:variable>

		<xsl:variable name="widows">
			<xsl:call-template name="getFormat">
				<xsl:with-param name="name">instruction</xsl:with-param>
				<xsl:with-param name="attributeName">widows</xsl:with-param>
				<xsl:with-param name="defaultValue" select="2"/>
			</xsl:call-template>
		</xsl:variable>

		<xsl:if test="EnumElement or InfoPar or precondition or result">
			<fo:list-block provisional-distance-between-starts="{$STEP_INDENT}mm">
				<xsl:call-template name="addStyle">
					<xsl:with-param name="name">block-level-element</xsl:with-param>
				</xsl:call-template>
				<xsl:call-template name="addStyle">
					<xsl:with-param name="name">instruction</xsl:with-param>
				</xsl:call-template>
				<xsl:apply-templates select="current()" mode="applyWidowOrphans">
					<xsl:with-param name="name">instruction</xsl:with-param>
					<xsl:with-param name="orphansDefault" select="2"/>
					<xsl:with-param name="widowsDefault" select="2"/>
				</xsl:apply-templates>
				<xsl:apply-templates select="current()" mode="writeCharacterizationInfo">
					<xsl:with-param name="bPadding" select="true()"/>
				</xsl:apply-templates>
				<xsl:apply-templates mode="Enum.Instruction">
					<xsl:with-param name="isInsideBlockTask" select="$isInsideBlockTask"/>
					<xsl:with-param name="orphans" select="$orphans"/>
					<xsl:with-param name="widows" select="$widows"/>
					<xsl:with-param name="enumCount" select="count(*)"/>
				</xsl:apply-templates>
			</fo:list-block>
		</xsl:if>
	</xsl:template>

	<xsl:template match="EnumElement" mode="Enum.Instruction">
		<xsl:param name="type"/>
		<xsl:param name="isInsideBlockTask"/>
		<xsl:param name="widows"/>
		<xsl:param name="orphans"/>
		<xsl:param name="enumCount"/>
		<xsl:param name="currentEnum" select="count(preceding-sibling::*)"/>

		<xsl:choose>
			<xsl:when test="parent::Enum">
				<xsl:apply-templates select="current()">
					<xsl:with-param name="type" select="$type"/>
				</xsl:apply-templates>
			</xsl:when>
			<xsl:otherwise>

				<xsl:variable name="stepIconUrl">
					<xsl:call-template name="getTemplateGraphicURL">
						<xsl:with-param name="name">step</xsl:with-param>
					</xsl:call-template>
				</xsl:variable>

				<xsl:variable name="stepTaskIconUrl">
					<xsl:call-template name="getTemplateGraphicURL">
						<xsl:with-param name="name">step.task</xsl:with-param>
					</xsl:call-template>
				</xsl:variable>

				<fo:list-item>
					<xsl:variable name="useKeepsForWidowsOrphans">
						<xsl:call-template name="getTemplateVariableValue">
							<xsl:with-param name="name">ENUM_USE_KEEPS_FOR_WIDOWS_ORPHANS</xsl:with-param>
						</xsl:call-template>
					</xsl:variable>
					<xsl:if test="not($useKeepsForWidowsOrphans = 'false')">
						<xsl:if test="string(number($orphans)) != 'NaN' and $orphans &gt; $currentEnum">
							<xsl:if test="$currentEnum &gt; 0">
								<xsl:attribute name="keep-with-previous">always</xsl:attribute>
							</xsl:if>
							<xsl:attribute name="keep-together.within-page">20</xsl:attribute>
							<xsl:attribute name="keep-together.within-column">20</xsl:attribute>
						</xsl:if>
						<xsl:if test="string(number($widows)) != 'NaN' and $widows &gt; ($enumCount - ($currentEnum + 1))">
							<xsl:if test="not($enumCount = ($currentEnum + 1)) and (string-length(following-sibling::*) &gt; 0 or following-sibling::*[*])">
								<xsl:attribute name="keep-with-next">always</xsl:attribute>
							</xsl:if>
							<xsl:attribute name="keep-together.within-page">20</xsl:attribute>
							<xsl:attribute name="keep-together.within-column">20</xsl:attribute>
						</xsl:if>
					</xsl:if>
					<xsl:call-template name="addStyle">
						<xsl:with-param name="name">step</xsl:with-param>
					</xsl:call-template>
					<fo:list-item-label end-indent="label-end()">
						<fo:block id="list-item-label-{generate-id()}">
							<xsl:call-template name="addStyle">
								<xsl:with-param name="name">step.label</xsl:with-param>
							</xsl:call-template>
							<xsl:if test="$isInsideBlockTask">
								<xsl:call-template name="addStyle">
									<xsl:with-param name="name">step.task.label</xsl:with-param>
								</xsl:call-template>
							</xsl:if>

							<xsl:variable name="pic_url">
								<xsl:choose>
									<xsl:when test="$isInsideBlockTask">
										<xsl:value-of select="$stepTaskIconUrl"/>
									</xsl:when>
									<xsl:otherwise>
										<xsl:value-of select="$stepIconUrl"/>
									</xsl:otherwise>
								</xsl:choose>
							</xsl:variable>
							<xsl:choose>
								<xsl:when test="string-length($pic_url) &gt; 0">
									<fo:inline>
										<fo:external-graphic src="url('{$pic_url}')"/>
									</fo:inline>
								</xsl:when>
								<xsl:when test="$isInsideBlockTask">
									<xsl:apply-templates select="current()" mode="Task">
										<xsl:with-param name="STEP_NR_PREFIX">
											<xsl:call-template name="getTemplateVariableValue">
												<xsl:with-param name="name" select="'STEP_TASK_PREFIX'"/>
											</xsl:call-template>
										</xsl:with-param>
										<xsl:with-param name="STEP_NR_SUFFIX">
											<xsl:call-template name="getTemplateVariableValue">
												<xsl:with-param name="name" select="'STEP_TASK_SUFFIX'"/>
											</xsl:call-template>
										</xsl:with-param>
										<xsl:with-param name="hasStepIcon" select="string-length($stepIconUrl) &gt; 0"/>
										<xsl:with-param name="hasStepTaskIcon" select="string-length($stepTaskIconUrl) &gt; 0"/>
									</xsl:apply-templates>
								</xsl:when>
								<xsl:otherwise>
									<xsl:apply-templates select="current()" mode="Instruction">
										<xsl:with-param name="STEP_NR_PREFIX">
											<xsl:call-template name="getTemplateVariableValue">
												<xsl:with-param name="name" select="'STEP_NR_PREFIX'"/>
											</xsl:call-template>
										</xsl:with-param>
										<xsl:with-param name="STEP_NR_SUFFIX">
											<xsl:call-template name="getTemplateVariableValue">
												<xsl:with-param name="name" select="'STEP_NR_SUFFIX'"/>
											</xsl:call-template>
										</xsl:with-param>
										<xsl:with-param name="hasStepIcon" select="string-length($stepIconUrl) &gt; 0"/>
										<xsl:with-param name="hasStepTaskIcon" select="string-length($stepTaskIconUrl) &gt; 0"/>
									</xsl:apply-templates>
								</xsl:otherwise>
							</xsl:choose>
						</fo:block>
					</fo:list-item-label>
					<fo:list-item-body start-indent="body-start()">
						<fo:block widows="2" orphans="2">
							<xsl:call-template name="addStyle">
								<xsl:with-param name="name">step.text</xsl:with-param>
							</xsl:call-template>
							<xsl:apply-templates select="current()" mode="writeCharacterizationInfo">
								<xsl:with-param name="bPadding" select="true()"/>
							</xsl:apply-templates>
							<xsl:apply-templates/>
						</fo:block>
					</fo:list-item-body>
				</fo:list-item>
			</xsl:otherwise>
		</xsl:choose>
	</xsl:template>

	<xsl:template match="EnumElement" mode="Task">
		<xsl:param name="STEP_NR_PREFIX"/>
		<xsl:param name="STEP_NR_SUFFIX"/>
		<xsl:param name="hasStepIcon"/>
		<xsl:param name="hasStepTaskIcon"/>

		<xsl:variable name="counter">
			<xsl:choose>
				<xsl:when test="parent::Enum.Instruction/@type = 'DontNumber'">
					<xsl:call-template name="getTemplateVariableValue">
						<xsl:with-param name="name">INSTRUCTION_TASK_CHARACTER</xsl:with-param>
						<xsl:with-param name="defaultValue">&#x25ba;</xsl:with-param>
					</xsl:call-template>
				</xsl:when>
				<xsl:when test="parent::Enum.Instruction/@type = 'Continue'">
					<xsl:apply-templates select="parent::Enum.Instruction" mode="calculateStart">
						<xsl:with-param name="childCount" select="count(preceding-sibling::EnumElement)"/>
						<xsl:with-param name="doCountSteps" select="not($hasStepIcon)"/>
						<xsl:with-param name="doCountTaskSteps" select="not($hasStepTaskIcon)"/>
					</xsl:apply-templates>
				</xsl:when>
				<xsl:otherwise>
					<xsl:value-of select="count(preceding-sibling::EnumElement) + 1"/>
				</xsl:otherwise>
			</xsl:choose>
		</xsl:variable>

		<xsl:value-of select="concat($STEP_NR_PREFIX, $counter, $STEP_NR_SUFFIX)"/>
	</xsl:template>

	<xsl:template match="EnumElement" mode="Instruction">
		<xsl:param name="STEP_NR_PREFIX"/>
		<xsl:param name="STEP_NR_SUFFIX"/>
		<xsl:param name="hasStepIcon"/>
		<xsl:param name="hasStepTaskIcon"/>

		<xsl:variable name="counter">
			<xsl:choose>
				<xsl:when test="parent::Enum.Instruction/@type = 'Continue'">
					<xsl:apply-templates select="parent::Enum.Instruction" mode="calculateStart">
						<xsl:with-param name="childCount" select="count(preceding-sibling::EnumElement)"/>
						<xsl:with-param name="doCountSteps" select="not($hasStepIcon)"/>
						<xsl:with-param name="doCountTaskSteps" select="not($hasStepTaskIcon)"/>
					</xsl:apply-templates>
				</xsl:when>
				<xsl:otherwise>
					<xsl:value-of select="count(preceding-sibling::EnumElement) + 1"/>
				</xsl:otherwise>
			</xsl:choose>
		</xsl:variable>

		<xsl:value-of select="concat($STEP_NR_PREFIX, $counter, $STEP_NR_SUFFIX)"/>
	</xsl:template>
	
	<xsl:template match="InfoItem.Warning | Media | InfoPar | table | table.NoBorder | InfoPar.Code | legend | code.example | Include.Content" mode="Enum.Instruction">
		<fo:list-item>
			<xsl:call-template name="addStyle">
				<xsl:with-param name="name">step</xsl:with-param>
			</xsl:call-template>
			<fo:list-item-label end-indent="label-end()">
				<fo:block></fo:block>
			</fo:list-item-label>
			<fo:list-item-body start-indent="body-start()">
				<fo:block-container>
					<fo:block start-indent="0" widows="2" orphans="2">
						<xsl:apply-templates select="current()">
							<xsl:with-param name="isInsideInstruction" select="true()"/>
						</xsl:apply-templates>
					</fo:block>
				</fo:block-container>
			</fo:list-item-body>
		</fo:list-item>
	</xsl:template>

	<xsl:template match="InfoItem.Warning | Media | Media.theme | InfoPar | table | table.NoBorder | InfoPar.Code | legend | code.example | Include.Content" mode="Enum">
		<fo:list-item>
			<xsl:call-template name="addStyle">
				<xsl:with-param name="name">enum.element</xsl:with-param>
			</xsl:call-template>
			<fo:list-item-label end-indent="label-end()">
				<fo:block></fo:block>
			</fo:list-item-label>
			<fo:list-item-body start-indent="body-start()">
				<fo:block-container>
					<fo:block start-indent="0" widows="2" orphans="2">
						<xsl:apply-templates select="current()">
							<xsl:with-param name="isInsideInstruction" select="true()"/>
						</xsl:apply-templates>
					</fo:block>
				</fo:block-container>
			</fo:list-item-body>
		</fo:list-item>
	</xsl:template>

	<xsl:template match="TableDesc" mode="Enum"/>

	<xsl:template match="enum.title">
		<xsl:param name="level"/>
		<xsl:if test="string-length(.) &gt; 0 or Media.theme">
			<fo:list-item>
				<xsl:call-template name="addStyle">
					<xsl:with-param name="name">enum.title</xsl:with-param>
				</xsl:call-template>
				<xsl:call-template name="addStyle">
					<xsl:with-param name="name" select="concat('enum.title.', $level)"/>
				</xsl:call-template>
				<fo:list-item-label>
					<fo:block>
						<xsl:apply-templates select="current()" mode="writeCharacterizationInfo">
							<xsl:with-param name="bPadding" select="true()"/>
						</xsl:apply-templates>
						<xsl:apply-templates/>
					</fo:block>
				</fo:list-item-label>
				<fo:list-item-body>
					<fo:block></fo:block>
				</fo:list-item-body>
			</fo:list-item>
		</xsl:if>
	</xsl:template>

	<xsl:template match="result" mode="Enum.Instruction">
		<xsl:param name="type"/>
		<xsl:param name="isInsideBlockTask"/>

		<xsl:variable name="pic_url">
			<xsl:call-template name="getTemplateGraphicURL">
				<xsl:with-param name="name">result</xsl:with-param>
			</xsl:call-template>
		</xsl:variable>

		<fo:list-item>
			<xsl:call-template name="addStyle">
				<xsl:with-param name="name">step</xsl:with-param>
			</xsl:call-template>
			<xsl:call-template name="addStyle">
				<xsl:with-param name="name">result</xsl:with-param>
			</xsl:call-template>
			<fo:list-item-label end-indent="label-end()">
				<fo:block id="list-item-label-{generate-id()}">
					<xsl:call-template name="addStyle">
						<xsl:with-param name="name">step.label</xsl:with-param>
					</xsl:call-template>

					<xsl:choose>
						<xsl:when test="string-length($pic_url) &gt; 0">
							<fo:inline>
								<fo:external-graphic src="url('{$pic_url}')"/>
							</fo:inline>
						</xsl:when>
						<xsl:otherwise>
							<fo:inline>
								<xsl:choose>
									<xsl:when test="$isPDFXMODE">
										<xsl:attribute name="font-family">Arial Unicode MS</xsl:attribute>
									</xsl:when>
									<xsl:otherwise>
										<xsl:attribute name="font-family">
											<xsl:apply-templates select="current()" mode="getDefaultFont"/>
										</xsl:attribute>
									</xsl:otherwise>
								</xsl:choose>
								<xsl:call-template name="getTemplateVariableValue">
									<xsl:with-param name="name" select="'RESULT_CHARACTER'"/>
									<xsl:with-param name="defaultValue">&#x2713;</xsl:with-param>
								</xsl:call-template>
							</fo:inline>
						</xsl:otherwise>
					</xsl:choose>
				</fo:block>
			</fo:list-item-label>
			<fo:list-item-body start-indent="body-start()">
				<fo:block>
					<xsl:call-template name="addStyle">
						<xsl:with-param name="name">step.text</xsl:with-param>
					</xsl:call-template>
					<xsl:apply-templates select="current()" mode="writeCharacterizationInfo">
						<xsl:with-param name="bPadding" select="true()"/>
					</xsl:apply-templates>
					<xsl:apply-templates/>
				</fo:block>
			</fo:list-item-body>
		</fo:list-item>
		
	</xsl:template>

	<xsl:template match="precondition" mode="Enum.Instruction">
		<xsl:param name="type"/>
		<xsl:param name="isInsideBlockTask"/>

		<xsl:variable name="pic_url">
			<xsl:call-template name="getTemplateGraphicURL">
				<xsl:with-param name="name">precondition</xsl:with-param>
			</xsl:call-template>
		</xsl:variable>

		<fo:list-item>
			<xsl:call-template name="addStyle">
				<xsl:with-param name="name">step</xsl:with-param>
			</xsl:call-template>
			<xsl:call-template name="addStyle">
				<xsl:with-param name="name">precondition</xsl:with-param>
			</xsl:call-template>
			<fo:list-item-label end-indent="label-end()">
				<fo:block id="list-item-label-{generate-id()}">
					<xsl:call-template name="addStyle">
						<xsl:with-param name="name">step.label</xsl:with-param>
					</xsl:call-template>

					<xsl:choose>
						<xsl:when test="string-length($pic_url) &gt; 0">
							<fo:inline>
								<fo:external-graphic src="url('{$pic_url}')"/>
							</fo:inline>
						</xsl:when>
						<xsl:otherwise>
							<fo:inline>
								<xsl:choose>
									<xsl:when test="$isPDFXMODE">
										<xsl:attribute name="font-family">Arial Unicode MS</xsl:attribute>
									</xsl:when>
									<xsl:otherwise>
										<xsl:attribute name="font-family">
											<xsl:apply-templates select="current()" mode="getDefaultFont"/>
										</xsl:attribute>
									</xsl:otherwise>
								</xsl:choose>
								<xsl:call-template name="getTemplateVariableValue">
									<xsl:with-param name="name" select="'PRECONDITION_CHARACTER'"/>
									<xsl:with-param name="defaultValue"></xsl:with-param>
								</xsl:call-template>
							</fo:inline>
						</xsl:otherwise>
					</xsl:choose>
				</fo:block>
			</fo:list-item-label>
			<fo:list-item-body start-indent="body-start()">
				<fo:block>
					<xsl:call-template name="addStyle">
						<xsl:with-param name="name">step.text</xsl:with-param>
					</xsl:call-template>
					<xsl:apply-templates/>
				</fo:block>
			</fo:list-item-body>
		</fo:list-item>
		
	</xsl:template>

	<xsl:template match="result | precondition" mode="getDefaultFont">Arial Unicode MS</xsl:template>

</xsl:stylesheet>
