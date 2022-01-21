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