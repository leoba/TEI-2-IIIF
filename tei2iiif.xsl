<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:xs="http://www.w3.org/2001/XMLSchema"
    xmlns:tei="http://www.tei-c.org/ns/1.0"
    xmlns:xd="http://www.oxygenxml.com/ns/doc/xsl"
    exclude-result-prefixes="xs tei"
    version="2.0">
    
    <xd:doc scope="stylesheet">
        <xd:desc>
            <xd:p><xd:b>Last edited on:</xd:b>October 18, 2016</xd:p>
            <xd:p><xd:b>Author:</xd:b> Dot Porter</xd:p>
            <xd:p>This document takes as input TEI Manuscript Description files and outputs IIIF manifests in json format</xd:p>
        </xd:desc>
    </xd:doc>
    
    <xsl:output indent="no" omit-xml-declaration="yes" method="text" encoding="utf-8"/>
    
    <xsl:template match="/">
        <xsl:apply-templates/>
    </xsl:template>
    
    <xsl:template match="tei:TEI">
        <xsl:variable name="idno" select="//tei:idno[@type='call-number']"/>
        <xsl:variable name="msid" select="lower-case(translate(translate($idno,' ',''),'.',''))"/>
        <xsl:variable name="collection">
            <xsl:choose>
                <xsl:when test="contains($idno,'LJS')">LJSchoenbergManuscripts</xsl:when>
                <xsl:otherwise>PennManuscripts</xsl:otherwise>
            </xsl:choose>
        </xsl:variable>
        <xsl:variable name="desc-title" select="//tei:titleStmt/tei:title"/>
        <xsl:variable name="title" select="replace($desc-title,'Description of ','')"/>
        <xsl:variable name="ms-title" select="//tei:msItem[1]/tei:title"/>
        <xsl:variable name="institution" select="//tei:institution"/>
        <xsl:variable name="repository" select="//tei:repository"/>
        <xsl:variable name="recordURL" select="//tei:altIdentifier/tei:idno"/>
        <!-- variables for description -->
        <xsl:variable name="summary" select="//tei:summary"/>
        <xsl:variable name="textLang" select="//tei:textLang"/>
        <xsl:variable name="support" select="//tei:support/tei:p"/>
        <xsl:variable name="extent" select="//tei:extent/tei:p"/>
        <xsl:variable name="collation" select="//tei:collation/tei:p"/>
        <xsl:variable name="layout" select="//tei:layout"/>
        <xsl:variable name="scriptNote" select="//tei:scriptNote"/>
        <xsl:variable name="decoNote" select="//tei:decoDesc/tei:decoNote[1]"/>
        <xsl:variable name="binding" select="//tei:binding/tei:p"/>
        <xsl:variable name="origin" select="//tei:origin/tei:p"/>
        <!-- Dates -->
        <xsl:variable name="date" select="//tei:origDate"/>
        <xsl:variable name="compuDate">
            <xsl:choose>
                <xsl:when
                    test="contains($date,'between')">
                    <xsl:value-of select="substring($date,9,4)"/>-<xsl:value-of select="substring($date,18,4)"/>
                </xsl:when>
                <xsl:when
                    test="contains($date,'--')">
                    <xsl:value-of select="tokenize($date,'--') [position() = 1]"/>00-<xsl:value-of select="tokenize($date,'--') [position() = 1]"/>99</xsl:when>
                <xsl:when
                    test="contains($date,'-')">
                    <xsl:value-of select="$date"/>
                </xsl:when>
                <xsl:when
                    test="contains($date,'approximately')">
                    <xsl:value-of select="substring($date,15,4)"/>
                </xsl:when>
                <xsl:when
                    test="contains($date,',')">
                    <xsl:value-of select="translate($date,',','-')"/>
                </xsl:when>
                <xsl:when
                    test="contains($date,'A.H.')">
                    <xsl:variable name="ah-token" select="tokenize($date,' ') [position() = 2]"/>
                    <xsl:if test="string-length($ah-token) = 3"><xsl:value-of select="substring(//tei:origDate,11,4)"/></xsl:if>
                    <xsl:if test="string-length($ah-token) = 4"><xsl:value-of select="substring(//tei:origDate,12,4)"/></xsl:if>
                </xsl:when>
                <xsl:otherwise>
                    <xsl:value-of select="$date"/>
                </xsl:otherwise>
            </xsl:choose>
        </xsl:variable>
        <!-- Cover Thumbnail -->
        <xsl:variable name="cover-thumb" select="//tei:facsimile/tei:surface[1]/tei:graphic[contains(@url,'master')]/@url"/>
        <xsl:variable name="folio-id" select="translate(translate($cover-thumb,'master/',''),'.tif','')"/>
        <xsl:result-document href="{$msid}/manifest.json">
        {
        "@context": "http://iiif.io/api/presentation/2/context.json",
        "@id": "http://45.55.178.234/iiif/<xsl:value-of select="$msid"/>/manifest.json",
        "@type": "sc:Manifest",
        "label": "<xsl:value-of select="$ms-title"/>. <xsl:value-of select="$institution"/>, <xsl:value-of select="$repository"/>, <xsl:value-of select="$idno"/>",
        "attribution": "Provided by the University of Pennsylvania Libraries",
        "seeAlso": {
        "@id": "http://openn.library.upenn.edu/Data/<xsl:value-of select="$collection"/>/<xsl:value-of select="$msid"/>/data/<xsl:value-of select="$msid"/>_TEI.xml",
        "format": "application/tei+xml"
        },
        "description": "Summary: <xsl:value-of select="$summary"/>\n        Language: <xsl:value-of select="$textLang"/>\n        Support: <xsl:value-of select="$support"/>\n        Extent: <xsl:value-of select="$extent"/>\n        Collation: <xsl:value-of select="$collation"/>\n        Layout: <xsl:value-of select="$layout"/>\n        Script: <xsl:value-of select="$scriptNote"/>\n        Decoration: <xsl:value-of select="$decoNote"/>\n        Binding: <xsl:value-of select="$binding"/>\n        Origin: <xsl:value-of select="$origin"/>\n        Cite as:\t\n        UPenn <xsl:value-of select="$idno"/>\n        For catalog record, see Permanent Link: <xsl:value-of select="$recordURL"/>\n  For TEI description and digital images, see: http://openn.library.upenn.edu/Data/<xsl:value-of select="$collection"/>/html/<xsl:value-of select="$msid"/>.html\n  ",
            "metadata": [{
            "label": "Date",
            "value": "<xsl:value-of select="$compuDate"/>"
            }],
            "thumbnail": {
            "@id": "http://45.55.178.234/loris/<xsl:value-of select="$collection"/>/<xsl:value-of select="$msid"/>/data/<xsl:value-of select="$cover-thumb"/>/full/400,/0/default.jpg",
            "service": {
            "@context": "http://iiif.io/api/image/2/context.json",
            "@id": "http://openn.library.upenn.edu/Data/<xsl:value-of select="$collection"/>/iiif/<xsl:value-of select="$msid"/>/<xsl:value-of select="$folio-id"/>",
            "profile": "http://iiif.io/api/image/2/level1.json"
            }
            },
            "sequences": [{
            "@id": "http://openn.library.upenn.edu/Data/<xsl:value-of select="$collection"/>/<xsl:value-of select="$msid"/>/sequence-1",
            "@type": "sc:Sequence",
            "label": "Current order",
            "canvases": [
            <xsl:for-each select="//tei:surface">
                <!-- canvas and resource variables -->
                <xsl:variable name="label" select="@n"/>
                <xsl:variable name="height" select="translate(tei:graphic[contains(@url,'master')]/@height,'px','')"/>
                <xsl:variable name="width" select="translate(tei:graphic[contains(@url,'master')]/@width,'px','')"/>
                <xsl:variable name="image" select="tei:graphic[contains(@url,'master')]/@url"/>
                <xsl:variable name="folio-id" select="translate(translate($image,'master/',''),'.tif','')"/>
                <xsl:variable name="count-number" select="position()"/>
                {
                "@id": "http://openn.library.upenn.edu/Data/<xsl:value-of select="$collection"/>/<xsl:value-of select="$msid"/>/canvas/canvas-<xsl:value-of select="$count-number"/>",
                "@type": "sc:Canvas",
                "label": "<xsl:value-of select="$label"/>",
                "height": <xsl:value-of select="$height"/>,
                "width": <xsl:value-of select="$width"/>,
                "images": [{
                    "@id": "http://openn.library.upenn.edu/Data/<xsl:value-of select="$collection"/>/<xsl:value-of select="$msid"/>/imageanno/anno-<xsl:value-of select="$count-number"/>",
                    "@type": "oa:Annotation",
                    "motivation": "sc:painting",
                    "on": "http://openn.library.upenn.edu/Data/<xsl:value-of select="$collection"/>/<xsl:value-of select="$msid"/>/canvas/canvas-<xsl:value-of select="$count-number"/>",
                    "resource": {
                    "@id": "http://openn.library.upenn.edu/Data/<xsl:value-of select="$collection"/>/iiif/<xsl:value-of select="$msid"/>/resource/<xsl:value-of select="$folio-id"/>",
                    "@type": "dcterms:Image",
                    "format": "image/jpeg",
                    "height": <xsl:value-of select="$height"/>,
                    "width": <xsl:value-of select="$width"/>,
                        "service": {
                        "@context": "http://iiif.io/api/image/2/context.json",
                        "@id": "http://45.55.178.234/loris/<xsl:value-of select="$collection"/>/<xsl:value-of select="$msid"/>/data/<xsl:value-of select="$image"/>",
                        "profile": "http://iiif.io/api/image/2/level1.json"}
                        }
                        }]
                        }<xsl:choose><xsl:when test="position() = last()">]}]}</xsl:when>
                <xsl:otherwise>,</xsl:otherwise>
                </xsl:choose>
            </xsl:for-each>
        </xsl:result-document>
    </xsl:template>
</xsl:stylesheet>