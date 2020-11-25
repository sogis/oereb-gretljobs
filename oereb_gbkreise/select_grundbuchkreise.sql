SELECT 
    t_id, -3::int8 AS t_basket, 
    'so_g_v_0180822grundbuchkreise_grundbuchkreis'::varchar(60) AS t_type, 
    NULL::varchar(200) AS t_ili_tid,
    aname, 
    art, 
    nbident, 
    grundbuchkreisnummer, 
    grundbuchkreis_bfsnr, 
    bfsnr, perimeter, 
    amtschreiberei, 
    amt, 
    strasse, 
    hausnummer, 
    plz, 
    ortschaft, 
    telefon, 
    email, 
    web, 
    auid
FROM 
    agi_av_gb_admin_einteilung_pub.grundbuchkreise_grundbuchkreis
;
