WITH darstellungsdienst AS 
(
    INSERT INTO 
        arp_planungszonen_oereb.transferstruktur_darstellungsdienst 
        (
            t_id,
            t_basket,
            t_ili_tid            
        )         
    SELECT
        nextval('arp_planungszonen_oereb.t_ili2db_seq'::regclass) AS t_id,
        basket.t_id,
        uuid_generate_v4() AS t_ili_tid
    FROM 
    (
        SELECT
            t_id
        FROM
            arp_planungszonen_oereb.t_ili2db_basket
        WHERE
            t_ili_tid = 'ch.so.arp.oereb_planungszonen' 
    ) AS basket
    RETURNING *
)
,
darstellungsdienst_multilingualuri AS 
(
    INSERT INTO
        arp_planungszonen_oereb.multilingualuri 
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
    arp_planungszonen_oereb.localiseduri 
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
    '${wmsHost}/wms/oereb?SERVICE=WMS&VERSION=1.3.0&REQUEST=GetMap&FORMAT=image%2Fpng&TRANSPARENT=true&LAYERS=ch.Planungszonen&STYLES=&SRS=EPSG%3A2056&CRS=EPSG%3A2056&DPI=96&WIDTH=1200&HEIGHT=1146&BBOX=2591250%2C1211350%2C2646050%2C1263700',
    darstellungsdienst_multilingualuri.t_id
FROM
    darstellungsdienst_multilingualuri
;

/* (1) Inner Join damit nur Typen verwendet werden, die eine Geometrie aufweisen.
 * 
 * (2) Geometrie gleich hier mitnehmen, dafür erst beim INSERT der Eigentumsbeschränkung
 * distincten.
 * 
 */

WITH darstellungsdienst AS 
(
    SELECT
        darstellungsdienst.t_id,
        darstellungsdienst.t_basket AS basket_t_id,
        localiseduri.atext
    FROM 
        arp_planungszonen_oereb.transferstruktur_darstellungsdienst AS darstellungsdienst
        LEFT JOIN arp_planungszonen_oereb.multilingualuri AS multilingualuri  
        ON multilingualuri.transfrstrkstllngsdnst_verweiswms = darstellungsdienst.t_id 
        LEFT JOIN arp_planungszonen_oereb.localiseduri AS localiseduri 
        ON localiseduri.multilingualuri_localisedtext = multilingualuri.t_id 
)
,
eigentumsbeschraenkung AS (
    -- Durch die Joins enstehen mehrfache Eigentumsbeschränkungen.
    -- Diese werden beim Insert wieder entfernt (distinct on).
    SELECT
        geobasisdaten_typ.t_id,
        darstellungsdienst.basket_t_id,
        'ch.Planungszonen' AS thema,
        geometrie.rechtsstatus,
        geometrie.publiziertab AS publiziertab,
        darstellungsdienst.t_id AS darstellungsdienst,
        amt.t_id AS zustaendigestelle,
        'Planungszone' AS legendetext_de,
        '692' AS artcode,        
        'urn:fdc:ilismeta.interlis.ch:2022:Typ_Kanton_Planungszonen' AS artcodeliste,
        geometrie.geometrie 
    FROM
        arp_nutzungsplanung.nutzungsplanung_typ_ueberlagernd_flaeche AS geobasisdaten_typ
        INNER JOIN arp_nutzungsplanung.nutzungsplanung_ueberlagernd_flaeche AS geometrie
        ON geobasisdaten_typ.t_id = geometrie.typ_ueberlagernd_flaeche 
        LEFT JOIN darstellungsdienst
        ON darstellungsdienst.atext ILIKE '%ch.Planungszonen%'
        LEFT JOIN arp_planungszonen_oereb.amt_amt AS amt 
        ON substring(amt.t_ili_tid FROM 4 FOR 4) = geobasisdaten_typ.t_datasetname 
    WHERE 
        geobasisdaten_typ.typ_kt = 'N692_Planungszone'
        AND 
        geometrie.rechtsstatus = 'inKraft'
)
,
legendeneintrag AS (
    INSERT INTO 
        arp_planungszonen_oereb.transferstruktur_legendeeintrag 
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
        nextval('arp_planungszonen_oereb.t_ili2db_seq'::regclass) AS legendeneintrag_t_id,
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
        LEFT JOIN arp_planungszonen_oereb.legendeneintraege_legendeneintrag AS eintrag
        ON (eigentumsbeschraenkung.artcode = eintrag.artcode AND eigentumsbeschraenkung.artcodeliste = eintrag.artcodeliste)
   RETURNING *
)
,
geometrie AS (
    INSERT INTO 
        arp_planungszonen_oereb.transferstruktur_geometrie 
        (
            t_basket,
            t_ili_tid,
            flaeche,
            rechtsstatus,
            publiziertab,
            eigentumsbeschraenkung
        )
    SELECT 
        basket_t_id,
        uuid_generate_v4(),
        geometrie,
        rechtsstatus,
        publiziertab,
        t_id
    FROM 
        eigentumsbeschraenkung
)
INSERT INTO
    arp_planungszonen_oereb.transferstruktur_eigentumsbeschraenkung 
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
    DISTINCT ON (eigentumsbeschraenkung.t_id)
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


INSERT INTO 
    arp_planungszonen_oereb.dokumente_dokument
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
    dokument.t_id, 
    dokument.t_basket,
    '_'||CAST(uuid_generate_v4() AS TEXT) AS t_ili_tid,
    CASE 
        WHEN dokument.rechtsvorschrift IS TRUE THEN 'Rechtsvorschrift'
        ELSE 'Hinweis'
    END AS typ,
    dokument.offiziellertitel AS titel_de,
    dokument.abkuerzung AS abkuerzung_de,
    dokument.offiziellenr AS offiziellenr_de,
    CASE
        WHEN dokument.abkuerzung = 'RRB' THEN CAST(999 AS int4) 
        ELSE CAST(998 AS int4)
    END AS auzugindex,
    dokument.rechtsstatus AS rechtsstatus,
    dokument.publiziert_ab AS publiziertab,


FROM 
    arp_nutzungsplanung.rechtsvorschrften_dokument AS dokument
    LEFT JOIN arp_nutzungsplanung.nutzungsplanung_typ_ueberlagernd_flaeche_dokument AS flaeche_dokument 
    ON flaeche_dokument.dokument = dokumente.t_id 
    INNER JOIN arp_planungszonen_oereb.transferstruktur_eigentumsbeschraenkung AS eigentumsbeschraenkung 
    ON eigentumsbeschraenkung.t_id = flaeche_dokument.typ_ueberlagernd_flaeche 
...