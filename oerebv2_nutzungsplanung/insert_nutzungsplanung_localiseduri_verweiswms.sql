/*
 * (1) Es werden immer alle Darstellungsdienste eingefügt. Falls es zu einem 
 * Darstellungsdient keine Daten gibt, ist das exportierte XTF nicht
 * modellkonform.
 * Aus diesem Grund werden zuletzt nicht-verwendete WMS wieder gelöscht.
 */

WITH themen AS 
(
    SELECT 
        'ch.Nutzungsplanung' AS thema,
        'ch.SO.NutzungsplanungGrundnutzung' AS subthema
    UNION ALL
    SELECT 
        'ch.Nutzungsplanung' AS thema,
        'ch.SO.NutzungsplanungUeberlagernd' AS subthema
    UNION ALL
    SELECT 
        'ch.Nutzungsplanung' AS thema,
        'ch.SO.NutzungsplanungSondernutzungsplaene' AS subthema
    UNION ALL
    SELECT 
        'ch.Nutzungsplanung' AS thema,
        'ch.SO.Baulinien' AS subthema
    UNION ALL
    SELECT 
        'ch.Laermempfindlichkeitsstufen' AS thema,
        CAST(NULL AS text) AS subthema
    UNION ALL
    SELECT 
        'ch.Waldabstandslinien' AS thema,
        CAST(NULL AS text) AS subthema        
)
,
-- Verknüpfung des Baskets aus der t_ili2db_basket Tabelle mit den (statischen)
-- Themen.
darstellungsdienst AS
(
    SELECT
        nextval('arp_nutzungsplanung_oerebv2.t_ili2db_seq'::regclass) AS t_id,
        basket.t_id AS basket_t_id,
        uuid_generate_v4() AS t_ili_tid,
        themen.thema,
        themen.subthema
    FROM 
    (
        SELECT
            t_id
        FROM
            arp_nutzungsplanung_oerebv2.t_ili2db_basket
        WHERE
            t_ili_tid = 'ch.so.arp.oereb_nutzungsplanung' 
    ) AS basket, 
    themen
)
,
-- Einfügen der obigen Abfrage in die Tabelle transferstruktur_darstellungsdienst
darstellungsdienst_insert AS (
    INSERT INTO 
        arp_nutzungsplanung_oerebv2.transferstruktur_darstellungsdienst 
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
-- Schreibe für jedes Thema einen Verweis auf den WMS Darstellungsdienst
darstellungsdienst_multilingualuri AS 
(
    INSERT INTO
        arp_nutzungsplanung_oerebv2.multilingualuri 
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
    arp_nutzungsplanung_oerebv2.localiseduri 
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
    CASE
        WHEN darstellungsdienst.subthema IS NULL THEN '${wmsHost}/wms/oereb?SERVICE=WMS&VERSION=1.3.0&REQUEST=GetMap&FORMAT=image%2Fpng&TRANSPARENT=true&LAYERS='||darstellungsdienst.thema||'&STYLES=&SRS=EPSG%3A2056&CRS=EPSG%3A2056&DPI=96&WIDTH=1200&HEIGHT=1146&BBOX=2591250%2C1211350%2C2646050%2C1263700'
        ELSE '${wmsHost}/wms/oereb?SERVICE=WMS&VERSION=1.3.0&REQUEST=GetMap&FORMAT=image%2Fpng&TRANSPARENT=true&LAYERS='||darstellungsdienst.subthema||'&STYLES=&SRS=EPSG%3A2056&CRS=EPSG%3A2056&DPI=96&WIDTH=1200&HEIGHT=1146&BBOX=2591250%2C1211350%2C2646050%2C1263700'
    END AS atext,
    darstellungsdienst_multilingualuri.t_id
FROM
    darstellungsdienst_multilingualuri
    LEFT JOIN darstellungsdienst
    ON darstellungsdienst.t_id = darstellungsdienst_multilingualuri.transfrstrkstllngsdnst_verweiswms
;