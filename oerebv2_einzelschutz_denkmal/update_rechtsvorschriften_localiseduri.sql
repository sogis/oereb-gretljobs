UPDATE stage.oerebkrm_v2_0_localiseduri
    SET atext = replace(atext, 'ch.so.ada.denkmal', 'ch.so.ada.denkmal-stage')
WHERE
    atext LIKE '%ch.so.ada.denkmal%'
AND
    strpos(atext, '-stage') = 0
;