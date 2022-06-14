WITH darstellungsdienst AS 
(
    INSERT INTO 
        arp_waldreservate_oerebv2.transferstruktur_darstellungsdienst 
        (
            t_id,
            t_basket,
            t_ili_tid            
        )         
    SELECT
        nextval('arp_waldreservate_oerebv2.t_ili2db_seq'::regclass) AS t_id,
        basket.t_id,
        uuid_generate_v4() AS t_ili_tid
    FROM 
    (
        SELECT
            t_id
        FROM
            arp_waldreservate_oerebv2.t_ili2db_basket
        WHERE
            t_ili_tid = 'ch.so.arp.oereb_waldreservate' 
    ) AS basket
    RETURNING *
)
,
darstellungsdienst_multilingualuri AS 
(
    INSERT INTO
        arp_waldreservate_oerebv2.multilingualuri 
        (
            t_basket,
            t_seq, 
            transfrstrkstllngsdnst_verweiswms
        )
    SELECT 
        t_basket,
        0,
        t_id
    FROM 
        darstellungsdienst
    RETURNING *
)
INSERT INTO 
    arp_waldreservate_oerebv2.localiseduri 
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
    '${wmsHost}/wms/oereb?SERVICE=WMS&VERSION=1.3.0&REQUEST=GetMap&FORMAT=image%2Fpng&TRANSPARENT=true&LAYERS=ch.Waldreservate&STYLES=&SRS=EPSG%3A2056&CRS=EPSG%3A2056&DPI=96&WIDTH=1200&HEIGHT=1146&BBOX=2591250%2C1211350%2C2646050%2C1263700',
    darstellungsdienst_multilingualuri.t_id
FROM
    darstellungsdienst_multilingualuri
;

/*
 * (1): Der Code muss für sämtliche Teilobjekte eines Waldreservates gleich sein. Sonst muss man die Query 
 * anders machen.
 * 
 */
WITH darstellungsdienst AS 
(
    SELECT
        darstellungsdienst.t_id,
        darstellungsdienst.t_basket AS basket_t_id,
        localiseduri.atext
    FROM 
        arp_waldreservate_oerebv2.transferstruktur_darstellungsdienst AS darstellungsdienst
        LEFT JOIN arp_waldreservate_oerebv2.multilingualuri AS multilingualuri  
        ON multilingualuri.transfrstrkstllngsdnst_verweiswms = darstellungsdienst.t_id 
        LEFT JOIN arp_waldreservate_oerebv2.localiseduri AS localiseduri 
        ON localiseduri.multilingualuri_localisedtext = multilingualuri.t_id 
)
,
eigentumsbeschraenkung AS (
    SELECT
        DISTINCT ON (waldreservate.t_id)
        waldreservate.t_id,
        darstellungsdienst.basket_t_id,
        'ch.Waldgrenzen' AS thema,
        waldreservate.rechtsstatus,
        waldreservate.publiziertab,
        darstellungsdienst.t_id AS darstellungsdienst,
        amt.amt_t_id AS zustaendigestelle,
        CASE 
            WHEN teilobjekt.mcpfe_code = 'MCPFE1_1' THEN 'Keine aktiven Eingriffe'
            WHEN teilobjekt.mcpfe_code = 'MCPFE1_2' THEN 'Minimale Eingriffe'
            WHEN teilobjekt.mcpfe_code = 'MCPFE1_3' THEN 'Biodiversitätsförderung durch gezielte Eingriffe'
        END AS legendetext_de,
        REPLACE(teilobjekt.mcpfe_code, '_', '.') AS artcode,
        'urn:fdc:ilismeta.interlis.ch:2017:Waldreservate_Codelisten_V1_1' AS artcodeliste
    FROM 
        arp_waldreservate_v1.geobasisdaten_waldreservat AS waldreservate
        LEFT JOIN arp_waldreservate_v1.geobasisdaten_waldreservat_teilobjekt AS teilobjekt 
        ON waldreservate.t_id = teilobjekt.wr 
        LEFT JOIN darstellungsdienst 
        ON darstellungsdienst.atext ILIKE '%ch.Waldreservate%',
        (
            SELECT 
                t_id AS amt_t_id
            FROM 
                arp_waldreservate_oerebv2.amt_amt 
            WHERE 
                t_ili_tid = 'ch.so.arp'
        ) AS amt
)
,
legendeneintrag AS (
    INSERT INTO 
        arp_waldreservate_oerebv2.transferstruktur_legendeeintrag 
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
        nextval('arp_waldreservate_oerebv2.t_ili2db_seq'::regclass) AS legendeneintrag_t_id,
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
        LEFT JOIN arp_waldreservate_oerebv2.legendeneintraege_legendeneintrag AS eintrag
        ON eigentumsbeschraenkung.artcode = eintrag.artcode 
    RETURNING *
)
INSERT INTO
    arp_waldreservate_oerebv2.transferstruktur_eigentumsbeschraenkung 
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
    ON (eigentumsbeschraenkung.artcode = legendeneintrag.artcode)
;


/*
 * Muss angepasst werden, falls nicht mehr alle Objekte (Waldreservate)
 * 1:1 in den ÖREB-Kataster kommen.
 */
INSERT INTO
    arp_waldreservate_oerebv2.transferstruktur_geometrie
    ( 
        t_basket,
        flaeche,
        rechtsstatus,
        publiziertab,
        eigentumsbeschraenkung
    )
SELECT
    basket.t_id AS t_basket,
    teilobjekt.geo_obj AS flaeche,
    eigentumsbeschraenkung.rechtsstatus ,
    eigentumsbeschraenkung.publiziertab AS publiziertab,
    eigentumsbeschraenkung.t_id AS eigentumsbeschraenkung
FROM
    arp_waldreservate_v1.geobasisdaten_waldreservat_teilobjekt AS teilobjekt
    INNER JOIN arp_waldreservate_oerebv2.transferstruktur_eigentumsbeschraenkung AS eigentumsbeschraenkung
    ON teilobjekt.wr = eigentumsbeschraenkung.t_id,
    (
        SELECT
            t_id
        FROM
            arp_waldreservate_oerebv2.t_ili2db_basket
        WHERE
            t_ili_tid = 'ch.so.arp.oereb_waldreservate' 
    ) AS basket
;


/*
 * Das funktioniert solange man einfach alles kopieren kann und die Modellstruktur identisch ist.
 */
WITH basket AS (
    SELECT
        t_id
    FROM
        arp_waldreservate_oerebv2.t_ili2db_basket
    WHERE
        t_ili_tid = 'ch.so.arp.oereb_waldreservate' 
)
,
dokumente_dokument AS
(
    INSERT INTO 
        arp_waldreservate_oerebv2.dokumente_dokument 
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
        dokument.t_id,
        basket.t_id AS t_basket,
        '_'||CAST(uuid_generate_v4() AS TEXT) AS t_ili_tid,
        'Rechtsvorschrift'AS typ,
        dokument.titel AS titel_de,
        dokument.abkuerzung AS abkuerzung_de,
        dokument.offiziellenr AS offiziellenr_de,
        998 AS auzugindex,
        dokument.rechtsstatus AS rechtsstatus,
        dokument.publiziertab AS publiziertab,
        (
            SELECT 
                t_id
            FROM
                arp_waldreservate_oerebv2.amt_amt 
            WHERE
                t_ili_tid = 'ch.so.sk'
        ) AS zustaendigestelle
    FROM 
        arp_waldreservate_v1.dokumente_dokument AS dokument,
        basket
)
INSERT INTO 
    arp_waldreservate_oerebv2.transferstruktur_hinweisvorschrift 
    (
        t_basket,
        t_ili_tid,
        eigentumsbeschraenkung,
        vorschrift
    )
SELECT 
    basket.t_id AS t_basket, 
    '_'||CAST(uuid_generate_v4() AS TEXT) AS t_ili_tid,
    waldreservat_dokument.festlegung,
    waldreservat_dokument.dokumente
FROM 
    arp_waldreservate_v1.geobasisdaten_waldreservat_dokument AS waldreservat_dokument,
    basket
;