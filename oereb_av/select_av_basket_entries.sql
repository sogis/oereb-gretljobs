SELECT 999999902 AS t_id, 999999901 AS dataset, 'dm01vch24lv95d.gemeindegrenzen' AS topic, NULL::varchar(200) AS t_ili_tid, '-'::varchar(200) AS attachmentkey, NULL::varchar(1024) AS domains
UNION
SELECT 999999904 AS t_id, 999999903 AS dataset, 'dm01vch24lv95d.liegenschaften' AS topic, NULL::varchar(200) AS t_ili_tid, '-'::varchar(200) AS attachmentkey, NULL::varchar(1024) AS domains
UNION
SELECT 999999906 AS t_id, 999999905 AS dataset, 'dm01vch24lv95d.gebaeudeadressen' AS topic, NULL::varchar(200) AS t_ili_tid, '-'::varchar(200) AS attachmentkey, NULL::varchar(1024) AS domains
UNION
SELECT 888888802 AS t_id, 888888801 AS dataset, 'plzoch1lv95d.plzortschaft_ortschaft' AS topic, NULL::varchar(200) AS t_ili_tid, '-'::varchar(200) AS attachmentkey, NULL::varchar(1024) AS domains
UNION
SELECT 888888804 AS t_id, 888888803 AS dataset, 'plzoch1lv95d.plzortschaft_plz6' AS topic, NULL::varchar(200) AS t_ili_tid, '-'::varchar(200) AS attachmentkey, NULL::varchar(1024) AS domains
UNION
SELECT 777777702 AS t_id, 777777701 AS dataset, 'so_g_v_0180822.grundbuchkreise' AS topic, NULL::varchar(200) AS t_ili_tid, '-'::varchar(200) AS attachmentkey, NULL::varchar(1024) AS domains
ORDER BY t_id;
