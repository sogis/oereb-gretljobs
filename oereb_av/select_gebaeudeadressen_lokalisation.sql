SELECT t_id + 999999999 AS t_id, 999999904::int8 AS t_basket, 'dm01vch24lv95dgemeindegrenzen_lsnachfuehrung'::varchar(60) AS t_type, NULL::varchar(200) AS t_ili_tid,
  nummerierungsprinzip, lokalisationnummer, attributeprovisorisch, istoffiziellebezeichnung, astatus, inaenderung, art, entstehung + 999999999 AS entstehung
FROM agi_dm01avso24.gebaeudeadressen_lokalisation;
