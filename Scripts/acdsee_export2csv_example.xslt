<?xml version="1.0"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" version="2.0">

<xsl:output method="text"/>

<xsl:template match="/">   
 <xsl:apply-templates select="ACDDB/AssetList/Asset/AssetCategoryList/AssetCategory" />     
</xsl:template>
  
<xsl:template match="AssetCategory">
<xsl:choose>
<xsl:when test="contains(../../Folder, '9999999')">  
<xsl:message terminate="no">Omitted invalid path: <xsl:value-of select="../../Folder" /></xsl:message>
</xsl:when>
<xsl:when test="contains(../../Folder, '99EF0000')">
<xsl:value-of select="replace(../../Folder, '&lt;Local\\99EF0000&gt;\\', 'D:\\')" /><xsl:value-of select="../../Name" /><xsl:text>;</xsl:text><xsl:value-of select="." /><xsl:text>
</xsl:text>
</xsl:when>
<xsl:otherwise>
<xsl:message terminate="yes">Invalid path: <xsl:value-of select="../../Folder" /></xsl:message>
</xsl:otherwise>
</xsl:choose>
</xsl:template>

</xsl:stylesheet>