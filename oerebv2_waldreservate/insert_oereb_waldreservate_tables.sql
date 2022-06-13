/*
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
*/

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
SELECT * FROM eigentumsbeschraenkung


