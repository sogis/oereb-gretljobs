SELECT
    COUNT(ovtg.*) AS anzahl
FROM
    test_stage.oerbkrmfr_v2_0transferstruktur_geometrie ovtg 
    JOIN test_stage.oerbkrmfr_v2_0transferstruktur_eigentumsbeschraenkung ovte
        ON ovtg.eigentumsbeschraenkung = ovte.t_id 
    JOIN test_stage.oerebkrm_v2_0amt_amt ovaa
        ON ovte.zustaendigestelle = ovaa.t_id 
WHERE
    ovaa.t_ili_tid ilike 'ch.' || ${bfsnr};
