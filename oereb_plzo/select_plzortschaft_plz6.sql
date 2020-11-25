SELECT t_id AS t_id, -2::int8 AS t_basket, 'plzoch1lv95dplzortschaft_plz6'::varchar(60) AS t_type, NULL::varchar(200) AS t_ili_tid,
  astatus, inaenderung, plz, zusatzziffern, flaeche, entstehung AS entstehung, plz6_von AS plz6_von
FROM agi_plz_ortschaften.plzortschaft_plz6;
