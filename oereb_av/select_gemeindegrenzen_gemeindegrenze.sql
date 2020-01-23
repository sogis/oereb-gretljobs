SELECT t_id AS t_id, -1::int8 AS t_basket, 'dm01vch24lv95dgemeindegrenzen_gemeindegrenze'::varchar(60) AS t_type, NULL::varchar(200) AS t_ili_tid,
  geometrie, entstehung AS entstehung, gemeindegrenze_von AS gemeindegrenze_von
FROM agi_dm01avso24.gemeindegrenzen_gemeindegrenze;
