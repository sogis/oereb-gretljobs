WITH darstellungsdienst AS 
(
    INSERT INTO 
        afu_gewaesserraum_oereb.transferstruktur_darstellungsdienst 
        (
            t_id,
            t_basket,
            t_ili_tid            
        )         
    SELECT
        nextval('afu_gewaesserraum_oereb.t_ili2db_seq'::regclass) AS t_id,
        basket.t_id,
        uuid_generate_v4() AS t_ili_tid
    FROM 
    (
        SELECT
            t_id
        FROM
            afu_gewaesserraum_oereb.t_ili2db_basket
        WHERE
            t_ili_tid = 'ch.so.afu.oereb_gewaesserraum' 
    ) AS basket
    RETURNING *
)
,
darstellungsdienst_multilingualuri AS 
(
    INSERT INTO
        afu_gewaesserraum_oereb.multilingualuri 
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
    afu_gewaesserraum_oereb.localiseduri 
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
    '${wmsHost}/wms/oereb?SERVICE=WMS&VERSION=1.3.0&REQUEST=GetMap&FORMAT=image%2Fpng&TRANSPARENT=true&LAYERS=ch.Gewaesserraum&STYLES=&SRS=EPSG%3A2056&CRS=EPSG%3A2056&DPI=96&WIDTH=1200&HEIGHT=1146&BBOX=2591250%2C1211350%2C2646050%2C1263700',
    darstellungsdienst_multilingualuri.t_id
FROM
    darstellungsdienst_multilingualuri
;


/*
 * (1) Nur Daten von Gemeinden, wo Gewässerraum freigeschaltet ist. Ansonsten müssen die Objekte
 * in der Nutzungsplanung verbleiben.
 * 
 */ 

WITH availabilty AS 
(
SELECT 
    gemeinde
FROM 
    agi_oereb_konfiguration.konfiguration_gemeindemitoerebk AS gemeindemitoereb 
    LEFT JOIN agi_oereb_konfiguration.themaref AS themaref 
    ON themaref.konfiguratn_gmndmtrebk_themen = gemeindemitoereb.t_id
WHERE 
    thema = 'ch.Gewaesserraum'
)
,
darstellungsdienst AS 
(
    SELECT
        darstellungsdienst.t_id,
        darstellungsdienst.t_basket AS basket_t_id,
        localiseduri.atext
    FROM 
        afu_gewaesserraum_oereb.transferstruktur_darstellungsdienst AS darstellungsdienst
        LEFT JOIN afu_gewaesserraum_oereb.multilingualuri AS multilingualuri  
        ON multilingualuri.transfrstrkstllngsdnst_verweiswms = darstellungsdienst.t_id 
        LEFT JOIN afu_gewaesserraum_oereb.localiseduri AS localiseduri 
        ON localiseduri.multilingualuri_localisedtext = multilingualuri.t_id 
)
,
eigentumsbeschraenkung AS (
    SELECT
        geobasisdaten_typ.t_id,
        darstellungsdienst.basket_t_id,
        'ch.Gewaesserraum' AS thema,
        geometrie.rechtsstatus,
        geometrie.publiziertab AS publiziertab,
        darstellungsdienst.t_id AS darstellungsdienst,
        amt.t_id AS zustaendigestelle,
        --geobasisdaten_typ.bezeichnung AS legendetext_de,
        'Gewässerraum' AS legendetext_de,
        --substring(geobasisdaten_typ.typ_kt FROM 2 FOR 3) AS artcode,
        'gewaesserraum' AS artcode,        
        'urn:fdc:ilismeta.interlis.ch:2022:Typ_Kanton_Gewaesserraum_Flaeche' AS artcodeliste,
        geometrie.geometrie 
    FROM
        arp_nutzungsplanung.nutzungsplanung_typ_grundnutzung AS geobasisdaten_typ
        INNER JOIN arp_nutzungsplanung.nutzungsplanung_grundnutzung AS geometrie
        ON geobasisdaten_typ.t_id = geometrie.typ_grundnutzung 
        LEFT JOIN darstellungsdienst
        ON darstellungsdienst.atext ILIKE '%ch.Gewaesserraum%'
        LEFT JOIN afu_gewaesserraum_oereb.amt_amt AS amt 
        ON substring(amt.t_ili_tid FROM 4 FOR 4) = geobasisdaten_typ.t_datasetname 
    WHERE 
        CAST(geobasisdaten_typ.t_datasetname AS int4) IN 
        (
            SELECT 
                gemeinde
            FROM 
                availabilty
        )
        AND 
        geobasisdaten_typ.typ_kt IN ('N161_kommunale_Uferschutzzone_innerhalb_Bauzone', 'N320_Gewaesser', 'N329_weitere_Zonen_fuer_Gewaesser_und_ihre_Ufer')
        AND 
        geometrie.rechtsstatus = 'inKraft'
        
    UNION ALL 
    
    SELECT
        geobasisdaten_typ.t_id,
        darstellungsdienst.basket_t_id,
        'ch.Gewaesserraum' AS thema,
        geometrie.rechtsstatus,
        geometrie.publiziertab AS publiziertab,
        darstellungsdienst.t_id AS darstellungsdienst,
        amt.t_id AS zustaendigestelle,
        --geobasisdaten_typ.bezeichnung AS legendetext_de,
        'Gewässerraum' AS legendetext_de,
        --substring(geobasisdaten_typ.typ_kt FROM 2 FOR 3) AS artcode,        
        'gewaesserraum' AS artcode,
        'urn:fdc:ilismeta.interlis.ch:2022:Typ_Kanton_Gewaesserraum_Flaeche' AS artcodeliste,
        geometrie.geometrie 
    FROM
        arp_nutzungsplanung.nutzungsplanung_typ_ueberlagernd_flaeche AS geobasisdaten_typ
        INNER JOIN arp_nutzungsplanung.nutzungsplanung_ueberlagernd_flaeche AS geometrie
        ON geobasisdaten_typ.t_id = geometrie.typ_ueberlagernd_flaeche 
        LEFT JOIN darstellungsdienst
        ON darstellungsdienst.atext ILIKE '%ch.Gewaesserraum%'
        LEFT JOIN afu_gewaesserraum_oereb.amt_amt AS amt 
        ON substring(amt.t_ili_tid FROM 4 FOR 4) = geobasisdaten_typ.t_datasetname 
    WHERE 
        CAST(geobasisdaten_typ.t_datasetname AS int4) IN 
        (
            SELECT 
                gemeinde
            FROM 
                availabilty
        )
        AND 
        geobasisdaten_typ.typ_kt = 'N528_kommunale_Uferschutzzone_ausserhalb_Bauzonen'
        AND 
        geometrie.rechtsstatus = 'inKraft'
        
    UNION ALL 
    
    SELECT
        geobasisdaten_typ.t_id,
        darstellungsdienst.basket_t_id,
        'ch.Gewaesserraum' AS thema,
        geometrie.rechtsstatus,
        geometrie.publiziertab AS publiziertab,
        darstellungsdienst.t_id AS darstellungsdienst,
        amt.t_id AS zustaendigestelle,
        --geobasisdaten_typ.bezeichnung AS legendetext_de,
        'Gewässerraum' AS legendetext_de,
        --substring(geobasisdaten_typ.typ_kt FROM 2 FOR 3) AS artcode,
        'gewaesserraum' AS artcode,
        'urn:fdc:ilismeta.interlis.ch:2022:Typ_Kanton_Gewaesserraum_Linie' AS artcodeliste,
        geometrie.geometrie 
    FROM
        arp_nutzungsplanung.erschlssngsplnung_typ_erschliessung_linienobjekt AS geobasisdaten_typ
        INNER JOIN arp_nutzungsplanung.erschlssngsplnung_erschliessung_linienobjekt AS geometrie
        ON geobasisdaten_typ.t_id = geometrie.typ_erschliessung_linienobjekt 
        LEFT JOIN darstellungsdienst
        ON darstellungsdienst.atext ILIKE '%ch.Gewaesserraum%'
        LEFT JOIN afu_gewaesserraum_oereb.amt_amt AS amt 
        ON substring(amt.t_ili_tid FROM 4 FOR 4) = geobasisdaten_typ.t_datasetname 
    WHERE 
        CAST(geobasisdaten_typ.t_datasetname AS int4) IN 
        (
            SELECT 
                gemeinde
            FROM 
                availabilty
        )
        AND 
        geobasisdaten_typ.typ_kt IN ('E727_Baulinie_Gewaesser', 'E729_weitere_kommunale_Baulinien')
        AND 
        geometrie.rechtsstatus = 'inKraft'    
)
,
legendeneintrag AS (
    INSERT INTO 
        afu_gewaesserraum_oereb.transferstruktur_legendeeintrag 
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
        nextval('afu_gewaesserraum_oereb.t_ili2db_seq'::regclass) AS legendeneintrag_t_id,
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
        LEFT JOIN afu_gewaesserraum_oereb.legendeneintraege_legendeneintrag AS eintrag
        ON (eigentumsbeschraenkung.artcode = eintrag.artcode AND eigentumsbeschraenkung.artcodeliste = eintrag.artcodeliste)
   RETURNING *
)
,
geometrie_flaeche AS (
    INSERT INTO 
        afu_gewaesserraum_oereb.transferstruktur_geometrie 
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
        nextval('afu_gewaesserraum_oereb.t_ili2db_seq'::regclass),
        basket_t_id,
        uuid_generate_v4(),
        geometrie,
        rechtsstatus,
        publiziertab,
        t_id
    FROM 
        eigentumsbeschraenkung
    WHERE 
        ST_GeometryType(geometrie) = 'ST_Polygon'
)
,
geometrie_linie AS (
    INSERT INTO 
        afu_gewaesserraum_oereb.transferstruktur_geometrie 
        (
            t_id,
            t_basket,
            t_ili_tid,
            linie,
            rechtsstatus,
            publiziertab,
            eigentumsbeschraenkung
        )
    SELECT 
        nextval('afu_gewaesserraum_oereb.t_ili2db_seq'::regclass),
        basket_t_id,
        uuid_generate_v4(),
        geometrie,
        rechtsstatus,
        publiziertab,
        t_id
    FROM 
        eigentumsbeschraenkung
    WHERE 
        ST_GeometryType(geometrie) = 'ST_LineString'
)
INSERT INTO
    afu_gewaesserraum_oereb.transferstruktur_eigentumsbeschraenkung 
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


/*
 * (1) In dokument_typ bewusst nur UNION, damit Dokument nicht mehrfache gelistet sind.
 * 
 */

WITH dokument_typ AS 
(
    SELECT 
        dokument.t_id,
        dokument.t_basket,
        dokument.t_datasetname,
        dokument.titel,
        dokument.offiziellertitel,
        dokument.abkuerzung,
        dokument.offiziellenr,
        dokument.rechtsstatus,
        dokument.publiziertab,
        dokument.rechtsvorschrift,
        typ_dokument.typ_grundnutzung AS typ_eigentumsbeschraenkung
    FROM 
        arp_nutzungsplanung.rechtsvorschrften_dokument AS dokument
        INNER JOIN arp_nutzungsplanung.nutzungsplanung_typ_grundnutzung_dokument AS typ_dokument
        ON typ_dokument.dokument = dokument.t_id         
        
    UNION  
    
    SELECT 
        dokument.t_id,
        dokument.t_basket,
        dokument.t_datasetname,
        dokument.titel,
        dokument.offiziellertitel,
        dokument.abkuerzung,
        dokument.offiziellenr,
        dokument.rechtsstatus,
        dokument.publiziertab,
        dokument.rechtsvorschrift,
        typ_dokument.typ_ueberlagernd_flaeche AS typ_eigentumsbeschraenkung
    FROM 
        arp_nutzungsplanung.rechtsvorschrften_dokument AS dokument
        INNER JOIN arp_nutzungsplanung.nutzungsplanung_typ_ueberlagernd_flaeche_dokument AS typ_dokument
        ON typ_dokument.dokument = dokument.t_id 

    UNION 
        
    SELECT 
        dokument.t_id,
        dokument.t_basket,
        dokument.t_datasetname,
        dokument.titel,
        dokument.offiziellertitel,
        dokument.abkuerzung,
        dokument.offiziellenr,
        dokument.rechtsstatus,
        dokument.publiziertab,
        dokument.rechtsvorschrift,
        typ_dokument.typ_erschliessung_linienobjekt AS typ_eigentumsbeschraenkung
    FROM 
        arp_nutzungsplanung.rechtsvorschrften_dokument AS dokument
        INNER JOIN arp_nutzungsplanung.erschlssngsplnung_typ_erschliessung_linienobjekt_dokument AS typ_dokument
        ON typ_dokument.dokument = dokument.t_id 
)
,
dokumente AS 
(
    INSERT INTO 
        afu_gewaesserraum_oereb.dokumente_dokument
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
        DISTINCT ON (dokument_typ.t_id)
        dokument_typ.t_id, 
        eigentumsbeschraenkung.t_basket,
        '_'||CAST(uuid_generate_v4() AS TEXT) AS t_ili_tid,
        CASE 
            WHEN dokument_typ.rechtsvorschrift IS TRUE THEN 'Rechtsvorschrift'
            ELSE 'Hinweis'
        END AS typ,
        dokument_typ.offiziellertitel AS titel_de,
        dokument_typ.abkuerzung AS abkuerzung_de,
        dokument_typ.offiziellenr AS offiziellenr_de,
        CASE
            WHEN dokument_typ.abkuerzung = 'RRB' OR dokument_typ.titel ILIKE '%Regierungsratsbeschluss%' THEN CAST(999 AS int4) 
            ELSE CAST(998 AS int4)
        END AS auzugindex,
        dokument_typ.rechtsstatus AS rechtsstatus,
        dokument_typ.publiziertab AS publiziertab,
        CASE
            WHEN dokument_typ.abkuerzung = 'RRB' OR dokument_typ.titel ILIKE '%Regierungsratsbeschluss%' THEN 
                (
                    SELECT 
                        t_id
                    FROM
                        afu_gewaesserraum_oereb.amt_amt 
                    WHERE
                        t_ili_tid = 'ch.so.sk'
                )
            ELSE
                (
                    SELECT 
                        t_id
                    FROM
                        afu_gewaesserraum_oereb.amt_amt 
                    WHERE
                        t_ili_tid = 'ch.' || dokument_typ.t_datasetname
                )
        END AS zustaendigestelle
    FROM 
        dokument_typ
        INNER JOIN afu_gewaesserraum_oereb.transferstruktur_eigentumsbeschraenkung AS eigentumsbeschraenkung 
        ON eigentumsbeschraenkung.t_id = dokument_typ.typ_eigentumsbeschraenkung
)
INSERT INTO
    afu_gewaesserraum_oereb.transferstruktur_hinweisvorschrift
    (
        t_id,
        t_basket,
        eigentumsbeschraenkung,
        vorschrift 
    )
SELECT 
    nextval('afu_gewaesserraum_oereb.t_ili2db_seq'::regclass),
    eigentumsbeschraenkung.t_basket,
    eigentumsbeschraenkung.t_id AS eigentumsbeschraenkung,
    dokument_typ.t_id AS vorschrift
FROM 
    dokument_typ
    INNER JOIN afu_gewaesserraum_oereb.transferstruktur_eigentumsbeschraenkung AS eigentumsbeschraenkung 
    ON eigentumsbeschraenkung.t_id = dokument_typ.typ_eigentumsbeschraenkung
;

WITH multilingualuri AS
(
    INSERT INTO
        afu_gewaesserraum_oereb.multilingualuri
        (
            t_id,
            t_basket,
            t_seq,
            dokumente_dokument_textimweb
        )
    SELECT
        nextval('afu_gewaesserraum_oereb.t_ili2db_seq'::regclass) AS t_id,
        basket.t_id,
        0 AS t_seq,
        dokumente_dokument.t_id AS dokumente_dokument_textimweb
    FROM
        afu_gewaesserraum_oereb.dokumente_dokument AS dokumente_dokument,
        (
            SELECT
                t_id
            FROM
                afu_gewaesserraum_oereb.t_ili2db_basket
            WHERE
                t_ili_tid = 'ch.so.afu.oereb_gewaesserraum' 
        ) AS basket
    RETURNING *
)
,
localiseduri AS 
(
    SELECT 
        nextval('afu_gewaesserraum_oereb.t_ili2db_seq'::regclass) AS t_id,
        basket.t_id AS basket_t_id,
        0 AS t_seq,
        'de' AS alanguage,
        textimweb AS atext,
        multilingualuri.t_id AS multilingualuri_localisedtext
    FROM
        arp_nutzungsplanung.rechtsvorschrften_dokument AS dokumente_dokument
        RIGHT JOIN multilingualuri 
        ON multilingualuri.dokumente_dokument_textimweb = dokumente_dokument.t_id,
        (
            SELECT
                t_id
            FROM
                afu_gewaesserraum_oereb.t_ili2db_basket
            WHERE
                t_ili_tid = 'ch.so.afu.oereb_gewaesserraum' 
        ) AS basket
)
INSERT INTO
    afu_gewaesserraum_oereb.localiseduri
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

