/**
 * (1) Es werden immer alle Darstellungsdienste eingefügt. Falls es zu einem 
 * Darstellungsdient keine Daten gibt, ist das exportierte XTF nicht
 * modellkonform.
 * Aus diesem Grund werden zuletzt nicht-verwendete WMS wieder gelöscht.
 * 
 * (2) Im Kantons-Dataset gibt es nur drei Themen. 
 */

WITH themen AS 
(
    SELECT 
        'ch.Nutzungsplanung' AS thema,
        'ch.SO.NutzungsplanungUeberlagernd' AS subthema
    UNION ALL
    SELECT 
        'ch.Nutzungsplanung' AS thema,
        'ch.SO.NutzungsplanungSondernutzungsplaene' AS subthema
    UNION ALL
    SELECT 
        'ch.Nutzungsplanung' AS thema,
        'ch.SO.Baulinien' AS subthema
)
,
darstellungsdienst AS
(
    SELECT
        nextval('arp_nutzungsplanung_kanton_oerebv2.t_ili2db_seq'::regclass) AS t_id,
        basket.t_id AS basket_t_id,
        uuid_generate_v4() AS t_ili_tid,
        themen.thema,
        themen.subthema
    FROM 
    (
        SELECT
            t_id
        FROM
            arp_nutzungsplanung_kanton_oerebv2.t_ili2db_basket
        WHERE
            t_ili_tid = 'ch.so.arp.oereb_nutzungsplanung_kantonal' 
    ) AS basket, 
    themen
)
,
darstellungsdienst_insert AS (
    INSERT INTO 
        arp_nutzungsplanung_kanton_oerebv2.transferstruktur_darstellungsdienst 
        (
            t_id,
            t_basket,
            t_ili_tid            
        )         
    SELECT 
        t_id,
        basket_t_id,
        t_ili_tid
    FROM 
        darstellungsdienst
)
,
darstellungsdienst_multilingualuri AS 
(
    INSERT INTO
        arp_nutzungsplanung_kanton_oerebv2.multilingualuri 
        (
            t_basket,
            t_seq, 
            transfrstrkstllngsdnst_verweiswms
        )
    SELECT 
        basket_t_id,
        0,
        t_id
    FROM 
        darstellungsdienst
    RETURNING *
)
INSERT INTO 
    arp_nutzungsplanung_kanton_oerebv2.localiseduri 
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
    CASE
        WHEN darstellungsdienst.subthema IS NULL THEN '${wmsHost}/wms/oereb?SERVICE=WMS&VERSION=1.3.0&REQUEST=GetMap&FORMAT=image%2Fpng&TRANSPARENT=true&LAYERS='||darstellungsdienst.thema||'&STYLES=&SRS=EPSG%3A2056&CRS=EPSG%3A2056&DPI=96&WIDTH=1200&HEIGHT=1146&BBOX=2591250%2C1211350%2C2646050%2C1263700'
        ELSE '${wmsHost}/wms/oereb?SERVICE=WMS&VERSION=1.3.0&REQUEST=GetMap&FORMAT=image%2Fpng&TRANSPARENT=true&LAYERS='||darstellungsdienst.subthema||'&STYLES=&SRS=EPSG%3A2056&CRS=EPSG%3A2056&DPI=96&WIDTH=1200&HEIGHT=1146&BBOX=2591250%2C1211350%2C2646050%2C1263700'
    END AS atext,
    darstellungsdienst_multilingualuri.t_id
FROM
    darstellungsdienst_multilingualuri
    LEFT JOIN darstellungsdienst
    ON darstellungsdienst.t_id = darstellungsdienst_multilingualuri.transfrstrkstllngsdnst_verweiswms
;

WITH darstellungsdienst AS 
(
    SELECT
        darstellungsdienst.t_id,
        darstellungsdienst.t_basket AS basket_t_id,
        localiseduri.atext
    FROM 
        arp_nutzungsplanung_kanton_oerebv2.transferstruktur_darstellungsdienst AS darstellungsdienst
        LEFT JOIN arp_nutzungsplanung_kanton_oerebv2.multilingualuri AS multilingualuri  
        ON multilingualuri.transfrstrkstllngsdnst_verweiswms = darstellungsdienst.t_id 
        LEFT JOIN arp_nutzungsplanung_kanton_oerebv2.localiseduri AS localiseduri 
        ON localiseduri.multilingualuri_localisedtext = multilingualuri.t_id 
)
,
eigentumsbeschraenkung AS (
    -- Durch die Joins enstehen mehrfache Eigentumsbeschränkungen.
    -- Diese werden beim Insert wieder entfernt (distinct on).
        
    -- Überlagernd (Fläche)
    -- N526, N527, N690
    -- ARP
    SELECT
        geobasisdaten_typ.t_id,
        darstellungsdienst.basket_t_id,
        'ch.Nutzungsplanung' AS thema,
        'ch.SO.NutzungsplanungUeberlagernd' AS subthema,
        geometrie.rechtsstatus,
        geometrie.publiziertab AS publiziertab,
        darstellungsdienst.t_id AS darstellungsdienst,
        amt.t_id AS zustaendigestelle,
        geobasisdaten_typ.bezeichnung AS legendetext_de,
        geobasisdaten_typ.code_kommunal AS artcode,        
        'urn:fdc:ilismeta.interlis.ch:2022:Nutzungsplanung_kantonal_Ueberlagernd_Flaeche' AS artcodeliste,
        geometrie.geometrie 
    FROM
        arp_nutzungsplanung_kanton.nutzungsplanung_typ_ueberlagernd_flaeche AS geobasisdaten_typ
        INNER JOIN arp_nutzungsplanung_kanton.nutzungsplanung_ueberlagernd_flaeche AS geometrie
        ON geobasisdaten_typ.t_id = geometrie.typ_ueberlagernd_flaeche 
        LEFT JOIN darstellungsdienst
        ON darstellungsdienst.atext ILIKE '%ch.SO.NutzungsplanungUeberlagernd%'
        LEFT JOIN arp_nutzungsplanung_kanton_oerebv2.amt_amt AS amt 
        ON amt.t_ili_tid = 'ch.so.arp'
    WHERE
        typ_kt IN ('N526_kantonale_Landwirtschafts_und_Schutzzone_Witi', 'N527_kantonale_Uferschutzzone', 'N690_kantonales_Vorranggebiet_Natur_und_Landschaft')
        AND
        geometrie.rechtsstatus = 'inKraft'
    
    UNION ALL
        
    -- Sondernutzungspläne
    -- N610
    -- ARP
    SELECT
        geobasisdaten_typ.t_id,
        darstellungsdienst.basket_t_id,
        'ch.Nutzungsplanung' AS thema,
        'ch.SO.NutzungsplanungSondernutzungsplaene' AS subthema,
        geometrie.rechtsstatus,
        geometrie.publiziertab AS publiziertab,
        darstellungsdienst.t_id AS darstellungsdienst,
        amt.t_id AS zustaendigestelle,
        geobasisdaten_typ.bezeichnung AS legendetext_de,
        geobasisdaten_typ.code_kommunal AS artcode,        
        'urn:fdc:ilismeta.interlis.ch:2022:Nutzungsplanung_kantonal_Ueberlagernd_Flaeche' AS artcodeliste,
        geometrie.geometrie 
    FROM
        arp_nutzungsplanung_kanton.nutzungsplanung_typ_ueberlagernd_flaeche AS geobasisdaten_typ
        INNER JOIN arp_nutzungsplanung_kanton.nutzungsplanung_ueberlagernd_flaeche AS geometrie
        ON geobasisdaten_typ.t_id = geometrie.typ_ueberlagernd_flaeche 
        LEFT JOIN darstellungsdienst
        ON darstellungsdienst.atext ILIKE '%ch.SO.NutzungsplanungSondernutzungsplaene%'
        LEFT JOIN arp_nutzungsplanung_kanton_oerebv2.amt_amt AS amt 
        ON amt.t_ili_tid = 'ch.so.arp'
    WHERE
        typ_kt = 'N610_Perimeter_kantonaler_Nutzungsplan'
        AND
        geometrie.rechtsstatus = 'inKraft'

    UNION ALL    
        
    -- Baulinien
    -- N711, N712, N713, N714, N715, N719
    -- AVT
    SELECT
        geobasisdaten_typ.t_id,
        darstellungsdienst.basket_t_id,            
        'ch.Nutzungsplanung' AS thema,
        'ch.SO.Baulinien' AS subthema,
        geometrie.rechtsstatus,
        geometrie.publiziertab AS publiziertab,
        darstellungsdienst.t_id AS darstellungsdienst,
        amt.t_id AS zustaendigestelle,
        geobasisdaten_typ.bezeichnung AS legendetext_de,
        geobasisdaten_typ.code_kommunal AS artcode,        
        'urn:fdc:ilismeta.interlis.ch:2022:Nutzungsplanung_kantonal_Erschliessung_Linienobjekt' AS artcodeliste,
        geometrie.geometrie 
    FROM
        arp_nutzungsplanung_kanton.erschlssngsplnung_typ_erschliessung_linienobjekt AS geobasisdaten_typ
        INNER JOIN arp_nutzungsplanung_kanton.erschlssngsplnung_erschliessung_linienobjekt AS geometrie
        ON geobasisdaten_typ.t_id = geometrie.typ_erschliessung_linienobjekt 
        LEFT JOIN darstellungsdienst
        ON darstellungsdienst.atext ILIKE '%ch.SO.Baulinien%'
        LEFT JOIN arp_nutzungsplanung_kanton_oerebv2.amt_amt AS amt 
        ON amt.t_ili_tid = 'ch.so.avt'
    WHERE
        geometrie.rechtsstatus = 'inKraft'
)
,
legendeneintrag AS (
    INSERT INTO 
        arp_nutzungsplanung_kanton_oerebv2.transferstruktur_legendeeintrag 
        (
            t_id,
            t_basket,
            t_ili_tid,
            symbol,
            legendetext_de,
            artcode,
            artcodeliste,
            thema,
            subthema,
            darstellungsdienst    
        )
    SELECT 
        DISTINCT ON (artcode, artcodeliste)
        nextval('arp_nutzungsplanung_kanton_oerebv2.t_ili2db_seq'::regclass) AS t_id,
        basket_t_id,
        uuid_generate_v4(),
        eintrag.symbol,
        legendetext_de,
        eigentumsbeschraenkung.artcode,
        eigentumsbeschraenkung.artcodeliste,
        eigentumsbeschraenkung.thema,
        eigentumsbeschraenkung.subthema,
        darstellungsdienst
    FROM 
        eigentumsbeschraenkung 
        LEFT JOIN arp_nutzungsplanung_kanton_oerebv2.legendeneintraege_legendeneintrag AS eintrag
        ON (substring(eigentumsbeschraenkung.artcode FROM 1 FOR 3) = eintrag.artcode AND eigentumsbeschraenkung.artcodeliste LIKE '%'||eintrag.artcodeliste||'%')
   RETURNING *
)
,
geometrie_flaeche AS (
    INSERT INTO 
        arp_nutzungsplanung_kanton_oerebv2.transferstruktur_geometrie 
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
        nextval('arp_nutzungsplanung_kanton_oerebv2.t_ili2db_seq'::regclass),                    
        basket_t_id,
        uuid_generate_v4(),
        ST_ReducePrecision(geometrie, 0.001),
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
        arp_nutzungsplanung_kanton_oerebv2.transferstruktur_geometrie 
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
        nextval('arp_nutzungsplanung_kanton_oerebv2.t_ili2db_seq'::regclass),                    
        basket_t_id,
        uuid_generate_v4(),
        ST_ReducePrecision(geometrie, 0.001),
        rechtsstatus,
        publiziertab,
        t_id
    FROM 
        eigentumsbeschraenkung
    WHERE 
        ST_GeometryType(geometrie) = 'ST_LineString'
)
INSERT INTO
    arp_nutzungsplanung_kanton_oerebv2.transferstruktur_eigentumsbeschraenkung 
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
 * (1) In dokument_typ UNION ALL, weil bei dokument distincted wird. 
 * ACHTUNG: Prüfen, ob nun nicht doch was doppelt erscheint. document_typ
 * wird für die Zwischentabelle verwendet.
 * 
 */

WITH dokument_typ AS 
(    
    SELECT 
        dokument.t_id,
        dokument.titel,
        dokument.offiziellertitel,
        dokument.abkuerzung,
        dokument.offiziellenr,
        dokument.rechtsstatus,
        dokument.publiziertab,
        dokument.rechtsvorschrift,
        typ_dokument.typ_ueberlagernd_flaeche AS typ_eigentumsbeschraenkung
    FROM 
        arp_nutzungsplanung_kanton.rechtsvorschrften_dokument AS dokument
        INNER JOIN arp_nutzungsplanung_kanton.nutzungsplanung_typ_ueberlagernd_flaeche_dokument AS typ_dokument
        ON typ_dokument.dokument = dokument.t_id
                    
    UNION ALL 
    
    SELECT 
        dokument.t_id,
        dokument.titel,
        dokument.offiziellertitel,
        dokument.abkuerzung,
        dokument.offiziellenr,
        dokument.rechtsstatus,
        dokument.publiziertab,
        dokument.rechtsvorschrift,
        typ_dokument.typ_erschliessung_linienobjekt AS typ_eigentumsbeschraenkung
    FROM 
        arp_nutzungsplanung_kanton.rechtsvorschrften_dokument AS dokument
        INNER JOIN arp_nutzungsplanung_kanton.erschlssngsplnung_typ_erschliessung_linienobjekt_dokument AS typ_dokument
        ON typ_dokument.dokument = dokument.t_id        
)
,
dokumente AS 
(
    INSERT INTO 
        arp_nutzungsplanung_kanton_oerebv2.dokumente_dokument
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
                        arp_nutzungsplanung_kanton_oerebv2.amt_amt 
                    WHERE
                        t_ili_tid = 'ch.so.sk'
                )
            WHEN legendeneintrag.artcode IN ('5270', '5260', '6100', '6900') AND (dokument_typ.abkuerzung != 'RRB' OR dokument_typ.titel NOT ILIKE '%Regierungsratsbeschluss%') THEN 
                (
                    SELECT 
                        t_id
                    FROM
                        arp_nutzungsplanung_kanton_oerebv2.amt_amt 
                    WHERE
                        t_ili_tid = 'ch.so.arp'            
                )
            ELSE
                (
                    SELECT 
                        t_id
                    FROM
                        arp_nutzungsplanung_kanton_oerebv2.amt_amt 
                    WHERE
                        t_ili_tid = 'ch.so.avt'
                )
        END AS zustaendigestelle
    FROM 
        dokument_typ
        INNER JOIN arp_nutzungsplanung_kanton_oerebv2.transferstruktur_eigentumsbeschraenkung AS eigentumsbeschraenkung 
        ON eigentumsbeschraenkung.t_id = dokument_typ.typ_eigentumsbeschraenkung
        LEFT JOIN arp_nutzungsplanung_kanton_oerebv2.transferstruktur_legendeeintrag AS legendeneintrag 
        ON eigentumsbeschraenkung.legende = legendeneintrag.t_id 
)
INSERT INTO
    arp_nutzungsplanung_kanton_oerebv2.transferstruktur_hinweisvorschrift
    (
        t_id,
        t_basket,
        eigentumsbeschraenkung,
        vorschrift 
    )
SELECT 
    nextval('arp_nutzungsplanung_kanton_oerebv2.t_ili2db_seq'::regclass),
    eigentumsbeschraenkung.t_basket,
    eigentumsbeschraenkung.t_id AS eigentumsbeschraenkung,
    dokument_typ.t_id AS vorschrift
FROM 
    dokument_typ
    INNER JOIN arp_nutzungsplanung_kanton_oerebv2.transferstruktur_eigentumsbeschraenkung AS eigentumsbeschraenkung 
    ON eigentumsbeschraenkung.t_id = dokument_typ.typ_eigentumsbeschraenkung
;

WITH multilingualuri AS
(
    INSERT INTO
        arp_nutzungsplanung_kanton_oerebv2.multilingualuri
        (
            t_id,
            t_basket,
            t_seq,
            dokumente_dokument_textimweb
        )
    SELECT
        nextval('arp_nutzungsplanung_kanton_oerebv2.t_ili2db_seq'::regclass) AS t_id,
        basket.t_id,
        0 AS t_seq,
        dokumente_dokument.t_id AS dokumente_dokument_textimweb
    FROM
        arp_nutzungsplanung_kanton_oerebv2.dokumente_dokument AS dokumente_dokument,
        (
            SELECT
                t_id
            FROM
                arp_nutzungsplanung_kanton_oerebv2.t_ili2db_basket
            WHERE
                t_ili_tid = 'ch.so.arp.oereb_nutzungsplanung' 
        ) AS basket
    RETURNING *
)
,
localiseduri AS 
(
    SELECT 
        nextval('arp_nutzungsplanung_kanton_oerebv2.t_ili2db_seq'::regclass) AS t_id,
        basket.t_id AS basket_t_id,
        0 AS t_seq,
        'de' AS alanguage,
        textimweb AS atext,
        multilingualuri.t_id AS multilingualuri_localisedtext
    FROM
        arp_nutzungsplanung_kanton.rechtsvorschrften_dokument AS dokumente_dokument
        RIGHT JOIN multilingualuri 
        ON multilingualuri.dokumente_dokument_textimweb = dokumente_dokument.t_id,
        (
            SELECT
                t_id
            FROM
                arp_nutzungsplanung_kanton_oerebv2.t_ili2db_basket
            WHERE
                t_ili_tid = 'ch.so.arp.oereb_nutzungsplanung_kantonal' 
        ) AS basket
)
INSERT INTO
    arp_nutzungsplanung_kanton_oerebv2.localiseduri
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

/**
 * Es werden die Darstellungsdienste gelöscht, die nicht verwendet werden. Sonst
 * gibt es Validierungsfehler. Ich teste nur ggü den Eigentumsbeschränkungen. 
 * Eigentlich müsste auch ggü den Legenden getestest werden. In unserem Fall scheint
 * mir das nicht notwendig, weil es keine Legenden ohne Eigentumsbeschränkung geben
 * darf. 
 */
WITH dangling_darstellungsdienst AS 
(
    SELECT 
        darstellungsdienst.t_id
    FROM
        arp_nutzungsplanung_kanton_oerebv2.transferstruktur_darstellungsdienst AS darstellungsdienst
        LEFT JOIN arp_nutzungsplanung_kanton_oerebv2.transferstruktur_eigentumsbeschraenkung AS eigentumsbeschrankung
        ON darstellungsdienst.t_id = eigentumsbeschrankung.darstellungsdienst 
    WHERE 
        eigentumsbeschrankung.t_id IS NULL       
)
,
dangling_multilingualuri AS 
(
    SELECT 
        muri.t_id
    FROM 
        arp_nutzungsplanung_kanton_oerebv2.multilingualuri AS muri
        INNER JOIN dangling_darstellungsdienst AS darstellungsdienst 
        ON muri.transfrstrkstllngsdnst_verweiswms = darstellungsdienst.t_id
)
,
dangling_localiseduri AS 
(
    SELECT 
        luri.t_id
    FROM 
        arp_nutzungsplanung_kanton_oerebv2.localiseduri AS luri
        INNER JOIN dangling_multilingualuri AS multilingualuri 
        ON luri.multilingualuri_localisedtext = multilingualuri.t_id
)
,
delete_dangling_localiseduri AS 
(
    DELETE FROM 
        arp_nutzungsplanung_kanton_oerebv2.localiseduri
    WHERE 
        t_id IN 
        (
            SELECT 
                t_id 
            FROM 
                dangling_localiseduri
        )
)
,
delete_dangling_multilingualuri AS 
(
    DELETE FROM 
        arp_nutzungsplanung_kanton_oerebv2.multilingualuri m 
    WHERE 
        t_id IN 
        (
            SELECT 
                t_id 
            FROM 
                dangling_multilingualuri
        )
)
DELETE FROM 
    arp_nutzungsplanung_kanton_oerebv2.transferstruktur_darstellungsdienst 
    WHERE 
        t_id IN 
        (
            SELECT 
                t_id 
            FROM 
                dangling_darstellungsdienst
        )
;