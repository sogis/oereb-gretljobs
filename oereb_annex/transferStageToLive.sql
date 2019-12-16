--first delete everything in the right order
DELETE FROM live.oerb_xtnx_v1_0annex_logo;
DELETE FROM live.oerb_xtnx_v1_0annex_glossary;
DELETE FROM live.oerb_xtnx_v1_0annex_exclusionofliability;
DELETE FROM live.oerb_xtnx_v1_0annex_generalinformation;
DELETE FROM live.oerb_xtnx_v1_0annex_thematxt;
DELETE FROM live.oereb_extractannex_v1_0_code_;
DELETE FROM live.oerb_xtnx_v1_0annex_municipalitywithplrc;
DELETE FROM live.oerb_xtnx_v1_0annex_office;
DELETE FROM live.oerb_xtnx_v1_0annex_maplayering;
DELETE FROM live.oerb_xtnx_v1_0annex_basedata;

-- base data
INSERT INTO live.oerb_xtnx_v1_0annex_basedata
 SELECT * FROM stage.oerb_xtnx_v1_0annex_basedata;
-- map layering
INSERT INTO live.oerb_xtnx_v1_0annex_maplayering
 SELECT * FROM stage.oerb_xtnx_v1_0annex_maplayering;
-- office
INSERT INTO live.oerb_xtnx_v1_0annex_office
 SELECT * FROM stage.oerb_xtnx_v1_0annex_office;
-- municipality with plrc
INSERT INTO live.oerb_xtnx_v1_0annex_municipalitywithplrc
  SELECT * FROM stage.oerb_xtnx_v1_0annex_municipalitywithplrc;
-- code list for active themes in muncipalities
INSERT INTO live.oereb_extractannex_v1_0_code_
  SELECT code.* FROM stage.oereb_extractannex_v1_0_code_ code;
 --     LEFT JOIN stage.t_ili2db_basket basket ON code.t_basket = basket.t_id
 --     LEFT JOIN stage.t_ili2db_dataset dataset ON basket.dataset = dataset.t_id
 --   WHERE dataset.datasetname = 'ch.so.agi.OeREB_extractAnnex_live';
-- themes - thematxt
INSERT INTO live.oerb_xtnx_v1_0annex_thematxt
 SELECT * FROM stage.oerb_xtnx_v1_0annex_thematxt;
-- generalinformation
INSERT INTO live.oerb_xtnx_v1_0annex_generalinformation 
 SELECT * FROM stage.oerb_xtnx_v1_0annex_generalinformation;
-- exclusion of liability
INSERT INTO live.oerb_xtnx_v1_0annex_exclusionofliability
 SELECT * FROM stage.oerb_xtnx_v1_0annex_exclusionofliability;
-- glossary
INSERT INTO live.oerb_xtnx_v1_0annex_glossary
  SELECT * FROM stage.oerb_xtnx_v1_0annex_glossary;
-- logo
INSERT INTO live.oerb_xtnx_v1_0annex_logo
  SELECT * FROM stage.oerb_xtnx_v1_0annex_logo;
