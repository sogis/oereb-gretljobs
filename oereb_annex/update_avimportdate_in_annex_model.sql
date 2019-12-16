WITH av_updates AS (
    SELECT
       ds.datasetname::int4 AS bfsnr,
       max(imp.importdate) AS last_importdate
    FROM agi_dm01avso24.t_ili2db_dataset ds
      LEFT JOIN agi_dm01avso24.t_ili2db_import imp ON ds.t_id = imp.dataset
      GROUP BY ds.datasetname, imp.dataset
      ORDER BY ds.datasetname ASC
)
UPDATE
  agi_oereb_annex.oerb_xtnx_v1_0annex_municipalitywithplrc munip
    SET basedatadate=avupd.last_importdate
  FROM av_updates avupd
    WHERE munip.municipality = avupd.bfsnr
;
