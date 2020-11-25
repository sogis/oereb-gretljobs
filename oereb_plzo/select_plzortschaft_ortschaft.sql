SELECT t_id AS t_id, -2::int8 AS t_basket, 'plzoch1lv95dplzortschaft_ortschaft'::varchar(60) AS t_type, NULL::varchar(200) AS t_ili_tid,
  astatus, inaenderung, flaeche, entstehung AS entstehung, ortschaft_von AS ortschaft_von
FROM agi_plz_ortschaften.plzortschaft_ortschaft;
