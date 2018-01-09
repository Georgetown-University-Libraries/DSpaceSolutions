<?xml version="1.0" encoding="UTF-8"?>
<!--

    The contents of this file are subject to the license and copyright
    detailed in the LICENSE and NOTICE files at the root of the source
    tree and available online at

    http://www.dspace.org/license/

-->

<xsl:stylesheet xmlns:i18n="http://apache.org/cocoon/i18n/2.1"
    xmlns:dri="http://di.tamu.edu/DRI/1.0/"
    xmlns:mets="http://www.loc.gov/METS/"
    xmlns:metsrights="http://cosimo.stanford.edu/sdr/metsrights/"
    xmlns:xlink="http://www.w3.org/TR/xlink/"
    xmlns:xsl="http://www.w3.org/1999/XSL/Transform" version="1.0"
    xmlns:dim="http://www.dspace.org/xmlns/dspace/dim"
    xmlns:xhtml="http://www.w3.org/1999/xhtml"
    xmlns:mods="http://www.loc.gov/mods/v3"
    xmlns:dc="http://purl.org/dc/elements/1.1/"
    xmlns:confman="org.dspace.core.ConfigurationManager"
     xmlns="http://www.w3.org/1999/xhtml"
    exclude-result-prefixes="i18n dri mets xlink xsl dim xhtml mods dc">
  
    <xsl:variable name="SCH_SCHOLARLY">https://schema.org/ScholarlyArticle</xsl:variable>
    <xsl:variable name="SCH_BOOK">https://schema.org/Book</xsl:variable>
    <xsl:variable name="SCH_VID">https://schema.org/VideoObject</xsl:variable>
    <xsl:variable name="SCH_PHOTO">https://schema.org/Photograph</xsl:variable>
    <xsl:variable name="SCH_VISART">https://schema.org/VisualArtwork</xsl:variable>
    <xsl:variable name="SCH_DEFAULT">http://schema.org/CreativeWork</xsl:variable>

    <xsl:variable name="base-path">
        <xsl:value-of select="$pagemeta/dri:metadata[@element='request'][@qualifier='scheme']"/>
        <xsl:text>://</xsl:text>
        <xsl:value-of select="$pagemeta/dri:metadata[@element='request'][@qualifier='serverName']"/>
        <xsl:value-of select="$pagemeta/dri:metadata[@element='contextPath']"/>
        <xsl:text>/</xsl:text>
    </xsl:variable>

    <xsl:variable name="AUTH" select="/dri:document/dri:meta/dri:userMeta/@authenticated"/>
    <xsl:variable name="HANDLE" select="/dri:document/dri:meta/dri:pageMeta/dri:metadata[@element='request'][@qualifier='URI']"/>
    <xsl:variable name="EXTMETSURL" select="concat('cocoon://metadata/',$HANDLE,'/mets.xml?rightsMDTypes=METSRIGHTS')"/>
    <xsl:variable name="EXTMETS" select="document($EXTMETSURL)"/>
    <xsl:variable name="FULLMODE" select="//dri:referenceSet[@id='aspect.artifactbrowser.ItemViewer.referenceSet.collection-viewer'][@type='detailView']"/>

    <xsl:variable name="SHOW_SCHOLAR" select="false()"/>
    <xsl:variable name="MICROTAG" select="$SCH_DEFAULT"/>

    <xsl:variable name="header-logo-link"/>
    <xsl:variable name="header-logo-link-lang"/>
    <xsl:variable name="header-logo"/>
    <xsl:variable name="header-logo-alt"/>

    <xsl:variable name="H_AUTHOR">Creator</xsl:variable>
    <xsl:variable name="H_EDITOR">Editor</xsl:variable>
    <xsl:variable name="H_ADVISOR">Advisor</xsl:variable>
    <xsl:variable name="H_CONTRIBUTOR">Contributor</xsl:variable>
    <xsl:variable name="DH_SUBJECT">Subject</xsl:variable>
    <xsl:variable name="H_SUBJECT"><xsl:value-of select="$DH_SUBJECT"/></xsl:variable>
    <xsl:variable name="DH_ABSTRACT">Abstract</xsl:variable>
    <xsl:variable name="H_ABSTRACT"><xsl:value-of select="$DH_ABSTRACT"/></xsl:variable>
    <xsl:variable name="H_CONTRIBOTHER">Other Contributor</xsl:variable>
    <xsl:variable name="H_TIME">Time Period</xsl:variable>
    <xsl:variable name="H_LOCATION">Location</xsl:variable>
    <xsl:variable name="H_PARTOF">Is Part Of</xsl:variable>

    <xsl:variable name="DFILTER_SUBJECT">/discover?filtertype=subject&amp;filter_relational_operator=equals&amp;filter=</xsl:variable>
    <xsl:variable name="FILTER_SUBJECT"><xsl:value-of select="$DFILTER_SUBJECT"/></xsl:variable>
    <xsl:variable name="FILTER_TITLE_SUBJECT">Find other items in DigitalGeorgetown with the same subject term</xsl:variable>
    
    <xsl:variable name="FILTER_TYPE">/discover?filtertype=type&amp;filter_relational_operator=equals&amp;filter=</xsl:variable>
    <xsl:variable name="FILTER_TITLE_TYPE">Find other items in DigitalGeorgetown with the same item type</xsl:variable>
    
    <xsl:variable name="FILTER_CREATOR"/>
    <xsl:variable name="FILTER_TITLE_CREATOR">Find other items in DigitalGeorgetown with the same creator</xsl:variable>

    <xsl:variable name="FILTER_GEO"/>
    <xsl:variable name="FILTER_TITLE_GEO"/>

    <xsl:variable name="FILTER_TIME"/>
    <xsl:variable name="FILTER_TITLE_TIME"/>

    <xsl:variable name="FILTER_PARTOF"/>
    <xsl:variable name="FILTER_TITLE_PARTOF"/>

    <xsl:variable name="DGHOME">http://www.library.georgetown.edu/digitalgeorgetown</xsl:variable>
    
    <xsl:key name="myancestor" match="/dri:document/dri:meta/dri:pageMeta/dri:trail/@target|/dri:document/dri:meta/dri:pageMeta/dri:metadata[@element='request'][@qualifier='URI']/text()" use="substring-after(.,'handle/')"/>


    <!-- GUCODE[[twb27: add root schema.org item type]]-->
    <xsl:template name="microtag-wrapper">
        <xsl:choose>
            <xsl:when test="$MICROTAG=''"/>
            <xsl:otherwise>
                <xsl:attribute name="itemscope"/>
                <xsl:attribute name="itemtype">
                    <xsl:value-of select="$MICROTAG"/>
                </xsl:attribute>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>

    <xsl:template name="microtag-special-summary">
        <xsl:choose>
            <xsl:when test="$MICROTAG=$SCH_VID">
                <xsl:apply-templates select="dim:field[@element='date'][@qualifier='accessioned']" mode="microtag-meta"/>
            </xsl:when>
        </xsl:choose>
    </xsl:template>
    
    <xsl:template match="dim:field" mode="microtag-meta">
        <xsl:variable name="itempropattr">
            <xsl:apply-templates select="." mode="microtag-prop"/>
        </xsl:variable>
        <xsl:if test="$itempropattr">
            <meta>
                <xsl:apply-templates select="." mode="microtag-prop"/>
                <xsl:attribute name="content">
                    <xsl:value-of select="."/>
                </xsl:attribute>
            </meta>
        </xsl:if>
    </xsl:template>
    
    <xsl:template match="dim:field" mode="microtag-type">
        <xsl:choose>
            <xsl:when test="$MICROTAG = ''"/>
            <xsl:when test="@element='creator' or (@element='contributor' and @qualifier='author')">
                <xsl:attribute name="itemscope"/>
                <xsl:attribute name="itemprop">author</xsl:attribute>
                <xsl:attribute name="itemtype">http://schema.org/Person</xsl:attribute>
            </xsl:when>
            <xsl:when test="@element='publisher'">
                <xsl:attribute name="itemscope"/>
                <xsl:attribute name="itemprop">publisher</xsl:attribute>
                <xsl:attribute name="itemtype">http://schema.org/Organization</xsl:attribute>
            </xsl:when>
            <xsl:when test="@element='contributor' and @qualifier='other'">
                <xsl:attribute name="itemscope"/>
                <xsl:attribute name="itemprop">contributor</xsl:attribute>
                <xsl:attribute name="itemtype">http://schema.org/Person</xsl:attribute>
            </xsl:when>
        </xsl:choose>
    </xsl:template>

    <xsl:template match="dim:field" mode="microtag-prop">
    <xsl:choose>
        <xsl:when test="$MICROTAG = ''"/>
        <xsl:when test="@element='title' and not(@qualifier)">
            <xsl:attribute name="itemprop">name headline</xsl:attribute>
        </xsl:when>
        <xsl:when test="@element='creator' or (@element='contributor' and @qualifier='author')">
            <xsl:attribute name="itemprop">name</xsl:attribute>
        </xsl:when>
        <xsl:when test="@element='contributor' and @qualifier='other'">
            <xsl:attribute name="itemprop">name</xsl:attribute>
        </xsl:when>
        <xsl:when test="@element='publisher'">
            <xsl:attribute name="itemprop">name</xsl:attribute>
        </xsl:when>
        <xsl:when test="@element='identifier' and @qualifier='uri'">
            <xsl:attribute name="itemprop">url</xsl:attribute>
        </xsl:when>
        <xsl:when test="@element='date' and @qualifier='created'">
            <xsl:attribute name="itemprop">dateCreated</xsl:attribute>
        </xsl:when>
        <xsl:when test="@element='date' and @qualifier='issued'">
            <xsl:attribute name="itemprop">datePublished</xsl:attribute>
        </xsl:when>
        <xsl:when test="@element='subject'">
            <xsl:attribute name="itemprop">about</xsl:attribute>
        </xsl:when>
        <xsl:when test="@element='description' and @qualifier='abstract'">
            <xsl:attribute name="itemprop">description</xsl:attribute>
        </xsl:when>
        <xsl:when test="@element='description' and not(@qualifier)">
            <xsl:attribute name="itemprop">description</xsl:attribute>
        </xsl:when>
        <xsl:when test="@element='relation' and @qualifier='isPartOf'">
            <xsl:attribute name="itemprop">isPartOf</xsl:attribute>
        </xsl:when>
        <xsl:when test="@element='relation' and @qualifier='ispartofseries'">
            <xsl:attribute name="itemprop">isPartOf</xsl:attribute>
        </xsl:when>
        <xsl:when test="@element='coverage' and @qualifier='spatial'">
            <xsl:attribute name="itemprop">contentLocation</xsl:attribute>
        </xsl:when>
        <xsl:when test="@element='description' and @qualifier='version'">
            <xsl:attribute name="itemprop">version</xsl:attribute>
        </xsl:when>
        <xsl:when test="@element='language'">
            <xsl:attribute name="itemprop">inLanguage</xsl:attribute>
        </xsl:when>
        <xsl:when test="@element='date' and @qualifier='accessioned' and $MICROTAG=$SCH_VID">
            <xsl:attribute name="itemprop">uploadDate</xsl:attribute>
        </xsl:when>
        <xsl:when test="@element='format' and @qualifier='extent' and $MICROTAG=$SCH_VID">
            <xsl:attribute name="itemprop">duration</xsl:attribute>
        </xsl:when>
        <xsl:when test="@element='identifier' and @qualifier='isbn' and $MICROTAG=$SCH_BOOK">
            <xsl:attribute name="itemprop">isbn</xsl:attribute>
        </xsl:when>
        <xsl:when test="@element='format' and @qualifier='medium' and $MICROTAG=$SCH_VISART">
            <xsl:attribute name="itemprop">artMedium</xsl:attribute>
        </xsl:when>
        <xsl:when test="@element='type' and $MICROTAG=$SCH_VISART">
            <xsl:attribute name="itemprop">artForm</xsl:attribute>
        </xsl:when>
    </xsl:choose>
    </xsl:template>
    
    <xsl:template match="dri:item[dri:xref[@target='/statistics']]"/>
</xsl:stylesheet>
