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
    ada_denkmalschutz_oereb.transferstruktur_eigentumsbeschraenkung
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
    SELECT
        DISTINCT ON (denkmal.id)
        denkmal.id,
        basket_dataset.basket_t_id,
        basket_dataset.datasetname,
        'geschütztes historisches Kulturdenkmal' AS aussage_de,
        'WeiteresThema' AS thema,
        'ch.SO.Einzelschutz' AS weiteresthema,
        CASE
            WHEN schutzdurchgemeinde IS TRUE
                THEN 'kommunal'
            ELSE 'kantonal'
        END AS artcode,
        CASE
            WHEN gis_geometrie.punkt IS NOT NULL AND gis_geometrie.apolygon IS NULL
                THEN 'urn:fdc:ilismeta.interlis.ch:2019:Typ_geschuetztes_historisches_Kulturdenkmal_Punkt'
            WHEN gis_geometrie.apolygon IS NOT NULL AND gis_geometrie.punkt IS NULL
                THEN 'urn:fdc:ilismeta.interlis.ch:2019:Typ_geschuetztes_historisches_Kulturdenkmal_Flaeche'
        END AS artcodeliste,
        'inKraft' AS rechtsstatus,
        rechtsvorschrift_link.datum AS publiziertab,
        amt.t_id AS zustaendigestelle
    FROM
        ada_denkmalschutz.fachapplikation_denkmal AS denkmal
        LEFT JOIN ada_denkmalschutz_oereb.vorschriften_amt AS amt
        ON amt.t_ili_tid = 'ch.so.ada'
        INNER JOIN ada_denkmalschutz.gis_geometrie AS gis_geometrie
        ON denkmal.id = gis_geometrie.denkmal_id
        AND
        ((gis_geometrie.punkt IS NOT NULL AND gis_geometrie.apolygon IS NULL)
         OR
        (gis_geometrie.punkt IS NULL AND gis_geometrie.apolygon IS NOT NULL))
        LEFT JOIN ada_denkmalschutz.fachapplikation_rechtsvorschrift_link AS rechtsvorschrift_link
        ON denkmal.id = rechtsvorschrift_link.denkmal_id,
        (
            SELECT
                basket.t_id AS basket_t_id,
                dataset.datasetname AS datasetname               
            FROM
                ada_denkmalschutz_oereb.t_ili2db_dataset AS dataset
                LEFT JOIN ada_denkmalschutz_oereb.t_ili2db_basket AS basket
                ON basket.dataset = dataset.t_id
            WHERE
                dataset.datasetname = 'ch.so.ada.denkmalschutz'
        ) AS basket_dataset
    WHERE
        rechtsvorschrift_link.datum IS NOT NULL
    AND
        denkmal.schutzstufe_code = 'geschuetzt'
;

/*
 * Dokumente
 */
 
INSERT INTO 
    ada_denkmalschutz_oereb.vorschriften_dokument
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
        'vorschriften_rechtsvorschrift' AS t_type,
        '_'||SUBSTRING(REPLACE(CAST(dokument.t_id AS text), '-', ''),1,15) AS t_ili_tid,       
        CASE
            WHEN schutzdurchgemeinde IS TRUE
                THEN 'Gemeinderatsbeschluss'
            ELSE 'Regierungsratsbeschluss'
        END AS titel_de,
        replace(dokument.titel, CHR(10), ' ') AS offizellertitel_de,
        CASE
            WHEN schutzdurchgemeinde IS TRUE
                THEN 'GRB'
            ELSE 'RRB'
        END AS abkuerzung_de,
        dokument.nummer AS offiziellenr,
        'SO' AS kanton,
        CASE
            WHEN schutzdurchgemeinde IS TRUE
                THEN dokument.bfsnummer
            ELSE NULL
        END AS gemeinde,
        'inKraft' AS rechtsstatus,
        dokument.datum AS publiziertab,
        amt.t_id AS zustaendigestelle

    FROM
        ada_denkmalschutz.fachapplikation_rechtsvorschrift_link AS dokument
        LEFT JOIN ada_denkmalschutz.fachapplikation_denkmal AS denkmal
        ON denkmal.id = dokument.denkmal_id
        LEFT JOIN ada_denkmalschutz_oereb.vorschriften_amt AS amt
        ON amt.t_ili_tid = 'ch.so.ada',
        (
            SELECT
                basket.t_id AS basket_t_id,
                dataset.datasetname AS datasetname           
            FROM
                ada_denkmalschutz_oereb.t_ili2db_dataset AS dataset
                LEFT JOIN ada_denkmalschutz_oereb.t_ili2db_basket AS basket
                ON basket.dataset = dataset.t_id
            WHERE
                dataset.datasetname = 'ch.so.ada.denkmalschutz' 
            ) AS basket_dataset
    WHERE
        dokument.datum IS NOT NULL
    AND
        denkmal.schutzstufe_code = 'geschuetzt'
;
INSERT INTO
     ada_denkmalschutz_oereb.transferstruktur_hinweisvorschrift
     (
         t_basket,
         t_datasetname,
         eigentumsbeschraenkung,
         vorschrift_vorschriften_dokument  
     )
     SELECT
         basket_t_id,
         datasetname,
         eigentumsbeschraenkung.t_id AS eigentumsbeschraenkung,
         typ_dokument.t_id AS vorschrift_vorschriften_dokument
      FROM
         ada_denkmalschutz.fachapplikation_rechtsvorschrift_link AS typ_dokument
         INNER JOIN ada_denkmalschutz_oereb.transferstruktur_eigentumsbeschraenkung AS eigentumsbeschraenkung
         ON typ_dokument.denkmal_id = eigentumsbeschraenkung.t_id,
        (
         SELECT
             basket.t_id AS basket_t_id,
             dataset.datasetname AS datasetname               
         FROM
             ada_denkmalschutz_oereb.t_ili2db_dataset AS dataset
             LEFT JOIN ada_denkmalschutz_oereb.t_ili2db_basket AS basket
             ON basket.dataset = dataset.t_id
         WHERE
            dataset.datasetname = 'ch.so.ada.denkmalschutz' 
        ) AS basket_dataset
     WHERE
        typ_dokument.datum IS NOT NULL
--     AND
--         denkmal.schutzstufe_code = 'geschuetzt'
;

/*
 * Datenumbau der Links auf die Dokumente, die im Rahmenmodell 'multilingual' sind und daher eher
 * mühsam normalisert sind.
 */

WITH multilingualuri AS
(
    INSERT INTO
        ada_denkmalschutz_oereb.multilingualuri
        (
            t_id,
            t_basket,
            t_datasetname,
            t_seq,
            vorschriften_dokument_textimweb
        )
    SELECT
        nextval('ada_denkmalschutz_oereb.t_ili2db_seq'::regclass) AS t_id,
        basket_dataset.basket_t_id,
        basket_dataset.datasetname,
        0 AS t_seq,
        vorschriften_dokument.t_id AS vorschriften_dokument_textimweb
    FROM
        ada_denkmalschutz_oereb.vorschriften_dokument AS vorschriften_dokument,
        (
            SELECT
                basket.t_id AS basket_t_id,
                dataset.datasetname AS datasetname               
            FROM
                ada_denkmalschutz_oereb.t_ili2db_dataset AS dataset
                LEFT JOIN ada_denkmalschutz_oereb.t_ili2db_basket AS basket
                ON basket.dataset = dataset.t_id
            WHERE
                dataset.datasetname = 'ch.so.ada.denkmalschutz' 
        ) AS basket_dataset
    WHERE
        vorschriften_dokument.t_datasetname = 'ch.so.ada.denkmalschutz'
    RETURNING *
)
,
localiseduri AS 
(
    SELECT 
        nextval('ada_denkmalschutz_oereb.t_ili2db_seq'::regclass) AS t_id,
        basket_dataset.basket_t_id,
        basket_dataset.datasetname,
        0 AS t_seq,
        'de' AS alanguage,
        CASE
            WHEN rechtsvorschrften_dokument.multimedia_link IS NULL
                THEN 'https://artplus.verw.rootso.org/MpWeb-apSolothurnDenkmal/download/pdf_404.pdf'
            ELSE rechtsvorschrften_dokument.multimedia_link
        END AS atext,
        multilingualuri.t_id AS multilingualuri_localisedtext
    FROM
        ada_denkmalschutz.fachapplikation_rechtsvorschrift_link AS rechtsvorschrften_dokument
        RIGHT JOIN multilingualuri 
        ON multilingualuri.vorschriften_dokument_textimweb = rechtsvorschrften_dokument.t_id,
        (
            SELECT
                basket.t_id AS basket_t_id,
                dataset.datasetname AS datasetname               
            FROM
                ada_denkmalschutz_oereb.t_ili2db_dataset AS dataset
                LEFT JOIN ada_denkmalschutz_oereb.t_ili2db_basket AS basket
                ON basket.dataset = dataset.t_id
            WHERE
                dataset.datasetname = 'ch.so.ada.denkmalschutz'                 
        ) AS basket_dataset
    WHERE
        rechtsvorschrften_dokument.datum IS NOT NULL
)
INSERT INTO
    ada_denkmalschutz_oereb.localiseduri
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
 * 
 * (1) Es gab Probleme beim zuweisen eines publiziertAb-Datums zu der Geometrie. Weil
 * ein solches in den Originaldaten im Fachsystem fehlt, wurde mit den Rechtsvorschriften
 * gejoined. Weil es aber mehrere Rechtsvorschriften zu einer Geometrie geben kann, gab 
 * es dann auch mehrere identische Geometrien für die gleiche Eigentumsbeschraenkung. 
 * Weil das nicht korrekt ist, wurde entschieden, dass für das publiziertAb-Datum der
 * Geometrie now() verwendet wird.
 */

INSERT INTO
    ada_denkmalschutz_oereb.transferstruktur_geometrie
    ( 
        t_basket,
        t_datasetname,
        punkt_lv95,
        flaeche_lv95,
        rechtsstatus,
        publiziertab,
        eigentumsbeschraenkung,
        zustaendigestelle
    )
    SELECT 
        basket_dataset.basket_t_id AS t_basket,
        basket_dataset.datasetname AS t_datasetname,
        CASE
            WHEN gis_geometrie.punkt IS NOT NULL
            THEN gis_geometrie.punkt
            ELSE NULL
        END AS punkt_lv95, 
        CASE
            WHEN gis_geometrie.apolygon IS NOT NULL
                 THEN ST_MakeValid(ST_RemoveRepeatedPoints(ST_SnapToGrid(gis_geometrie.apolygon, 0.001)))
            ELSE NULL
        END AS flaeche_lv95,
        'inKraft' AS rechtsstatus,
        CAST(now() AS date) AS publiziertab,
        eigentumsbeschraenkung.t_id AS eigentumsbeschraenkung,
        eigentumsbeschraenkung.zustaendigestelle AS zustaendigestelle
    FROM
        ada_denkmalschutz.gis_geometrie AS gis_geometrie
        INNER JOIN ada_denkmalschutz_oereb.transferstruktur_eigentumsbeschraenkung AS eigentumsbeschraenkung
        ON gis_geometrie.denkmal_id = eigentumsbeschraenkung.t_id,
         (
             SELECT
                 basket.t_id AS basket_t_id,
                 dataset.datasetname AS datasetname               
             FROM
                 ada_denkmalschutz_oereb.t_ili2db_dataset AS dataset
                 LEFT JOIN ada_denkmalschutz_oereb.t_ili2db_basket AS basket
                 ON basket.dataset = dataset.t_id
             WHERE
                 dataset.datasetname = 'ch.so.ada.denkmalschutz'
         ) AS basket_dataset
    WHERE
        ((gis_geometrie.punkt IS NOT NULL AND gis_geometrie.apolygon IS NULL)
         OR
        (gis_geometrie.punkt IS NULL AND gis_geometrie.apolygon IS NOT NULL))
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
        ada_denkmalschutz_oereb.transferstruktur_darstellungsdienst 
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
                subthema,
                CASE
                    WHEN geometrie.punkt_lv95 IS NOT NULL
                        THEN 'Punkt'
                    WHEN geometrie.flaeche_lv95 IS NOT NULL
                        THEN 'Flaeche'
                 END AS geometrietyp,
                 weiteresthema AS layername
            FROM
                ada_denkmalschutz_oereb.transferstruktur_eigentumsbeschraenkung AS eigentumsbeschraenkung
                LEFT JOIN ada_denkmalschutz_oereb.transferstruktur_geometrie AS geometrie
                ON eigentumsbeschraenkung.t_id = geometrie.eigentumsbeschraenkung
            WHERE
                ((geometrie.punkt_lv95 IS NOT NULL AND geometrie.flaeche_lv95 IS NULL)
                 OR
                (geometrie.punkt_lv95 IS NULL AND geometrie.flaeche_lv95 IS NOT NULL))
                
        ) AS eigentumsbeschraenkung,
        (
            SELECT
                basket.t_id AS basket_t_id,
                dataset.datasetname AS datasetname               
            FROM
                ada_denkmalschutz_oereb.t_ili2db_dataset AS dataset
                LEFT JOIN ada_denkmalschutz_oereb.t_ili2db_basket AS basket
                ON basket.dataset = dataset.t_id
            WHERE
                dataset.datasetname = 'ch.so.ada.denkmalschutz' 
        ) AS basket_dataset
    RETURNING *
)
INSERT INTO 
    ada_denkmalschutz_oereb.transferstruktur_legendeeintrag
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
                WHEN geometrie.punkt_lv95 IS NOT NULL
                    THEN 'Punkt'
                WHEN geometrie.flaeche_lv95 IS NOT NULL
                    THEN 'Flaeche'
             END AS geometrietyp,
             weiteresthema AS layername
        FROM
            ada_denkmalschutz_oereb.transferstruktur_eigentumsbeschraenkung AS eigentumsbeschraenkung
            LEFT JOIN ada_denkmalschutz_oereb.transferstruktur_geometrie AS geometrie
            ON eigentumsbeschraenkung.t_id = geometrie.eigentumsbeschraenkung
    ) AS eigentumsbeschraenkung
    LEFT JOIN transferstruktur_darstellungsdienst
    ON transferstruktur_darstellungsdienst.verweiswms ILIKE '%'||RTRIM(eigentumsbeschraenkung.layername, '.')||'%'
;

UPDATE
    ada_denkmalschutz_oereb.transferstruktur_eigentumsbeschraenkung
SET 
    darstellungsdienst =
    (
        SELECT
            t_id
        FROM
            ada_denkmalschutz_oereb.transferstruktur_darstellungsdienst
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
            ada_denkmalschutz_oereb.transferstruktur_geometrie AS geometrie
        WHERE
            thema = 'WeiteresThema'
        AND
            weiteresthema = 'ch.SO.Einzelschutz'
        AND
            aussage_de = 'geschütztes historisches Kulturdenkmal'
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
    ada_denkmalschutz_oereb.vorschriften_dokument
  WHERE
    t_ili_tid IN ('ch.so.sk.bgs.436.11', 'ch.so.sk.bgs.711.1', 'ch.so.sk.bgs.711.61') 
)
INSERT INTO ada_denkmalschutz_oereb.vorschriften_hinweisweiteredokumente (
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
  ada_denkmalschutz_oereb.vorschriften_dokument AS vorschriften_dokument
  LEFT JOIN vorschriften_dokument_gesetze
  ON 1=1
WHERE
    t_type = 'vorschriften_rechtsvorschrift'
AND
  vorschriften_dokument.t_datasetname = 'ch.so.ada.denkmalschutz'
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
    ada_denkmalschutz_oereb.vorschriften_amt
SET
    t_ili_tid = 'ch.so.sk.'||uuid_generate_v4()
WHERE
    t_datasetname = 'ch.so.ada.denkmalschutz'
AND
    t_ili_tid = 'ch.so.sk'
;
