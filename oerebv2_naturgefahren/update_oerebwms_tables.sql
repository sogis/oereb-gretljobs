SELECT 
        eigentumsbeschraenkung.t_id,
        legende.thema,
        legende.subthema,
        legende.legendetext_de AS legendetext,
        legende.artcode,
        legende.artcodeliste
    FROM 
        ${dbSchema}.oerbkrmfr_v2_0transferstruktur_eigentumsbeschraenkung AS eigentumsbeschraenkung
        LEFT JOIN ${dbSchema}.oerbkrmfr_v2_0transferstruktur_legendeeintrag AS legende
        ON eigentumsbeschraenkung.legende = legende.t_id 
    WHERE 
        legende.subthema = 'ch.SO.NutzungsplanungNaturgefahren'