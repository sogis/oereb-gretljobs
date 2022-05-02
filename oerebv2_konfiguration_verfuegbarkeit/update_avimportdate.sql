WITH av_updates AS (
    SELECT
        ds.datasetname::int4 AS bfsnr,
        max(imp.importdate) AS last_importdate
    FROM 
        agi_dm01avso24.t_ili2db_dataset ds
        LEFT JOIN agi_dm01avso24.t_ili2db_import imp 
        ON ds.t_id = imp.dataset
    GROUP BY 
        ds.datasetname, imp.dataset
    ORDER BY 
        ds.datasetname ASC
)
UPDATE
    agi_konfiguration_oerebv2.konfiguration_gemeindemitoerebk AS munip
        SET basedatadate=avupd.last_importdate
    FROM 
        av_updates AS avupd
    WHERE 
        munip.municipality = avupd.bfsnr
        AND 
        t_datasetname = 'verfuegbarkeit'
;
