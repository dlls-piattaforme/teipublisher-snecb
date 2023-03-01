xquery version "3.1";

module namespace idx="http://teipublisher.com/index";

declare namespace tei="http://www.tei-c.org/ns/1.0";
declare namespace dbk="http://docbook.org/ns/docbook";

declare variable $idx:app-root :=
    let $rawPath := system:get-module-load-path()
    return
        (: strip the xmldb: part :)
        if (starts-with($rawPath, "xmldb:exist://")) then
            if (starts-with($rawPath, "xmldb:exist://embedded-eXist-server")) then
                substring($rawPath, 36)
            else
                substring($rawPath, 15)
        else
            $rawPath
    ;

(:~
 : Helper function called from collection.xconf to create index fields and facets.
 : This module needs to be loaded before collection.xconf starts indexing documents
 : and therefore should reside in the root of the app.
 :)
declare function idx:get-metadata($root as element(), $field as xs:string) {
    let $header := $root/tei:teiHeader
    let $body := $root/tei:text/tei:body
    return
        switch ($field)
            case "title" return
                (
                $body//tei:biblStruct/tei:monogr/tei:title[not(@type)]
                )
            case "titleShort" return
                (
                $body//tei:biblStruct/tei:monogr/tei:title[@type='short']
                )
            case "titlePublication" return
                (
                $body//tei:biblStruct/tei:monogr/tei:title[@type='publication']
                )
            case "author" return
                (
                $body//tei:biblStruct/tei:monogr/tei:author[@role='author']
                )
            case "translator" return
                (
                $body//tei:biblStruct/tei:monogr/tei:author[@role='translator'] (: per il traduttore comunque usa un tag author, cambia il role :)
                )
            case "daten" return (
                 $body//tei:biblStruct/tei:monogr/tei:imprint/tei:date[not(@type)]
                )
            case "range" return (
                 $body//tei:biblStruct/tei:monogr/tei:imprint/tei:date[@type='range']
            )
            case "collection" return (
                $body//tei:biblStruct/tei:note[@type='collection']
            )
            case "tag" return (
                $body//tei:biblStruct/tei:note[@type='tags']/tei:note
            )
            case "editor" return (
                $body//tei:biblStruct/tei:monogr/tei:editor
            )
            case "cit" return (
                $body//tei:biblStruct/tei:note[@type='citation']
            )
            default return
                ()
};

declare function idx:get-genre($header as element()?) {
    for $target in $header//tei:textClass/tei:catRef[@scheme="#genre"]/@target
    let $category := id(substring($target, 2), doc($idx:app-root || "/data/taxonomy.xml"))
    return
        $category/ancestor-or-self::tei:category[parent::tei:category]/tei:catDesc
};
