SELECT t_id AS t_id,
       -1::int8 AS t_basket,
       'dm01vch24lv95dbodenbedeckung_boflaeche'::varchar(60) AS t_type,
       NULL::varchar(200) AS t_ili_tid,
       geometrie,
       qualitaet,
       CASE WHEN art LIKE 'befestigt.uebrige_befestigte.%' THEN 'befestigt.uebrige_befestigte'
            WHEN art LIKE 'humusiert.Acker_Wiese_Weide.%' THEN 'humusiert.Acker_Wiese_Weide'
            WHEN art LIKE 'humusiert.Intensivkultur.uebrige_Intensivkultur.%' THEN 'humusiert.Intensivkultur.uebrige_Intensivkultur'
            WHEN art LIKE 'humusiert.Gartenanlage.%' THEN 'humusiert.Gartenanlage'
            WHEN art LIKE 'bestockt.uebrige_bestockte.%' THEN 'bestockt.uebrige_bestockte'
            WHEN art LIKE 'vegetationslos.Abbau_Deponie.%' THEN 'vegetationslos.Abbau_Deponie'
            ELSE art
       END AS art, 
       entstehung
FROM
       agi_dm01avso24.bodenbedeckung_boflaeche
;
