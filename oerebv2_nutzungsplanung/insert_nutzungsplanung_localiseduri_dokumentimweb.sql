WITH multilingualuri AS
(
    INSERT INTO
        arp_nutzungsplanung_oerebv2.multilingualuri
        (
            t_id,
            t_basket,
            t_seq,
            dokumente_dokument_textimweb
        )
    -- Verknüpfung der Dokumente mit dem Basket der Nutzungsplanung
    SELECT
        nextval('arp_nutzungsplanung_oerebv2.t_ili2db_seq'::regclass) AS t_id,
        basket.t_id,
        0 AS t_seq,
        dokumente_dokument.t_id AS dokumente_dokument_textimweb
    FROM
        arp_nutzungsplanung_oerebv2.dokumente_dokument AS dokumente_dokument,
        (
            SELECT
                t_id
            FROM
                arp_nutzungsplanung_oerebv2.t_ili2db_basket
            WHERE
                t_ili_tid = 'ch.so.arp.oereb_nutzungsplanung' 
        ) AS basket
    RETURNING *
)
,
localiseduri AS 
(
    SELECT 
        nextval('arp_nutzungsplanung_oerebv2.t_ili2db_seq'::regclass) AS t_id,
        basket.t_id AS basket_t_id,
        0 AS t_seq,
        'de' AS alanguage,
        textimweb AS atext,
        multilingualuri.t_id AS multilingualuri_localisedtext
    FROM
        arp_nutzungsplanung_v1.rechtsvorschrften_dokument AS dokumente_dokument
        RIGHT JOIN multilingualuri 
        ON multilingualuri.dokumente_dokument_textimweb = dokumente_dokument.t_id,
        (
            SELECT
                t_id
            FROM
                arp_nutzungsplanung_oerebv2.t_ili2db_basket
            WHERE
                t_ili_tid = 'ch.so.arp.oereb_nutzungsplanung' 
        ) AS basket
)
INSERT INTO
    arp_nutzungsplanung_oerebv2.localiseduri
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