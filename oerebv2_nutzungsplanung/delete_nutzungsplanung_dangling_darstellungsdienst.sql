/**
 * Es werden die Darstellungsdienste gelöscht, die nicht verwendet werden. Sonst
 * gibt es Validierungsfehler. Ich teste nur ggü den Eigentumsbeschränkungen. 
 * Eigentlich müsste auch ggü den Legenden getestest werden. In unserem Fall scheint
 * mir das nicht notwendig, weil es keine Legenden ohne Eigentumsbeschränkung geben
 * darf. 
 */
WITH dangling_darstellungsdienst AS 
(
    SELECT 
        darstellungsdienst.t_id
    FROM
        arp_nutzungsplanung_oerebv2.transferstruktur_darstellungsdienst AS darstellungsdienst
        LEFT JOIN arp_nutzungsplanung_oerebv2.transferstruktur_eigentumsbeschraenkung AS eigentumsbeschrankung
        ON darstellungsdienst.t_id = eigentumsbeschrankung.darstellungsdienst 
    WHERE 
        eigentumsbeschrankung.t_id IS NULL       
)
,
dangling_multilingualuri AS 
(
    SELECT 
        muri.t_id
    FROM 
        arp_nutzungsplanung_oerebv2.multilingualuri AS muri
        INNER JOIN dangling_darstellungsdienst AS darstellungsdienst 
        ON muri.transfrstrkstllngsdnst_verweiswms = darstellungsdienst.t_id
)
,
dangling_localiseduri AS 
(
    SELECT 
        luri.t_id
    FROM 
        arp_nutzungsplanung_oerebv2.localiseduri AS luri
        INNER JOIN dangling_multilingualuri AS multilingualuri 
        ON luri.multilingualuri_localisedtext = multilingualuri.t_id
)
,
delete_dangling_localiseduri AS 
(
    DELETE FROM 
        arp_nutzungsplanung_oerebv2.localiseduri
    WHERE 
        t_id IN 
        (
            SELECT 
                t_id 
            FROM 
                dangling_localiseduri
        )
)
,
delete_dangling_multilingualuri AS 
(
    DELETE FROM 
        arp_nutzungsplanung_oerebv2.multilingualuri m 
    WHERE 
        t_id IN 
        (
            SELECT 
                t_id 
            FROM 
                dangling_multilingualuri
        )
)
DELETE FROM 
    arp_nutzungsplanung_oerebv2.transferstruktur_darstellungsdienst 
    WHERE 
        t_id IN 
        (
            SELECT 
                t_id 
            FROM 
                dangling_darstellungsdienst
        )
;