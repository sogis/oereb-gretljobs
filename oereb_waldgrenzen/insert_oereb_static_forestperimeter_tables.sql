/* 
 * Als erstes wird der Darstellungsdienst umgebaut. 
 * 
 * (1) Eigentumsbeschränkung verweist auf Darstellungsdienst und Legendeneintrag. Aus
 * diesem Grund kann nicht zuerst die Eigenstumsbeschränkung umgebaut werden.
 * 
 * (2) Für Nutzungsplanung wird die Query wahrscheinlich leicht komplizierter wegen
 * der verschiedenen Themen und Subthemen. Auch bei anderen Datensätzen mit gleicher
 * Veranlagung.
 */
WITH darstellungsdienst AS 
(
    INSERT INTO 
        awjf_statische_waldgrenzen_oereb.transferstruktur_darstellungsdienst 
        (
            t_id,
            t_basket,
            t_ili_tid            
        )         
    SELECT
        nextval('awjf_statische_waldgrenzen_oereb.t_ili2db_seq'::regclass) AS t_id,
        basket.t_id,
        uuid_generate_v4() AS t_ili_tid
    FROM 
    (
        SELECT
            t_id
        FROM
            awjf_statische_waldgrenzen_oereb.t_ili2db_basket
        WHERE
            t_ili_tid = 'ch.so.awjf.waldgrenzen' 
    ) AS basket
    RETURNING *
)
,
darstellungsdienst_multilingualuri AS 
(
    INSERT INTO
        awjf_statische_waldgrenzen_oereb.multilingualuri 
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
    awjf_statische_waldgrenzen_oereb.localiseduri 
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
    '${wmsHost}/wms/oereb?SERVICE=WMS&VERSION=1.3.0&REQUEST=GetMap&FORMAT=image%2Fpng&TRANSPARENT=true&LAYERS=ch.StatischeWaldgrenzen&STYLES=&SRS=EPSG%3A2056&CRS=EPSG%3A2056&DPI=96&WIDTH=1200&HEIGHT=1146&BBOX=2591250%2C1211350%2C2646050%2C1263700',
    darstellungsdienst_multilingualuri.t_id
FROM
    darstellungsdienst_multilingualuri
;

-- FIXME FIXME FIXME TODO
/* 
 * Eigentumsbeschränkungen und Legendeneinträge
 * 
 * (1) Müssen in einem CTE-Block gemeinsam abgehandlet werden, weil die Eigentumsbeschränkungen
 * auf die Legendeneinträge verweisen aber man die Legendeinträge nur erstellen kann, wenn man
 * weiss, welche Eigentumsbeschränkungen es gibt. Benötigt werden ebenfalls noch die Darstellungsdienste
 * aus dem ersten CTE-Block damit man den Legendeneintrag via Thema dem richtigen Darstellungsdient
 * zuweisen kann.
 * 
 * (2) "geobasisdaten_typ IN" (etc.) filtern Eigentumsbeschränkungen weg, die mit keinem Dokument verknüpft sind.
 * Sind solche Objekte vorhanden, handelt es sich in der Regel um einen Datenfehler in den Ursprungsdaten.
 * 'publiziertab IS NOT NULL' filtert Objekte raus, die kein Publikationsdatum haben (Mandatory im Rahmenmodell.)
 *
 * (3) rechtsstatus = "inKraft": Die Bedingung hier reicht nicht, damit (später) auch nur die Geometrien verwendet
 * werden, die "inKraft" sind. Grund dafür ist, dass es nicht "inKraft" Geometrien geben kann, die auf einen
 * Typ zeigen, dem Geometrien zugewiesen sind, die "inKraft" sind. Nur solche Typen, dem gar keine "inKraft"
 * Geometrien zugewiesen sind, werden hier rausgefiltert. Darum muss auch mit den Geometrien gejoined werden,
 * was wiederum zu Verdoppelung des Typs führt und mit DISTINCT bereinigt werden muss.
 *
 * (4) Ebenfalls reicht die Bedingung "inKraft" bei den Dokumenten nicht. Hier werden nur Typen rausgefiltert, die 
 * nur Dokumente angehängt haben, die NICHT inKraft sind. Sind bei einem Typ aber sowohl inKraft wie auch nicht-
 * inKraft-Dokumente angehängt, wird korrekterweise der Typ trotzdem verwendet. Bei den Dokumenten muss der
 * Filter nochmals gesetzt werden. 
 * 
 * (5) Zu prüfen, ob bei der Einführung von Vorwirkung (4) noch gilt. 
 * 
 * (6) Die richtigen Symbole werden erst nachträglich mit einem anderen Gretl-Task korrekt abgefüllt. Hier wird
 * ein Dummy-Symbol gespeichert.
*/

WITH darstellungsdienst AS 
(
    SELECT
        darstellungsdienst.t_id,
        darstellungsdienst.t_basket AS basket_t_id,
        localiseduri.atext
    FROM 
        awjf_statische_waldgrenzen_oereb.transferstruktur_darstellungsdienst AS darstellungsdienst
        LEFT JOIN awjf_statische_waldgrenzen_oereb.multilingualuri AS multilingualuri  
        ON multilingualuri.transfrstrkstllngsdnst_verweiswms = darstellungsdienst.t_id 
        LEFT JOIN awjf_statische_waldgrenzen_oereb.localiseduri AS localiseduri 
        ON localiseduri.multilingualuri_localisedtext = multilingualuri.t_id 
)
,
eigentumsbeschraenkung AS (
        SELECT
        DISTINCT ON (geobasisdaten_typ.t_id)
        geobasisdaten_typ.t_id,
        darstellungsdienst.basket_t_id,
        'ch.StatischeWaldgrenzen' AS thema,
        waldgrenze.rechtsstatus,
        waldgrenze.publiziert_ab AS publiziertab,
        darstellungsdienst.t_id AS darstellungsdienst,
        amt.amt_t_id AS zustaendigestelle,
        --nextval('awjf_statische_waldgrenzen_oereb.t_ili2db_seq'::regclass) AS legendeneintrag_t_id,
        --decode('iVBORw0KGgoAAAANSUhEUgAAAEYAAAAjCAYAAAApF3xtAAAABHNCSVQICAgIfAhkiAAAAAlwSFlzAAAD8AAAA/AB2OVKxAAAABl0RVh0U29mdHdhcmUAd3d3Lmlua3NjYXBlLm9yZ5vuPBoAAAOoSURBVGiB7ZpfaM1hGMc/PzvGjFLDzGwixVD+xOnsQmOrlcTGldquFq2RzJ+yG5KUpYw0t65WxtXcUGwXXJhIys1xQZSNkWSOzUp6XDzO3vM6e4/fjB3yfuvtfd7v+zzv+zvfnvfP+Z0TCAgeaZiS7Qf4W+GFcSBitYqKIBbL0qNkGffuwevXpi0go6WmRv5b1NRIqhZ+KTnghXHAC+OAF8YBL4wDXhgH3MK8fAnr19tlwwbYtg3a2+HzZ+P76JHxOXvWHqe2VvnNmw0XiylXWQmJhO1//rwZ6+pV5To6DHfxou3/4QNs2qR9Gzcqd+uW8T9xwvY/dsz0dXe7lXHeY+Jx61xPK2VlIm/fqm9Pj+H37bPvB4sWKZ+fb7ggMP4tLYZ//lwkL8/0tbUp39pquPx8kb4+E9PcbPqmTVNuaEikoEC5mTNFEgnlBwc1HkTmzhUZHp7gPWbFCmhthePHYdky5eJxaGkJFZ4R587Bs2dqHzliZ+JYGBoy88bj6RkEMGMGNDaq/ekTXLmidmenxgM0NUFennueUBmzc6fhX70SiUSULymZeMaASG2tPUamjAGN7+0Vqa62+WTGiIj094vk5ipfXq5cNKrt6dNF3ryxn3PCN9+iIi0A79+PO9xCEGjd1QV1dTaXKUYEduyAmzfdMQsWwK5davf2wuXLcP++tuvrYd68jNP82qk05TcdZsuX6wYMMDCg4yaXgAtNTSrEwIC2q6thyZKxfQ8eNPbu3VoHgc07kP3juq0NcnLUbmiAdesy+0ejJrsikfRTMBVr1hjhh4e13rJF98yfIPvCrF4Ne/dCaSmcOhUu5vRpKC6Gw4dh1arMvj9mx6FDoaaI/NxlEnDhgpawWLgQ+vrC+W7dCrNm6X1pzhyoqgoV9msZkzzykntNbq7p+/LF9k22U30mE0GgSw5g6tTQYeMX5to1ePdO7dJSrRcvNifDnTswMqL248fmrdjSpeOeKpsIt5R6evQKnUjA06eGT+70xcW6qV2/Dk+eQFkZrFwJt2/r0QqwZ89vfvQ/i3DCDA7Cw4emnZOjG9+BA4a7dEm/Rz14AC9eaAHNpP37jYj/CNzCzJ+vXwNSEQTKV1VplqSisBDu3oUbNzRTPn5Un+3bYe1a2/fMGfj6dexLVixm5q2o0Lqy0nDRaHrM0aN62XTtYydP6r44e7bz46bBvwz/Dv8yPBy8MA54YRzwwjjghXEgsP4G4n+7Hm3awniMwi8lB7wwDnwD/bFRBvNxDWsAAAAASUVORK5CYII=', 'base64') AS symbol,        
        CASE
            WHEN geobasisdaten_typ.art = 'Nutzungsplanung_in_Bauzonen' THEN 'in Bauzonen'
            ELSE 'ausserhalb Bauzonen'
        END AS legendetext_de,
        CASE
            WHEN geobasisdaten_typ.art = 'Nutzungsplanung_in_Bauzonen'
                THEN 'in_Bauzonen'
            ELSE 'ausserhalb_Bauzonen'
        END AS  artcode,        
        'urn:fdc:ilismeta.interlis.ch:2017:Typ_Kanton_Waldgrenzen' AS artcodeliste
    FROM
        awjf_statische_waldgrenze.geobasisdaten_typ AS geobasisdaten_typ
        LEFT JOIN awjf_statische_waldgrenze.geobasisdaten_waldgrenze_linie AS waldgrenze
        ON geobasisdaten_typ.t_id = waldgrenze.waldgrenze_typ
        LEFT JOIN darstellungsdienst
        ON darstellungsdienst.atext ILIKE '%ch.StatischeWaldgrenzen%',
        (
            SELECT 
                t_id AS amt_t_id
            FROM 
                awjf_statische_waldgrenzen_oereb.amt_amt 
            WHERE 
                t_ili_tid = 'ch.so.awjf'
        ) AS amt
    WHERE
        geobasisdaten_typ.t_id IN 
        (
            SELECT
                DISTINCT ON (festlegung) 
                festlegung
            FROM
                awjf_statische_waldgrenze.geobasisdaten_typ_dokument AS geobasisdaten_typ_dokument
                LEFT JOIN awjf_statische_waldgrenze.dokumente_dokument AS dokument
                ON dokument.t_id = geobasisdaten_typ_dokument.dokumente
            WHERE
                dokument.rechtsstatus = 'inKraft'  
            AND 
                dokument.typ <> 'Bericht'
        )  
        AND
        waldgrenze.rechtsstatus = 'inKraft'
        AND
        waldgrenze.datum_archivierung IS NULL
        AND 
        geobasisdaten_typ.verbindlichkeit = 'Nutzungsplanfestlegung'
)
,
legendeneintrag AS (
    INSERT INTO 
        awjf_statische_waldgrenzen_oereb.transferstruktur_legendeeintrag 
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
        -- Eigentlich noch legendetext aber nicht bei Nutzungsplanung, da wir dort aggregierte Symbole verwenden.
        DISTINCT ON (artcode, artcodeliste)
        nextval('awjf_statische_waldgrenzen_oereb.t_ili2db_seq'::regclass) AS legendeneintrag_t_id,
        basket_t_id,
        uuid_generate_v4(),
        decode('iVBORw0KGgoAAAANSUhEUgAAAEYAAAAjCAYAAAApF3xtAAAABHNCSVQICAgIfAhkiAAAAAlwSFlzAAAD8AAAA/AB2OVKxAAAABl0RVh0U29mdHdhcmUAd3d3Lmlua3NjYXBlLm9yZ5vuPBoAAAOoSURBVGiB7ZpfaM1hGMc/PzvGjFLDzGwixVD+xOnsQmOrlcTGldquFq2RzJ+yG5KUpYw0t65WxtXcUGwXXJhIys1xQZSNkWSOzUp6XDzO3vM6e4/fjB3yfuvtfd7v+zzv+zvfnvfP+Z0TCAgeaZiS7Qf4W+GFcSBitYqKIBbL0qNkGffuwevXpi0go6WmRv5b1NRIqhZ+KTnghXHAC+OAF8YBL4wDXhgH3MK8fAnr19tlwwbYtg3a2+HzZ+P76JHxOXvWHqe2VvnNmw0XiylXWQmJhO1//rwZ6+pV5To6DHfxou3/4QNs2qR9Gzcqd+uW8T9xwvY/dsz0dXe7lXHeY+Jx61xPK2VlIm/fqm9Pj+H37bPvB4sWKZ+fb7ggMP4tLYZ//lwkL8/0tbUp39pquPx8kb4+E9PcbPqmTVNuaEikoEC5mTNFEgnlBwc1HkTmzhUZHp7gPWbFCmhthePHYdky5eJxaGkJFZ4R587Bs2dqHzliZ+JYGBoy88bj6RkEMGMGNDaq/ekTXLmidmenxgM0NUFennueUBmzc6fhX70SiUSULymZeMaASG2tPUamjAGN7+0Vqa62+WTGiIj094vk5ipfXq5cNKrt6dNF3ryxn3PCN9+iIi0A79+PO9xCEGjd1QV1dTaXKUYEduyAmzfdMQsWwK5davf2wuXLcP++tuvrYd68jNP82qk05TcdZsuX6wYMMDCg4yaXgAtNTSrEwIC2q6thyZKxfQ8eNPbu3VoHgc07kP3juq0NcnLUbmiAdesy+0ejJrsikfRTMBVr1hjhh4e13rJF98yfIPvCrF4Ne/dCaSmcOhUu5vRpKC6Gw4dh1arMvj9mx6FDoaaI/NxlEnDhgpawWLgQ+vrC+W7dCrNm6X1pzhyoqgoV9msZkzzykntNbq7p+/LF9k22U30mE0GgSw5g6tTQYeMX5to1ePdO7dJSrRcvNifDnTswMqL248fmrdjSpeOeKpsIt5R6evQKnUjA06eGT+70xcW6qV2/Dk+eQFkZrFwJt2/r0QqwZ89vfvQ/i3DCDA7Cw4emnZOjG9+BA4a7dEm/Rz14AC9eaAHNpP37jYj/CNzCzJ+vXwNSEQTKV1VplqSisBDu3oUbNzRTPn5Un+3bYe1a2/fMGfj6dexLVixm5q2o0Lqy0nDRaHrM0aN62XTtYydP6r44e7bz46bBvwz/Dv8yPBy8MA54YRzwwjjghXEgsP4G4n+7Hm3awniMwi8lB7wwDnwD/bFRBvNxDWsAAAAASUVORK5CYII=', 'base64') AS symbol,
        legendetext_de,
        artcode,
        artcodeliste,
        thema,
        darstellungsdienst
    FROM 
        eigentumsbeschraenkung      
    RETURNING *
)
INSERT INTO
    awjf_statische_waldgrenzen_oereb.transferstruktur_eigentumsbeschraenkung 
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
 * (1) Bei diesem Edit-Modell gibt es keine Rekursion bei den Dokumenten. 
 * 
 * (2) hinweisvorschrift: Alle Dokumente, welche inKraft sind und mit einer
 * Eigentumsbeschraenkung verknüpft sind.
 * 
 * (3) Sämtliche Informationen über die betroffenen Dokumente selektieren
 * und in die Zieltabelle schreiben.
 * 
 * (4) Die TID ist vom Typ OID AS OEREBOID = OID TEXT*255 und muss somit
 * mit einem Buchstaben beginnen.
*/

WITH basket AS (
    SELECT
        t_id
    FROM
        awjf_statische_waldgrenzen_oereb.t_ili2db_basket
    WHERE
        t_ili_tid = 'ch.so.awjf.waldgrenzen' 
)
,
hinweisvorschrift AS (
    SELECT 
        t_typ_dokument.t_id,
        basket.t_id AS t_basket,
        t_typ_dokument.eigentumsbeschraenkung,
        t_typ_dokument.vorschrift_vorschriften_dokument
    FROM 
    (
        SELECT 
            typ_dokument.t_id,
            typ_dokument.festlegung AS eigentumsbeschraenkung,
            typ_dokument.dokumente AS vorschrift_vorschriften_dokument
        FROM 
            awjf_statische_waldgrenze.geobasisdaten_typ_dokument AS typ_dokument
            LEFT JOIN awjf_statische_waldgrenze.dokumente_dokument AS dokument 
            ON dokument.t_id = typ_dokument.dokumente 
        WHERE 
            dokument.rechtsstatus = 'inKraft'
        -- So werden auch Hinweise veröffentlicht.
        -- Weil jedoch bei den Eigentumsbeschränkungen die Berichte weggefiltert
        -- werden, kann es nicht sein, dass es Eigentumsbeschränkungen gibt, die
        -- nur Hinweise als Dokument haben.    
        --AND 
        --  dokument.typ <> 'Bericht'
    ) AS t_typ_dokument
    RIGHT JOIN awjf_statische_waldgrenzen_oereb.transferstruktur_eigentumsbeschraenkung AS eigentumsbeschraenkung 
    ON t_typ_dokument.eigentumsbeschraenkung = eigentumsbeschraenkung.t_id,
    basket
)
,
dokumente_dokument AS
(
    INSERT INTO 
        awjf_statische_waldgrenzen_oereb.dokumente_dokument 
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
        dokument.t_id,
        basket.t_id AS t_basket,
        '_'||CAST(uuid_generate_v4() AS TEXT) AS t_ili_tid,
        CASE 
            WHEN dokument.typ <> 'Bericht' THEN 'Rechtsvorschrift'
            ELSE 'Hinweis'
        END AS typ,
        dokument.offiziellertitel AS titel_de,
        dokument.abkuerzung AS abkuerzung_de,
        dokument.offiziellenr AS offiziellenr_de,
        CAST(500 AS int4) AS auszugindex,
        dokument.rechtsstatus AS rechtsstatus,
        dokument.publiziert_ab AS publiziertab,
        CASE
            WHEN dokument.typ = 'RRB' THEN 
                (
                    SELECT 
                        t_id
                    FROM
                        awjf_statische_waldgrenzen_oereb.amt_amt 
                    WHERE
                        t_ili_tid = 'ch.so.sk'
                )
            ELSE
                (
                    SELECT 
                        t_id
                    FROM
                        awjf_statische_waldgrenzen_oereb.amt_amt 
                    WHERE
                        t_ili_tid = 'ch.so.awjf'
                )
        END AS zustaendigestelle
    FROM 
        awjf_statische_waldgrenze.dokumente_dokument AS dokument
        RIGHT JOIN hinweisvorschrift
        ON dokument.t_id = hinweisvorschrift.vorschrift_vorschriften_dokument,
        basket
    WHERE
        rechtsstatus = 'inKraft'
    AND 
        datum_archivierung IS NULL
)
INSERT INTO 
    awjf_statische_waldgrenzen_oereb.transferstruktur_hinweisvorschrift 
    (
        t_id,
        t_basket,
        eigentumsbeschraenkung,
        vorschrift
    )
SELECT 
    t_id,
    t_basket,
    eigentumsbeschraenkung,
    vorschrift_vorschriften_dokument
FROM 
    hinweisvorschrift 
;

/*
 * Datenumbau der Links auf die Dokumente, die im Rahmenmodell 'multilingual' sind und daher eher
 * mühsam normalisert sind.
 * 
 */

WITH multilingualuri AS
(
    INSERT INTO
        awjf_statische_waldgrenzen_oereb.multilingualuri
        (
            t_id,
            t_basket,
            t_seq,
            dokumente_dokument_textimweb
        )
    SELECT
        nextval('awjf_statische_waldgrenzen_oereb.t_ili2db_seq'::regclass) AS t_id,
        basket.t_id,
        0 AS t_seq,
        dokumente_dokument.t_id AS dokumente_dokument_textimweb
    FROM
        awjf_statische_waldgrenzen_oereb.dokumente_dokument AS dokumente_dokument,
        (
            SELECT
                t_id
            FROM
                awjf_statische_waldgrenzen_oereb.t_ili2db_basket
            WHERE
                t_ili_tid = 'ch.so.awjf.waldgrenzen' 
        ) AS basket
    RETURNING *
)
,
localiseduri AS 
(
    SELECT 
        nextval('awjf_statische_waldgrenzen_oereb.t_ili2db_seq'::regclass) AS t_id,
        basket.t_id AS basket_t_id,
        0 AS t_seq,
        'de' AS alanguage,
        text_im_web AS atext,
        multilingualuri.t_id AS multilingualuri_localisedtext
    FROM
        awjf_statische_waldgrenze.dokumente_dokument AS dokumente_dokument
        RIGHT JOIN multilingualuri 
        ON multilingualuri.dokumente_dokument_textimweb = dokumente_dokument.t_id,
        (
            SELECT
                t_id
            FROM
                awjf_statische_waldgrenzen_oereb.t_ili2db_basket
            WHERE
                t_ili_tid = 'ch.so.awjf.waldgrenzen' 
        ) AS basket
)
INSERT INTO
    awjf_statische_waldgrenzen_oereb.localiseduri
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

/*
 * Umbau der Geometrien, die Inhalt des ÖREB-Katasters sind.
 */

INSERT INTO
    awjf_statische_waldgrenzen_oereb.transferstruktur_geometrie
    ( 
        t_basket,
        linie,
        rechtsstatus,
        publiziertab,
        eigentumsbeschraenkung
    )
SELECT
    basket.t_id AS t_basket,
    ST_MakeValid(ST_RemoveRepeatedPoints(ST_SnapToGrid(waldgrenze.geometrie, 0.001))) AS linie,
    waldgrenze.rechtsstatus,
    waldgrenze.publiziert_ab AS publiziertab,
    eigentumsbeschraenkung.t_id AS eigentumsbeschraenkung
FROM
    awjf_statische_waldgrenze.geobasisdaten_waldgrenze_linie AS waldgrenze
    INNER JOIN awjf_statische_waldgrenzen_oereb.transferstruktur_eigentumsbeschraenkung AS eigentumsbeschraenkung
    ON waldgrenze.waldgrenze_typ = eigentumsbeschraenkung.t_id,
    (
        SELECT
            t_id
        FROM
            awjf_statische_waldgrenzen_oereb.t_ili2db_basket
        WHERE
            t_ili_tid = 'ch.so.awjf.waldgrenzen' 
    ) AS basket
WHERE
    waldgrenze.rechtsstatus = 'inKraft'
AND 
    waldgrenze.datum_archivierung IS NULL
;


