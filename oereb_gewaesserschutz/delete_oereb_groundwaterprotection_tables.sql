DELETE FROM
    afu_grundwasserschutz_oereb.transferstruktur_legendeeintrag
WHERE
    t_datasetname = 'ch.so.afu.grundwasserschutz'
;
DELETE FROM 
    afu_grundwasserschutz_oereb.localiseduri 
WHERE 
    t_datasetname = 'ch.so.afu.grundwasserschutz'
;
DELETE FROM 
    afu_grundwasserschutz_oereb.multilingualuri
WHERE 
    t_datasetname = 'ch.so.afu.grundwasserschutz'
;
DELETE FROM
    afu_grundwasserschutz_oereb.vorschriften_hinweisweiteredokumente
WHERE
    t_datasetname = 'ch.so.afu.grundwasserschutz'
;
DELETE FROM 
    afu_grundwasserschutz_oereb.transferstruktur_hinweisvorschrift
WHERE
    t_datasetname = 'ch.so.afu.grundwasserschutz'
;
DELETE FROM 
    afu_grundwasserschutz_oereb.vorschriften_dokument
WHERE
    t_datasetname = 'ch.so.afu.grundwasserschutz'
;
DELETE FROM 
    afu_grundwasserschutz_oereb.transferstruktur_geometrie
WHERE 
    t_datasetname = 'ch.so.afu.grundwasserschutz'
;
DELETE FROM 
    afu_grundwasserschutz_oereb.transferstruktur_eigentumsbeschraenkung
WHERE
    t_datasetname = 'ch.so.afu.grundwasserschutz'    
;
DELETE FROM
    afu_grundwasserschutz_oereb.transferstruktur_darstellungsdienst
WHERE
    t_datasetname = 'ch.so.afu.grundwasserschutz'
;
