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
 * (1) Inner Join mit Rechtsvorschriften_link führt dazu, dass Objekt ohne
 * Link durch die Maschen fallen. Technisch gut, weil ein Dokument zwingend ist,
 * inhaltich nicht gut, weil so das Objekt nich im Kataster publiziert wird.
 * Amt muss Daten korrigieren.
 * 
 * (2) Was mit dieser Query nicht funktioniert, sind Objekte welche eine Punkt- und
 * Polygongeometrie haben. Dann müsste man wegen der Artcodeliste irgendwie das
 * Objekt verdoppeln. Mehrere Punktgeometrie pro Objekt kann gemäss Modellkommentar
 * vorkommen.
 *
 */

WITH darstellungsdienst AS 
(
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
eigentumsbeschraenkung AS 
(
    SELECT
        DISTINCT ON (denkmal.id)
        denkmal.id,
        basket.t_id AS basket_t_id,
        'ch.SO.Einzelschutz' AS thema,
        'inKraft' AS rechtsstatus,
        rechtsvorschrift_link.datum AS publiziertab,
        darstellungsdienst.t_id AS darstellungsdienst,
        amt.t_id AS zustaendigestelle,
        'geschütztes historisches Kulturdenkmal' AS legendetext_de,        
        'geschuetztes_Kulturdenkmal' AS artcode,
        CASE
            WHEN gis_geometrie.punkt IS NOT NULL AND gis_geometrie.apolygon IS NULL
                THEN 'urn:fdc:ilismeta.interlis.ch:2019:Typ_geschuetztes_historisches_Kulturdenkmal_Punkt'
            WHEN gis_geometrie.apolygon IS NOT NULL AND gis_geometrie.punkt IS NULL
                THEN 'urn:fdc:ilismeta.interlis.ch:2019:Typ_geschuetztes_historisches_Kulturdenkmal_Flaeche'
        END AS artcodeliste
    FROM
        ada_denkmalschutz.fachapplikation_denkmal AS denkmal
        LEFT JOIN ada_denkmalschutz_oerebv2.amt_amt AS amt
        ON amt.t_ili_tid = 'ch.so.ada'
        INNER JOIN ada_denkmalschutz.gis_geometrie AS gis_geometrie
        ON denkmal.id = gis_geometrie.denkmal_id
        AND
        ((gis_geometrie.punkt IS NOT NULL AND gis_geometrie.apolygon IS NULL)
         OR
        (gis_geometrie.punkt IS NULL AND gis_geometrie.apolygon IS NOT NULL))
        INNER JOIN ada_denkmalschutz.fachapplikation_rechtsvorschrift_link AS rechtsvorschrift_link
        ON denkmal.id = rechtsvorschrift_link.denkmal_id,
        (
            SELECT
                t_id
            FROM
                ada_denkmalschutz_oerebv2.t_ili2db_basket
            WHERE
                t_ili_tid = 'ch.so.ada.oereb_einzelschutz_denkmal' 
        ) AS basket,
        darstellungsdienst
     WHERE
         denkmal.schutzstufe_code = 'geschuetzt'
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
        eigentumsbeschraenkung.id
    FROM 
        ada_denkmalschutz.gis_geometrie AS geometrie
        INNER JOIN eigentumsbeschraenkung 
        ON geometrie.denkmal_id = eigentumsbeschraenkung.id
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
        eigentumsbeschraenkung.id
    FROM 
        ada_denkmalschutz.gis_geometrie AS geometrie
        INNER JOIN eigentumsbeschraenkung 
        ON geometrie.denkmal_id = eigentumsbeschraenkung.id
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
    eigentumsbeschraenkung.id, 
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
        offiziellenr,
        auszugindex,
        rechtsstatus,
        publiziertab,
        zustaendigestelle
    )
    SELECT 
        DISTINCT ON (dokument.t_id)
        dokument.t_id AS t_id,
        basket.t_id AS basket_t_id,
        '_'||SUBSTRING(REPLACE(CAST(dokument.t_id AS text), '-', ''),1,15) AS t_ili_tid,  
        'Rechtsvorschrift' AS art,
        CASE
            WHEN schutzdurchgemeinde IS TRUE
                THEN 'Gemeinderatsbeschluss'
            ELSE 'Regierungsratsbeschluss'
        END AS titel_de,
        CASE
            WHEN schutzdurchgemeinde IS TRUE
                THEN 'GRB'
            ELSE 'RRB'
        END AS abkuerzung_de,
        CASE
            WHEN dokument.nummer LIKE '%/%'
                THEN dokument.nummer
            ELSE EXTRACT(YEAR FROM datum)||'/'||nummer
        END AS offiziellenr,
        CAST(998 AS int) AS auszugindex,
        'inKraft' AS rechtsstatus,
        dokument.datum AS publiziertab,
        amt.t_id AS zustaendigestelle
    FROM
        ada_denkmalschutz.fachapplikation_rechtsvorschrift_link AS dokument
        INNER JOIN ada_denkmalschutz.fachapplikation_denkmal AS denkmal
        ON denkmal.id = dokument.denkmal_id
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
    WHERE
        denkmal.schutzstufe_code = 'geschuetzt'
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
        ada_denkmalschutz.fachapplikation_rechtsvorschrift_link AS typ_dokument
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
    -- WHERE
    --    typ_dokument.datum IS NOT NULL
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
            WHEN rechtsvorschrften_dokument.multimedia_link IS NULL
                THEN 'https://s3.eu-central-1.amazonaws.com/'||${s3AdaLiveBucket}||'/pdf_404.pdf'
            ELSE regexp_replace(rechtsvorschrften_dokument.multimedia_link, 'artplus\.verw\.rootso\.org/MpWeb-apSolothurnDenkmal/download/(.*)\?mode=gis', 's3.eu-central-1.amazonaws.com/'||${s3AdaLiveBucket}||'/ada_\1.pdf')
        END AS atext,
        multilingualuri.t_id AS multilingualuri_localisedtext
    FROM
        ada_denkmalschutz.fachapplikation_rechtsvorschrift_link AS rechtsvorschrften_dokument
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
    --WHERE
     --   rechtsvorschrften_dokument.datum IS NOT NULL
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