WITH darstellungsdienst AS 
(
    INSERT INTO 
        afu_geotope_oereb.transferstruktur_darstellungsdienst 
        (
            t_id,
            t_basket,
            t_ili_tid            
        )         
    SELECT
        nextval('afu_geotope_oereb.t_ili2db_seq'::regclass) AS t_id,
        basket.t_id,
        uuid_generate_v4() AS t_ili_tid
    FROM 
    (
        SELECT
            t_id
        FROM
            afu_geotope_oereb.t_ili2db_basket
        WHERE
            t_ili_tid = 'ch.so.afu.oereb_einzelschutz_geotop' 
    ) AS basket
    RETURNING *
)
,
darstellungsdienst_multilingualuri AS 
(
    INSERT INTO
        afu_geotope_oereb.multilingualuri 
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
    afu_geotope_oereb.localiseduri 
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
 * Den Eigentumsbeschränkungsblock könnte man vereinfachen resp. viel gleichen
 * Code entfernen (die Joins).
 * 
 */

WITH darstellungsdienst AS 
(
    SELECT
        darstellungsdienst.t_id,
        darstellungsdienst.t_basket AS basket_t_id,
        localiseduri.atext
    FROM 
        afu_geotope_oereb.transferstruktur_darstellungsdienst AS darstellungsdienst
        LEFT JOIN afu_geotope_oereb.multilingualuri AS multilingualuri  
        ON multilingualuri.transfrstrkstllngsdnst_verweiswms = darstellungsdienst.t_id 
        LEFT JOIN afu_geotope_oereb.localiseduri AS localiseduri 
        ON localiseduri.multilingualuri_localisedtext = multilingualuri.t_id 
)
,
eigentumsbeschraenkung AS 
(
   -- Aufschluss
    SELECT
        aufschluss.t_id,
        basket.t_id AS basket_t_id,
        'ch.SO.Einzelschutz' AS thema,
        rechtsstatus,
        aufschluss.publiziert_ab AS publiziertab,
        darstellungsdienst.t_id AS darstellungsdienst,
        amt.t_id AS zustaendigestelle,
        'Geotope' AS legendetext_de,        
        'geotope' AS artcode,
        'urn:fdc:ilismeta.interlis.ch:2020:Typ_geschuetztes_Geotop_Flaeche' AS artcodeliste,
        geometrie
    FROM
        afu_geotope.geotope_aufschluss AS aufschluss
        LEFT JOIN afu_geotope_oereb.amt_amt AS amt
        ON amt.t_ili_tid = 'ch.so.afu',
        (
            SELECT
                t_id
            FROM
                afu_geotope_oereb.t_ili2db_basket
            WHERE
                t_ili_tid = 'ch.so.afu.oereb_einzelschutz_geotop' 
        ) AS basket,
        darstellungsdienst
     WHERE
         oereb_objekt IS TRUE
         
    UNION ALL 
    
    -- Landschaftsform
    SELECT
        landschaftsform.t_id,
        basket.t_id AS basket_t_id,
        'ch.SO.Einzelschutz' AS thema,
        rechtsstatus,
        landschaftsform.publiziert_ab AS publiziertab,
        darstellungsdienst.t_id AS darstellungsdienst,
        amt.t_id AS zustaendigestelle,
        'Geotope' AS legendetext_de,        
        'geotope' AS artcode,
        'urn:fdc:ilismeta.interlis.ch:2020:Typ_geschuetztes_Geotop_Flaeche' AS artcodeliste,
        geometrie
    FROM
        afu_geotope.geotope_landschaftsform AS landschaftsform
        LEFT JOIN afu_geotope_oereb.amt_amt AS amt
        ON amt.t_ili_tid = 'ch.so.afu',
        (
            SELECT
                t_id
            FROM
                afu_geotope_oereb.t_ili2db_basket
            WHERE
                t_ili_tid = 'ch.so.afu.oereb_einzelschutz_geotop' 
        ) AS basket,
        darstellungsdienst
     WHERE
         oereb_objekt IS TRUE

    UNION ALL
    
    --  Erratiker
    SELECT
        erratiker.t_id,
        basket.t_id AS basket_t_id,
        'ch.SO.Einzelschutz' AS thema,
        rechtsstatus,
        erratiker.publiziert_ab AS publiziertab,
        darstellungsdienst.t_id AS darstellungsdienst,
        amt.t_id AS zustaendigestelle,
        'Geotope' AS legendetext_de,        
        'geotope' AS artcode,
        'urn:fdc:ilismeta.interlis.ch:2020:Typ_geschuetztes_Geotop_Punkt' AS artcodeliste,
        geometrie
    FROM
        afu_geotope.geotope_erratiker AS erratiker
        LEFT JOIN afu_geotope_oereb.amt_amt AS amt
        ON amt.t_ili_tid = 'ch.so.afu',
        (
            SELECT
                t_id
            FROM
                afu_geotope_oereb.t_ili2db_basket
            WHERE
                t_ili_tid = 'ch.so.afu.oereb_einzelschutz_geotop' 
        ) AS basket,
        darstellungsdienst
     WHERE
         oereb_objekt IS TRUE

    UNION ALL 
    
    -- Höhle
    SELECT
        hoehle.t_id,
        basket.t_id AS basket_t_id,
        'ch.SO.Einzelschutz' AS thema,
        rechtsstatus,
        hoehle.publiziert_ab AS publiziertab,
        darstellungsdienst.t_id AS darstellungsdienst,
        amt.t_id AS zustaendigestelle,
        'Geotope' AS legendetext_de,        
        'geotope' AS artcode,
        'urn:fdc:ilismeta.interlis.ch:2020:Typ_geschuetztes_Geotop_Punkt' AS artcodeliste,
        geometrie
    FROM
        afu_geotope.geotope_hoehle AS hoehle
        LEFT JOIN afu_geotope_oereb.amt_amt AS amt
        ON amt.t_ili_tid = 'ch.so.afu',
        (
            SELECT
                t_id
            FROM
                afu_geotope_oereb.t_ili2db_basket
            WHERE
                t_ili_tid = 'ch.so.afu.oereb_einzelschutz_geotop' 
        ) AS basket,
        darstellungsdienst
     WHERE
         oereb_objekt IS TRUE
 
    UNION ALL 
    
    -- Quelle
    SELECT
        quelle.t_id,
        basket.t_id AS basket_t_id,
        'ch.SO.Einzelschutz' AS thema,
        rechtsstatus,
        quelle.publiziert_ab AS publiziertab,
        darstellungsdienst.t_id AS darstellungsdienst,
        amt.t_id AS zustaendigestelle,
        'Geotope' AS legendetext_de,        
        'geotope' AS artcode,
        'urn:fdc:ilismeta.interlis.ch:2020:Typ_geschuetztes_Geotop_Punkt' AS artcodeliste,
        geometrie
    FROM
        afu_geotope.geotope_quelle AS quelle
        LEFT JOIN afu_geotope_oereb.amt_amt AS amt
        ON amt.t_ili_tid = 'ch.so.afu',
        (
            SELECT
                t_id
            FROM
                afu_geotope_oereb.t_ili2db_basket
            WHERE
                t_ili_tid = 'ch.so.afu.oereb_einzelschutz_geotop' 
        ) AS basket,
        darstellungsdienst
     WHERE
         oereb_objekt IS TRUE     
)
,
geometrie_flaeche AS 
(
    INSERT INTO 
    afu_geotope_oereb.transferstruktur_geometrie 
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
        nextval('afu_geotope_oereb.t_ili2db_seq'::regclass) AS t_id,
        basket_t_id,
        uuid_generate_v4(),
        ST_ReducePrecision((ST_Dump(geometrie)).geom::geometry(Polygon,2056), 0.001) AS flaeche,
        rechtsstatus,
        publiziertab,
        t_id
    FROM 
        eigentumsbeschraenkung
    WHERE 
        ST_GeometryType(geometrie) = 'ST_MultiPolygon'
)
,
geometrie_punkt AS (
    INSERT INTO 
    afu_geotope_oereb.transferstruktur_geometrie 
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
        nextval('afu_geotope_oereb.t_ili2db_seq'::regclass) AS t_id,
        basket_t_id,
        uuid_generate_v4(),
        geometrie,
        rechtsstatus,
        publiziertab,
        t_id
    FROM 
        eigentumsbeschraenkung
    WHERE 
        ST_GeometryType(geometrie) = 'ST_Point'

)
,
legendeneintrag AS (
    INSERT INTO 
        afu_geotope_oereb.transferstruktur_legendeeintrag 
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
        nextval('afu_geotope_oereb.t_ili2db_seq'::regclass) AS legendeneintrag_t_id,
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
        LEFT JOIN afu_geotope_oereb.legendeneintraege_legendeneintrag AS eintrag
        ON (eigentumsbeschraenkung.artcode = eintrag.artcode AND eigentumsbeschraenkung.artcodeliste = eintrag.artcodeliste)
    RETURNING *
)
INSERT INTO
    afu_geotope_oereb.transferstruktur_eigentumsbeschraenkung 
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
    eigentumsbeschraenkung.t_id, 
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
 */

INSERT INTO
    afu_geotope_oereb.dokumente_dokument
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
        dokument.t_id AS t_id,
        basket.t_id AS basket_t_id,
        '_'||SUBSTRING(REPLACE(CAST(dokument.t_id AS text), '-', ''),1,15) AS t_ili_tid,
        'Rechtsvorschrift' AS art,
        CASE
            WHEN dokument.typ = 'RRB'
                 THEN 'Regierungsratsbeschluss'
            ELSE dokument.typ
        END AS titel_de,
        dokument.typ AS abkuerzung_de,
        dokument.offizielle_nr AS offiziellenr,
        CAST(998 AS int4) AS auszugindex,
        dokument.rechtsstatus AS rechtsstatus,
        dokument.publiziert_ab AS publiziertab,
        amt.t_id AS zustaendigestelle
    FROM
        afu_geotope.geotope_dokument AS dokument
        LEFT JOIN afu_geotope_oereb.amt_amt AS amt
        ON amt.t_ili_tid = 'ch.so.afu',
        (
            SELECT 
                t_id 
            FROM 
                afu_geotope_oereb.t_ili2db_basket 
            WHERE 
                t_ili_tid = 'ch.so.afu.oereb_einzelschutz_geotop'
        ) AS basket
    WHERE
        dokument.typ = 'RRB'
    AND
        dokument.rechtsstatus= 'inKraft'
;

WITH dokumente AS
(
    SELECT
        aufschluss AS geotop,
        dokument
    FROM
        afu_geotope.geotope_aufschluss_dokument
        
    UNION ALL    
    
    SELECT
        erratiker AS geotop,
        dokument
    FROM
        afu_geotope.geotope_erratiker_dokument
    
        UNION ALL    
    
    SELECT
        hoehle AS geotop,
        dokument
    FROM
        afu_geotope.geotope_hoehle_dokument
    
    UNION ALL    
    
    SELECT
        landform AS geotop,
        dokument
    FROM
        afu_geotope.geotope_landform_dokument
    
    UNION ALL
    
    SELECT
        quelle AS geotop,
        dokument
    FROM
        afu_geotope.geotope_quelle_dokument
)
,
hinweisvorschrift AS
(
    SELECT
        eigentumsbeschraenkung.t_id AS eigentumsbeschraenkung,
        dokumente.dokument AS dokument
    FROM
        dokumente
        INNER JOIN afu_geotope_oereb.transferstruktur_eigentumsbeschraenkung AS eigentumsbeschraenkung
        ON dokumente.geotop = eigentumsbeschraenkung.t_id
        LEFT JOIN afu_geotope.geotope_dokument AS geotope_dokument
        ON dokumente.dokument = geotope_dokument.t_id
    WHERE
        geotope_dokument.typ = 'RRB'
        AND 
        geotope_dokument.rechtsstatus = 'inKraft'
)
INSERT INTO
    afu_geotope_oereb.transferstruktur_hinweisvorschrift 
    (
        t_basket,
        eigentumsbeschraenkung,
        vorschrift
    )
    SELECT
        basket.t_id,
        hinweisvorschrift.eigentumsbeschraenkung AS eigentumsbeschraenkung,
        hinweisvorschrift.dokument AS vorschrift_vorschriften_dokument
    FROM
        hinweisvorschrift,
        (
            SELECT 
                t_id 
            FROM 
                afu_geotope_oereb.t_ili2db_basket 
            WHERE 
                t_ili_tid = 'ch.so.afu.oereb_einzelschutz_geotop'
        ) AS basket
;

WITH multilingualuri AS
(
    INSERT INTO
        afu_geotope_oereb.multilingualuri
        (
            t_id,
            t_basket,
            t_seq,
            dokumente_dokument_textimweb
        )
    SELECT
        nextval('afu_geotope_oereb.t_ili2db_seq'::regclass) AS t_id,
        basket.t_id AS basket_t_id,
        0 AS t_seq,
        dokumente_dokument.t_id AS dokumente_dokument_textimweb
    FROM
        afu_geotope_oereb.dokumente_dokument AS dokumente_dokument,
        (
            SELECT 
                t_id 
            FROM 
                afu_geotope_oereb.t_ili2db_basket 
            WHERE 
                t_ili_tid = 'ch.so.afu.oereb_einzelschutz_geotop'
        ) AS basket
    RETURNING *
)
,
localiseduri AS
(
    SELECT
        nextval('afu_geotope_oereb.t_ili2db_seq'::regclass) AS t_id,
        basket.t_id AS basket_t_id,
        0 AS t_seq,
        'de' AS alanguage,
        CASE
            WHEN rechtsvorschrften_dokument.pfad IS NULL
                THEN 'https://geo.so.ch/docs/ch.so.afu.geotope/404.pdf'
            ELSE replace(rechtsvorschrften_dokument.pfad, 'G:\documents\ch.so.afu.geotope\', 'https://geo.so.ch/docs/ch.so.afu.geotope/')
        END AS atext,
        multilingualuri.t_id AS multilingualuri_localisedtext
    FROM
        afu_geotope.geotope_dokument AS rechtsvorschrften_dokument
        RIGHT JOIN multilingualuri
        ON multilingualuri.dokumente_dokument_textimweb = rechtsvorschrften_dokument.t_id,
        (
            SELECT 
                t_id 
            FROM 
                afu_geotope_oereb.t_ili2db_basket 
            WHERE 
                t_ili_tid = 'ch.so.afu.oereb_einzelschutz_geotop'
        ) AS basket
   WHERE
       rechtsvorschrften_dokument.publiziert_ab IS NOT NULL
)
INSERT INTO
    afu_geotope_oereb.localiseduri
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
