-- datasets
INSERT INTO live.t_ili2db_dataset
SELECT t_id, datasetname FROM stage.t_ili2db_dataset 
  WHERE t_id NOT IN (SELECT t_id FROM live.t_ili2db_dataset);
-- baskets
INSERT INTO live.t_ili2db_basket
SELECT t_id, dataset, topic, t_ili_tid, attachmentkey, domains
  FROM stage.t_ili2db_basket
 WHERE t_id NOT IN (SELECT t_id FROM live.t_ili2db_basket)