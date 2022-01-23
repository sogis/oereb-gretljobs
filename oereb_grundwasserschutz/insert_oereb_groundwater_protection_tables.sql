/* Siehe auch statische Waldgrenzen.
 * 
 * (1) Der erste Block ist bloss notwendig, weil es zwei Themen sind. Ebenfalls wird die
 * Trennung des Darstellungsdienstes (mit einem zusätzlichen Insert) notwendig, weil beim
 * letzten Block man das Thema einem Record zuweisen muss. Der Blocke darstellungsdienst_insert
 * resp. die Tabelle ist ziemlich dumm. Man muss zwar am Ende alle drei Tabellen verknüpfen.
 * Dieses Wissen steckt aber im Block darstungsdienst.
 * 
 */

WITH themen AS 
(
    SELECT 
        'ch.Grundwasserschutzzonen' AS thema
    UNION ALL
    SELECT 
        'ch.Grundwasserschutzareale' AS thema
)
,
darstellungsdienst AS 
(
    SELECT
        nextval('afu_grundwasserschutz_oereb.t_ili2db_seq'::regclass) AS t_id,
        basket.t_id AS basket_t_id,
        uuid_generate_v4() AS t_ili_tid,
        themen.thema
    FROM 
    (
        SELECT
            t_id
        FROM
            afu_grundwasserschutz_oereb.t_ili2db_basket
        WHERE
            t_ili_tid = 'ch.so.afu.oereb_grundwasserschutz' 
    ) AS basket, 
    themen
)
,
darstellungsdienst_insert AS (
    INSERT INTO 
        afu_grundwasserschutz_oereb.transferstruktur_darstellungsdienst 
        (
            t_id,
            t_basket,
            t_ili_tid            
        )         
    SELECT 
        t_id,
        basket_t_id,
        t_ili_tid
    FROM 
        darstellungsdienst
)
,
darstellungsdienst_multilingualuri AS 
(
    INSERT INTO
        afu_grundwasserschutz_oereb.multilingualuri 
        (
            t_basket,
            t_seq, 
            transfrstrkstllngsdnst_verweiswms
        )
    SELECT 
        basket_t_id,
        0,
        t_id
    FROM 
        darstellungsdienst
    RETURNING *
)
INSERT INTO 
    afu_grundwasserschutz_oereb.localiseduri 
    (
        t_basket,
        t_seq,
        alanguage,
        atext,
        multilingualuri_localisedtext
    )
SELECT
    t_basket,
    0,
    'de',
    '${wmsHost}/wms/oereb?SERVICE=WMS&VERSION=1.3.0&REQUEST=GetMap&FORMAT=image%2Fpng&TRANSPARENT=true&LAYERS='||darstellungsdienst.thema||'&STYLES=&SRS=EPSG%3A2056&CRS=EPSG%3A2056&DPI=96&WIDTH=1200&HEIGHT=1146&BBOX=2591250%2C1211350%2C2646050%2C1263700',
    darstellungsdienst_multilingualuri.t_id
FROM
    darstellungsdienst_multilingualuri
    LEFT JOIN darstellungsdienst
    ON darstellungsdienst.t_id = darstellungsdienst_multilingualuri.transfrstrkstllngsdnst_verweiswms
;

/* 
 * Eigentumsbeschränkungen und Legendeneinträge
 * 
 * (1) Geometrie kann in einem Abwasch gemacht werden, das im Ausgangsmodell die Geometrie mit der
 * Eigentumsbeschränkung in einer Klasse verwaltet wird.
 */

WITH darstellungsdienst AS 
(
    SELECT
        darstellungsdienst.t_id,
        darstellungsdienst.t_basket AS basket_t_id,
        localiseduri.atext
    FROM 
        afu_grundwasserschutz_oereb.transferstruktur_darstellungsdienst AS darstellungsdienst
        LEFT JOIN afu_grundwasserschutz_oereb.multilingualuri AS multilingualuri  
        ON multilingualuri.transfrstrkstllngsdnst_verweiswms = darstellungsdienst.t_id 
        LEFT JOIN afu_grundwasserschutz_oereb.localiseduri AS localiseduri 
        ON localiseduri.multilingualuri_localisedtext = multilingualuri.t_id 
)
,
eigentumsbeschraenkung AS 
(
    SELECT
        --DISTINCT ON (gwszone.t_id) Braucht es nicht, da nicht mit Geometrie gejoined wird (im Gegensatz zum statischen Wald)
        gwszone.t_id,
        darstellungsdienst.basket_t_id,
        CASE
            WHEN gwszone.typ = 'S1'
                THEN 'Grundwasserschutzzone S1'
            WHEN gwszone.typ = 'S2'
                THEN 'Grundwasserschutzzone S2'
            WHEN gwszone.typ = 'S3'
                THEN 'Grundwasserschutzzone S3'
            WHEN gwszone.typ = 'Sh'
                THEN 'Grundwasserschutzzone Sh'
            WHEN gwszone.typ = 'Sm'
                THEN 'Grundwasserschutzzone Sm'
            WHEN gwszone.typ = 'S3Zu'
                THEN 'Grundwasserschutzzone S3Zu'
            WHEN gwszone.typ = 'S_kantonaleArt'
                THEN 'Grundwasserschutzzone S_kantonaleArt'
        END AS legendetext_de,
        'ch.Grundwasserschutzzonen' AS thema,
        gwszone.typ AS artcode,
        'urn:fdc:ilismeta.interlis.ch:2017:Typ_Kanton_Grundwasserschutzzonen' AS artcodeliste,
        status.rechtsstatus,
        status.rechtskraftdatum AS publiziertab, 
        darstellungsdienst.t_id AS darstellungsdienst,
        amt.t_id AS zustaendigestelle,
        geometrie
    FROM
        afu_gewaesserschutz.gwszonen_gwszone AS gwszone
        LEFT JOIN afu_grundwasserschutz_oereb.amt_amt AS amt
        ON amt.t_ili_tid = 'ch.so.afu'
        LEFT JOIN afu_gewaesserschutz.gwszonen_status AS status
        ON gwszone.astatus = status.t_id
        LEFT JOIN darstellungsdienst 
        ON darstellungsdienst.atext ILIKE '%ch.Grundwasserschutzzonen%'
    WHERE
        status.rechtskraftdatum IS NOT NULL
    AND
        status.rechtsstatus = 'inKraft'
        
    UNION ALL 
    
    SELECT
        --DISTINCT ON (gwszone.t_id) Braucht es nicht, da nicht mit Geometrie gejoined wird (im Gegensatz zum statischen Wald)
        gwszone.t_id,
        darstellungsdienst.basket_t_id,
        'Grundwasserschutzareal' AS legendetext_de,
        'ch.Grundwasserschutzareale' AS thema,
        gwszone.typ AS artcode,
        'urn:fdc:ilismeta.interlis.ch:2017:Typ_Kanton_Grundwasserschutzareale' AS artcodeliste,
        status.rechtsstatus,
        status.rechtskraftdatum AS publiziertab, 
        darstellungsdienst.t_id AS darstellungsdienst,
        amt.t_id AS zustaendigestelle,
        geometrie
    FROM
        afu_gewaesserschutz.gwszonen_gwsareal AS gwszone
        LEFT JOIN afu_grundwasserschutz_oereb.amt_amt AS amt
        ON amt.t_ili_tid = 'ch.so.afu'
        LEFT JOIN afu_gewaesserschutz.gwszonen_status AS status
        ON gwszone.astatus = status.t_id
        LEFT JOIN darstellungsdienst 
        ON darstellungsdienst.atext ILIKE '%ch.Grundwasserschutzareale%'
    WHERE
        status.rechtskraftdatum IS NOT NULL
    AND
        status.rechtsstatus = 'inKraft'
)
,
geometrie AS 
(
    INSERT INTO 
    afu_grundwasserschutz_oereb.transferstruktur_geometrie 
    (
        t_id,
        t_basket,
        t_ili_tid,
        flaeche,
        rechtsstatus,
        publiziertab,
        eigentumsbeschraenkung
    )
    SELECT 
        nextval('afu_grundwasserschutz_oereb.t_ili2db_seq'::regclass) AS t_id,
        basket_t_id,
        uuid_generate_v4(),
        geometrie,
        rechtsstatus,
        publiziertab,
        t_id
    FROM 
        eigentumsbeschraenkung
)
,
legendeneintrag AS (
    INSERT INTO 
        afu_grundwasserschutz_oereb.transferstruktur_legendeeintrag 
        (
            t_id,
            t_basket,
            t_ili_tid,
            symbol,
            legendetext_de,
            artcode,
            artcodeliste,
            thema,
            darstellungsdienst    
        )
    SELECT 
        DISTINCT ON (artcode, artcodeliste)
        nextval('afu_grundwasserschutz_oereb.t_ili2db_seq'::regclass) AS legendeneintrag_t_id,
        basket_t_id,
        uuid_generate_v4(),
        eintrag.symbol,
        legendetext_de,
        eigentumsbeschraenkung.artcode,
        eigentumsbeschraenkung.artcodeliste,
        eigentumsbeschraenkung.thema,
        darstellungsdienst
    FROM 
        eigentumsbeschraenkung 
        LEFT JOIN afu_grundwasserschutz_oereb.legendeneintraege_legendeneintrag AS eintrag
        ON (eigentumsbeschraenkung.artcode = eintrag.artcode AND eigentumsbeschraenkung.artcodeliste = eintrag.artcodeliste)
    RETURNING *
)
INSERT INTO
    afu_grundwasserschutz_oereb.transferstruktur_eigentumsbeschraenkung 
    (
        t_id,
        t_basket,
        t_ili_tid,
        rechtsstatus,
        publiziertab,
        darstellungsdienst,
        legende,
        zustaendigestelle
    )
SELECT 
    eigentumsbeschraenkung.t_id, 
    eigentumsbeschraenkung.basket_t_id,
    uuid_generate_v4(),
    eigentumsbeschraenkung.rechtsstatus,
    eigentumsbeschraenkung.publiziertab,
    eigentumsbeschraenkung.darstellungsdienst,
    legendeneintrag.t_id,
    eigentumsbeschraenkung.zustaendigestelle
FROM 
    eigentumsbeschraenkung 
    LEFT JOIN legendeneintrag 
    ON (eigentumsbeschraenkung.artcode = legendeneintrag.artcode AND eigentumsbeschraenkung.artcodeliste = legendeneintrag.artcodeliste)
;

/** 
 * Dokumente
 * 
 * Werden 1:1 kopiert, inkl. die Zwischentabelle. Es muss nichts flachgewalzt werden, weil die Dokumente
 * nicht so erfasst werden.
 */

INSERT INTO 
    afu_grundwasserschutz_oereb.dokumente_dokument
    (
        t_id,
        t_basket,
        t_ili_tid,
        typ,
        titel_de,
        abkuerzung_de,
        offiziellenr_de,
        auszugindex,
        rechtsstatus,
        publiziertab,
        zustaendigestelle
    )   
    SELECT 
        DISTINCT ON (dokument.t_id)
        dokument.t_id AS t_id,
        basket.t_id AS basket_t_id,
        '_'||SUBSTRING(REPLACE(CAST(dokument.t_id AS text), '-', ''),1,15) AS t_ili_tid,
        CASE
            WHEN art = 'Rechtsvorschrift' THEN 'Rechtsvorschrift'
            ELSE 'Hinweis'
        END AS typ,
        dokument.titel AS titel_de,
        dokument.abkuerzung AS abkuerzung_de,
        CASE
            WHEN dokument.titel = 'Regierungsratsbeschluss' AND dokument.offiziellenr IS NOT NULL
                THEN date_part('YEAR', publiziertab)||'/'||offiziellenr
            ELSE dokument.offiziellenr
        END AS offiziellenr_de,
        CASE
            WHEN art <> 'Rechtsvorschrift' THEN CAST(998 AS int4) 
            ELSE CAST(999 AS int4)
        END as auzugindex,
        dokument.rechtsstatus AS rechtsstatus,
        dokument.publiziertab AS publiziertab,
        amt.t_id AS zustaendigestelle
    FROM
        afu_gewaesserschutz.gwszonen_dokument AS dokument,
        (
            SELECT 
                t_id
            FROM 
                afu_grundwasserschutz_oereb.amt_amt 
            WHERE 
                t_ili_tid = 'ch.so.afu'
        ) AS amt,
        (
            SELECT 
                t_id 
            FROM 
                afu_grundwasserschutz_oereb.t_ili2db_basket 
            WHERE 
                t_ili_tid = 'ch.so.afu.oereb_grundwasserschutz'
        ) AS basket
    WHERE
        art = 'Rechtsvorschrift'
    AND
        rechtsstatus = 'inKraft'
;

INSERT INTO
    afu_grundwasserschutz_oereb.transferstruktur_hinweisvorschrift
    (
        t_id,
        t_basket,
        eigentumsbeschraenkung,
        vorschrift  
    )
    SELECT 
        hinweisvorschrift.t_id, 
        basket.t_id AS basket_t_id,
        hinweisvorschrift.eigentumsbeschraenkung,
        hinweisvorschrift.vorschrift_vorschriften_dokument
    FROM
    (
        SELECT
            t_id, 
            gwszone AS eigentumsbeschraenkung,
            rechtsvorschrift AS vorschrift_vorschriften_dokument
        FROM
            afu_gewaesserschutz.gwszonen_rechtsvorschriftgwszone

        UNION ALL

        SELECT
            t_id, 
            gwsareal AS eigentumsbeschraenkung,
            rechtsvorschrift AS vorschrift_vorschriften_dokument
        FROM
            afu_gewaesserschutz.gwszonen_rechtsvorschriftgwsareal            
    ) AS hinweisvorschrift
    INNER JOIN afu_grundwasserschutz_oereb.dokumente_dokument AS dokumente_dokument
    ON dokumente_dokument.t_id = hinweisvorschrift.vorschrift_vorschriften_dokument,  
    (
        SELECT 
            t_id 
        FROM 
            afu_grundwasserschutz_oereb.t_ili2db_basket 
        WHERE 
            t_ili_tid = 'ch.so.afu.oereb_grundwasserschutz'
    ) AS basket
;

/*
 * Datenumbau der Links auf die Dokumente, die im Rahmenmodell 'multilingual' sind und daher eher
 * mühsam normalisert sind.
 * 
 * Das funktioniert so einfach weil wir die t_id mitschleppen können.
 */

WITH multilingualuri AS
(
    INSERT INTO
        afu_grundwasserschutz_oereb.multilingualuri
        (
            t_id,
            t_basket,
            t_seq,
            dokumente_dokument_textimweb
        )
    SELECT
        nextval('afu_grundwasserschutz_oereb.t_ili2db_seq'::regclass) AS t_id,
        basket.t_id AS basket_t_id,
        0 AS t_seq,
        dokumente_dokument.t_id AS dokumente_dokument_textimweb
    FROM
        afu_grundwasserschutz_oereb.dokumente_dokument AS dokumente_dokument,
        (
            SELECT 
                t_id 
            FROM 
                afu_grundwasserschutz_oereb.t_ili2db_basket 
            WHERE 
                t_ili_tid = 'ch.so.afu.oereb_grundwasserschutz'
        ) AS basket
    RETURNING *
)
,
localiseduri AS 
(
    SELECT 
        nextval('afu_grundwasserschutz_oereb.t_ili2db_seq'::regclass) AS t_id,
        basket.t_id AS basket_t_id,
        0 AS t_seq,
        'de' AS alanguage,
        CASE
            WHEN rechtsvorschrften_dokument.textimweb IS NULL
                THEN 'https://geo.so.ch/docs/ch.so.arp.zonenplaene/Zonenplaene_pdf/404.pdf'
            ELSE rechtsvorschrften_dokument.textimweb
        END AS atext,
        multilingualuri.t_id AS multilingualuri_localisedtext
    FROM
        afu_gewaesserschutz.gwszonen_dokument AS rechtsvorschrften_dokument
        RIGHT JOIN multilingualuri 
        ON multilingualuri.dokumente_dokument_textimweb = rechtsvorschrften_dokument.t_id,
        (
            SELECT 
                t_id 
            FROM 
                afu_grundwasserschutz_oereb.t_ili2db_basket 
            WHERE 
                t_ili_tid = 'ch.so.afu.oereb_grundwasserschutz'
        ) AS basket
    WHERE
        art = 'Rechtsvorschrift'
    AND
        rechtsstatus = 'inKraft'
)
INSERT INTO
    afu_grundwasserschutz_oereb.localiseduri
    (
        t_id,
        t_basket,
        t_seq,
        alanguage,
        atext,
        multilingualuri_localisedtext
    )
    SELECT 
        t_id,
        basket_t_id,
        t_seq,
        alanguage,
        atext,
        multilingualuri_localisedtext
    FROM 
        localiseduri
;
