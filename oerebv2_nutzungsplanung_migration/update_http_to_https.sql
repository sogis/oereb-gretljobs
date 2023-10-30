-- Update table in stage_v2 schema
UPDATE stage_v2.oerebkrm_v2_0_localiseduri
SET atext = replace(atext, 'http://', 'https://')
WHERE atext ILIKE 'http://geo.so.ch/%';

-- Update table in live_v2 schema
UPDATE live_v2.oerebkrm_v2_0_localiseduri
SET atext = replace(atext, 'http://', 'https://')
WHERE atext ILIKE 'http://geo.so.ch/%';