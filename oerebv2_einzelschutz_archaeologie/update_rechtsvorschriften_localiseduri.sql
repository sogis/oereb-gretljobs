UPDATE stage.oerebkrm_v2_0_localiseduri
    SET atext = replace(atext, 'ch.so.ada.archaeologie', 'ch.so.ada.archaeologie-stage')
WHERE
    atext LIKE '%ch.so.ada.archaeologie%'
AND
    strpos(atext, '-stage') = 0
;