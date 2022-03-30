/*
 * (1) Es werden immer alle Darstellungsdienste eingefügt. Falls es zu einem 
 * Darstellungsdient keine Daten gibt, ist das exportierte XTF nicht
 * modellkonform.
 * Aus diesem Grund werden zuletzt nicht-verwendete WMS wieder gelöscht.
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
    UNION ALL
    SELECT 
        'ch.Waldabstandslinien' AS thema,
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
        agi_konfiguration_oerebv2.konfiguration_gemeindemitoerebk AS gemeindemitoereb 
        LEFT JOIN agi_konfiguration_oerebv2.themaref AS themaref 
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

    -- Grundnutzung
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
        arp_nutzungsplanung_v1.nutzungsplanung_typ_grundnutzung AS geobasisdaten_typ
        INNER JOIN arp_nutzungsplanung_v1.nutzungsplanung_grundnutzung AS geometrie
        ON geobasisdaten_typ.t_id = geometrie.typ_grundnutzung 
        LEFT JOIN darstellungsdienst
        ON darstellungsdienst.atext ILIKE '%ch.SO.NutzungsplanungGrundnutzung%'
        LEFT JOIN arp_nutzungsplanung_oerebv2.amt_amt AS amt 
        ON substring(amt.t_ili_tid FROM 4 FOR 4) = geobasisdaten_typ.t_datasetname 
    WHERE
        (
            typ_kt NOT IN 
            (
                'N161_kommunale_Uferschutzzone_innerhalb_Bauzone', -- gilt nicht, falls Gemeinde Gewässerraum ausgeschieden hat. Siehe 'OR'
                'N180_Verkehrszone_Strasse',
                'N181_Verkehrszone_Bahnareal',
                'N182_Verkehrszone_Flugplatzareal',
                'N189_weitere_Verkehrszonen',
                'N210_Landwirtschaftszone',
                'N320_Gewaesser', -- gilt immer
                'N329_weitere_Zonen_fuer_Gewaesser_und_ihre_Ufer', -- gilt immer
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
            OR 
            (
                typ_kt = 'N161_kommunale_Uferschutzzone_innerhalb_Bauzone' 
                AND 
                CAST(geobasisdaten_typ.t_datasetname AS int4) NOT IN 
                (
                    SELECT 
                        gemeinde
                    FROM 
                        availabilty
                )
            )
        )
        AND 
        geometrie.rechtsstatus IN ('inKraft', 'AenderungMitVorwirkung')
        
        UNION ALL 
        
        -- Überlagernd (Fläche)
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
            'urn:fdc:ilismeta.interlis.ch:2017:NP_Typ_Kanton_Ueberlagernd_Flaeche.'||geobasisdaten_typ.t_datasetname AS artcodeliste,
            geometrie.geometrie 
        FROM
            arp_nutzungsplanung_v1.nutzungsplanung_typ_ueberlagernd_flaeche AS geobasisdaten_typ
            INNER JOIN arp_nutzungsplanung_v1.nutzungsplanung_ueberlagernd_flaeche AS geometrie
            ON geobasisdaten_typ.t_id = geometrie.typ_ueberlagernd_flaeche 
            LEFT JOIN darstellungsdienst
            ON darstellungsdienst.atext ILIKE '%ch.SO.NutzungsplanungUeberlagernd%'
            LEFT JOIN arp_nutzungsplanung_oerebv2.amt_amt AS amt 
            ON substring(amt.t_ili_tid FROM 4 FOR 4) = geobasisdaten_typ.t_datasetname 
        WHERE
            (
                typ_kt IN 
                (
                    'N510_ueberlagernde_Ortsbildschutzzone',
                    'N523_Landschaftsschutzzone',
                    'N526_kantonale_Landwirtschafts_und_Schutzzone_Witi',
                    'N527_kantonale_Uferschutzzone',
                    'N529_weitere_Schutzzonen_fuer_Lebensraeume_und_Landschaften',
                    'N590_Hofstattzone_Freihaltezone',
                    'N591_Bauliche_Einschraenkungen',
                    'N690_kantonales_Vorranggebiet_Natur_und_Landschaft',
                    'N691_kommunales_Vorranggebiet_Natur_und_Landschaft',
                    'N692_Planungszone',
                    --'N699_weitere_flaechenbezogene_Festlegungen_NP',
                    'N812_geologisches_Objekt',
                    'N813_Naturobjekt',
                    'N822_schuetzenswertes_Kulturobjekt',
                    'N823_erhaltenswertes_Kulturobjekt'
                )
                OR
                (
                    typ_kt = 'N599_weitere_ueberlagernde_Nutzungszonen' AND verbindlichkeit = 'Nutzungsplanfestlegung'
                ) 
                OR
                (
                    typ_kt = 'N699_weitere_flaechenbezogene_Festlegungen_NP' AND verbindlichkeit = 'Nutzungsplanfestlegung'
                ) 
                OR 
                (
                    -- Falls Gewässerraum nicht rechtsgültig ausgeschieden ist,
                    -- wird dieser Typ weiterhin bei der Nutzungsplanung geführt.
                    typ_kt = 'N528_kommunale_Uferschutzzone_ausserhalb_Bauzonen'  
                    AND 
                    CAST(geobasisdaten_typ.t_datasetname AS int4) NOT IN 
                    (
                        SELECT 
                            gemeinde
                        FROM 
                            availabilty
                    )
                )
            )
            AND 
        geometrie.rechtsstatus IN ('inKraft', 'AenderungMitVorwirkung')

        UNION ALL
            
        -- Überlagernd (Linie)
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
            'urn:fdc:ilismeta.interlis.ch:2017:NP_Typ_Kanton_Ueberlagernd_Linie.'||geobasisdaten_typ.t_datasetname AS artcodeliste,
            geometrie.geometrie 
        FROM
            arp_nutzungsplanung_v1.nutzungsplanung_typ_ueberlagernd_linie AS geobasisdaten_typ
            INNER JOIN arp_nutzungsplanung_v1.nutzungsplanung_ueberlagernd_linie AS geometrie
            ON geobasisdaten_typ.t_id = geometrie.typ_ueberlagernd_linie 
            LEFT JOIN darstellungsdienst
            ON darstellungsdienst.atext ILIKE '%ch.SO.NutzungsplanungUeberlagernd%'
            LEFT JOIN arp_nutzungsplanung_oerebv2.amt_amt AS amt 
            ON substring(amt.t_ili_tid FROM 4 FOR 4) = geobasisdaten_typ.t_datasetname 
        WHERE
            (
                typ_kt = 'N799_weitere_linienbezogene_Festlegungen_NP' AND verbindlichkeit = 'Nutzungsplanfestlegung'
            )
            AND 
        geometrie.rechtsstatus IN ('inKraft', 'AenderungMitVorwirkung')

        UNION ALL
            
        -- Überlagernd (Punkt)
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
            'urn:fdc:ilismeta.interlis.ch:2017:NP_Typ_Kanton_Ueberlagernd_Punkt.'||geobasisdaten_typ.t_datasetname AS artcodeliste,
            geometrie.geometrie 
        FROM
            arp_nutzungsplanung_v1.nutzungsplanung_typ_ueberlagernd_punkt AS geobasisdaten_typ
            INNER JOIN arp_nutzungsplanung_v1.nutzungsplanung_ueberlagernd_punkt AS geometrie
            ON geobasisdaten_typ.t_id = geometrie.typ_ueberlagernd_punkt
            LEFT JOIN darstellungsdienst
            ON darstellungsdienst.atext ILIKE '%ch.SO.NutzungsplanungUeberlagernd%'
            LEFT JOIN arp_nutzungsplanung_oerebv2.amt_amt AS amt 
            ON substring(amt.t_ili_tid FROM 4 FOR 4) = geobasisdaten_typ.t_datasetname 
        WHERE
            (
                typ_kt = 'N899_weitere_punktbezogene_Festlegungen_NP' AND verbindlichkeit = 'Nutzungsplanfestlegung'
            )
            AND 
        geometrie.rechtsstatus IN ('inKraft', 'AenderungMitVorwirkung')
            
        UNION ALL 
        
        -- Sondernutzungspläne
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
            'urn:fdc:ilismeta.interlis.ch:2017:NP_Typ_Kanton_Ueberlagernd_Flaeche.'||geobasisdaten_typ.t_datasetname AS artcodeliste,
            geometrie.geometrie 
        FROM
            arp_nutzungsplanung_v1.nutzungsplanung_typ_ueberlagernd_flaeche AS geobasisdaten_typ
            INNER JOIN arp_nutzungsplanung_v1.nutzungsplanung_ueberlagernd_flaeche AS geometrie
            ON geobasisdaten_typ.t_id = geometrie.typ_ueberlagernd_flaeche 
            LEFT JOIN darstellungsdienst
            ON darstellungsdienst.atext ILIKE '%ch.SO.NutzungsplanungSondernutzungsplaene%'
            LEFT JOIN arp_nutzungsplanung_oerebv2.amt_amt AS amt 
            ON substring(amt.t_ili_tid FROM 4 FOR 4) = geobasisdaten_typ.t_datasetname 
        WHERE
            (
                typ_kt IN 
                (
                    -- N610_Perimeter_kantonaler_Nutzungsplan kommt neu aus einem anderen Schema
                    'N611_Perimeter_kommunaler_Gestaltungsplan',
                    'N620_Perimeter_Gestaltungsplanpflicht'
                )
            )
            AND 
        geometrie.rechtsstatus IN ('inKraft', 'AenderungMitVorwirkung')

        UNION ALL    
            
        -- Baulinien + Waldabstandslinie 
        SELECT
            geobasisdaten_typ.t_id,
            darstellungsdienst.basket_t_id,            
            CASE
                WHEN typ_kt = 'E725_Waldabstandslinie'
                    THEN 'ch.Waldabstandslinien'
                ELSE 'ch.Nutzungsplanung'
            END AS thema,
            CASE
                WHEN typ_kt = 'E725_Waldabstandslinie'
                    THEN CAST(NULL AS text)
                ELSE 'ch.SO.Baulinien'
            END AS subthema,
            geometrie.rechtsstatus,
            geometrie.publiziertab AS publiziertab,
            darstellungsdienst.t_id AS darstellungsdienst,
            amt.t_id AS zustaendigestelle,
            geobasisdaten_typ.bezeichnung AS legendetext_de,
            geobasisdaten_typ.code_kommunal AS artcode,        
            'urn:fdc:ilismeta.interlis.ch:2017:NP_Typ_Kanton_Erschliessung_Linienobjekt.'||geobasisdaten_typ.t_datasetname AS artcodeliste,
            geometrie.geometrie 
        FROM
            arp_nutzungsplanung_v1.erschlssngsplnung_typ_erschliessung_linienobjekt AS geobasisdaten_typ
            INNER JOIN arp_nutzungsplanung_v1.erschlssngsplnung_erschliessung_linienobjekt AS geometrie
            ON geobasisdaten_typ.t_id = geometrie.typ_erschliessung_linienobjekt 
            LEFT JOIN darstellungsdienst
            ON 
            (
                darstellungsdienst.atext ILIKE '%ch.Waldabstandslinien%' AND typ_kt = 'E725_Waldabstandslinie'
                OR 
                darstellungsdienst.atext ILIKE '%ch.SO.Baulinien%' AND typ_kt != 'E725_Waldabstandslinie'
            )
            LEFT JOIN arp_nutzungsplanung_oerebv2.amt_amt AS amt 
            ON substring(amt.t_ili_tid FROM 4 FOR 4) = geobasisdaten_typ.t_datasetname 
        WHERE
            (
                typ_kt IN 
                (
                    'E711_Baulinie_Strasse_kantonal',
                    'E712_Vorbaulinie_kantonal',
                    'E713_Gestaltungsbaulinie_kantonal',
                    'E714_Rueckwaertige_Baulinie_kantonal',
                    'E715_Baulinie_Infrastruktur_kantonal',
                    'E719_weitere_nationale_und_kantonale_Baulinien',
                    'E720_Baulinie_Strasse',
                    'E721_Vorbaulinie',
                    'E722_Gestaltungsbaulinie',
                    'E723_Rueckwaertige_Baulinie',
                    'E724_Baulinie_Infrastruktur',
                    'E725_Waldabstandslinie',
                    'E726_Baulinie_Hecke',
                    --'E727_Baulinie_Gewaesser',
                    'E728_Immissionsstreifen',
                    'E729_weitere_kommunale_Baulinien' -- ????
                )
                OR 
                (
                    -- Falls Gewässerraum nicht rechtsgültig ausgeschieden ist,
                    -- wird dieser Typ weiterhin bei der Nutzungsplanung geführt.
                    typ_kt = 'E727_Baulinie_Gewaesser'  
                    AND 
                    CAST(geobasisdaten_typ.t_datasetname AS int4) NOT IN 
                    (
                        SELECT 
                            gemeinde
                        FROM 
                            availabilty
                    )
                )
            )
            AND 
        geometrie.rechtsstatus IN ('inKraft', 'AenderungMitVorwirkung')

        UNION ALL 
            
        -- Lärmempfindlichkeit
        SELECT
            geobasisdaten_typ.t_id,
            darstellungsdienst.basket_t_id,
            'ch.Laermempfindlichkeitsstufen' AS thema,
            CAST(NULL AS TEXT) AS subthema,
            geometrie.rechtsstatus,
            geometrie.publiziertab AS publiziertab,
            darstellungsdienst.t_id AS darstellungsdienst,
            amt.t_id AS zustaendigestelle,
            geobasisdaten_typ.bezeichnung AS legendetext_de,
            substring(geobasisdaten_typ.typ_kt FROM 2 FOR 3) AS artcode,        
            'urn:fdc:ilismeta.interlis.ch:2020:Typ_Kanton_Empfindlichkeitsstufe.'||geobasisdaten_typ.t_datasetname AS artcodeliste,
            geometrie.geometrie 
        FROM
            arp_nutzungsplanung_v1.laermmpfhktsstfen_typ_empfindlichkeitsstufe AS geobasisdaten_typ
            INNER JOIN arp_nutzungsplanung_v1.laermmpfhktsstfen_empfindlichkeitsstufe AS geometrie
            ON geobasisdaten_typ.t_id = geometrie.typ_empfindlichkeitsstufen 
            LEFT JOIN darstellungsdienst
            ON darstellungsdienst.atext ILIKE '%ch.Laermempfindlichkeitsstufen%'
            LEFT JOIN arp_nutzungsplanung_oerebv2.amt_amt AS amt 
            ON substring(amt.t_ili_tid FROM 4 FOR 4) = geobasisdaten_typ.t_datasetname 
        WHERE
            (
                typ_kt IN 
                (
                    'N680_Empfindlichkeitsstufe_I',
                    'N681_Empfindlichkeitsstufe_II',
                    'N682_Empfindlichkeitsstufe_II_aufgestuft',
                    'N683_Empfindlichkeitsstufe_III',
                    'N684_Empfindlichkeitsstufe_III_aufgestuft',
                    'N685_Empfindlichkeitsstufe_IV',
                    'N686_keine_Empfindlichkeitsstufe'
                )
            )
            AND 
        geometrie.rechtsstatus IN ('inKraft', 'AenderungMitVorwirkung')
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
,
geometrie_linie AS (
    INSERT INTO 
        arp_nutzungsplanung_oerebv2.transferstruktur_geometrie 
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
        ST_GeometryType(geometrie) = 'ST_LineString'
)
,
geometrie_punkt AS (
    INSERT INTO 
        arp_nutzungsplanung_oerebv2.transferstruktur_geometrie 
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
        ST_GeometryType(geometrie) = 'ST_Point'
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
 * (1) In dokument_typ UNION ALL, weil bei dokument distincted wird. 
 * ACHTUNG: Prüfen, ob nun nicht doch was doppelt erscheint. document_typ
 * wird für die Zwischentabelle verwendet.
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
        arp_nutzungsplanung_v1.rechtsvorschrften_dokument AS dokument
        INNER JOIN arp_nutzungsplanung_v1.nutzungsplanung_typ_grundnutzung_dokument AS typ_dokument
        ON typ_dokument.dokument = dokument.t_id   
        
    UNION ALL 
    
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
        arp_nutzungsplanung_v1.rechtsvorschrften_dokument AS dokument
        INNER JOIN arp_nutzungsplanung_v1.nutzungsplanung_typ_ueberlagernd_flaeche_dokument AS typ_dokument
        ON typ_dokument.dokument = dokument.t_id
        
    UNION ALL 
    
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
        typ_dokument.typ_ueberlagernd_linie AS typ_eigentumsbeschraenkung
    FROM 
        arp_nutzungsplanung_v1.rechtsvorschrften_dokument AS dokument
        INNER JOIN arp_nutzungsplanung_v1.nutzungsplanung_typ_ueberlagernd_linie_dokument AS typ_dokument
        ON typ_dokument.dokument = dokument.t_id
        
    UNION ALL 
    
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
        typ_dokument.typ_ueberlagernd_punkt AS typ_eigentumsbeschraenkung
    FROM 
        arp_nutzungsplanung_v1.rechtsvorschrften_dokument AS dokument
        INNER JOIN arp_nutzungsplanung_v1.nutzungsplanung_typ_ueberlagernd_punkt_dokument AS typ_dokument
        ON typ_dokument.dokument = dokument.t_id
        
    UNION ALL 
    
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
        arp_nutzungsplanung_v1.rechtsvorschrften_dokument AS dokument
        INNER JOIN arp_nutzungsplanung_v1.erschlssngsplnung_typ_erschliessung_linienobjekt_dokument AS typ_dokument
        ON typ_dokument.dokument = dokument.t_id
        
    UNION ALL 
    
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
        typ_dokument.typ_empfindlichkeitsstufen AS typ_eigentumsbeschraenkung
    FROM 
        arp_nutzungsplanung_v1.rechtsvorschrften_dokument AS dokument
        INNER JOIN arp_nutzungsplanung_v1.laermmpfhktsstfen_typ_empfindlichkeitsstufe_dokument AS typ_dokument
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
        arp_nutzungsplanung_v1.rechtsvorschrften_dokument AS dokumente_dokument
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
        arp_nutzungsplanung_oerebv2.transferstruktur_darstellungsdienst AS darstellungsdienst
        LEFT JOIN arp_nutzungsplanung_oerebv2.transferstruktur_eigentumsbeschraenkung AS eigentumsbeschrankung
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
        arp_nutzungsplanung_oerebv2.multilingualuri AS muri
        INNER JOIN dangling_darstellungsdienst AS darstellungsdienst 
        ON muri.transfrstrkstllngsdnst_verweiswms = darstellungsdienst.t_id
)
,
dangling_localiseduri AS 
(
    SELECT 
        luri.t_id
    FROM 
        arp_nutzungsplanung_oerebv2.localiseduri AS luri
        INNER JOIN dangling_multilingualuri AS multilingualuri 
        ON luri.multilingualuri_localisedtext = multilingualuri.t_id
)
,
delete_dangling_localiseduri AS 
(
    DELETE FROM 
        arp_nutzungsplanung_oerebv2.localiseduri
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
        arp_nutzungsplanung_oerebv2.multilingualuri m 
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
    arp_nutzungsplanung_oerebv2.transferstruktur_darstellungsdienst 
    WHERE 
        t_id IN 
        (
            SELECT 
                t_id 
            FROM 
                dangling_darstellungsdienst
        )
;