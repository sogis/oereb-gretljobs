WITH darstellungsdienst AS 
(
    INSERT INTO 
        ada_denkmalschutz_oerebv2.transferstruktur_darstellungsdienst 
        (
            t_id,
            t_basket,
            t_ili_tid            
        )         
    SELECT
        nextval('ada_denkmalschutz_oerebv2.t_ili2db_seq'::regclass) AS t_id,
        basket.t_id,
        uuid_generate_v4() AS t_ili_tid
    FROM 
    (
        SELECT
            t_id
        FROM
            ada_denkmalschutz_oerebv2.t_ili2db_basket
        WHERE
            t_ili_tid = 'ch.so.ada.oereb_einzelschutz_denkmal' 
    ) AS basket
    RETURNING *
)
,
darstellungsdienst_multilingualuri AS 
(
    INSERT INTO
        ada_denkmalschutz_oerebv2.multilingualuri 
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
    ada_denkmalschutz_oerebv2.localiseduri 
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
    '${wmsHost}/wms/oereb?SERVICE=WMS&VERSION=1.3.0&REQUEST=GetMap&FORMAT=image%2Fpng&TRANSPARENT=true&LAYERS=ch.SO.Einzelschutz&STYLES=&SRS=EPSG%3A2056&CRS=EPSG%3A2056&DPI=96&WIDTH=1200&HEIGHT=1146&BBOX=2591250%2C1211350%2C2646050%2C1263700',
    darstellungsdienst_multilingualuri.t_id
FROM
    darstellungsdienst_multilingualuri
;

/*
 * Was mit dieser Query nicht funktioniert, sind Objekte welche eine Punkt- und
 * Polygongeometrie haben. Dann müsste man wegen der Artcodeliste irgendwie das
 * Objekt verdoppeln. Mehrere Punktgeometrie pro Objekt kann gemäss Modellkommentar
 * vorkommen.
 *
 */
 WITH

darstellungsdienst AS (
    SELECT
        darstellungsdienst.t_id,
        darstellungsdienst.t_basket AS basket_t_id,
        localiseduri.atext
    FROM 
        ada_denkmalschutz_oerebv2.transferstruktur_darstellungsdienst AS darstellungsdienst
        LEFT JOIN ada_denkmalschutz_oerebv2.multilingualuri AS multilingualuri  
        ON multilingualuri.transfrstrkstllngsdnst_verweiswms = darstellungsdienst.t_id 
        LEFT JOIN ada_denkmalschutz_oerebv2.localiseduri AS localiseduri 
        ON localiseduri.multilingualuri_localisedtext = multilingualuri.t_id 
)
,
basket_id AS (
    SELECT
        t_id AS basket_t_id
    FROM
        ada_denkmalschutz_oerebv2.t_ili2db_basket
    WHERE
        t_ili_tid = 'ch.so.ada.oereb_einzelschutz_denkmal' 
)
,
min_rechtsvorschrift_datum AS (
    SELECT 
        min(datum) AS min_datum,
        denkmal_id
    FROM 
        ada_denkmalschutz_v1.oereb_doclink_v
    GROUP BY 
        denkmal_id       
)
,
amt_ada AS ( -- Gint genau eine Zeile zurück
    SELECT 
        t_id AS amt_tid
    FROM 
        ada_denkmalschutz_oerebv2.amt_amt
    WHERE 
        t_ili_tid = 'ch.so.ada'
)
,
eigentumsbeschraenkung AS 
(
    SELECT
        denkmal.denkmal_id,
        basket_id.basket_t_id,
        'ch.SO.Einzelschutz' AS thema,
        'inKraft' AS rechtsstatus,
        mindat.min_datum AS publiziertab,
        darstellungsdienst.t_id AS darstellungsdienst,
        amt_ada.amt_tid AS zustaendigestelle,
        'geschütztes historisches Kulturdenkmal' AS legendetext_de,        
        'geschuetztes_Kulturdenkmal' AS artcode,
        CASE
            WHEN denkmal.digi_as_polygon IS FALSE 
                THEN 'urn:fdc:ilismeta.interlis.ch:2019:Typ_geschuetztes_historisches_Kulturdenkmal_Punkt'
            ELSE
                'urn:fdc:ilismeta.interlis.ch:2019:Typ_geschuetztes_historisches_Kulturdenkmal_Flaeche'
        END AS artcodeliste
    FROM        
        ada_denkmalschutz_v1.denkmal_entwurfsstatus_v AS denkmal
        INNER JOIN 
            min_rechtsvorschrift_datum mindat ON denkmal.denkmal_id = mindat.denkmal_id,
        amt_ada,
        basket_id,
        darstellungsdienst     
    WHERE 
            denkmal.in_oereb IS TRUE
        AND 
            denkmal.digitalisiert IS TRUE
)
,
geometrie_flaeche AS 
(
    INSERT INTO 
        ada_denkmalschutz_oerebv2.transferstruktur_geometrie
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
        nextval('ada_denkmalschutz_oerebv2.t_ili2db_seq'::regclass) AS t_id,
        eigentumsbeschraenkung.basket_t_id,
        uuid_generate_v4(),
        ST_ReducePrecision(apolygon, 0.001) AS flaeche,
        eigentumsbeschraenkung.rechtsstatus,
        eigentumsbeschraenkung.publiziertab,
        eigentumsbeschraenkung.denkmal_id
    FROM 
        ada_denkmalschutz_v1.gis_geometrie AS geometrie
        INNER JOIN eigentumsbeschraenkung 
        ON geometrie.denkmal_id = eigentumsbeschraenkung.denkmal_id
    WHERE 
        apolygon IS NOT NULL   
)
,
geometrie_punkt AS 
(
    INSERT INTO 
        ada_denkmalschutz_oerebv2.transferstruktur_geometrie
        (
            t_id,
            t_basket,
            t_ili_tid,
            punkt,
            rechtsstatus,
            publiziertab,
            eigentumsbeschraenkung
        )
    SELECT 
        nextval('ada_denkmalschutz_oerebv2.t_ili2db_seq'::regclass) AS t_id,
        eigentumsbeschraenkung.basket_t_id,
        uuid_generate_v4(),
        punkt,
        eigentumsbeschraenkung.rechtsstatus,
        eigentumsbeschraenkung.publiziertab,
        eigentumsbeschraenkung.denkmal_id
    FROM 
        ada_denkmalschutz_v1.gis_geometrie AS geometrie
        INNER JOIN eigentumsbeschraenkung 
        ON geometrie.denkmal_id = eigentumsbeschraenkung.denkmal_id
    WHERE 
        punkt IS NOT NULL        
)
,
legendeneintrag AS (
    INSERT INTO 
        ada_denkmalschutz_oerebv2.transferstruktur_legendeeintrag 
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
        nextval('ada_denkmalschutz_oerebv2.t_ili2db_seq'::regclass) AS legendeneintrag_t_id,
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
        LEFT JOIN ada_denkmalschutz_oerebv2.legendeneintraege_legendeneintrag AS eintrag
        ON (eigentumsbeschraenkung.artcode = eintrag.artcode AND eigentumsbeschraenkung.artcodeliste = eintrag.artcodeliste)
    RETURNING *
)

INSERT INTO
    ada_denkmalschutz_oerebv2.transferstruktur_eigentumsbeschraenkung 
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
    eigentumsbeschraenkung.denkmal_id, 
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
    ON (eigentumsbeschraenkung.artcode = legendeneintrag.artcode AND eigentumsbeschraenkung.artcodeliste = legendeneintrag.artcodeliste)
;
      

/*
 * Dokumente
 * 
 * (1) Saubere wäre wenn man die Eigentumsbeschränkung-Tabelle verwenden könnte. 
 * Das geht nicht, weil man noch Infos aus der Original-Tabelle braucht.
 */
 

INSERT INTO 
    ada_denkmalschutz_oerebv2.dokumente_dokument
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
        dokument.t_id AS t_id,
        basket.t_id AS basket_t_id,
        '_'||SUBSTRING(REPLACE(CAST(dokument.t_id AS text), '-', ''),1,15) AS t_ili_tid,  
        'Rechtsvorschrift' AS art,
        CASE
            WHEN rrb_jahr_nummer IS NULL
                THEN 'Gemeinderatsbeschluss, ' || regexp_replace(dokument.titel, '\r?\n|\r|\s+',' ','g')
            ELSE 'Regierungsratsbeschluss, ' || regexp_replace(dokument.titel, '\r?\n|\r|\s+',' ','g')
        END AS titel_de,
        CASE
            WHEN rrb_jahr_nummer IS NULL
                THEN 'GRB'
            ELSE 'RRB'
        END AS abkuerzung_de,
        rrb_jahr_nummer AS offiziellenr,
        CAST(998 AS int) AS auszugindex,
        'inKraft' AS rechtsstatus,
        dokument.datum AS publiziertab,
        amt.t_id AS zustaendigestelle
    FROM
        ada_denkmalschutz_v1.oereb_doclink_v AS dokument
        LEFT JOIN ada_denkmalschutz_oerebv2.amt_amt AS amt
        ON amt.t_ili_tid = 'ch.so.ada',
        (
            SELECT
                t_id
            FROM
                ada_denkmalschutz_oerebv2.t_ili2db_basket
            WHERE
                t_ili_tid = 'ch.so.ada.oereb_einzelschutz_denkmal' 
        ) AS basket
;

INSERT INTO
     ada_denkmalschutz_oerebv2.transferstruktur_hinweisvorschrift
     (
         t_basket,
         eigentumsbeschraenkung,
         vorschrift  
     )
     SELECT
         basket.t_id AS basket_t_id,
         eigentumsbeschraenkung.t_id AS eigentumsbeschraenkung,
         typ_dokument.t_id AS vorschrift_vorschriften_dokument
      FROM
        ada_denkmalschutz_v1.oereb_doclink_v AS typ_dokument
        INNER JOIN ada_denkmalschutz_oerebv2.transferstruktur_eigentumsbeschraenkung AS eigentumsbeschraenkung
        ON typ_dokument.denkmal_id = eigentumsbeschraenkung.t_id,
        (
            SELECT
                t_id
            FROM
                ada_denkmalschutz_oerebv2.t_ili2db_basket
            WHERE
                t_ili_tid = 'ch.so.ada.oereb_einzelschutz_denkmal' 
        ) AS basket
;

WITH multilingualuri AS
(
    INSERT INTO
        ada_denkmalschutz_oerebv2.multilingualuri
        (
            t_id,
            t_basket,
            t_seq,
            dokumente_dokument_textimweb
        )
    SELECT
        nextval('ada_denkmalschutz_oerebv2.t_ili2db_seq'::regclass) AS t_id,
        basket.t_id AS basket_t_id,
        0 AS t_seq,
        dokumente_dokument.t_id AS dokumente_dokument_textimweb
    FROM
        ada_denkmalschutz_oerebv2.dokumente_dokument AS dokumente_dokument,
        (
            SELECT 
                t_id 
            FROM 
                ada_denkmalschutz_oerebv2.t_ili2db_basket 
            WHERE 
                t_ili_tid = 'ch.so.ada.oereb_einzelschutz_denkmal'
        ) AS basket
    RETURNING *
)
,
localiseduri AS 
(
    SELECT 
        nextval('ada_denkmalschutz_oerebv2.t_ili2db_seq'::regclass) AS t_id,
        basket.t_id AS basket_t_id,
        0 AS t_seq,
        'de' AS alanguage,
        CASE
            WHEN dok_download_url IS NULL
                THEN 'https://geo.so.ch/docs/ch.so.ada.denkmalschutz/Error_404.pdf'
            ELSE dok_download_url
        END AS atext,
        multilingualuri.t_id AS multilingualuri_localisedtext
    FROM
        ada_denkmalschutz_v1.oereb_doclink_v AS rechtsvorschrften_dokument
        RIGHT JOIN multilingualuri 
        ON multilingualuri.dokumente_dokument_textimweb = rechtsvorschrften_dokument.t_id,
        (
            SELECT 
                t_id 
            FROM 
                ada_denkmalschutz_oerebv2.t_ili2db_basket 
            WHERE 
                t_ili_tid = 'ch.so.ada.oereb_einzelschutz_denkmal'
        ) AS basket
)
INSERT INTO
    ada_denkmalschutz_oerebv2.localiseduri
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
