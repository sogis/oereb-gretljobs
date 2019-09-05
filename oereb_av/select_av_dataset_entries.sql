SELECT 999999901 AS t_id, 'avimport_gemeindegrenzen' AS datasetname
UNION
SELECT 999999903 AS t_id, 'avimport_liegenschaften' AS datasetname
UNION
SELECT 999999905 AS t_id, 'avimport_gebaeudeadressen' AS datasetname
UNION
SELECT 888888801 AS t_id, 'plzortschaften_ortschaft' AS datasetname
UNION
SELECT 888888803 AS t_id, 'plzortschaften_plz6' AS datasetname
UNION
SELECT 777777701 AS t_id, 'agi_av_gb_admin_einteilung_pub_grundbuchkreise' AS datasetname
ORDER BY t_id;
