SELECT t_id + 999999999 AS t_id, 999999902::int8 AS t_basket, 'dm01vch24lv95dgemeindegrenzen_gemeindegrenze'::varchar(60) AS t_type, NULL::varchar(200) AS t_ili_tid,
  ST_CurveToLine(geometrie)::geometry(POLYGON,2056) AS geometrie, entstehung + 999999999 AS entstehung, gemeindegrenze_von + 999999999 AS gemeindegrenze_von
FROM agi_dm01avso24.gemeindegrenzen_gemeindegrenze;
