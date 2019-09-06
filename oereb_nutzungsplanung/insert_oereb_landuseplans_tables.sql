/*
 * Die korrekte Reihenfolge der Queries ist zwingend. 
 * 
 * Es wird versucht möglichst rasch die Daten in den Tabellen zu speichern. So
 * können die Queries gekapselt werden und/oder in nachvollziehbareren 
 * Teilschritten durchgeführt werden. Alternativ kann man (fast) alles in einer sehr
 * langen CTE umbauen.
 * 
 * Es wird versucht wenn immer möglich die Original-TID (resp. der PK aus der 
 * Quelltabelle) in der Zieltabelle beizubehalten. Damit bleiben Beziehungen
 * 'bestehen' und sind einfacher zu behandeln.
 */

/*
 * Zurücksetzen der Staatskanzlei-TID. Siehe Kommentar am Ende des Umbaues.
 * 
 */
UPDATE 
    arp_npl_oereb.vorschriften_amt
SET
    t_ili_tid = 'ch.so.sk'
WHERE
    t_datasetname = 'ch.so.arp.nutzungsplanung'
AND
    t_ili_tid LIKE 'ch.so.sk.%'
;

/*
 * Die Eigentumsbeschränkungen können als erstes persistiert werden. Der Umbau der anderen Objekte erfolgt anschliessend.
 * Verschiedene Herausforderungen / Spezialitäten müssen behandelt werden:
 * 
 * (1) basket und dataset müssen eruiert und als FK gespeichert werden. Beide werden
 * werden in einer Subquery ermittelt. Dies ist möglich, da bereits die zuständigen Stellen
 * vorhanden sein müssen, weil sie mitexportiert werden und daher den gleichen Dataset-Identifier
 * aufweisen (im Gegensatz dazu die Gesetze).
 * 
 * (2) Die Grundnutzung wird nicht flächendeckend in den ÖREB-Kataster überführt, d.h. es
 * gibt Grundnutzungen, die nicht Bestandteil des Katasters sind. Dieser Filter ist eine
 * einfache WHERE-Clause.
 * 
 * (3) Die Attribute 'publiziertab' und 'rechtsstatus' sind im kantonalen Modell nicht in
 * der Typ-Klasse vorhanden und werden aus diesem Grund für den ÖREB-Kataster
 * ebenfalls von der Geometrie-Klasse verwendet. Der Join führt dazu, dass ein unschönes 
 * Distinct notwendig wird. Und dass für den Typ / für die Eigentumsbeschränkung ein 
 * willkürliches Datum gewählt wird (falls es unterschiedliche Daten gibt).
 * 
 * (4) Momentan geht man von der Annahme aus, dass bei den diesen Eigentumsbeschränkungen
 * die Gemeinde die zuständige Stelle ist. Falls das nicht mehr zutrifft, muss man die
 * zuständigen Stellen eventuell in einem nachgelagerten Schritt abhandeln.
 * 
 * (5) Unschönheit: Exportiert werden alle zuständigen Stellen, die vorgängig importiert wurden. 
 * Will man das nicht, müssen die nicht verwendeten zuständigen Stellen (des gleichen Datasets)
 * mit einer Query gelöscht werden.
 * 
 * (6) Ein Artcode kann mehrfach vorkommen. Die Kombination Artcode und Artcodeliste (=Namespace) ist
 * eindeutig.  Aufpassen, dass bei den nachfolgenden Queries nicht fälschlicherweise angenommen wird, 
 * dass der Artcode unique ist.
 * Ausnahme: Bei den Symbolen ist diese Annahme materiell richtig (solange eine kantonale aggregierte
 * Form präsentiert wird) und führt zu keinen falschen Resultaten.
 * 
 * (7) 'typ_grundnutzung IN' (etc.) filtern Eigentumsbeschränkungen weg, die mit keinem Dokument verknüpft sind.
 * Sind solche Objekte vorhanden, handelt es sich in der Regel um einen Datenfehler in den Ursprungsdaten.
 * 'publiziertab IS NOT NULL' filtert Objekte raus, die kein Publikationsdatum haben (Mandatory im Rahmenmodell.)
 * 
 * (8) Waldabstandslinien unterscheiden sich nur im Thema/Subthema von den restlichen Linien-Erschliessungsobjekten. 
 * Aus diesem Grund wird kein separates SELECT gemacht, sondern das Thema/Subthema mit CASE/WHEN behandelt.
 *
 * (9) rechtsstatus = 'inKraft': Die Bedingung hier reicht nicht, damit (später) auch nur die Geometrien verwendet
 * werden, die 'inKraft' sind. Grund dafür ist, dass es nicht-'inKraft' Geometrien geben kann, die auf einen
 * Typ zeigen, dem Geometrien zugewiesen sind, die 'inKraft' sind. Nur solche Typen, dem gar keine 'inKraft'
 * Geometrien zugewiesen sind, werden hier rausgefiltert.
 *
 * (10) Ebenfalls reicht die Bedingung 'inKraft' bei den Dokumenten nicht. Hier werden nur Typen rausgefiltert, die 
 * nur Dokumente angehängt haben, die NICHT inKraft sind. Sind bei einem Typ aber sowohl inKraft wie auch nicht-
 * inKraft-Dokumente angehängt, wird korrekterweise der Typ trotzdem verwendet. Bei den Dokumenten muss der
 * Filter nochmals gesetzt werden.
 */

INSERT INTO 
    arp_npl_oereb.transferstruktur_eigentumsbeschraenkung
    (
        t_id,
        t_basket,
        t_datasetname,
        aussage_de,
        thema,
        subthema,
        artcode,
        artcodeliste,
        rechtsstatus,
        publiziertab,
        zustaendigestelle
    )
    -- Grundnutzung
    SELECT
        DISTINCT ON (typ_grundnutzung.t_ili_tid)
        typ_grundnutzung.t_id,
        basket_dataset.basket_t_id,
        basket_dataset.datasetname,
        typ_grundnutzung.bezeichnung AS aussage_de,
        'Nutzungsplanung' AS thema,
        'ch.so.Nutzungsplanung.NutzungsplanungGrundnutzung' AS subthema,
        typ_grundnutzung.code_kommunal AS artcode,
        'urn:fdc:ilismeta.interlis.ch:2017:NP_Typ_Kanton_Grundnutzung.'||typ_grundnutzung.t_datasetname AS artcodeliste,
        grundnutzung.rechtsstatus,
        grundnutzung.publiziertab, 
        amt.t_id AS zustaendigestelle
    FROM
        arp_npl.nutzungsplanung_typ_grundnutzung AS typ_grundnutzung
        LEFT JOIN arp_npl_oereb.vorschriften_amt AS amt
        ON typ_grundnutzung.t_datasetname = RIGHT(amt.t_ili_tid, 4)
        LEFT JOIN arp_npl.nutzungsplanung_grundnutzung AS grundnutzung
        ON typ_grundnutzung.t_id = grundnutzung.typ_grundnutzung,
        (
            SELECT
                basket.t_id AS basket_t_id,
                dataset.datasetname AS datasetname               
            FROM
                arp_npl_oereb.t_ili2db_dataset AS dataset
                LEFT JOIN arp_npl_oereb.t_ili2db_basket AS basket
                ON basket.dataset = dataset.t_id
            WHERE
                dataset.datasetname = 'ch.so.arp.nutzungsplanung' 
        ) AS basket_dataset
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
        typ_grundnutzung.t_id IN 
        (
            SELECT
                DISTINCT ON (typ_grundnutzung) 
                typ_grundnutzung
            FROM
                arp_npl.nutzungsplanung_typ_grundnutzung_dokument AS typ_grundnutzung_dokument
                LEFT JOIN arp_npl.rechtsvorschrften_dokument AS dokument
                ON dokument.t_id = typ_grundnutzung_dokument.dokument
            WHERE
                dokument.rechtsstatus = 'inKraft'        
        )  
        AND
        grundnutzung.publiziertab IS NOT NULL
        AND
        grundnutzung.rechtsstatus = 'inKraft'

    UNION ALL
    
    -- Überlagernd (Fläche)
    SELECT
        DISTINCT ON (typ_ueberlagernd_flaeche.t_ili_tid)
        typ_ueberlagernd_flaeche.t_id,
        basket_dataset.basket_t_id,
        basket_dataset.datasetname,
        typ_ueberlagernd_flaeche.bezeichnung AS aussage_de,
        'Nutzungsplanung' AS thema,
        'ch.so.Nutzungsplanung.NutzungsplanungUeberlagernd' AS subthema,
        typ_ueberlagernd_flaeche.code_kommunal AS artcode,
        'urn:fdc:ilismeta.interlis.ch:2017:NP_Typ_Kanton_Ueberlagernd_Flaeche.'||typ_ueberlagernd_flaeche.t_datasetname AS artcodeliste,
        ueberlagernd_flaeche.rechtsstatus,
        ueberlagernd_flaeche.publiziertab,
        amt.t_id AS zustaendigestelle
    FROM
        arp_npl.nutzungsplanung_typ_ueberlagernd_flaeche AS typ_ueberlagernd_flaeche
        LEFT JOIN arp_npl_oereb.vorschriften_amt AS amt
        ON typ_ueberlagernd_flaeche.t_datasetname = RIGHT(amt.t_ili_tid, 4)
        LEFT JOIN arp_npl.nutzungsplanung_ueberlagernd_flaeche AS ueberlagernd_flaeche
        ON typ_ueberlagernd_flaeche.t_id = ueberlagernd_flaeche.typ_ueberlagernd_flaeche,
        (
            SELECT
                basket.t_id AS basket_t_id,
                dataset.datasetname AS datasetname               
            FROM
                arp_npl_oereb.t_ili2db_dataset AS dataset
                LEFT JOIN arp_npl_oereb.t_ili2db_basket AS basket
                ON basket.dataset = dataset.t_id
            WHERE
                dataset.datasetname = 'ch.so.arp.nutzungsplanung'
        ) AS basket_dataset
    WHERE
        (
            typ_kt IN 
            (
                'N510_ueberlagernde_Ortsbildschutzzone',
                'N523_Landschaftsschutzzone',
                'N526_kantonale_Landwirtschafts_und_Schutzzone_Witi',
                'N527_kantonale_Uferschutzzone',
                'N528_kommunale_Uferschutzzone_ausserhalb_Bauzonen',
                'N529_weitere_Schutzzonen_fuer_Lebensraeume_und_Landschaften',
                'N590_Hofstattzone_Freihaltezone',
                'N591_Bauliche_Einschraenkungen',
                'N690_kantonales_Vorranggebiet_Natur_und_Landschaft',
                'N691_kommunales_Vorranggebiet_Natur_und_Landschaft',
                'N692_Planungszone',
                'N699_weitere_flaechenbezogene_Festlegungen_NP',
                'N812_geologisches_Objekt',
                'N813_Naturobjekt',
                'N822_schuetzenswertes_Kulturobjekt',
                'N823_erhaltenswertes_Kulturobjekt'
            )
            OR
            (
                typ_kt = 'N599_weitere_ueberlagernde_Nutzungszonen' AND verbindlichkeit = 'Nutzungsplanfestlegung'
    
            ) 
       )     
        AND
        typ_ueberlagernd_flaeche.t_id IN 
        (
            SELECT
                DISTINCT ON (typ_ueberlagernd_flaeche) 
                typ_ueberlagernd_flaeche
            FROM
                arp_npl.nutzungsplanung_typ_ueberlagernd_flaeche_dokument AS typ_ueberlagernd_flaeche_dokument
                LEFT JOIN arp_npl.rechtsvorschrften_dokument AS dokument
                ON dokument.t_id = typ_ueberlagernd_flaeche_dokument.dokument
            WHERE
                dokument.rechtsstatus = 'inKraft'
        )  
        AND 
        ueberlagernd_flaeche.publiziertab IS NOT NULL
        AND
        ueberlagernd_flaeche.rechtsstatus = 'inKraft'

    UNION ALL

    -- Überlagernd (Linie) 
    SELECT
        DISTINCT ON (typ_ueberlagernd_linie.t_ili_tid)
        typ_ueberlagernd_linie.t_id,
        basket_dataset.basket_t_id,
        basket_dataset.datasetname,
        typ_ueberlagernd_linie.bezeichnung AS aussage_de,
        'Nutzungsplanung' AS thema,
        'ch.so.Nutzungsplanung.NutzungsplanungUeberlagernd' AS subthema,
        typ_ueberlagernd_linie.code_kommunal AS artcode,
        'urn:fdc:ilismeta.interlis.ch:2017:NP_Typ_Kanton_Ueberlagernd_Linie.'||typ_ueberlagernd_linie.t_datasetname AS artcodeliste,
        ueberlagernd_linie.rechtsstatus,
        ueberlagernd_linie.publiziertab,
        amt.t_id AS zustaendigestelle
    FROM
        arp_npl.nutzungsplanung_typ_ueberlagernd_linie AS typ_ueberlagernd_linie
        LEFT JOIN arp_npl_oereb.vorschriften_amt AS amt
        ON typ_ueberlagernd_linie.t_datasetname = RIGHT(amt.t_ili_tid, 4)
        LEFT JOIN arp_npl.nutzungsplanung_ueberlagernd_linie AS ueberlagernd_linie
        ON typ_ueberlagernd_linie.t_id = ueberlagernd_linie.typ_ueberlagernd_linie,
        (
            SELECT
                basket.t_id AS basket_t_id,
                dataset.datasetname AS datasetname               
            FROM
                arp_npl_oereb.t_ili2db_dataset AS dataset
                LEFT JOIN arp_npl_oereb.t_ili2db_basket AS basket
                ON basket.dataset = dataset.t_id
            WHERE
                dataset.datasetname = 'ch.so.arp.nutzungsplanung'
        ) AS basket_dataset
    WHERE
        (
            typ_kt = 'N799_weitere_linienbezogene_Festlegungen_NP' AND verbindlichkeit = 'Nutzungsplanfestlegung'
        )
        AND
        typ_ueberlagernd_linie.t_id IN 
        (
            SELECT
                DISTINCT ON (typ_ueberlagernd_linie) 
                typ_ueberlagernd_linie
            FROM
                arp_npl.nutzungsplanung_typ_ueberlagernd_linie_dokument AS typ_ueberlagernd_linie_dokument
                LEFT JOIN arp_npl.rechtsvorschrften_dokument AS dokument
                ON dokument.t_id = typ_ueberlagernd_linie_dokument.dokument
            WHERE
                dokument.rechtsstatus = 'inKraft'
        )  
        AND 
        ueberlagernd_linie.publiziertab IS NOT NULL
        AND
        ueberlagernd_linie.rechtsstatus = 'inKraft'

    UNION ALL

    -- Überlagernd (Punkt)    
    SELECT
        DISTINCT ON (typ_ueberlagernd_punkt.t_ili_tid)
        typ_ueberlagernd_punkt.t_id,
        basket_dataset.basket_t_id,
        basket_dataset.datasetname,
        typ_ueberlagernd_punkt.bezeichnung AS aussage_de,
        'Nutzungsplanung' AS thema,
        'ch.so.Nutzungsplanung.NutzungsplanungUeberlagernd' AS subthema,
        typ_ueberlagernd_punkt.code_kommunal AS artcode,
        'urn:fdc:ilismeta.interlis.ch:2017:NP_Typ_Kanton_Ueberlagernd_Punkt.'||typ_ueberlagernd_punkt.t_datasetname AS artcodeliste,
        ueberlagernd_punkt.rechtsstatus,
        ueberlagernd_punkt.publiziertab,  
        amt.t_id AS zustaendigestelle
    FROM
        arp_npl.nutzungsplanung_typ_ueberlagernd_punkt AS typ_ueberlagernd_punkt
        LEFT JOIN arp_npl_oereb.vorschriften_amt AS amt
        ON typ_ueberlagernd_punkt.t_datasetname = RIGHT(amt.t_ili_tid, 4)
        LEFT JOIN arp_npl.nutzungsplanung_ueberlagernd_punkt AS ueberlagernd_punkt
        ON typ_ueberlagernd_punkt.t_id = ueberlagernd_punkt.typ_ueberlagernd_punkt,
        (
            SELECT
                basket.t_id AS basket_t_id,
                dataset.datasetname AS datasetname               
            FROM
                arp_npl_oereb.t_ili2db_dataset AS dataset
                LEFT JOIN arp_npl_oereb.t_ili2db_basket AS basket
                ON basket.dataset = dataset.t_id
            WHERE
                dataset.datasetname = 'ch.so.arp.nutzungsplanung'
        ) AS basket_dataset
    WHERE
        (
            typ_kt IN 
            (
                'N811_erhaltenswerter_Einzelbaum',
                'N820_kantonal_geschuetztes_Kulturobjekt',
                'N822_schuetzenswertes_Kulturobjekt',
                'N823_erhaltenswertes_Kulturobjekt'
            )
            OR
            (
                typ_kt = 'N899_weitere_punktbezogene_Festlegungen_NP' AND verbindlichkeit = 'Nutzungsplanfestlegung'
    
            )   
        )
        AND
        typ_ueberlagernd_punkt.t_id IN 
        (
            SELECT
                DISTINCT ON (typ_ueberlagernd_punkt) 
                typ_ueberlagernd_punkt
            FROM
                arp_npl.nutzungsplanung_typ_ueberlagernd_punkt_dokument AS typ_ueberlagernd_punkt_dokument
                LEFT JOIN arp_npl.rechtsvorschrften_dokument AS dokument
                ON dokument.t_id = typ_ueberlagernd_punkt_dokument.dokument
            WHERE
                dokument.rechtsstatus = 'inKraft'
        )  
        AND 
        ueberlagernd_punkt.publiziertab IS NOT NULL
        AND
        ueberlagernd_punkt.rechtsstatus = 'inKraft'

    UNION ALL

    -- Sondernutzungspläne
    SELECT
        DISTINCT ON (typ_ueberlagernd_flaeche.t_ili_tid)
        typ_ueberlagernd_flaeche.t_id,
        basket_dataset.basket_t_id,
        basket_dataset.datasetname,
        typ_ueberlagernd_flaeche.bezeichnung AS aussage_de,
        'Nutzungsplanung' AS thema,
        'ch.so.Nutzungsplanung.NutzungsplanungSondernutzungsplaene' AS subthema,
        typ_ueberlagernd_flaeche.code_kommunal AS artcode,
        'urn:fdc:ilismeta.interlis.ch:2017:NP_Typ_Kanton_Ueberlagernd_Flaeche.'||typ_ueberlagernd_flaeche.t_datasetname AS artcodeliste,
        ueberlagernd_flaeche.rechtsstatus,
        ueberlagernd_flaeche.publiziertab,
        amt.t_id AS zustaendigestelle
    FROM
        arp_npl.nutzungsplanung_typ_ueberlagernd_flaeche AS typ_ueberlagernd_flaeche
        LEFT JOIN arp_npl_oereb.vorschriften_amt AS amt
        ON typ_ueberlagernd_flaeche.t_datasetname = RIGHT(amt.t_ili_tid, 4)
        LEFT JOIN arp_npl.nutzungsplanung_ueberlagernd_flaeche AS ueberlagernd_flaeche
        ON typ_ueberlagernd_flaeche.t_id = ueberlagernd_flaeche.typ_ueberlagernd_flaeche,
        (
            SELECT
                basket.t_id AS basket_t_id,
                dataset.datasetname AS datasetname               
            FROM
                arp_npl_oereb.t_ili2db_dataset AS dataset
                LEFT JOIN arp_npl_oereb.t_ili2db_basket AS basket
                ON basket.dataset = dataset.t_id
            WHERE
                dataset.datasetname = 'ch.so.arp.nutzungsplanung' 
        ) AS basket_dataset
    WHERE
        typ_kt IN 
        (
            'N610_Perimeter_kantonaler_Nutzungsplan',
            'N611_Perimeter_kommunaler_Gestaltungsplan',
            'N620_Perimeter_Gestaltungsplanpflicht'
        )
        AND
        typ_ueberlagernd_flaeche.t_id IN 
        (
            SELECT
                DISTINCT ON (typ_ueberlagernd_flaeche) 
                typ_ueberlagernd_flaeche
            FROM
                arp_npl.nutzungsplanung_typ_ueberlagernd_flaeche_dokument AS typ_ueberlagernd_flaeche_dokument
                LEFT JOIN arp_npl.rechtsvorschrften_dokument AS dokument
                ON dokument.t_id = typ_ueberlagernd_flaeche_dokument.dokument
            WHERE
                dokument.rechtsstatus = 'inKraft'
        )  
        AND 
        ueberlagernd_flaeche.publiziertab IS NOT NULL    
        AND
        ueberlagernd_flaeche.rechtsstatus = 'inKraft'

    UNION ALL

    -- Baulinien + Waldabstandslinie 
    SELECT
        DISTINCT ON (typ_erschliessung_linienobjekt.t_ili_tid)
        typ_erschliessung_linienobjekt.t_id,
        basket_dataset.basket_t_id,
        basket_dataset.datasetname,
        typ_erschliessung_linienobjekt.bezeichnung AS aussage_de,
        CASE
            WHEN typ_kt = 'E725_Waldabstandslinie'
                THEN 'Waldabstandslinien'
            ELSE 'Nutzungsplanung'
        END AS thema,
        CASE
            WHEN typ_kt = 'E725_Waldabstandslinie'
                THEN ''::text
            ELSE 'ch.so.Nutzungsplanung.Baulinien'
        END AS subthema,
        typ_erschliessung_linienobjekt.code_kommunal AS artcode,
        'urn:fdc:ilismeta.interlis.ch:2017:NP_Typ_Kanton_Erschliessung_Linienobjekt.'||typ_erschliessung_linienobjekt.t_datasetname AS artcodeliste,
        erschliessung_linienobjekt.rechtsstatus,
        erschliessung_linienobjekt.publiziertab,
        amt.t_id AS zustaendigestelle
    FROM
        arp_npl.erschlssngsplnung_typ_erschliessung_linienobjekt AS typ_erschliessung_linienobjekt
        LEFT JOIN arp_npl_oereb.vorschriften_amt AS amt
        ON typ_erschliessung_linienobjekt.t_datasetname = RIGHT(amt.t_ili_tid, 4)
        LEFT JOIN arp_npl.erschlssngsplnung_erschliessung_linienobjekt AS erschliessung_linienobjekt
        ON typ_erschliessung_linienobjekt.t_id = erschliessung_linienobjekt.typ_erschliessung_linienobjekt,
        (
            SELECT
                basket.t_id AS basket_t_id,
                dataset.datasetname AS datasetname               
            FROM
                arp_npl_oereb.t_ili2db_dataset AS dataset
                LEFT JOIN arp_npl_oereb.t_ili2db_basket AS basket
                ON basket.dataset = dataset.t_id
            WHERE
                dataset.datasetname = 'ch.so.arp.nutzungsplanung'
        ) AS basket_dataset
    WHERE
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
            'E727_Baulinie_Gewaesser',
            'E728_Immissionsstreifen',
            'E729_weitere_kommunale_Baulinien'
        )
        AND
        typ_erschliessung_linienobjekt.t_id IN 
        (
            SELECT
                DISTINCT ON (typ_erschliessung_linienobjekt) 
                typ_erschliessung_linienobjekt
            FROM
                arp_npl.erschlssngsplnung_typ_erschliessung_linienobjekt_dokument AS typ_erschliessung_linienobjekt_dokument
                LEFT JOIN arp_npl.rechtsvorschrften_dokument AS dokument
                ON dokument.t_id = typ_erschliessung_linienobjekt_dokument.dokument
            WHERE
                dokument.rechtsstatus = 'inKraft'
        )  
        AND
        erschliessung_linienobjekt.publiziertab IS NOT NULL 
        AND
        erschliessung_linienobjekt.rechtsstatus = 'inKraft'

    UNION ALL

    -- Laermempfindlichkeit 
    SELECT
        DISTINCT ON (typ_ueberlagernd_flaeche.t_ili_tid)
        typ_ueberlagernd_flaeche.t_id,
        basket_dataset.basket_t_id,
        basket_dataset.datasetname,
        typ_ueberlagernd_flaeche.bezeichnung AS aussage_de,
        'Laermemfindlichkeitsstufen' AS thema,
        ''::text AS subthema, -- Wegen Darstellungsdienst-Query (kann man aber besser machen, Funktion fällt mir auf die Schnelle nicht ein).
        typ_ueberlagernd_flaeche.code_kommunal AS artcode,
        'urn:fdc:ilismeta.interlis.ch:2017:NP_Typ_Kanton_Erschliessung_Flaechenobjekt.'||typ_ueberlagernd_flaeche.t_datasetname AS artcodeliste,
        ueberlagernd_flaeche.rechtsstatus,
        ueberlagernd_flaeche.publiziertab, 
        amt.t_id AS zustaendigestelle
    FROM
        arp_npl.nutzungsplanung_typ_ueberlagernd_flaeche AS typ_ueberlagernd_flaeche
        LEFT JOIN arp_npl_oereb.vorschriften_amt AS amt
        ON typ_ueberlagernd_flaeche.t_datasetname = RIGHT(amt.t_ili_tid, 4)
        LEFT JOIN arp_npl.nutzungsplanung_ueberlagernd_flaeche AS ueberlagernd_flaeche
        ON typ_ueberlagernd_flaeche.t_id = ueberlagernd_flaeche.typ_ueberlagernd_flaeche,
        (
            SELECT
                basket.t_id AS basket_t_id,
                dataset.datasetname AS datasetname               
            FROM
                arp_npl_oereb.t_ili2db_dataset AS dataset
                LEFT JOIN arp_npl_oereb.t_ili2db_basket AS basket
                ON basket.dataset = dataset.t_id
            WHERE
                dataset.datasetname = 'ch.so.arp.nutzungsplanung'
        ) AS basket_dataset
    WHERE
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
        AND
        typ_ueberlagernd_flaeche.t_id IN 
        (
            SELECT
                DISTINCT ON (typ_ueberlagernd_flaeche) 
                typ_ueberlagernd_flaeche
            FROM
                arp_npl.nutzungsplanung_typ_ueberlagernd_flaeche_dokument AS typ_ueberlagernd_flaeche_dokument
                LEFT JOIN arp_npl.rechtsvorschrften_dokument AS dokument
                ON dokument.t_id = typ_ueberlagernd_flaeche_dokument.dokument
            WHERE
                dokument.rechtsstatus = 'inKraft'
        )  
        AND 
        ueberlagernd_flaeche.publiziertab IS NOT NULL   
        AND
        ueberlagernd_flaeche.rechtsstatus = 'inKraft'
;

/*
 * Update (Korrektur) der zuständigen Stellen.
 * 
 * Die zuständige Stelle einiger Typen ist nicht die Gemeinden, sondern ein
 * kantonales Amt (ARP oder AVT). Der Einfachheithalber wird zuerst alles
 * der Gemeinde zugewissen (obere Query). Mit einem Update werden den 
 * einzelnen Typen die korrekte zuständige Stelle zugewiesen.
 */

UPDATE 
    arp_npl_oereb.transferstruktur_eigentumsbeschraenkung
SET
    zustaendigestelle = subquery.t_id
FROM
(
    SELECT 
        t_id 
    FROM 
        arp_npl_oereb.vorschriften_amt
    WHERE
        t_ili_tid = 'ch.so.arp'
) AS subquery
WHERE
    substring(artcode, 1, 3) IN ('526', '527', '610', '690')
;

UPDATE 
    arp_npl_oereb.transferstruktur_eigentumsbeschraenkung
SET
    zustaendigestelle = subquery.t_id
FROM
(
    SELECT 
        t_id 
    FROM 
        arp_npl_oereb.vorschriften_amt
    WHERE
        t_ili_tid = 'ch.so.avt'
) AS subquery
WHERE
    substring(artcode, 1, 3) IN ('711', '712', '713', '714', '715', '719')
;

/*
 * Es werden die Dokumente der ersten Hierarchie-Ebene ("direkt verlinkt") abgehandelt, d.h.
 * "HinweisWeitere"-Dokumente werden in einem weiteren Schritt bearbeitet. Um die Dokumente
 * zu kopieren, muss auch die n-m-Zwischentabelle bearbeitet werden, wegen der
 * Foreign Keys Constraints. Bemerkungen:
 * 
 * (1) Das Abfüllen der zuständigen Stellen muss ggf. nochmals überarbeitet
 * werden. Kommt darauf an, ob das hier reicht. In den Ausgangsdaten müssen
 * die Attribute Abkuerzung und Rechtsvorschrift zwingend gesetzt sein, sonst
 * kann nicht korrekt umgebaut werden. 
 * 
 * (2) Relativ mühsam ist der Umstand, dass bereits Daten in der Dokumenten-
 * Tabelle vorhanden sind (die kantonalen Gesetze). Deren Primary Keys hat
 * man nicht im Griff und so kann es vorkommen, dass es zu einer Kollision
 * mit den zu kopierenden Daten kommt. Abhilfe schafft beim Erstellen des
 * Staging-Schemas der Parameter --idSeqMin. Damit kann der Startwert der
 * Sequenz gesetzt werden, um solche Kollisionen mit grösster Wahrscheinlichkeit
 * zu verhindern.
 * 
 * (3) Die t_ili_tid kann nicht einfach so aus der Quelltabelle übernommen werden,
 * da sie keine valide OID ist (die gemäss Modell verlangt wird). Gemäss Kommentar
 * sollte sie zudem wie eine Domain aufgebaut sein. Der Einfachheit halber (Referenzen
 * gibt es ja in der DB darauf nicht, sondern auf den PK) mache ich aus der UUID eine
 * valide OID mittels Substring, Replace und Concat.
 * 
 * (4) Es gibt Objekte (Typen), die in den Kataster aufgenommen werden müssen (gemäss
 * Excelliste) aber keine Dokumente zugewiesen haben. -> Datenfehler. Aus diesem Grund
 * wird eine Where-Clause verwendet (dokument.t_id IS NOT NULL). 
 * 2019-08-03 / sz: Wieder entfernt, da man diese Daten bereits ganz zu Beginn (erste 
 * Query) rausfiltern muss.
 * 
 * (5) In der 'hinweisvorschrift'-Query werden nur diejenigen Dokumente verwendet, die
 * inKraft sind. Durch den RIGHT JOIN in der Query 'vorschriften_dokument' werden
 * dann ebenfalls nur die Dokumente selektiert, die inKraft sind. Ein weiterer Filter
 * ist hier unnötig.
 */

WITH basket_dataset AS 
(
    SELECT
        basket.t_id AS basket_t_id,
        dataset.datasetname AS datasetname               
    FROM
        arp_npl_oereb.t_ili2db_dataset AS dataset
        LEFT JOIN arp_npl_oereb.t_ili2db_basket AS basket
        ON basket.dataset = dataset.t_id
    WHERE
        dataset.datasetname = 'ch.so.arp.nutzungsplanung' 
)
,
hinweisvorschrift AS 
(
    SELECT
        t_typ_dokument.t_id,
        basket_dataset.basket_t_id AS t_basket,
        basket_dataset.datasetname AS t_datasetname,        
        t_typ_dokument.eigentumsbeschraenkung,
        t_typ_dokument.vorschrift_vorschriften_dokument
    FROM
    (
        -- Grundnutzung
        SELECT
            typ_dokument.t_id,
            typ_dokument.typ_grundnutzung AS eigentumsbeschraenkung,
            typ_dokument.dokument AS vorschrift_vorschriften_dokument
        FROM
            arp_npl.nutzungsplanung_typ_grundnutzung_dokument AS typ_dokument
            LEFT JOIN arp_npl.rechtsvorschrften_dokument AS dokument
            ON dokument.t_id = typ_dokument.dokument
        WHERE
            dokument.rechtsstatus = 'inKraft'
            
        UNION ALL
        
        -- Überlagernd (Fläche) + Sondernutzungspläne + Lärmempfindlichkeitsstufen 
        SELECT
            typ_dokument.t_id,
            typ_dokument.typ_ueberlagernd_flaeche AS eigentumsbeschraenkung,
            typ_dokument.dokument AS vorschrift_vorschriften_dokument
        FROM
            arp_npl.nutzungsplanung_typ_ueberlagernd_flaeche_dokument AS typ_dokument
            LEFT JOIN arp_npl.rechtsvorschrften_dokument AS dokument
            ON dokument.t_id = typ_dokument.dokument
        WHERE
            dokument.rechtsstatus = 'inKraft'

        UNION ALL
        
        -- Überlagernd (Linie)        
        SELECT
            typ_dokument.t_id,
            typ_dokument.typ_ueberlagernd_linie AS eigentumsbeschraenkung,
            typ_dokument.dokument AS vorschrift_vorschriften_dokument
        FROM
            arp_npl.nutzungsplanung_typ_ueberlagernd_linie_dokument AS typ_dokument
            LEFT JOIN arp_npl.rechtsvorschrften_dokument AS dokument
            ON dokument.t_id = typ_dokument.dokument
        WHERE
            dokument.rechtsstatus = 'inKraft'

        UNION ALL

        -- Überlagernd (Punkt)        
        SELECT
            typ_dokument.t_id,
            typ_dokument.typ_ueberlagernd_punkt AS eigentumsbeschraenkung,
            typ_dokument.dokument AS vorschrift_vorschriften_dokument
        FROM
            arp_npl.nutzungsplanung_typ_ueberlagernd_punkt_dokument AS typ_dokument
            LEFT JOIN arp_npl.rechtsvorschrften_dokument AS dokument
            ON dokument.t_id = typ_dokument.dokument
        WHERE
            dokument.rechtsstatus = 'inKraft'

        UNION ALL

        -- Baulinien + Waldabstandslinien
        SELECT
            typ_dokument.t_id,
            typ_dokument.typ_erschliessung_linienobjekt AS eigentumsbeschraenkung,
            typ_dokument.dokument AS vorschrift_vorschriften_dokument
        FROM
            arp_npl.erschlssngsplnung_typ_erschliessung_linienobjekt_dokument AS typ_dokument
            LEFT JOIN arp_npl.rechtsvorschrften_dokument AS dokument
            ON dokument.t_id = typ_dokument.dokument
        WHERE
            dokument.rechtsstatus = 'inKraft'
    ) AS t_typ_dokument
    RIGHT JOIN arp_npl_oereb.transferstruktur_eigentumsbeschraenkung AS eigentumsbeschraenkung
    ON t_typ_dokument.eigentumsbeschraenkung = eigentumsbeschraenkung.t_id,
    basket_dataset
)
,
vorschriften_dokument AS
(
    INSERT INTO 
        arp_npl_oereb.vorschriften_dokument
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
            WHEN rechtsvorschrift IS FALSE
                THEN 'vorschriften_dokument'
            ELSE 'vorschriften_rechtsvorschrift'
        END AS t_type,
        '_'||SUBSTRING(REPLACE(CAST(dokument.t_ili_tid AS text), '-', ''),1,15) AS t_ili_tid,        
        dokument.titel AS titel_de,
        dokument.offiziellertitel AS offizellertitel_de,
        dokument.abkuerzung AS abkuerzung_de,
        dokument.offiziellenr AS offiziellenr,
        dokument.kanton AS kanton,
        dokument.gemeinde AS gemeinde,
        dokument.rechtsstatus AS rechtsstatus,
        dokument.publiziertab AS publiziertab,
        CASE
            WHEN abkuerzung = 'RRB'
                THEN 
                (
                    SELECT 
                        t_id
                    FROM
                        arp_npl_oereb.vorschriften_amt
                    WHERE
                        t_datasetname = 'ch.so.arp.nutzungsplanung'
                    AND
                        t_ili_tid = 'ch.so.sk'
                )
            ELSE
                (
                    SELECT 
                        t_id
                    FROM
                        arp_npl_oereb.vorschriften_amt
                    WHERE
                        RIGHT(t_ili_tid, 4) = CAST(gemeinde AS TEXT)
                )
         END AS zustaendigestelle
    FROM
        arp_npl.rechtsvorschrften_dokument AS dokument
        RIGHT JOIN hinweisvorschrift
        ON dokument.t_id = hinweisvorschrift.vorschrift_vorschriften_dokument,
        (
            SELECT
                basket.t_id AS basket_t_id,
                dataset.datasetname AS datasetname               
            FROM
                arp_npl_oereb.t_ili2db_dataset AS dataset
                LEFT JOIN arp_npl_oereb.t_ili2db_basket AS basket
                ON basket.dataset = dataset.t_id
            WHERE
                dataset.datasetname = 'ch.so.arp.nutzungsplanung' 
        ) AS basket_dataset   
   RETURNING *
)
INSERT INTO
    arp_npl_oereb.transferstruktur_hinweisvorschrift
    (
        t_id,
        t_basket,
        t_datasetname,
        eigentumsbeschraenkung,
        vorschrift_vorschriften_dokument  
    )
SELECT
    t_id, -- TODO: muss nicht zwingend Original-TID sein, oder?
    t_basket,
    t_datasetname,
    eigentumsbeschraenkung,
    vorschrift_vorschriften_dokument
FROM
    hinweisvorschrift
;

/*
 * Umbau der zusätzlichen Dokumente, die im Originalmodell in der 
 * HinweisWeitereDokumente vorkommen und nicht direkt (via Zwischen-
 * Tabelle) mit der Eigentumsbeschränkung / mit dem Typ verknüpft sind. 
 * 
 * (1) Flachwalzen: Anstelle der gnietigen HinweisWeitereDokumente-Tabelle 
 * kann man alles flachwalzen, d.h. alle Dokument-zu-Dokument-Links werden 
 * direkt mit an den Typ / an die Eigentumsbeschränkung verlinkt. Dazu muss man 
 * für jedes Dokument in dieser Schleife das Top-Level-Dokument (das 'wirkliche'
 * Ursprungs-Dokument) kennen, damit dann auch noch die Verbindungstabelle
 * (transferstruktur_hinweisvorschrift) zwischen Eigentumsbeschränkung und 
 * Dokument abgefüllt werden kann.
 * 
 * (2) Umbau sehr gut validieren (wegen des Flachwalzens)!
 * 
 * (3) Die rekursive CTE muss am Anfang stehen.
 * 
 * (4) STIMTT DAS NOCH? Achtung: Beim Einfügen der zusätzlichen Dokumente in die Dokumententabelle
 * kann es Duplikate geben, da zwei verschiedene Top-Level-Dokumente auf das gleiche
 * weitere Dokument verweisen. Das wirft einen Fehler (Primary Key Constraint). Aus
 * diesem Grund muss beim Inserten noch ein DISTINCT auf die t_id gemacht werden. 
 * Beim anschliessenden Herstellen der Verknüpfung aber nicht mehr.
 * 
 * (5)  Bei 'zusaetzliche_dokumente AS ..' können Dokumente vorkommen, die bereits aufgrund aus einer 
 * direkten Verlinkung in einem anderen Thema/Subthemas in der Dokumenten-Tabelle vorhanden sind. 
 * Diese Duplikaten werden erst beim Inserten gefiltert, da man die trotzdem eine weitere Beziehung
 * in eines anderen Themas/Subthemas stammen. Das Filtern wird erst beim Insert gemacht, da
 * man die Beziehung in 'transferstruktur_hinweisvorschrift' einfügen muss. Sonst geht dieses
 * Wissen verloren. Braucht auch noch einen Filter beim Inserten dieser Beziehung, sonst kommen
 * ebenfalls die bereits direkt verlinkten.
 * 
 * (6) Weil jetzt in der Tabelle 'arp_npl_oereb.vorschriften_dokument' nur noch (vorangehende Query)
 * die inKraft-Dokumente sind, weiss ich nicht genau, was passiert wenn ein nicht-inKraft-
 * Dokument irgendwo zwischen zwei inKraft-Dokumenten bei der Rekursion zu liegen kommt.
 * Ich bin nicht sicher, ob die 'ursprung' und 'hinweis'-Filter im zweiten Teil der
 * rekursiven Query etwas bewirken.
 * Müsste man anhand eines einfachen Beispieles ausprobieren.
 */


WITH RECURSIVE x(ursprung, hinweis, parents, last_ursprung, depth) AS 
(
    SELECT 
        ursprung, 
        hinweis, 
        ARRAY[ursprung] AS parents, 
        ursprung AS last_ursprung, 
        0 AS "depth" 
    FROM 
        arp_npl.rechtsvorschrften_hinweisweiteredokumente
    WHERE
        ursprung != hinweis
    AND ursprung IN 
    (
        SELECT
            t_id
        FROM
            arp_npl_oereb.vorschriften_dokument
        WHERE
            t_datasetname = 'ch.so.arp.nutzungsplanung'
    )
    AND hinweis IN 
    (
        SELECT
            t_id
        FROM
            arp_npl_oereb.vorschriften_dokument
        WHERE
            t_datasetname = 'ch.so.arp.nutzungsplanung'
    )

    UNION ALL
  
    SELECT 
        x.ursprung, 
        x.hinweis, 
        parents||t1.hinweis, 
        t1.hinweis AS last_ursprung, 
        x."depth" + 1
    FROM 
        x 
        INNER JOIN arp_npl.rechtsvorschrften_hinweisweiteredokumente t1 
        ON (last_ursprung = t1.ursprung)
    WHERE 
        t1.hinweis IS NOT NULL
    AND x.ursprung IN 
    (
        SELECT
            t_id
        FROM
            arp_npl_oereb.vorschriften_dokument
        WHERE
            t_datasetname = 'ch.so.arp.nutzungsplanung'
    )
    AND x.hinweis IN 
    (
        SELECT
            t_id
        FROM
            arp_npl_oereb.vorschriften_dokument
        WHERE
            t_datasetname = 'ch.so.arp.nutzungsplanung'
    )
),
zusaetzliche_dokumente AS 
(
    SELECT 
        DISTINCT ON (x.last_ursprung, x.ursprung)
        x.ursprung AS top_level_dokument,
        x.last_ursprung AS t_id,
        basket_dataset.basket_t_id,
        basket_dataset.datasetname,
        CASE
            WHEN rechtsvorschrift IS FALSE
                THEN 'vorschriften_dokument'
            ELSE 'vorschriften_rechtsvorschrift'
        END AS t_type,
        '_'||SUBSTRING(REPLACE(CAST(dokument.t_ili_tid AS text), '-', ''),1,15) AS t_ili_tid,        
        dokument.titel AS titel_de,
        dokument.offiziellertitel AS offizellertitel_de,
        dokument.abkuerzung AS abkuerzung_de,
        dokument.offiziellenr AS offiziellenr,
        dokument.kanton AS kanton,
        dokument.gemeinde AS gemeinde,
        dokument.rechtsstatus AS rechtsstatus,
        dokument.publiziertab AS publiziertab,
        CASE
            WHEN abkuerzung = 'RRB'
                THEN 
                (
                    SELECT 
                        t_id
                    FROM
                        arp_npl_oereb.vorschriften_amt
                    WHERE
                        t_datasetname = 'ch.so.arp.nutzungsplanung' 
                    AND
                        t_ili_tid = 'ch.so.sk' 
                )
            ELSE
                (
                    SELECT 
                        t_id
                    FROM
                        arp_npl_oereb.vorschriften_amt
                    WHERE
                        RIGHT(t_ili_tid, 4) = CAST(gemeinde AS TEXT)
                )
         END AS zustaendigestelle        
    FROM 
        x
        LEFT JOIN arp_npl.rechtsvorschrften_dokument AS dokument
        ON dokument.t_id = x.last_ursprung,
        (
            SELECT
                basket.t_id AS basket_t_id,
                dataset.datasetname AS datasetname               
            FROM
                arp_npl_oereb.t_ili2db_dataset AS dataset
                LEFT JOIN arp_npl_oereb.t_ili2db_basket AS basket
                ON basket.dataset = dataset.t_id
            WHERE
                dataset.datasetname = 'ch.so.arp.nutzungsplanung' 
        ) AS basket_dataset        
    -- WHERE
    --     /* Dokumente, die bereits im Zielschema vorhanden sind. Dabei
    --     * handelt es sich um die direkt verknüpften Dokumente.  Diese
    --     * werden in der vorgängigen Query-Gruppe behandelt. */
    --     last_ursprung NOT IN
    --     (
    --         SELECT
    --             t_id
    --         FROM
    --             arp_npl_oereb.vorschriften_dokument
    --         WHERE
    --             t_datasetname = 'ch.so.arp.nutzungsplanung'
    --     )
)
,
zusaetzliche_dokumente_insert AS 
(
    INSERT INTO 
        arp_npl_oereb.vorschriften_dokument
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
        DISTINCT ON (t_id)    
        t_id,
        basket_t_id,
        datasetname,
        t_type,
        t_ili_tid,
        titel_de,
        offizellertitel_de,
        abkuerzung_de,
        offiziellenr,
        kanton,
        gemeinde,
        rechtsstatus,
        publiziertab,
        zustaendigestelle
    FROM
        zusaetzliche_dokumente
    WHERE
        t_id NOT IN 
        (
            SELECT
                t_id
            FROM
                arp_npl_oereb.vorschriften_dokument
            WHERE
                t_datasetname = 'ch.so.arp.nutzungsplanung'
        )
)
INSERT INTO 
    arp_npl_oereb.transferstruktur_hinweisvorschrift 
    (
        t_basket,
        t_datasetname,
        eigentumsbeschraenkung,
        vorschrift_vorschriften_dokument
    )
    SELECT 
        DISTINCT 
        basket_dataset.basket_t_id,
        basket_dataset.datasetname,
        hinweisvorschrift.eigentumsbeschraenkung,
        zusaetzliche_dokumente.t_id AS vorschrift_vorschriften_dokument
    FROM 
        zusaetzliche_dokumente
        LEFT JOIN arp_npl_oereb.transferstruktur_hinweisvorschrift AS hinweisvorschrift
        ON hinweisvorschrift.vorschrift_vorschriften_dokument = zusaetzliche_dokumente.top_level_dokument,
        (
            SELECT
                basket.t_id AS basket_t_id,
                dataset.datasetname AS datasetname               
            FROM
                arp_npl_oereb.t_ili2db_dataset AS dataset
                LEFT JOIN arp_npl_oereb.t_ili2db_basket AS basket
                ON basket.dataset = dataset.t_id
            WHERE
                dataset.datasetname = 'ch.so.arp.nutzungsplanung' 
        ) AS basket_dataset
    WHERE
        NOT EXISTS 
        (
            SELECT 
                eigentumsbeschraenkung, vorschrift_vorschriften_dokument 
            FROM 
                arp_npl_oereb.transferstruktur_hinweisvorschrift     
            WHERE 
                eigentumsbeschraenkung = hinweisvorschrift.eigentumsbeschraenkung
                AND
                vorschrift_vorschriften_dokument = zusaetzliche_dokumente.t_id
        )
;

/*
 * Datenumbau der Links auf die Dokumente, die im Rahmenmodell 'multilingual' sind und daher eher
 * mühsam normalisert sind.
 * 
 * (1) Im NPL-Modell sind die URL nicht vollständig, sondern es werden nur Teile des Pfads verwaltet.
 * Beim Datenumbau in das Rahmenmodell wird daraus eine vollständige URL gemacht.
 */

WITH multilingualuri AS
(
    INSERT INTO
        arp_npl_oereb.multilingualuri
        (
            t_id,
            t_basket,
            t_datasetname,
            t_seq,
            vorschriften_dokument_textimweb
        )
    SELECT
        nextval('arp_npl_oereb.t_ili2db_seq'::regclass) AS t_id,
        basket_dataset.basket_t_id,
        basket_dataset.datasetname,
        0 AS t_seq,
        vorschriften_dokument.t_id AS vorschriften_dokument_textimweb
    FROM
        arp_npl_oereb.vorschriften_dokument AS vorschriften_dokument,
        (
            SELECT
                basket.t_id AS basket_t_id,
                dataset.datasetname AS datasetname               
            FROM
                arp_npl_oereb.t_ili2db_dataset AS dataset
                LEFT JOIN arp_npl_oereb.t_ili2db_basket AS basket
                ON basket.dataset = dataset.t_id
            WHERE
                dataset.datasetname = 'ch.so.arp.nutzungsplanung' 
        ) AS basket_dataset
    WHERE
        vorschriften_dokument.t_datasetname = 'ch.so.arp.nutzungsplanung'
    RETURNING *
)
,
localiseduri AS 
(
    SELECT 
        nextval('arp_npl_oereb.t_ili2db_seq'::regclass) AS t_id,
        basket_dataset.basket_t_id,
        basket_dataset.datasetname,
        0 AS t_seq,
        'de' AS alanguage,
        CAST('https://geo.so.ch/docs/ch.so.arp.zonenplaene/Zonenplaene_pdf/'||rechtsvorschrften_dokument.textimweb AS TEXT) AS atext,
        multilingualuri.t_id AS multilingualuri_localisedtext
    FROM
        arp_npl.rechtsvorschrften_dokument AS rechtsvorschrften_dokument
        RIGHT JOIN multilingualuri 
        ON multilingualuri.vorschriften_dokument_textimweb = rechtsvorschrften_dokument.t_id,
        (
            SELECT
                basket.t_id AS basket_t_id,
                dataset.datasetname AS datasetname               
            FROM
                arp_npl_oereb.t_ili2db_dataset AS dataset
                LEFT JOIN arp_npl_oereb.t_ili2db_basket AS basket
                ON basket.dataset = dataset.t_id
            WHERE
                dataset.datasetname = 'ch.so.arp.nutzungsplanung'                 
        ) AS basket_dataset
)
INSERT INTO
    arp_npl_oereb.localiseduri
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
 * (1) Es werde nicht alle Geometrien der jeweiligen
 * Nutzungsebene kopiert, sondern nur diejenigen, die Inhalt 
 * des ÖREB-Katasters sind. Dieser Filter wird bei Umbau 
 * des NPL-Typs gesetzt.
 * 
 * (2) Die zuständige Stelle ist identisch mit der zuständigen
 * Stelle der Eigentumsbeschränkung.
 * 
 * (3) Die Geometrien werden mit ST_MakeValid(ST_RemoveRepeatedPoints(ST_SnapToGrid()))
 * bereinigt. 
 */

INSERT INTO
    arp_npl_oereb.transferstruktur_geometrie
    (
        t_id,
        t_basket,
        t_datasetname,
        flaeche_lv95,
        rechtsstatus,
        publiziertab,
        eigentumsbeschraenkung,
        zustaendigestelle
    )
    SELECT 
        nutzung.t_id,
        basket_dataset.basket_t_id AS t_basket,
        basket_dataset.datasetname AS t_datasetname,
        ST_MakeValid(ST_RemoveRepeatedPoints(ST_SnapToGrid(nutzung.geometrie, 0.001))) AS flaeche_lv95,
        nutzung.rechtsstatus AS rechtsstatus,
        nutzung.publiziertab AS publiziertab,
        eigentumsbeschraenkung.t_id AS eigentumsbeschraenkung,
        eigentumsbeschraenkung.zustaendigestelle AS zustaendigestelle
    FROM
    (
        -- Grundnutzung
        SELECT
            t_id,    
            geometrie AS geometrie,
            rechtsstatus AS rechtsstatus,
            publiziertab AS publiziertab,
            typ_grundnutzung AS typ_nutzung
        FROM
            arp_npl.nutzungsplanung_grundnutzung
        WHERE
            rechtsstatus = 'inKraft'

        UNION ALL
        
        -- Überlagernd (Fläche) + Sondernutzungspläne + Lärmempfindlichkeitsstufen
        SELECT
            t_id,    
            ST_Buffer(geometrie, 0) AS geometrie, -- TODO: fixme
            rechtsstatus AS rechtsstatus,
            publiziertab AS publiziertab,
            typ_ueberlagernd_flaeche AS typ_nutzung            
        FROM
            arp_npl.nutzungsplanung_ueberlagernd_flaeche
        WHERE
            rechtsstatus = 'inKraft'
    ) AS nutzung
    INNER JOIN arp_npl_oereb.transferstruktur_eigentumsbeschraenkung AS eigentumsbeschraenkung
    ON nutzung.typ_nutzung = eigentumsbeschraenkung.t_id,
    (
        SELECT
            basket.t_id AS basket_t_id,
            dataset.datasetname AS datasetname               
        FROM
            arp_npl_oereb.t_ili2db_dataset AS dataset
            LEFT JOIN arp_npl_oereb.t_ili2db_basket AS basket
            ON basket.dataset = dataset.t_id
        WHERE
            dataset.datasetname = 'ch.so.arp.nutzungsplanung' 
    ) AS basket_dataset
;

INSERT INTO
    arp_npl_oereb.transferstruktur_geometrie
    (
        t_id,
        t_basket,
        t_datasetname,
        linie_lv95,
        rechtsstatus,
        publiziertab,
        eigentumsbeschraenkung,
        zustaendigestelle
    )
    SELECT 
        nutzung.t_id,
        basket_dataset.basket_t_id AS t_basket,
        basket_dataset.datasetname AS t_datasetname,
        ST_MakeValid(ST_RemoveRepeatedPoints(ST_SnapToGrid(nutzung.geometrie, 0.001))) AS linie_lv95,
        nutzung.rechtsstatus AS rechtsstatus,
        nutzung.publiziertab AS publiziertab,
        eigentumsbeschraenkung.t_id AS eigentumsbeschraenkung,
        eigentumsbeschraenkung.zustaendigestelle AS zustaendigestelle
    FROM
    (
        -- Überlagernd (Linie)
        SELECT
            t_id,    
            geometrie AS geometrie,
            rechtsstatus AS rechtsstatus,
            publiziertab AS publiziertab,
            typ_ueberlagernd_linie AS typ_nutzung            
        FROM
            arp_npl.nutzungsplanung_ueberlagernd_linie
        WHERE
            rechtsstatus = 'inKraft'

        UNION ALL

        -- Baulinien
        SELECT
            t_id,    
            geometrie AS geometrie,
            rechtsstatus AS rechtsstatus,
            publiziertab AS publiziertab,
            typ_erschliessung_linienobjekt AS typ_nutzung            
        FROM
            arp_npl.erschlssngsplnung_erschliessung_linienobjekt
        WHERE
            rechtsstatus = 'inKraft'
        AND 
            ST_IsValid(geometrie)
    ) AS nutzung
    INNER JOIN arp_npl_oereb.transferstruktur_eigentumsbeschraenkung AS eigentumsbeschraenkung
    ON nutzung.typ_nutzung = eigentumsbeschraenkung.t_id,
    (
        SELECT
            basket.t_id AS basket_t_id,
            dataset.datasetname AS datasetname               
        FROM
            arp_npl_oereb.t_ili2db_dataset AS dataset
            LEFT JOIN arp_npl_oereb.t_ili2db_basket AS basket
            ON basket.dataset = dataset.t_id
        WHERE
            dataset.datasetname = 'ch.so.arp.nutzungsplanung' 
    ) AS basket_dataset
;

INSERT INTO
    arp_npl_oereb.transferstruktur_geometrie
    (
        t_id,
        t_basket,
        t_datasetname,
        punkt_lv95,
        rechtsstatus,
        publiziertab,
        eigentumsbeschraenkung,
        zustaendigestelle
    )
    SELECT 
        nutzung.t_id,
        basket_dataset.basket_t_id AS t_basket,
        basket_dataset.datasetname AS t_datasetname,
        ST_MakeValid(ST_RemoveRepeatedPoints(ST_SnapToGrid(nutzung.geometrie, 0.001))) AS punkt_lv95,
        nutzung.rechtsstatus AS rechtsstatus,
        nutzung.publiziertab AS publiziertab,
        eigentumsbeschraenkung.t_id AS eigentumsbeschraenkung,
        eigentumsbeschraenkung.zustaendigestelle AS zustaendigestelle
    FROM
    (
        -- Überlagernd (Punkt)
        SELECT
            t_id,    
            geometrie AS geometrie,
            rechtsstatus AS rechtsstatus,
            publiziertab AS publiziertab,
            typ_ueberlagernd_punkt AS typ_nutzung            
        FROM
            arp_npl.nutzungsplanung_ueberlagernd_punkt
        WHERE
            rechtsstatus = 'inKraft'
    ) AS nutzung
    INNER JOIN arp_npl_oereb.transferstruktur_eigentumsbeschraenkung AS eigentumsbeschraenkung
    ON nutzung.typ_nutzung = eigentumsbeschraenkung.t_id,
    (
        SELECT
            basket.t_id AS basket_t_id,
            dataset.datasetname AS datasetname               
        FROM
            arp_npl_oereb.t_ili2db_dataset AS dataset
            LEFT JOIN arp_npl_oereb.t_ili2db_basket AS basket
            ON basket.dataset = dataset.t_id
        WHERE
            dataset.datasetname = 'ch.so.arp.nutzungsplanung' 
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
        arp_npl_oereb.transferstruktur_darstellungsdienst 
        (
            t_basket,
            t_datasetname,
            verweiswms,
            legendeimweb
        )
        SELECT
            basket_dataset.basket_t_id AS t_basket,
            basket_dataset.datasetname AS t_datasetname,
            --'https://geo-t.so.ch/wms/oereb?
            --'http://wms:80/wms/oereb?
            'https://geo-t.so.ch/wms/oereb?SERVICE=WMS&VERSION=1.3.0&REQUEST=GetMap&FORMAT=image%2Fpng&TRANSPARENT=true&LAYERS='||RTRIM(TRIM((layername||'.'||geometrietyp)), '.')||'&STYLES=&SRS=EPSG%3A2056&CRS=EPSG%3A2056&DPI=96&WIDTH=1200&HEIGHT=1146&BBOX=2591250%2C1211350%2C2646050%2C1263700' AS verweiswms,
            'https://geo-t.so.ch/wms/oereb?SERVICE=WMS&VERSION=1.3.0&REQUEST=GetLegendGraphics&FORMAT=image/png&LAYER='||RTRIM(TRIM((layername||'.'||geometrietyp)), '.') AS legendeimweb
        FROM
        (
            SELECT 
                DISTINCT ON (thema, subthema, geometrietyp)
                thema,
                subthema,
                CASE 
                    WHEN artcodeliste ILIKE '%NP_Typ_Kanton_Grundnutzung%' THEN ''
                    WHEN (artcodeliste ILIKE '%NP_Typ_Kanton_Ueberlagernd_Flaeche%' AND subthema = 'ch.so.Nutzungsplanung.NutzungsplanungUeberlagernd') THEN 'Flaeche'
                    WHEN (artcodeliste ILIKE '%NP_Typ_Kanton_Ueberlagernd_Flaeche%' AND subthema = 'ch.so.Nutzungsplanung.NutzungsplanungSondernutzungsplaene') THEN ''
                    WHEN artcodeliste ILIKE '%NP_Typ_Kanton_Ueberlagernd_Linie%' THEN 'Linie'
                    WHEN artcodeliste ILIKE '%NP_Typ_Kanton_Ueberlagernd_Punkt%' THEN 'Punkt'
                    WHEN artcodeliste ILIKE '%NP_Typ_Kanton_Erschliessung_Flaechenobjekt%' THEN ''
                    WHEN artcodeliste ILIKE '%NP_Typ_Kanton_Erschliessung_Linienobjekt%' THEN ''
                END AS geometrietyp,
                CASE 
                    WHEN subthema != ''::text THEN subthema
                    ELSE 'ch.so.'||thema
                END AS layername
            FROM
                arp_npl_oereb.transferstruktur_eigentumsbeschraenkung AS eigentumsbeschraenkung 
        ) AS eigentumsbeschraenkung,
        (
            SELECT
                basket.t_id AS basket_t_id,
                dataset.datasetname AS datasetname               
            FROM
                arp_npl_oereb.t_ili2db_dataset AS dataset
                LEFT JOIN arp_npl_oereb.t_ili2db_basket AS basket
                ON basket.dataset = dataset.t_id
            WHERE
                dataset.datasetname = 'ch.so.arp.nutzungsplanung' 
        ) AS basket_dataset
    RETURNING *
)
INSERT INTO 
    arp_npl_oereb.transferstruktur_legendeeintrag
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
            decode('iVBORw0KGgoAAAANSUhEUgAAAEIAAAAjCAYAAAAg/NwXAAAABHNCSVQICAgIfAhkiAAAAAlwSFlzAAADgQAAA4EBLr/cFwAAABl0RVh0U29mdHdhcmUAd3d3Lmlua3NjYXBlLm9yZ5vuPBoAAAOiSURBVGiB7ZpPSBRRHMc/u6tZgligRcSqQVAI7cmUtCVdUEIiUDPLsksdLFHoUoJil5UKOu2lg4iHUDQEjboFpqAdJGI1CiKkEhQRDxKhKOZ0+M34ZtLZP/1xI+cDw/ze7/1m5jdf3nu/N+y6NNBwwJ3oBP4VHCF0kiyt48fh1KkEpbLNjI7C27cbTasQxcUQCm1zRgmiqckihDM1dBwhdBwhdBwhdBwhdBwhdOyF6OiAvDzr4ffDnTswM6PiwmHV39+v/BMTm/1tbdLOz4cPH6zPa21V8VNT4quulnYgAEtLKlbT4Px56SsqEl9vr7r++XMV++WLPC8vT3K3Q5PbytHYqG3Q1qZZ+szH3r2aNjkpccPDyh8KqetHRjb7a2uVr6JCxb57p2kej+oLh8V/9Kjytber+O5u5U9OFt/srNigaWfOqNhgUMUODip/Y6PlnWKbGrduwb17cO6ctBcXZUPyOwwMwKtXYjc3w/fvkeMfPICFBVhZgZaWzf0HD0JlpdgvXsDcnNiPH8s5OxvOnrW9fZJtj5nr1yE3V+yCAhgfly3q2lpMl9ty+za0t8OzZ9Fjv36FYBCysuDz561jGhqgr09E7emRzwVjCt64AR6P7e1jE8KMzydCrK1Jcr+K2w1jY3DhgrRdLhmkdrHr6/DoEaSm2sf7/ZLf5KSMhE+fxL97N1y7FjmduF8ggqpxYSQ2Pw/JyVBXZx+bmwsnT8LqqkxLrxdKS7eOvXlTzuEwdHaKffEiZGRETCdx5fPuXUhLE7u+Ho4csY91uWSNMAgGYc+erWPr6mDfPrGXl+Xc0BA1ncQJkZkpa4TXK6UzGn4/VFVBYSFcuWIfl5oKV6+qdkGBlM4oJHZD1doK09Owf39s8f39sq64o6RdUaFso5JEIX4hzBsbt1vmt4G5BJoryq5dcT/mtzDnZLYjEJ8Q8/NSo0Hmd3q61GeD4WG1kr98qfw5OXE9JhHEVj6rqyElBT5+hG/fxHf5sixihw7JFnhoCJ4+le1serq0QdaAQOAvpf/niE2I9++t7fJyePhQtbu6oKxMNi+vXyt/ZiY8eRLz8Ewk9kKUlMh21sDjgQMHpJ6fOGGNzcqCN2/kpcfHpd77fHDpkohhUFkpIyQpSQ4zxcXyUWSMMpA9weys3P9namrg2DHZLP3M4cNw/77Yp0/bv70Z24+u/51f+ujaAThC6DhC6DhC6DhC6LgsfwvYwb99WoXYwThTQ8cRQucHQTGF/rvy36kAAAAASUVORK5CYII=', 'base64') AS symbol,
            eigentumsbeschraenkung.aussage_de AS legendetext_de,
            eigentumsbeschraenkung.artcode,
            eigentumsbeschraenkung.artcodeliste,
            eigentumsbeschraenkung.thema,
            eigentumsbeschraenkung.subthema,
            CASE 
                WHEN artcodeliste ILIKE '%NP_Typ_Kanton_Grundnutzung%' THEN ''
                WHEN (artcodeliste ILIKE '%NP_Typ_Kanton_Ueberlagernd_Flaeche%' AND subthema = 'ch.so.Nutzungsplanung.NutzungsplanungUeberlagernd') THEN 'Flaeche'
                WHEN (artcodeliste ILIKE '%NP_Typ_Kanton_Ueberlagernd_Flaeche%' AND subthema = 'ch.so.Nutzungsplanung.NutzungsplanungSondernutzungsplaene') THEN ''
                WHEN artcodeliste ILIKE '%NP_Typ_Kanton_Ueberlagernd_Linie%' THEN 'Linie'
                WHEN artcodeliste ILIKE '%NP_Typ_Kanton_Ueberlagernd_Punkt%' THEN 'Punkt'
                WHEN artcodeliste ILIKE '%NP_Typ_Kanton_Erschliessung_Flaechenobjekt%' THEN ''
                WHEN artcodeliste ILIKE '%NP_Typ_Kanton_Erschliessung_Linienobjekt%' THEN ''
            END AS geometrietyp
        FROM
            arp_npl_oereb.transferstruktur_eigentumsbeschraenkung AS eigentumsbeschraenkung 
    ) AS eigentumsbeschraenkung
    LEFT JOIN transferstruktur_darstellungsdienst
    ON transferstruktur_darstellungsdienst.verweiswms ILIKE '%'||RTRIM(eigentumsbeschraenkung.thema||'.'||eigentumsbeschraenkung.subthema||'.'||eigentumsbeschraenkung.geometrietyp, '.')||'%'
;

UPDATE 
    arp_npl_oereb.transferstruktur_eigentumsbeschraenkung
SET 
    darstellungsdienst = (SELECT t_id FROM arp_npl_oereb.transferstruktur_darstellungsdienst WHERE verweiswms ILIKE '%NutzungsplanungGrundnutzung%')
WHERE
    subthema = 'ch.so.Nutzungsplanung.NutzungsplanungGrundnutzung'
;

UPDATE 
    arp_npl_oereb.transferstruktur_eigentumsbeschraenkung
SET 
    darstellungsdienst = (SELECT t_id FROM arp_npl_oereb.transferstruktur_darstellungsdienst WHERE verweiswms ILIKE '%NutzungsplanungUeberlagernd.Flaeche%')
WHERE
    t_id IN 
    (
        SELECT
            DISTINCT ON (eigentumsbeschraenkung.t_id)
            eigentumsbeschraenkung.t_id
        FROM
            arp_npl_oereb.transferstruktur_eigentumsbeschraenkung AS eigentumsbeschraenkung
        WHERE
            eigentumsbeschraenkung.subthema = 'ch.so.Nutzungsplanung.NutzungsplanungUeberlagernd'
        AND
            artcodeliste ILIKE '%NP_Typ_Kanton_Ueberlagernd_Flaeche%'
    )
;

UPDATE 
    arp_npl_oereb.transferstruktur_eigentumsbeschraenkung
SET 
    darstellungsdienst = (SELECT t_id FROM arp_npl_oereb.transferstruktur_darstellungsdienst WHERE verweiswms ILIKE '%NutzungsplanungUeberlagernd.Linie%')
WHERE
    t_id IN 
    (
        SELECT
            DISTINCT ON (eigentumsbeschraenkung.t_id)
            eigentumsbeschraenkung.t_id
        FROM
            arp_npl_oereb.transferstruktur_eigentumsbeschraenkung AS eigentumsbeschraenkung
        WHERE
            eigentumsbeschraenkung.subthema = 'ch.so.Nutzungsplanung.NutzungsplanungUeberlagernd'
        AND
            artcodeliste ILIKE '%NP_Typ_Kanton_Ueberlagernd_Linie%'
    )
;

UPDATE 
    arp_npl_oereb.transferstruktur_eigentumsbeschraenkung
SET 
    darstellungsdienst = (SELECT t_id FROM arp_npl_oereb.transferstruktur_darstellungsdienst WHERE verweiswms ILIKE '%NutzungsplanungUeberlagernd.Punkt%')
WHERE
    t_id IN 
    (
        SELECT
            DISTINCT ON (eigentumsbeschraenkung.t_id)
            eigentumsbeschraenkung.t_id
        FROM
            arp_npl_oereb.transferstruktur_eigentumsbeschraenkung AS eigentumsbeschraenkung
        WHERE
            eigentumsbeschraenkung.subthema = 'ch.so.Nutzungsplanung.NutzungsplanungUeberlagernd'
        AND
            artcodeliste ILIKE '%NP_Typ_Kanton_Ueberlagernd_Punkt%'
    )
;

UPDATE 
    arp_npl_oereb.transferstruktur_eigentumsbeschraenkung
SET 
    darstellungsdienst = (SELECT t_id FROM arp_npl_oereb.transferstruktur_darstellungsdienst WHERE verweiswms ILIKE '%NutzungsplanungSondernutzungsplaene%')
WHERE
    subthema = 'ch.so.Nutzungsplanung.NutzungsplanungSondernutzungsplaene'
;

UPDATE 
    arp_npl_oereb.transferstruktur_eigentumsbeschraenkung
SET 
    darstellungsdienst = (SELECT t_id FROM arp_npl_oereb.transferstruktur_darstellungsdienst WHERE verweiswms ILIKE '%Baulinien%')
WHERE
    subthema = 'ch.so.Nutzungsplanung.Baulinien'
;

UPDATE 
    arp_npl_oereb.transferstruktur_eigentumsbeschraenkung
SET 
    darstellungsdienst = (SELECT t_id FROM arp_npl_oereb.transferstruktur_darstellungsdienst WHERE verweiswms ILIKE '%Waldabstandslinien%')
WHERE
    thema = 'Waldabstandslinien'
;

UPDATE 
    arp_npl_oereb.transferstruktur_eigentumsbeschraenkung
SET 
    darstellungsdienst = (SELECT t_id FROM arp_npl_oereb.transferstruktur_darstellungsdienst WHERE verweiswms ILIKE '%Laermemfindlichkeitsstufen%')
WHERE
    thema = 'Laermemfindlichkeitsstufen'
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
    arp_npl_oereb.vorschriften_dokument
  WHERE
    t_ili_tid IN ('ch.admin.bk.sr.700', 'ch.so.sk.bgs.711.1', 'ch.so.sk.bgs.711.61') 
)
INSERT INTO arp_npl_oereb.vorschriften_hinweisweiteredokumente (
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
  arp_npl_oereb.vorschriften_dokument AS vorschriften_dokument
  LEFT JOIN vorschriften_dokument_gesetze
  ON 1=1
WHERE
  t_type = 'vorschriften_rechtsvorschrift'
AND
  vorschriften_dokument.t_datasetname = 'ch.so.arp.nutzungsplanung'
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
 * Ganz zu Beginn des Umbaues muss aber die nachträglich veränderte TID
 * wieder zurückgestellt werden.
 */ 

UPDATE 
    arp_npl_oereb.vorschriften_amt
SET
    t_ili_tid = 'ch.so.sk.'||uuid_generate_v4()
WHERE
    t_datasetname = 'ch.so.arp.nutzungsplanung'
AND
    t_ili_tid = 'ch.so.sk'
;