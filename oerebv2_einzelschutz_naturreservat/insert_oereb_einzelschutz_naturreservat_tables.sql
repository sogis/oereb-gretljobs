WITH themen AS 
(
    SELECT 
        'ch.SO.Einzelschutz' AS thema,
        CAST(NULL AS text) AS subthema
    UNION ALL
    SELECT 
        'ch.Nutzungsplanung' AS thema,
        'ch.SO.NutzungsplanungUeberlagernd' AS subthema
)
,
darstellungsdienst AS 
(
    SELECT
        nextval('arp_naturreservate_oerebv2.t_ili2db_seq'::regclass) AS t_id,
        basket.t_id AS basket_t_id,
        uuid_generate_v4() AS t_ili_tid,
        themen.thema,
        themen.subthema
    FROM 
    (
        SELECT
            t_id
        FROM
            arp_naturreservate_oerebv2.t_ili2db_basket
        WHERE
            t_ili_tid = 'ch.so.arp.oereb_einzelschutz_naturreservat' 
    ) AS basket, 
    themen
)
,
darstellungsdienst_insert AS (
    INSERT INTO 
        arp_naturreservate_oerebv2.transferstruktur_darstellungsdienst 
        (
            t_id,
            t_basket,
            t_ili_tid            
        )         
    SELECT 
        t_id,
        basket_t_id,
        t_ili_tid
    FROM 
        darstellungsdienst
)
,
darstellungsdienst_multilingualuri AS 
(
    INSERT INTO
        arp_naturreservate_oerebv2.multilingualuri 
        (
            t_basket,
            t_seq, 
            transfrstrkstllngsdnst_verweiswms
        )
    SELECT 
        basket_t_id,
        0,
        t_id
    FROM 
        darstellungsdienst
    RETURNING *
)
INSERT INTO 
    arp_naturreservate_oerebv2.localiseduri 
    (
        t_basket,
        t_seq,
        alanguage,
        atext,
        multilingualuri_localisedtext
    )
SELECT
    t_basket,
    0,
    'de',
    CASE
        WHEN darstellungsdienst.subthema IS NULL THEN '${wmsHost}/wms/oereb?SERVICE=WMS&VERSION=1.3.0&REQUEST=GetMap&FORMAT=image%2Fpng&TRANSPARENT=true&LAYERS='||darstellungsdienst.thema||'&STYLES=&SRS=EPSG%3A2056&CRS=EPSG%3A2056&DPI=96&WIDTH=1200&HEIGHT=1146&BBOX=2591250%2C1211350%2C2646050%2C1263700'
        ELSE '${wmsHost}/wms/oereb?SERVICE=WMS&VERSION=1.3.0&REQUEST=GetMap&FORMAT=image%2Fpng&TRANSPARENT=true&LAYERS='||darstellungsdienst.subthema||'&STYLES=&SRS=EPSG%3A2056&CRS=EPSG%3A2056&DPI=96&WIDTH=1200&HEIGHT=1146&BBOX=2591250%2C1211350%2C2646050%2C1263700'
    END AS atext,
    darstellungsdienst_multilingualuri.t_id
FROM
    darstellungsdienst_multilingualuri
    LEFT JOIN darstellungsdienst
    ON darstellungsdienst.t_id = darstellungsdienst_multilingualuri.transfrstrkstllngsdnst_verweiswms
;


/* 
 * Eigentumsbeschränkungen und Legendeneinträge
 * 
 * (1) Achtung: Mit der Einführung der Vorwirkung muss geprüft werden, ob dieser
 * einfache Filteransatz mit inKraft (hier und bei Dokumenten und Geometrie) noch
 * stimmt oder ob hier leicht komplexer gefiltert werden muss.
 * 
 * (2) Das Joinen mit den Legendeninträgen muss gut geprüft werden. 
 */
WITH darstellungsdienst AS 
(
    SELECT
        darstellungsdienst.t_id,
        darstellungsdienst.t_basket AS basket_t_id,
        localiseduri.atext
    FROM 
        arp_naturreservate_oerebv2.transferstruktur_darstellungsdienst AS darstellungsdienst
        LEFT JOIN arp_naturreservate_oerebv2.multilingualuri AS multilingualuri  
        ON multilingualuri.transfrstrkstllngsdnst_verweiswms = darstellungsdienst.t_id 
        LEFT JOIN arp_naturreservate_oerebv2.localiseduri AS localiseduri 
        ON localiseduri.multilingualuri_localisedtext = multilingualuri.t_id 
)
,
eigentumsbeschraenkung AS 
(
    SELECT 
        foo.t_id,
        darstellungsdienst.basket_t_id AS basket_t_id,
        foo.legendetext_de,
        foo.thema,
        foo.subthema,
        foo.artcode,
        foo.artcodeliste,
        foo.rechtsstatus,
        foo.publiziertab,
        foo.zustaendigestelle,
        darstellungsdienst.t_id AS darstellungsdienst
    FROM 
    (
        SELECT
            reservat.t_id,
            'Naturschutzgebiete' AS legendetext_de,
            CASE
                WHEN reservat.einzelschutz IS TRUE
                    THEN 'ch.SO.Einzelschutz'
                ELSE 'ch.Nutzungsplanung'
            END AS thema,
            CASE
                WHEN reservat.einzelschutz IS TRUE
                    THEN NULL
                ELSE 'ch.SO.NutzungsplanungUeberlagernd'
            END AS subthema,        
            CASE
                WHEN reservat.einzelschutz IS TRUE
                    THEN 'naturschutzgebiete'
                ELSE '5220'
            END AS artcode,
            CASE
                WHEN reservat.einzelschutz IS TRUE
                    THEN 'urn:fdc:ilismeta.interlis.ch:2019:Typ_Naturschutzgebiete_Flaeche'
                ELSE 'urn:fdc:ilismeta.interlis.ch:2017:NP_Typ_Kanton_Ueberlagernd_Flaeche.Naturreservat_Flaeche'
            END AS artcodeliste,
            'inKraft' AS rechtsstatus,
            reservat.publiziertab AS publiziertab,
            amt.t_id AS zustaendigestelle
        FROM
            arp_naturreservate.reservate_reservat AS reservat
            LEFT JOIN arp_naturreservate_oerebv2.amt_amt AS amt
            ON amt.t_ili_tid = 'ch.so.arp'
        WHERE
            reservat.rechtsstatus = 'inKraft'
    ) AS foo
    LEFT JOIN darstellungsdienst
    ON (darstellungsdienst.atext ILIKE '%'||thema||'%' OR darstellungsdienst.atext ILIKE '%'||subthema||'%')
)
,
legendeneintrag AS (
    INSERT INTO 
        arp_naturreservate_oerebv2.transferstruktur_legendeeintrag 
        (
            t_id,
            t_basket,
            t_ili_tid,
            symbol,
            legendetext_de,
            artcode,
            artcodeliste,
            thema,
            subthema,
            darstellungsdienst    
        )
    SELECT 
        DISTINCT ON (artcode, artcodeliste)
        nextval('arp_naturreservate_oerebv2.t_ili2db_seq'::regclass) AS legendeneintrag_t_id,
        basket_t_id,
        uuid_generate_v4(),
        eintrag.symbol,
        legendetext_de,
        eigentumsbeschraenkung.artcode,
        eigentumsbeschraenkung.artcodeliste,
        eigentumsbeschraenkung.thema,
        eigentumsbeschraenkung.subthema,
        darstellungsdienst
    FROM 
        eigentumsbeschraenkung 
        LEFT JOIN arp_naturreservate_oerebv2.legendeneintraege_legendeneintrag AS eintrag
        ON 
        (
            (
                eigentumsbeschraenkung.artcode = eintrag.artcode
                OR 
                substring(eigentumsbeschraenkung.artcode FROM 1 FOR 3) = eintrag.artcode
            )
            AND 
            eigentumsbeschraenkung.artcodeliste = eintrag.artcodeliste
        )
    RETURNING *
)
INSERT INTO
    arp_naturreservate_oerebv2.transferstruktur_eigentumsbeschraenkung 
    (
        t_id,
        t_basket,
        t_ili_tid,
        rechtsstatus,
        publiziertab,
        darstellungsdienst,
        legende,
        zustaendigestelle
    )
SELECT 
    eigentumsbeschraenkung.t_id, 
    eigentumsbeschraenkung.basket_t_id,
    uuid_generate_v4(),
    eigentumsbeschraenkung.rechtsstatus,
    eigentumsbeschraenkung.publiziertab,
    eigentumsbeschraenkung.darstellungsdienst,
    legendeneintrag.t_id,
    eigentumsbeschraenkung.zustaendigestelle
FROM 
    eigentumsbeschraenkung 
    LEFT JOIN legendeneintrag 
    ON (eigentumsbeschraenkung.artcode = legendeneintrag.artcode AND eigentumsbeschraenkung.artcodeliste = legendeneintrag.artcodeliste)
;

/*
 * Dokumente
 */

INSERT INTO
    arp_naturreservate_oerebv2.dokumente_dokument
    (
        t_id,
        t_basket,
        t_ili_tid,
        typ,
        titel_de,
        abkuerzung_de,
        offiziellenr_de,
        auszugindex,
        rechtsstatus,
        publiziertab,
        zustaendigestelle
    )
    SELECT
        dokument.t_id AS t_id,
        basket.t_id AS basket_t_id,
        '_'||SUBSTRING(REPLACE(CAST(dokument.t_id AS text), '-', ''),1,15) AS t_ili_tid,
        'Rechtsvorschrift' AS art,
        CASE
            WHEN dokument.typ = 'RRB'
                 THEN concat('Regierungsratsbeschluss', ' ,' || dokument.bezeichnung)
            ELSE concat(dokument_typ, ' ,' || dokument.bezeichnung)
        END AS titel_de,
        dokument.typ AS abkuerzung_de,
        dokument.offiziellenr AS offiziellenr,
        CAST(998 AS int4) AS auszugindex,
        'inKraft' AS rechtsstatus,
        dokument.publiziertab,
        amt.t_id AS zustaendigestelle
    FROM
        arp_naturreservate.reservate_dokument AS dokument,
        (
            SELECT 
                t_id
            FROM 
                arp_naturreservate_oerebv2.amt_amt 
            WHERE 
                t_ili_tid = 'ch.so.arp'
        ) AS amt,
        (
            SELECT 
                t_id 
            FROM 
                arp_naturreservate_oerebv2.t_ili2db_basket 
            WHERE 
                t_ili_tid = 'ch.so.arp.oereb_einzelschutz_naturreservat'
        ) AS basket
    WHERE
        dokument.rechtsvorschrift IS TRUE
    AND
        dokument.rechtsstatus= 'inKraft'
;

INSERT INTO
    arp_naturreservate_oerebv2.transferstruktur_hinweisvorschrift
    (
        t_basket,
        eigentumsbeschraenkung,
        vorschrift
    )
    SELECT
        basket.t_id AS basket_t_id,
        hinweis_vorschrift.reservat AS eigentumsbeschraenkung,
        hinweis_vorschrift.dokument AS vorschrift
    FROM
    arp_naturreservate.reservate_reservat_dokument AS hinweis_vorschrift
        INNER JOIN arp_naturreservate_oerebv2.dokumente_dokument AS dokumente_dokument
        ON dokumente_dokument.t_id = hinweis_vorschrift.dokument
    INNER JOIN arp_naturreservate_oerebv2.transferstruktur_eigentumsbeschraenkung AS eigentumsbeschraenkung
    ON eigentumsbeschraenkung.t_id = hinweis_vorschrift.reservat,
    (
        SELECT 
            t_id 
        FROM 
            arp_naturreservate_oerebv2.t_ili2db_basket 
        WHERE 
            t_ili_tid = 'ch.so.arp.oereb_einzelschutz_naturreservat'
    ) AS basket
;

WITH multilingualuri AS
(
    INSERT INTO
        arp_naturreservate_oerebv2.multilingualuri
        (
            t_id,
            t_basket,
            t_seq,
            dokumente_dokument_textimweb
        )
    SELECT
        nextval('arp_naturreservate_oerebv2.t_ili2db_seq'::regclass) AS t_id,
        basket.t_id AS basket_t_id,
        0 AS t_seq,
        dokumente_dokument.t_id AS dokumente_dokument_textimweb
    FROM
        arp_naturreservate_oerebv2.dokumente_dokument AS dokumente_dokument,
        (
            SELECT 
                t_id 
            FROM 
                arp_naturreservate_oerebv2.t_ili2db_basket 
            WHERE 
                t_ili_tid = 'ch.so.arp.oereb_einzelschutz_naturreservat'
        ) AS basket
    RETURNING *
)
,
localiseduri AS
(
    SELECT
        nextval('arp_naturreservate_oerebv2.t_ili2db_seq'::regclass) AS t_id,
        basket.t_id AS basket_t_id,
        0 AS t_seq,
        'de' AS alanguage,
        CASE
            WHEN rechtsvorschriften_dokument.dateipfad IS NULL
                THEN 'https://geo.so.ch/docs/ch.so.arp.naturreservate/rrb/404.pdf'
            ELSE replace(replace(rechtsvorschriften_dokument.dateipfad, 'G:\documents\ch.so.arp.naturreservate\', 'https://geo.so.ch/docs/ch.so.arp.naturreservate/'),'\', '/')
        END AS atext,
        multilingualuri.t_id AS multilingualuri_localisedtext
    FROM
        arp_naturreservate.reservate_dokument AS rechtsvorschriften_dokument
        RIGHT JOIN multilingualuri
        ON multilingualuri.dokumente_dokument_textimweb = rechtsvorschriften_dokument.t_id,
        (
            SELECT 
                t_id 
            FROM 
                arp_naturreservate_oerebv2.t_ili2db_basket 
            WHERE 
                t_ili_tid = 'ch.so.arp.oereb_einzelschutz_naturreservat'
        ) AS basket
    WHERE
        rechtsvorschriften_dokument.rechtsvorschrift IS TRUE
    AND
        rechtsvorschriften_dokument.rechtsstatus= 'inKraft'
)
INSERT INTO
    arp_naturreservate_oerebv2.localiseduri
    (
        t_id,
        t_basket,
        t_seq,
        alanguage,
        atext,
        multilingualuri_localisedtext
    )
    SELECT
        t_id,
        basket_t_id,
        t_seq,
        alanguage,
        atext,
        multilingualuri_localisedtext
    FROM
        localiseduri
;

/*
 * Umbau der Geometrien, die Inhalt des ÖREB-Katasters sind.
 * 
 */

INSERT INTO
    arp_naturreservate_oerebv2.transferstruktur_geometrie
    (
        t_basket,
        flaeche,
        rechtsstatus,
        publiziertab,
        eigentumsbeschraenkung
    )
    SELECT
        basket.t_id AS basket_t_id,
        ST_ReducePrecision((ST_Dump(teilgebiet_geometrie.geometrie)).geom::geometry(Polygon,2056), 0.001) AS flaeche,
        teilgebiet_geometrie.rechtsstatus,
        teilgebiet_geometrie.publiziertab AS publiziertab,
        eigentumsbeschraenkung.t_id AS eigentumsbeschraenkung
    FROM
        arp_naturreservate.reservate_teilgebiet AS teilgebiet_geometrie
        INNER JOIN arp_naturreservate_oerebv2.transferstruktur_eigentumsbeschraenkung AS eigentumsbeschraenkung
        ON teilgebiet_geometrie.reservat = eigentumsbeschraenkung.t_id,
        (
            SELECT 
                t_id 
            FROM 
                arp_naturreservate_oerebv2.t_ili2db_basket 
            WHERE 
                t_ili_tid = 'ch.so.arp.oereb_einzelschutz_naturreservat'
        ) AS basket
    WHERE
        teilgebiet_geometrie.rechtsstatus= 'inKraft'
;