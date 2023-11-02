SELECT
    COUNT(tr.*) AS anzahl
FROM
    stage.oerbkrmfr_v2_0transferstruktur_geometrie tr
    JOIN stage.t_ili2db_basket ba
        ON tr.t_basket = ba.t_id
    JOIN stage.t_ili2db_dataset ds
        ON ba.dataset = ds.t_id
WHERE
    ds.datasetname ILIKE 'ch.so.arp.oereb_nutzungsplanung.' || ${bfsnr};
