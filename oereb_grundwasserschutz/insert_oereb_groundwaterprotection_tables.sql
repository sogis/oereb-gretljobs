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
    afu_grundwasserschutz_oereb.transferstruktur_eigentumsbeschraenkung
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
    
    -- Grundwasserschutzzonen
    SELECT
        DISTINCT ON (gwszone.t_id)
        gwszone.t_id,
        basket_dataset.basket_t_id,
        basket_dataset.datasetname,
        gwszone.typ AS aussage_de,
        'Grundwasserschutzzonen' AS thema,
        gwszone.typ AS artcode,
        'urn:fdc:ilismeta.interlis.ch:2017:Typ_Kanton_Grundwasserschutzzonen' AS artcodeliste,           -- ist die Bezeichnung richtig?
        status.rechtsstatus,
        status.rechtskraftdatum AS publiziertab, 
        amt.t_id AS zustaendigestelle
    FROM
        afu_gewaesserschutz.gwszonen_gwszone AS gwszone
        LEFT JOIN afu_grundwasserschutz_oereb.vorschriften_amt AS amt
        ON amt.t_ili_tid = 'ch.so.afu'
        LEFT JOIN afu_gewaesserschutz.gwszonen_status AS status
        ON gwszone.astatus = status.t_id,
        (
            SELECT
                basket.t_id AS basket_t_id,
                dataset.datasetname AS datasetname               
            FROM
                afu_grundwasserschutz_oereb.t_ili2db_dataset AS dataset
                LEFT JOIN afu_grundwasserschutz_oereb.t_ili2db_basket AS basket
                ON basket.dataset = dataset.t_id
            WHERE
                dataset.datasetname = 'ch.so.afu.grundwasserschutz'
        ) AS basket_dataset
    WHERE
        status.rechtskraftdatum IS NOT NULL
    AND
        status.rechtsstatus = 'inKraft'

     UNION ALL
     
     -- Grundwasserschutzareale
     SELECT
         DISTINCT ON (gwsareal.t_id)
         gwsareal.t_id,
         basket_dataset.basket_t_id,
         basket_dataset.datasetname,
         gwsareal.typ AS aussage_de,
         'Grundwasserschutzareale' AS thema,
         gwsareal.typ AS artcode,
         'urn:fdc:ilismeta.interlis.ch:2017:Typ_Kanton_Grundwasserschutzareale' AS artcodeliste,           -- ist die Bezeichnung richtig?
         status.rechtsstatus,
         status.rechtskraftdatum AS publiziertab, 
         amt.t_id AS zustaendigestelle
     FROM
         afu_gewaesserschutz.gwszonen_gwsareal AS gwsareal
         LEFT JOIN afu_grundwasserschutz_oereb.vorschriften_amt AS amt
         ON amt.t_ili_tid = 'ch.so.afu'
         LEFT JOIN afu_gewaesserschutz.gwszonen_status AS status
         ON gwsareal.astatus = status.t_id,
         (
             SELECT
                 basket.t_id AS basket_t_id,
                 dataset.datasetname AS datasetname               
             FROM
                 afu_grundwasserschutz_oereb.t_ili2db_dataset AS dataset
                 LEFT JOIN afu_grundwasserschutz_oereb.t_ili2db_basket AS basket
                 ON basket.dataset = dataset.t_id
             WHERE
                 dataset.datasetname = 'ch.so.afu.grundwasserschutz'
         ) AS basket_dataset
     WHERE
         status.rechtskraftdatum IS NOT NULL
     AND
         status.rechtsstatus = 'inKraft'
;

/*
 * Dokumente
 */

INSERT INTO
    afu_grundwasserschutz_oereb.transferstruktur_hinweisvorschrift
    (
        t_id,
        t_basket,
        t_datasetname,
        eigentumsbeschraenkung,
        vorschrift_vorschriften_dokument  
    )
    SELECT 
        t_id, 
        basket_t_id,
        datasetname,
        eigentumsbeschraenkung,
        vorschrift_vorschriften_dokument
    FROM
    (
        SELECT
            t_id, 
            gwszone AS eigentumsbeschraenkung,
            rechtsvorschrift AS vorschrift_vorschriften_dokument
        FROM
            afu_gewaesserschutz.gwszonen_rechtsvorschriftgwszone

        UNION ALL

        SELECT
            t_id, 
            gwsareal AS eigentumsbeschraenkung,
            rechtsvorschrift AS vorschrift_vorschriften_dokument
        FROM
            afu_gewaesserschutz.gwszonen_rechtsvorschriftgwsareal            
    ) AS hinweisvorschrift,  
    (
        SELECT
            basket.t_id AS basket_t_id,
            dataset.datasetname AS datasetname               
        FROM
            afu_grundwasserschutz_oereb.t_ili2db_dataset AS dataset
            LEFT JOIN afu_grundwasserschutz_oereb.t_ili2db_basket AS basket
            ON basket.dataset = dataset.t_id
        WHERE
           dataset.datasetname = 'ch.so.afu.grundwasserschutz' 
    ) AS basket_dataset
;    
INSERT INTO 
    afu_grundwasserschutz_oereb.vorschriften_dokument
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
            WHEN art = 'Rechtsvorschrift'
                THEN 'vorschriften_rechtsvorschrift'
            ELSE 'vorschriften_dokument'
        END AS t_type,
        '_'||SUBSTRING(REPLACE(CAST(dokument.t_id AS text), '-', ''),1,15) AS t_ili_tid,        
        dokument.titel AS titel_de,
        dokument.offiziellertitel AS offizellertitel_de,
        dokument.abkuerzung AS abkuerzung_de,
        dokument.offiziellenr AS offiziellenr,
        dokument.kanton AS kanton,
        dokument.gemeinde AS gemeinde,
        dokument.rechtsstatus AS rechtsstatus,
        dokument.publiziertab AS publiziertab,
        amt.t_id AS zustaendigestelle
    FROM
        afu_gewaesserschutz.gwszonen_dokument AS dokument,
        (
            SELECT
                basket.t_id AS basket_t_id,
                dataset.datasetname AS datasetname           
            FROM
                afu_grundwasserschutz_oereb.t_ili2db_dataset AS dataset
                LEFT JOIN afu_grundwasserschutz_oereb.t_ili2db_basket AS basket
                ON basket.dataset = dataset.t_id
            WHERE
                dataset.datasetname = 'ch.so.afu.grundwasserschutz' 
            ) AS basket_dataset
            LEFT JOIN afu_grundwasserschutz_oereb.vorschriften_amt AS amt
            ON amt.t_ili_tid = 'ch.so.afu'
;

/*
 * Umbau der Geometrien, die Inhalt des ÖREB-Katasters sind.
 */

INSERT INTO
    afu_grundwasserschutz_oereb.transferstruktur_geometrie
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
        ST_MakeValid(ST_RemoveRepeatedPoints(ST_SnapToGrid(schutzzone.geometrie, 0.001))) AS flaeche_lv95,
        schutzzone.rechtsstatus,
        schutzzone.publiziertab AS publiziertab, 
        eigentumsbeschraenkung.t_id AS eigentumsbeschraenkung,
        eigentumsbeschraenkung.zustaendigestelle AS zustaendigestelle
    FROM
    (
        -- Grundwasserschutzzonen
        SELECT
            gwszone.t_id AS t_id,    
            geometrie AS geometrie,
            status.rechtsstatus,
            status.rechtskraftdatum AS publiziertab
        FROM
            afu_gewaesserschutz.gwszonen_gwszone AS gwszone
            LEFT JOIN afu_gewaesserschutz.gwszonen_status AS status
        ON gwszone.astatus = status.t_id
        WHERE
            rechtsstatus = 'inKraft'

         UNION ALL
         
         -- Grundwasserschutzareale
         SELECT
             gwsareal.t_id AS t_id,    
             geometrie AS geometrie,
             status.rechtsstatus,
             status.rechtskraftdatum AS publiziertab
         FROM
             afu_gewaesserschutz.gwszonen_gwsareal AS gwsareal
             LEFT JOIN afu_gewaesserschutz.gwszonen_status AS status
         ON gwsareal.astatus = status.t_id
         WHERE
             rechtsstatus = 'inKraft'
    ) AS schutzzone
        INNER JOIN afu_grundwasserschutz_oereb.transferstruktur_eigentumsbeschraenkung AS eigentumsbeschraenkung
        ON schutzzone.t_id = eigentumsbeschraenkung.t_id,
         (
             SELECT
                 basket.t_id AS basket_t_id,
                 dataset.datasetname AS datasetname               
             FROM
                 afu_grundwasserschutz_oereb.t_ili2db_dataset AS dataset
                 LEFT JOIN afu_grundwasserschutz_oereb.t_ili2db_basket AS basket
                 ON basket.dataset = dataset.t_id
             WHERE
                 dataset.datasetname = 'ch.so.afu.grundwasserschutz'
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
        afu_grundwasserschutz_oereb.transferstruktur_darstellungsdienst 
        (
            t_basket,
            t_datasetname,
            verweiswms,
            legendeimweb
        )
        SELECT
            basket_dataset.basket_t_id AS t_basket,
            basket_dataset.datasetname AS t_datasetname,
            '${wmsHost}/wms/oereb?SERVICE=WMS&VERSION=1.3.0&REQUEST=GetMap&FORMAT=image%2Fpng&TRANSPARENT=true&LAYERS='||RTRIM(TRIM((layername||'.'||geometrietyp)), '.')||'&STYLES=&SRS=EPSG%3A2056&CRS=EPSG%3A2056&DPI=96&WIDTH=1200&HEIGHT=1146&BBOX=2591250%2C1211350%2C2646050%2C1263700' AS verweiswms,
            '${wmsHost}/wms/oereb?SERVICE=WMS&VERSION=1.3.0&REQUEST=GetLegendGraphics&FORMAT=image/png&LAYER='||RTRIM(TRIM((layername||'.'||geometrietyp)), '.') AS legendeimweb
        FROM
        (
            SELECT 
                DISTINCT ON (thema, geometrietyp)
                thema,
                subthema,
                'Flaeche' AS geometrietyp,
                'ch.SO.'||thema AS layername
            FROM
                afu_grundwasserschutz_oereb.transferstruktur_eigentumsbeschraenkung AS eigentumsbeschraenkung 
        ) AS eigentumsbeschraenkung,
        (
            SELECT
                basket.t_id AS basket_t_id,
                dataset.datasetname AS datasetname               
            FROM
                afu_grundwasserschutz_oereb.t_ili2db_dataset AS dataset
                LEFT JOIN afu_grundwasserschutz_oereb.t_ili2db_basket AS basket
                ON basket.dataset = dataset.t_id
            WHERE
                dataset.datasetname = 'ch.so.afu.grundwasserschutz' 
        ) AS basket_dataset
    RETURNING *
)
INSERT INTO 
    afu_grundwasserschutz_oereb.transferstruktur_legendeeintrag
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
            'Flaeche' AS geometrietyp,
            'ch.SO.'||thema AS layername
        FROM
            afu_grundwasserschutz_oereb.transferstruktur_eigentumsbeschraenkung AS eigentumsbeschraenkung 
    ) AS eigentumsbeschraenkung
    LEFT JOIN transferstruktur_darstellungsdienst
    ON transferstruktur_darstellungsdienst.verweiswms ILIKE '%'||RTRIM(eigentumsbeschraenkung.layername||'.'||eigentumsbeschraenkung.geometrietyp, '.')||'%'
;

UPDATE 
    afu_grundwasserschutz_oereb.transferstruktur_eigentumsbeschraenkung
SET 
    darstellungsdienst = (SELECT t_id FROM afu_grundwasserschutz_oereb.transferstruktur_darstellungsdienst WHERE verweiswms ILIKE '%Grundwasserschutzzonen%')
WHERE
    thema = 'Grundwasserschutzzonen'
;

UPDATE 
    afu_grundwasserschutz_oereb.transferstruktur_eigentumsbeschraenkung
SET 
    darstellungsdienst = (SELECT t_id FROM afu_grundwasserschutz_oereb.transferstruktur_darstellungsdienst WHERE verweiswms ILIKE '%Grundwasserschutzareale%')
WHERE
    thema = 'Grundwasserschutzareale'
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
    afu_grundwasserschutz_oereb.vorschriften_dokument
  WHERE
    t_ili_tid IN ('ch.admin.bk.sr.700', 'ch.so.sk.bgs.711.1', 'ch.so.sk.bgs.711.61') 
)
INSERT INTO afu_grundwasserschutz_oereb.vorschriften_hinweisweiteredokumente (
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
  afu_grundwasserschutz_oereb.vorschriften_dokument AS vorschriften_dokument
  LEFT JOIN vorschriften_dokument_gesetze
  ON 1=1
WHERE
  t_type = 'vorschriften_rechtsvorschrift'
AND
  vorschriften_dokument.t_datasetname = 'ch.so.afu.grundwasserschutz'
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
    afu_grundwasserschutz_oereb.vorschriften_amt
SET
    t_ili_tid = 'ch.so.sk.'||uuid_generate_v4()
WHERE
    t_datasetname = 'ch.so.afu.grundwasserschutz'
AND
    t_ili_tid = 'ch.so.sk'
;
