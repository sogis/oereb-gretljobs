SELECT t_id + 999999999 AS t_id, 999999904::int8 AS t_basket, 'dm01vch24lv95dgemeindegrenzen_lsnachfuehrung'::varchar(60) AS t_type, NULL::varchar(200) AS t_ili_tid,
  nbident, identifikator, beschreibung, ST_CurveToLine(perimeter)::geometry(POLYGON,2056) AS perimeter, gueltigkeit, gueltigereintrag, gbeintrag, datum1, datum2
FROM agi_dm01avso24.liegenschaften_lsnachfuehrung;
