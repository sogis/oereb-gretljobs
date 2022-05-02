DELETE FROM 
    ${dbSchema}.so_g_rb0220222wms_einzelschutz_flaeche
WHERE 
    (
        thema = 'ch.SO.Einzelschutz'
        AND 
        artcodeliste = 'urn:fdc:ilismeta.interlis.ch:2019:Typ_Naturschutzgebiete_Flaeche'
    )
;
 
WITH eigentumsbeschraenkung_thema AS 
(
    SELECT 
        eigentumsbeschraenkung.t_id,
        legende.thema,
        legende.subthema,
        legende.legendetext_de AS legendetext,
        legende.artcode,
        legende.artcodeliste
    FROM 
        ${dbSchema}.oerbkrmfr_v2_0transferstruktur_eigentumsbeschraenkung AS eigentumsbeschraenkung
        LEFT JOIN ${dbSchema}.oerbkrmfr_v2_0transferstruktur_legendeeintrag AS legende
        ON eigentumsbeschraenkung.legende = legende.t_id 
    WHERE 
        (
            legende.thema = 'ch.SO.Einzelschutz'
            AND 
            legende.artcodeliste = 'urn:fdc:ilismeta.interlis.ch:2019:Typ_Naturschutzgebiete_Flaeche'
        )
)
,
dokumente AS 
(
    SELECT 
        hinweisvorschrift.eigentumsbeschraenkung,
        hinweisvorschrift.vorschrift AS t_id,
        dokument.t_ili_tid,
        dokument.typ,
        dokument.titel_de,
        dokument.abkuerzung_de,
        dokument.offiziellenr_de,
        dokument.auszugindex,
        dokument.rechtsstatus,
        dokument.publiziertab,
        dokument.publiziertbis
        
    FROM 
        ${dbSchema}.oerbkrmfr_v2_0transferstruktur_hinweisvorschrift AS hinweisvorschrift
        LEFT JOIN ${dbSchema}.oerebkrm_v2_0dokumente_dokument AS dokument 
        ON hinweisvorschrift.vorschrift = dokument.t_id 
    WHERE 
        eigentumsbeschraenkung IN 
        (
            SELECT 
                t_id 
            FROM 
                eigentumsbeschraenkung_thema
        )
)
,
eigentumsbeschraenkung_dokumente AS 
(
    SELECT
        eigentumsbeschraenkung,
        json_agg(json_strip_nulls(row_to_json(dokumente))) AS dokumente
    FROM 
        dokumente
    GROUP BY 
        eigentumsbeschraenkung
)
,
eigentumsbeschraenkung_amt AS 
(
    SELECT 
        eigentumsbeschraenkung.t_id,
        amt.aname_de AS zustaendigestelle,
        CASE 
            WHEN luri.atext IS NULL THEN 'https://keine-webseite.com'
            ELSE luri.atext 
        END AS amtimweb
    FROM 
        eigentumsbeschraenkung_thema 
        LEFT JOIN ${dbSchema}.oerbkrmfr_v2_0transferstruktur_eigentumsbeschraenkung AS eigentumsbeschraenkung
        ON eigentumsbeschraenkung.t_id = eigentumsbeschraenkung_thema.t_id
        LEFT JOIN ${dbSchema}.oerebkrm_v2_0amt_amt AS amt  
        ON amt.t_id = eigentumsbeschraenkung.zustaendigestelle 
        LEFT JOIN ${dbSchema}.oerebkrm_v2_0_multilingualuri AS muri 
        ON muri.oerebkrm_v2_0amt_amt_amtimweb = amt.t_id 
        LEFT JOIN 
        (
            SELECT 
                t_id,
                alanguage,
                atext,
                oerbkrm_v2__mltlngluri_localisedtext
            FROM
                ${dbSchema}.oerebkrm_v2_0_localiseduri 
            WHERE 
                alanguage = 'de'
        ) AS luri        
        ON luri.oerbkrm_v2__mltlngluri_localisedtext = muri.t_id
)
,
eigentumsbeschrankung_geometrie AS 
(
    SELECT 
        eigentumsbeschraenkung_thema.t_id, 
        geometrie.flaeche AS geometrie
    FROM 
        eigentumsbeschraenkung_thema 
        LEFT JOIN ${dbSchema}.oerbkrmfr_v2_0transferstruktur_geometrie AS geometrie 
        ON geometrie.eigentumsbeschraenkung = eigentumsbeschraenkung_thema.t_id
)
INSERT INTO 
    ${dbSchema}.so_g_rb0220222wms_einzelschutz_flaeche 
    (
        t_ili_tid,
        geometrie,
        legendetext,
        dokumente,
        artcode,
        artcodeliste,
        thema,
        subthema,
        rechtsstatus,
        zustaendigestelle,
        amtimweb,
        publiziertab,
        publiziertbis
    )
SELECT 
    eigentumsbeschraenkung.t_ili_tid,
    geometrie.geometrie,
    eigentumsbeschraenkung_thema.legendetext AS legendetext,
    eigentumsbeschraenkung_dokumente.dokumente AS dokumente,
    eigentumsbeschraenkung_thema.artcode,
    eigentumsbeschraenkung_thema.artcodeliste,
    eigentumsbeschraenkung_thema.thema,
    eigentumsbeschraenkung_thema.subthema,
    eigentumsbeschraenkung.rechtsstatus,
    eigentumsbeschraenkung_amt.zustaendigestelle AS zustaendigestelle,
    eigentumsbeschraenkung_amt.amtimweb AS amtimweb,
    eigentumsbeschraenkung.publiziertab,
    eigentumsbeschraenkung.publiziertbis
    
FROM 
    eigentumsbeschraenkung_thema 
    LEFT JOIN ${dbSchema}.oerbkrmfr_v2_0transferstruktur_eigentumsbeschraenkung AS eigentumsbeschraenkung
    ON eigentumsbeschraenkung.t_id = eigentumsbeschraenkung_thema.t_id
    LEFT JOIN eigentumsbeschraenkung_amt 
    ON eigentumsbeschraenkung_amt.t_id = eigentumsbeschraenkung.t_id    
    LEFT JOIN eigentumsbeschrankung_geometrie AS geometrie 
    ON geometrie.t_id = eigentumsbeschraenkung.t_id
    LEFT JOIN eigentumsbeschraenkung_dokumente 
    ON eigentumsbeschraenkung.t_id = eigentumsbeschraenkung_dokumente.eigentumsbeschraenkung
;

DELETE FROM 
    ${dbSchema}.so_g_rb0220222wms_nutzungsplanung_ueberlagernd_flaeche
WHERE 
    (
        thema = 'ch.Nutzungsplanung'
        AND 
        subthema = 'ch.SO.NutzungsplanungUeberlagernd'
        AND 
        artcodeliste = 'urn:fdc:ilismeta.interlis.ch:2017:NP_Typ_Kanton_Ueberlagernd_Flaeche.Naturreservat_Flaeche'
    )
;

WITH eigentumsbeschraenkung_thema AS 
(
    SELECT 
        eigentumsbeschraenkung.t_id,
        legende.thema,
        legende.subthema,
        legende.legendetext_de AS legendetext,
        legende.artcode,
        legende.artcodeliste
    FROM 
        ${dbSchema}.oerbkrmfr_v2_0transferstruktur_eigentumsbeschraenkung AS eigentumsbeschraenkung
        LEFT JOIN ${dbSchema}.oerbkrmfr_v2_0transferstruktur_legendeeintrag AS legende
        ON eigentumsbeschraenkung.legende = legende.t_id 
    WHERE 
        (
            legende.thema = 'ch.Nutzungsplanung'
            AND 
            legende.subthema = 'ch.SO.NutzungsplanungUeberlagernd'
            AND 
            legende.artcodeliste = 'urn:fdc:ilismeta.interlis.ch:2017:NP_Typ_Kanton_Ueberlagernd_Flaeche.Naturreservat_Flaeche'
        )
)
,
dokumente AS 
(
    SELECT 
        hinweisvorschrift.eigentumsbeschraenkung,
        hinweisvorschrift.vorschrift AS t_id,
        dokument.t_ili_tid,
        dokument.typ,
        dokument.titel_de,
        dokument.abkuerzung_de,
        dokument.offiziellenr_de,
        dokument.auszugindex,
        dokument.rechtsstatus,
        dokument.publiziertab,
        dokument.publiziertbis
        
    FROM 
        ${dbSchema}.oerbkrmfr_v2_0transferstruktur_hinweisvorschrift AS hinweisvorschrift
        LEFT JOIN ${dbSchema}.oerebkrm_v2_0dokumente_dokument AS dokument 
        ON hinweisvorschrift.vorschrift = dokument.t_id 
    WHERE 
        eigentumsbeschraenkung IN 
        (
            SELECT 
                t_id 
            FROM 
                eigentumsbeschraenkung_thema
        )
)
,
eigentumsbeschraenkung_dokumente AS 
(
    SELECT
        eigentumsbeschraenkung,
        json_agg(json_strip_nulls(row_to_json(dokumente))) AS dokumente
    FROM 
        dokumente
    GROUP BY 
        eigentumsbeschraenkung
)
,
eigentumsbeschraenkung_amt AS 
(
    SELECT 
        eigentumsbeschraenkung.t_id,
        amt.aname_de AS zustaendigestelle,
        CASE 
            WHEN luri.atext IS NULL THEN 'https://keine-webseite.com'
            ELSE luri.atext 
        END AS amtimweb
    FROM 
        eigentumsbeschraenkung_thema 
        LEFT JOIN ${dbSchema}.oerbkrmfr_v2_0transferstruktur_eigentumsbeschraenkung AS eigentumsbeschraenkung
        ON eigentumsbeschraenkung.t_id = eigentumsbeschraenkung_thema.t_id
        LEFT JOIN ${dbSchema}.oerebkrm_v2_0amt_amt AS amt  
        ON amt.t_id = eigentumsbeschraenkung.zustaendigestelle 
        LEFT JOIN ${dbSchema}.oerebkrm_v2_0_multilingualuri AS muri 
        ON muri.oerebkrm_v2_0amt_amt_amtimweb = amt.t_id 
        LEFT JOIN 
        (
            SELECT 
                t_id,
                alanguage,
                atext,
                oerbkrm_v2__mltlngluri_localisedtext
            FROM
                ${dbSchema}.oerebkrm_v2_0_localiseduri 
            WHERE 
                alanguage = 'de'
        ) AS luri        
        ON luri.oerbkrm_v2__mltlngluri_localisedtext = muri.t_id
)
,
eigentumsbeschrankung_geometrie AS 
(
    SELECT 
        eigentumsbeschraenkung_thema.t_id, 
        geometrie.flaeche AS geometrie
    FROM 
        eigentumsbeschraenkung_thema 
        LEFT JOIN ${dbSchema}.oerbkrmfr_v2_0transferstruktur_geometrie AS geometrie 
        ON geometrie.eigentumsbeschraenkung = eigentumsbeschraenkung_thema.t_id
)
INSERT INTO 
    ${dbSchema}.so_g_rb0220222wms_nutzungsplanung_ueberlagernd_flaeche 
    (
        t_ili_tid,
        geometrie,
        legendetext,
        dokumente,
        artcode,
        artcodeliste,
        thema,
        subthema,
        rechtsstatus,
        zustaendigestelle,
        amtimweb,
        publiziertab,
        publiziertbis
    )
SELECT 
    eigentumsbeschraenkung.t_ili_tid,
    geometrie.geometrie,
    eigentumsbeschraenkung_thema.legendetext AS legendetext,
    eigentumsbeschraenkung_dokumente.dokumente AS dokumente,
    eigentumsbeschraenkung_thema.artcode,
    eigentumsbeschraenkung_thema.artcodeliste,
    eigentumsbeschraenkung_thema.thema,
    eigentumsbeschraenkung_thema.subthema,
    eigentumsbeschraenkung.rechtsstatus,
    eigentumsbeschraenkung_amt.zustaendigestelle AS zustaendigestelle,
    eigentumsbeschraenkung_amt.amtimweb AS amtimweb,
    eigentumsbeschraenkung.publiziertab,
    eigentumsbeschraenkung.publiziertbis
    
FROM 
    eigentumsbeschraenkung_thema 
    LEFT JOIN ${dbSchema}.oerbkrmfr_v2_0transferstruktur_eigentumsbeschraenkung AS eigentumsbeschraenkung
    ON eigentumsbeschraenkung.t_id = eigentumsbeschraenkung_thema.t_id
    LEFT JOIN eigentumsbeschraenkung_amt 
    ON eigentumsbeschraenkung_amt.t_id = eigentumsbeschraenkung.t_id    
    LEFT JOIN eigentumsbeschrankung_geometrie AS geometrie 
    ON geometrie.t_id = eigentumsbeschraenkung.t_id
    LEFT JOIN eigentumsbeschraenkung_dokumente 
    ON eigentumsbeschraenkung.t_id = eigentumsbeschraenkung_dokumente.eigentumsbeschraenkung
;
