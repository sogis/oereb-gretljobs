UPDATE stage.oerebkrm_v2_0_localiseduri ovl
SET atext = replace(atext, 'https://geo.so.ch/', 'https://geo-i.so.ch/')
WHERE ovl.atext ilike '%https://geo.so.ch/%';

UPDATE live.oerebkrm_v2_0_localiseduri ovl
SET atext = replace(atext, 'https://geo.so.ch/', 'https://geo-i.so.ch/')
WHERE ovl.atext ilike '%https://geo.so.ch/%';