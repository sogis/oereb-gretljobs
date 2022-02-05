SELECT t_id AS t_id, -1::int8 AS t_basket, 'dm01vch24lv95dgebaeudeadressen_gebaeudeeingang'::varchar(60) AS t_type, NULL::varchar(200) AS t_ili_tid,
  astatus, inaenderung, attributeprovisorisch, istoffiziellebezeichnung, lage, hoehenlage, hausnummer, im_gebaeude, gwr_egid, gwr_edid, entstehung AS entstehung, gebaeudeeingang_von AS gebaeudeeingang_von
FROM agi_dm01avso24.gebaeudeadressen_gebaeudeeingang;
