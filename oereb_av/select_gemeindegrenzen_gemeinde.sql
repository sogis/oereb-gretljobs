SELECT t_id + 999999999 AS t_id, 999999902::int8 AS t_basket, 'dm01vch24lv95dgemeindegrenzen_gemeinde'::varchar(60) AS t_type, NULL::varchar(200) AS t_ili_tid,
  aname::varchar(30) AS aname, bfsnr
FROM agi_dm01avso24.gemeindegrenzen_gemeinde;
