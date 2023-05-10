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

inserts_basequery AS (
    SELECT
        nextval('ada_archaeologie_oerebv2.t_ili2db_seq'::regclass) AS multiling_tid,
        nextval('ada_archaeologie_oerebv2.t_ili2db_seq'::regclass) AS localized_tid,
        basket.t_id AS basket_tid,
        dok.t_id AS dok_tid,
        rrb.dateiname
    FROM
        ada_archaeologie_oerebv2.dokumente_dokument AS dok
    JOIN
        ada_archaeologie_v1.fachapplikation_regierungsratsbeschluss rrb ON dok.offiziellenr_de = rrb.rrb_nummer
    CROSS JOIN 
        basket
),

insert_multilingualuri AS
(
    INSERT INTO
        ada_archaeologie_oerebv2.multilingualuri
        (
            t_id,
            t_basket,
            t_seq,
            dokumente_dokument_textimweb
        )
    SELECT
        multiling_tid,
        basket_tid,
        0 AS t_seq,
        dok_tid
    FROM
        inserts_basequery
)

-- insert localizeduri
INSERT INTO
    ada_archaeologie_oerebv2.localiseduri
    (
        t_id,
        t_basket,
        t_seq,
        alanguage,
        atext,
        multilingualuri_localisedtext
    )
SELECT 
    localized_tid,
    basket_tid,
    0 AS t_seq,
    'de' AS alanguage,
    'https://geo.so.ch/docs/ch.so.ada.fundstellen/' || dateiname || '.pdf',
    multiling_tid
FROM
    inserts_basequery
;