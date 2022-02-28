/*
 * (1) Es werden immer alle Darstellungsdienste eingefügt. Falls es zu einem 
 * Darstellungsdient keine Daten gibt, ist das exportierte XTF nicht
 * modellkonform.
 * Man könnte vorgängig rausfinden, ob es zu jedem Thema Daten gibt. Das 
 * dünkt aber übertrieben, weil viel Code entsteht.
 */

WITH themen AS 
(
    SELECT 
        'ch.Nutzungsplanung' AS thema,
        'ch.SO.NutzungsplanungGrundnutzung' AS subthema
    UNION ALL
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
    UNION ALL
    SELECT 
        'ch.Laermempfindlichkeitsstufen' AS thema,
        CAST(NULL AS text) AS subthema
)
,
darstellungsdienst AS
(
    SELECT
        nextval('arp_nutzungsplanung_oerebv2.t_ili2db_seq'::regclass) AS t_id,
        basket.t_id AS basket_t_id,
        uuid_generate_v4() AS t_ili_tid,
        themen.thema,
        themen.subthema
    FROM 
    (
        SELECT
            t_id
        FROM
            arp_nutzungsplanung_oerebv2.t_ili2db_basket
        WHERE
            t_ili_tid = 'ch.so.arp.oereb_nutzungsplanung' 
    ) AS basket, 
    themen
)
,
darstellungsdienst_insert AS (
    INSERT INTO 
        arp_nutzungsplanung_oerebv2.transferstruktur_darstellungsdienst 
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
        arp_nutzungsplanung_oerebv2.multilingualuri 
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
    arp_nutzungsplanung_oerebv2.localiseduri 
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
        arp_nutzungsplanung_oerebv2.transferstruktur_darstellungsdienst AS darstellungsdienst
        LEFT JOIN arp_nutzungsplanung_oerebv2.multilingualuri AS multilingualuri  
        ON multilingualuri.transfrstrkstllngsdnst_verweiswms = darstellungsdienst.t_id 
        LEFT JOIN arp_nutzungsplanung_oerebv2.localiseduri AS localiseduri 
        ON localiseduri.multilingualuri_localisedtext = multilingualuri.t_id 
)
,
eigentumsbeschraenkung AS (
    -- Durch die Joins enstehen mehrfache Eigentumsbeschränkungen.
    -- Diese werden beim Insert wieder entfernt (distinct on).
    SELECT
        geobasisdaten_typ.t_id,
        darstellungsdienst.basket_t_id,
        'ch.Nutzungsplanung' AS thema,
        'ch.SO.NutzungsplanungGrundnutzung' AS subthema,
        geometrie.rechtsstatus,
        geometrie.publiziertab AS publiziertab,
        darstellungsdienst.t_id AS darstellungsdienst,
        amt.t_id AS zustaendigestelle,
        geobasisdaten_typ.bezeichnung AS legendetext_de,
        geobasisdaten_typ.code_kommunal AS artcode,        
        'urn:fdc:ilismeta.interlis.ch:2017:NP_Typ_Kanton_Grundnutzung.'||geobasisdaten_typ.t_datasetname AS artcodeliste,
        geometrie.geometrie 
    FROM
        arp_nutzungsplanung.nutzungsplanung_typ_grundnutzung AS geobasisdaten_typ
        INNER JOIN arp_nutzungsplanung.nutzungsplanung_grundnutzung AS geometrie
        ON geobasisdaten_typ.t_id = geometrie.typ_grundnutzung 
        LEFT JOIN darstellungsdienst
        ON darstellungsdienst.atext ILIKE '%ch.SO.NutzungsplanungGrundnutzung%'
        LEFT JOIN arp_nutzungsplanung_oerebv2.amt_amt AS amt 
        ON substring(amt.t_ili_tid FROM 4 FOR 4) = geobasisdaten_typ.t_datasetname 
    WHERE 
        typ_kt NOT IN 
        (
            'N180_Verkehrszone_Strasse',
            'N181_Verkehrszone_Bahnareal',
            'N182_Verkehrszone_Flugplatzareal',
            'N189_weitere_Verkehrszonen',
            'N210_Landwirtschaftszone',
            'N320_Gewaesser',
            'N329_weitere_Zonen_fuer_Gewaesser_und_ihre_Ufer',
            'N420_Verkehrsflaeche_Strasse', 
            'N421_Verkehrsflaeche_Bahnareal', 
            'N422_Verkehrsflaeche_Flugplatzareal', 
            'N429_weitere_Verkehrsflaechen', 
            'N430_Reservezone_Wohnzone_Mischzone_Kernzone_Zentrumszone',
            'N431_Reservezone_Arbeiten',
            'N432_Reservezone_OeBA',
            'N439_Reservezone',
            'N440_Wald'
        )
        AND 
        geometrie.rechtsstatus = 'inKraft'
)
,
legendeneintrag AS (
    INSERT INTO 
        arp_nutzungsplanung_oerebv2.transferstruktur_legendeeintrag 
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
        nextval('arp_nutzungsplanung_oerebv2.t_ili2db_seq'::regclass) AS t_id,
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
        LEFT JOIN arp_nutzungsplanung_oerebv2.legendeneintraege_legendeneintrag AS eintrag
        ON (substring(eigentumsbeschraenkung.artcode FROM 1 FOR 3) = eintrag.artcode AND eigentumsbeschraenkung.artcodeliste LIKE '%'||eintrag.artcodeliste||'%')
   RETURNING *
)
,
geometrie_flaeche AS (
    INSERT INTO 
        arp_nutzungsplanung_oerebv2.transferstruktur_geometrie 
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
        nextval('arp_nutzungsplanung_oerebv2.t_ili2db_seq'::regclass),                    
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
INSERT INTO
    arp_nutzungsplanung_oerebv2.transferstruktur_eigentumsbeschraenkung 
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
)
,
dokumente AS 
(
    INSERT INTO 
        arp_nutzungsplanung_oerebv2.dokumente_dokument
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
                        arp_nutzungsplanung_oerebv2.amt_amt 
                    WHERE
                        t_ili_tid = 'ch.so.sk'
                )
            ELSE
                (
                    SELECT 
                        t_id
                    FROM
                        arp_nutzungsplanung_oerebv2.amt_amt 
                    WHERE
                        t_ili_tid = 'ch.' || dokument_typ.t_datasetname
                )
        END AS zustaendigestelle
    FROM 
        dokument_typ
        INNER JOIN arp_nutzungsplanung_oerebv2.transferstruktur_eigentumsbeschraenkung AS eigentumsbeschraenkung 
        ON eigentumsbeschraenkung.t_id = dokument_typ.typ_eigentumsbeschraenkung
)

INSERT INTO
    arp_nutzungsplanung_oerebv2.transferstruktur_hinweisvorschrift
    (
        t_id,
        t_basket,
        eigentumsbeschraenkung,
        vorschrift 
    )
SELECT 
    nextval('arp_nutzungsplanung_oerebv2.t_ili2db_seq'::regclass),
    eigentumsbeschraenkung.t_basket,
    eigentumsbeschraenkung.t_id AS eigentumsbeschraenkung,
    dokument_typ.t_id AS vorschrift
FROM 
    dokument_typ
    INNER JOIN arp_nutzungsplanung_oerebv2.transferstruktur_eigentumsbeschraenkung AS eigentumsbeschraenkung 
    ON eigentumsbeschraenkung.t_id = dokument_typ.typ_eigentumsbeschraenkung
;

WITH multilingualuri AS
(
    INSERT INTO
        arp_nutzungsplanung_oerebv2.multilingualuri
        (
            t_id,
            t_basket,
            t_seq,
            dokumente_dokument_textimweb
        )
    SELECT
        nextval('arp_nutzungsplanung_oerebv2.t_ili2db_seq'::regclass) AS t_id,
        basket.t_id,
        0 AS t_seq,
        dokumente_dokument.t_id AS dokumente_dokument_textimweb
    FROM
        arp_nutzungsplanung_oerebv2.dokumente_dokument AS dokumente_dokument,
        (
            SELECT
                t_id
            FROM
                arp_nutzungsplanung_oerebv2.t_ili2db_basket
            WHERE
                t_ili_tid = 'ch.so.arp.oereb_nutzungsplanung' 
        ) AS basket
    RETURNING *
)
,
localiseduri AS 
(
    SELECT 
        nextval('arp_nutzungsplanung_oerebv2.t_ili2db_seq'::regclass) AS t_id,
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
                arp_nutzungsplanung_oerebv2.t_ili2db_basket
            WHERE
                t_ili_tid = 'ch.so.arp.oereb_nutzungsplanung' 
        ) AS basket
)
INSERT INTO
    arp_nutzungsplanung_oerebv2.localiseduri
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
