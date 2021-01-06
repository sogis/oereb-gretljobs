/*
 * Die korrekte Reihenfolge der Queries ist zwingend. 
 * 
 * Allg. Überlegungen/Bemerkungen zum Datenumbau finden sich im SQL-Skript
 * sogis/oereb-gretljobs/oereb_nutzungsplanung/insert_oereb_landuseplans_tables.sql.
 * Das Thema Gewässerschutz kann gemäss Filterfunktion im Dokument
 * "Planerischer_Gewaesserschutz_ID130,131,132_20171023_V1.1_d.pdf" in die
 * Transferstruktur des Rahmenmodells für den ÖREB-Kataster transformiert werden.
 */

INSERT INTO 
    afu_geotope_oereb.transferstruktur_eigentumsbeschraenkung
  (
        t_id,
        t_basket,
        t_datasetname,
        aussage_de,
        thema,
        weiteresthema,
        artcode,
        artcodeliste,
        rechtsstatus,
        publiziertab,
        zustaendigestelle
    )
   -- Aufschluss
    SELECT
        DISTINCT ON (aufschluss.t_id)
        aufschluss.t_id,
        basket_dataset.basket_t_id,
        basket_dataset.datasetname,
        'Geotope' AS aussage_de,
        'WeiteresThema' AS thema,
        'ch.SO.Einzelschutz' AS weiteresthema,
        'kantonal.geschuetztes_Geotop' AS artcode,
        'urn:fdc:ilismeta.interlis.ch:2017:Typ_geschuetztes_Geotop_Flaeche' AS artcodeliste,
        rechtsstatus,
        aufschluss.publiziert_ab AS publiziertab,
        amt.t_id AS zustaendigestelle
    FROM
        afu_geotope.geotope_aufschluss AS aufschluss
        LEFT JOIN afu_geotope_oereb.vorschriften_amt AS amt
        ON amt.t_ili_tid = 'ch.so.afu',
        (
            SELECT
                basket.t_id AS basket_t_id,
                dataset.datasetname AS datasetname
            FROM
                afu_geotope_oereb.t_ili2db_dataset AS dataset
                LEFT JOIN afu_geotope_oereb.t_ili2db_basket AS basket
                ON basket.dataset = dataset.t_id
            WHERE
                dataset.datasetname = 'ch.so.afu.geotop'
        ) AS basket_dataset
     WHERE
         oereb_objekt IS TRUE
       
    UNION ALL
    
    --  Erratiker
    SELECT
        DISTINCT ON (erratiker.t_id)
        erratiker.t_id,
        basket_dataset.basket_t_id,
        basket_dataset.datasetname,
        'Geotope' AS aussage_de,
        'WeiteresThema' AS thema,
        'ch.SO.Einzelschutz' AS weiteresthema,
        'kantonal.geschuetztes_Geotop' AS artcode,
        'urn:fdc:ilismeta.interlis.ch:2017:Typ_geschuetztes_Geotop_Punkt' AS artcodeliste,
        rechtsstatus,
        erratiker.publiziert_ab AS publiziertab,
        amt.t_id AS zustaendigestelle
    FROM
        afu_geotope.geotope_erratiker AS erratiker
        LEFT JOIN afu_geotope_oereb.vorschriften_amt AS amt
        ON amt.t_ili_tid = 'ch.so.afu',
        (
            SELECT
                basket.t_id AS basket_t_id,
                dataset.datasetname AS datasetname
            FROM
                afu_geotope_oereb.t_ili2db_dataset AS dataset
                LEFT JOIN afu_geotope_oereb.t_ili2db_basket AS basket
                ON basket.dataset = dataset.t_id
            WHERE
                dataset.datasetname = 'ch.so.afu.geotop'
        ) AS basket_dataset
     WHERE
         oereb_objekt IS TRUE
        
    UNION ALL
    
    -- Höhle
    SELECT
        DISTINCT ON (hoehle.t_id)
        hoehle.t_id,
        basket_dataset.basket_t_id,
        basket_dataset.datasetname,
        'Geotope' AS aussage_de,
        'WeiteresThema' AS thema,
        'ch.SO.Einzelschutz' AS weiteresthema,
        'kantonal.geschuetztes_Geotop' AS artcode,
        'urn:fdc:ilismeta.interlis.ch:2017:Typ_geschuetztes_Geotop_Punkt' AS artcodeliste,
        rechtsstatus,
        hoehle.publiziert_ab AS publiziertab,
        amt.t_id AS zustaendigestelle
    FROM
        afu_geotope.geotope_hoehle AS hoehle
        LEFT JOIN afu_geotope_oereb.vorschriften_amt AS amt
        ON amt.t_ili_tid = 'ch.so.afu',
        (
            SELECT
                basket.t_id AS basket_t_id,
                dataset.datasetname AS datasetname
            FROM
                afu_geotope_oereb.t_ili2db_dataset AS dataset
                LEFT JOIN afu_geotope_oereb.t_ili2db_basket AS basket
                ON basket.dataset = dataset.t_id
            WHERE
                dataset.datasetname = 'ch.so.afu.geotop'
        ) AS basket_dataset
     WHERE
         oereb_objekt IS TRUE
        
    UNION ALL
    
    -- Landschaftsform
    SELECT
        DISTINCT ON (landschaftsform.t_id)
        landschaftsform.t_id,
        basket_dataset.basket_t_id,
        basket_dataset.datasetname,
        'Geotope' AS aussage_de,
        'WeiteresThema' AS thema,
        'ch.SO.Einzelschutz' AS weiteresthema,
        'kantonal' AS artcode,
        'urn:fdc:ilismeta.interlis.ch:2017:Typ_geschuetztes_Geotop_Flaeche' AS artcodeliste,
        rechtsstatus,
        landschaftsform.publiziert_ab AS publiziertab,
        amt.t_id AS zustaendigestelle
    FROM
        afu_geotope.geotope_landschaftsform AS landschaftsform
        LEFT JOIN afu_geotope_oereb.vorschriften_amt AS amt
        ON amt.t_ili_tid = 'ch.so.afu',
        (
            SELECT
                basket.t_id AS basket_t_id,
                dataset.datasetname AS datasetname
            FROM
                afu_geotope_oereb.t_ili2db_dataset AS dataset
                LEFT JOIN afu_geotope_oereb.t_ili2db_basket AS basket
                ON basket.dataset = dataset.t_id
            WHERE
                dataset.datasetname = 'ch.so.afu.geotop'
        ) AS basket_dataset
     WHERE
         oereb_objekt IS TRUE
        
    UNION ALL
    
    -- Quelle
    SELECT
        DISTINCT ON (quelle.t_id)
        quelle.t_id,
        basket_dataset.basket_t_id,
        basket_dataset.datasetname,
        'Geotope' AS aussage_de,
        'WeiteresThema' AS thema,
        'ch.SO.Einzelschutz' AS weiteresthema,
        'kantonal.geschuetztes_Geotop' AS artcode,
        'urn:fdc:ilismeta.interlis.ch:2017:Typ_geschuetztes_Geotop_Punkt' AS artcodeliste,
        rechtsstatus,
        quelle.publiziert_ab AS publiziertab,
        amt.t_id AS zustaendigestelle
    FROM
        afu_geotope.geotope_quelle AS quelle
        LEFT JOIN afu_geotope_oereb.vorschriften_amt AS amt
        ON amt.t_ili_tid = 'ch.so.afu',
        (
            SELECT
                basket.t_id AS basket_t_id,
                dataset.datasetname AS datasetname
            FROM
                afu_geotope_oereb.t_ili2db_dataset AS dataset
                LEFT JOIN afu_geotope_oereb.t_ili2db_basket AS basket
                ON basket.dataset = dataset.t_id
            WHERE
                dataset.datasetname = 'ch.so.afu.geotop'
        ) AS basket_dataset
     WHERE
         oereb_objekt IS TRUE
;

/*
 * Dokumente
 */

INSERT INTO
    afu_geotope_oereb.vorschriften_dokument
    (
        t_id,
        t_basket,
        t_datasetname,
        t_type,
        t_ili_tid,
        titel_de,
        offiziellertitel_de,
        abkuerzung_de,
        offiziellenr,
        kanton,
        gemeinde,
        rechtsstatus,
        publiziertab,
        zustaendigestelle
    )
     SELECT
        DISTINCT ON (dokument.t_id)
        dokument.t_id AS t_id,
        basket_dataset.basket_t_id,
        basket_dataset.datasetname,
        CASE
            WHEN dokument.typ = 'RRB'
                THEN 'vorschriften_rechtsvorschrift'
        END AS t_type,
        '_'||SUBSTRING(REPLACE(CAST(dokument.t_id AS text), '-', ''),1,15) AS t_ili_tid,
        dokument.typ AS titel_de,
        dokument.titel AS offizellertitel_de,
        dokument.typ AS abkuerzung_de,
        dokument.offizielle_nr AS offiziellenr,
        'SO' AS kanton,
        NULL AS gemeinde,
        dokument.rechtsstatus AS rechtsstatus,
        dokument.publiziert_ab AS publiziertab,
        amt.t_id AS zustaendigestelle
    FROM
        afu_geotope.geotope_dokument AS dokument
        LEFT JOIN afu_geotope_oereb.vorschriften_amt AS amt
        ON amt.t_ili_tid = 'ch.so.afu',
        (
            SELECT
                basket.t_id AS basket_t_id,
                dataset.datasetname AS datasetname
            FROM
                afu_geotope_oereb.t_ili2db_dataset AS dataset
                LEFT JOIN afu_geotope_oereb.t_ili2db_basket AS basket
                ON basket.dataset = dataset.t_id
            WHERE
                dataset.datasetname = 'ch.so.afu.geotop'
            ) AS basket_dataset
    WHERE
        dokument.typ = 'RRB'
    AND
        rechtsstatus = 'inKraft'
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
)
INSERT INTO
    afu_geotope_oereb.transferstruktur_hinweisvorschrift
    (
        t_basket,
        t_datasetname,
        eigentumsbeschraenkung,
        vorschrift_vorschriften_dokument
    )
    SELECT
        basket_t_id,
        datasetname,
        hinweisvorschrift.eigentumsbeschraenkung AS eigentumsbeschraenkung,
        hinweisvorschrift.dokument AS vorschrift_vorschriften_dokument
    FROM
        hinweisvorschrift,
        (
            SELECT
                basket.t_id AS basket_t_id,
                dataset.datasetname AS datasetname
            FROM
                afu_geotope_oereb.t_ili2db_dataset AS dataset
                LEFT JOIN afu_geotope_oereb.t_ili2db_basket AS basket
                ON basket.dataset = dataset.t_id
            WHERE
                dataset.datasetname = 'ch.so.afu.geotop'
    ) AS basket_dataset
;

/*
 * Datenumbau der Links auf die Dokumente, die im Rahmenmodell 'multilingual' sind und daher eher
 * mühsam normalisert sind.
 */

WITH multilingualuri AS
(
    INSERT INTO
        afu_geotope_oereb.multilingualuri
        (
            t_id,
            t_basket,
            t_datasetname,
            t_seq,
            vorschriften_dokument_textimweb
        )
    SELECT
        nextval('afu_geotope_oereb.t_ili2db_seq'::regclass) AS t_id,
        basket_dataset.basket_t_id,
        basket_dataset.datasetname,
        0 AS t_seq,
        vorschriften_dokument.t_id AS vorschriften_dokument_textimweb
    FROM
        afu_geotope_oereb.vorschriften_dokument AS vorschriften_dokument,
        (
            SELECT
                basket.t_id AS basket_t_id,
                dataset.datasetname AS datasetname
            FROM
                afu_geotope_oereb.t_ili2db_dataset AS dataset
                LEFT JOIN afu_geotope_oereb.t_ili2db_basket AS basket
                ON basket.dataset = dataset.t_id
            WHERE
                dataset.datasetname = 'ch.so.afu.geotop'
        ) AS basket_dataset
    WHERE
        vorschriften_dokument.t_datasetname = 'ch.so.afu.geotop'
    RETURNING *
)
,
localiseduri AS
(
    SELECT
        nextval('afu_geotope_oereb.t_ili2db_seq'::regclass) AS t_id,
        basket_dataset.basket_t_id,
        basket_dataset.datasetname,
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
        ON multilingualuri.vorschriften_dokument_textimweb = rechtsvorschrften_dokument.t_id,
        (
            SELECT
                basket.t_id AS basket_t_id,
                dataset.datasetname AS datasetname
            FROM
                afu_geotope_oereb.t_ili2db_dataset AS dataset
                LEFT JOIN afu_geotope_oereb.t_ili2db_basket AS basket
                ON basket.dataset = dataset.t_id
            WHERE
                dataset.datasetname = 'ch.so.afu.geotop'
        ) AS basket_dataset
   WHERE
       rechtsvorschrften_dokument.publiziert_ab IS NOT NULL
)
INSERT INTO
    afu_geotope_oereb.localiseduri
    (
        t_id,
        t_basket,
        t_datasetname,
        t_seq,
        alanguage,
        atext,
        multilingualuri_localisedtext
    )
    SELECT
        t_id,
        basket_t_id,
        datasetname,
        t_seq,
        alanguage,
        atext,
        multilingualuri_localisedtext
    FROM
        localiseduri
;

/*
 * Umbau der Geometrien, die Inhalt des ÖREB-Katasters sind.
 */

-- Punktgeometrien
INSERT INTO
    afu_geotope_oereb.transferstruktur_geometrie
    (
        t_basket,
        t_datasetname,
        punkt_lv95,
        rechtsstatus,
        publiziertab,
        eigentumsbeschraenkung,
        zustaendigestelle
    )
    SELECT
        basket_dataset.basket_t_id AS t_basket,
        basket_dataset.datasetname AS t_datasetname,
        geotop.geometrie AS punkt_lv95,
        geotop.rechtsstatus AS rechtsstatus,
        geotop.publiziertab AS publiziertab,
        eigentumsbeschraenkung.t_id AS eigentumsbeschraenkung,
        eigentumsbeschraenkung.zustaendigestelle AS zustaendigestelle
    FROM
    (
    --Erratiker
    SELECT
        t_id,
        geometrie AS geometrie,
        geometrie.rechtsstatus AS rechtsstatus,
        publiziert_ab AS publiziertab
    FROM
        afu_geotope.geotope_erratiker AS geometrie
    WHERE
         oereb_objekt IS TRUE
         
    UNION ALL
    
    -- Höhle
    SELECT
        t_id,
        geometrie AS geometrie,
        geometrie.rechtsstatus AS rechtsstatus,
        publiziert_ab AS publiziertab
    FROM
        afu_geotope.geotope_hoehle AS geometrie
    WHERE
         oereb_objekt IS TRUE
         
    UNION ALL
    
    -- Quelle
    SELECT
        t_id,
        geometrie AS geometrie,
        geometrie.rechtsstatus AS rechtsstatus,
        publiziert_ab AS publiziertab
    FROM
        afu_geotope.geotope_quelle AS geometrie
    WHERE
         oereb_objekt IS TRUE
    ) AS geotop
    
    INNER JOIN afu_geotope_oereb.transferstruktur_eigentumsbeschraenkung AS eigentumsbeschraenkung
    ON geotop.t_id = eigentumsbeschraenkung.t_id,
    (
        SELECT
            basket.t_id AS basket_t_id,
            dataset.datasetname AS datasetname
        FROM
            afu_geotope_oereb.t_ili2db_dataset AS dataset
            LEFT JOIN afu_geotope_oereb.t_ili2db_basket AS basket
            ON basket.dataset = dataset.t_id
        WHERE
            dataset.datasetname = 'ch.so.afu.geotop'
    ) AS basket_dataset
;

-- Flächengeometrien
INSERT INTO
    afu_geotope_oereb.transferstruktur_geometrie
    (
        t_basket,
        t_datasetname,
        flaeche_lv95,
        rechtsstatus,
        publiziertab,
        eigentumsbeschraenkung,
        zustaendigestelle
    )
    SELECT
        basket_dataset.basket_t_id AS t_basket,
        basket_dataset.datasetname AS t_datasetname,
        ST_GeometryN(ST_CollectionExtract(ST_MakeValid(ST_RemoveRepeatedPoints(ST_SnapToGrid(geotop.geometrie, 0.001))), 3), 1) AS flaeche_lv95,
        geotop.rechtsstatus AS rechtsstatus,
        geotop.publiziertab AS publiziertab,
        eigentumsbeschraenkung.t_id AS eigentumsbeschraenkung,
        eigentumsbeschraenkung.zustaendigestelle AS zustaendigestelle
    FROM
    (
    -- Aufschluss
    SELECT
        t_id,
        geometrie AS geometrie,
        geometrie.rechtsstatus AS rechtsstatus,
        publiziert_ab AS publiziertab
    FROM
        afu_geotope.geotope_aufschluss AS geometrie
     WHERE
         oereb_objekt IS TRUE
         
    UNION ALL
    
    -- Landschaftsform
    SELECT
        t_id,
        geometrie AS geometrie,
        geometrie.rechtsstatus AS rechtsstatus,
        publiziert_ab AS publiziertab
    FROM
        afu_geotope.geotope_landschaftsform AS geometrie
    WHERE
         oereb_objekt IS TRUE
    ) AS geotop
    
    INNER JOIN afu_geotope_oereb.transferstruktur_eigentumsbeschraenkung AS eigentumsbeschraenkung
    ON geotop.t_id = eigentumsbeschraenkung.t_id,
    (
        SELECT
            basket.t_id AS basket_t_id,
            dataset.datasetname AS datasetname
        FROM
            afu_geotope_oereb.t_ili2db_dataset AS dataset
            LEFT JOIN afu_geotope_oereb.t_ili2db_basket AS basket
            ON basket.dataset = dataset.t_id
        WHERE
            dataset.datasetname = 'ch.so.afu.geotop'
    ) AS basket_dataset
;

/*
 * Abfüllen der "WMS- und Legendentabellen".
 * 
 * (1) Achtung: URL für GetMap und Legende überprüfen.
 *  
 * (2) Geht das Update schöner?
 * 
 * (3) Auffälliges Dummy-PNG als Symbol damit Datenbank-Constraint nicht verletzt wird.
 *  
 * (4) Query-Logik funktionert nur, falls die Layer im WMS aus den Namen des Themas und Subthemas
 * zusammengesetzt sind.
 *
 * (5) Join zwischen Legendeneintrag und Darstellungsdienst wird über das Subthema im WMS-Layername gemacht.
 * 
 * (6) Man kann nicht auf Vorrat für sämtliche Themen/Subthemen/Geometrietypen einen Darstellungsdienst
 * einfügen. Das verletzt das Modell.
 */

WITH transferstruktur_darstellungsdienst AS
(
    INSERT INTO
        afu_geotope_oereb.transferstruktur_darstellungsdienst
        (
            t_basket,
            t_datasetname,
            verweiswms,
            legendeimweb
        )
        SELECT
            basket_dataset.basket_t_id AS t_basket,
            basket_dataset.datasetname AS t_datasetname,
            '${wmsHost}/wms/oereb?SERVICE=WMS&VERSION=1.3.0&REQUEST=GetMap&FORMAT=image%2Fpng&TRANSPARENT=true&LAYERS='||RTRIM(TRIM(layername), '.')||'&STYLES=&SRS=EPSG%3A2056&CRS=EPSG%3A2056&DPI=96&WIDTH=1200&HEIGHT=1146&BBOX=2591250%2C1211350%2C2646050%2C1263700' AS verweiswms,
            '${wmsHost}/wms/oereb?SERVICE=WMS&VERSION=1.3.0&REQUEST=GetLegendGraphics&FORMAT=image/png&LAYER='||RTRIM(TRIM(layername), '.') AS legendeimweb
        FROM
        (
            SELECT
                DISTINCT ON (thema)
                thema,
                CASE
                    WHEN artcodeliste ILIKE '%Typ_geschuetztes_Geotop_Flaeche%'
                        THEN 'Flaeche'
                    WHEN artcodeliste ILIKE '%Typ_geschuetztes_Geotop_Punkt%'
                        THEN 'Punkt'
                END AS geometrietyp,
                weiteresthema AS layername
            FROM
                afu_geotope_oereb.transferstruktur_eigentumsbeschraenkung AS eigentumsbeschraenkung
        ) AS eigentumsbeschraenkung,
        (
            SELECT
                basket.t_id AS basket_t_id,
                dataset.datasetname AS datasetname
            FROM
                afu_geotope_oereb.t_ili2db_dataset AS dataset
                LEFT JOIN afu_geotope_oereb.t_ili2db_basket AS basket
                ON basket.dataset = dataset.t_id
            WHERE
                dataset.datasetname = 'ch.so.afu.geotop'
        ) AS basket_dataset
    RETURNING *
)
INSERT INTO
    afu_geotope_oereb.transferstruktur_legendeeintrag
    (
        t_basket,
        t_datasetname,
        t_seq,
        symbol,
        legendetext_de,
        artcode,
        artcodeliste,
        thema,
        subthema,
        weiteresthema,
        transfrstrkstllngsdnst_legende
    )
    SELECT
        DISTINCT ON (geometrietyp)
        eigentumsbeschraenkung.t_basket,
        eigentumsbeschraenkung.t_datasetname,
        eigentumsbeschraenkung.t_seq,
        eigentumsbeschraenkung.symbol,
        eigentumsbeschraenkung.legendetext_de,
        eigentumsbeschraenkung.artcode,
        eigentumsbeschraenkung.artcodeliste,
        eigentumsbeschraenkung.thema,
        eigentumsbeschraenkung.subthema,
        eigentumsbeschraenkung.weiteresthema,
        transferstruktur_darstellungsdienst.t_id
    FROM
    (
        SELECT
            DISTINCT ON (geometrietyp)
            eigentumsbeschraenkung.t_basket,
            eigentumsbeschraenkung.t_datasetname,
            0::int AS t_seq,
            decode('iVBORw0KGgoAAAANSUhEUgAAAEYAAAAjCAYAAAApF3xtAAAABHNCSVQICAgIfAhkiAAAAAlwSFlzAAAD8AAAA/AB2OVKxAAAABl0RVh0U29mdHdhcmUAd3d3Lmlua3NjYXBlLm9yZ5vuPBoAAAOoSURBVGiB7ZpfaM1hGMc/PzvGjFLDzGwixVD+xOnsQmOrlcTGldquFq2RzJ+yG5KUpYw0t65WxtXcUGwXXJhIys1xQZSNkWSOzUp6XDzO3vM6e4/fjB3yfuvtfd7v+zzv+zvfnvfP+Z0TCAgeaZiS7Qf4W+GFcSBitYqKIBbL0qNkGffuwevXpi0go6WmRv5b1NRIqhZ+KTnghXHAC+OAF8YBL4wDXhgH3MK8fAnr19tlwwbYtg3a2+HzZ+P76JHxOXvWHqe2VvnNmw0XiylXWQmJhO1//rwZ6+pV5To6DHfxou3/4QNs2qR9Gzcqd+uW8T9xwvY/dsz0dXe7lXHeY+Jx61xPK2VlIm/fqm9Pj+H37bPvB4sWKZ+fb7ggMP4tLYZ//lwkL8/0tbUp39pquPx8kb4+E9PcbPqmTVNuaEikoEC5mTNFEgnlBwc1HkTmzhUZHp7gPWbFCmhthePHYdky5eJxaGkJFZ4R587Bs2dqHzliZ+JYGBoy88bj6RkEMGMGNDaq/ekTXLmidmenxgM0NUFennueUBmzc6fhX70SiUSULymZeMaASG2tPUamjAGN7+0Vqa62+WTGiIj094vk5ipfXq5cNKrt6dNF3ryxn3PCN9+iIi0A79+PO9xCEGjd1QV1dTaXKUYEduyAmzfdMQsWwK5davf2wuXLcP++tuvrYd68jNP82qk05TcdZsuX6wYMMDCg4yaXgAtNTSrEwIC2q6thyZKxfQ8eNPbu3VoHgc07kP3juq0NcnLUbmiAdesy+0ejJrsikfRTMBVr1hjhh4e13rJF98yfIPvCrF4Ne/dCaSmcOhUu5vRpKC6Gw4dh1arMvj9mx6FDoaaI/NxlEnDhgpawWLgQ+vrC+W7dCrNm6X1pzhyoqgoV9msZkzzykntNbq7p+/LF9k22U30mE0GgSw5g6tTQYeMX5to1ePdO7dJSrRcvNifDnTswMqL248fmrdjSpeOeKpsIt5R6evQKnUjA06eGT+70xcW6qV2/Dk+eQFkZrFwJt2/r0QqwZ89vfvQ/i3DCDA7Cw4emnZOjG9+BA4a7dEm/Rz14AC9eaAHNpP37jYj/CNzCzJ+vXwNSEQTKV1VplqSisBDu3oUbNzRTPn5Un+3bYe1a2/fMGfj6dexLVixm5q2o0Lqy0nDRaHrM0aN62XTtYydP6r44e7bz46bBvwz/Dv8yPBy8MA54YRzwwjjghXEgsP4G4n+7Hm3awniMwi8lB7wwDnwD/bFRBvNxDWsAAAAASUVORK5CYII=', 'base64') AS symbol,
            eigentumsbeschraenkung.aussage_de AS legendetext_de,
            eigentumsbeschraenkung.artcode,
            eigentumsbeschraenkung.artcodeliste,
            eigentumsbeschraenkung.thema,
            eigentumsbeschraenkung.subthema,
            eigentumsbeschraenkung.weiteresthema,
            CASE
                WHEN artcodeliste ILIKE '%Typ_geschuetztes_Geotop_Punkt%'
                    THEN 'Punkt'
                WHEN artcodeliste ILIKE '%Typ_geschuetztes_Geotop_Flaeche%'
                    THEN 'Flaeche'
            END AS geometrietyp,
            weiteresthema AS layername
        FROM
            afu_geotope_oereb.transferstruktur_eigentumsbeschraenkung AS eigentumsbeschraenkung
    ) AS eigentumsbeschraenkung
    LEFT JOIN transferstruktur_darstellungsdienst
    ON transferstruktur_darstellungsdienst.verweiswms ILIKE '%'||RTRIM(eigentumsbeschraenkung.layername||'.'||eigentumsbeschraenkung.geometrietyp, '.')||'%'
;

UPDATE
    afu_geotope_oereb.transferstruktur_eigentumsbeschraenkung
SET
    darstellungsdienst =
    (
        SELECT
            t_id
        FROM
            afu_geotope_oereb.transferstruktur_darstellungsdienst
        WHERE
            verweiswms ILIKE '%ch.SO.Einzelschutz%'
    )
WHERE
    t_id IN
    (
        SELECT
            DISTINCT ON (geometrie.eigentumsbeschraenkung)
            geometrie.eigentumsbeschraenkung
        FROM
            afu_geotope_oereb.transferstruktur_geometrie AS geometrie
        WHERE
            thema = 'WeiteresThema'
        AND
            weiteresthema = 'ch.SO.Einzelschutz'
        AND
            aussage_de = 'Geotope'
    )
;


/*
 * Hinweise auf die gesetzlichen Grundlagen.
 * 
 * (1) Momentan nur auf die kantonalen Gesetze und Verordnungen, da
 * die Bundesgesetze und -verordnungen nicht importiert wurden.
 * 
 * (2) Ebenfalls gut prüfen.
 */

WITH vorschriften_dokument_gesetze AS (
  SELECT
    t_id AS hinweis
  FROM
    afu_geotope_oereb.vorschriften_dokument
 WHERE
   t_ili_tid IN ('ch.so.sk.bgs.435.141', 'ch.so.sk.bgs.711.1', 'ch.so.sk.bgs.711.61')
)
INSERT INTO afu_geotope_oereb.vorschriften_hinweisweiteredokumente (
 t_basket,
 t_datasetname,
 ursprung,
 hinweis
)
SELECT
  vorschriften_dokument.t_basket,
  vorschriften_dokument.t_datasetname,
  vorschriften_dokument.t_id,
  vorschriften_dokument_gesetze.hinweis
FROM
  afu_geotope_oereb.vorschriften_dokument AS vorschriften_dokument
  LEFT JOIN vorschriften_dokument_gesetze
  ON 1=1
WHERE
  t_type = 'vorschriften_rechtsvorschrift'
AND
  vorschriften_dokument.t_datasetname = 'ch.so.afu.geotop'
;

/*
 * Updaten der Staatskanzlei-TID.
 * 
 * Weil im Vorschriftenmodell die Rolle in der Dokumenten-Amt-Beziehung nicht
 * EXTERNAL ist, taucht jetzt die Staatskanzlei mehrfach auf. Einmal bei den
 * Gesetzen und dann wohl bei jedem Thema bei den RRB. Applikatorisch ist
 * das soweit kein Beinbruch, schmerzt aber trotzdem, da man die Daten
 * nicht mehr komplett auf Modellkonformität prüfen kann (Bundesgesetze + 
 * kantonale Gesetze + Daten). In diesem Fall gibt es die TID "ch.so.sk" 
 * mehrfach. Aus diesem Grund muss bei den Daten die TID der Staatskanzlei
 * jeweils verändert werden. Erst jedoch ganz am Schluss, damit mit beim
 * Datenumbau selber immer nur auf "ch.so.sk" verweisen kann.
 * 
 * Weil die zuständigen Stellen wie auch die Gesetze bei jedem Umbau
 * wieder neu importiert werden, muss die t_ili_tid nicht mehr zurück
 * gesetzt werden.
 */ 

UPDATE
    afu_geotope_oereb.vorschriften_amt
SET
    t_ili_tid = 'ch.so.sk.'||uuid_generate_v4()
WHERE
    t_datasetname = 'ch.so.afu.geotop'
AND
    t_ili_tid = 'ch.so.sk'
;
