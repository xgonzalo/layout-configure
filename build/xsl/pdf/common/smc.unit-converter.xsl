<?xml version="1.0" encoding="utf-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" version="1.0">

	<xsl:template match="Enum.Instruction" mode="calculateStart">
		<xsl:param name="current" select="1"/>
		<xsl:param name="childCount" select="count(EnumElement)"/>
		<xsl:param name="doCountSteps" select="true()"/>
		<xsl:param name="doCountTaskSteps" select="true()"/>
		
		<xsl:variable name="start" select="$current + $childCount"/>

		<xsl:choose>
			<xsl:when test="@type = 'Continue'">
				<xsl:choose>
					<xsl:when test="preceding-sibling::Enum.Instruction">
						<xsl:apply-templates select="preceding-sibling::Enum.Instruction[1]" mode="calculateStart">
							<xsl:with-param name="current" select="$start"/>
							<xsl:with-param name="doCountSteps" select="$doCountSteps"/>
							<xsl:with-param name="doCountTaskSteps" select="$doCountTaskSteps"/>
						</xsl:apply-templates>
					</xsl:when>
					<xsl:when test="parent::Block/preceding-sibling::Block[not(not($doCountSteps) and @Function = 'block.instruction') and not(not($doCountTaskSteps) and @Function = 'block.task') and Enum.Instruction]/Enum.Instruction">
						<xsl:choose>
							<xsl:when test="parent::Block/preceding-sibling::Block[not(not($doCountSteps) and @Function = 'block.instruction') and not(not($doCountTaskSteps) and @Function = 'block.task') and Enum.Instruction][1]/*[position() = last()]/self::Enum.Instruction">
								<xsl:apply-templates select="parent::Block/preceding-sibling::Block[not(not($doCountSteps) and @Function = 'block.instruction') and not(not($doCountTaskSteps) and @Function = 'block.task') and Enum.Instruction][1]/*[position() = last()]/self::Enum.Instruction" mode="calculateStart">
									<xsl:with-param name="current" select="$start"/>
									<xsl:with-param name="doCountSteps" select="$doCountSteps"/>
									<xsl:with-param name="doCountTaskSteps" select="$doCountTaskSteps"/>
								</xsl:apply-templates>
							</xsl:when>
							<xsl:otherwise>
								<xsl:apply-templates select="parent::Block/preceding-sibling::Block[not(not($doCountSteps) and @Function = 'block.instruction') and not(not($doCountTaskSteps) and @Function = 'block.task') and Enum.Instruction][1]/*[position() = last()]/preceding-sibling::Enum.Instruction[1]" mode="calculateStart">
									<xsl:with-param name="current" select="$start"/>
									<xsl:with-param name="doCountSteps" select="$doCountSteps"/>
									<xsl:with-param name="doCountTaskSteps" select="$doCountTaskSteps"/>
								</xsl:apply-templates>
							</xsl:otherwise>
						</xsl:choose>
					</xsl:when>
					<xsl:otherwise>
						<xsl:value-of select="$start"/>
					</xsl:otherwise>
				</xsl:choose>
			</xsl:when>
			<xsl:otherwise>
				<xsl:value-of select="$start"/>
			</xsl:otherwise>
		</xsl:choose>
	</xsl:template>

	<xsl:template match="Enum" mode="calculateStart">
		<xsl:param name="current" select="1"/>
		<xsl:param name="numericType"/>
		<xsl:param name="numericContinueType"/>
		<xsl:param name="childCount" select="count(EnumElement)"/>

		<xsl:variable name="start" select="$current + $childCount"/>

		<xsl:choose>
			<xsl:when test="@type = $numericContinueType">
				<xsl:choose>
					<xsl:when test="(preceding-sibling::Enum[@type = $numericType or @type = $numericContinueType]
							  | parent::tableCell/preceding-sibling::tableCell/Enum[@type = $numericType or @type = $numericContinueType]
							  | parent::tableCell/parent::tableRow/preceding-sibling::tableRow/tableCell/Enum[@type = $numericType or @type = $numericContinueType]
							  | parent::tableCell/parent::tableRow/parent::tableStandard/preceding-sibling::tableHead/tableRow/tableCell/Enum[@type = $numericType or @type = $numericContinueType]
							  | parent::tableCell/parent::tableRow/../../preceding-sibling::Enum[@type = $numericType or @type = $numericContinueType]
							  | preceding-sibling::*[name() = 'table' or name() = 'table.NoBorder']/*/tableRow/tableCell/Enum[@type = $numericType or @type = $numericContinueType])">
						<xsl:for-each select="(preceding-sibling::Enum[@type = $numericType or @type = $numericContinueType]
							  | parent::tableCell/preceding-sibling::tableCell/Enum[@type = $numericType or @type = $numericContinueType]
							  | parent::tableCell/parent::tableRow/preceding-sibling::tableRow/tableCell/Enum[@type = $numericType or @type = $numericContinueType]
							  | parent::tableCell/parent::tableRow/parent::tableStandard/preceding-sibling::tableHead/tableRow/tableCell/Enum[@type = $numericType or @type = $numericContinueType]
							  | parent::tableCell/parent::tableRow/../../preceding-sibling::Enum[@type = $numericType or @type = $numericContinueType]
							  | preceding-sibling::*[name() = 'table' or name() = 'table.NoBorder']/*/tableRow/tableCell/Enum[@type = $numericType or @type = $numericContinueType])[position() = last()]">
							<xsl:apply-templates select="current()" mode="calculateStart">
								<xsl:with-param name="current" select="$start"/>
								<xsl:with-param name="numericType" select="$numericType"/>
								<xsl:with-param name="numericContinueType" select="$numericContinueType"/>
							</xsl:apply-templates>
						</xsl:for-each>
					</xsl:when>
					<xsl:when test="ancestor::Block[1]/preceding-sibling::Block//Enum[@type = $numericType or @type = $numericContinueType]">
						<xsl:for-each select="(ancestor::Block[1]/preceding-sibling::Block//Enum[@type = $numericType or @type = $numericContinueType])[position() = last()]">
							<xsl:apply-templates select="current()" mode="calculateStart">
								<xsl:with-param name="current" select="$start"/>
								<xsl:with-param name="numericType" select="$numericType"/>
								<xsl:with-param name="numericContinueType" select="$numericContinueType"/>
							</xsl:apply-templates>
						</xsl:for-each>
					</xsl:when>
					<xsl:otherwise>
						<xsl:value-of select="$start"/>
					</xsl:otherwise>
				</xsl:choose>
			</xsl:when>
			<xsl:when test="@type = $numericType">
				<xsl:value-of select="$start"/>
			</xsl:when>
			<xsl:otherwise>
				<xsl:value-of select="0"/>
			</xsl:otherwise>
		</xsl:choose>
	</xsl:template>

	<xsl:template name="getPixels">
		<xsl:param name="value"/>
		<xsl:param name="dpi" select="72"/>
		<xsl:choose>
			<xsl:when test="string-length($value) = 0">
				<xsl:value-of select="0"/>
			</xsl:when>
			<xsl:when test="$value = '0'">
				<xsl:value-of select="0"/>
			</xsl:when>
			<xsl:when test="number(substring($value, 0, string-length($value) - 1)) = 0">
				<xsl:value-of select="0"/>
			</xsl:when>
			<xsl:when test="number(substring-before($value, 'mm'))">
				<xsl:value-of select="(number(substring-before($value, 'mm')) div 25.4) * $dpi"/>
			</xsl:when>
			<xsl:when test="number(substring-before($value, 'cm'))">
				<xsl:value-of select="(number(substring-before($value, 'cm')) div 2.54) * $dpi"/>
			</xsl:when>
			<xsl:when test="number(substring-before($value, 'in'))">
				<xsl:value-of select="number(substring-before($value, 'in')) * $dpi"/>
			</xsl:when>
			<xsl:when test="number(substring-before($value, 'pt'))">
				<xsl:value-of select="(number(substring-before($value, 'pt')) * 72) div $dpi"/>
			</xsl:when>
			<xsl:when test="number(substring-before($value, 'px'))">
				<xsl:value-of select="number(substring-before($value, 'px'))"/>
			</xsl:when>
			<xsl:when test="string(number($value)) != 'NaN'">
				<xsl:value-of select="$value"/>
			</xsl:when>
			<xsl:otherwise>0</xsl:otherwise>
		</xsl:choose>
	</xsl:template>

	<xsl:template name="calcDimension">
		<xsl:param name="dimToCalc"/>
		<xsl:param name="dimToCalcMax"/>
		<xsl:param name="secondDim"/>
		<xsl:param name="secondDimMax"/>

		<xsl:choose>
			<xsl:when test="$dimToCalc &lt;= $dimToCalcMax and $secondDim &lt;= $secondDimMax">
				<xsl:value-of select="$dimToCalc"/>
			</xsl:when>
			<xsl:when test="$dimToCalc &gt; $dimToCalcMax">
				<xsl:call-template name="calcDimension">
					<xsl:with-param name="dimToCalc" select="$dimToCalcMax"/>
					<xsl:with-param name="dimToCalcMax" select="$dimToCalcMax"/>
					<xsl:with-param name="secondDim" select="($dimToCalcMax div $dimToCalc) * $secondDim"/>
					<xsl:with-param name="secondDimMax" select="$secondDimMax"/>
				</xsl:call-template>
			</xsl:when>
			<xsl:when test="$secondDim &gt; $secondDimMax">
				<xsl:call-template name="calcDimension">
					<xsl:with-param name="dimToCalc" select="($secondDimMax div $secondDim) * $dimToCalc"/>
					<xsl:with-param name="dimToCalcMax" select="$dimToCalcMax"/>
					<xsl:with-param name="secondDim" select="$secondDimMax"/>
					<xsl:with-param name="secondDimMax" select="$secondDimMax"/>
				</xsl:call-template>
			</xsl:when>
		</xsl:choose>

	</xsl:template>

	<xsl:template name="formatNumber">
		<xsl:param name="number" select="."/>
		<xsl:param name="unit" select="@unit"/>
		<xsl:value-of select="$number"/>
		<xsl:if test="string-length($unit) &gt; 0">
			<xsl:value-of select="$unit"/>
		</xsl:if>
	</xsl:template>

</xsl:stylesheet>