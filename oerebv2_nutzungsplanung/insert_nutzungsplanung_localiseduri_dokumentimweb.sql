/*
 * In der Tabelle multilingualuri gibt es sowohl URI auf die zuständigen Stellen
 * aus der Tabelle amt_amt, wie auch Links zu den Dokumenten im Web und die 
 * URI zu den Webdiensten.
 * In der Tabelle localiseduri stehen die nach Sprache unterschiedenen URI,
 * jeder Eintrag hat einen Fremdschlüssel auf die Tabelle multilingualuri.
 * Letztere hat wiederum einen Fremdschlüssel entweder auf amt_amt, dokumente_dokument
 * oder transfrstrkstllngsdnst_verweiswms.
 *
 * Die multilingualuri der zuständigen Stellen werden mit dem Task
 * :importResponsibleOfficesToOereb bereits vor dem Datenumbau mittels Ili2pg
 * in die Datenbank importiert.
 *
 * Mit der Abfrage in insert_nutzungsplanung_localiseduri_verweiswms.sql werden
 * die URI der Darstellungsdienste eingefügt.
 *
 * Mit der nachfolgenden Abfrage werden noch die URI zu den Dokumenten ein-
 * gefügt.
 *
 */
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
    -- Verknüpfung der Dokumente mit dem Basket der Nutzungsplanung. Die Tabelle
    -- dokumente_dokument wird bereits in einem früheren Schritt abgefüllt.
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
        -- Basket Identifier der Nutzungsplanung
        basket.t_id AS basket_t_id,
        0 AS t_seq,
        -- Sprache statisch
        'de' AS alanguage,
        -- der eigentliche URI kommt bereits aus dem Erfassungsmodell
        textimweb AS atext,
        -- Fremdschlüssel auf die Tabelle multilingualuri
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