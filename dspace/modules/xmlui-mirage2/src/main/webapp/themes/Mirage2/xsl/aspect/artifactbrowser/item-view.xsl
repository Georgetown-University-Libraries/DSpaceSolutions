<!--

    The contents of this file are subject to the license and copyright
    detailed in the LICENSE and NOTICE files at the root of the source
    tree and available online at

    http://www.dspace.org/license/

-->

<!--
    Rendering specific to the item display page.

    Author: art.lowel at atmire.com
    Author: lieven.droogmans at atmire.com
    Author: ben at atmire.com
    Author: Alexey Maslov

-->

<xsl:stylesheet
    xmlns:i18n="http://apache.org/cocoon/i18n/2.1"
    xmlns:dri="http://di.tamu.edu/DRI/1.0/"
    xmlns:mets="http://www.loc.gov/METS/"
    xmlns:dim="http://www.dspace.org/xmlns/dspace/dim"
    xmlns:xlink="http://www.w3.org/TR/xlink/"
    xmlns:xsl="http://www.w3.org/1999/XSL/Transform" version="1.0"
    xmlns:atom="http://www.w3.org/2005/Atom"
    xmlns:ore="http://www.openarchives.org/ore/terms/"
    xmlns:oreatom="http://www.openarchives.org/ore/atom/"
    xmlns="http://www.w3.org/1999/xhtml"
    xmlns:xalan="http://xml.apache.org/xalan"
    xmlns:encoder="xalan://java.net.URLEncoder"
    xmlns:util="org.dspace.app.xmlui.utils.XSLUtils"
    xmlns:jstring="java.lang.String"
    xmlns:rights="http://cosimo.stanford.edu/sdr/metsrights/"
    xmlns:confman="org.dspace.core.ConfigurationManager"
    exclude-result-prefixes="xalan encoder i18n dri mets dim xlink xsl util jstring rights confman">

    <xsl:output indent="yes"/>

    <xsl:template name="itemSummaryView-DIM">
        <!-- Generate the info about the item from the metadata section -->
        <xsl:apply-templates select="./mets:dmdSec/mets:mdWrap[@OTHERMDTYPE='DIM']/mets:xmlData/dim:dim"
        mode="itemSummaryView-DIM"/>

        <xsl:copy-of select="$SFXLink" />

        <!-- Generate the Creative Commons license information from the file section (DSpace deposit license hidden by default)-->
        <xsl:if test="./mets:fileSec/mets:fileGrp[@USE='CC-LICENSE' or @USE='LICENSE']">
            <div class="license-info table">
                <p>
                    <i18n:text>xmlui.dri2xhtml.METS-1.0.license-text</i18n:text>
                </p>
                <ul class="list-unstyled">
                    <xsl:apply-templates select="./mets:fileSec/mets:fileGrp[@USE='CC-LICENSE' or @USE='LICENSE']" mode="simple"/>
                </ul>
            </div>
        </xsl:if>

    </xsl:template>

    <!-- An item rendered in the detailView pattern, the "full item record" view of a DSpace item in Manakin. -->
    <!-- GUCODE[[twb27:display bitstreams above metadata]] -->
    <xsl:template name="itemDetailView-DIM">
        <!-- GUCODE[[twb27:created new template mode to handle title]] -->
        <xsl:apply-templates select="mets:dmdSec/mets:mdWrap[@OTHERMDTYPE='DIM']/mets:xmlData/dim:dim"
                             mode="itemDetailView-DIM-title"/>
        
        <!-- GUCODE[[twb27: show special header items such as Sharestream at the top of the page]] -->
        <xsl:for-each select=".//dim:dim">
            <xsl:call-template name="summaryHeaderDetail"/>
        </xsl:for-each>
        <!-- GUCODE[[twb27: handle item files]] -->
        <xsl:apply-templates select="." mode="itemDetailView-DIM-Files"/>

        <!-- Output all of the metadata about the item from the metadata section -->
        <xsl:apply-templates select="mets:dmdSec/mets:mdWrap[@OTHERMDTYPE='DIM']/mets:xmlData/dim:dim"
                             mode="itemDetailView-DIM"/>
    </xsl:template>

    <!-- GUCODE[[twb27: break file specific logic into a template to handle custom GU logic]] -->
    <xsl:template match="mets:METS" mode="itemDetailView-DIM-Files">
        <xsl:variable name="orig" select="./mets:fileSec/mets:fileGrp[@USE='CONTENT' or @USE='ORIGINAL' or @USE='LICENSE']/mets:file[not(mets:FLocat[@xlink:label='Sharestream Auth Image' or @xlink:label='Sharestream Thumbnail' or @xlink:label='HIDE' or @xlink:label='HTML Finding Aid'])]"/>
        
        <!-- Generate the bitstream information from the file section -->
        <xsl:choose>
            <xsl:when test="$orig">
                <h3><i18n:text>xmlui.dri2xhtml.METS-1.0.item-files-head</i18n:text></h3>
                <div class="file-list">
                    <xsl:apply-templates select="./mets:fileSec/mets:fileGrp[@USE='CONTENT' or @USE='ORIGINAL' or @USE='LICENSE' or @USE='CC-LICENSE']">
                        <xsl:with-param name="context" select="."/>
                        <xsl:with-param name="primaryBitstream" select="./mets:structMap[@TYPE='LOGICAL']/mets:div[@TYPE='DSpace Item']/mets:fptr/@FILEID"/>
                    </xsl:apply-templates>
                </div>
            </xsl:when>
            <!-- Special case for handling ORE resource maps stored as DSpace bitstreams -->
            <xsl:when test="./mets:fileSec/mets:fileGrp[@USE='ORE']">
                <xsl:apply-templates select="./mets:fileSec/mets:fileGrp[@USE='ORE']" mode="itemDetailView-DIM" />
            </xsl:when>
            <xsl:otherwise> 
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>


    <xsl:template match="dim:dim" mode="itemSummaryView-DIM">
        <div class="item-summary-view-metadata">
            <xsl:call-template name="itemSummaryView-DIM-title"/>
            <xsl:call-template name="microtag-special-summary"/>
            
            <!--GUCODE[[twb27:Show Sharestream Player, Finding Aid Image, Markdown]]-->
            <!--GUCODE[[twb27:Show Bitstreams at the Top, Suppress if needed]]-->
            <xsl:call-template name="summaryHeader"/>
            <xsl:choose>
                <xsl:when test="//mets:fileSec/mets:fileGrp[@USE='METADATA']/mets:file/mets:FLocat[@xlink:label='IIIF Manifest']"/>
                <xsl:when test="//mets:fileSec/mets:fileGrp[mets:file[mets:FLocat[@LOCTYPE='URL'][@xlink:label='HTML Finding Aid']]]"/>
                <xsl:when test="dim:field[@element='relation' and @qualifier='uri'][starts-with(.,'IIIF:')]"/>
                <xsl:when test="dim:field[@element='relation' and @qualifier='uri'][starts-with(.,'IIIF-ND:')]"/>
                <xsl:otherwise>
                    <xsl:call-template name="itemSummaryView-DIM-Files"/>
                </xsl:otherwise>
           </xsl:choose>
            <div class="row">
                <div class="col-sm-12">
                    <xsl:call-template name="itemSummaryView-DIM-authors"/>
                    <!-- GUCODE[[twb27]] -->
                    <xsl:call-template name="itemSummaryView-DIM-editors"/>
                    <xsl:call-template name="itemSummaryView-DIM-advisors"/>
                    <xsl:call-template name="itemSummaryView-DIM-contributors"/>
                    <!-- GUCODE[[twb27: custom header fields]] -->
                    <xsl:call-template name="itemSummaryView-DIM-orcid"/>
                    <xsl:call-template name="itemSummaryView-DIM-bibCite"/>
                </div>
            </div>
            <div class="row">
                <div class="col-sm-12">
                    <!--GUCODE[[twb27:Customize Summary View]]-->
                    <xsl:call-template name="itemSummaryView-DIM-abstract"/>
                    <xsl:call-template name="itemSummaryView-DIM-descript"/>
                    <xsl:call-template name="itemSummaryView-DIM-URI"/>
                    <xsl:call-template name="itemSummaryView-DIM-URI-EXT"/>
                    <xsl:call-template name="itemSummaryView-DIM-date"/>
                    <xsl:call-template name="itemSummaryView-DIM-rights"/>
                    <xsl:call-template name="itemSummaryView-DIM-subject"/>
                    <xsl:call-template name="itemSummaryView-DIM-timepd"/>
                    <xsl:call-template name="itemSummaryView-DIM-type"/>
                    <xsl:call-template name="itemSummaryView-DIM-locat"/>
                    <xsl:call-template name="itemSummaryView-DIM-liftdate"/>
                    <xsl:call-template name="itemSummaryView-DIM-ispartof"/>
                    <xsl:call-template name="itemSummaryView-DIM-custom"/>
                </div>
            </div>

            <!-- GUCODE[[twb27: customize placement of summary/full link] -->
            <div class="row">
                <div class="col-sm-12">
                    <xsl:call-template name="itemSummaryView-collections"/>
                    <xsl:if test="$ds_item_view_toggle_url != ''">
                        <xsl:call-template name="itemSummaryView-show-full"/>
                    </xsl:if>
                </div>
            </div>
        </div>
    </xsl:template>

    <!-- GUCODE[[twb27: individual file hanlding]] -->
    <xsl:template name="itemSummaryView-DIM-Files">
        <xsl:variable name="orig" select="//mets:fileSec/mets:fileGrp[@USE='CONTENT' or @USE='ORIGINAL' or @USE='LICENSE']/mets:file[not(mets:FLocat[@xlink:label='Sharestream Auth Image' or @xlink:label='Sharestream Thumbnail' or @xlink:label='HIDE' or @xlink:label='HTML Finding Aid'])]"/>
        <xsl:if test="$orig">
        <div class="row">
            <div class="col-sm-12">
                <div class="row">
                    <div class="col-xs-12 col-sm-12 col-md-4">
                        <xsl:call-template name="itemSummaryView-DIM-thumbnail"/>
                    </div>
                    <div class="col-xs-12 col-sm-12 col-md-8">
                        <xsl:call-template name="itemSummaryView-DIM-file-section"/>
                    </div>
                </div>
            </div>
        </div>
        <hr/>
        </xsl:if>
    </xsl:template>

    <!-- GUCODE[[twb27: add microtag header]] -->
    <xsl:template name="itemSummaryView-DIM-title">
        <xsl:choose>
            <xsl:when test="count(dim:field[@element='title'][not(@qualifier)]) &gt; 1">
                <h2 class="page-header first-page-header">
                    <xsl:apply-templates select="dim:field[@element='title'][not(@qualifier)][1]" mode="microtag-prop"/>
                    <xsl:value-of select="dim:field[@element='title'][not(@qualifier)][1]/node()"/>
                </h2>
                <div class="simple-item-view-other">
                    <p class="lead">
                        <xsl:for-each select="dim:field[@element='title'][not(@qualifier)]">
                            <xsl:if test="not(position() = 1)">
                                <xsl:value-of select="./node()"/>
                                <xsl:if test="count(following-sibling::dim:field[@element='title'][not(@qualifier)]) != 0">
                                    <xsl:text>; </xsl:text>
                                    <br/>
                                </xsl:if>
                            </xsl:if>

                        </xsl:for-each>
                    </p>
                </div>
            </xsl:when>
            <xsl:when test="count(dim:field[@element='title'][not(@qualifier)]) = 1">
                <h2 class="page-header first-page-header">
                     <xsl:apply-templates select="dim:field[@element='title'][not(@qualifier)]" mode="microtag-prop"/>
                    <xsl:value-of select="dim:field[@element='title'][not(@qualifier)][1]/node()"/>
                </h2>
            </xsl:when>
            <xsl:otherwise>
                <h2 class="page-header first-page-header">
                    <xsl:if test="not($MICROTAG='')">
                        <xsl:attribute name="itemprop">name headline</xsl:attribute>
                    </xsl:if>
                    <i18n:text>xmlui.dri2xhtml.METS-1.0.no-title</i18n:text>
                </h2>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>

    <!-- GUCODE[[twb27:suppress thumbnails for special bitstream types]] -->
    <xsl:template name="itemSummaryView-DIM-thumbnail">
        <div class="thumbnail">
            <xsl:variable name="thumb" select="//mets:fileGrp[@USE='THUMBNAIL']/mets:file[@GROUPID][1]"/>
            <xsl:variable name="thumbgid" select="$thumb/@GROUPID"/>
            <xsl:variable name="orig" select="//mets:fileGrp[@USE='CONTENT']/mets:file[@GROUPID=$thumbgid]"/>
            <xsl:choose>
                <xsl:when test="$orig[mets:FLocat[@xlink:label='HTML Finding Aid']]"/>
                <xsl:when test="$orig[mets:FLocat[@xlink:label='HIDE']]"/>
                <xsl:when test="$orig[mets:FLocat[@xlink:label='Sharestream Auth Image']]"/>
                <xsl:when test="$orig[mets:FLocat[@xlink:label='Sharestream Thumbnail']]"/>
                <xsl:when test="not($orig)"/>
                <xsl:when test="//mets:fileSec/mets:fileGrp[@USE='THUMBNAIL']">
                    <xsl:variable name="src">
                        <xsl:choose>
                            <xsl:when test="$orig">
                                <xsl:value-of
                                        select="$thumb/mets:FLocat[@LOCTYPE='URL']/@xlink:href"/>
                            </xsl:when>
                            <xsl:otherwise>
                                <xsl:value-of
                                        select="//mets:fileSec/mets:fileGrp[@USE='THUMBNAIL']/mets:file/mets:FLocat[@LOCTYPE='URL']/@xlink:href"/>
                            </xsl:otherwise>
                        </xsl:choose>
                    </xsl:variable>
                    <xsl:call-template name="gu-thumbnail-still">
                        <xsl:with-param name="thumb" select="$thumb"/>
                        <xsl:with-param name="src" select="$src"/>
                    </xsl:call-template>
                </xsl:when>
                <xsl:otherwise>
                    <img alt="Thumbnail">
                        <xsl:attribute name="data-src">
                            <xsl:text>holder.js/100%x</xsl:text>
                            <xsl:value-of select="$thumbnail.maxheight"/>
                            <xsl:text>/text:No Thumbnail</xsl:text>
                        </xsl:attribute>
                    </img>
                </xsl:otherwise>
            </xsl:choose>
        </div>
    </xsl:template>

    <!--GUCODE[[twb27:Custom Summary Fields]]-->
    <xsl:template name="itemSummaryView-DIM-abstract">
        <xsl:if test="dim:field[@element='description' and @qualifier='abstract']">
            <div class="simple-item-view-description item-page-field-wrapper table">
                <h5><xsl:value-of select="$H_ABSTRACT"/></h5>
                <div>
                    <xsl:for-each select="dim:field[@element='description' and @qualifier='abstract']">
                        <xsl:choose>
                            <xsl:when test="node()">
                                <span>
                                    <xsl:apply-templates select="." mode="microtag-prop"/>
                                    <xsl:apply-templates select="node()" mode="urltext"/>
                                </span>
                            </xsl:when>
                            <xsl:otherwise>
                                <xsl:text>&#160;</xsl:text>
                            </xsl:otherwise>
                        </xsl:choose>
                        <xsl:if test="count(following-sibling::dim:field[@element='description' and @qualifier='abstract']) != 0">
                            <div class="spacer">&#160;</div>
                        </xsl:if>
                    </xsl:for-each>
                    <xsl:if test="count(dim:field[@element='description' and @qualifier='abstract']) &gt; 1">
                        <div class="spacer">&#160;</div>
                    </xsl:if>
                </div>
            </div>
        </xsl:if>
    </xsl:template>

    <xsl:template name="itemSummaryView-DIM-liftdate">
        <xsl:if test="dim:field[@element='embargo' and @qualifier='lift-date']">
            <div class="simple-item-view-description item-page-field-wrapper table">
                <h5>Embargo Lift Date</h5>
                <div>
                    <xsl:for-each select="dim:field[@element='embargo' and @qualifier='lift-date']">
                        <xsl:choose>
                            <xsl:when test="node()">
                                <xsl:copy-of select="node()"/>
                            </xsl:when>
                            <xsl:otherwise>
                                <xsl:text>&#160;</xsl:text>
                            </xsl:otherwise>
                        </xsl:choose>
                        <xsl:if test="count(following-sibling::dim:field[@element='embargo' and @qualifier='lift-date']) != 0">
                            <div class="spacer">&#160;</div>
                        </xsl:if>
                    </xsl:for-each>
                    <xsl:if test="count(dim:field[@element='embargo' and @qualifier='lift-date']) &gt; 1">
                        <div class="spacer">&#160;</div>
                    </xsl:if>
                </div>
            </div>
        </xsl:if>
    </xsl:template>

    <xsl:template name="itemSummaryView-DIM-locat">
        <xsl:if test="dim:field[@element='coverage' and @qualifier='spatial']">
            <div class="simple-item-view-description item-page-field-wrapper table">
                <h5><xsl:value-of select="$H_LOCATION"/></h5>
                <div>
                    <xsl:for-each select="dim:field[@element='coverage' and @qualifier='spatial']">
                        <xsl:choose>
                            <xsl:when test="node()">
                                <xsl:call-template name="gu-linkable-term">
                                    <xsl:with-param name="filter" select="$FILTER_GEO"/>
                                    <xsl:with-param name="class" select="'gu-geo-link'"/>
                                    <xsl:with-param name="title" select="$FILTER_TITLE_GEO"/>
                                </xsl:call-template>
                            </xsl:when>
                            <xsl:otherwise>
                                <xsl:text>&#160;</xsl:text>
                            </xsl:otherwise>
                        </xsl:choose>
                        <xsl:if test="count(following-sibling::dim:field[@element='coverage' and @qualifier='spatial']) != 0">
                            <xsl:text>; </xsl:text>
                        </xsl:if>
                    </xsl:for-each>
                    <xsl:if test="count(dim:field[@element='coverage' and @qualifier='spatial']) &gt; 1">
                        <xsl:text>; </xsl:text>
                    </xsl:if>
                </div>
            </div>
        </xsl:if>
    </xsl:template>

    <xsl:template name="itemSummaryView-DIM-timepd">
        <xsl:if test="dim:field[@element='coverage' and @qualifier='temporal']">
            <div class="simple-item-view-description item-page-field-wrapper table">
                <h5><xsl:value-of select="$H_TIME"/></h5>
                <div>
                    <xsl:for-each select="dim:field[@element='coverage' and @qualifier='temporal']">
                        <xsl:choose>
                            <xsl:when test="node()">
                                <xsl:call-template name="gu-linkable-term">
                                    <xsl:with-param name="filter" select="$FILTER_TIME"/>
                                    <xsl:with-param name="class" select="'gu-timepd-link'"/>
                                    <xsl:with-param name="title" select="$FILTER_TITLE_TIME"/>
                                </xsl:call-template>
                            </xsl:when>
                            <xsl:otherwise>
                                <xsl:text>&#160;</xsl:text>
                            </xsl:otherwise>
                        </xsl:choose>
                        <xsl:if test="count(following-sibling::dim:field[@element='coverage' and @qualifier='temporal']) != 0">
                            <xsl:text>; </xsl:text>
                        </xsl:if>
                    </xsl:for-each>
                    <xsl:if test="count(dim:field[@element='coverage' and @qualifier='temporal']) &gt; 1">
                        <xsl:text>; </xsl:text>
                    </xsl:if>
                </div>
            </div>
        </xsl:if>
    </xsl:template>

    <xsl:template name="itemSummaryView-DIM-ispartof">
        <xsl:if test="dim:field[@element='relation' and @qualifier='isPartOf']">
            <div class="simple-item-view-description item-page-field-wrapper table">
                <h5><xsl:value-of select="$H_PARTOF"/></h5>
                <div>
                    <xsl:for-each select="dim:field[@element='relation' and @qualifier='isPartOf']">
                        <xsl:choose>
                            <xsl:when test="node()">
                                <xsl:call-template name="gu-linkable-term">
                                    <xsl:with-param name="filter" select="$FILTER_PARTOF"/>
                                    <xsl:with-param name="class" select="'gu-partof-link'"/>
                                    <xsl:with-param name="title" select="$FILTER_TITLE_PARTOF"/>
                                </xsl:call-template>
                            </xsl:when>
                            <xsl:otherwise>
                                <xsl:text>&#160;</xsl:text>
                            </xsl:otherwise>
                        </xsl:choose>
                        <xsl:if test="count(following-sibling::dim:field[@element='relation' and @qualifier='isPartOf']) != 0">
                            <xsl:text>; </xsl:text>
                        </xsl:if>
                    </xsl:for-each>
                    <xsl:if test="count(dim:field[@element='relation' and @qualifier='isPartOf']) &gt; 1">
                        <xsl:text>; </xsl:text>
                    </xsl:if>
                </div>
            </div>
        </xsl:if>
    </xsl:template>

    <xsl:template name="itemSummaryView-DIM-rights">
        <xsl:if test="dim:field[@element='rights']">
            <div class="simple-item-view-description item-page-field-wrapper table">
                <h5>Rights</h5>
                <div>
                    <xsl:for-each select="dim:field[@element='rights']">
                        <xsl:choose>
                            <xsl:when test="node()">
                                <xsl:copy-of select="node()"/>
                            </xsl:when>
                            <xsl:otherwise>
                                <xsl:text>&#160;</xsl:text>
                            </xsl:otherwise>
                        </xsl:choose>
                        <xsl:if test="count(following-sibling::dim:field[@element='rights']) != 0">
                            <div class="spacer">&#160;</div>
                        </xsl:if>
                    </xsl:for-each>
                    <xsl:if test="count(dim:field[@element='rights']) &gt; 1">
                        <div class="spacer">&#160;</div>
                    </xsl:if>
                </div>
            </div>
        </xsl:if>
    </xsl:template>
    
    <xsl:template name="gu-linkable-term">
      <xsl:param name="filter"/>
      <xsl:param name="class"/>
      <xsl:param name="title"/>
      <xsl:choose>
        <xsl:when test="string-length($filter) &gt; 0">
          <a class="{$class}" href="{concat($filter,.)}" title="{$title}">
            <span>
              <xsl:apply-templates select="." mode="microtag-prop"/>
              <xsl:apply-templates select="text()"/>
            </span>
          </a>
        </xsl:when>
        <xsl:otherwise>
          <span>
            <xsl:apply-templates select="." mode="microtag-prop"/>
            <xsl:apply-templates select="text()"/>
          </span>
        </xsl:otherwise>
      </xsl:choose>
    </xsl:template>

    <xsl:template name="itemSummaryView-DIM-subject">
        <xsl:if test="dim:field[@element='subject']">
            <div class="simple-item-view-description item-page-field-wrapper table">
                <h5><xsl:value-of select="$H_SUBJECT"/></h5>
                <div>
                    <xsl:for-each select="dim:field[@element='subject']">
                        <xsl:choose>
                            <xsl:when test="node()">
                                <xsl:call-template name="gu-linkable-term">
                                    <xsl:with-param name="filter" select="$FILTER_SUBJECT"/>
                                    <xsl:with-param name="class" select="'gu-subject-link'"/>
                                    <xsl:with-param name="title" select="$FILTER_TITLE_SUBJECT"/>
                                </xsl:call-template>
                            </xsl:when>
                            <xsl:otherwise>
                                <xsl:text>&#160;</xsl:text>
                            </xsl:otherwise>
                        </xsl:choose>
                        <xsl:if test="count(following-sibling::dim:field[@element='subject']) != 0">
                            <xsl:text>; </xsl:text>
                        </xsl:if>
                    </xsl:for-each>
                    <xsl:if test="count(dim:field[@element='subject']) &gt; 1">
                        <xsl:text>; </xsl:text>
                    </xsl:if>
                </div>
            </div>
        </xsl:if>
    </xsl:template>

    <xsl:template name="itemSummaryView-DIM-type">
        <xsl:if test="dim:field[@element='type']">
            <div class="simple-item-view-description item-page-field-wrapper table">
                <h5>Type</h5>
                <div>
                    <xsl:for-each select="dim:field[@element='type']">
                        <xsl:choose>
                            <xsl:when test="node()">
                                <xsl:call-template name="gu-linkable-term">
                                    <xsl:with-param name="filter" select="$FILTER_TYPE"/>
                                    <xsl:with-param name="class" select="'gu-type-link'"/>
                                    <xsl:with-param name="title" select="$FILTER_TITLE_TYPE"/>
                                </xsl:call-template>
                            </xsl:when>
                            <xsl:otherwise>
                                <xsl:text>&#160;</xsl:text>
                            </xsl:otherwise>
                        </xsl:choose>
                        <xsl:if test="count(following-sibling::dim:field[@element='type']) != 0">
                            <xsl:text>; </xsl:text>
                        </xsl:if>
                    </xsl:for-each>
                    <xsl:if test="count(dim:field[@element='type']) &gt; 1">
                        <xsl:text>; </xsl:text>
                    </xsl:if>
                </div>
            </div>
        </xsl:if>
    </xsl:template>

    <xsl:template name="itemSummaryView-DIM-bibCite">
        <xsl:if test="dim:field[@element='identifier' and @qualifier='bibliographicCitation']">
            <div class="simple-item-view-description item-page-field-wrapper table">
                <h5 >Bibliographic Citation</h5>
                <div>
                    <xsl:for-each select="dim:field[@element='identifier' and @qualifier='bibliographicCitation']">
                        <xsl:choose>
                            <xsl:when test="node()">
                                <xsl:apply-templates select="text()" mode="urltext"/>
                            </xsl:when>
                            <xsl:otherwise>
                                <xsl:text>&#160;</xsl:text>
                            </xsl:otherwise>
                        </xsl:choose>
                        <xsl:if test="count(following-sibling::dim:field[@element='identifier' and @qualifier='bibliographicCitation']) != 0">
                            <div class="spacer">&#160;</div>
                        </xsl:if>
                    </xsl:for-each>
                    <xsl:if test="count(dim:field[@element='identifier' and @qualifier='bibliographicCitation']) &gt; 1">
                        <div class="spacer">&#160;</div>
                    </xsl:if>
                </div>
            </div>
        </xsl:if>
    </xsl:template>

    <!-- GUCODE[[twb27:handle description fields with Markdown]] -->
    <xsl:template name="itemSummaryView-DIM-descript">
        <xsl:if test="dim:field[@element='description' and not(@qualifier)][not(starts-with(.,'[MD]'))]">
            <div class="simple-item-view-description item-page-field-wrapper table">
                <h5>Description</h5>
                <div>
                    <xsl:for-each select="dim:field[@element='description' and not(@qualifier)][not(starts-with(.,'[MD]'))]">
                        <xsl:choose>
                            <xsl:when test="node()">
                                <span>
                                    <xsl:apply-templates select="." mode="microtag-prop"/>
                                    <xsl:apply-templates select="node()" mode="urltext"/>
                                </span>
                            </xsl:when>
                            <xsl:otherwise>
                                <xsl:text>&#160;</xsl:text>
                            </xsl:otherwise>
                        </xsl:choose>
                        <xsl:if test="count(following-sibling::dim:field[@element='description' and not(@qualifier)]) != 0">
                            <div class="spacer">&#160;</div>
                        </xsl:if>
                    </xsl:for-each>
                    <xsl:if test="count(dim:field[@element='description' and not(@qualifier)]) &gt; 1">
                        <div class="spacer">&#160;</div>
                    </xsl:if>
                </div>
            </div>
        </xsl:if>
    </xsl:template>



    <xsl:template name="itemSummaryView-DIM-authors">
        <xsl:variable name="allContributors" select="dim:field[@element='contributor' and descendant::text()]"/>
        <xsl:variable name="creators" select="dim:field[@element='creator' and descendant::text()]"/>
        <xsl:variable name="authors" select="$allContributors[@qualifier='author']"/>
        <div class="simple-item-view-authors item-page-field-wrapper table">
            <xsl:choose>
                <xsl:when test="$authors|$creators">
                    <h5><xsl:value-of select="$H_AUTHOR"/></h5>
                    <xsl:for-each select="$authors|$creators">
                        <xsl:call-template name="itemSummaryView-DIM-authors-entry" />
                    </xsl:for-each>
                </xsl:when>
                <xsl:when test="$allContributors"/>
                <xsl:otherwise>
                    <h5><xsl:value-of select="$H_AUTHOR"/></h5>
                    <i18n:text>xmlui.dri2xhtml.METS-1.0.no-author</i18n:text>
                </xsl:otherwise>
            </xsl:choose>
        </div>
    </xsl:template>

    <xsl:template name="itemSummaryView-DIM-editors">
        <xsl:variable name="allContributors" select="dim:field[@element='contributor' and descendant::text()]"/>
        <xsl:variable name="editors" select="$allContributors[@qualifier='editor']"/>
        <xsl:if test="$editors">
            <div class="simple-item-view-editors item-page-field-wrapper table">
                <h5><xsl:value-of select="$H_EDITOR"/></h5>
                <xsl:for-each select="$editors">
                    <xsl:call-template name="itemSummaryView-DIM-authors-entry" />
                </xsl:for-each>
            </div>
        </xsl:if>
    </xsl:template>

    <xsl:template name="itemSummaryView-DIM-advisors">
        <xsl:variable name="allContributors" select="dim:field[@element='contributor' and descendant::text()]"/>
        <xsl:variable name="advisors" select="$allContributors[@qualifier='advisor']"/>
        <xsl:if test="$advisors">
            <div class="simple-item-view-editors item-page-field-wrapper table">
                <h5><xsl:value-of select="$H_ADVISOR"/></h5>
                <xsl:for-each select="$advisors">
                    <xsl:call-template name="itemSummaryView-DIM-authors-entry" />
                </xsl:for-each>
            </div>
        </xsl:if>
    </xsl:template>

    <xsl:template name="itemSummaryView-DIM-contributors">
        <xsl:variable name="allContributors" select="dim:field[@element='contributor' and descendant::text()]"/>
        <xsl:variable name="genContributors" select="$allContributors[not(@qualifier='author' or @qualifier='advisor' or @qualifier='editor')]"/>
        <xsl:if test="$genContributors">
            <div class="simple-item-view-contributors item-page-field-wrapper table">
                <h5><xsl:value-of select="$H_CONTRIBUTOR"/></h5>
                <xsl:for-each select="$genContributors">
                    <xsl:call-template name="itemSummaryView-DIM-authors-entry" />
                </xsl:for-each>
            </div>
        </xsl:if>
    </xsl:template>



    <!-- GUCODE[[twb27: add microtags for authors]] -->
    <xsl:template name="itemSummaryView-DIM-authors-entry">
        <div>
            <xsl:apply-templates select="." mode="microtag-type"/>
            <xsl:if test="@authority">
                <xsl:attribute name="class"><xsl:text>ds-dc_contributor_author-authority</xsl:text></xsl:attribute>
            </xsl:if>
            <xsl:call-template name="gu-linkable-term">
                <xsl:with-param name="filter" select="$FILTER_CREATOR"/>
                <xsl:with-param name="class" select="'gu-creator-link'"/>
                <xsl:with-param name="title" select="$FILTER_TITLE_CREATOR"/>
            </xsl:call-template>
        </div>
    </xsl:template>

    <!-- GUCODE[[twb27: placeholder templates to be overridden by theme]] -->
    <xsl:template name="itemSummaryView-DIM-custom"/>

    <!-- GUCODE[[twb27: orcid handling]] -->
    <xsl:template name="itemSummaryView-DIM-orcid">
        <xsl:if test="dim:field[@element='identifier' and @qualifier='orcid' and descendant::text()]">
            <div class="simple-item-view-uri item-page-field-wrapper table">
                <h5>ORCID</h5>
                <span>
                    <xsl:for-each select="dim:field[@element='identifier' and @qualifier='orcid']">
                        <a href="{concat('http://orcid.org/',.)}">
                            <xsl:value-of select="text()"/>
                        </a>
                        <xsl:if test="count(following-sibling::dim:field[@element='identifier' and @qualifier='orcid']) != 0">
                            <br/>
                        </xsl:if>
                    </xsl:for-each>
                </span>
            </div>
        </xsl:if>
    </xsl:template>


    <!-- GUCODE[[twb27: add microtags for uri]] -->
    <xsl:template name="itemSummaryView-DIM-URI">
        <xsl:if test="dim:field[@element='identifier' and @qualifier='uri' and descendant::text()]">
            <div class="simple-item-view-uri item-page-field-wrapper table">
                <h5><i18n:text>xmlui.dri2xhtml.METS-1.0.item-uri</i18n:text></h5>
                <span>
                    <xsl:for-each select="dim:field[@element='identifier' and @qualifier='uri']">
                        <span>
                            <xsl:apply-templates select="." mode="microtag-prop"/>
                            <xsl:apply-templates select="./node()" mode="urltext"/>
                        </span>
                        <xsl:if test="count(following-sibling::dim:field[@element='identifier' and @qualifier='uri']) != 0">
                            <br/>
                        </xsl:if>
                    </xsl:for-each>
                </span>
            </div>
        </xsl:if>
    </xsl:template>

    <xsl:template name="itemSummaryView-DIM-URI-EXT">
        <xsl:if test="dim:field[@element='description' and @qualifier='uri' and descendant::text()]">
            <div class="simple-item-view-uri item-page-field-wrapper table">
                <h5>External Link</h5>
                <span>
                    <xsl:for-each select="dim:field[@element='description' and @qualifier='uri']">
                        <span>
                            <xsl:apply-templates select="./node()" mode="urltext"/>
                        </span>
                        <xsl:if test="count(following-sibling::dim:field[@element='description' and @qualifier='uri']) != 0">
                            <br/>
                        </xsl:if>
                    </xsl:for-each>
                </span>
            </div>
        </xsl:if>
    </xsl:template>


    <!--GUCODE[[twb27:Make Date Create Primary]]-->
    <xsl:template name="itemSummaryView-DIM-date">
        <xsl:if test="dim:field[@element='date' and @qualifier='created' and descendant::text()]">
            <div class="simple-item-view-date word-break item-page-field-wrapper table">
                <h5>
                    <i18n:text>xmlui.dri2xhtml.METS-1.0.item-date</i18n:text>
                </h5>
                <xsl:for-each select="dim:field[@element='date' and @qualifier='created']">
                    <span>
                        <xsl:apply-templates select="." mode="microtag-prop"/>
                        <xsl:copy-of select="substring(./node(),1,10)"/>
                    </span>
                    <xsl:if test="count(following-sibling::dim:field[@element='date' and @qualifier='created']) != 0">
                        <br/>
                    </xsl:if>
                </xsl:for-each>
            </div>
        </xsl:if>
    </xsl:template>

    <xsl:template name="itemSummaryView-show-full">
        <div class="simple-item-view-show-full item-page-field-wrapper table">
            <h5>
                <i18n:text>xmlui.mirage2.itemSummaryView.MetaData</i18n:text>
            </h5>
            <a>
                <xsl:attribute name="href"><xsl:value-of select="$ds_item_view_toggle_url"/></xsl:attribute>
                <i18n:text>xmlui.ArtifactBrowser.ItemViewer.show_full</i18n:text>
            </a>
        </div>
    </xsl:template>

    <xsl:template name="itemSummaryView-collections">
        <xsl:if test="$document//dri:referenceSet[@id='aspect.artifactbrowser.ItemViewer.referenceSet.collection-viewer']">
            <div class="simple-item-view-collections item-page-field-wrapper table">
                <h5>
                    <i18n:text>xmlui.mirage2.itemSummaryView.Collections</i18n:text>
                </h5>
                <xsl:apply-templates select="$document//dri:referenceSet[@id='aspect.artifactbrowser.ItemViewer.referenceSet.collection-viewer']/dri:reference"/>
            </div>
        </xsl:if>
    </xsl:template>

    <!-- GUCODE[[twb27:suppress file listing for special bitstream types]] -->
    <xsl:template name="itemSummaryView-DIM-file-section">
        <xsl:variable name="orig" select="//mets:fileSec/mets:fileGrp[@USE='CONTENT' or @USE='ORIGINAL' or @USE='LICENSE']/mets:file"/>
        <xsl:variable name="origFiltered" select="$orig[not(mets:FLocat[@LOCTYPE='URL'][@xlink:label='Sharestream Auth Image']) and not(mets:FLocat[@LOCTYPE='URL'][@xlink:label='Sharestream Thumbnail']) and not(mets:FLocat[@LOCTYPE='URL'][@xlink:label='HIDE']) and not(mets:FLocat[@LOCTYPE='URL'][@xlink:label='HTML Finding Aid'])]"/>
        <xsl:choose>
            <xsl:when test="$origFiltered">
                <div class="item-page-field-wrapper table word-break">
                    <h5>
                        <i18n:text>xmlui.dri2xhtml.METS-1.0.item-files-viewOpen</i18n:text>
                    </h5>

                    <xsl:variable name="label-1">
                            <xsl:choose>
                                <xsl:when test="confman:getProperty('mirage2.item-view.bitstream.href.label.1')">
                                    <xsl:value-of select="confman:getProperty('mirage2.item-view.bitstream.href.label.1')"/>
                                </xsl:when>
                                <xsl:otherwise>
                                    <xsl:text>label</xsl:text>
                                </xsl:otherwise>
                            </xsl:choose>
                    </xsl:variable>

                    <xsl:variable name="label-2">
                            <xsl:choose>
                                <xsl:when test="confman:getProperty('mirage2.item-view.bitstream.href.label.2')">
                                    <xsl:value-of select="confman:getProperty('mirage2.item-view.bitstream.href.label.2')"/>
                                </xsl:when>
                                <xsl:otherwise>
                                    <xsl:text>title</xsl:text>
                                </xsl:otherwise>
                            </xsl:choose>
                    </xsl:variable>

                    <xsl:for-each select="$origFiltered">
                        <xsl:call-template name="itemSummaryView-DIM-file-section-entry">
                            <xsl:with-param name="href" select="mets:FLocat[@LOCTYPE='URL']/@xlink:href" />
                            <xsl:with-param name="mimetype" select="@MIMETYPE" />
                            <xsl:with-param name="label-1" select="$label-1" />
                            <xsl:with-param name="label-2" select="$label-2" />
                            <xsl:with-param name="title" select="mets:FLocat[@LOCTYPE='URL']/@xlink:title" />
                            <xsl:with-param name="label" select="mets:FLocat[@LOCTYPE='URL']/@xlink:label" />
                            <xsl:with-param name="size" select="@SIZE" />
                        </xsl:call-template>
                    </xsl:for-each>
                </div>
            </xsl:when>
            <!-- Special case for handling ORE resource maps stored as DSpace bitstreams -->
            <xsl:when test="//mets:fileSec/mets:fileGrp[@USE='ORE']">
                <xsl:apply-templates select="//mets:fileSec/mets:fileGrp[@USE='ORE']" mode="itemSummaryView-DIM" />
            </xsl:when>
        </xsl:choose>
    </xsl:template>

    <!-- GUCODE[[twb27: add dynamic view links]] -->
    <xsl:template name="itemSummaryView-DIM-file-section-entry">
        <xsl:param name="href" />
        <xsl:param name="mimetype" />
        <xsl:param name="label-1" />
        <xsl:param name="label-2" />
        <xsl:param name="title" />
        <xsl:param name="label" />
        <xsl:param name="size" />
        
        <div class="gu-summary">
            <xsl:variable name="tagname">
                <xsl:choose>
                    <xsl:when test="mets:FLocat[@LOCTYPE='URL'][@xlink:label='Dynamic View']">span</xsl:when>
                    <xsl:otherwise>a</xsl:otherwise>
                </xsl:choose>
            </xsl:variable>
            <xsl:element name="{$tagname}">
                <xsl:attribute name="class">gu-itemview</xsl:attribute>
                <xsl:choose>
                    <xsl:when test="mets:FLocat[@LOCTYPE='URL'][@xlink:label='Dynamic View']">
                      <xsl:text>Bookview Available</xsl:text>
                    </xsl:when>
                    <xsl:otherwise>
                        <xsl:attribute name="href">
                            <xsl:value-of select="$href"/>
                        </xsl:attribute>
                        <xsl:call-template name="getFileIcon">
                            <xsl:with-param name="mimetype">
                                <xsl:value-of select="substring-before($mimetype,'/')"/>
                                <xsl:text>/</xsl:text>
                                <xsl:value-of select="substring-after($mimetype,'/')"/>
                            </xsl:with-param>
                        </xsl:call-template>
                        <xsl:if test="$tagname = 'a'">
                          <xsl:text>View/Open: </xsl:text>
                        </xsl:if>
                        <xsl:choose>
                            <xsl:when test="contains($label-1, 'label') and string-length($label)!=0">
                                <xsl:value-of select="$label"/>
                            </xsl:when>
                            <xsl:when test="contains($label-1, 'title') and string-length($title)!=0">
                                <xsl:value-of select="$title"/>
                            </xsl:when>
                            <xsl:when test="contains($label-2, 'label') and string-length($label)!=0">
                                <xsl:value-of select="$label"/>
                            </xsl:when>
                            <xsl:when test="contains($label-2, 'title') and string-length($title)!=0">
                                <xsl:value-of select="$title"/>
                            </xsl:when>
                            <xsl:otherwise>
                                <xsl:call-template name="getFileTypeDesc">
                                    <xsl:with-param name="mimetype">
                                        <xsl:value-of select="substring-before($mimetype,'/')"/>
                                        <xsl:text>/</xsl:text>
                                        <xsl:choose>
                                            <xsl:when test="contains($mimetype,';')">
                                                <xsl:value-of select="substring-before(substring-after($mimetype,'/'),';')"/>
                                            </xsl:when>
                                            <xsl:otherwise>
                                                <xsl:value-of select="substring-after($mimetype,'/')"/>
                                            </xsl:otherwise>
                                        </xsl:choose>
                                    </xsl:with-param>
                                </xsl:call-template>
                            </xsl:otherwise>
                        </xsl:choose>
                        <xsl:text> (</xsl:text>
                        <!-- GUCODE[[twb27: override casing for kb, mb, gb per Steve Fernie]] -->
                        <xsl:choose>
                            <xsl:when test="$size &lt; 1024">
                                <xsl:value-of select="$size"/>
                                <i18n:text>xmlui.dri2xhtml.METS-1.0.size-bytes</i18n:text>
                            </xsl:when>
                            <xsl:when test="$size &lt; 1024 * 1024">
                                <xsl:value-of select="substring(string($size div 1024),1,3)"/>
                                <i18n:text>xmlui.dri2xhtml.METS-1.0.size-kilobytes</i18n:text>
                            </xsl:when>
                            <xsl:when test="$size &lt; 1024 * 1024 * 1024">
                                <xsl:value-of select="substring(string($size div (1024 * 1024)),1,3)"/>
                                <i18n:text>xmlui.dri2xhtml.METS-1.0.size-megabytes</i18n:text>
                            </xsl:when>
                            <xsl:otherwise>
                                <xsl:value-of select="substring(string($size div (1024 * 1024 * 1024)),1,3)"/>
                                <i18n:text>xmlui.dri2xhtml.METS-1.0.size-gigabytes</i18n:text>
                            </xsl:otherwise>
                        </xsl:choose>
                        <xsl:text>)</xsl:text>
                    </xsl:otherwise>
                </xsl:choose>
            </xsl:element>
            <xsl:text> </xsl:text>
            <xsl:call-template name="gu-bookview-link"/>
        </div>
    </xsl:template>

    <xsl:template match="dim:dim" mode="itemDetailView-DIM-title">
        <xsl:call-template name="itemSummaryView-DIM-title"/>
    </xsl:template>

    <xsl:template match="dim:dim" mode="itemDetailView-DIM">
        <div class="ds-table-responsive">
            <table class="ds-includeSet-table detailtable table table-striped table-hover">
                <xsl:apply-templates mode="itemDetailView-DIM"/>
            </table>
        </div>

        <span class="Z3988">
            <xsl:attribute name="title">
                 <xsl:call-template name="renderCOinS"/>
            </xsl:attribute>
            &#xFEFF; <!-- non-breaking space to force separating the end tag -->
        </span>
        <xsl:copy-of select="$SFXLink" />
    </xsl:template>

    <!-- GUCODE[[twb27: embed microtags while drawing the detail view table]] -->
    <xsl:template match="dim:field" mode="itemDetailView-DIM">
            <tr>
                <xsl:attribute name="class">
                    <xsl:text>ds-table-row </xsl:text>
                    <xsl:if test="(position() div 2 mod 2 = 0)">even </xsl:if>
                    <xsl:if test="(position() div 2 mod 2 = 1)">odd </xsl:if>
                </xsl:attribute>
                <td class="label-cell">
                    <xsl:value-of select="./@mdschema"/>
                    <xsl:text>.</xsl:text>
                    <xsl:value-of select="./@element"/>
                    <xsl:if test="./@qualifier">
                        <xsl:text>.</xsl:text>
                        <xsl:value-of select="./@qualifier"/>
                    </xsl:if>
                </td>
                <td class="word-break">
                    <xsl:apply-templates select="." mode="microtag-type"/>
                    <span>
                        <xsl:apply-templates select="." mode="microtag-prop"/>
                        <xsl:if test="@element='description' and not(@qualifier) and starts-with(.,'[MD]')">
                            <xsl:attribute name="class">gu-markdown</xsl:attribute>
                        </xsl:if>
                        <xsl:copy-of select="./node()"/>
                     </span>
                </td>
                <td><xsl:value-of select="./@language"/></td>
            </tr>
    </xsl:template>

    <!-- don't render the item-view-toggle automatically in the summary view, only when it gets called -->
    <xsl:template match="dri:p[contains(@rend , 'item-view-toggle') and
        (preceding-sibling::dri:referenceSet[@type = 'summaryView'] or following-sibling::dri:referenceSet[@type = 'summaryView'])]">
    </xsl:template>

    <!-- don't render the head on the item view page -->
    <xsl:template match="dri:div[@n='item-view']/dri:head" priority="5">
    </xsl:template>

    <xsl:template match="mets:fileGrp[@USE='CONTENT']">
        <xsl:param name="context"/>
        <xsl:param name="primaryBitstream" select="-1"/>
        <xsl:choose>
            <!-- If one exists and it's of text/html MIME type, only display the primary bitstream -->
            <xsl:when test="mets:file[@ID=$primaryBitstream]/@MIMETYPE='text/html'">
                <xsl:apply-templates select="mets:file[@ID=$primaryBitstream]">
                    <xsl:with-param name="context" select="$context"/>
                </xsl:apply-templates>
            </xsl:when>
            <!-- Otherwise, iterate over and display all of them -->
            <xsl:otherwise>
                <xsl:apply-templates select="mets:file">
                    <!--Do not sort any more bitstream order can be changed-->
                    <xsl:with-param name="context" select="$context"/>
                </xsl:apply-templates>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>
    <!-- GUCODE[[twb27:suppress file listings for special bitstream types]] -->
    <xsl:template match="mets:fileGrp[@USE='CONTENT']/mets:file[mets:FLocat[@xlink:label='Sharestream Auth Image']]"/>
    <xsl:template match="mets:fileGrp[@USE='CONTENT']/mets:file[mets:FLocat[@xlink:label='Sharestream Thumbnail']]"/>
    <xsl:template match="mets:fileGrp[@USE='CONTENT']/mets:file[mets:FLocat[@xlink:label='HIDE']]"/>
    <xsl:template match="mets:fileGrp[@USE='CONTENT']/mets:file[mets:FLocat[@xlink:label='HTML Finding Aid']]"/>

    <xsl:template match="mets:fileGrp[@USE='LICENSE']">
        <xsl:param name="context"/>
        <xsl:param name="primaryBitstream" select="-1"/>
            <xsl:apply-templates select="mets:file">
                        <xsl:with-param name="context" select="$context"/>
            </xsl:apply-templates>
    </xsl:template>

    <!-- GUCODE[[twb27: call custom GU code before displaying a thumbnail (to check authentication)]] -->
    <xsl:template match="mets:file">
        <xsl:param name="context" select="."/>
        <div class="file-wrapper row">
            <div class="col-xs-6 col-sm-3">
                <xsl:choose>
                    <xsl:when test="../../mets:fileGrp[@USE='THUMBNAIL']/mets:file[@GROUPID=current()/@GROUPID]">
                        <xsl:call-template name="gu-thumbnail-link">
                            <xsl:with-param name="src" select="../../mets:fileGrp[@USE='THUMBNAIL']/mets:file[@GROUPID=current()/@GROUPID]/mets:FLocat[@LOCTYPE='URL']/@xlink:href"/>
                        </xsl:call-template>
                    </xsl:when>
                    <xsl:otherwise>
                        <div class="thumbnail">
                            <img alt="Thumbnail">
                                <xsl:attribute name="data-src">
                                    <xsl:text>holder.js/100%x</xsl:text>
                                    <xsl:value-of select="$thumbnail.maxheight"/>
                                    <xsl:text>/text:No Thumbnail</xsl:text>
                                </xsl:attribute>
                            </img>
                        </div>
                    </xsl:otherwise>
                </xsl:choose>
            </div>

            <div class="col-xs-6 col-sm-7">
                <dl class="file-metadata dl-horizontal">
                    <dt>
                        <i18n:text>xmlui.dri2xhtml.METS-1.0.item-files-name</i18n:text>
                        <xsl:text>:</xsl:text>
                    </dt>
                    <dd class="word-break">
                        <xsl:attribute name="title">
                            <xsl:value-of select="mets:FLocat[@LOCTYPE='URL']/@xlink:title"/>
                        </xsl:attribute>
                        <xsl:value-of select="util:shortenString(mets:FLocat[@LOCTYPE='URL']/@xlink:title, 30, 5)"/>
                    </dd>
                <!-- File size always comes in bytes and thus needs conversion -->
                    <dt>
                        <i18n:text>xmlui.dri2xhtml.METS-1.0.item-files-size</i18n:text>
                        <xsl:text>:</xsl:text>
                    </dt>
                    <dd class="word-break">
                        <xsl:choose>
                            <xsl:when test="@SIZE &lt; 1024">
                                <xsl:value-of select="@SIZE"/>
                                <i18n:text>xmlui.dri2xhtml.METS-1.0.size-bytes</i18n:text>
                            </xsl:when>
                            <xsl:when test="@SIZE &lt; 1024 * 1024">
                                <xsl:value-of select="substring(string(@SIZE div 1024),1,3)"/>
                                <i18n:text>xmlui.dri2xhtml.METS-1.0.size-kilobytes</i18n:text>
                            </xsl:when>
                            <xsl:when test="@SIZE &lt; 1024 * 1024 * 1024">
                                <xsl:value-of select="substring(string(@SIZE div (1024 * 1024)),1,3)"/>
                                <i18n:text>xmlui.dri2xhtml.METS-1.0.size-megabytes</i18n:text>
                            </xsl:when>
                            <xsl:otherwise>
                                <xsl:value-of select="substring(string(@SIZE div (1024 * 1024 * 1024)),1,5)"/>
                                <i18n:text>xmlui.dri2xhtml.METS-1.0.size-gigabytes</i18n:text>
                            </xsl:otherwise>
                        </xsl:choose>
                    </dd>
                <!-- Lookup File Type description in local messages.xml based on MIME Type.
         In the original DSpace, this would get resolved to an application via
         the Bitstream Registry, but we are constrained by the capabilities of METS
         and can't really pass that info through. -->
                    <dt>
                        <i18n:text>xmlui.dri2xhtml.METS-1.0.item-files-format</i18n:text>
                        <xsl:text>:</xsl:text>
                    </dt>
                    <dd class="word-break">
                        <xsl:call-template name="getFileTypeDesc">
                            <xsl:with-param name="mimetype">
                                <xsl:value-of select="substring-before(@MIMETYPE,'/')"/>
                                <xsl:text>/</xsl:text>
                                <xsl:choose>
                                    <xsl:when test="contains(@MIMETYPE,';')">
                                <xsl:value-of select="substring-before(substring-after(@MIMETYPE,'/'),';')"/>
                                    </xsl:when>
                                    <xsl:otherwise>
                                        <xsl:value-of select="substring-after(@MIMETYPE,'/')"/>
                                    </xsl:otherwise>
                                </xsl:choose>

                            </xsl:with-param>
                        </xsl:call-template>
                    </dd>
                <!-- Display the contents of 'Description' only if bitstream contains a description -->
                <xsl:if test="mets:FLocat[@LOCTYPE='URL']/@xlink:label != ''">
                        <dt>
                            <i18n:text>xmlui.dri2xhtml.METS-1.0.item-files-description</i18n:text>
                            <xsl:text>:</xsl:text>
                        </dt>
                        <dd class="word-break">
                            <xsl:attribute name="title">
                                <xsl:value-of select="mets:FLocat[@LOCTYPE='URL']/@xlink:label"/>
                            </xsl:attribute>
                            <xsl:value-of select="util:shortenString(mets:FLocat[@LOCTYPE='URL']/@xlink:label, 30, 5)"/>
                        </dd>
                </xsl:if>
                </dl>
            </div>

            <div class="file-link col-xs-6 col-xs-offset-6 col-sm-2 col-sm-offset-0">
                <xsl:choose>
                    <!-- 
                    <xsl:when test="@ADMID">
                        <xsl:call-template name="display-rights"/>
                    </xsl:when>
                     -->
                    <xsl:otherwise>
                        <xsl:call-template name="getFileIcon">
                            <xsl:with-param name="mimetype">
                                <xsl:value-of select="substring-before(@MIMETYPE,'/')"/>
                                <xsl:text>/</xsl:text>
                                <xsl:value-of select="substring-after(@MIMETYPE,'/')"/>
                            </xsl:with-param>
                        </xsl:call-template>
                        <xsl:call-template name="view-open"/>
                        <div class="artifact-preview">
                          <div class="thumbnail">
                            <xsl:call-template name="gu-bookview-link"/>
                          </div>
                        </div>
                    </xsl:otherwise>
                </xsl:choose>
            </div>
        </div>

    </xsl:template>

    <!-- GUCODE[[twb27: suppress view/open for dynamic view items (Covey)]] -->
    <xsl:template name="view-open">
        <xsl:choose>
            <xsl:when test="mets:FLocat[@xlink:label='Dynamic View']"/>
            <xsl:otherwise>
                <a>
                    <xsl:attribute name="href">
                        <xsl:value-of select="mets:FLocat[@LOCTYPE='URL']/@xlink:href"/>
                    </xsl:attribute>
                    <i18n:text>xmlui.dri2xhtml.METS-1.0.item-files-viewOpen</i18n:text>
                </a>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>

    <xsl:template name="display-rights">
        <xsl:variable name="file_id" select="jstring:replaceAll(jstring:replaceAll(string(@ADMID), '_METSRIGHTS', ''), 'rightsMD_', '')"/>
        <xsl:variable name="rights_declaration" select="../../../mets:amdSec/mets:rightsMD[@ID = concat('rightsMD_', $file_id, '_METSRIGHTS')]/mets:mdWrap/mets:xmlData/rights:RightsDeclarationMD"/>
        <xsl:variable name="rights_context" select="$rights_declaration/rights:Context"/>
        <xsl:variable name="users">
            <xsl:for-each select="$rights_declaration/*">
                <xsl:value-of select="rights:UserName"/>
                <xsl:choose>
                    <xsl:when test="rights:UserName/@USERTYPE = 'GROUP'">
                       <xsl:text> (group)</xsl:text>
                    </xsl:when>
                    <xsl:when test="rights:UserName/@USERTYPE = 'INDIVIDUAL'">
                       <xsl:text> (individual)</xsl:text>
                    </xsl:when>
                </xsl:choose>
                <xsl:if test="position() != last()">, </xsl:if>
            </xsl:for-each>
        </xsl:variable>

        <xsl:choose>
            <xsl:when test="not ($rights_context/@CONTEXTCLASS = 'GENERAL PUBLIC') and ($rights_context/rights:Permissions/@DISPLAY = 'true')">
                <a href="{mets:FLocat[@LOCTYPE='URL']/@xlink:href}">
                    <img width="64" height="64" src="{concat($theme-path,'/images/Crystal_Clear_action_lock3_64px.png')}" title="Read access available for {$users}"/>
                    <!-- icon source: http://commons.wikimedia.org/wiki/File:Crystal_Clear_action_lock3.png -->
                </a>
            </xsl:when>
            <xsl:otherwise>
                <xsl:call-template name="view-open"/>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>

    <xsl:template name="getFileIcon">
        <xsl:param name="mimetype"/>
            <i aria-hidden="true">
                <xsl:attribute name="class">
                <xsl:text>glyphicon </xsl:text>
                <xsl:choose>
                    <xsl:when test="contains(mets:FLocat[@LOCTYPE='URL']/@xlink:href,'isAllowed=n')">
                        <xsl:text> glyphicon-lock</xsl:text>
                    </xsl:when>
                    <xsl:otherwise>
                        <xsl:text> glyphicon-file</xsl:text>
                    </xsl:otherwise>
                </xsl:choose>
                </xsl:attribute>
            </i>
        <xsl:text> </xsl:text>
    </xsl:template>

    <!-- Generate the license information from the file section -->
    <xsl:template match="mets:fileGrp[@USE='CC-LICENSE']" mode="simple">
        <li><a href="{mets:file/mets:FLocat[@xlink:title='license_text']/@xlink:href}"><i18n:text>xmlui.dri2xhtml.structural.link_cc</i18n:text></a></li>
    </xsl:template>

    <!-- Generate the license information from the file section -->
    <xsl:template match="mets:fileGrp[@USE='LICENSE']" mode="simple">
        <li><a href="{mets:file/mets:FLocat[@xlink:title='license.txt']/@xlink:href}"><i18n:text>xmlui.dri2xhtml.structural.link_original_license</i18n:text></a></li>
    </xsl:template>

    <!--
    File Type Mapping template

    This maps format MIME Types to human friendly File Type descriptions.
    Essentially, it looks for a corresponding 'key' in your messages.xml of this
    format: xmlui.dri2xhtml.mimetype.{MIME Type}

    (e.g.) <message key="xmlui.dri2xhtml.mimetype.application/pdf">PDF</message>

    If a key is found, the translated value is displayed as the File Type (e.g. PDF)
    If a key is NOT found, the MIME Type is displayed by default (e.g. application/pdf)
    -->
    <xsl:template name="getFileTypeDesc">
        <xsl:param name="mimetype"/>

        <!--Build full key name for MIME type (format: xmlui.dri2xhtml.mimetype.{MIME type})-->
        <xsl:variable name="mimetype-key">xmlui.dri2xhtml.mimetype.<xsl:value-of select='$mimetype'/></xsl:variable>

        <!--Lookup the MIME Type's key in messages.xml language file.  If not found, just display MIME Type-->
        <i18n:text i18n:key="{$mimetype-key}"><xsl:value-of select="$mimetype"/></i18n:text>
    </xsl:template>


</xsl:stylesheet>
