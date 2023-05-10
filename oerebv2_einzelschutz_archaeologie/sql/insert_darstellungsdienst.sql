BEGIN;

WITH 

basket AS (
    SELECT 
        t_id
    FROM 
        ada_archaeologie_oerebv2.t_ili2db_basket
    WHERE 
       t_ili_tid = 'ch.so.ada.oereb_einzelschutz_archaeologie'  
    LIMIT 1
), 

darstellungsdienst AS 
(
    INSERT INTO 
        ada_archaeologie_oerebv2.transferstruktur_darstellungsdienst 
        (
            t_id,
            t_basket,
            t_ili_tid            
        )         
    SELECT
        nextval('ada_archaeologie_oerebv2.t_ili2db_seq'::regclass) AS t_id,
        basket.t_id,
        uuid_generate_v4() AS t_ili_tid
    FROM 
        basket
    RETURNING *
)
,
darstellungsdienst_multilingualuri AS 
(
    INSERT INTO
        ada_archaeologie_oerebv2.multilingualuri 
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
    ada_archaeologie_oerebv2.localiseduri 
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
    '$wmsHost$/wms/oereb?SERVICE=WMS&VERSION=1.3.0&REQUEST=GetMap&FORMAT=image%2Fpng&TRANSPARENT=true&LAYERS=ch.SO.Einzelschutz&STYLES=&SRS=EPSG%3A2056&CRS=EPSG%3A2056&DPI=96&WIDTH=1200&HEIGHT=1146&BBOX=2591250%2C1211350%2C2646050%2C1263700',
    darstellungsdienst_multilingualuri.t_id
FROM
    darstellungsdienst_multilingualuri
;  

COMMIT;