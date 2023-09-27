CREATE OR REPLACE VIEW test_stage.transferstruktur_geom_zustelle_flaeche AS
SELECT
    ovtg.t_id,
    ovtg.t_basket,
    ovtg.t_type,
    ovtg.t_ili_tid,
    ovtg.flaeche AS geometrie,
    ovtg.rechtsstatus,
    ovtg.publiziertab,
    ovtg.publiziertbis,
    ovtg.metadatengeobasisdaten,
    ovtg.eigentumsbeschraenkung
FROM
    test_stage.oerbkrmfr_v2_0transferstruktur_geometrie ovtg 
    JOIN test_stage.oerbkrmfr_v2_0transferstruktur_eigentumsbeschraenkung ovte
        ON ovtg.eigentumsbeschraenkung = ovte.t_id 
    JOIN test_stage.oerebkrm_v2_0amt_amt ovaa
        ON ovte.zustaendigestelle = ovaa.t_id 
WHERE
    ovaa.t_ili_tid ilike 'ch.' || ${bfsnr}
AND
    ovtg.flaeche is not null;

CREATE OR REPLACE VIEW test_stage.transferstruktur_geom_zustelle_linie AS
SELECT
    ovtg.t_id,
    ovtg.t_basket,
    ovtg.t_type,
    ovtg.t_ili_tid,
    ovtg.linie AS geometrie,
    ovtg.rechtsstatus,
    ovtg.publiziertab,
    ovtg.publiziertbis,
    ovtg.metadatengeobasisdaten,
    ovtg.eigentumsbeschraenkung
FROM
    test_stage.oerbkrmfr_v2_0transferstruktur_geometrie ovtg 
    JOIN test_stage.oerbkrmfr_v2_0transferstruktur_eigentumsbeschraenkung ovte
        ON ovtg.eigentumsbeschraenkung = ovte.t_id 
    JOIN test_stage.oerebkrm_v2_0amt_amt ovaa
        ON ovte.zustaendigestelle = ovaa.t_id 
WHERE
    ovaa.t_ili_tid ilike 'ch.' || ${bfsnr}
AND
    ovtg.linie is not null;

CREATE OR REPLACE VIEW test_stage.transferstruktur_geom_zustelle_punkt AS
SELECT
    ovtg.t_id,
    ovtg.t_basket,
    ovtg.t_type,
    ovtg.t_ili_tid,
    ovtg.punkt AS geometrie,
    ovtg.rechtsstatus,
    ovtg.publiziertab,
    ovtg.publiziertbis,
    ovtg.metadatengeobasisdaten,
    ovtg.eigentumsbeschraenkung
FROM
    test_stage.oerbkrmfr_v2_0transferstruktur_geometrie ovtg 
    JOIN test_stage.oerbkrmfr_v2_0transferstruktur_eigentumsbeschraenkung ovte
        ON ovtg.eigentumsbeschraenkung = ovte.t_id 
    JOIN test_stage.oerebkrm_v2_0amt_amt ovaa
        ON ovte.zustaendigestelle = ovaa.t_id 
WHERE
    ovaa.t_ili_tid ilike 'ch.' || ${bfsnr}
AND
    ovtg.punkt is not null;
