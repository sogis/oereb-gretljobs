/*
 * Die korrekte Reihenfolge der Queries ist zwingend. 
 * 
 * Allg. Überlegungen/Bemerkungen zum Datenumbau finden sich im SQL-Skript
 * sogis/oereb-gretljobs/oereb_nutzungsplanung/insert_oereb_landuseplans_tables.sql.
 */

WITH dokumente AS 
(
    SELECT
        typ_dokument.festlegung
    FROM
      awjf_statische_waldgrenze.geobasisdaten_typ_dokument AS typ_dokument
      LEFT JOIN awjf_statische_waldgrenze.dokumente_dokument AS dokument
          ON typ_dokument.dokumente = dokument.t_id
    WHERE
        typ <> 'Bericht'
    AND
        rechtsstatus = 'inKraft'
    AND
        datum_archivierung IS NULL
    
)  
INSERT INTO 
    awjf_statische_waldgrenzen_oereb.transferstruktur_eigentumsbeschraenkung
    (
        t_id,
        t_basket,
        t_datasetname,
        aussage_de,
        thema,
        artcode,
        artcodeliste,
        rechtsstatus,
        publiziertab,
        zustaendigestelle
    )
SELECT
        DISTINCT ON (waldgrenze.t_id)
        waldgrenze.t_id,
        basket_dataset.basket_t_id,
        basket_dataset.datasetname,
        --geobasisdaten_typ.bezeichnung AS aussage_de,
        'Waldgrenzen' AS aussage_de,
        'Waldgrenzen' AS thema,
        'Waldgrenzen' AS artcode,
        'urn:fdc:ilismeta.interlis.ch:2017:Typ_Kanton_Waldgrenzen' AS artcodeliste,
        waldgrenze.rechtsstatus,
        waldgrenze.publiziert_ab AS publiziertab, 
        amt.t_id AS zustaendigestelle
    FROM
        awjf_statische_waldgrenze.geobasisdaten_waldgrenze_linie AS waldgrenze
        INNER JOIN awjf_statische_waldgrenze.geobasisdaten_typ AS geobasisdaten_typ
            ON waldgrenze.waldgrenze_typ = geobasisdaten_typ.t_id
        INNER JOIN dokumente
            ON dokumente.festlegung = waldgrenze.waldgrenze_typ
        LEFT JOIN awjf_statische_waldgrenzen_oereb.vorschriften_amt AS amt
            ON amt.t_ili_tid = 'ch.so.awjf',
        (
            SELECT
                basket.t_id AS basket_t_id,
                dataset.datasetname AS datasetname               
            FROM
                awjf_statische_waldgrenzen_oereb.t_ili2db_dataset AS dataset
                LEFT JOIN awjf_statische_waldgrenzen_oereb.t_ili2db_basket AS basket
                ON basket.dataset = dataset.t_id
            WHERE
                dataset.datasetname = 'ch.so.awjf.waldgrenzen'
        ) AS basket_dataset
    WHERE
        waldgrenze.rechtsstatus = 'inKraft'
    AND
        waldgrenze.datum_archivierung IS NULL
    AND 
        geobasisdaten_typ.verbindlichkeit = 'Nutzungsplanfestlegung'
;

/*
 * Dokumente
 */

INSERT INTO
     awjf_statische_waldgrenzen_oereb.transferstruktur_hinweisvorschrift
     (
--         t_id,
         t_basket,
         t_datasetname,
         eigentumsbeschraenkung,
         vorschrift_vorschriften_dokument  
     )
     SELECT
--         t_id, 
         basket_t_id,
         datasetname,
         waldgrenze.t_id AS eigentumsbeschraenkung,
         typ_dokument.dokumente AS vorschrift_vorschriften_dokument
      FROM
         awjf_statische_waldgrenze.geobasisdaten_typ_dokument AS typ_dokument
         LEFT JOIN awjf_statische_waldgrenze.geobasisdaten_waldgrenze_linie AS waldgrenze
         ON typ_dokument.festlegung = waldgrenze.waldgrenze_typ
         INNER JOIN awjf_statische_waldgrenze.dokumente_dokument AS dokument
         ON dokument.t_id = typ_dokument.dokumente,
     (
         SELECT
             basket.t_id AS basket_t_id,
             dataset.datasetname AS datasetname               
         FROM
             awjf_statische_waldgrenzen_oereb.t_ili2db_dataset AS dataset
             LEFT JOIN awjf_statische_waldgrenzen_oereb.t_ili2db_basket AS basket
             ON basket.dataset = dataset.t_id
         WHERE
            dataset.datasetname = 'ch.so.awjf.waldgrenzen' 
     ) AS basket_dataset
     WHERE
        typ <> 'Bericht'
    AND
        dokument.rechtsstatus = 'inKraft'
    AND
        dokument.datum_archivierung IS NULL
;

INSERT INTO 
    awjf_statische_waldgrenzen_oereb.vorschriften_dokument
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
            WHEN typ = 'RRB'
                THEN 'vorschriften_rechtsvorschrift'
            ELSE 'vorschriften_dokument'
        END AS t_type,
        '_'||SUBSTRING(REPLACE(CAST(dokument.t_id AS text), '-', ''),1,15) AS t_ili_tid,        
        dokument.offiziellertitel AS titel_de,
        dokument.offiziellertitel AS offizellertitel_de,
        dokument.abkuerzung AS abkuerzung_de,
        dokument.offiziellenr AS offiziellenr,
        dokument.kanton AS kanton,
        dokument.gemeinde AS gemeinde,
        dokument.rechtsstatus AS rechtsstatus,
        dokument.publiziert_ab AS publiziertab,
        amt.t_id AS zustaendigestelle
    FROM
        awjf_statische_waldgrenze.dokumente_dokument AS dokument,
        (
            SELECT
                basket.t_id AS basket_t_id,
                dataset.datasetname AS datasetname           
            FROM
                awjf_statische_waldgrenzen_oereb.t_ili2db_dataset AS dataset
                LEFT JOIN awjf_statische_waldgrenzen_oereb.t_ili2db_basket AS basket
                ON basket.dataset = dataset.t_id
            WHERE
                dataset.datasetname = 'ch.so.awjf.waldgrenzen' 
        ) AS basket_dataset
        LEFT JOIN awjf_statische_waldgrenzen_oereb.vorschriften_amt AS amt
        ON amt.t_ili_tid = 'ch.so.awjf'
            
     WHERE
        typ <> 'Bericht'
    AND
        rechtsstatus = 'inKraft'
    AND
        datum_archivierung IS NULL
;

/*
 * Datenumbau der Links auf die Dokumente, die im Rahmenmodell 'multilingual' sind und daher eher
 * mühsam normalisert sind.
 */

WITH multilingualuri AS
(
    INSERT INTO
        awjf_statische_waldgrenzen_oereb.multilingualuri
        (
            t_id,
            t_basket,
            t_datasetname,
            t_seq,
            vorschriften_dokument_textimweb
        )
    SELECT
        nextval('awjf_statische_waldgrenzen_oereb.t_ili2db_seq'::regclass) AS t_id,
        basket_dataset.basket_t_id,
        basket_dataset.datasetname,
        0 AS t_seq,
        vorschriften_dokument.t_id AS vorschriften_dokument_textimweb
    FROM
        awjf_statische_waldgrenzen_oereb.vorschriften_dokument AS vorschriften_dokument,
        (
            SELECT
                basket.t_id AS basket_t_id,
                dataset.datasetname AS datasetname               
            FROM
                awjf_statische_waldgrenzen_oereb.t_ili2db_dataset AS dataset
                LEFT JOIN awjf_statische_waldgrenzen_oereb.t_ili2db_basket AS basket
                ON basket.dataset = dataset.t_id
            WHERE
                dataset.datasetname = 'ch.so.awjf.waldgrenzen' 
        ) AS basket_dataset
    WHERE
        vorschriften_dokument.t_datasetname = 'ch.so.awjf.waldgrenzen'
    RETURNING *
)
,
localiseduri AS 
(
    SELECT 
        nextval('awjf_statische_waldgrenzen_oereb.t_ili2db_seq'::regclass) AS t_id,
        basket_dataset.basket_t_id,
        basket_dataset.datasetname,
        0 AS t_seq,
        'de' AS alanguage,
        rechtsvorschrften_dokument.text_im_web AS atext,
        multilingualuri.t_id AS multilingualuri_localisedtext
    FROM
        awjf_statische_waldgrenze.dokumente_dokument AS rechtsvorschrften_dokument
        RIGHT JOIN multilingualuri 
        ON multilingualuri.vorschriften_dokument_textimweb = rechtsvorschrften_dokument.t_id,
        (
            SELECT
                basket.t_id AS basket_t_id,
                dataset.datasetname AS datasetname               
            FROM
                awjf_statische_waldgrenzen_oereb.t_ili2db_dataset AS dataset
                LEFT JOIN awjf_statische_waldgrenzen_oereb.t_ili2db_basket AS basket
                ON basket.dataset = dataset.t_id
            WHERE
                dataset.datasetname = 'ch.so.awjf.waldgrenzen'                 
        ) AS basket_dataset
)
INSERT INTO
    awjf_statische_waldgrenzen_oereb.localiseduri
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

INSERT INTO
    awjf_statische_waldgrenzen_oereb.transferstruktur_geometrie
    ( 
        t_basket,
        t_datasetname,
        linie_lv95,
        rechtsstatus,
        publiziertab,
        eigentumsbeschraenkung,
        zustaendigestelle
    )
        SELECT
            basket_dataset.basket_t_id AS t_basket,
            basket_dataset.datasetname AS t_datasetname,
            ST_MakeValid(ST_RemoveRepeatedPoints(ST_SnapToGrid(waldgrenze.geometrie, 0.001))) AS linie_lv95,
            waldgrenze.rechtsstatus,
            waldgrenze.publiziert_ab AS publiziertab,
            eigentumsbeschraenkung.t_id AS eigentumsbeschraenkung,
            eigentumsbeschraenkung.zustaendigestelle AS zustaendigestelle
        FROM
            awjf_statische_waldgrenze.geobasisdaten_waldgrenze_linie AS waldgrenze

        INNER JOIN awjf_statische_waldgrenzen_oereb.transferstruktur_eigentumsbeschraenkung AS eigentumsbeschraenkung
        ON waldgrenze.t_id = eigentumsbeschraenkung.t_id,
         (
             SELECT
                 basket.t_id AS basket_t_id,
                 dataset.datasetname AS datasetname               
             FROM
                 awjf_statische_waldgrenzen_oereb.t_ili2db_dataset AS dataset
                 LEFT JOIN awjf_statische_waldgrenzen_oereb.t_ili2db_basket AS basket
                 ON basket.dataset = dataset.t_id
             WHERE
                 dataset.datasetname = 'ch.so.awjf.waldgrenzen'
         ) AS basket_dataset
             WHERE
            waldgrenze.rechtsstatus = 'inKraft'
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
        awjf_statische_waldgrenzen_oereb.transferstruktur_darstellungsdienst 
        (
            t_basket,
            t_datasetname,
            verweiswms,
            legendeimweb
        )
        SELECT
            basket_dataset.basket_t_id AS t_basket,
            basket_dataset.datasetname AS t_datasetname,
            '${wmsHost}/wms/oereb?SERVICE=WMS&VERSION=1.3.0&REQUEST=GetMap&FORMAT=image%2Fpng&TRANSPARENT=true&LAYERS='||RTRIM(TRIM((layername)), '.')||'&STYLES=&SRS=EPSG%3A2056&CRS=EPSG%3A2056&DPI=96&WIDTH=1200&HEIGHT=1146&BBOX=2591250%2C1211350%2C2646050%2C1263700' AS verweiswms,
            '${wmsHost}/wms/oereb?SERVICE=WMS&VERSION=1.3.0&REQUEST=GetLegendGraphics&FORMAT=image/png&LAYER='||RTRIM(TRIM((layername)), '.') AS legendeimweb
        FROM
        (
            SELECT 
                DISTINCT ON (thema, geometrietyp)
                thema,
                subthema,
                'Linie' AS geometrietyp,
                'ch.SO.'||thema AS layername
            FROM
                awjf_statische_waldgrenzen_oereb.transferstruktur_eigentumsbeschraenkung AS eigentumsbeschraenkung 
        ) AS eigentumsbeschraenkung,
        (
            SELECT
                basket.t_id AS basket_t_id,
                dataset.datasetname AS datasetname               
            FROM
                awjf_statische_waldgrenzen_oereb.t_ili2db_dataset AS dataset
                LEFT JOIN awjf_statische_waldgrenzen_oereb.t_ili2db_basket AS basket
                ON basket.dataset = dataset.t_id
            WHERE
                dataset.datasetname = 'ch.so.awjf.waldgrenzen' 
        ) AS basket_dataset
    RETURNING *
)
INSERT INTO 
    awjf_statische_waldgrenzen_oereb.transferstruktur_legendeeintrag
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
        transfrstrkstllngsdnst_legende
    )
    SELECT
        DISTINCT ON (artcode, artcodeliste)
        eigentumsbeschraenkung.t_basket,
        eigentumsbeschraenkung.t_datasetname,
        eigentumsbeschraenkung.t_seq,        
        eigentumsbeschraenkung.symbol,
        eigentumsbeschraenkung.legendetext_de,
        eigentumsbeschraenkung.artcode,
        eigentumsbeschraenkung.artcodeliste,
        eigentumsbeschraenkung.thema,
        eigentumsbeschraenkung.subthema,
        transferstruktur_darstellungsdienst.t_id
    FROM
    (
        SELECT
            DISTINCT ON (artcode, artcodeliste)
            eigentumsbeschraenkung.t_basket,
            eigentumsbeschraenkung.t_datasetname,
            0::int AS t_seq,        
            decode('iVBORw0KGgoAAAANSUhEUgAAAEYAAAAjCAYAAAApF3xtAAAABHNCSVQICAgIfAhkiAAAAAlwSFlzAAAD8AAAA/AB2OVKxAAAABl0RVh0U29mdHdhcmUAd3d3Lmlua3NjYXBlLm9yZ5vuPBoAAAOoSURBVGiB7ZpfaM1hGMc/PzvGjFLDzGwixVD+xOnsQmOrlcTGldquFq2RzJ+yG5KUpYw0t65WxtXcUGwXXJhIys1xQZSNkWSOzUp6XDzO3vM6e4/fjB3yfuvtfd7v+zzv+zvfnvfP+Z0TCAgeaZiS7Qf4W+GFcSBitYqKIBbL0qNkGffuwevXpi0go6WmRv5b1NRIqhZ+KTnghXHAC+OAF8YBL4wDXhgH3MK8fAnr19tlwwbYtg3a2+HzZ+P76JHxOXvWHqe2VvnNmw0XiylXWQmJhO1//rwZ6+pV5To6DHfxou3/4QNs2qR9Gzcqd+uW8T9xwvY/dsz0dXe7lXHeY+Jx61xPK2VlIm/fqm9Pj+H37bPvB4sWKZ+fb7ggMP4tLYZ//lwkL8/0tbUp39pquPx8kb4+E9PcbPqmTVNuaEikoEC5mTNFEgnlBwc1HkTmzhUZHp7gPWbFCmhthePHYdky5eJxaGkJFZ4R587Bs2dqHzliZ+JYGBoy88bj6RkEMGMGNDaq/ekTXLmidmenxgM0NUFennueUBmzc6fhX70SiUSULymZeMaASG2tPUamjAGN7+0Vqa62+WTGiIj094vk5ipfXq5cNKrt6dNF3ryxn3PCN9+iIi0A79+PO9xCEGjd1QV1dTaXKUYEduyAmzfdMQsWwK5davf2wuXLcP++tuvrYd68jNP82qk05TcdZsuX6wYMMDCg4yaXgAtNTSrEwIC2q6thyZKxfQ8eNPbu3VoHgc07kP3juq0NcnLUbmiAdesy+0ejJrsikfRTMBVr1hjhh4e13rJF98yfIPvCrF4Ne/dCaSmcOhUu5vRpKC6Gw4dh1arMvj9mx6FDoaaI/NxlEnDhgpawWLgQ+vrC+W7dCrNm6X1pzhyoqgoV9msZkzzykntNbq7p+/LF9k22U30mE0GgSw5g6tTQYeMX5to1ePdO7dJSrRcvNifDnTswMqL248fmrdjSpeOeKpsIt5R6evQKnUjA06eGT+70xcW6qV2/Dk+eQFkZrFwJt2/r0QqwZ89vfvQ/i3DCDA7Cw4emnZOjG9+BA4a7dEm/Rz14AC9eaAHNpP37jYj/CNzCzJ+vXwNSEQTKV1VplqSisBDu3oUbNzRTPn5Un+3bYe1a2/fMGfj6dexLVixm5q2o0Lqy0nDRaHrM0aN62XTtYydP6r44e7bz46bBvwz/Dv8yPBy8MA54YRzwwjjghXEgsP4G4n+7Hm3awniMwi8lB7wwDnwD/bFRBvNxDWsAAAAASUVORK5CYII=', 'base64') AS symbol,
            eigentumsbeschraenkung.aussage_de AS legendetext_de,
            eigentumsbeschraenkung.artcode,
            eigentumsbeschraenkung.artcodeliste,
            eigentumsbeschraenkung.thema,
            eigentumsbeschraenkung.subthema,
            'Linie' AS geometrietyp,
            'ch.SO.'||thema AS layername
        FROM
            awjf_statische_waldgrenzen_oereb.transferstruktur_eigentumsbeschraenkung AS eigentumsbeschraenkung 
    ) AS eigentumsbeschraenkung
    LEFT JOIN transferstruktur_darstellungsdienst
    ON transferstruktur_darstellungsdienst.verweiswms ILIKE '%'||RTRIM(eigentumsbeschraenkung.layername, '.')||'%'
;

UPDATE 
    awjf_statische_waldgrenzen_oereb.transferstruktur_eigentumsbeschraenkung
SET 
    darstellungsdienst = (SELECT t_id FROM awjf_statische_waldgrenzen_oereb.transferstruktur_darstellungsdienst WHERE verweiswms ILIKE '%Waldgrenzen%')
WHERE
    thema = 'Waldgrenzen'
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
    awjf_statische_waldgrenzen_oereb.vorschriften_dokument
  WHERE
    t_ili_tid IN ('ch.admin.bk.sr.921.0', 'ch.admin.bk.sr.921.01', 'ch.so.sk.931.11', 'ch.so.sk.931.12', 'ch.so.sk.931.72') 
)
INSERT INTO awjf_statische_waldgrenzen_oereb.vorschriften_hinweisweiteredokumente (
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
  awjf_statische_waldgrenzen_oereb.vorschriften_dokument AS vorschriften_dokument
  LEFT JOIN vorschriften_dokument_gesetze
  ON 1=1
WHERE
  t_type = 'vorschriften_rechtsvorschrift'
AND
  vorschriften_dokument.t_datasetname = 'ch.so.awjf.waldgrenzen'
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
    awjf_statische_waldgrenzen_oereb.vorschriften_amt
SET
    t_ili_tid = 'ch.so.sk.'||uuid_generate_v4()
WHERE
    t_datasetname = 'ch.so.awjf.waldgrenzen'
AND
    t_ili_tid = 'ch.so.sk'
;

