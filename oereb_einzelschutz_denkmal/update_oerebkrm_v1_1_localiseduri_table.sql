UPDATE stage.oerebkrm_v1_1_localiseduri
    SET atext = replace(atext, 'https://ch.so.ada.denkmal', 'https://ch.so.ada.denkmal-stage')
WHERE
    oerebkrm_v1_1_localiseduri.t_basket = (
        SELECT
               DISTINCT basket.t_id               
            FROM
                stage.t_ili2db_dataset AS dataset
                LEFT JOIN stage.t_ili2db_basket AS basket
                ON basket.dataset = dataset.t_id
            WHERE
                dataset.datasetname = 'ch.so.ada.denkmalschutz'     
    )
;
