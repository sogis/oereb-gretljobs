-- Liste der Gemeinden, welche den Gewässerraum ausgeschieden haben
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
-- Eigentumsbeschränkungen der Grundnutzung
eigentumsbeschraenkung_grundnutzung AS
(
    SELECT
        geobasisdaten_typ.t_id,
        darstellungsdienst.basket_t_id,
        'ch.Nutzungsplanung' AS thema,
        'ch.SO.NutzungsplanungGrundnutzung' AS subthema,
        geometrie.rechtsstatus,
        CASE 
            WHEN geometrie.publiziertab IS NULL
                THEN '2100-12-31'
            ELSE geometrie.publiziertab 
        END AS publiziertab,
        --geometrie.publiziertab AS publiziertab,
        darstellungsdienst.t_id AS darstellungsdienst,
        amt.t_id AS zustaendigestelle,
        geobasisdaten_typ.bezeichnung AS legendetext_de,
        geobasisdaten_typ.code_kommunal AS artcode,        
        'urn:fdc:ilismeta.interlis.ch:2017:NP_Typ_Kanton_Grundnutzung.'||geobasisdaten_typ.t_datasetname AS artcodeliste,
        geometrie.geometrie,
        geobasisdaten_typ.t_datasetname 
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
)
,
-- Eigentumsbeschränkungen Überlagerungen (Fläche)
eigentumsbeschraenkung_ueberlagernd_flaeche AS
(
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
        geometrie.geometrie,
        geobasisdaten_typ.t_datasetname 
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
)
,
-- Eigentumsbeschränkungen Überlagerungen (Linien)
eigentumsbeschraenkung_ueberlagernd_linie AS
(
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
        geometrie.geometrie,
        geobasisdaten_typ.t_datasetname 
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
)
,
-- Eigentumsbeschränkungen Überlagerungen (Punkte)
eigentumsbeschraenkung_ueberlagernd_punkt AS
(
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
        geometrie.geometrie,
        geobasisdaten_typ.t_datasetname 
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
)
,
-- Eigentumsbeschränkungen Überlagerungen (Sondernutzungspläne)
eigentumsbeschraenkung_sondernutzungsplaene AS
(
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
        geometrie.geometrie,
        geobasisdaten_typ.t_datasetname 
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
)
,
-- Eigentumsbeschränkungen Erschliessung (Baulinien und Waldabstandslinie)
eigentumsbeschraenkung_baulinien AS
(
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
        geometrie.geometrie,
        geobasisdaten_typ.t_datasetname
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
)
,
-- Eigentumsbeschränkungen Empfindlichkeitsstufen
eigentumsbeschraenkung_empfindlichkeitsstufen AS
(
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
       'urn:fdc:ilismeta.interlis.ch:2020:Typ_Kanton_Empfindlichkeitsstufe' AS artcodeliste,
       geometrie.geometrie,
       geobasisdaten_typ.t_datasetname
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
)
,
-- Fasse die verschiedenen Arten von Eigentumsbeschränkungen mittels UNION ALL
-- zusammen
eigentumsbeschraenkung AS
(
    -- Durch die Joins enstehen mehrfache Eigentumsbeschränkungen.
    -- Diese werden beim Insert wieder entfernt (distinct on).
    SELECT * FROM
    (
        SELECT * FROM eigentumsbeschraenkung_grundnutzung

        UNION ALL 

        SELECT * FROM eigentumsbeschraenkung_ueberlagernd_flaeche

        UNION ALL

        SELECT * FROM eigentumsbeschraenkung_ueberlagernd_linie

        UNION ALL

        SELECT * FROM eigentumsbeschraenkung_ueberlagernd_punkt

        UNION ALL 

        SELECT * FROM eigentumsbeschraenkung_sondernutzungsplaene

        UNION ALL    

        SELECT * FROM eigentumsbeschraenkung_baulinien

        UNION ALL 

        SELECT * FROM eigentumsbeschraenkung_empfindlichkeitsstufen
    ) AS eigentumsbeschränkung_unfiltered
    -- Setze die folgenden Bedingungen, welche für alle Beschränkungen gelten:
    --   - alle Beschränkungen müssen in Kraft sein
    --   - nur Eigentumsbeschränkungen aus dem Dataset der entsprechenden Gemeinde
    -- => so können wir bereits hier diese temporäre Tabelle reduzieren.
    WHERE eigentumsbeschränkung_unfiltered.rechtsstatus IN ('inKraft'/*, 'AenderungMitVorwirkung'*/)
        AND CAST(eigentumsbeschränkung_unfiltered.t_datasetname AS int4) = ${bfsnr}
)
,
legendeneintrag AS
(
    INSERT INTO 
        arp_nutzungsplanung_oerebv2.transferstruktur_legendeeintrag 
        (
            t_id,
            t_basket,
            --t_ili_tid,
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
        --uuid_generate_v4(),
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
-- Schreibe in die Tabelle Geometrie die Flächengeometrien
geometrie_flaeche AS
(
    INSERT INTO 
        arp_nutzungsplanung_oerebv2.transferstruktur_geometrie 
        (
            t_id,
            t_basket,
            -- Wenn wir beim Export die Option exportTid nicht verwenden, können
            -- wir uns sparen, diese Spalte abzufüllen. Dasselbe gilt auch für
            -- die Abfragen Linien und Punkte
            --t_ili_tid,
            flaeche,
            rechtsstatus,
            publiziertab,
            eigentumsbeschraenkung
        )
    SELECT 
        nextval('arp_nutzungsplanung_oerebv2.t_ili2db_seq'::regclass),                    
        basket_t_id,
        --uuid_generate_v4(),
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
-- Schreibe in die Tabelle Geometrie die Liniengeometrien (analog Flächen)
geometrie_linie AS
(
    INSERT INTO 
        arp_nutzungsplanung_oerebv2.transferstruktur_geometrie 
        (
            t_id,
            t_basket,
            --t_ili_tid,
            linie,
            rechtsstatus,
            publiziertab,
            eigentumsbeschraenkung
        )
    SELECT 
        nextval('arp_nutzungsplanung_oerebv2.t_ili2db_seq'::regclass),                    
        basket_t_id,
        --uuid_generate_v4(),
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
-- Schreibe in die Tabelle Geometrie die Punktgeometrien (analog Flächen)
geometrie_punkt AS
(
    INSERT INTO 
        arp_nutzungsplanung_oerebv2.transferstruktur_geometrie 
        (
            t_id,
            t_basket,
            --t_ili_tid,
            punkt,
            rechtsstatus,
            publiziertab,
            eigentumsbeschraenkung
        )
    SELECT 
        nextval('arp_nutzungsplanung_oerebv2.t_ili2db_seq'::regclass),                    
        basket_t_id,
        --uuid_generate_v4(),
        ST_ReducePrecision(geometrie, 0.001),
        rechtsstatus,
        publiziertab,
        t_id
    FROM 
        eigentumsbeschraenkung
    WHERE 
        ST_GeometryType(geometrie) = 'ST_Point'
)
-- Schreibe die Tabelle Eigentumsbeschränkung
INSERT INTO
    arp_nutzungsplanung_oerebv2.transferstruktur_eigentumsbeschraenkung 
    (
        t_id,
        t_basket,
        --t_ili_tid,
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
    --uuid_generate_v4(),
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