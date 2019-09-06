SELECT t_id AS t_id, -2::int8 AS t_basket, 'plzoch1lv95dplzortschaft_osnachfuehrung'::varchar(60) AS t_type, NULL::varchar(200) AS t_ili_tid,
  nbident, identifikator, beschreibung, perimeter, gueltigkeit, gueltigereintrag
FROM agi_plz_ortschaften.plzortschaft_osnachfuehrung;
