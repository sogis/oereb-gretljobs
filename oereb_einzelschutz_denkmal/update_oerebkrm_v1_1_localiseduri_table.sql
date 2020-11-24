UPDATE stage.oerebkrm_v1_1_localiseduri
    SET atext = replace(atext, 'https://ch.so.ada.denkmal', 'https://ch.so.ada.denkmal-stage')
WHERE
    atext LIKE '%ch.so.ada.denkmal%'
;
