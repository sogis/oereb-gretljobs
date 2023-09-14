WITH 

agilegende AS ( -- Aus xtf eingelesene legende
    SELECT 
        symbol, 
        artcode, 
        artcodeliste,
        thema, 
        subthema
    FROM 
        ada_archaeologie_oerebv2.legendeneintraege_legendeneintrag
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
)

INSERT INTO ada_archaeologie_oerebv2.transferstruktur_legendeeintrag 
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
    nextval('ada_archaeologie_oerebv2.t_ili2db_seq'::regclass) AS legendeneintrag_t_id,
    basket.t_id,
    uuid_generate_v4(),
    agilegende.symbol,
    'geschütztes archäologisches Kulturdenkmal' AS legendetext_de,
    agilegende.artcode,
    agilegende.artcodeliste,
    agilegende.thema,
    darstellung.t_id
FROM 
    agilegende
CROSS JOIN
    basket
CROSS JOIN
    darstellung
;