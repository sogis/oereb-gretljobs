-- delete old datasets
DELETE FROM stage.t_ili2db_dataset WHERE datasetname LIKE 'ch.so.agi.OeREB_extractAnnex.xtf-%';
DELETE FROM stage.t_ili2db_dataset WHERE datasetname LIKE 'ch.so.agi.OeREB_extractAnnex_%';
DELETE FROM stage.t_ili2db_dataset WHERE datasetname = 'ch.so.agi.oereb_extract_annex.aktive_gemeinden';
DELETE FROM stage.t_ili2db_dataset WHERE datasetname = 'ch.so.agi.oereb_extract_annex.katasteramt';
DELETE FROM stage.t_ili2db_dataset WHERE datasetname = 'ch.so.agi.oereb_extract_annex.stammdaten';
--delete old baskets
DELETE FROM stage.t_ili2db_basket WHERE attachmentkey LIKE 'ch.so.agi.OeREB_extractAnnex-AktiveGemeinden.xtf-%';
DELETE FROM stage.t_ili2db_basket WHERE attachmentkey LIKE 'ch.so.agi.OeREB_extractAnnex-KatatasterAmt.xtf-%';
DELETE FROM stage.t_ili2db_basket WHERE attachmentkey LIKE 'ch.so.agi.OeREB_extractAnnex-Stammdaten.xtf-%';
DELETE FROM stage.t_ili2db_basket WHERE attachmentkey LIKE 'ch.so.agi.OeREB_extractAnnex.xtf-%'
--delete everything from stage in the right order
DELETE FROM stage.oerb_xtnx_v1_0annex_logo;
DELETE FROM stage.oerb_xtnx_v1_0annex_glossary;
DELETE FROM stage.oerb_xtnx_v1_0annex_exclusionofliability;
DELETE FROM stage.oerb_xtnx_v1_0annex_generalinformation;
DELETE FROM stage.oerb_xtnx_v1_0annex_thematxt;
DELETE FROM stage.oereb_extractannex_v1_0_code_;
DELETE FROM stage.oerb_xtnx_v1_0annex_municipalitywithplrc;
DELETE FROM stage.oerb_xtnx_v1_0annex_office;
DELETE FROM stage.oerb_xtnx_v1_0annex_maplayering;
DELETE FROM stage.oerb_xtnx_v1_0annex_basedata;
