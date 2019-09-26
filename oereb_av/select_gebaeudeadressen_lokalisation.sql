SELECT t_id AS t_id, -1::int8 AS t_basket, 'dm01vch24lv95dgebaeudeadressen_lokalisation'::varchar(60) AS t_type, NULL::varchar(200) AS t_ili_tid,
  nummerierungsprinzip, lokalisationnummer, attributeprovisorisch, istoffiziellebezeichnung, astatus, inaenderung, art, entstehung AS entstehung
FROM agi_dm01avso24.gebaeudeadressen_lokalisation;
