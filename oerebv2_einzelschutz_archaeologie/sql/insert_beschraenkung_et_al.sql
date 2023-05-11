/*
Legt die Eigentumsbeschränkungen aufgrund der Fundstellen im Quell-Schema an.

Aufgrund der nur als CTE verfügbaren ID-Mappings zwischen Quell- und Oereb-Schema
werden in diesem Skript auch die Dokumente, Dokumentverknüpfungen und Flächen angelegt.
*/
WITH 

legende AS ( 
    SELECT 
        t_id
    FROM 
        ada_archaeologie_oerebv2.transferstruktur_legendeeintrag
    WHERE 
        artcodeliste = 'urn:fdc:ilismeta.interlis.ch:2019:Typ_geschuetztes_archaeologisches_Kulturdenkmal_Flaeche'
    LIMIT 1
),

basket AS (
    SELECT 
        t_id
    FROM 
        ada_archaeologie_oerebv2.t_ili2db_basket
    WHERE 
       t_ili_tid = 'ch.so.ada.oereb_einzelschutz_archaeologie'  
    LIMIT 1
), 

darstellung AS 
(
    SELECT 
        t_id
    FROM 
        ada_archaeologie_oerebv2.transferstruktur_darstellungsdienst 
    LIMIT 1
),

amt AS (
    SELECT 
        t_id
    FROM 
        ada_archaeologie_oerebv2.amt_amt
    WHERE 
        t_ili_tid = 'ch.so.ada'
    LIMIT 1
),

beschraenkung_id_map AS (
    SELECT 
        nextval('ada_archaeologie_oerebv2.t_ili2db_seq'::regclass) AS t_id,
        fund.t_id AS quell_tid,
        fund.rrb_role AS quell_rrb_tid
    FROM 
        ada_archaeologie_v1.fachapplikation_fundstelle fund
    WHERE 
        fund.rrb_role IS NOT NULL  
),

dokument_id_map AS (
    SELECT 
        nextval('ada_archaeologie_oerebv2.t_ili2db_seq'::regclass) AS t_id,
        t_id AS quell_tid,
        rrb_nummer,
        titel,
        datum,
        dateiname
    FROM 
        ada_archaeologie_v1.fachapplikation_regierungsratsbeschluss rrb
),

beschraenkung_insert AS (
    INSERT INTO ada_archaeologie_oerebv2.transferstruktur_eigentumsbeschraenkung (
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
        b.t_id,
        basket.t_id AS t_basket,
        uuid_generate_v4() AS t_ili_tid,
        'inKraft' AS rechtsstatus,
        dok.datum AS publiziertab,
        darstellung.t_id AS darstellung_tid,
        legende.t_id AS legende_tid,
        amt.t_id AS amt_tid
    FROM 
        beschraenkung_id_map b
    JOIN
        dokument_id_map dok ON b.quell_rrb_tid = dok.quell_tid
    CROSS JOIN 
        basket
    CROSS JOIN 
        darstellung
    CROSS JOIN
        legende
    CROSS JOIN
        amt
),

dokument_insert AS (
    INSERT INTO ada_archaeologie_oerebv2.dokumente_dokument
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
        dok.t_id,
        basket.t_id AS t_basket,
        '_'||CAST(uuid_generate_v4() AS TEXT) AS t_ili_tid,
        'Rechtsvorschrift' AS typ,
        'Regierungsratsbeschluss' AS titel_de,
        'RRB' AS abkuerzung_de,
        dok.rrb_nummer AS offiziellenr_de,
        CAST(998 AS int) AS auszugindex,
        'inKraft' AS rechtsstatus,
        dok.datum AS publiziertab,
        amt.t_id AS amt_tid
    FROM 
        dokument_id_map dok
    CROSS JOIN 
        basket
    CROSS JOIN 
        amt
),

doklink_insert AS (
    INSERT INTO ada_archaeologie_oerebv2.transferstruktur_hinweisvorschrift
     (
        eigentumsbeschraenkung,
        vorschrift,
        t_basket
     )
    SELECT 
        b.t_id AS beschr_tid,
        dok.t_id AS dok_tid,
        basket.t_id AS t_basket
    FROM 
        beschraenkung_id_map b 
    JOIN 
        dokument_id_map dok ON b.quell_rrb_tid = dok.quell_tid
    CROSS JOIN 
        basket
),

flaeche_id_map AS (
    SELECT 
        nextval('ada_archaeologie_oerebv2.t_ili2db_seq'::regclass) AS t_id,
        fundstelle_role AS quell_fund_tid,
        (ST_Dump(amultipolygon)).geom::geometry(Polygon,2056) AS singlepoly
    FROM 
        ada_archaeologie_v1.geo_flaeche
    WHERE 
        oereb_flaeche IS TRUE
)

--flaeche_insert
INSERT INTO 
    ada_archaeologie_oerebv2.transferstruktur_geometrie
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
    f.t_id,
    basket.t_id AS t_basket,
    uuid_generate_v4(),
    ST_ReducePrecision(singlepoly, 0.001) AS flaeche,
    'inKraft' AS rechtsstatus,
    d.datum,
    b.t_id AS beschr_tid
FROM 
    flaeche_id_map f
JOIN
    beschraenkung_id_map b ON f.quell_fund_tid = b.quell_tid
JOIN 
    dokument_id_map d ON b.quell_rrb_tid = d.quell_tid
CROSS JOIN 
    basket
;