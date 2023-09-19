/*
 * (1) In dokument_typ UNION ALL, weil bei dokument distincted wird. 
 * ACHTUNG: Prüfen, ob nun nicht doch was doppelt erscheint. document_typ
 * wird für die Zwischentabelle verwendet.
 * 
 */

--- Verknüpfung der Dokumente mit den Grundnutzungen
WITH dokument_typ_grundnutzung AS
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
        CASE 
            WHEN publiziertab IS NULL THEN '2100-12-31'
            ELSE publiziertab 
        END AS publiziertab,
        --dokument.publiziertab,
        dokument.rechtsvorschrift,
        typ_dokument.typ_grundnutzung AS typ_eigentumsbeschraenkung
    FROM 
        arp_nutzungsplanung_v1.rechtsvorschrften_dokument AS dokument
        INNER JOIN arp_nutzungsplanung_v1.nutzungsplanung_typ_grundnutzung_dokument AS typ_dokument
        ON typ_dokument.dokument = dokument.t_id
),
-- Verknüpfung der Dokumente mit den Überlagerungen (Flächen)
dokument_typ_ueberlagernd_flaeche AS
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
        typ_dokument.typ_ueberlagernd_flaeche AS typ_eigentumsbeschraenkung
    FROM 
        arp_nutzungsplanung_v1.rechtsvorschrften_dokument AS dokument
        INNER JOIN arp_nutzungsplanung_v1.nutzungsplanung_typ_ueberlagernd_flaeche_dokument AS typ_dokument
        ON typ_dokument.dokument = dokument.t_id
),
-- Verknüpfung der Dokumente mit den Überlagerungen (Linien)
dokument_typ_ueberlagernd_linie AS
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
        typ_dokument.typ_ueberlagernd_linie AS typ_eigentumsbeschraenkung
    FROM 
        arp_nutzungsplanung_v1.rechtsvorschrften_dokument AS dokument
        INNER JOIN arp_nutzungsplanung_v1.nutzungsplanung_typ_ueberlagernd_linie_dokument AS typ_dokument
        ON typ_dokument.dokument = dokument.t_id
),
-- Verknüpfung der Dokumente mit den Überlagerungen (Punkte)
dokument_typ_ueberlagernd_punkt AS
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
        typ_dokument.typ_ueberlagernd_punkt AS typ_eigentumsbeschraenkung
    FROM 
        arp_nutzungsplanung_v1.rechtsvorschrften_dokument AS dokument
        INNER JOIN arp_nutzungsplanung_v1.nutzungsplanung_typ_ueberlagernd_punkt_dokument AS typ_dokument
        ON typ_dokument.dokument = dokument.t_id
),
-- Verknüpfung der Dokumente mit den Erschliessungen (Linien)
-- !!!!!!!!!!!!!
-- Wo bleibend die Verknüpfungen zu den Flächen- und Punktobjekten der Erschliessung?
-- !!!!!!!!!!!!!
dokument_typ_erschliessung_linienobjekt AS
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
        typ_dokument.typ_erschliessung_linienobjekt AS typ_eigentumsbeschraenkung
    FROM 
        arp_nutzungsplanung_v1.rechtsvorschrften_dokument AS dokument
        INNER JOIN arp_nutzungsplanung_v1.erschlssngsplnung_typ_erschliessung_linienobjekt_dokument AS typ_dokument
        ON typ_dokument.dokument = dokument.t_id
),
-- Verknüpfung der Dokumente mit den Empfindlichkeitsstufen
dokument_typ_empfindlichkeitsstufe AS
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
        typ_dokument.typ_empfindlichkeitsstufen AS typ_eigentumsbeschraenkung
    FROM 
        arp_nutzungsplanung_v1.rechtsvorschrften_dokument AS dokument
        INNER JOIN arp_nutzungsplanung_v1.laermmpfhktsstfen_typ_empfindlichkeitsstufe_dokument AS typ_dokument
        ON typ_dokument.dokument = dokument.t_id
),
-- Fasse alle Verknüpfungen zu den verschiedenen Eigentumsbeschränkungen zusammen
dokument_typ AS 
(
    SELECT * FROM
    (
        SELECT * FROM dokument_typ_grundnutzung
        
        UNION ALL 

        SELECT * FROM dokument_typ_ueberlagernd_flaeche

        UNION ALL 

        SELECT * FROM dokument_typ_ueberlagernd_linie

        UNION ALL

        SELECT * FROM dokument_typ_ueberlagernd_punkt

        UNION ALL 

        SELECT * FROM dokument_typ_erschliessung_linienobjekt

        UNION ALL 

        SELECT * FROM dokument_typ_empfindlichkeitsstufe

    ) AS dokument_typ_unfiltered
    -- Setze die folgenden Bedingungen, welche für alle Typen gelten:
    --   - alle Dokumente müssen in Kraft sein
    --   - nur Dokumente aus dem Dataset der entsprechenden Gemeinde
    -- => so können wir bereits hier diese temporäre Tabelle reduzieren.
    WHERE dokument_typ_unfiltered.rechtsstatus = 'inKraft'
        AND CAST(dokument_typ_unfiltered.t_datasetname AS int4) = ${bfsnr}
),
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
            offiziellenr_de,
            auszugindex,
            rechtsstatus,
            publiziertab,
            zustaendigestelle
        )
    SELECT 
        DISTINCT ON (dokument_typ.t_id)
        dokument_typ.t_id, 
        eigentumsbeschraenkung.t_basket,
        -- Wieso ist diese t_ili_id mit Underline prefixed?
        '_'||CAST(uuid_generate_v4() AS TEXT) AS t_ili_tid,
        CASE 
            WHEN dokument_typ.rechtsvorschrift IS TRUE THEN 'Rechtsvorschrift'
            ELSE 'Hinweis'
        END AS typ,
        CASE 
            WHEN dokument_typ.abkuerzung = 'RRB' OR dokument_typ.titel ILIKE '%Regierungsratsbeschluss%' THEN 'Regierungsratsbeschluss, '||dokument_typ.offiziellertitel
            ELSE dokument_typ.offiziellertitel
        END AS titel_de,
        --dokument_typ.offiziellertitel AS titel_de,
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
        -- Verknüpfe die Dokumente mit dem Basket der entsprechenden
        -- Eigentumsbeschränkung
        INNER JOIN arp_nutzungsplanung_oerebv2.transferstruktur_eigentumsbeschraenkung AS eigentumsbeschraenkung 
        ON eigentumsbeschraenkung.t_id = dokument_typ.typ_eigentumsbeschraenkung
)
-- Die Tabelle transferstruktur_hinweisvorschrift ist die Verknpüfung zwischen
-- den Dokumenten und den Eigentumsbeschränkungen mit je einem Fremdschlüssel
-- auf Eigentumsbeschränkung und Vorschrift (und zusätzlich auf den Basket)
INSERT INTO
    arp_nutzungsplanung_oerebv2.transferstruktur_hinweisvorschrift
    (
        t_id,
        t_basket,
        eigentumsbeschraenkung,
        vorschrift 
    )
SELECT 
    nextval('arp_nutzungsplanung_oerebv2.t_ili2db_seq'::regclass) AS t_id,
    eigentumsbeschraenkung.t_basket,
    eigentumsbeschraenkung.t_id AS eigentumsbeschraenkung,
    dokument_typ.t_id AS vorschrift
FROM 
    dokument_typ
    INNER JOIN arp_nutzungsplanung_oerebv2.transferstruktur_eigentumsbeschraenkung AS eigentumsbeschraenkung 
    ON eigentumsbeschraenkung.t_id = dokument_typ.typ_eigentumsbeschraenkung
;