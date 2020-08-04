CREATE SCHEMA IF NOT EXISTS afu_geotope;
CREATE SEQUENCE afu_geotope.t_ili2db_seq;;
-- GeometryCHLV95_V1.SurfaceStructure
CREATE TABLE afu_geotope.surfacestructure (
  T_Id bigint PRIMARY KEY DEFAULT nextval('afu_geotope.t_ili2db_seq')
  ,T_Seq bigint NULL
  ,surface geometry(POLYGON,2056) NULL
  ,multisurface_surfaces bigint NULL
)
;
CREATE INDEX surfacestructure_surface_idx ON afu_geotope.surfacestructure USING GIST ( surface );
CREATE INDEX surfacestructure_multisurface_surfaces_idx ON afu_geotope.surfacestructure ( multisurface_surfaces );
-- GeometryCHLV95_V1.MultiSurface
CREATE TABLE afu_geotope.multisurface (
  T_Id bigint PRIMARY KEY DEFAULT nextval('afu_geotope.t_ili2db_seq')
  ,T_Seq bigint NULL
)
;
-- SO_AFU_Geotope_20200312.Lithostratigraphie.geologische_Schicht
CREATE TABLE afu_geotope.lithostratigrphie_geologische_schicht (
  T_Id bigint PRIMARY KEY DEFAULT nextval('afu_geotope.t_ili2db_seq')
  ,bezeichnung varchar(255) NOT NULL
  ,geologische_stufe bigint NOT NULL
)
;
CREATE INDEX lithstrtgrph_glgsch_schcht_geologische_stufe_idx ON afu_geotope.lithostratigrphie_geologische_schicht ( geologische_stufe );
COMMENT ON TABLE afu_geotope.lithostratigrphie_geologische_schicht IS 'Geologische Schicht/Formation (Lithostrati)';
COMMENT ON COLUMN afu_geotope.lithostratigrphie_geologische_schicht.bezeichnung IS 'Name der geologische Schicht';
COMMENT ON COLUMN afu_geotope.lithostratigrphie_geologische_schicht.geologische_stufe IS 'Fremdschluessel zu geologische_Stufe';
-- SO_AFU_Geotope_20200312.Lithostratigraphie.geologische_Serie
CREATE TABLE afu_geotope.lithostratigrphie_geologische_serie (
  T_Id bigint PRIMARY KEY DEFAULT nextval('afu_geotope.t_ili2db_seq')
  ,bezeichnung varchar(255) NOT NULL
  ,geologisches_system bigint NOT NULL
)
;
CREATE INDEX lithostratgrph_glgsch_srie_geologisches_system_idx ON afu_geotope.lithostratigrphie_geologische_serie ( geologisches_system );
COMMENT ON TABLE afu_geotope.lithostratigrphie_geologische_serie IS 'Geologische Serie (Chronostrati)';
COMMENT ON COLUMN afu_geotope.lithostratigrphie_geologische_serie.bezeichnung IS 'Name der geologischen Serie';
COMMENT ON COLUMN afu_geotope.lithostratigrphie_geologische_serie.geologisches_system IS 'Fremdschluessel zu geologisches System';
-- SO_AFU_Geotope_20200312.Lithostratigraphie.geologische_Stufe
CREATE TABLE afu_geotope.lithostratigrphie_geologische_stufe (
  T_Id bigint PRIMARY KEY DEFAULT nextval('afu_geotope.t_ili2db_seq')
  ,bezeichnung varchar(255) NOT NULL
  ,geologische_serie bigint NOT NULL
)
;
CREATE INDEX lithostrtgrph_glgsch_stufe_geologische_serie_idx ON afu_geotope.lithostratigrphie_geologische_stufe ( geologische_serie );
COMMENT ON TABLE afu_geotope.lithostratigrphie_geologische_stufe IS 'Geologische Stufe (Chronostrati)';
COMMENT ON COLUMN afu_geotope.lithostratigrphie_geologische_stufe.bezeichnung IS 'Name der geologischen Stufe';
COMMENT ON COLUMN afu_geotope.lithostratigrphie_geologische_stufe.geologische_serie IS 'Fremdschluessel zu geologische_Serie';
-- SO_AFU_Geotope_20200312.Lithostratigraphie.geologisches_System
CREATE TABLE afu_geotope.lithostratigrphie_geologisches_system (
  T_Id bigint PRIMARY KEY DEFAULT nextval('afu_geotope.t_ili2db_seq')
  ,bezeichnung varchar(255) NOT NULL
)
;
COMMENT ON TABLE afu_geotope.lithostratigrphie_geologisches_system IS 'Geologisches System (Chronostrati)';
COMMENT ON COLUMN afu_geotope.lithostratigrphie_geologisches_system.bezeichnung IS 'Name des geologischen Systems';
-- SO_AFU_Geotope_20200312.Geotope.Dokument
CREATE TABLE afu_geotope.geotope_dokument (
  T_Id bigint PRIMARY KEY DEFAULT nextval('afu_geotope.t_ili2db_seq')
  ,T_Ili_Tid uuid NULL DEFAULT uuid_generate_v4()
  ,titel varchar(100) NOT NULL
  ,offizieller_titel varchar(255) NOT NULL
  ,abkuerzung varchar(20) NULL
  ,pfad text NULL
  ,typ varchar(255) NOT NULL
  ,offizielle_nr varchar(100) NULL
  ,rechtsstatus varchar(255) NOT NULL
  ,publiziert_ab date NULL
)
;
COMMENT ON COLUMN afu_geotope.geotope_dokument.titel IS 'Dokumentenname';
COMMENT ON COLUMN afu_geotope.geotope_dokument.offizieller_titel IS 'offizieller Titel des Dokuments';
COMMENT ON COLUMN afu_geotope.geotope_dokument.abkuerzung IS 'Abkuerzung des Dokuments';
COMMENT ON COLUMN afu_geotope.geotope_dokument.pfad IS 'Pfad zum Dokument';
COMMENT ON COLUMN afu_geotope.geotope_dokument.typ IS 'Dokumententyp';
COMMENT ON COLUMN afu_geotope.geotope_dokument.offizielle_nr IS 'offizielle Nummer des Gesetzes oder des RRBs';
COMMENT ON COLUMN afu_geotope.geotope_dokument.rechtsstatus IS 'Rechtsstatus des Dokuments';
COMMENT ON COLUMN afu_geotope.geotope_dokument.publiziert_ab IS 'Datum, ab dem das Dokument in Kraft tritt';
-- SO_AFU_Geotope_20200312.Geotope.Fachbereich
CREATE TABLE afu_geotope.geotope_fachbereich (
  T_Id bigint PRIMARY KEY DEFAULT nextval('afu_geotope.t_ili2db_seq')
  ,T_Ili_Tid uuid NULL DEFAULT uuid_generate_v4()
  ,fachbereichsname varchar(20) NOT NULL
)
;
COMMENT ON TABLE afu_geotope.geotope_fachbereich IS 'Name des Fachbereichs beim AfU';
-- SO_AFU_Geotope_20200312.Geotope.zustaendige_Stelle
CREATE TABLE afu_geotope.geotope_zustaendige_stelle (
  T_Id bigint PRIMARY KEY DEFAULT nextval('afu_geotope.t_ili2db_seq')
  ,T_Ili_Tid uuid NULL DEFAULT uuid_generate_v4()
  ,amtsname varchar(255) NOT NULL
  ,amt_im_web varchar(255) NOT NULL
)
;
COMMENT ON TABLE afu_geotope.geotope_zustaendige_stelle IS 'fuer das Geotop zustaendige Stelle';
COMMENT ON COLUMN afu_geotope.geotope_zustaendige_stelle.amtsname IS 'Name des Amts / der zustaendigen Stelle';
COMMENT ON COLUMN afu_geotope.geotope_zustaendige_stelle.amt_im_web IS 'Webseite des Amts / der zustaendigen Stelle';
-- SO_AFU_Geotope_20200312.Geotope.Erratiker
CREATE TABLE afu_geotope.geotope_erratiker (
  T_Id bigint PRIMARY KEY DEFAULT nextval('afu_geotope.t_ili2db_seq')
  ,T_Ili_Tid uuid NULL DEFAULT uuid_generate_v4()
  ,geometrie geometry(POINT,2056) NOT NULL
  ,groesse varchar(100) NOT NULL
  ,eiszeit varchar(255) NOT NULL
  ,herkunft varchar(100) NOT NULL
  ,schalenstein boolean NULL
  ,aufenthaltsort varchar(200) NULL
  ,petrografie varchar(255) NOT NULL
  ,entstehung varchar(255) NOT NULL
  ,objektname varchar(200) NOT NULL
  ,regionalgeologische_einheit varchar(255) NOT NULL
  ,bedeutung varchar(255) NOT NULL
  ,zustand varchar(255) NOT NULL
  ,beschreibung varchar(2048) NULL
  ,schutzwuerdigkeit varchar(255) NOT NULL
  ,geowissenschaftlicher_wert varchar(255) NOT NULL
  ,anthropogene_gefaehrdung varchar(255) NOT NULL
  ,lokalname varchar(255) NOT NULL
  ,kant_geschuetztes_objekt boolean NOT NULL
  ,alte_inventar_nummer varchar(10) NULL
  ,ingeso_oid varchar(20) NULL
  ,hinweis_literatur varchar(512) NULL
  ,rechtsstatus varchar(255) NOT NULL
  ,publiziert_ab date NULL
  ,oereb_objekt boolean NOT NULL
  ,zustaendige_stelle bigint NULL
)
;
CREATE INDEX geotope_erratiker_geometrie_idx ON afu_geotope.geotope_erratiker USING GIST ( geometrie );
CREATE INDEX geotope_erratiker_zustaendige_stelle_idx ON afu_geotope.geotope_erratiker ( zustaendige_stelle );
COMMENT ON TABLE afu_geotope.geotope_erratiker IS 'Steinbloecke, die durch seltenere geophysikalische Prozesse oder menschliches Zutun nicht dort liegen, wo sie erwartet wuerden';
COMMENT ON COLUMN afu_geotope.geotope_erratiker.geometrie IS 'Punktgeometrie des Erratikers';
COMMENT ON COLUMN afu_geotope.geotope_erratiker.groesse IS 'Groesse des Erratikers (Laenge x Breite x Hoehe in [cm] oder Volumen in [m3])';
COMMENT ON COLUMN afu_geotope.geotope_erratiker.eiszeit IS 'Eiszeit aus welcher der Erratiker stammt';
COMMENT ON COLUMN afu_geotope.geotope_erratiker.herkunft IS 'Herkunft des Erratikers';
COMMENT ON COLUMN afu_geotope.geotope_erratiker.schalenstein IS 'Handelt es sich beim Erratiker um einen Schalenstein? ja/nein';
COMMENT ON COLUMN afu_geotope.geotope_erratiker.aufenthaltsort IS 'Aufenthaltsort des Erratikers';
COMMENT ON COLUMN afu_geotope.geotope_erratiker.petrografie IS 'mineralische und chemische Zusammensetzung der Gesteine und ihrer Gefuege';
COMMENT ON COLUMN afu_geotope.geotope_erratiker.entstehung IS 'Entstehung des Erratikers';
COMMENT ON COLUMN afu_geotope.geotope_erratiker.objektname IS 'Name des Geotops';
COMMENT ON COLUMN afu_geotope.geotope_erratiker.regionalgeologische_einheit IS 'Zuordnung des Geotops zu einer Gesamtheit der wichtigsten geologischen Merkmale einer Region';
COMMENT ON COLUMN afu_geotope.geotope_erratiker.bedeutung IS 'Bedeutung des Geotops';
COMMENT ON COLUMN afu_geotope.geotope_erratiker.zustand IS 'Verfassung des Geotops';
COMMENT ON COLUMN afu_geotope.geotope_erratiker.beschreibung IS 'kurze Beschreibung';
COMMENT ON COLUMN afu_geotope.geotope_erratiker.schutzwuerdigkeit IS 'Schutzwuerdigkeit des Geotops';
COMMENT ON COLUMN afu_geotope.geotope_erratiker.geowissenschaftlicher_wert IS 'Bedeutung des Geotops in der Geowissenschaft';
COMMENT ON COLUMN afu_geotope.geotope_erratiker.anthropogene_gefaehrdung IS 'durch den Mensch verursachte Bedrohung des Geotops';
COMMENT ON COLUMN afu_geotope.geotope_erratiker.lokalname IS 'Lokalname der Fundstelle des Geotops';
COMMENT ON COLUMN afu_geotope.geotope_erratiker.kant_geschuetztes_objekt IS 'Ist das Geotop durch den Kanton geschuetzt?';
COMMENT ON COLUMN afu_geotope.geotope_erratiker.alte_inventar_nummer IS 'alte Ingeso-Nummer';
COMMENT ON COLUMN afu_geotope.geotope_erratiker.ingeso_oid IS 'OID des INGESO-Systems';
COMMENT ON COLUMN afu_geotope.geotope_erratiker.hinweis_literatur IS 'Hinweise auf Literatur, welche nicht digital vorhanden ist';
COMMENT ON COLUMN afu_geotope.geotope_erratiker.rechtsstatus IS 'Rechtsstatus des Geotops';
COMMENT ON COLUMN afu_geotope.geotope_erratiker.publiziert_ab IS 'Datum an dem das Geotop in Kraft tritt';
COMMENT ON COLUMN afu_geotope.geotope_erratiker.oereb_objekt IS 'Ist das Geotop ein Teil des OEREB-Katasters?';
COMMENT ON COLUMN afu_geotope.geotope_erratiker.zustaendige_stelle IS 'Fremdschluessel zu zustaendige_Stelle';
-- SO_AFU_Geotope_20200312.Geotope.Hoehle
CREATE TABLE afu_geotope.geotope_hoehle (
  T_Id bigint PRIMARY KEY DEFAULT nextval('afu_geotope.t_ili2db_seq')
  ,T_Ili_Tid uuid NULL DEFAULT uuid_generate_v4()
  ,geometrie geometry(POINT,2056) NOT NULL
  ,objektname varchar(200) NOT NULL
  ,regionalgeologische_einheit varchar(255) NOT NULL
  ,bedeutung varchar(255) NOT NULL
  ,zustand varchar(255) NOT NULL
  ,beschreibung varchar(2048) NULL
  ,schutzwuerdigkeit varchar(255) NOT NULL
  ,geowissenschaftlicher_wert varchar(255) NOT NULL
  ,anthropogene_gefaehrdung varchar(255) NOT NULL
  ,lokalname varchar(255) NOT NULL
  ,kant_geschuetztes_objekt boolean NOT NULL
  ,alte_inventar_nummer varchar(10) NULL
  ,ingeso_oid varchar(20) NULL
  ,hinweis_literatur varchar(512) NULL
  ,rechtsstatus varchar(255) NOT NULL
  ,publiziert_ab date NULL
  ,oereb_objekt boolean NOT NULL
  ,zustaendige_stelle bigint NULL
)
;
CREATE INDEX geotope_hoehle_geometrie_idx ON afu_geotope.geotope_hoehle USING GIST ( geometrie );
CREATE INDEX geotope_hoehle_zustaendige_stelle_idx ON afu_geotope.geotope_hoehle ( zustaendige_stelle );
COMMENT ON TABLE afu_geotope.geotope_hoehle IS 'natuerlich entstandener unterirdischer Hohlraum';
COMMENT ON COLUMN afu_geotope.geotope_hoehle.geometrie IS 'Punktgeometrie der Hoehle';
COMMENT ON COLUMN afu_geotope.geotope_hoehle.objektname IS 'Name des Geotops';
COMMENT ON COLUMN afu_geotope.geotope_hoehle.regionalgeologische_einheit IS 'Zuordnung des Geotops zu einer Gesamtheit der wichtigsten geologischen Merkmale einer Region';
COMMENT ON COLUMN afu_geotope.geotope_hoehle.bedeutung IS 'Bedeutung des Geotops';
COMMENT ON COLUMN afu_geotope.geotope_hoehle.zustand IS 'Verfassung des Geotops';
COMMENT ON COLUMN afu_geotope.geotope_hoehle.beschreibung IS 'kurze Beschreibung';
COMMENT ON COLUMN afu_geotope.geotope_hoehle.schutzwuerdigkeit IS 'Schutzwuerdigkeit des Geotops';
COMMENT ON COLUMN afu_geotope.geotope_hoehle.geowissenschaftlicher_wert IS 'Bedeutung des Geotops in der Geowissenschaft';
COMMENT ON COLUMN afu_geotope.geotope_hoehle.anthropogene_gefaehrdung IS 'durch den Mensch verursachte Bedrohung des Geotops';
COMMENT ON COLUMN afu_geotope.geotope_hoehle.lokalname IS 'Lokalname der Fundstelle des Geotops';
COMMENT ON COLUMN afu_geotope.geotope_hoehle.kant_geschuetztes_objekt IS 'Ist das Geotop durch den Kanton geschuetzt?';
COMMENT ON COLUMN afu_geotope.geotope_hoehle.alte_inventar_nummer IS 'alte Ingeso-Nummer';
COMMENT ON COLUMN afu_geotope.geotope_hoehle.ingeso_oid IS 'OID des INGESO-Systems';
COMMENT ON COLUMN afu_geotope.geotope_hoehle.hinweis_literatur IS 'Hinweise auf Literatur, welche nicht digital vorhanden ist';
COMMENT ON COLUMN afu_geotope.geotope_hoehle.rechtsstatus IS 'Rechtsstatus des Geotops';
COMMENT ON COLUMN afu_geotope.geotope_hoehle.publiziert_ab IS 'Datum an dem das Geotop in Kraft tritt';
COMMENT ON COLUMN afu_geotope.geotope_hoehle.oereb_objekt IS 'Ist das Geotop ein Teil des OEREB-Katasters?';
COMMENT ON COLUMN afu_geotope.geotope_hoehle.zustaendige_stelle IS 'Fremdschluessel zu zustaendige_Stelle';
-- SO_AFU_Geotope_20200312.Geotope.Landschaftsform
CREATE TABLE afu_geotope.geotope_landschaftsform (
  T_Id bigint PRIMARY KEY DEFAULT nextval('afu_geotope.t_ili2db_seq')
  ,T_Ili_Tid uuid NULL DEFAULT uuid_generate_v4()
  ,geometrie geometry(MULTIPOLYGON,2056) NOT NULL
  ,landschaftstyp varchar(255) NOT NULL
  ,entstehung varchar(255) NOT NULL
  ,oberflaechenform varchar(255) NOT NULL
  ,objektname varchar(200) NOT NULL
  ,regionalgeologische_einheit varchar(255) NOT NULL
  ,bedeutung varchar(255) NOT NULL
  ,zustand varchar(255) NOT NULL
  ,beschreibung varchar(2048) NULL
  ,schutzwuerdigkeit varchar(255) NOT NULL
  ,geowissenschaftlicher_wert varchar(255) NOT NULL
  ,anthropogene_gefaehrdung varchar(255) NOT NULL
  ,lokalname varchar(255) NOT NULL
  ,kant_geschuetztes_objekt boolean NOT NULL
  ,alte_inventar_nummer varchar(10) NULL
  ,ingeso_oid varchar(20) NULL
  ,hinweis_literatur varchar(512) NULL
  ,rechtsstatus varchar(255) NOT NULL
  ,publiziert_ab date NULL
  ,oereb_objekt boolean NOT NULL
  ,zustaendige_stelle bigint NULL
)
;
CREATE INDEX geotope_landschaftsform_geometrie_idx ON afu_geotope.geotope_landschaftsform USING GIST ( geometrie );
CREATE INDEX geotope_landschaftsform_zustaendige_stelle_idx ON afu_geotope.geotope_landschaftsform ( zustaendige_stelle );
COMMENT ON TABLE afu_geotope.geotope_landschaftsform IS 'Form der Landschaft';
COMMENT ON COLUMN afu_geotope.geotope_landschaftsform.geometrie IS 'Flaechengeometrie der Landschaftsform';
COMMENT ON COLUMN afu_geotope.geotope_landschaftsform.landschaftstyp IS 'Art der Landschaftsform';
COMMENT ON COLUMN afu_geotope.geotope_landschaftsform.entstehung IS 'Entstehung der Landschaftsform';
COMMENT ON COLUMN afu_geotope.geotope_landschaftsform.oberflaechenform IS 'oberflaechige Form der Landschaftsform';
COMMENT ON COLUMN afu_geotope.geotope_landschaftsform.objektname IS 'Name des Geotops';
COMMENT ON COLUMN afu_geotope.geotope_landschaftsform.regionalgeologische_einheit IS 'Zuordnung des Geotops zu einer Gesamtheit der wichtigsten geologischen Merkmale einer Region';
COMMENT ON COLUMN afu_geotope.geotope_landschaftsform.bedeutung IS 'Bedeutung des Geotops';
COMMENT ON COLUMN afu_geotope.geotope_landschaftsform.zustand IS 'Verfassung des Geotops';
COMMENT ON COLUMN afu_geotope.geotope_landschaftsform.beschreibung IS 'kurze Beschreibung';
COMMENT ON COLUMN afu_geotope.geotope_landschaftsform.schutzwuerdigkeit IS 'Schutzwuerdigkeit des Geotops';
COMMENT ON COLUMN afu_geotope.geotope_landschaftsform.geowissenschaftlicher_wert IS 'Bedeutung des Geotops in der Geowissenschaft';
COMMENT ON COLUMN afu_geotope.geotope_landschaftsform.anthropogene_gefaehrdung IS 'durch den Mensch verursachte Bedrohung des Geotops';
COMMENT ON COLUMN afu_geotope.geotope_landschaftsform.lokalname IS 'Lokalname der Fundstelle des Geotops';
COMMENT ON COLUMN afu_geotope.geotope_landschaftsform.kant_geschuetztes_objekt IS 'Ist das Geotop durch den Kanton geschuetzt?';
COMMENT ON COLUMN afu_geotope.geotope_landschaftsform.alte_inventar_nummer IS 'alte Ingeso-Nummer';
COMMENT ON COLUMN afu_geotope.geotope_landschaftsform.ingeso_oid IS 'OID des INGESO-Systems';
COMMENT ON COLUMN afu_geotope.geotope_landschaftsform.hinweis_literatur IS 'Hinweise auf Literatur, welche nicht digital vorhanden ist';
COMMENT ON COLUMN afu_geotope.geotope_landschaftsform.rechtsstatus IS 'Rechtsstatus des Geotops';
COMMENT ON COLUMN afu_geotope.geotope_landschaftsform.publiziert_ab IS 'Datum an dem das Geotop in Kraft tritt';
COMMENT ON COLUMN afu_geotope.geotope_landschaftsform.oereb_objekt IS 'Ist das Geotop ein Teil des OEREB-Katasters?';
COMMENT ON COLUMN afu_geotope.geotope_landschaftsform.zustaendige_stelle IS 'Fremdschluessel zu zustaendige_Stelle';
-- SO_AFU_Geotope_20200312.Geotope.Quelle
CREATE TABLE afu_geotope.geotope_quelle (
  T_Id bigint PRIMARY KEY DEFAULT nextval('afu_geotope.t_ili2db_seq')
  ,T_Ili_Tid uuid NULL DEFAULT uuid_generate_v4()
  ,geometrie geometry(POINT,2056) NOT NULL
  ,objektname varchar(200) NOT NULL
  ,regionalgeologische_einheit varchar(255) NOT NULL
  ,bedeutung varchar(255) NOT NULL
  ,zustand varchar(255) NOT NULL
  ,beschreibung varchar(2048) NULL
  ,schutzwuerdigkeit varchar(255) NOT NULL
  ,geowissenschaftlicher_wert varchar(255) NOT NULL
  ,anthropogene_gefaehrdung varchar(255) NOT NULL
  ,lokalname varchar(255) NOT NULL
  ,kant_geschuetztes_objekt boolean NOT NULL
  ,alte_inventar_nummer varchar(10) NULL
  ,ingeso_oid varchar(20) NULL
  ,hinweis_literatur varchar(512) NULL
  ,rechtsstatus varchar(255) NOT NULL
  ,publiziert_ab date NULL
  ,oereb_objekt boolean NOT NULL
  ,zustaendige_stelle bigint NULL
)
;
CREATE INDEX geotope_quelle_geometrie_idx ON afu_geotope.geotope_quelle USING GIST ( geometrie );
CREATE INDEX geotope_quelle_zustaendige_stelle_idx ON afu_geotope.geotope_quelle ( zustaendige_stelle );
COMMENT ON TABLE afu_geotope.geotope_quelle IS 'Ort, an dem dauerhaft oder zeitweise Grundwasser auf natuerliche Weise an der Gelaendeoberflaeche austritt';
COMMENT ON COLUMN afu_geotope.geotope_quelle.geometrie IS 'Punktgeometrie der Quelle';
COMMENT ON COLUMN afu_geotope.geotope_quelle.objektname IS 'Name des Geotops';
COMMENT ON COLUMN afu_geotope.geotope_quelle.regionalgeologische_einheit IS 'Zuordnung des Geotops zu einer Gesamtheit der wichtigsten geologischen Merkmale einer Region';
COMMENT ON COLUMN afu_geotope.geotope_quelle.bedeutung IS 'Bedeutung des Geotops';
COMMENT ON COLUMN afu_geotope.geotope_quelle.zustand IS 'Verfassung des Geotops';
COMMENT ON COLUMN afu_geotope.geotope_quelle.beschreibung IS 'kurze Beschreibung';
COMMENT ON COLUMN afu_geotope.geotope_quelle.schutzwuerdigkeit IS 'Schutzwuerdigkeit des Geotops';
COMMENT ON COLUMN afu_geotope.geotope_quelle.geowissenschaftlicher_wert IS 'Bedeutung des Geotops in der Geowissenschaft';
COMMENT ON COLUMN afu_geotope.geotope_quelle.anthropogene_gefaehrdung IS 'durch den Mensch verursachte Bedrohung des Geotops';
COMMENT ON COLUMN afu_geotope.geotope_quelle.lokalname IS 'Lokalname der Fundstelle des Geotops';
COMMENT ON COLUMN afu_geotope.geotope_quelle.kant_geschuetztes_objekt IS 'Ist das Geotop durch den Kanton geschuetzt?';
COMMENT ON COLUMN afu_geotope.geotope_quelle.alte_inventar_nummer IS 'alte Ingeso-Nummer';
COMMENT ON COLUMN afu_geotope.geotope_quelle.ingeso_oid IS 'OID des INGESO-Systems';
COMMENT ON COLUMN afu_geotope.geotope_quelle.hinweis_literatur IS 'Hinweise auf Literatur, welche nicht digital vorhanden ist';
COMMENT ON COLUMN afu_geotope.geotope_quelle.rechtsstatus IS 'Rechtsstatus des Geotops';
COMMENT ON COLUMN afu_geotope.geotope_quelle.publiziert_ab IS 'Datum an dem das Geotop in Kraft tritt';
COMMENT ON COLUMN afu_geotope.geotope_quelle.oereb_objekt IS 'Ist das Geotop ein Teil des OEREB-Katasters?';
COMMENT ON COLUMN afu_geotope.geotope_quelle.zustaendige_stelle IS 'Fremdschluessel zu zustaendige_Stelle';
-- SO_AFU_Geotope_20200312.Geotope.Aufschluss
CREATE TABLE afu_geotope.geotope_aufschluss (
  T_Id bigint PRIMARY KEY DEFAULT nextval('afu_geotope.t_ili2db_seq')
  ,T_Ili_Tid uuid NULL DEFAULT uuid_generate_v4()
  ,geometrie geometry(MULTIPOLYGON,2056) NOT NULL
  ,petrografie varchar(255) NOT NULL
  ,entstehung varchar(255) NOT NULL
  ,oberflaechenform varchar(255) NOT NULL
  ,geologische_schicht_bis bigint NULL
  ,geologische_schicht_von bigint NULL
  ,geologische_serie_bis bigint NULL
  ,geologische_serie_von bigint NULL
  ,geologische_stufe_bis bigint NULL
  ,geologische_stufe_von bigint NULL
  ,geologisches_system_bis bigint NULL
  ,geologisches_system_von bigint NULL
  ,objektname varchar(200) NOT NULL
  ,regionalgeologische_einheit varchar(255) NOT NULL
  ,bedeutung varchar(255) NOT NULL
  ,zustand varchar(255) NOT NULL
  ,beschreibung varchar(2048) NULL
  ,schutzwuerdigkeit varchar(255) NOT NULL
  ,geowissenschaftlicher_wert varchar(255) NOT NULL
  ,anthropogene_gefaehrdung varchar(255) NOT NULL
  ,lokalname varchar(255) NOT NULL
  ,kant_geschuetztes_objekt boolean NOT NULL
  ,alte_inventar_nummer varchar(10) NULL
  ,ingeso_oid varchar(20) NULL
  ,hinweis_literatur varchar(512) NULL
  ,rechtsstatus varchar(255) NOT NULL
  ,publiziert_ab date NULL
  ,oereb_objekt boolean NOT NULL
  ,zustaendige_stelle bigint NULL
)
;
CREATE INDEX geotope_aufschluss_geometrie_idx ON afu_geotope.geotope_aufschluss USING GIST ( geometrie );
CREATE INDEX geotope_aufschluss_geologische_schicht_bis_idx ON afu_geotope.geotope_aufschluss ( geologische_schicht_bis );
CREATE INDEX geotope_aufschluss_geologische_schicht_von_idx ON afu_geotope.geotope_aufschluss ( geologische_schicht_von );
CREATE INDEX geotope_aufschluss_geologische_serie_bis_idx ON afu_geotope.geotope_aufschluss ( geologische_serie_bis );
CREATE INDEX geotope_aufschluss_geologische_serie_von_idx ON afu_geotope.geotope_aufschluss ( geologische_serie_von );
CREATE INDEX geotope_aufschluss_geologische_stufe_bis_idx ON afu_geotope.geotope_aufschluss ( geologische_stufe_bis );
CREATE INDEX geotope_aufschluss_geologische_stufe_von_idx ON afu_geotope.geotope_aufschluss ( geologische_stufe_von );
CREATE INDEX geotope_aufschluss_geologisches_system_bis_idx ON afu_geotope.geotope_aufschluss ( geologisches_system_bis );
CREATE INDEX geotope_aufschluss_geologisches_system_von_idx ON afu_geotope.geotope_aufschluss ( geologisches_system_von );
CREATE INDEX geotope_aufschluss_zustaendige_stelle_idx ON afu_geotope.geotope_aufschluss ( zustaendige_stelle );
COMMENT ON TABLE afu_geotope.geotope_aufschluss IS 'Stelle an der Erdoberflaeche, an der Gestein unverhuellt zu Tage tritt';
COMMENT ON COLUMN afu_geotope.geotope_aufschluss.geometrie IS 'Flaechengeometrie des Aufschlusses';
COMMENT ON COLUMN afu_geotope.geotope_aufschluss.petrografie IS 'mineralische und chemische Zusammensetzung der Gesteine und ihrer Gefuege';
COMMENT ON COLUMN afu_geotope.geotope_aufschluss.entstehung IS 'Entstehung des Aufschlusses';
COMMENT ON COLUMN afu_geotope.geotope_aufschluss.oberflaechenform IS 'oberflaechige Form des Aufschlusses';
COMMENT ON COLUMN afu_geotope.geotope_aufschluss.geologische_schicht_von IS 'Fremdschluessel zu geologische_Schicht';
COMMENT ON COLUMN afu_geotope.geotope_aufschluss.geologische_serie_bis IS 'Fremdschluessel zu geologische Serie';
COMMENT ON COLUMN afu_geotope.geotope_aufschluss.geologische_serie_von IS 'Fremdschluessel zu geologische_Serie';
COMMENT ON COLUMN afu_geotope.geotope_aufschluss.geologische_stufe_bis IS 'Fremdschluessel zu geologische_Stufe';
COMMENT ON COLUMN afu_geotope.geotope_aufschluss.geologische_stufe_von IS 'Fremdschluessel zu geologische_Stufe';
COMMENT ON COLUMN afu_geotope.geotope_aufschluss.geologisches_system_bis IS 'Fremdschluessel zu geologisches System';
COMMENT ON COLUMN afu_geotope.geotope_aufschluss.geologisches_system_von IS 'Fremdschluessel zu geologisches_System';
COMMENT ON COLUMN afu_geotope.geotope_aufschluss.objektname IS 'Name des Geotops';
COMMENT ON COLUMN afu_geotope.geotope_aufschluss.regionalgeologische_einheit IS 'Zuordnung des Geotops zu einer Gesamtheit der wichtigsten geologischen Merkmale einer Region';
COMMENT ON COLUMN afu_geotope.geotope_aufschluss.bedeutung IS 'Bedeutung des Geotops';
COMMENT ON COLUMN afu_geotope.geotope_aufschluss.zustand IS 'Verfassung des Geotops';
COMMENT ON COLUMN afu_geotope.geotope_aufschluss.beschreibung IS 'kurze Beschreibung';
COMMENT ON COLUMN afu_geotope.geotope_aufschluss.schutzwuerdigkeit IS 'Schutzwuerdigkeit des Geotops';
COMMENT ON COLUMN afu_geotope.geotope_aufschluss.geowissenschaftlicher_wert IS 'Bedeutung des Geotops in der Geowissenschaft';
COMMENT ON COLUMN afu_geotope.geotope_aufschluss.anthropogene_gefaehrdung IS 'durch den Mensch verursachte Bedrohung des Geotops';
COMMENT ON COLUMN afu_geotope.geotope_aufschluss.lokalname IS 'Lokalname der Fundstelle des Geotops';
COMMENT ON COLUMN afu_geotope.geotope_aufschluss.kant_geschuetztes_objekt IS 'Ist das Geotop durch den Kanton geschuetzt?';
COMMENT ON COLUMN afu_geotope.geotope_aufschluss.alte_inventar_nummer IS 'alte Ingeso-Nummer';
COMMENT ON COLUMN afu_geotope.geotope_aufschluss.ingeso_oid IS 'OID des INGESO-Systems';
COMMENT ON COLUMN afu_geotope.geotope_aufschluss.hinweis_literatur IS 'Hinweise auf Literatur, welche nicht digital vorhanden ist';
COMMENT ON COLUMN afu_geotope.geotope_aufschluss.rechtsstatus IS 'Rechtsstatus des Geotops';
COMMENT ON COLUMN afu_geotope.geotope_aufschluss.publiziert_ab IS 'Datum an dem das Geotop in Kraft tritt';
COMMENT ON COLUMN afu_geotope.geotope_aufschluss.oereb_objekt IS 'Ist das Geotop ein Teil des OEREB-Katasters?';
COMMENT ON COLUMN afu_geotope.geotope_aufschluss.zustaendige_stelle IS 'Fremdschluessel zu zustaendige_Stelle';
-- SO_AFU_Geotope_20200312.Geotope.Fundstelle_Grabung
CREATE TABLE afu_geotope.geotope_fundstelle_grabung (
  T_Id bigint PRIMARY KEY DEFAULT nextval('afu_geotope.t_ili2db_seq')
  ,T_Ili_Tid uuid NULL DEFAULT uuid_generate_v4()
  ,geometrie geometry(POINT,2056) NOT NULL
  ,aufenthaltsort varchar(200) NOT NULL
  ,fundgegenstaende varchar(200) NOT NULL
  ,petrografie varchar(255) NOT NULL
  ,geologische_schicht_bis bigint NULL
  ,geologische_schicht_von bigint NULL
  ,geologische_serie_bis bigint NULL
  ,geologische_serie_von bigint NULL
  ,geologische_stufe_bis bigint NULL
  ,geologische_stufe_von bigint NULL
  ,geologisches_system_bis bigint NULL
  ,geologisches_system_von bigint NULL
  ,objektname varchar(200) NOT NULL
  ,regionalgeologische_einheit varchar(255) NOT NULL
  ,bedeutung varchar(255) NOT NULL
  ,zustand varchar(255) NOT NULL
  ,beschreibung varchar(2048) NULL
  ,schutzwuerdigkeit varchar(255) NOT NULL
  ,geowissenschaftlicher_wert varchar(255) NOT NULL
  ,anthropogene_gefaehrdung varchar(255) NOT NULL
  ,lokalname varchar(255) NOT NULL
  ,kant_geschuetztes_objekt boolean NOT NULL
  ,alte_inventar_nummer varchar(10) NULL
  ,ingeso_oid varchar(20) NULL
  ,hinweis_literatur varchar(512) NULL
  ,rechtsstatus varchar(255) NOT NULL
  ,publiziert_ab date NULL
  ,oereb_objekt boolean NOT NULL
  ,zustaendige_stelle bigint NULL
)
;
CREATE INDEX geotope_fundstelle_grabung_geometrie_idx ON afu_geotope.geotope_fundstelle_grabung USING GIST ( geometrie );
CREATE INDEX geotope_fundstelle_grabung_geologische_schicht_bis_idx ON afu_geotope.geotope_fundstelle_grabung ( geologische_schicht_bis );
CREATE INDEX geotope_fundstelle_grabung_geologische_schicht_von_idx ON afu_geotope.geotope_fundstelle_grabung ( geologische_schicht_von );
CREATE INDEX geotope_fundstelle_grabung_geologische_serie_bis_idx ON afu_geotope.geotope_fundstelle_grabung ( geologische_serie_bis );
CREATE INDEX geotope_fundstelle_grabung_geologische_serie_von_idx ON afu_geotope.geotope_fundstelle_grabung ( geologische_serie_von );
CREATE INDEX geotope_fundstelle_grabung_geologische_stufe_bis_idx ON afu_geotope.geotope_fundstelle_grabung ( geologische_stufe_bis );
CREATE INDEX geotope_fundstelle_grabung_geologische_stufe_von_idx ON afu_geotope.geotope_fundstelle_grabung ( geologische_stufe_von );
CREATE INDEX geotope_fundstelle_grabung_geologisches_system_bis_idx ON afu_geotope.geotope_fundstelle_grabung ( geologisches_system_bis );
CREATE INDEX geotope_fundstelle_grabung_geologisches_system_von_idx ON afu_geotope.geotope_fundstelle_grabung ( geologisches_system_von );
CREATE INDEX geotope_fundstelle_grabung_zustaendige_stelle_idx ON afu_geotope.geotope_fundstelle_grabung ( zustaendige_stelle );
COMMENT ON TABLE afu_geotope.geotope_fundstelle_grabung IS 'Stelle an dem ein Fund gemacht wurde oder gegraben wurde';
COMMENT ON COLUMN afu_geotope.geotope_fundstelle_grabung.geometrie IS 'Punktgeometrie der Fundstelle oder der Grabung';
COMMENT ON COLUMN afu_geotope.geotope_fundstelle_grabung.aufenthaltsort IS 'Aufenthaltsort der Funde';
COMMENT ON COLUMN afu_geotope.geotope_fundstelle_grabung.fundgegenstaende IS 'gefundene Gegenstaende';
COMMENT ON COLUMN afu_geotope.geotope_fundstelle_grabung.petrografie IS 'mineralische und chemische Zusammensetzung der Gesteine und ihrer Gefuege';
COMMENT ON COLUMN afu_geotope.geotope_fundstelle_grabung.geologische_schicht_von IS 'Fremdschluessel zu geologische_Schicht';
COMMENT ON COLUMN afu_geotope.geotope_fundstelle_grabung.geologische_serie_bis IS 'Fremdschluessel zu geologische Serie';
COMMENT ON COLUMN afu_geotope.geotope_fundstelle_grabung.geologische_serie_von IS 'Fremdschluessel zu geologische_Serie';
COMMENT ON COLUMN afu_geotope.geotope_fundstelle_grabung.geologische_stufe_bis IS 'Fremdschluessel zu geologische_Stufe';
COMMENT ON COLUMN afu_geotope.geotope_fundstelle_grabung.geologische_stufe_von IS 'Fremdschluessel zu geologische_Stufe';
COMMENT ON COLUMN afu_geotope.geotope_fundstelle_grabung.geologisches_system_bis IS 'Fremdschluessel zu geologisches System';
COMMENT ON COLUMN afu_geotope.geotope_fundstelle_grabung.geologisches_system_von IS 'Fremdschluessel zu geologisches_System';
COMMENT ON COLUMN afu_geotope.geotope_fundstelle_grabung.objektname IS 'Name des Geotops';
COMMENT ON COLUMN afu_geotope.geotope_fundstelle_grabung.regionalgeologische_einheit IS 'Zuordnung des Geotops zu einer Gesamtheit der wichtigsten geologischen Merkmale einer Region';
COMMENT ON COLUMN afu_geotope.geotope_fundstelle_grabung.bedeutung IS 'Bedeutung des Geotops';
COMMENT ON COLUMN afu_geotope.geotope_fundstelle_grabung.zustand IS 'Verfassung des Geotops';
COMMENT ON COLUMN afu_geotope.geotope_fundstelle_grabung.beschreibung IS 'kurze Beschreibung';
COMMENT ON COLUMN afu_geotope.geotope_fundstelle_grabung.schutzwuerdigkeit IS 'Schutzwuerdigkeit des Geotops';
COMMENT ON COLUMN afu_geotope.geotope_fundstelle_grabung.geowissenschaftlicher_wert IS 'Bedeutung des Geotops in der Geowissenschaft';
COMMENT ON COLUMN afu_geotope.geotope_fundstelle_grabung.anthropogene_gefaehrdung IS 'durch den Mensch verursachte Bedrohung des Geotops';
COMMENT ON COLUMN afu_geotope.geotope_fundstelle_grabung.lokalname IS 'Lokalname der Fundstelle des Geotops';
COMMENT ON COLUMN afu_geotope.geotope_fundstelle_grabung.kant_geschuetztes_objekt IS 'Ist das Geotop durch den Kanton geschuetzt?';
COMMENT ON COLUMN afu_geotope.geotope_fundstelle_grabung.alte_inventar_nummer IS 'alte Ingeso-Nummer';
COMMENT ON COLUMN afu_geotope.geotope_fundstelle_grabung.ingeso_oid IS 'OID des INGESO-Systems';
COMMENT ON COLUMN afu_geotope.geotope_fundstelle_grabung.hinweis_literatur IS 'Hinweise auf Literatur, welche nicht digital vorhanden ist';
COMMENT ON COLUMN afu_geotope.geotope_fundstelle_grabung.rechtsstatus IS 'Rechtsstatus des Geotops';
COMMENT ON COLUMN afu_geotope.geotope_fundstelle_grabung.publiziert_ab IS 'Datum an dem das Geotop in Kraft tritt';
COMMENT ON COLUMN afu_geotope.geotope_fundstelle_grabung.oereb_objekt IS 'Ist das Geotop ein Teil des OEREB-Katasters?';
COMMENT ON COLUMN afu_geotope.geotope_fundstelle_grabung.zustaendige_stelle IS 'Fremdschluessel zu zustaendige_Stelle';
-- SO_AFU_Geotope_20200312.Geotope.Erratiker_Dokument
CREATE TABLE afu_geotope.geotope_erratiker_dokument (
  T_Id bigint PRIMARY KEY DEFAULT nextval('afu_geotope.t_ili2db_seq')
  ,dokument bigint NOT NULL
  ,erratiker bigint NOT NULL
)
;
CREATE INDEX geotope_erratiker_dokument_dokument_idx ON afu_geotope.geotope_erratiker_dokument ( dokument );
CREATE INDEX geotope_erratiker_dokument_erratiker_idx ON afu_geotope.geotope_erratiker_dokument ( erratiker );
-- SO_AFU_Geotope_20200312.Geotope.Erratiker_Fachbereich
CREATE TABLE afu_geotope.geotope_erratiker_fachbereich (
  T_Id bigint PRIMARY KEY DEFAULT nextval('afu_geotope.t_ili2db_seq')
  ,erratiker bigint NOT NULL
  ,fachbereich bigint NOT NULL
)
;
CREATE INDEX geotope_erratiker_fchbrich_erratiker_idx ON afu_geotope.geotope_erratiker_fachbereich ( erratiker );
CREATE INDEX geotope_erratiker_fchbrich_fachbereich_idx ON afu_geotope.geotope_erratiker_fachbereich ( fachbereich );
COMMENT ON COLUMN afu_geotope.geotope_erratiker_fachbereich.fachbereich IS 'Ein Erratiker hat im Minimum ein Fachbereich';
-- SO_AFU_Geotope_20200312.Geotope.Hoehle_Dokument
CREATE TABLE afu_geotope.geotope_hoehle_dokument (
  T_Id bigint PRIMARY KEY DEFAULT nextval('afu_geotope.t_ili2db_seq')
  ,hoehle bigint NOT NULL
  ,dokument bigint NOT NULL
)
;
CREATE INDEX geotope_hoehle_dokument_hoehle_idx ON afu_geotope.geotope_hoehle_dokument ( hoehle );
CREATE INDEX geotope_hoehle_dokument_dokument_idx ON afu_geotope.geotope_hoehle_dokument ( dokument );
-- SO_AFU_Geotope_20200312.Geotope.Hoehle_Fachbereich
CREATE TABLE afu_geotope.geotope_hoehle_fachbereich (
  T_Id bigint PRIMARY KEY DEFAULT nextval('afu_geotope.t_ili2db_seq')
  ,hoehle bigint NOT NULL
  ,fachbereich bigint NOT NULL
)
;
CREATE INDEX geotope_hoehle_fachbereich_hoehle_idx ON afu_geotope.geotope_hoehle_fachbereich ( hoehle );
CREATE INDEX geotope_hoehle_fachbereich_fachbereich_idx ON afu_geotope.geotope_hoehle_fachbereich ( fachbereich );
COMMENT ON TABLE afu_geotope.geotope_hoehle_fachbereich IS 'Eine Hoehle hat im Minimum ein Fachbereich';
COMMENT ON COLUMN afu_geotope.geotope_hoehle_fachbereich.fachbereich IS 'Eine Hoehle hat im Minimum ein Fachbereich';
-- SO_AFU_Geotope_20200312.Geotope.Landform_Dokument
CREATE TABLE afu_geotope.geotope_landform_dokument (
  T_Id bigint PRIMARY KEY DEFAULT nextval('afu_geotope.t_ili2db_seq')
  ,landform bigint NOT NULL
  ,dokument bigint NOT NULL
)
;
CREATE INDEX geotope_landform_dokument_landform_idx ON afu_geotope.geotope_landform_dokument ( landform );
CREATE INDEX geotope_landform_dokument_dokument_idx ON afu_geotope.geotope_landform_dokument ( dokument );
-- SO_AFU_Geotope_20200312.Geotope.Landform_Fachbereich
CREATE TABLE afu_geotope.geotope_landform_fachbereich (
  T_Id bigint PRIMARY KEY DEFAULT nextval('afu_geotope.t_ili2db_seq')
  ,landform bigint NOT NULL
  ,fachbereich bigint NOT NULL
)
;
CREATE INDEX geotope_landform_fachbrich_landform_idx ON afu_geotope.geotope_landform_fachbereich ( landform );
CREATE INDEX geotope_landform_fachbrich_fachbereich_idx ON afu_geotope.geotope_landform_fachbereich ( fachbereich );
COMMENT ON COLUMN afu_geotope.geotope_landform_fachbereich.fachbereich IS 'Eine Landform hat im Minimum ein Fachbereich';
-- SO_AFU_Geotope_20200312.Geotope.Quelle_Dokument
CREATE TABLE afu_geotope.geotope_quelle_dokument (
  T_Id bigint PRIMARY KEY DEFAULT nextval('afu_geotope.t_ili2db_seq')
  ,quelle bigint NOT NULL
  ,dokument bigint NOT NULL
)
;
CREATE INDEX geotope_quelle_dokument_quelle_idx ON afu_geotope.geotope_quelle_dokument ( quelle );
CREATE INDEX geotope_quelle_dokument_dokument_idx ON afu_geotope.geotope_quelle_dokument ( dokument );
-- SO_AFU_Geotope_20200312.Geotope.Quelle_Fachbereich
CREATE TABLE afu_geotope.geotope_quelle_fachbereich (
  T_Id bigint PRIMARY KEY DEFAULT nextval('afu_geotope.t_ili2db_seq')
  ,quelle bigint NOT NULL
  ,fachbereich bigint NOT NULL
)
;
CREATE INDEX geotope_quelle_fachbereich_quelle_idx ON afu_geotope.geotope_quelle_fachbereich ( quelle );
CREATE INDEX geotope_quelle_fachbereich_fachbereich_idx ON afu_geotope.geotope_quelle_fachbereich ( fachbereich );
-- SO_AFU_Geotope_20200312.Geotope.Aufschluss_Dokument
CREATE TABLE afu_geotope.geotope_aufschluss_dokument (
  T_Id bigint PRIMARY KEY DEFAULT nextval('afu_geotope.t_ili2db_seq')
  ,aufschluss bigint NOT NULL
  ,dokument bigint NOT NULL
)
;
CREATE INDEX geotope_aufschluss_dokment_aufschluss_idx ON afu_geotope.geotope_aufschluss_dokument ( aufschluss );
CREATE INDEX geotope_aufschluss_dokment_dokument_idx ON afu_geotope.geotope_aufschluss_dokument ( dokument );
-- SO_AFU_Geotope_20200312.Geotope.Aufschluss_Fachbereich
CREATE TABLE afu_geotope.geotope_aufschluss_fachbereich (
  T_Id bigint PRIMARY KEY DEFAULT nextval('afu_geotope.t_ili2db_seq')
  ,aufschluss bigint NOT NULL
  ,fachbereich bigint NOT NULL
)
;
CREATE INDEX geotope_aufschlss_fchbrich_aufschluss_idx ON afu_geotope.geotope_aufschluss_fachbereich ( aufschluss );
CREATE INDEX geotope_aufschlss_fchbrich_fachbereich_idx ON afu_geotope.geotope_aufschluss_fachbereich ( fachbereich );
COMMENT ON TABLE afu_geotope.geotope_aufschluss_fachbereich IS 'Ein Aufschluss hat im Minimum ein Fachbereich';
-- SO_AFU_Geotope_20200312.Geotope.Fundstelle_Grabung_Dokument
CREATE TABLE afu_geotope.geotope_fundstelle_grabung_dokument (
  T_Id bigint PRIMARY KEY DEFAULT nextval('afu_geotope.t_ili2db_seq')
  ,fundstelle_grabung bigint NOT NULL
  ,dokument bigint NOT NULL
)
;
CREATE INDEX geotp_fndstll_grbng_dkment_fundstelle_grabung_idx ON afu_geotope.geotope_fundstelle_grabung_dokument ( fundstelle_grabung );
CREATE INDEX geotp_fndstll_grbng_dkment_dokument_idx ON afu_geotope.geotope_fundstelle_grabung_dokument ( dokument );
-- SO_AFU_Geotope_20200312.Geotope.Fundstelle_Grabung_Fachbereich
CREATE TABLE afu_geotope.geotope_fundstelle_grabung_fachbereich (
  T_Id bigint PRIMARY KEY DEFAULT nextval('afu_geotope.t_ili2db_seq')
  ,fundstelle_grabung bigint NOT NULL
  ,fachbereich bigint NOT NULL
)
;
CREATE INDEX geotp_fndstllrbng_fchbrich_fundstelle_grabung_idx ON afu_geotope.geotope_fundstelle_grabung_fachbereich ( fundstelle_grabung );
CREATE INDEX geotp_fndstllrbng_fchbrich_fachbereich_idx ON afu_geotope.geotope_fundstelle_grabung_fachbereich ( fachbereich );
COMMENT ON TABLE afu_geotope.geotope_fundstelle_grabung_fachbereich IS 'Eine Fundstelle hat im Minimum ein Fachbereich';
CREATE TABLE afu_geotope.T_ILI2DB_BASKET (
  T_Id bigint PRIMARY KEY
  ,dataset bigint NULL
  ,topic varchar(200) NOT NULL
  ,T_Ili_Tid varchar(200) NULL
  ,attachmentKey varchar(200) NOT NULL
  ,domains varchar(1024) NULL
)
;
CREATE INDEX T_ILI2DB_BASKET_dataset_idx ON afu_geotope.t_ili2db_basket ( dataset );
CREATE TABLE afu_geotope.T_ILI2DB_DATASET (
  T_Id bigint PRIMARY KEY
  ,datasetName varchar(200) NULL
)
;
CREATE TABLE afu_geotope.T_ILI2DB_INHERITANCE (
  thisClass varchar(1024) PRIMARY KEY
  ,baseClass varchar(1024) NULL
)
;
CREATE TABLE afu_geotope.T_ILI2DB_SETTINGS (
  tag varchar(60) PRIMARY KEY
  ,setting varchar(1024) NULL
)
;
CREATE TABLE afu_geotope.T_ILI2DB_TRAFO (
  iliname varchar(1024) NOT NULL
  ,tag varchar(1024) NOT NULL
  ,setting varchar(1024) NOT NULL
)
;
CREATE TABLE afu_geotope.T_ILI2DB_MODEL (
  filename varchar(250) NOT NULL
  ,iliversion varchar(3) NOT NULL
  ,modelName text NOT NULL
  ,content text NOT NULL
  ,importDate timestamp NOT NULL
  ,PRIMARY KEY (modelName,iliversion)
)
;
CREATE TABLE afu_geotope.eiszeit (
  itfCode integer PRIMARY KEY
  ,iliCode varchar(1024) NOT NULL
  ,seq integer NULL
  ,inactive boolean NOT NULL
  ,dispName varchar(250) NOT NULL
  ,description varchar(1024) NULL
)
;
CREATE TABLE afu_geotope.entstehung (
  itfCode integer PRIMARY KEY
  ,iliCode varchar(1024) NOT NULL
  ,seq integer NULL
  ,inactive boolean NOT NULL
  ,dispName varchar(250) NOT NULL
  ,description varchar(1024) NULL
)
;
CREATE TABLE afu_geotope.schutzwuerdigkeit (
  itfCode integer PRIMARY KEY
  ,iliCode varchar(1024) NOT NULL
  ,seq integer NULL
  ,inactive boolean NOT NULL
  ,dispName varchar(250) NOT NULL
  ,description varchar(1024) NULL
)
;
CREATE TABLE afu_geotope.geologische_schicht (
  itfCode integer PRIMARY KEY
  ,iliCode varchar(1024) NOT NULL
  ,seq integer NULL
  ,inactive boolean NOT NULL
  ,dispName varchar(250) NOT NULL
  ,description varchar(1024) NULL
)
;
CREATE TABLE afu_geotope.regionalgeologische_einheit (
  itfCode integer PRIMARY KEY
  ,iliCode varchar(1024) NOT NULL
  ,seq integer NULL
  ,inactive boolean NOT NULL
  ,dispName varchar(250) NOT NULL
  ,description varchar(1024) NULL
)
;
CREATE TABLE afu_geotope.geowissenschaftlicher_wert (
  itfCode integer PRIMARY KEY
  ,iliCode varchar(1024) NOT NULL
  ,seq integer NULL
  ,inactive boolean NOT NULL
  ,dispName varchar(250) NOT NULL
  ,description varchar(1024) NULL
)
;
CREATE TABLE afu_geotope.gesteinsart (
  itfCode integer PRIMARY KEY
  ,iliCode varchar(1024) NOT NULL
  ,seq integer NULL
  ,inactive boolean NOT NULL
  ,dispName varchar(250) NOT NULL
  ,description varchar(1024) NULL
)
;
CREATE TABLE afu_geotope.landschaftstyp (
  itfCode integer PRIMARY KEY
  ,iliCode varchar(1024) NOT NULL
  ,seq integer NULL
  ,inactive boolean NOT NULL
  ,dispName varchar(250) NOT NULL
  ,description varchar(1024) NULL
)
;
CREATE TABLE afu_geotope.geologisches_system (
  itfCode integer PRIMARY KEY
  ,iliCode varchar(1024) NOT NULL
  ,seq integer NULL
  ,inactive boolean NOT NULL
  ,dispName varchar(250) NOT NULL
  ,description varchar(1024) NULL
)
;
CREATE TABLE afu_geotope.petrografie (
  itfCode integer PRIMARY KEY
  ,iliCode varchar(1024) NOT NULL
  ,seq integer NULL
  ,inactive boolean NOT NULL
  ,dispName varchar(250) NOT NULL
  ,description varchar(1024) NULL
)
;
CREATE TABLE afu_geotope.oberflaechenform_aufschluss (
  itfCode integer PRIMARY KEY
  ,iliCode varchar(1024) NOT NULL
  ,seq integer NULL
  ,inactive boolean NOT NULL
  ,dispName varchar(250) NOT NULL
  ,description varchar(1024) NULL
)
;
CREATE TABLE afu_geotope.dokumententyp (
  itfCode integer PRIMARY KEY
  ,iliCode varchar(1024) NOT NULL
  ,seq integer NULL
  ,inactive boolean NOT NULL
  ,dispName varchar(250) NOT NULL
  ,description varchar(1024) NULL
)
;
CREATE TABLE afu_geotope.oberflaechenform_landschaftsform (
  itfCode integer PRIMARY KEY
  ,iliCode varchar(1024) NOT NULL
  ,seq integer NULL
  ,inactive boolean NOT NULL
  ,dispName varchar(250) NOT NULL
  ,description varchar(1024) NULL
)
;
CREATE TABLE afu_geotope.petrografie_erratiker (
  itfCode integer PRIMARY KEY
  ,iliCode varchar(1024) NOT NULL
  ,seq integer NULL
  ,inactive boolean NOT NULL
  ,dispName varchar(250) NOT NULL
  ,description varchar(1024) NULL
)
;
CREATE TABLE afu_geotope.geologische_stufe (
  itfCode integer PRIMARY KEY
  ,iliCode varchar(1024) NOT NULL
  ,seq integer NULL
  ,inactive boolean NOT NULL
  ,dispName varchar(250) NOT NULL
  ,description varchar(1024) NULL
)
;
CREATE TABLE afu_geotope.geologische_serie (
  itfCode integer PRIMARY KEY
  ,iliCode varchar(1024) NOT NULL
  ,seq integer NULL
  ,inactive boolean NOT NULL
  ,dispName varchar(250) NOT NULL
  ,description varchar(1024) NULL
)
;
CREATE TABLE afu_geotope.zustand (
  itfCode integer PRIMARY KEY
  ,iliCode varchar(1024) NOT NULL
  ,seq integer NULL
  ,inactive boolean NOT NULL
  ,dispName varchar(250) NOT NULL
  ,description varchar(1024) NULL
)
;
CREATE TABLE afu_geotope.anthropogene_gefaehrdung (
  itfCode integer PRIMARY KEY
  ,iliCode varchar(1024) NOT NULL
  ,seq integer NULL
  ,inactive boolean NOT NULL
  ,dispName varchar(250) NOT NULL
  ,description varchar(1024) NULL
)
;
CREATE TABLE afu_geotope.bedeutung (
  itfCode integer PRIMARY KEY
  ,iliCode varchar(1024) NOT NULL
  ,seq integer NULL
  ,inactive boolean NOT NULL
  ,dispName varchar(250) NOT NULL
  ,description varchar(1024) NULL
)
;
CREATE TABLE afu_geotope.rechtsstatus (
  itfCode integer PRIMARY KEY
  ,iliCode varchar(1024) NOT NULL
  ,seq integer NULL
  ,inactive boolean NOT NULL
  ,dispName varchar(250) NOT NULL
  ,description varchar(1024) NULL
)
;
CREATE TABLE afu_geotope.T_ILI2DB_CLASSNAME (
  IliName varchar(1024) PRIMARY KEY
  ,SqlName varchar(1024) NOT NULL
)
;
CREATE TABLE afu_geotope.T_ILI2DB_ATTRNAME (
  IliName varchar(1024) NOT NULL
  ,SqlName varchar(1024) NOT NULL
  ,ColOwner varchar(1024) NOT NULL
  ,Target varchar(1024) NULL
  ,PRIMARY KEY (SqlName,ColOwner)
)
;
CREATE TABLE afu_geotope.T_ILI2DB_COLUMN_PROP (
  tablename varchar(255) NOT NULL
  ,subtype varchar(255) NULL
  ,columnname varchar(255) NOT NULL
  ,tag varchar(1024) NOT NULL
  ,setting varchar(1024) NOT NULL
)
;
CREATE TABLE afu_geotope.T_ILI2DB_TABLE_PROP (
  tablename varchar(255) NOT NULL
  ,tag varchar(1024) NOT NULL
  ,setting varchar(1024) NOT NULL
)
;
CREATE TABLE afu_geotope.T_ILI2DB_META_ATTRS (
  ilielement varchar(255) NOT NULL
  ,attr_name varchar(1024) NOT NULL
  ,attr_value varchar(1024) NOT NULL
)
;
ALTER TABLE afu_geotope.surfacestructure ADD CONSTRAINT surfacestructure_multisurface_surfaces_fkey FOREIGN KEY ( multisurface_surfaces ) REFERENCES afu_geotope.multisurface DEFERRABLE INITIALLY DEFERRED;
ALTER TABLE afu_geotope.lithostratigrphie_geologische_schicht ADD CONSTRAINT lithstrtgrph_glgsch_schcht_geologische_stufe_fkey FOREIGN KEY ( geologische_stufe ) REFERENCES afu_geotope.lithostratigrphie_geologische_stufe DEFERRABLE INITIALLY DEFERRED;
ALTER TABLE afu_geotope.lithostratigrphie_geologische_serie ADD CONSTRAINT lithostratgrph_glgsch_srie_geologisches_system_fkey FOREIGN KEY ( geologisches_system ) REFERENCES afu_geotope.lithostratigrphie_geologisches_system DEFERRABLE INITIALLY DEFERRED;
ALTER TABLE afu_geotope.lithostratigrphie_geologische_stufe ADD CONSTRAINT lithostrtgrph_glgsch_stufe_geologische_serie_fkey FOREIGN KEY ( geologische_serie ) REFERENCES afu_geotope.lithostratigrphie_geologische_serie DEFERRABLE INITIALLY DEFERRED;
ALTER TABLE afu_geotope.geotope_erratiker ADD CONSTRAINT geotope_erratiker_zustaendige_stelle_fkey FOREIGN KEY ( zustaendige_stelle ) REFERENCES afu_geotope.geotope_zustaendige_stelle DEFERRABLE INITIALLY DEFERRED;
ALTER TABLE afu_geotope.geotope_hoehle ADD CONSTRAINT geotope_hoehle_zustaendige_stelle_fkey FOREIGN KEY ( zustaendige_stelle ) REFERENCES afu_geotope.geotope_zustaendige_stelle DEFERRABLE INITIALLY DEFERRED;
ALTER TABLE afu_geotope.geotope_landschaftsform ADD CONSTRAINT geotope_landschaftsform_zustaendige_stelle_fkey FOREIGN KEY ( zustaendige_stelle ) REFERENCES afu_geotope.geotope_zustaendige_stelle DEFERRABLE INITIALLY DEFERRED;
ALTER TABLE afu_geotope.geotope_quelle ADD CONSTRAINT geotope_quelle_zustaendige_stelle_fkey FOREIGN KEY ( zustaendige_stelle ) REFERENCES afu_geotope.geotope_zustaendige_stelle DEFERRABLE INITIALLY DEFERRED;
ALTER TABLE afu_geotope.geotope_aufschluss ADD CONSTRAINT geotope_aufschluss_geologische_schicht_bis_fkey FOREIGN KEY ( geologische_schicht_bis ) REFERENCES afu_geotope.lithostratigrphie_geologische_schicht DEFERRABLE INITIALLY DEFERRED;
ALTER TABLE afu_geotope.geotope_aufschluss ADD CONSTRAINT geotope_aufschluss_geologische_schicht_von_fkey FOREIGN KEY ( geologische_schicht_von ) REFERENCES afu_geotope.lithostratigrphie_geologische_schicht DEFERRABLE INITIALLY DEFERRED;
ALTER TABLE afu_geotope.geotope_aufschluss ADD CONSTRAINT geotope_aufschluss_geologische_serie_bis_fkey FOREIGN KEY ( geologische_serie_bis ) REFERENCES afu_geotope.lithostratigrphie_geologische_serie DEFERRABLE INITIALLY DEFERRED;
ALTER TABLE afu_geotope.geotope_aufschluss ADD CONSTRAINT geotope_aufschluss_geologische_serie_von_fkey FOREIGN KEY ( geologische_serie_von ) REFERENCES afu_geotope.lithostratigrphie_geologische_serie DEFERRABLE INITIALLY DEFERRED;
ALTER TABLE afu_geotope.geotope_aufschluss ADD CONSTRAINT geotope_aufschluss_geologische_stufe_bis_fkey FOREIGN KEY ( geologische_stufe_bis ) REFERENCES afu_geotope.lithostratigrphie_geologische_stufe DEFERRABLE INITIALLY DEFERRED;
ALTER TABLE afu_geotope.geotope_aufschluss ADD CONSTRAINT geotope_aufschluss_geologische_stufe_von_fkey FOREIGN KEY ( geologische_stufe_von ) REFERENCES afu_geotope.lithostratigrphie_geologische_stufe DEFERRABLE INITIALLY DEFERRED;
ALTER TABLE afu_geotope.geotope_aufschluss ADD CONSTRAINT geotope_aufschluss_geologisches_system_bis_fkey FOREIGN KEY ( geologisches_system_bis ) REFERENCES afu_geotope.lithostratigrphie_geologisches_system DEFERRABLE INITIALLY DEFERRED;
ALTER TABLE afu_geotope.geotope_aufschluss ADD CONSTRAINT geotope_aufschluss_geologisches_system_von_fkey FOREIGN KEY ( geologisches_system_von ) REFERENCES afu_geotope.lithostratigrphie_geologisches_system DEFERRABLE INITIALLY DEFERRED;
ALTER TABLE afu_geotope.geotope_aufschluss ADD CONSTRAINT geotope_aufschluss_zustaendige_stelle_fkey FOREIGN KEY ( zustaendige_stelle ) REFERENCES afu_geotope.geotope_zustaendige_stelle DEFERRABLE INITIALLY DEFERRED;
ALTER TABLE afu_geotope.geotope_fundstelle_grabung ADD CONSTRAINT geotope_fundstelle_grabung_geologische_schicht_bis_fkey FOREIGN KEY ( geologische_schicht_bis ) REFERENCES afu_geotope.lithostratigrphie_geologische_schicht DEFERRABLE INITIALLY DEFERRED;
ALTER TABLE afu_geotope.geotope_fundstelle_grabung ADD CONSTRAINT geotope_fundstelle_grabung_geologische_schicht_von_fkey FOREIGN KEY ( geologische_schicht_von ) REFERENCES afu_geotope.lithostratigrphie_geologische_schicht DEFERRABLE INITIALLY DEFERRED;
ALTER TABLE afu_geotope.geotope_fundstelle_grabung ADD CONSTRAINT geotope_fundstelle_grabung_geologische_serie_bis_fkey FOREIGN KEY ( geologische_serie_bis ) REFERENCES afu_geotope.lithostratigrphie_geologische_serie DEFERRABLE INITIALLY DEFERRED;
ALTER TABLE afu_geotope.geotope_fundstelle_grabung ADD CONSTRAINT geotope_fundstelle_grabung_geologische_serie_von_fkey FOREIGN KEY ( geologische_serie_von ) REFERENCES afu_geotope.lithostratigrphie_geologische_serie DEFERRABLE INITIALLY DEFERRED;
ALTER TABLE afu_geotope.geotope_fundstelle_grabung ADD CONSTRAINT geotope_fundstelle_grabung_geologische_stufe_bis_fkey FOREIGN KEY ( geologische_stufe_bis ) REFERENCES afu_geotope.lithostratigrphie_geologische_stufe DEFERRABLE INITIALLY DEFERRED;
ALTER TABLE afu_geotope.geotope_fundstelle_grabung ADD CONSTRAINT geotope_fundstelle_grabung_geologische_stufe_von_fkey FOREIGN KEY ( geologische_stufe_von ) REFERENCES afu_geotope.lithostratigrphie_geologische_stufe DEFERRABLE INITIALLY DEFERRED;
ALTER TABLE afu_geotope.geotope_fundstelle_grabung ADD CONSTRAINT geotope_fundstelle_grabung_geologisches_system_bis_fkey FOREIGN KEY ( geologisches_system_bis ) REFERENCES afu_geotope.lithostratigrphie_geologisches_system DEFERRABLE INITIALLY DEFERRED;
ALTER TABLE afu_geotope.geotope_fundstelle_grabung ADD CONSTRAINT geotope_fundstelle_grabung_geologisches_system_von_fkey FOREIGN KEY ( geologisches_system_von ) REFERENCES afu_geotope.lithostratigrphie_geologisches_system DEFERRABLE INITIALLY DEFERRED;
ALTER TABLE afu_geotope.geotope_fundstelle_grabung ADD CONSTRAINT geotope_fundstelle_grabung_zustaendige_stelle_fkey FOREIGN KEY ( zustaendige_stelle ) REFERENCES afu_geotope.geotope_zustaendige_stelle DEFERRABLE INITIALLY DEFERRED;
ALTER TABLE afu_geotope.geotope_erratiker_dokument ADD CONSTRAINT geotope_erratiker_dokument_dokument_fkey FOREIGN KEY ( dokument ) REFERENCES afu_geotope.geotope_dokument DEFERRABLE INITIALLY DEFERRED;
ALTER TABLE afu_geotope.geotope_erratiker_dokument ADD CONSTRAINT geotope_erratiker_dokument_erratiker_fkey FOREIGN KEY ( erratiker ) REFERENCES afu_geotope.geotope_erratiker DEFERRABLE INITIALLY DEFERRED;
ALTER TABLE afu_geotope.geotope_erratiker_fachbereich ADD CONSTRAINT geotope_erratiker_fchbrich_erratiker_fkey FOREIGN KEY ( erratiker ) REFERENCES afu_geotope.geotope_erratiker DEFERRABLE INITIALLY DEFERRED;
ALTER TABLE afu_geotope.geotope_erratiker_fachbereich ADD CONSTRAINT geotope_erratiker_fchbrich_fachbereich_fkey FOREIGN KEY ( fachbereich ) REFERENCES afu_geotope.geotope_fachbereich DEFERRABLE INITIALLY DEFERRED;
ALTER TABLE afu_geotope.geotope_hoehle_dokument ADD CONSTRAINT geotope_hoehle_dokument_hoehle_fkey FOREIGN KEY ( hoehle ) REFERENCES afu_geotope.geotope_hoehle DEFERRABLE INITIALLY DEFERRED;
ALTER TABLE afu_geotope.geotope_hoehle_dokument ADD CONSTRAINT geotope_hoehle_dokument_dokument_fkey FOREIGN KEY ( dokument ) REFERENCES afu_geotope.geotope_dokument DEFERRABLE INITIALLY DEFERRED;
ALTER TABLE afu_geotope.geotope_hoehle_fachbereich ADD CONSTRAINT geotope_hoehle_fachbereich_hoehle_fkey FOREIGN KEY ( hoehle ) REFERENCES afu_geotope.geotope_hoehle DEFERRABLE INITIALLY DEFERRED;
ALTER TABLE afu_geotope.geotope_hoehle_fachbereich ADD CONSTRAINT geotope_hoehle_fachbereich_fachbereich_fkey FOREIGN KEY ( fachbereich ) REFERENCES afu_geotope.geotope_fachbereich DEFERRABLE INITIALLY DEFERRED;
ALTER TABLE afu_geotope.geotope_landform_dokument ADD CONSTRAINT geotope_landform_dokument_landform_fkey FOREIGN KEY ( landform ) REFERENCES afu_geotope.geotope_landschaftsform DEFERRABLE INITIALLY DEFERRED;
ALTER TABLE afu_geotope.geotope_landform_dokument ADD CONSTRAINT geotope_landform_dokument_dokument_fkey FOREIGN KEY ( dokument ) REFERENCES afu_geotope.geotope_dokument DEFERRABLE INITIALLY DEFERRED;
ALTER TABLE afu_geotope.geotope_landform_fachbereich ADD CONSTRAINT geotope_landform_fachbrich_landform_fkey FOREIGN KEY ( landform ) REFERENCES afu_geotope.geotope_landschaftsform DEFERRABLE INITIALLY DEFERRED;
ALTER TABLE afu_geotope.geotope_landform_fachbereich ADD CONSTRAINT geotope_landform_fachbrich_fachbereich_fkey FOREIGN KEY ( fachbereich ) REFERENCES afu_geotope.geotope_fachbereich DEFERRABLE INITIALLY DEFERRED;
ALTER TABLE afu_geotope.geotope_quelle_dokument ADD CONSTRAINT geotope_quelle_dokument_quelle_fkey FOREIGN KEY ( quelle ) REFERENCES afu_geotope.geotope_quelle DEFERRABLE INITIALLY DEFERRED;
ALTER TABLE afu_geotope.geotope_quelle_dokument ADD CONSTRAINT geotope_quelle_dokument_dokument_fkey FOREIGN KEY ( dokument ) REFERENCES afu_geotope.geotope_dokument DEFERRABLE INITIALLY DEFERRED;
ALTER TABLE afu_geotope.geotope_quelle_fachbereich ADD CONSTRAINT geotope_quelle_fachbereich_quelle_fkey FOREIGN KEY ( quelle ) REFERENCES afu_geotope.geotope_quelle DEFERRABLE INITIALLY DEFERRED;
ALTER TABLE afu_geotope.geotope_quelle_fachbereich ADD CONSTRAINT geotope_quelle_fachbereich_fachbereich_fkey FOREIGN KEY ( fachbereich ) REFERENCES afu_geotope.geotope_fachbereich DEFERRABLE INITIALLY DEFERRED;
ALTER TABLE afu_geotope.geotope_aufschluss_dokument ADD CONSTRAINT geotope_aufschluss_dokment_aufschluss_fkey FOREIGN KEY ( aufschluss ) REFERENCES afu_geotope.geotope_aufschluss DEFERRABLE INITIALLY DEFERRED;
ALTER TABLE afu_geotope.geotope_aufschluss_dokument ADD CONSTRAINT geotope_aufschluss_dokment_dokument_fkey FOREIGN KEY ( dokument ) REFERENCES afu_geotope.geotope_dokument DEFERRABLE INITIALLY DEFERRED;
ALTER TABLE afu_geotope.geotope_aufschluss_fachbereich ADD CONSTRAINT geotope_aufschlss_fchbrich_aufschluss_fkey FOREIGN KEY ( aufschluss ) REFERENCES afu_geotope.geotope_aufschluss DEFERRABLE INITIALLY DEFERRED;
ALTER TABLE afu_geotope.geotope_aufschluss_fachbereich ADD CONSTRAINT geotope_aufschlss_fchbrich_fachbereich_fkey FOREIGN KEY ( fachbereich ) REFERENCES afu_geotope.geotope_fachbereich DEFERRABLE INITIALLY DEFERRED;
ALTER TABLE afu_geotope.geotope_fundstelle_grabung_dokument ADD CONSTRAINT geotp_fndstll_grbng_dkment_fundstelle_grabung_fkey FOREIGN KEY ( fundstelle_grabung ) REFERENCES afu_geotope.geotope_fundstelle_grabung DEFERRABLE INITIALLY DEFERRED;
ALTER TABLE afu_geotope.geotope_fundstelle_grabung_dokument ADD CONSTRAINT geotp_fndstll_grbng_dkment_dokument_fkey FOREIGN KEY ( dokument ) REFERENCES afu_geotope.geotope_dokument DEFERRABLE INITIALLY DEFERRED;
ALTER TABLE afu_geotope.geotope_fundstelle_grabung_fachbereich ADD CONSTRAINT geotp_fndstllrbng_fchbrich_fundstelle_grabung_fkey FOREIGN KEY ( fundstelle_grabung ) REFERENCES afu_geotope.geotope_fundstelle_grabung DEFERRABLE INITIALLY DEFERRED;
ALTER TABLE afu_geotope.geotope_fundstelle_grabung_fachbereich ADD CONSTRAINT geotp_fndstllrbng_fchbrich_fachbereich_fkey FOREIGN KEY ( fachbereich ) REFERENCES afu_geotope.geotope_fachbereich DEFERRABLE INITIALLY DEFERRED;
ALTER TABLE afu_geotope.T_ILI2DB_BASKET ADD CONSTRAINT T_ILI2DB_BASKET_dataset_fkey FOREIGN KEY ( dataset ) REFERENCES afu_geotope.T_ILI2DB_DATASET DEFERRABLE INITIALLY DEFERRED;
CREATE UNIQUE INDEX T_ILI2DB_DATASET_datasetName_key ON afu_geotope.T_ILI2DB_DATASET (datasetName)
;
CREATE UNIQUE INDEX T_ILI2DB_MODEL_modelName_iliversion_key ON afu_geotope.T_ILI2DB_MODEL (modelName,iliversion)
;
CREATE UNIQUE INDEX T_ILI2DB_ATTRNAME_SqlName_ColOwner_key ON afu_geotope.T_ILI2DB_ATTRNAME (SqlName,ColOwner)
;
INSERT INTO afu_geotope.T_ILI2DB_CLASSNAME (IliName,SqlName) VALUES ('SO_AFU_Geotope_20200312.Geotope.geologische_Stufe_bis_Geotop_plus','geotope_geologische_stufe_bis_geotop_plus');
INSERT INTO afu_geotope.T_ILI2DB_CLASSNAME (IliName,SqlName) VALUES ('SO_AFU_Geotope_20200312.Geotope.Fundstelle_Grabung_Fachbereich','geotope_fundstelle_grabung_fachbereich');
INSERT INTO afu_geotope.T_ILI2DB_CLASSNAME (IliName,SqlName) VALUES ('SO_AFU_Geotope_20200312.Geotope.Geotop_plus','geotope_geotop_plus');
INSERT INTO afu_geotope.T_ILI2DB_CLASSNAME (IliName,SqlName) VALUES ('SO_AFU_Geotope_20200312.Lithostratigraphie.geologische_Serie_geologische_Stufe','lithostratigrphie_geologische_serie_geologische_stufe');
INSERT INTO afu_geotope.T_ILI2DB_CLASSNAME (IliName,SqlName) VALUES ('SO_AFU_Geotope_20200312.Eiszeit','eiszeit');
INSERT INTO afu_geotope.T_ILI2DB_CLASSNAME (IliName,SqlName) VALUES ('SO_AFU_Geotope_20200312.Bedeutung','bedeutung');
INSERT INTO afu_geotope.T_ILI2DB_CLASSNAME (IliName,SqlName) VALUES ('SO_AFU_Geotope_20200312.Regionalgeologische_Einheit','regionalgeologische_einheit');
INSERT INTO afu_geotope.T_ILI2DB_CLASSNAME (IliName,SqlName) VALUES ('SO_AFU_Geotope_20200312.Geotope.Geotop','geotope_geotop');
INSERT INTO afu_geotope.T_ILI2DB_CLASSNAME (IliName,SqlName) VALUES ('SO_AFU_Geotope_20200312.Lithostratigraphie.geologische_Stufe_geologische_Schicht','lithostratigrphie_geologische_stufe_geologische_schicht');
INSERT INTO afu_geotope.T_ILI2DB_CLASSNAME (IliName,SqlName) VALUES ('SO_AFU_Geotope_20200312.Geotope.Fundstelle_Grabung_Dokument','geotope_fundstelle_grabung_dokument');
INSERT INTO afu_geotope.T_ILI2DB_CLASSNAME (IliName,SqlName) VALUES ('SO_AFU_Geotope_20200312.Geotope.Erratiker','geotope_erratiker');
INSERT INTO afu_geotope.T_ILI2DB_CLASSNAME (IliName,SqlName) VALUES ('SO_AFU_Geotope_20200312.Lithostratigraphie.geologisches_System_geologische_Serie','lithostratigrphie_geologisches_system_geologische_serie');
INSERT INTO afu_geotope.T_ILI2DB_CLASSNAME (IliName,SqlName) VALUES ('SO_AFU_Geotope_20200312.Geotope.geologische_Serie_bis_Geotop_plus','geotope_geologische_serie_bis_geotop_plus');
INSERT INTO afu_geotope.T_ILI2DB_CLASSNAME (IliName,SqlName) VALUES ('SO_AFU_Geotope_20200312.Geotope.Landschaftsform','geotope_landschaftsform');
INSERT INTO afu_geotope.T_ILI2DB_CLASSNAME (IliName,SqlName) VALUES ('SO_AFU_Geotope_20200312.Geotope.Aufschluss','geotope_aufschluss');
INSERT INTO afu_geotope.T_ILI2DB_CLASSNAME (IliName,SqlName) VALUES ('SO_AFU_Geotope_20200312.geologische_Serie','geologische_serie');
INSERT INTO afu_geotope.T_ILI2DB_CLASSNAME (IliName,SqlName) VALUES ('SO_AFU_Geotope_20200312.Dokumententyp','dokumententyp');
INSERT INTO afu_geotope.T_ILI2DB_CLASSNAME (IliName,SqlName) VALUES ('SO_AFU_Geotope_20200312.Geotope.Landform_Dokument','geotope_landform_dokument');
INSERT INTO afu_geotope.T_ILI2DB_CLASSNAME (IliName,SqlName) VALUES ('SO_AFU_Geotope_20200312.Geotope.Hoehle_Dokument','geotope_hoehle_dokument');
INSERT INTO afu_geotope.T_ILI2DB_CLASSNAME (IliName,SqlName) VALUES ('SO_AFU_Geotope_20200312.Geotope.Landform_Fachbereich','geotope_landform_fachbereich');
INSERT INTO afu_geotope.T_ILI2DB_CLASSNAME (IliName,SqlName) VALUES ('SO_AFU_Geotope_20200312.Zustand','zustand');
INSERT INTO afu_geotope.T_ILI2DB_CLASSNAME (IliName,SqlName) VALUES ('SO_AFU_Geotope_20200312.Geotope.Quelle','geotope_quelle');
INSERT INTO afu_geotope.T_ILI2DB_CLASSNAME (IliName,SqlName) VALUES ('SO_AFU_Geotope_20200312.Lithostratigraphie.geologische_Stufe','lithostratigrphie_geologische_stufe');
INSERT INTO afu_geotope.T_ILI2DB_CLASSNAME (IliName,SqlName) VALUES ('SO_AFU_Geotope_20200312.Entstehung','entstehung');
INSERT INTO afu_geotope.T_ILI2DB_CLASSNAME (IliName,SqlName) VALUES ('SO_AFU_Geotope_20200312.Oberflaechenform_Landschaftsform','oberflaechenform_landschaftsform');
INSERT INTO afu_geotope.T_ILI2DB_CLASSNAME (IliName,SqlName) VALUES ('SO_AFU_Geotope_20200312.Geotope.Aufschluss_Fachbereich','geotope_aufschluss_fachbereich');
INSERT INTO afu_geotope.T_ILI2DB_CLASSNAME (IliName,SqlName) VALUES ('SO_AFU_Geotope_20200312.Geotope.geologische_Schicht_von_Geotop_plus','geotope_geologische_schicht_von_geotop_plus');
INSERT INTO afu_geotope.T_ILI2DB_CLASSNAME (IliName,SqlName) VALUES ('SO_AFU_Geotope_20200312.Geotope.Quelle_Fachbereich','geotope_quelle_fachbereich');
INSERT INTO afu_geotope.T_ILI2DB_CLASSNAME (IliName,SqlName) VALUES ('SO_AFU_Geotope_20200312.Geotope.Erratiker_Dokument','geotope_erratiker_dokument');
INSERT INTO afu_geotope.T_ILI2DB_CLASSNAME (IliName,SqlName) VALUES ('SO_AFU_Geotope_20200312.Lithostratigraphie.geologische_Serie','lithostratigrphie_geologische_serie');
INSERT INTO afu_geotope.T_ILI2DB_CLASSNAME (IliName,SqlName) VALUES ('SO_AFU_Geotope_20200312.Geotope.geologische_Serie_von_Geotop_plus','geotope_geologische_serie_von_geotop_plus');
INSERT INTO afu_geotope.T_ILI2DB_CLASSNAME (IliName,SqlName) VALUES ('SO_AFU_Geotope_20200312.Oberflaechenform_Aufschluss','oberflaechenform_aufschluss');
INSERT INTO afu_geotope.T_ILI2DB_CLASSNAME (IliName,SqlName) VALUES ('SO_AFU_Geotope_20200312.geologische_Schicht','geologische_schicht');
INSERT INTO afu_geotope.T_ILI2DB_CLASSNAME (IliName,SqlName) VALUES ('SO_AFU_Geotope_20200312.Schutzwuerdigkeit','schutzwuerdigkeit');
INSERT INTO afu_geotope.T_ILI2DB_CLASSNAME (IliName,SqlName) VALUES ('SO_AFU_Geotope_20200312.Gesteinsart','gesteinsart');
INSERT INTO afu_geotope.T_ILI2DB_CLASSNAME (IliName,SqlName) VALUES ('SO_AFU_Geotope_20200312.Rechtsstatus','rechtsstatus');
INSERT INTO afu_geotope.T_ILI2DB_CLASSNAME (IliName,SqlName) VALUES ('SO_AFU_Geotope_20200312.Geotope.Hoehle','geotope_hoehle');
INSERT INTO afu_geotope.T_ILI2DB_CLASSNAME (IliName,SqlName) VALUES ('SO_AFU_Geotope_20200312.Geotope.geologische_Schicht_bis_Geotop_plus','geotope_geologische_schicht_bis_geotop_plus');
INSERT INTO afu_geotope.T_ILI2DB_CLASSNAME (IliName,SqlName) VALUES ('GeometryCHLV95_V1.SurfaceStructure','surfacestructure');
INSERT INTO afu_geotope.T_ILI2DB_CLASSNAME (IliName,SqlName) VALUES ('SO_AFU_Geotope_20200312.Geotope.Quelle_Dokument','geotope_quelle_dokument');
INSERT INTO afu_geotope.T_ILI2DB_CLASSNAME (IliName,SqlName) VALUES ('SO_AFU_Geotope_20200312.Geotope.Aufschluss_Dokument','geotope_aufschluss_dokument');
INSERT INTO afu_geotope.T_ILI2DB_CLASSNAME (IliName,SqlName) VALUES ('SO_AFU_Geotope_20200312.Anthropogene_Gefaehrdung','anthropogene_gefaehrdung');
INSERT INTO afu_geotope.T_ILI2DB_CLASSNAME (IliName,SqlName) VALUES ('SO_AFU_Geotope_20200312.geologische_Stufe','geologische_stufe');
INSERT INTO afu_geotope.T_ILI2DB_CLASSNAME (IliName,SqlName) VALUES ('SO_AFU_Geotope_20200312.Petrografie_Erratiker','petrografie_erratiker');
INSERT INTO afu_geotope.T_ILI2DB_CLASSNAME (IliName,SqlName) VALUES ('SO_AFU_Geotope_20200312.Geotope.Fundstelle_Grabung','geotope_fundstelle_grabung');
INSERT INTO afu_geotope.T_ILI2DB_CLASSNAME (IliName,SqlName) VALUES ('SO_AFU_Geotope_20200312.Lithostratigraphie.geologisches_System','lithostratigrphie_geologisches_system');
INSERT INTO afu_geotope.T_ILI2DB_CLASSNAME (IliName,SqlName) VALUES ('SO_AFU_Geotope_20200312.Geotope.Fachbereich','geotope_fachbereich');
INSERT INTO afu_geotope.T_ILI2DB_CLASSNAME (IliName,SqlName) VALUES ('SO_AFU_Geotope_20200312.Geotope.geologisches_System_bis_Geotop_plus','geotope_geologisches_system_bis_geotop_plus');
INSERT INTO afu_geotope.T_ILI2DB_CLASSNAME (IliName,SqlName) VALUES ('SO_AFU_Geotope_20200312.Geotope.geologisches_System_von_Geotop_plus','geotope_geologisches_system_von_geotop_plus');
INSERT INTO afu_geotope.T_ILI2DB_CLASSNAME (IliName,SqlName) VALUES ('SO_AFU_Geotope_20200312.Geotope.Hoehle_Fachbereich','geotope_hoehle_fachbereich');
INSERT INTO afu_geotope.T_ILI2DB_CLASSNAME (IliName,SqlName) VALUES ('SO_AFU_Geotope_20200312.geowissenschaftlicher_Wert','geowissenschaftlicher_wert');
INSERT INTO afu_geotope.T_ILI2DB_CLASSNAME (IliName,SqlName) VALUES ('SO_AFU_Geotope_20200312.Geotope.geologische_Stufe_von_Geotop_plus','geotope_geologische_stufe_von_geotop_plus');
INSERT INTO afu_geotope.T_ILI2DB_CLASSNAME (IliName,SqlName) VALUES ('SO_AFU_Geotope_20200312.Petrografie','petrografie');
INSERT INTO afu_geotope.T_ILI2DB_CLASSNAME (IliName,SqlName) VALUES ('SO_AFU_Geotope_20200312.geologisches_System','geologisches_system');
INSERT INTO afu_geotope.T_ILI2DB_CLASSNAME (IliName,SqlName) VALUES ('SO_AFU_Geotope_20200312.Geotope.zustaendige_Stelle','geotope_zustaendige_stelle');
INSERT INTO afu_geotope.T_ILI2DB_CLASSNAME (IliName,SqlName) VALUES ('SO_AFU_Geotope_20200312.Geotope.Dokument','geotope_dokument');
INSERT INTO afu_geotope.T_ILI2DB_CLASSNAME (IliName,SqlName) VALUES ('SO_AFU_Geotope_20200312.Geotope.Erratiker_Fachbereich','geotope_erratiker_fachbereich');
INSERT INTO afu_geotope.T_ILI2DB_CLASSNAME (IliName,SqlName) VALUES ('SO_AFU_Geotope_20200312.Lithostratigraphie.geologische_Schicht','lithostratigrphie_geologische_schicht');
INSERT INTO afu_geotope.T_ILI2DB_CLASSNAME (IliName,SqlName) VALUES ('GeometryCHLV95_V1.MultiSurface','multisurface');
INSERT INTO afu_geotope.T_ILI2DB_CLASSNAME (IliName,SqlName) VALUES ('SO_AFU_Geotope_20200312.Geotope.zustaendige_Stelle_Geotop','geotope_zustaendige_stelle_geotop');
INSERT INTO afu_geotope.T_ILI2DB_CLASSNAME (IliName,SqlName) VALUES ('SO_AFU_Geotope_20200312.Landschaftstyp','landschaftstyp');
INSERT INTO afu_geotope.T_ILI2DB_ATTRNAME (IliName,SqlName,ColOwner,Target) VALUES ('SO_AFU_Geotope_20200312.Geotope.Geotop.Bedeutung','bedeutung','geotope_aufschluss',NULL);
INSERT INTO afu_geotope.T_ILI2DB_ATTRNAME (IliName,SqlName,ColOwner,Target) VALUES ('SO_AFU_Geotope_20200312.Geotope.geologische_Serie_bis_Geotop_plus.geologische_Serie_bis','geologische_serie_bis','geotope_aufschluss','lithostratigrphie_geologische_serie');
INSERT INTO afu_geotope.T_ILI2DB_ATTRNAME (IliName,SqlName,ColOwner,Target) VALUES ('SO_AFU_Geotope_20200312.Geotope.Geotop.Beschreibung','beschreibung','geotope_landschaftsform',NULL);
INSERT INTO afu_geotope.T_ILI2DB_ATTRNAME (IliName,SqlName,ColOwner,Target) VALUES ('GeometryCHLV95_V1.MultiSurface.Surfaces','multisurface_surfaces','surfacestructure','multisurface');
INSERT INTO afu_geotope.T_ILI2DB_ATTRNAME (IliName,SqlName,ColOwner,Target) VALUES ('SO_AFU_Geotope_20200312.Geotope.Landschaftsform.Geometrie','geometrie','geotope_landschaftsform',NULL);
INSERT INTO afu_geotope.T_ILI2DB_ATTRNAME (IliName,SqlName,ColOwner,Target) VALUES ('SO_AFU_Geotope_20200312.Geotope.Hoehle.Geometrie','geometrie','geotope_hoehle',NULL);
INSERT INTO afu_geotope.T_ILI2DB_ATTRNAME (IliName,SqlName,ColOwner,Target) VALUES ('SO_AFU_Geotope_20200312.Lithostratigraphie.geologische_Schicht.Bezeichnung','bezeichnung','lithostratigrphie_geologische_schicht',NULL);
INSERT INTO afu_geotope.T_ILI2DB_ATTRNAME (IliName,SqlName,ColOwner,Target) VALUES ('SO_AFU_Geotope_20200312.Geotope.Aufschluss.Entstehung','entstehung','geotope_aufschluss',NULL);
INSERT INTO afu_geotope.T_ILI2DB_ATTRNAME (IliName,SqlName,ColOwner,Target) VALUES ('SO_AFU_Geotope_20200312.Geotope.Aufschluss.Petrografie','petrografie','geotope_aufschluss',NULL);
INSERT INTO afu_geotope.T_ILI2DB_ATTRNAME (IliName,SqlName,ColOwner,Target) VALUES ('SO_AFU_Geotope_20200312.Geotope.Aufschluss.Geometrie','geometrie','geotope_aufschluss',NULL);
INSERT INTO afu_geotope.T_ILI2DB_ATTRNAME (IliName,SqlName,ColOwner,Target) VALUES ('SO_AFU_Geotope_20200312.Geotope.Geotop.Schutzwuerdigkeit','schutzwuerdigkeit','geotope_quelle',NULL);
INSERT INTO afu_geotope.T_ILI2DB_ATTRNAME (IliName,SqlName,ColOwner,Target) VALUES ('SO_AFU_Geotope_20200312.Geotope.Geotop.Objektname','objektname','geotope_quelle',NULL);
INSERT INTO afu_geotope.T_ILI2DB_ATTRNAME (IliName,SqlName,ColOwner,Target) VALUES ('SO_AFU_Geotope_20200312.Geotope.Geotop.INGESO_OID','ingeso_oid','geotope_landschaftsform',NULL);
INSERT INTO afu_geotope.T_ILI2DB_ATTRNAME (IliName,SqlName,ColOwner,Target) VALUES ('SO_AFU_Geotope_20200312.Geotope.Dokument.Typ','typ','geotope_dokument',NULL);
INSERT INTO afu_geotope.T_ILI2DB_ATTRNAME (IliName,SqlName,ColOwner,Target) VALUES ('SO_AFU_Geotope_20200312.Geotope.Dokument.offizielle_Nr','offizielle_nr','geotope_dokument',NULL);
INSERT INTO afu_geotope.T_ILI2DB_ATTRNAME (IliName,SqlName,ColOwner,Target) VALUES ('SO_AFU_Geotope_20200312.Geotope.geologische_Stufe_bis_Geotop_plus.geologische_Stufe_bis','geologische_stufe_bis','geotope_fundstelle_grabung','lithostratigrphie_geologische_stufe');
INSERT INTO afu_geotope.T_ILI2DB_ATTRNAME (IliName,SqlName,ColOwner,Target) VALUES ('SO_AFU_Geotope_20200312.Geotope.Dokument.publiziert_ab','publiziert_ab','geotope_dokument',NULL);
INSERT INTO afu_geotope.T_ILI2DB_ATTRNAME (IliName,SqlName,ColOwner,Target) VALUES ('SO_AFU_Geotope_20200312.Lithostratigraphie.geologisches_System.Bezeichnung','bezeichnung','lithostratigrphie_geologisches_system',NULL);
INSERT INTO afu_geotope.T_ILI2DB_ATTRNAME (IliName,SqlName,ColOwner,Target) VALUES ('SO_AFU_Geotope_20200312.Geotope.zustaendige_Stelle_Geotop.zustaendige_Stelle','zustaendige_stelle','geotope_hoehle','geotope_zustaendige_stelle');
INSERT INTO afu_geotope.T_ILI2DB_ATTRNAME (IliName,SqlName,ColOwner,Target) VALUES ('SO_AFU_Geotope_20200312.Geotope.Geotop.Oereb_Objekt','oereb_objekt','geotope_landschaftsform',NULL);
INSERT INTO afu_geotope.T_ILI2DB_ATTRNAME (IliName,SqlName,ColOwner,Target) VALUES ('SO_AFU_Geotope_20200312.Geotope.Landschaftsform.Oberflaechenform','oberflaechenform','geotope_landschaftsform',NULL);
INSERT INTO afu_geotope.T_ILI2DB_ATTRNAME (IliName,SqlName,ColOwner,Target) VALUES ('SO_AFU_Geotope_20200312.Geotope.Geotop.Objektname','objektname','geotope_fundstelle_grabung',NULL);
INSERT INTO afu_geotope.T_ILI2DB_ATTRNAME (IliName,SqlName,ColOwner,Target) VALUES ('SO_AFU_Geotope_20200312.Geotope.Geotop.publiziert_ab','publiziert_ab','geotope_aufschluss',NULL);
INSERT INTO afu_geotope.T_ILI2DB_ATTRNAME (IliName,SqlName,ColOwner,Target) VALUES ('SO_AFU_Geotope_20200312.Geotope.Landform_Fachbereich.Fachbereich','fachbereich','geotope_landform_fachbereich','geotope_fachbereich');
INSERT INTO afu_geotope.T_ILI2DB_ATTRNAME (IliName,SqlName,ColOwner,Target) VALUES ('SO_AFU_Geotope_20200312.Geotope.Erratiker.Groesse','groesse','geotope_erratiker',NULL);
INSERT INTO afu_geotope.T_ILI2DB_ATTRNAME (IliName,SqlName,ColOwner,Target) VALUES ('SO_AFU_Geotope_20200312.Geotope.Geotop.Schutzwuerdigkeit','schutzwuerdigkeit','geotope_fundstelle_grabung',NULL);
INSERT INTO afu_geotope.T_ILI2DB_ATTRNAME (IliName,SqlName,ColOwner,Target) VALUES ('SO_AFU_Geotope_20200312.Geotope.Geotop.Objektname','objektname','geotope_landschaftsform',NULL);
INSERT INTO afu_geotope.T_ILI2DB_ATTRNAME (IliName,SqlName,ColOwner,Target) VALUES ('SO_AFU_Geotope_20200312.Geotope.Geotop.kant_geschuetztes_Objekt','kant_geschuetztes_objekt','geotope_aufschluss',NULL);
INSERT INTO afu_geotope.T_ILI2DB_ATTRNAME (IliName,SqlName,ColOwner,Target) VALUES ('SO_AFU_Geotope_20200312.Geotope.Geotop.Hinweis_Literatur','hinweis_literatur','geotope_landschaftsform',NULL);
INSERT INTO afu_geotope.T_ILI2DB_ATTRNAME (IliName,SqlName,ColOwner,Target) VALUES ('SO_AFU_Geotope_20200312.Lithostratigraphie.geologische_Stufe_geologische_Schicht.geologische_Stufe','geologische_stufe','lithostratigrphie_geologische_schicht','lithostratigrphie_geologische_stufe');
INSERT INTO afu_geotope.T_ILI2DB_ATTRNAME (IliName,SqlName,ColOwner,Target) VALUES ('SO_AFU_Geotope_20200312.Geotope.Geotop.alte_Inventar_Nummer','alte_inventar_nummer','geotope_hoehle',NULL);
INSERT INTO afu_geotope.T_ILI2DB_ATTRNAME (IliName,SqlName,ColOwner,Target) VALUES ('SO_AFU_Geotope_20200312.Geotope.Geotop.publiziert_ab','publiziert_ab','geotope_fundstelle_grabung',NULL);
INSERT INTO afu_geotope.T_ILI2DB_ATTRNAME (IliName,SqlName,ColOwner,Target) VALUES ('SO_AFU_Geotope_20200312.Geotope.Geotop.Oereb_Objekt','oereb_objekt','geotope_fundstelle_grabung',NULL);
INSERT INTO afu_geotope.T_ILI2DB_ATTRNAME (IliName,SqlName,ColOwner,Target) VALUES ('SO_AFU_Geotope_20200312.Geotope.Dokument.Rechtsstatus','rechtsstatus','geotope_dokument',NULL);
INSERT INTO afu_geotope.T_ILI2DB_ATTRNAME (IliName,SqlName,ColOwner,Target) VALUES ('SO_AFU_Geotope_20200312.Geotope.Geotop.anthropogene_Gefaehrdung','anthropogene_gefaehrdung','geotope_fundstelle_grabung',NULL);
INSERT INTO afu_geotope.T_ILI2DB_ATTRNAME (IliName,SqlName,ColOwner,Target) VALUES ('SO_AFU_Geotope_20200312.Geotope.Quelle_Dokument.Dokument','dokument','geotope_quelle_dokument','geotope_dokument');
INSERT INTO afu_geotope.T_ILI2DB_ATTRNAME (IliName,SqlName,ColOwner,Target) VALUES ('SO_AFU_Geotope_20200312.Geotope.Geotop.regionalgeologische_Einheit','regionalgeologische_einheit','geotope_fundstelle_grabung',NULL);
INSERT INTO afu_geotope.T_ILI2DB_ATTRNAME (IliName,SqlName,ColOwner,Target) VALUES ('SO_AFU_Geotope_20200312.Geotope.Geotop.geowissenschaftlicher_Wert','geowissenschaftlicher_wert','geotope_quelle',NULL);
INSERT INTO afu_geotope.T_ILI2DB_ATTRNAME (IliName,SqlName,ColOwner,Target) VALUES ('SO_AFU_Geotope_20200312.Geotope.geologische_Stufe_von_Geotop_plus.geologische_Stufe_von','geologische_stufe_von','geotope_fundstelle_grabung','lithostratigrphie_geologische_stufe');
INSERT INTO afu_geotope.T_ILI2DB_ATTRNAME (IliName,SqlName,ColOwner,Target) VALUES ('SO_AFU_Geotope_20200312.Geotope.Erratiker.Aufenthaltsort','aufenthaltsort','geotope_erratiker',NULL);
INSERT INTO afu_geotope.T_ILI2DB_ATTRNAME (IliName,SqlName,ColOwner,Target) VALUES ('SO_AFU_Geotope_20200312.Geotope.Geotop.alte_Inventar_Nummer','alte_inventar_nummer','geotope_landschaftsform',NULL);
INSERT INTO afu_geotope.T_ILI2DB_ATTRNAME (IliName,SqlName,ColOwner,Target) VALUES ('SO_AFU_Geotope_20200312.Geotope.Geotop.regionalgeologische_Einheit','regionalgeologische_einheit','geotope_aufschluss',NULL);
INSERT INTO afu_geotope.T_ILI2DB_ATTRNAME (IliName,SqlName,ColOwner,Target) VALUES ('SO_AFU_Geotope_20200312.Geotope.Geotop.kant_geschuetztes_Objekt','kant_geschuetztes_objekt','geotope_fundstelle_grabung',NULL);
INSERT INTO afu_geotope.T_ILI2DB_ATTRNAME (IliName,SqlName,ColOwner,Target) VALUES ('SO_AFU_Geotope_20200312.Geotope.Geotop.alte_Inventar_Nummer','alte_inventar_nummer','geotope_erratiker',NULL);
INSERT INTO afu_geotope.T_ILI2DB_ATTRNAME (IliName,SqlName,ColOwner,Target) VALUES ('SO_AFU_Geotope_20200312.Geotope.Geotop.Zustand','zustand','geotope_erratiker',NULL);
INSERT INTO afu_geotope.T_ILI2DB_ATTRNAME (IliName,SqlName,ColOwner,Target) VALUES ('SO_AFU_Geotope_20200312.Geotope.Geotop.Schutzwuerdigkeit','schutzwuerdigkeit','geotope_aufschluss',NULL);
INSERT INTO afu_geotope.T_ILI2DB_ATTRNAME (IliName,SqlName,ColOwner,Target) VALUES ('SO_AFU_Geotope_20200312.Geotope.Landform_Fachbereich.Landform','landform','geotope_landform_fachbereich','geotope_landschaftsform');
INSERT INTO afu_geotope.T_ILI2DB_ATTRNAME (IliName,SqlName,ColOwner,Target) VALUES ('SO_AFU_Geotope_20200312.Geotope.Erratiker_Dokument.Erratiker','erratiker','geotope_erratiker_dokument','geotope_erratiker');
INSERT INTO afu_geotope.T_ILI2DB_ATTRNAME (IliName,SqlName,ColOwner,Target) VALUES ('SO_AFU_Geotope_20200312.Geotope.Fundstelle_Grabung.Petrografie','petrografie','geotope_fundstelle_grabung',NULL);
INSERT INTO afu_geotope.T_ILI2DB_ATTRNAME (IliName,SqlName,ColOwner,Target) VALUES ('SO_AFU_Geotope_20200312.Geotope.Fachbereich.Fachbereichsname','fachbereichsname','geotope_fachbereich',NULL);
INSERT INTO afu_geotope.T_ILI2DB_ATTRNAME (IliName,SqlName,ColOwner,Target) VALUES ('SO_AFU_Geotope_20200312.Geotope.Geotop.geowissenschaftlicher_Wert','geowissenschaftlicher_wert','geotope_aufschluss',NULL);
INSERT INTO afu_geotope.T_ILI2DB_ATTRNAME (IliName,SqlName,ColOwner,Target) VALUES ('SO_AFU_Geotope_20200312.Geotope.Geotop.anthropogene_Gefaehrdung','anthropogene_gefaehrdung','geotope_hoehle',NULL);
INSERT INTO afu_geotope.T_ILI2DB_ATTRNAME (IliName,SqlName,ColOwner,Target) VALUES ('SO_AFU_Geotope_20200312.Lithostratigraphie.geologische_Serie.Bezeichnung','bezeichnung','lithostratigrphie_geologische_serie',NULL);
INSERT INTO afu_geotope.T_ILI2DB_ATTRNAME (IliName,SqlName,ColOwner,Target) VALUES ('SO_AFU_Geotope_20200312.Geotope.Erratiker_Fachbereich.Fachbereich','fachbereich','geotope_erratiker_fachbereich','geotope_fachbereich');
INSERT INTO afu_geotope.T_ILI2DB_ATTRNAME (IliName,SqlName,ColOwner,Target) VALUES ('SO_AFU_Geotope_20200312.Geotope.Erratiker.Petrografie','petrografie','geotope_erratiker',NULL);
INSERT INTO afu_geotope.T_ILI2DB_ATTRNAME (IliName,SqlName,ColOwner,Target) VALUES ('SO_AFU_Geotope_20200312.Geotope.Hoehle_Dokument.Hoehle','hoehle','geotope_hoehle_dokument','geotope_hoehle');
INSERT INTO afu_geotope.T_ILI2DB_ATTRNAME (IliName,SqlName,ColOwner,Target) VALUES ('SO_AFU_Geotope_20200312.Geotope.zustaendige_Stelle_Geotop.zustaendige_Stelle','zustaendige_stelle','geotope_fundstelle_grabung','geotope_zustaendige_stelle');
INSERT INTO afu_geotope.T_ILI2DB_ATTRNAME (IliName,SqlName,ColOwner,Target) VALUES ('SO_AFU_Geotope_20200312.Geotope.Quelle_Fachbereich.Fachbereich','fachbereich','geotope_quelle_fachbereich','geotope_fachbereich');
INSERT INTO afu_geotope.T_ILI2DB_ATTRNAME (IliName,SqlName,ColOwner,Target) VALUES ('SO_AFU_Geotope_20200312.Geotope.Geotop.kant_geschuetztes_Objekt','kant_geschuetztes_objekt','geotope_erratiker',NULL);
INSERT INTO afu_geotope.T_ILI2DB_ATTRNAME (IliName,SqlName,ColOwner,Target) VALUES ('SO_AFU_Geotope_20200312.Geotope.Geotop.Hinweis_Literatur','hinweis_literatur','geotope_erratiker',NULL);
INSERT INTO afu_geotope.T_ILI2DB_ATTRNAME (IliName,SqlName,ColOwner,Target) VALUES ('SO_AFU_Geotope_20200312.Geotope.Aufschluss_Fachbereich.Fachbereich','fachbereich','geotope_aufschluss_fachbereich','geotope_fachbereich');
INSERT INTO afu_geotope.T_ILI2DB_ATTRNAME (IliName,SqlName,ColOwner,Target) VALUES ('SO_AFU_Geotope_20200312.Geotope.Geotop.Bedeutung','bedeutung','geotope_quelle',NULL);
INSERT INTO afu_geotope.T_ILI2DB_ATTRNAME (IliName,SqlName,ColOwner,Target) VALUES ('SO_AFU_Geotope_20200312.Geotope.Geotop.anthropogene_Gefaehrdung','anthropogene_gefaehrdung','geotope_erratiker',NULL);
INSERT INTO afu_geotope.T_ILI2DB_ATTRNAME (IliName,SqlName,ColOwner,Target) VALUES ('SO_AFU_Geotope_20200312.Geotope.Geotop.Beschreibung','beschreibung','geotope_erratiker',NULL);
INSERT INTO afu_geotope.T_ILI2DB_ATTRNAME (IliName,SqlName,ColOwner,Target) VALUES ('SO_AFU_Geotope_20200312.Lithostratigraphie.geologische_Serie_geologische_Stufe.geologische_Serie','geologische_serie','lithostratigrphie_geologische_stufe','lithostratigrphie_geologische_serie');
INSERT INTO afu_geotope.T_ILI2DB_ATTRNAME (IliName,SqlName,ColOwner,Target) VALUES ('SO_AFU_Geotope_20200312.Geotope.Geotop.publiziert_ab','publiziert_ab','geotope_quelle',NULL);
INSERT INTO afu_geotope.T_ILI2DB_ATTRNAME (IliName,SqlName,ColOwner,Target) VALUES ('SO_AFU_Geotope_20200312.Geotope.zustaendige_Stelle.Amt_im_Web','amt_im_web','geotope_zustaendige_stelle',NULL);
INSERT INTO afu_geotope.T_ILI2DB_ATTRNAME (IliName,SqlName,ColOwner,Target) VALUES ('SO_AFU_Geotope_20200312.Geotope.zustaendige_Stelle_Geotop.zustaendige_Stelle','zustaendige_stelle','geotope_aufschluss','geotope_zustaendige_stelle');
INSERT INTO afu_geotope.T_ILI2DB_ATTRNAME (IliName,SqlName,ColOwner,Target) VALUES ('SO_AFU_Geotope_20200312.Geotope.geologische_Serie_von_Geotop_plus.geologische_Serie_von','geologische_serie_von','geotope_fundstelle_grabung','lithostratigrphie_geologische_serie');
INSERT INTO afu_geotope.T_ILI2DB_ATTRNAME (IliName,SqlName,ColOwner,Target) VALUES ('SO_AFU_Geotope_20200312.Geotope.geologisches_System_bis_Geotop_plus.geologisches_System_bis','geologisches_system_bis','geotope_fundstelle_grabung','lithostratigrphie_geologisches_system');
INSERT INTO afu_geotope.T_ILI2DB_ATTRNAME (IliName,SqlName,ColOwner,Target) VALUES ('SO_AFU_Geotope_20200312.Lithostratigraphie.geologisches_System_geologische_Serie.geologisches_System','geologisches_system','lithostratigrphie_geologische_serie','lithostratigrphie_geologisches_system');
INSERT INTO afu_geotope.T_ILI2DB_ATTRNAME (IliName,SqlName,ColOwner,Target) VALUES ('SO_AFU_Geotope_20200312.Geotope.Quelle_Dokument.Quelle','quelle','geotope_quelle_dokument','geotope_quelle');
INSERT INTO afu_geotope.T_ILI2DB_ATTRNAME (IliName,SqlName,ColOwner,Target) VALUES ('SO_AFU_Geotope_20200312.Geotope.Geotop.INGESO_OID','ingeso_oid','geotope_fundstelle_grabung',NULL);
INSERT INTO afu_geotope.T_ILI2DB_ATTRNAME (IliName,SqlName,ColOwner,Target) VALUES ('SO_AFU_Geotope_20200312.Geotope.Geotop.Rechtsstatus','rechtsstatus','geotope_hoehle',NULL);
INSERT INTO afu_geotope.T_ILI2DB_ATTRNAME (IliName,SqlName,ColOwner,Target) VALUES ('SO_AFU_Geotope_20200312.Geotope.Geotop.INGESO_OID','ingeso_oid','geotope_aufschluss',NULL);
INSERT INTO afu_geotope.T_ILI2DB_ATTRNAME (IliName,SqlName,ColOwner,Target) VALUES ('SO_AFU_Geotope_20200312.Geotope.Geotop.Rechtsstatus','rechtsstatus','geotope_erratiker',NULL);
INSERT INTO afu_geotope.T_ILI2DB_ATTRNAME (IliName,SqlName,ColOwner,Target) VALUES ('SO_AFU_Geotope_20200312.Geotope.Geotop.Zustand','zustand','geotope_fundstelle_grabung',NULL);
INSERT INTO afu_geotope.T_ILI2DB_ATTRNAME (IliName,SqlName,ColOwner,Target) VALUES ('SO_AFU_Geotope_20200312.Geotope.Geotop.Zustand','zustand','geotope_landschaftsform',NULL);
INSERT INTO afu_geotope.T_ILI2DB_ATTRNAME (IliName,SqlName,ColOwner,Target) VALUES ('SO_AFU_Geotope_20200312.Geotope.Landschaftsform.Landschaftstyp','landschaftstyp','geotope_landschaftsform',NULL);
INSERT INTO afu_geotope.T_ILI2DB_ATTRNAME (IliName,SqlName,ColOwner,Target) VALUES ('SO_AFU_Geotope_20200312.Geotope.Quelle.Geometrie','geometrie','geotope_quelle',NULL);
INSERT INTO afu_geotope.T_ILI2DB_ATTRNAME (IliName,SqlName,ColOwner,Target) VALUES ('SO_AFU_Geotope_20200312.Geotope.geologische_Stufe_von_Geotop_plus.geologische_Stufe_von','geologische_stufe_von','geotope_aufschluss','lithostratigrphie_geologische_stufe');
INSERT INTO afu_geotope.T_ILI2DB_ATTRNAME (IliName,SqlName,ColOwner,Target) VALUES ('SO_AFU_Geotope_20200312.Lithostratigraphie.geologische_Stufe.Bezeichnung','bezeichnung','lithostratigrphie_geologische_stufe',NULL);
INSERT INTO afu_geotope.T_ILI2DB_ATTRNAME (IliName,SqlName,ColOwner,Target) VALUES ('SO_AFU_Geotope_20200312.Geotope.Landform_Dokument.Landform','landform','geotope_landform_dokument','geotope_landschaftsform');
INSERT INTO afu_geotope.T_ILI2DB_ATTRNAME (IliName,SqlName,ColOwner,Target) VALUES ('SO_AFU_Geotope_20200312.Geotope.Hoehle_Dokument.Dokument','dokument','geotope_hoehle_dokument','geotope_dokument');
INSERT INTO afu_geotope.T_ILI2DB_ATTRNAME (IliName,SqlName,ColOwner,Target) VALUES ('SO_AFU_Geotope_20200312.Geotope.Geotop.geowissenschaftlicher_Wert','geowissenschaftlicher_wert','geotope_hoehle',NULL);
INSERT INTO afu_geotope.T_ILI2DB_ATTRNAME (IliName,SqlName,ColOwner,Target) VALUES ('SO_AFU_Geotope_20200312.Geotope.Geotop.regionalgeologische_Einheit','regionalgeologische_einheit','geotope_landschaftsform',NULL);
INSERT INTO afu_geotope.T_ILI2DB_ATTRNAME (IliName,SqlName,ColOwner,Target) VALUES ('SO_AFU_Geotope_20200312.Geotope.Geotop.regionalgeologische_Einheit','regionalgeologische_einheit','geotope_hoehle',NULL);
INSERT INTO afu_geotope.T_ILI2DB_ATTRNAME (IliName,SqlName,ColOwner,Target) VALUES ('SO_AFU_Geotope_20200312.Geotope.Erratiker.Entstehung','entstehung','geotope_erratiker',NULL);
INSERT INTO afu_geotope.T_ILI2DB_ATTRNAME (IliName,SqlName,ColOwner,Target) VALUES ('SO_AFU_Geotope_20200312.Geotope.geologische_Schicht_von_Geotop_plus.geologische_Schicht_von','geologische_schicht_von','geotope_fundstelle_grabung','lithostratigrphie_geologische_schicht');
INSERT INTO afu_geotope.T_ILI2DB_ATTRNAME (IliName,SqlName,ColOwner,Target) VALUES ('SO_AFU_Geotope_20200312.Geotope.Geotop.Rechtsstatus','rechtsstatus','geotope_quelle',NULL);
INSERT INTO afu_geotope.T_ILI2DB_ATTRNAME (IliName,SqlName,ColOwner,Target) VALUES ('SO_AFU_Geotope_20200312.Geotope.Geotop.Lokalname','lokalname','geotope_quelle',NULL);
INSERT INTO afu_geotope.T_ILI2DB_ATTRNAME (IliName,SqlName,ColOwner,Target) VALUES ('SO_AFU_Geotope_20200312.Geotope.Landform_Dokument.Dokument','dokument','geotope_landform_dokument','geotope_dokument');
INSERT INTO afu_geotope.T_ILI2DB_ATTRNAME (IliName,SqlName,ColOwner,Target) VALUES ('SO_AFU_Geotope_20200312.Geotope.Fundstelle_Grabung.Geometrie','geometrie','geotope_fundstelle_grabung',NULL);
INSERT INTO afu_geotope.T_ILI2DB_ATTRNAME (IliName,SqlName,ColOwner,Target) VALUES ('SO_AFU_Geotope_20200312.Geotope.Aufschluss_Fachbereich.Aufschluss','aufschluss','geotope_aufschluss_fachbereich','geotope_aufschluss');
INSERT INTO afu_geotope.T_ILI2DB_ATTRNAME (IliName,SqlName,ColOwner,Target) VALUES ('SO_AFU_Geotope_20200312.Geotope.Geotop.geowissenschaftlicher_Wert','geowissenschaftlicher_wert','geotope_fundstelle_grabung',NULL);
INSERT INTO afu_geotope.T_ILI2DB_ATTRNAME (IliName,SqlName,ColOwner,Target) VALUES ('SO_AFU_Geotope_20200312.Geotope.zustaendige_Stelle_Geotop.zustaendige_Stelle','zustaendige_stelle','geotope_quelle','geotope_zustaendige_stelle');
INSERT INTO afu_geotope.T_ILI2DB_ATTRNAME (IliName,SqlName,ColOwner,Target) VALUES ('SO_AFU_Geotope_20200312.Geotope.Geotop.Beschreibung','beschreibung','geotope_hoehle',NULL);
INSERT INTO afu_geotope.T_ILI2DB_ATTRNAME (IliName,SqlName,ColOwner,Target) VALUES ('SO_AFU_Geotope_20200312.Geotope.geologische_Serie_von_Geotop_plus.geologische_Serie_von','geologische_serie_von','geotope_aufschluss','lithostratigrphie_geologische_serie');
INSERT INTO afu_geotope.T_ILI2DB_ATTRNAME (IliName,SqlName,ColOwner,Target) VALUES ('SO_AFU_Geotope_20200312.Geotope.Geotop.INGESO_OID','ingeso_oid','geotope_quelle',NULL);
INSERT INTO afu_geotope.T_ILI2DB_ATTRNAME (IliName,SqlName,ColOwner,Target) VALUES ('SO_AFU_Geotope_20200312.Geotope.Dokument.Abkuerzung','abkuerzung','geotope_dokument',NULL);
INSERT INTO afu_geotope.T_ILI2DB_ATTRNAME (IliName,SqlName,ColOwner,Target) VALUES ('SO_AFU_Geotope_20200312.Geotope.Fundstelle_Grabung_Fachbereich.Fachbereich','fachbereich','geotope_fundstelle_grabung_fachbereich','geotope_fachbereich');
INSERT INTO afu_geotope.T_ILI2DB_ATTRNAME (IliName,SqlName,ColOwner,Target) VALUES ('SO_AFU_Geotope_20200312.Geotope.Geotop.Hinweis_Literatur','hinweis_literatur','geotope_fundstelle_grabung',NULL);
INSERT INTO afu_geotope.T_ILI2DB_ATTRNAME (IliName,SqlName,ColOwner,Target) VALUES ('SO_AFU_Geotope_20200312.Geotope.Dokument.Titel','titel','geotope_dokument',NULL);
INSERT INTO afu_geotope.T_ILI2DB_ATTRNAME (IliName,SqlName,ColOwner,Target) VALUES ('SO_AFU_Geotope_20200312.Geotope.Erratiker_Dokument.Dokument','dokument','geotope_erratiker_dokument','geotope_dokument');
INSERT INTO afu_geotope.T_ILI2DB_ATTRNAME (IliName,SqlName,ColOwner,Target) VALUES ('SO_AFU_Geotope_20200312.Geotope.Geotop.anthropogene_Gefaehrdung','anthropogene_gefaehrdung','geotope_aufschluss',NULL);
INSERT INTO afu_geotope.T_ILI2DB_ATTRNAME (IliName,SqlName,ColOwner,Target) VALUES ('SO_AFU_Geotope_20200312.Geotope.geologisches_System_bis_Geotop_plus.geologisches_System_bis','geologisches_system_bis','geotope_aufschluss','lithostratigrphie_geologisches_system');
INSERT INTO afu_geotope.T_ILI2DB_ATTRNAME (IliName,SqlName,ColOwner,Target) VALUES ('SO_AFU_Geotope_20200312.Geotope.Erratiker.Geometrie','geometrie','geotope_erratiker',NULL);
INSERT INTO afu_geotope.T_ILI2DB_ATTRNAME (IliName,SqlName,ColOwner,Target) VALUES ('SO_AFU_Geotope_20200312.Geotope.Hoehle_Fachbereich.Hoehle','hoehle','geotope_hoehle_fachbereich','geotope_hoehle');
INSERT INTO afu_geotope.T_ILI2DB_ATTRNAME (IliName,SqlName,ColOwner,Target) VALUES ('SO_AFU_Geotope_20200312.Geotope.Quelle_Fachbereich.Quelle','quelle','geotope_quelle_fachbereich','geotope_quelle');
INSERT INTO afu_geotope.T_ILI2DB_ATTRNAME (IliName,SqlName,ColOwner,Target) VALUES ('SO_AFU_Geotope_20200312.Geotope.Geotop.Schutzwuerdigkeit','schutzwuerdigkeit','geotope_landschaftsform',NULL);
INSERT INTO afu_geotope.T_ILI2DB_ATTRNAME (IliName,SqlName,ColOwner,Target) VALUES ('SO_AFU_Geotope_20200312.Geotope.Landschaftsform.Entstehung','entstehung','geotope_landschaftsform',NULL);
INSERT INTO afu_geotope.T_ILI2DB_ATTRNAME (IliName,SqlName,ColOwner,Target) VALUES ('SO_AFU_Geotope_20200312.Geotope.Geotop.Rechtsstatus','rechtsstatus','geotope_fundstelle_grabung',NULL);
INSERT INTO afu_geotope.T_ILI2DB_ATTRNAME (IliName,SqlName,ColOwner,Target) VALUES ('SO_AFU_Geotope_20200312.Geotope.Geotop.Oereb_Objekt','oereb_objekt','geotope_aufschluss',NULL);
INSERT INTO afu_geotope.T_ILI2DB_ATTRNAME (IliName,SqlName,ColOwner,Target) VALUES ('SO_AFU_Geotope_20200312.Geotope.Geotop.Lokalname','lokalname','geotope_erratiker',NULL);
INSERT INTO afu_geotope.T_ILI2DB_ATTRNAME (IliName,SqlName,ColOwner,Target) VALUES ('SO_AFU_Geotope_20200312.Geotope.geologische_Schicht_bis_Geotop_plus.geologische_Schicht_bis','geologische_schicht_bis','geotope_aufschluss','lithostratigrphie_geologische_schicht');
INSERT INTO afu_geotope.T_ILI2DB_ATTRNAME (IliName,SqlName,ColOwner,Target) VALUES ('SO_AFU_Geotope_20200312.Geotope.Geotop.Beschreibung','beschreibung','geotope_fundstelle_grabung',NULL);
INSERT INTO afu_geotope.T_ILI2DB_ATTRNAME (IliName,SqlName,ColOwner,Target) VALUES ('SO_AFU_Geotope_20200312.Geotope.Geotop.Objektname','objektname','geotope_hoehle',NULL);
INSERT INTO afu_geotope.T_ILI2DB_ATTRNAME (IliName,SqlName,ColOwner,Target) VALUES ('SO_AFU_Geotope_20200312.Geotope.Geotop.Objektname','objektname','geotope_aufschluss',NULL);
INSERT INTO afu_geotope.T_ILI2DB_ATTRNAME (IliName,SqlName,ColOwner,Target) VALUES ('SO_AFU_Geotope_20200312.Geotope.geologische_Stufe_bis_Geotop_plus.geologische_Stufe_bis','geologische_stufe_bis','geotope_aufschluss','lithostratigrphie_geologische_stufe');
INSERT INTO afu_geotope.T_ILI2DB_ATTRNAME (IliName,SqlName,ColOwner,Target) VALUES ('SO_AFU_Geotope_20200312.Geotope.Geotop.Bedeutung','bedeutung','geotope_landschaftsform',NULL);
INSERT INTO afu_geotope.T_ILI2DB_ATTRNAME (IliName,SqlName,ColOwner,Target) VALUES ('SO_AFU_Geotope_20200312.Geotope.Geotop.Lokalname','lokalname','geotope_fundstelle_grabung',NULL);
INSERT INTO afu_geotope.T_ILI2DB_ATTRNAME (IliName,SqlName,ColOwner,Target) VALUES ('SO_AFU_Geotope_20200312.Geotope.Geotop.anthropogene_Gefaehrdung','anthropogene_gefaehrdung','geotope_landschaftsform',NULL);
INSERT INTO afu_geotope.T_ILI2DB_ATTRNAME (IliName,SqlName,ColOwner,Target) VALUES ('SO_AFU_Geotope_20200312.Geotope.Geotop.Bedeutung','bedeutung','geotope_erratiker',NULL);
INSERT INTO afu_geotope.T_ILI2DB_ATTRNAME (IliName,SqlName,ColOwner,Target) VALUES ('SO_AFU_Geotope_20200312.Geotope.Geotop.Zustand','zustand','geotope_hoehle',NULL);
INSERT INTO afu_geotope.T_ILI2DB_ATTRNAME (IliName,SqlName,ColOwner,Target) VALUES ('SO_AFU_Geotope_20200312.Geotope.Geotop.Zustand','zustand','geotope_quelle',NULL);
INSERT INTO afu_geotope.T_ILI2DB_ATTRNAME (IliName,SqlName,ColOwner,Target) VALUES ('SO_AFU_Geotope_20200312.Geotope.Geotop.alte_Inventar_Nummer','alte_inventar_nummer','geotope_aufschluss',NULL);
INSERT INTO afu_geotope.T_ILI2DB_ATTRNAME (IliName,SqlName,ColOwner,Target) VALUES ('SO_AFU_Geotope_20200312.Geotope.geologische_Schicht_bis_Geotop_plus.geologische_Schicht_bis','geologische_schicht_bis','geotope_fundstelle_grabung','lithostratigrphie_geologische_schicht');
INSERT INTO afu_geotope.T_ILI2DB_ATTRNAME (IliName,SqlName,ColOwner,Target) VALUES ('SO_AFU_Geotope_20200312.Geotope.Geotop.Oereb_Objekt','oereb_objekt','geotope_quelle',NULL);
INSERT INTO afu_geotope.T_ILI2DB_ATTRNAME (IliName,SqlName,ColOwner,Target) VALUES ('SO_AFU_Geotope_20200312.Geotope.Geotop.Oereb_Objekt','oereb_objekt','geotope_erratiker',NULL);
INSERT INTO afu_geotope.T_ILI2DB_ATTRNAME (IliName,SqlName,ColOwner,Target) VALUES ('SO_AFU_Geotope_20200312.Geotope.Dokument.offizieller_Titel','offizieller_titel','geotope_dokument',NULL);
INSERT INTO afu_geotope.T_ILI2DB_ATTRNAME (IliName,SqlName,ColOwner,Target) VALUES ('SO_AFU_Geotope_20200312.Geotope.zustaendige_Stelle_Geotop.zustaendige_Stelle','zustaendige_stelle','geotope_landschaftsform','geotope_zustaendige_stelle');
INSERT INTO afu_geotope.T_ILI2DB_ATTRNAME (IliName,SqlName,ColOwner,Target) VALUES ('SO_AFU_Geotope_20200312.Geotope.Geotop.Schutzwuerdigkeit','schutzwuerdigkeit','geotope_hoehle',NULL);
INSERT INTO afu_geotope.T_ILI2DB_ATTRNAME (IliName,SqlName,ColOwner,Target) VALUES ('SO_AFU_Geotope_20200312.Geotope.Fundstelle_Grabung_Fachbereich.Fundstelle_Grabung','fundstelle_grabung','geotope_fundstelle_grabung_fachbereich','geotope_fundstelle_grabung');
INSERT INTO afu_geotope.T_ILI2DB_ATTRNAME (IliName,SqlName,ColOwner,Target) VALUES ('SO_AFU_Geotope_20200312.Geotope.Fundstelle_Grabung.Fundgegenstaende','fundgegenstaende','geotope_fundstelle_grabung',NULL);
INSERT INTO afu_geotope.T_ILI2DB_ATTRNAME (IliName,SqlName,ColOwner,Target) VALUES ('SO_AFU_Geotope_20200312.Geotope.Geotop.INGESO_OID','ingeso_oid','geotope_erratiker',NULL);
INSERT INTO afu_geotope.T_ILI2DB_ATTRNAME (IliName,SqlName,ColOwner,Target) VALUES ('SO_AFU_Geotope_20200312.Geotope.Geotop.Hinweis_Literatur','hinweis_literatur','geotope_quelle',NULL);
INSERT INTO afu_geotope.T_ILI2DB_ATTRNAME (IliName,SqlName,ColOwner,Target) VALUES ('SO_AFU_Geotope_20200312.Geotope.Fundstelle_Grabung_Dokument.Dokument','dokument','geotope_fundstelle_grabung_dokument','geotope_dokument');
INSERT INTO afu_geotope.T_ILI2DB_ATTRNAME (IliName,SqlName,ColOwner,Target) VALUES ('SO_AFU_Geotope_20200312.Geotope.Geotop.publiziert_ab','publiziert_ab','geotope_landschaftsform',NULL);
INSERT INTO afu_geotope.T_ILI2DB_ATTRNAME (IliName,SqlName,ColOwner,Target) VALUES ('SO_AFU_Geotope_20200312.Geotope.Geotop.Schutzwuerdigkeit','schutzwuerdigkeit','geotope_erratiker',NULL);
INSERT INTO afu_geotope.T_ILI2DB_ATTRNAME (IliName,SqlName,ColOwner,Target) VALUES ('SO_AFU_Geotope_20200312.Geotope.Geotop.Oereb_Objekt','oereb_objekt','geotope_hoehle',NULL);
INSERT INTO afu_geotope.T_ILI2DB_ATTRNAME (IliName,SqlName,ColOwner,Target) VALUES ('SO_AFU_Geotope_20200312.Geotope.Geotop.Lokalname','lokalname','geotope_landschaftsform',NULL);
INSERT INTO afu_geotope.T_ILI2DB_ATTRNAME (IliName,SqlName,ColOwner,Target) VALUES ('SO_AFU_Geotope_20200312.Geotope.Dokument.Pfad','pfad','geotope_dokument',NULL);
INSERT INTO afu_geotope.T_ILI2DB_ATTRNAME (IliName,SqlName,ColOwner,Target) VALUES ('SO_AFU_Geotope_20200312.Geotope.Geotop.publiziert_ab','publiziert_ab','geotope_hoehle',NULL);
INSERT INTO afu_geotope.T_ILI2DB_ATTRNAME (IliName,SqlName,ColOwner,Target) VALUES ('SO_AFU_Geotope_20200312.Geotope.Geotop.Objektname','objektname','geotope_erratiker',NULL);
INSERT INTO afu_geotope.T_ILI2DB_ATTRNAME (IliName,SqlName,ColOwner,Target) VALUES ('SO_AFU_Geotope_20200312.Geotope.Geotop.geowissenschaftlicher_Wert','geowissenschaftlicher_wert','geotope_erratiker',NULL);
INSERT INTO afu_geotope.T_ILI2DB_ATTRNAME (IliName,SqlName,ColOwner,Target) VALUES ('SO_AFU_Geotope_20200312.Geotope.geologisches_System_von_Geotop_plus.geologisches_System_von','geologisches_system_von','geotope_aufschluss','lithostratigrphie_geologisches_system');
INSERT INTO afu_geotope.T_ILI2DB_ATTRNAME (IliName,SqlName,ColOwner,Target) VALUES ('SO_AFU_Geotope_20200312.Geotope.Geotop.Lokalname','lokalname','geotope_hoehle',NULL);
INSERT INTO afu_geotope.T_ILI2DB_ATTRNAME (IliName,SqlName,ColOwner,Target) VALUES ('SO_AFU_Geotope_20200312.Geotope.Geotop.INGESO_OID','ingeso_oid','geotope_hoehle',NULL);
INSERT INTO afu_geotope.T_ILI2DB_ATTRNAME (IliName,SqlName,ColOwner,Target) VALUES ('SO_AFU_Geotope_20200312.Geotope.zustaendige_Stelle_Geotop.zustaendige_Stelle','zustaendige_stelle','geotope_erratiker','geotope_zustaendige_stelle');
INSERT INTO afu_geotope.T_ILI2DB_ATTRNAME (IliName,SqlName,ColOwner,Target) VALUES ('SO_AFU_Geotope_20200312.Geotope.Geotop.regionalgeologische_Einheit','regionalgeologische_einheit','geotope_quelle',NULL);
INSERT INTO afu_geotope.T_ILI2DB_ATTRNAME (IliName,SqlName,ColOwner,Target) VALUES ('SO_AFU_Geotope_20200312.Geotope.Geotop.kant_geschuetztes_Objekt','kant_geschuetztes_objekt','geotope_quelle',NULL);
INSERT INTO afu_geotope.T_ILI2DB_ATTRNAME (IliName,SqlName,ColOwner,Target) VALUES ('SO_AFU_Geotope_20200312.Geotope.geologische_Schicht_von_Geotop_plus.geologische_Schicht_von','geologische_schicht_von','geotope_aufschluss','lithostratigrphie_geologische_schicht');
INSERT INTO afu_geotope.T_ILI2DB_ATTRNAME (IliName,SqlName,ColOwner,Target) VALUES ('SO_AFU_Geotope_20200312.Geotope.Geotop.Hinweis_Literatur','hinweis_literatur','geotope_hoehle',NULL);
INSERT INTO afu_geotope.T_ILI2DB_ATTRNAME (IliName,SqlName,ColOwner,Target) VALUES ('SO_AFU_Geotope_20200312.Geotope.Fundstelle_Grabung.Aufenthaltsort','aufenthaltsort','geotope_fundstelle_grabung',NULL);
INSERT INTO afu_geotope.T_ILI2DB_ATTRNAME (IliName,SqlName,ColOwner,Target) VALUES ('SO_AFU_Geotope_20200312.Geotope.geologisches_System_von_Geotop_plus.geologisches_System_von','geologisches_system_von','geotope_fundstelle_grabung','lithostratigrphie_geologisches_system');
INSERT INTO afu_geotope.T_ILI2DB_ATTRNAME (IliName,SqlName,ColOwner,Target) VALUES ('SO_AFU_Geotope_20200312.Geotope.Geotop.publiziert_ab','publiziert_ab','geotope_erratiker',NULL);
INSERT INTO afu_geotope.T_ILI2DB_ATTRNAME (IliName,SqlName,ColOwner,Target) VALUES ('SO_AFU_Geotope_20200312.Geotope.Erratiker.Herkunft','herkunft','geotope_erratiker',NULL);
INSERT INTO afu_geotope.T_ILI2DB_ATTRNAME (IliName,SqlName,ColOwner,Target) VALUES ('SO_AFU_Geotope_20200312.Geotope.Geotop.geowissenschaftlicher_Wert','geowissenschaftlicher_wert','geotope_landschaftsform',NULL);
INSERT INTO afu_geotope.T_ILI2DB_ATTRNAME (IliName,SqlName,ColOwner,Target) VALUES ('SO_AFU_Geotope_20200312.Geotope.Geotop.Rechtsstatus','rechtsstatus','geotope_landschaftsform',NULL);
INSERT INTO afu_geotope.T_ILI2DB_ATTRNAME (IliName,SqlName,ColOwner,Target) VALUES ('SO_AFU_Geotope_20200312.Geotope.Geotop.Beschreibung','beschreibung','geotope_aufschluss',NULL);
INSERT INTO afu_geotope.T_ILI2DB_ATTRNAME (IliName,SqlName,ColOwner,Target) VALUES ('SO_AFU_Geotope_20200312.Geotope.Geotop.Bedeutung','bedeutung','geotope_fundstelle_grabung',NULL);
INSERT INTO afu_geotope.T_ILI2DB_ATTRNAME (IliName,SqlName,ColOwner,Target) VALUES ('SO_AFU_Geotope_20200312.Geotope.Hoehle_Fachbereich.Fachbereich','fachbereich','geotope_hoehle_fachbereich','geotope_fachbereich');
INSERT INTO afu_geotope.T_ILI2DB_ATTRNAME (IliName,SqlName,ColOwner,Target) VALUES ('SO_AFU_Geotope_20200312.Geotope.Geotop.Hinweis_Literatur','hinweis_literatur','geotope_aufschluss',NULL);
INSERT INTO afu_geotope.T_ILI2DB_ATTRNAME (IliName,SqlName,ColOwner,Target) VALUES ('SO_AFU_Geotope_20200312.Geotope.zustaendige_Stelle.Amtsname','amtsname','geotope_zustaendige_stelle',NULL);
INSERT INTO afu_geotope.T_ILI2DB_ATTRNAME (IliName,SqlName,ColOwner,Target) VALUES ('SO_AFU_Geotope_20200312.Geotope.Geotop.Beschreibung','beschreibung','geotope_quelle',NULL);
INSERT INTO afu_geotope.T_ILI2DB_ATTRNAME (IliName,SqlName,ColOwner,Target) VALUES ('GeometryCHLV95_V1.SurfaceStructure.Surface','surface','surfacestructure',NULL);
INSERT INTO afu_geotope.T_ILI2DB_ATTRNAME (IliName,SqlName,ColOwner,Target) VALUES ('SO_AFU_Geotope_20200312.Geotope.Erratiker_Fachbereich.Erratiker','erratiker','geotope_erratiker_fachbereich','geotope_erratiker');
INSERT INTO afu_geotope.T_ILI2DB_ATTRNAME (IliName,SqlName,ColOwner,Target) VALUES ('SO_AFU_Geotope_20200312.Geotope.Geotop.regionalgeologische_Einheit','regionalgeologische_einheit','geotope_erratiker',NULL);
INSERT INTO afu_geotope.T_ILI2DB_ATTRNAME (IliName,SqlName,ColOwner,Target) VALUES ('SO_AFU_Geotope_20200312.Geotope.Erratiker.Eiszeit','eiszeit','geotope_erratiker',NULL);
INSERT INTO afu_geotope.T_ILI2DB_ATTRNAME (IliName,SqlName,ColOwner,Target) VALUES ('SO_AFU_Geotope_20200312.Geotope.geologische_Serie_bis_Geotop_plus.geologische_Serie_bis','geologische_serie_bis','geotope_fundstelle_grabung','lithostratigrphie_geologische_serie');
INSERT INTO afu_geotope.T_ILI2DB_ATTRNAME (IliName,SqlName,ColOwner,Target) VALUES ('SO_AFU_Geotope_20200312.Geotope.Geotop.anthropogene_Gefaehrdung','anthropogene_gefaehrdung','geotope_quelle',NULL);
INSERT INTO afu_geotope.T_ILI2DB_ATTRNAME (IliName,SqlName,ColOwner,Target) VALUES ('SO_AFU_Geotope_20200312.Geotope.Geotop.Lokalname','lokalname','geotope_aufschluss',NULL);
INSERT INTO afu_geotope.T_ILI2DB_ATTRNAME (IliName,SqlName,ColOwner,Target) VALUES ('SO_AFU_Geotope_20200312.Geotope.Geotop.alte_Inventar_Nummer','alte_inventar_nummer','geotope_quelle',NULL);
INSERT INTO afu_geotope.T_ILI2DB_ATTRNAME (IliName,SqlName,ColOwner,Target) VALUES ('SO_AFU_Geotope_20200312.Geotope.Aufschluss_Dokument.Dokument','dokument','geotope_aufschluss_dokument','geotope_dokument');
INSERT INTO afu_geotope.T_ILI2DB_ATTRNAME (IliName,SqlName,ColOwner,Target) VALUES ('SO_AFU_Geotope_20200312.Geotope.Geotop.kant_geschuetztes_Objekt','kant_geschuetztes_objekt','geotope_hoehle',NULL);
INSERT INTO afu_geotope.T_ILI2DB_ATTRNAME (IliName,SqlName,ColOwner,Target) VALUES ('SO_AFU_Geotope_20200312.Geotope.Fundstelle_Grabung_Dokument.Fundstelle_Grabung','fundstelle_grabung','geotope_fundstelle_grabung_dokument','geotope_fundstelle_grabung');
INSERT INTO afu_geotope.T_ILI2DB_ATTRNAME (IliName,SqlName,ColOwner,Target) VALUES ('SO_AFU_Geotope_20200312.Geotope.Aufschluss.Oberflaechenform','oberflaechenform','geotope_aufschluss',NULL);
INSERT INTO afu_geotope.T_ILI2DB_ATTRNAME (IliName,SqlName,ColOwner,Target) VALUES ('SO_AFU_Geotope_20200312.Geotope.Geotop.Zustand','zustand','geotope_aufschluss',NULL);
INSERT INTO afu_geotope.T_ILI2DB_ATTRNAME (IliName,SqlName,ColOwner,Target) VALUES ('SO_AFU_Geotope_20200312.Geotope.Aufschluss_Dokument.Aufschluss','aufschluss','geotope_aufschluss_dokument','geotope_aufschluss');
INSERT INTO afu_geotope.T_ILI2DB_ATTRNAME (IliName,SqlName,ColOwner,Target) VALUES ('SO_AFU_Geotope_20200312.Geotope.Geotop.alte_Inventar_Nummer','alte_inventar_nummer','geotope_fundstelle_grabung',NULL);
INSERT INTO afu_geotope.T_ILI2DB_ATTRNAME (IliName,SqlName,ColOwner,Target) VALUES ('SO_AFU_Geotope_20200312.Geotope.Geotop.Rechtsstatus','rechtsstatus','geotope_aufschluss',NULL);
INSERT INTO afu_geotope.T_ILI2DB_ATTRNAME (IliName,SqlName,ColOwner,Target) VALUES ('SO_AFU_Geotope_20200312.Geotope.Erratiker.Schalenstein','schalenstein','geotope_erratiker',NULL);
INSERT INTO afu_geotope.T_ILI2DB_ATTRNAME (IliName,SqlName,ColOwner,Target) VALUES ('SO_AFU_Geotope_20200312.Geotope.Geotop.kant_geschuetztes_Objekt','kant_geschuetztes_objekt','geotope_landschaftsform',NULL);
INSERT INTO afu_geotope.T_ILI2DB_ATTRNAME (IliName,SqlName,ColOwner,Target) VALUES ('SO_AFU_Geotope_20200312.Geotope.Geotop.Bedeutung','bedeutung','geotope_hoehle',NULL);
INSERT INTO afu_geotope.T_ILI2DB_TRAFO (iliname,tag,setting) VALUES ('SO_AFU_Geotope_20200312.Geotope.Landschaftsform.Geometrie','ch.ehi.ili2db.multiSurfaceTrafo','coalesce');
INSERT INTO afu_geotope.T_ILI2DB_TRAFO (iliname,tag,setting) VALUES ('SO_AFU_Geotope_20200312.Geotope.Fundstelle_Grabung_Fachbereich','ch.ehi.ili2db.inheritance','newClass');
INSERT INTO afu_geotope.T_ILI2DB_TRAFO (iliname,tag,setting) VALUES ('SO_AFU_Geotope_20200312.Geotope.geologische_Stufe_bis_Geotop_plus','ch.ehi.ili2db.inheritance','embedded');
INSERT INTO afu_geotope.T_ILI2DB_TRAFO (iliname,tag,setting) VALUES ('SO_AFU_Geotope_20200312.Geotope.geologische_Serie_von_Geotop_plus','ch.ehi.ili2db.inheritance','embedded');
INSERT INTO afu_geotope.T_ILI2DB_TRAFO (iliname,tag,setting) VALUES ('SO_AFU_Geotope_20200312.Lithostratigraphie.geologische_Serie','ch.ehi.ili2db.inheritance','newClass');
INSERT INTO afu_geotope.T_ILI2DB_TRAFO (iliname,tag,setting) VALUES ('SO_AFU_Geotope_20200312.Geotope.Geotop_plus','ch.ehi.ili2db.inheritance','subClass');
INSERT INTO afu_geotope.T_ILI2DB_TRAFO (iliname,tag,setting) VALUES ('SO_AFU_Geotope_20200312.Lithostratigraphie.geologische_Serie_geologische_Stufe','ch.ehi.ili2db.inheritance','embedded');
INSERT INTO afu_geotope.T_ILI2DB_TRAFO (iliname,tag,setting) VALUES ('SO_AFU_Geotope_20200312.Geotope.Geotop','ch.ehi.ili2db.inheritance','subClass');
INSERT INTO afu_geotope.T_ILI2DB_TRAFO (iliname,tag,setting) VALUES ('SO_AFU_Geotope_20200312.Geotope.Hoehle','ch.ehi.ili2db.inheritance','newClass');
INSERT INTO afu_geotope.T_ILI2DB_TRAFO (iliname,tag,setting) VALUES ('SO_AFU_Geotope_20200312.Lithostratigraphie.geologische_Stufe_geologische_Schicht','ch.ehi.ili2db.inheritance','embedded');
INSERT INTO afu_geotope.T_ILI2DB_TRAFO (iliname,tag,setting) VALUES ('SO_AFU_Geotope_20200312.Geotope.geologische_Schicht_bis_Geotop_plus','ch.ehi.ili2db.inheritance','embedded');
INSERT INTO afu_geotope.T_ILI2DB_TRAFO (iliname,tag,setting) VALUES ('GeometryCHLV95_V1.SurfaceStructure','ch.ehi.ili2db.inheritance','newClass');
INSERT INTO afu_geotope.T_ILI2DB_TRAFO (iliname,tag,setting) VALUES ('SO_AFU_Geotope_20200312.Geotope.Quelle_Dokument','ch.ehi.ili2db.inheritance','newClass');
INSERT INTO afu_geotope.T_ILI2DB_TRAFO (iliname,tag,setting) VALUES ('SO_AFU_Geotope_20200312.Geotope.Fundstelle_Grabung_Dokument','ch.ehi.ili2db.inheritance','newClass');
INSERT INTO afu_geotope.T_ILI2DB_TRAFO (iliname,tag,setting) VALUES ('SO_AFU_Geotope_20200312.Geotope.Aufschluss_Dokument','ch.ehi.ili2db.inheritance','newClass');
INSERT INTO afu_geotope.T_ILI2DB_TRAFO (iliname,tag,setting) VALUES ('SO_AFU_Geotope_20200312.Geotope.geologische_Serie_bis_Geotop_plus','ch.ehi.ili2db.inheritance','embedded');
INSERT INTO afu_geotope.T_ILI2DB_TRAFO (iliname,tag,setting) VALUES ('SO_AFU_Geotope_20200312.Lithostratigraphie.geologisches_System_geologische_Serie','ch.ehi.ili2db.inheritance','embedded');
INSERT INTO afu_geotope.T_ILI2DB_TRAFO (iliname,tag,setting) VALUES ('SO_AFU_Geotope_20200312.Geotope.Erratiker','ch.ehi.ili2db.inheritance','newClass');
INSERT INTO afu_geotope.T_ILI2DB_TRAFO (iliname,tag,setting) VALUES ('SO_AFU_Geotope_20200312.Geotope.Landschaftsform','ch.ehi.ili2db.inheritance','newClass');
INSERT INTO afu_geotope.T_ILI2DB_TRAFO (iliname,tag,setting) VALUES ('SO_AFU_Geotope_20200312.Lithostratigraphie.geologisches_System','ch.ehi.ili2db.inheritance','newClass');
INSERT INTO afu_geotope.T_ILI2DB_TRAFO (iliname,tag,setting) VALUES ('SO_AFU_Geotope_20200312.Geotope.Fundstelle_Grabung','ch.ehi.ili2db.inheritance','newClass');
INSERT INTO afu_geotope.T_ILI2DB_TRAFO (iliname,tag,setting) VALUES ('SO_AFU_Geotope_20200312.Geotope.geologisches_System_bis_Geotop_plus','ch.ehi.ili2db.inheritance','embedded');
INSERT INTO afu_geotope.T_ILI2DB_TRAFO (iliname,tag,setting) VALUES ('SO_AFU_Geotope_20200312.Geotope.Fachbereich','ch.ehi.ili2db.inheritance','newClass');
INSERT INTO afu_geotope.T_ILI2DB_TRAFO (iliname,tag,setting) VALUES ('SO_AFU_Geotope_20200312.Geotope.Aufschluss','ch.ehi.ili2db.inheritance','newClass');
INSERT INTO afu_geotope.T_ILI2DB_TRAFO (iliname,tag,setting) VALUES ('SO_AFU_Geotope_20200312.Geotope.geologisches_System_von_Geotop_plus','ch.ehi.ili2db.inheritance','embedded');
INSERT INTO afu_geotope.T_ILI2DB_TRAFO (iliname,tag,setting) VALUES ('SO_AFU_Geotope_20200312.Geotope.Landform_Dokument','ch.ehi.ili2db.inheritance','newClass');
INSERT INTO afu_geotope.T_ILI2DB_TRAFO (iliname,tag,setting) VALUES ('SO_AFU_Geotope_20200312.Geotope.Hoehle_Fachbereich','ch.ehi.ili2db.inheritance','newClass');
INSERT INTO afu_geotope.T_ILI2DB_TRAFO (iliname,tag,setting) VALUES ('SO_AFU_Geotope_20200312.Geotope.Hoehle_Dokument','ch.ehi.ili2db.inheritance','newClass');
INSERT INTO afu_geotope.T_ILI2DB_TRAFO (iliname,tag,setting) VALUES ('SO_AFU_Geotope_20200312.Geotope.geologische_Stufe_von_Geotop_plus','ch.ehi.ili2db.inheritance','embedded');
INSERT INTO afu_geotope.T_ILI2DB_TRAFO (iliname,tag,setting) VALUES ('SO_AFU_Geotope_20200312.Geotope.Landform_Fachbereich','ch.ehi.ili2db.inheritance','newClass');
INSERT INTO afu_geotope.T_ILI2DB_TRAFO (iliname,tag,setting) VALUES ('SO_AFU_Geotope_20200312.Lithostratigraphie.geologische_Stufe','ch.ehi.ili2db.inheritance','newClass');
INSERT INTO afu_geotope.T_ILI2DB_TRAFO (iliname,tag,setting) VALUES ('SO_AFU_Geotope_20200312.Geotope.Quelle','ch.ehi.ili2db.inheritance','newClass');
INSERT INTO afu_geotope.T_ILI2DB_TRAFO (iliname,tag,setting) VALUES ('SO_AFU_Geotope_20200312.Geotope.Aufschluss.Geometrie','ch.ehi.ili2db.multiSurfaceTrafo','coalesce');
INSERT INTO afu_geotope.T_ILI2DB_TRAFO (iliname,tag,setting) VALUES ('SO_AFU_Geotope_20200312.Geotope.zustaendige_Stelle','ch.ehi.ili2db.inheritance','newClass');
INSERT INTO afu_geotope.T_ILI2DB_TRAFO (iliname,tag,setting) VALUES ('SO_AFU_Geotope_20200312.Geotope.Aufschluss_Fachbereich','ch.ehi.ili2db.inheritance','newClass');
INSERT INTO afu_geotope.T_ILI2DB_TRAFO (iliname,tag,setting) VALUES ('SO_AFU_Geotope_20200312.Geotope.Dokument','ch.ehi.ili2db.inheritance','newClass');
INSERT INTO afu_geotope.T_ILI2DB_TRAFO (iliname,tag,setting) VALUES ('SO_AFU_Geotope_20200312.Lithostratigraphie.geologische_Schicht','ch.ehi.ili2db.inheritance','newClass');
INSERT INTO afu_geotope.T_ILI2DB_TRAFO (iliname,tag,setting) VALUES ('SO_AFU_Geotope_20200312.Geotope.Erratiker_Fachbereich','ch.ehi.ili2db.inheritance','newClass');
INSERT INTO afu_geotope.T_ILI2DB_TRAFO (iliname,tag,setting) VALUES ('GeometryCHLV95_V1.MultiSurface','ch.ehi.ili2db.inheritance','newClass');
INSERT INTO afu_geotope.T_ILI2DB_TRAFO (iliname,tag,setting) VALUES ('SO_AFU_Geotope_20200312.Geotope.geologische_Schicht_von_Geotop_plus','ch.ehi.ili2db.inheritance','embedded');
INSERT INTO afu_geotope.T_ILI2DB_TRAFO (iliname,tag,setting) VALUES ('SO_AFU_Geotope_20200312.Geotope.Quelle_Fachbereich','ch.ehi.ili2db.inheritance','newClass');
INSERT INTO afu_geotope.T_ILI2DB_TRAFO (iliname,tag,setting) VALUES ('SO_AFU_Geotope_20200312.Geotope.zustaendige_Stelle_Geotop','ch.ehi.ili2db.inheritance','embedded');
INSERT INTO afu_geotope.T_ILI2DB_TRAFO (iliname,tag,setting) VALUES ('SO_AFU_Geotope_20200312.Geotope.Erratiker_Dokument','ch.ehi.ili2db.inheritance','newClass');
INSERT INTO afu_geotope.T_ILI2DB_INHERITANCE (thisClass,baseClass) VALUES ('SO_AFU_Geotope_20200312.Geotope.geologische_Serie_bis_Geotop_plus',NULL);
INSERT INTO afu_geotope.T_ILI2DB_INHERITANCE (thisClass,baseClass) VALUES ('SO_AFU_Geotope_20200312.Geotope.Aufschluss','SO_AFU_Geotope_20200312.Geotope.Geotop_plus');
INSERT INTO afu_geotope.T_ILI2DB_INHERITANCE (thisClass,baseClass) VALUES ('SO_AFU_Geotope_20200312.Lithostratigraphie.geologische_Stufe',NULL);
INSERT INTO afu_geotope.T_ILI2DB_INHERITANCE (thisClass,baseClass) VALUES ('SO_AFU_Geotope_20200312.Geotope.Quelle','SO_AFU_Geotope_20200312.Geotope.Geotop');
INSERT INTO afu_geotope.T_ILI2DB_INHERITANCE (thisClass,baseClass) VALUES ('SO_AFU_Geotope_20200312.Geotope.Landform_Dokument',NULL);
INSERT INTO afu_geotope.T_ILI2DB_INHERITANCE (thisClass,baseClass) VALUES ('SO_AFU_Geotope_20200312.Geotope.Quelle_Fachbereich',NULL);
INSERT INTO afu_geotope.T_ILI2DB_INHERITANCE (thisClass,baseClass) VALUES ('SO_AFU_Geotope_20200312.Geotope.Hoehle_Dokument',NULL);
INSERT INTO afu_geotope.T_ILI2DB_INHERITANCE (thisClass,baseClass) VALUES ('SO_AFU_Geotope_20200312.Geotope.Aufschluss_Fachbereich',NULL);
INSERT INTO afu_geotope.T_ILI2DB_INHERITANCE (thisClass,baseClass) VALUES ('SO_AFU_Geotope_20200312.Lithostratigraphie.geologisches_System_geologische_Serie',NULL);
INSERT INTO afu_geotope.T_ILI2DB_INHERITANCE (thisClass,baseClass) VALUES ('SO_AFU_Geotope_20200312.Geotope.zustaendige_Stelle_Geotop',NULL);
INSERT INTO afu_geotope.T_ILI2DB_INHERITANCE (thisClass,baseClass) VALUES ('GeometryCHLV95_V1.SurfaceStructure',NULL);
INSERT INTO afu_geotope.T_ILI2DB_INHERITANCE (thisClass,baseClass) VALUES ('SO_AFU_Geotope_20200312.Geotope.geologische_Schicht_von_Geotop_plus',NULL);
INSERT INTO afu_geotope.T_ILI2DB_INHERITANCE (thisClass,baseClass) VALUES ('SO_AFU_Geotope_20200312.Geotope.Hoehle_Fachbereich',NULL);
INSERT INTO afu_geotope.T_ILI2DB_INHERITANCE (thisClass,baseClass) VALUES ('SO_AFU_Geotope_20200312.Geotope.Quelle_Dokument',NULL);
INSERT INTO afu_geotope.T_ILI2DB_INHERITANCE (thisClass,baseClass) VALUES ('SO_AFU_Geotope_20200312.Geotope.geologisches_System_bis_Geotop_plus',NULL);
INSERT INTO afu_geotope.T_ILI2DB_INHERITANCE (thisClass,baseClass) VALUES ('SO_AFU_Geotope_20200312.Geotope.Fundstelle_Grabung','SO_AFU_Geotope_20200312.Geotope.Geotop_plus');
INSERT INTO afu_geotope.T_ILI2DB_INHERITANCE (thisClass,baseClass) VALUES ('SO_AFU_Geotope_20200312.Geotope.Fundstelle_Grabung_Fachbereich',NULL);
INSERT INTO afu_geotope.T_ILI2DB_INHERITANCE (thisClass,baseClass) VALUES ('SO_AFU_Geotope_20200312.Geotope.Aufschluss_Dokument',NULL);
INSERT INTO afu_geotope.T_ILI2DB_INHERITANCE (thisClass,baseClass) VALUES ('SO_AFU_Geotope_20200312.Geotope.geologisches_System_von_Geotop_plus',NULL);
INSERT INTO afu_geotope.T_ILI2DB_INHERITANCE (thisClass,baseClass) VALUES ('SO_AFU_Geotope_20200312.Lithostratigraphie.geologische_Serie',NULL);
INSERT INTO afu_geotope.T_ILI2DB_INHERITANCE (thisClass,baseClass) VALUES ('SO_AFU_Geotope_20200312.Geotope.Erratiker_Dokument',NULL);
INSERT INTO afu_geotope.T_ILI2DB_INHERITANCE (thisClass,baseClass) VALUES ('SO_AFU_Geotope_20200312.Geotope.geologische_Serie_von_Geotop_plus',NULL);
INSERT INTO afu_geotope.T_ILI2DB_INHERITANCE (thisClass,baseClass) VALUES ('SO_AFU_Geotope_20200312.Geotope.Hoehle','SO_AFU_Geotope_20200312.Geotope.Geotop');
INSERT INTO afu_geotope.T_ILI2DB_INHERITANCE (thisClass,baseClass) VALUES ('SO_AFU_Geotope_20200312.Geotope.Geotop',NULL);
INSERT INTO afu_geotope.T_ILI2DB_INHERITANCE (thisClass,baseClass) VALUES ('SO_AFU_Geotope_20200312.Lithostratigraphie.geologische_Stufe_geologische_Schicht',NULL);
INSERT INTO afu_geotope.T_ILI2DB_INHERITANCE (thisClass,baseClass) VALUES ('SO_AFU_Geotope_20200312.Geotope.geologische_Stufe_bis_Geotop_plus',NULL);
INSERT INTO afu_geotope.T_ILI2DB_INHERITANCE (thisClass,baseClass) VALUES ('SO_AFU_Geotope_20200312.Geotope.Fachbereich',NULL);
INSERT INTO afu_geotope.T_ILI2DB_INHERITANCE (thisClass,baseClass) VALUES ('SO_AFU_Geotope_20200312.Geotope.Geotop_plus','SO_AFU_Geotope_20200312.Geotope.Geotop');
INSERT INTO afu_geotope.T_ILI2DB_INHERITANCE (thisClass,baseClass) VALUES ('SO_AFU_Geotope_20200312.Geotope.Erratiker_Fachbereich',NULL);
INSERT INTO afu_geotope.T_ILI2DB_INHERITANCE (thisClass,baseClass) VALUES ('SO_AFU_Geotope_20200312.Lithostratigraphie.geologisches_System',NULL);
INSERT INTO afu_geotope.T_ILI2DB_INHERITANCE (thisClass,baseClass) VALUES ('SO_AFU_Geotope_20200312.Geotope.Landform_Fachbereich',NULL);
INSERT INTO afu_geotope.T_ILI2DB_INHERITANCE (thisClass,baseClass) VALUES ('SO_AFU_Geotope_20200312.Lithostratigraphie.geologische_Serie_geologische_Stufe',NULL);
INSERT INTO afu_geotope.T_ILI2DB_INHERITANCE (thisClass,baseClass) VALUES ('SO_AFU_Geotope_20200312.Geotope.Dokument',NULL);
INSERT INTO afu_geotope.T_ILI2DB_INHERITANCE (thisClass,baseClass) VALUES ('SO_AFU_Geotope_20200312.Geotope.geologische_Schicht_bis_Geotop_plus',NULL);
INSERT INTO afu_geotope.T_ILI2DB_INHERITANCE (thisClass,baseClass) VALUES ('SO_AFU_Geotope_20200312.Geotope.geologische_Stufe_von_Geotop_plus',NULL);
INSERT INTO afu_geotope.T_ILI2DB_INHERITANCE (thisClass,baseClass) VALUES ('SO_AFU_Geotope_20200312.Geotope.Erratiker','SO_AFU_Geotope_20200312.Geotope.Geotop');
INSERT INTO afu_geotope.T_ILI2DB_INHERITANCE (thisClass,baseClass) VALUES ('SO_AFU_Geotope_20200312.Geotope.zustaendige_Stelle',NULL);
INSERT INTO afu_geotope.T_ILI2DB_INHERITANCE (thisClass,baseClass) VALUES ('SO_AFU_Geotope_20200312.Geotope.Landschaftsform','SO_AFU_Geotope_20200312.Geotope.Geotop');
INSERT INTO afu_geotope.T_ILI2DB_INHERITANCE (thisClass,baseClass) VALUES ('GeometryCHLV95_V1.MultiSurface',NULL);
INSERT INTO afu_geotope.T_ILI2DB_INHERITANCE (thisClass,baseClass) VALUES ('SO_AFU_Geotope_20200312.Geotope.Fundstelle_Grabung_Dokument',NULL);
INSERT INTO afu_geotope.T_ILI2DB_INHERITANCE (thisClass,baseClass) VALUES ('SO_AFU_Geotope_20200312.Lithostratigraphie.geologische_Schicht',NULL);
INSERT INTO afu_geotope.eiszeit (seq,iliCode,itfCode,dispName,inactive,description) VALUES (NULL,'unbekannt',0,'unbekannt',FALSE,NULL);
INSERT INTO afu_geotope.eiszeit (seq,iliCode,itfCode,dispName,inactive,description) VALUES (NULL,'Wuerm',1,'Wuerm',FALSE,'vor 115''000 - 10''000 Jahren');
INSERT INTO afu_geotope.eiszeit (seq,iliCode,itfCode,dispName,inactive,description) VALUES (NULL,'Riss',2,'Riss',FALSE,'vor 300''000 - 130''000 Jahren');
INSERT INTO afu_geotope.eiszeit (seq,iliCode,itfCode,dispName,inactive,description) VALUES (NULL,'Mindel',3,'Mindel',FALSE,'vor 460''000 - 400''000 Jahren');
INSERT INTO afu_geotope.eiszeit (seq,iliCode,itfCode,dispName,inactive,description) VALUES (NULL,'Guenz',4,'Guenz',FALSE,'vor 600''000 - 800''000 Jahren');
INSERT INTO afu_geotope.entstehung (seq,iliCode,itfCode,dispName,inactive,description) VALUES (NULL,'natuerlich',0,'natuerlich',FALSE,NULL);
INSERT INTO afu_geotope.entstehung (seq,iliCode,itfCode,dispName,inactive,description) VALUES (NULL,'anthropogen',1,'anthropogen',FALSE,NULL);
INSERT INTO afu_geotope.entstehung (seq,iliCode,itfCode,dispName,inactive,description) VALUES (NULL,'unbekannt',2,'unbekannt',FALSE,NULL);
INSERT INTO afu_geotope.schutzwuerdigkeit (seq,iliCode,itfCode,dispName,inactive,description) VALUES (NULL,'geschuetzt',0,'geschuetzt',FALSE,NULL);
INSERT INTO afu_geotope.schutzwuerdigkeit (seq,iliCode,itfCode,dispName,inactive,description) VALUES (NULL,'schutzwuerdig',1,'schutzwuerdig',FALSE,NULL);
INSERT INTO afu_geotope.schutzwuerdigkeit (seq,iliCode,itfCode,dispName,inactive,description) VALUES (NULL,'erhaltenswert',2,'erhaltenswert',FALSE,NULL);
INSERT INTO afu_geotope.schutzwuerdigkeit (seq,iliCode,itfCode,dispName,inactive,description) VALUES (NULL,'unbedeutend',3,'unbedeutend',FALSE,NULL);
INSERT INTO afu_geotope.schutzwuerdigkeit (seq,iliCode,itfCode,dispName,inactive,description) VALUES (NULL,'unbekannt',4,'unbekannt',FALSE,NULL);
INSERT INTO afu_geotope.geologische_schicht (seq,iliCode,itfCode,dispName,inactive,description) VALUES (NULL,'Murchisonae_Schichten',0,'Murchisonae Schichten',FALSE,NULL);
INSERT INTO afu_geotope.geologische_schicht (seq,iliCode,itfCode,dispName,inactive,description) VALUES (NULL,'Opalinuston',1,'Opalinuston',FALSE,NULL);
INSERT INTO afu_geotope.geologische_schicht (seq,iliCode,itfCode,dispName,inactive,description) VALUES (NULL,'Blagdeni_Schichten',2,'Blagdeni Schichten',FALSE,NULL);
INSERT INTO afu_geotope.geologische_schicht (seq,iliCode,itfCode,dispName,inactive,description) VALUES (NULL,'Humphriesi_Schichten',3,'Humphriesi Schichten',FALSE,NULL);
INSERT INTO afu_geotope.geologische_schicht (seq,iliCode,itfCode,dispName,inactive,description) VALUES (NULL,'Unterer_Hauptrogenstein',4,'Unterer Hauptrogenstein',FALSE,NULL);
INSERT INTO afu_geotope.geologische_schicht (seq,iliCode,itfCode,dispName,inactive,description) VALUES (NULL,'Maeandrina_Schichten',5,'Maeandrina Schichten',FALSE,NULL);
INSERT INTO afu_geotope.geologische_schicht (seq,iliCode,itfCode,dispName,inactive,description) VALUES (NULL,'Sowerbyi_Sauzei_Schichten',6,'Sowerbyi Sauzei Schichten',FALSE,NULL);
INSERT INTO afu_geotope.geologische_schicht (seq,iliCode,itfCode,dispName,inactive,description) VALUES (NULL,'Ferrugineus_Oolith',7,'Ferrugineus Oolith',FALSE,NULL);
INSERT INTO afu_geotope.geologische_schicht (seq,iliCode,itfCode,dispName,inactive,description) VALUES (NULL,'Homomyen_Mergel',8,'Homomyen Mergel',FALSE,NULL);
INSERT INTO afu_geotope.geologische_schicht (seq,iliCode,itfCode,dispName,inactive,description) VALUES (NULL,'Movelier_Schichten',9,'Movelier Schichten',FALSE,NULL);
INSERT INTO afu_geotope.geologische_schicht (seq,iliCode,itfCode,dispName,inactive,description) VALUES (NULL,'Oberer_Hauptrogenstein',10,'Oberer Hauptrogenstein',FALSE,NULL);
INSERT INTO afu_geotope.geologische_schicht (seq,iliCode,itfCode,dispName,inactive,description) VALUES (NULL,'Varians_Schichten',11,'Varians Schichten',FALSE,NULL);
INSERT INTO afu_geotope.geologische_schicht (seq,iliCode,itfCode,dispName,inactive,description) VALUES (NULL,'Anceps_Athleta_Schichten',12,'Anceps Athleta Schichten',FALSE,NULL);
INSERT INTO afu_geotope.geologische_schicht (seq,iliCode,itfCode,dispName,inactive,description) VALUES (NULL,'Callovien_Ton',13,'Callovien Ton',FALSE,NULL);
INSERT INTO afu_geotope.geologische_schicht (seq,iliCode,itfCode,dispName,inactive,description) VALUES (NULL,'Dalle_nacree',14,'Dalle nacree',FALSE,NULL);
INSERT INTO afu_geotope.geologische_schicht (seq,iliCode,itfCode,dispName,inactive,description) VALUES (NULL,'Macrocephalus_Schichten',15,'Macrocephalus Schichten',FALSE,NULL);
INSERT INTO afu_geotope.geologische_schicht (seq,iliCode,itfCode,dispName,inactive,description) VALUES (NULL,'Insekten_Mergel',16,'Insekten Mergel',FALSE,NULL);
INSERT INTO afu_geotope.geologische_schicht (seq,iliCode,itfCode,dispName,inactive,description) VALUES (NULL,'Arieten_Kalk',17,'Arieten Kalk',FALSE,NULL);
INSERT INTO afu_geotope.geologische_schicht (seq,iliCode,itfCode,dispName,inactive,description) VALUES (NULL,'Opliqua_Spinatus_Schichten',18,'Opliqua Spinatus Schichten',FALSE,NULL);
INSERT INTO afu_geotope.geologische_schicht (seq,iliCode,itfCode,dispName,inactive,description) VALUES (NULL,'Obtusus_Ton',19,'Obtusus Ton',FALSE,NULL);
INSERT INTO afu_geotope.geologische_schicht (seq,iliCode,itfCode,dispName,inactive,description) VALUES (NULL,'Posidonien_Schiefer',20,'Posidonien Schiefer',FALSE,NULL);
INSERT INTO afu_geotope.geologische_schicht (seq,iliCode,itfCode,dispName,inactive,description) VALUES (NULL,'Birmenstorfer_Schichten',21,'Birmenstorfer Schichten',FALSE,NULL);
INSERT INTO afu_geotope.geologische_schicht (seq,iliCode,itfCode,dispName,inactive,description) VALUES (NULL,'Korallenkalk',22,'Korallenkalk',FALSE,NULL);
INSERT INTO afu_geotope.geologische_schicht (seq,iliCode,itfCode,dispName,inactive,description) VALUES (NULL,'Liesberg_Schichten',23,'Liesberg Schichten',FALSE,NULL);
INSERT INTO afu_geotope.geologische_schicht (seq,iliCode,itfCode,dispName,inactive,description) VALUES (NULL,'Rauracien_Oolith',24,'Rauracien Oolith',FALSE,NULL);
INSERT INTO afu_geotope.geologische_schicht (seq,iliCode,itfCode,dispName,inactive,description) VALUES (NULL,'Oxford_Mergel',25,'Oxford Mergel',FALSE,NULL);
INSERT INTO afu_geotope.geologische_schicht (seq,iliCode,itfCode,dispName,inactive,description) VALUES (NULL,'Renggeri_Ton',26,'Renggeri Ton',FALSE,NULL);
INSERT INTO afu_geotope.geologische_schicht (seq,iliCode,itfCode,dispName,inactive,description) VALUES (NULL,'Terrain_a_chailles',27,'Terrain a chailles',FALSE,NULL);
INSERT INTO afu_geotope.geologische_schicht (seq,iliCode,itfCode,dispName,inactive,description) VALUES (NULL,'Effinger_Schichten',28,'Effinger Schichten',FALSE,NULL);
INSERT INTO afu_geotope.geologische_schicht (seq,iliCode,itfCode,dispName,inactive,description) VALUES (NULL,'Humeralis_Schichten',29,'Humeralis Schichten',FALSE,NULL);
INSERT INTO afu_geotope.geologische_schicht (seq,iliCode,itfCode,dispName,inactive,description) VALUES (NULL,'Natica_Schichten',30,'Natica Schichten',FALSE,NULL);
INSERT INTO afu_geotope.geologische_schicht (seq,iliCode,itfCode,dispName,inactive,description) VALUES (NULL,'Verena_Schichten',31,'Verena Schichten',FALSE,NULL);
INSERT INTO afu_geotope.geologische_schicht (seq,iliCode,itfCode,dispName,inactive,description) VALUES (NULL,'Siderolithikum',32,'Siderolithikum',FALSE,NULL);
INSERT INTO afu_geotope.geologische_schicht (seq,iliCode,itfCode,dispName,inactive,description) VALUES (NULL,'OMM',33,'OMM',FALSE,NULL);
INSERT INTO afu_geotope.geologische_schicht (seq,iliCode,itfCode,dispName,inactive,description) VALUES (NULL,'OSM',34,'OSM',FALSE,NULL);
INSERT INTO afu_geotope.geologische_schicht (seq,iliCode,itfCode,dispName,inactive,description) VALUES (NULL,'USM',35,'USM',FALSE,NULL);
INSERT INTO afu_geotope.geologische_schicht (seq,iliCode,itfCode,dispName,inactive,description) VALUES (NULL,'UMM',36,'UMM',FALSE,NULL);
INSERT INTO afu_geotope.geologische_schicht (seq,iliCode,itfCode,dispName,inactive,description) VALUES (NULL,'UMM_USM',37,'UMM USM',FALSE,NULL);
INSERT INTO afu_geotope.geologische_schicht (seq,iliCode,itfCode,dispName,inactive,description) VALUES (NULL,'Quarzsandsteine',38,'Quarzsandsteine',FALSE,NULL);
INSERT INTO afu_geotope.geologische_schicht (seq,iliCode,itfCode,dispName,inactive,description) VALUES (NULL,'Roet',39,'Roet',FALSE,NULL);
INSERT INTO afu_geotope.geologische_schicht (seq,iliCode,itfCode,dispName,inactive,description) VALUES (NULL,'Plattensandstein',40,'Plattensandstein',FALSE,NULL);
INSERT INTO afu_geotope.geologische_schicht (seq,iliCode,itfCode,dispName,inactive,description) VALUES (NULL,'Gansinger_Dolomit',41,'Gansinger Dolomit',FALSE,NULL);
INSERT INTO afu_geotope.geologische_schicht (seq,iliCode,itfCode,dispName,inactive,description) VALUES (NULL,'Gipskeuper',42,'Gipskeuper',FALSE,NULL);
INSERT INTO afu_geotope.geologische_schicht (seq,iliCode,itfCode,dispName,inactive,description) VALUES (NULL,'Obere_Bunte_Mergel',43,'Obere Bunte Mergel',FALSE,NULL);
INSERT INTO afu_geotope.geologische_schicht (seq,iliCode,itfCode,dispName,inactive,description) VALUES (NULL,'Schilfsandstein',44,'Schilfsandstein',FALSE,NULL);
INSERT INTO afu_geotope.geologische_schicht (seq,iliCode,itfCode,dispName,inactive,description) VALUES (NULL,'Untere_Bunte_Mergel',45,'Untere Bunte Mergel',FALSE,NULL);
INSERT INTO afu_geotope.geologische_schicht (seq,iliCode,itfCode,dispName,inactive,description) VALUES (NULL,'Rhaet',46,'Rhaet',FALSE,NULL);
INSERT INTO afu_geotope.geologische_schicht (seq,iliCode,itfCode,dispName,inactive,description) VALUES (NULL,'Lettenkohle',47,'Lettenkohle',FALSE,NULL);
INSERT INTO afu_geotope.geologische_schicht (seq,iliCode,itfCode,dispName,inactive,description) VALUES (NULL,'Anhydritgruppe',48,'Anhydritgruppe',FALSE,NULL);
INSERT INTO afu_geotope.geologische_schicht (seq,iliCode,itfCode,dispName,inactive,description) VALUES (NULL,'Dolomitzone',49,'Dolomitzone',FALSE,NULL);
INSERT INTO afu_geotope.geologische_schicht (seq,iliCode,itfCode,dispName,inactive,description) VALUES (NULL,'Salzlager',50,'Salzlager',FALSE,NULL);
INSERT INTO afu_geotope.geologische_schicht (seq,iliCode,itfCode,dispName,inactive,description) VALUES (NULL,'Sulfatzone',51,'Sulfatzone',FALSE,NULL);
INSERT INTO afu_geotope.geologische_schicht (seq,iliCode,itfCode,dispName,inactive,description) VALUES (NULL,'Hauptmuschelkalk',52,'Hauptmuschelkalk',FALSE,NULL);
INSERT INTO afu_geotope.geologische_schicht (seq,iliCode,itfCode,dispName,inactive,description) VALUES (NULL,'Plattenkalk',53,'Plattenkalk',FALSE,NULL);
INSERT INTO afu_geotope.geologische_schicht (seq,iliCode,itfCode,dispName,inactive,description) VALUES (NULL,'Trigonodus_Dolomit',54,'Trigonodus Dolomit',FALSE,NULL);
INSERT INTO afu_geotope.geologische_schicht (seq,iliCode,itfCode,dispName,inactive,description) VALUES (NULL,'Trochitenkalk',55,'Trochitenkalk',FALSE,NULL);
INSERT INTO afu_geotope.geologische_schicht (seq,iliCode,itfCode,dispName,inactive,description) VALUES (NULL,'Orbicularis_Mergel',56,'Orbicularis Mergel',FALSE,NULL);
INSERT INTO afu_geotope.geologische_schicht (seq,iliCode,itfCode,dispName,inactive,description) VALUES (NULL,'Wellendolomit',57,'Wellendolomit',FALSE,NULL);
INSERT INTO afu_geotope.geologische_schicht (seq,iliCode,itfCode,dispName,inactive,description) VALUES (NULL,'Wellenkalk',58,'Wellenkalk',FALSE,NULL);
INSERT INTO afu_geotope.geologische_schicht (seq,iliCode,itfCode,dispName,inactive,description) VALUES (NULL,'Wellengebirge',59,'Wellengebirge',FALSE,NULL);
INSERT INTO afu_geotope.geologische_schicht (seq,iliCode,itfCode,dispName,inactive,description) VALUES (NULL,'Hochterrasse',60,'Hochterrasse',FALSE,NULL);
INSERT INTO afu_geotope.geologische_schicht (seq,iliCode,itfCode,dispName,inactive,description) VALUES (NULL,'Grundmoraene',61,'Grundmoraene',FALSE,NULL);
INSERT INTO afu_geotope.geologische_schicht (seq,iliCode,itfCode,dispName,inactive,description) VALUES (NULL,'Niederterrasse',62,'Niederterrasse',FALSE,NULL);
INSERT INTO afu_geotope.geologische_schicht (seq,iliCode,itfCode,dispName,inactive,description) VALUES (NULL,'Sander',63,'Sander',FALSE,NULL);
INSERT INTO afu_geotope.geologische_schicht (seq,iliCode,itfCode,dispName,inactive,description) VALUES (NULL,'Seitenmoraene',64,'Seitenmoraene',FALSE,NULL);
INSERT INTO afu_geotope.geologische_schicht (seq,iliCode,itfCode,dispName,inactive,description) VALUES (NULL,'U_Tal',65,'U Tal',FALSE,NULL);
INSERT INTO afu_geotope.geologische_schicht (seq,iliCode,itfCode,dispName,inactive,description) VALUES (NULL,'unbekannt',66,'unbekannt',FALSE,NULL);
INSERT INTO afu_geotope.geologische_schicht (seq,iliCode,itfCode,dispName,inactive,description) VALUES (NULL,'undifferenziert',67,'undifferenziert',FALSE,NULL);
INSERT INTO afu_geotope.geologische_schicht (seq,iliCode,itfCode,dispName,inactive,description) VALUES (NULL,'Vorbourg_Kalke',68,'Vorbourg Kalke',FALSE,NULL);
INSERT INTO afu_geotope.geologische_schicht (seq,iliCode,itfCode,dispName,inactive,description) VALUES (NULL,'Erratiker',69,'Erratiker',FALSE,NULL);
INSERT INTO afu_geotope.geologische_schicht (seq,iliCode,itfCode,dispName,inactive,description) VALUES (NULL,'Moraene',70,'Moraene',FALSE,NULL);
INSERT INTO afu_geotope.geologische_schicht (seq,iliCode,itfCode,dispName,inactive,description) VALUES (NULL,'Glaziallandschaft',71,'Glaziallandschaft',FALSE,NULL);
INSERT INTO afu_geotope.geologische_schicht (seq,iliCode,itfCode,dispName,inactive,description) VALUES (NULL,'Balsthaler_Formation',72,'Balsthaler Formation',FALSE,NULL);
INSERT INTO afu_geotope.geologische_schicht (seq,iliCode,itfCode,dispName,inactive,description) VALUES (NULL,'Wallmoraene',73,'Wallmoraene',FALSE,NULL);
INSERT INTO afu_geotope.geologische_schicht (seq,iliCode,itfCode,dispName,inactive,description) VALUES (NULL,'Holzflue_Schicht',74,'Holzflue Schicht',FALSE,NULL);
INSERT INTO afu_geotope.regionalgeologische_einheit (seq,iliCode,itfCode,dispName,inactive,description) VALUES (NULL,'Tafeljura',0,'Tafeljura',FALSE,NULL);
INSERT INTO afu_geotope.regionalgeologische_einheit (seq,iliCode,itfCode,dispName,inactive,description) VALUES (NULL,'Faltenjura',1,'Faltenjura',FALSE,NULL);
INSERT INTO afu_geotope.regionalgeologische_einheit (seq,iliCode,itfCode,dispName,inactive,description) VALUES (NULL,'Mittelland',2,'Mittelland',FALSE,NULL);
INSERT INTO afu_geotope.regionalgeologische_einheit (seq,iliCode,itfCode,dispName,inactive,description) VALUES (NULL,'unbekannt',3,'unbekannt',FALSE,NULL);
INSERT INTO afu_geotope.geowissenschaftlicher_wert (seq,iliCode,itfCode,dispName,inactive,description) VALUES (NULL,'geringwertig',0,'geringwertig',FALSE,NULL);
INSERT INTO afu_geotope.geowissenschaftlicher_wert (seq,iliCode,itfCode,dispName,inactive,description) VALUES (NULL,'bedeutend',1,'bedeutend',FALSE,NULL);
INSERT INTO afu_geotope.geowissenschaftlicher_wert (seq,iliCode,itfCode,dispName,inactive,description) VALUES (NULL,'wertvoll',2,'wertvoll',FALSE,NULL);
INSERT INTO afu_geotope.geowissenschaftlicher_wert (seq,iliCode,itfCode,dispName,inactive,description) VALUES (NULL,'besonders_wertvoll',3,'besonders wertvoll',FALSE,NULL);
INSERT INTO afu_geotope.geowissenschaftlicher_wert (seq,iliCode,itfCode,dispName,inactive,description) VALUES (NULL,'unbekannt',4,'unbekannt',FALSE,NULL);
INSERT INTO afu_geotope.gesteinsart (seq,iliCode,itfCode,dispName,inactive,description) VALUES (NULL,'Granit',0,'Granit',FALSE,NULL);
INSERT INTO afu_geotope.gesteinsart (seq,iliCode,itfCode,dispName,inactive,description) VALUES (NULL,'Mergel',1,'Mergel',FALSE,NULL);
INSERT INTO afu_geotope.gesteinsart (seq,iliCode,itfCode,dispName,inactive,description) VALUES (NULL,'Penninischer_Gruenschiefer',2,'Penninischer Gruenschiefer',FALSE,NULL);
INSERT INTO afu_geotope.gesteinsart (seq,iliCode,itfCode,dispName,inactive,description) VALUES (NULL,'Porphyrischer_Granit',3,'Porphyrischer Granit',FALSE,NULL);
INSERT INTO afu_geotope.gesteinsart (seq,iliCode,itfCode,dispName,inactive,description) VALUES (NULL,'Sandstein',4,'Sandstein',FALSE,NULL);
INSERT INTO afu_geotope.gesteinsart (seq,iliCode,itfCode,dispName,inactive,description) VALUES (NULL,'Ton',5,'Ton',FALSE,NULL);
INSERT INTO afu_geotope.gesteinsart (seq,iliCode,itfCode,dispName,inactive,description) VALUES (NULL,'Vallorcine_Konglomerat',6,'Vallorcine Konglomerat',FALSE,NULL);
INSERT INTO afu_geotope.gesteinsart (seq,iliCode,itfCode,dispName,inactive,description) VALUES (NULL,'Wechsellagerung',7,'Wechsellagerung',FALSE,NULL);
INSERT INTO afu_geotope.gesteinsart (seq,iliCode,itfCode,dispName,inactive,description) VALUES (NULL,'unbekannt',8,'unbekannt',FALSE,NULL);
INSERT INTO afu_geotope.gesteinsart (seq,iliCode,itfCode,dispName,inactive,description) VALUES (NULL,'Kalkstein',9,'Kalkstein',FALSE,NULL);
INSERT INTO afu_geotope.gesteinsart (seq,iliCode,itfCode,dispName,inactive,description) VALUES (NULL,'Oolithischer_Kalkstein',10,'Oolithischer Kalkstein',FALSE,NULL);
INSERT INTO afu_geotope.gesteinsart (seq,iliCode,itfCode,dispName,inactive,description) VALUES (NULL,'Quelltuff',11,'Quelltuff',FALSE,NULL);
INSERT INTO afu_geotope.gesteinsart (seq,iliCode,itfCode,dispName,inactive,description) VALUES (NULL,'Chloritgneis',12,'Chloritgneis',FALSE,NULL);
INSERT INTO afu_geotope.gesteinsart (seq,iliCode,itfCode,dispName,inactive,description) VALUES (NULL,'Gips',13,'Gips',FALSE,NULL);
INSERT INTO afu_geotope.gesteinsart (seq,iliCode,itfCode,dispName,inactive,description) VALUES (NULL,'Dolomit',14,'Dolomit',FALSE,NULL);
INSERT INTO afu_geotope.gesteinsart (seq,iliCode,itfCode,dispName,inactive,description) VALUES (NULL,'Arollagneis',15,'Arollagneis',FALSE,NULL);
INSERT INTO afu_geotope.gesteinsart (seq,iliCode,itfCode,dispName,inactive,description) VALUES (NULL,'Muschelsandstein',16,'Muschelsandstein',FALSE,NULL);
INSERT INTO afu_geotope.gesteinsart (seq,iliCode,itfCode,dispName,inactive,description) VALUES (NULL,'Kalkglimmerschiefer',17,'Kalkglimmerschiefer',FALSE,NULL);
INSERT INTO afu_geotope.gesteinsart (seq,iliCode,itfCode,dispName,inactive,description) VALUES (NULL,'Boluston',18,'Boluston',FALSE,NULL);
INSERT INTO afu_geotope.gesteinsart (seq,iliCode,itfCode,dispName,inactive,description) VALUES (NULL,'Bohnerz',19,'Bohnerz',FALSE,NULL);
INSERT INTO afu_geotope.gesteinsart (seq,iliCode,itfCode,dispName,inactive,description) VALUES (NULL,'Sparit',20,'Sparit',FALSE,NULL);
INSERT INTO afu_geotope.gesteinsart (seq,iliCode,itfCode,dispName,inactive,description) VALUES (NULL,'Quarzitischer_Aplit',21,'Quarzitischer Aplit',FALSE,NULL);
INSERT INTO afu_geotope.gesteinsart (seq,iliCode,itfCode,dispName,inactive,description) VALUES (NULL,'Smaragdit_Saussurit_Gabbro',22,'Smaragdit Saussurit Gabbro',FALSE,NULL);
INSERT INTO afu_geotope.gesteinsart (seq,iliCode,itfCode,dispName,inactive,description) VALUES (NULL,'Kalktuff',23,'Kalktuff',FALSE,NULL);
INSERT INTO afu_geotope.gesteinsart (seq,iliCode,itfCode,dispName,inactive,description) VALUES (NULL,'Quarzit',24,'Quarzit',FALSE,NULL);
INSERT INTO afu_geotope.gesteinsart (seq,iliCode,itfCode,dispName,inactive,description) VALUES (NULL,'Echinodermen',25,'Echinodermen',FALSE,NULL);
INSERT INTO afu_geotope.gesteinsart (seq,iliCode,itfCode,dispName,inactive,description) VALUES (NULL,'Hornblendegneis',26,'Hornblendegneis',FALSE,NULL);
INSERT INTO afu_geotope.gesteinsart (seq,iliCode,itfCode,dispName,inactive,description) VALUES (NULL,'Stromatolith',27,'Stromatolith',FALSE,NULL);
INSERT INTO afu_geotope.gesteinsart (seq,iliCode,itfCode,dispName,inactive,description) VALUES (NULL,'Gneis_allgemein',28,'Gneis allgemein',FALSE,NULL);
INSERT INTO afu_geotope.gesteinsart (seq,iliCode,itfCode,dispName,inactive,description) VALUES (NULL,'Schotter',29,'Schotter',FALSE,NULL);
INSERT INTO afu_geotope.landschaftstyp (seq,iliCode,itfCode,dispName,inactive,description) VALUES (NULL,'Glaziallandschaft',0,'Glaziallandschaft',FALSE,NULL);
INSERT INTO afu_geotope.landschaftstyp (seq,iliCode,itfCode,dispName,inactive,description) VALUES (NULL,'Moraene',1,'Moraene',FALSE,NULL);
INSERT INTO afu_geotope.landschaftstyp (seq,iliCode,itfCode,dispName,inactive,description) VALUES (NULL,'Schlucht_Klus_Halbklus',2,'Schlucht Klus Halbklus',FALSE,NULL);
INSERT INTO afu_geotope.landschaftstyp (seq,iliCode,itfCode,dispName,inactive,description) VALUES (NULL,'Fluviallandschaft',3,'Fluviallandschaft',FALSE,NULL);
INSERT INTO afu_geotope.landschaftstyp (seq,iliCode,itfCode,dispName,inactive,description) VALUES (NULL,'Karstlandschaft',4,'Karstlandschaft',FALSE,NULL);
INSERT INTO afu_geotope.landschaftstyp (seq,iliCode,itfCode,dispName,inactive,description) VALUES (NULL,'Gebirgslandschaft',5,'Gebirgslandschaft',FALSE,NULL);
INSERT INTO afu_geotope.landschaftstyp (seq,iliCode,itfCode,dispName,inactive,description) VALUES (NULL,'unbekannt',6,'unbekannt',FALSE,NULL);
INSERT INTO afu_geotope.landschaftstyp (seq,iliCode,itfCode,dispName,inactive,description) VALUES (NULL,'Tal',7,'Tal',FALSE,NULL);
INSERT INTO afu_geotope.geologisches_system (seq,iliCode,itfCode,dispName,inactive,description) VALUES (NULL,'Tertiaer',0,'Tertiaer',FALSE,NULL);
INSERT INTO afu_geotope.geologisches_system (seq,iliCode,itfCode,dispName,inactive,description) VALUES (NULL,'unbekannt',1,'unbekannt',FALSE,NULL);
INSERT INTO afu_geotope.geologisches_system (seq,iliCode,itfCode,dispName,inactive,description) VALUES (NULL,'Quartaer',2,'Quartaer',FALSE,NULL);
INSERT INTO afu_geotope.geologisches_system (seq,iliCode,itfCode,dispName,inactive,description) VALUES (NULL,'Trias',3,'Trias',FALSE,NULL);
INSERT INTO afu_geotope.geologisches_system (seq,iliCode,itfCode,dispName,inactive,description) VALUES (NULL,'Jura',4,'Jura',FALSE,NULL);
INSERT INTO afu_geotope.petrografie (seq,iliCode,itfCode,dispName,inactive,description) VALUES (NULL,'Kalkstein',0,'Kalkstein',FALSE,NULL);
INSERT INTO afu_geotope.petrografie (seq,iliCode,itfCode,dispName,inactive,description) VALUES (NULL,'oolithischer_Kalkstein',1,'oolithischer Kalkstein',FALSE,NULL);
INSERT INTO afu_geotope.petrografie (seq,iliCode,itfCode,dispName,inactive,description) VALUES (NULL,'mergeliger_Kalkstein',2,'mergeliger Kalkstein',FALSE,NULL);
INSERT INTO afu_geotope.petrografie (seq,iliCode,itfCode,dispName,inactive,description) VALUES (NULL,'sandiger_Kalkstein',3,'sandiger Kalkstein',FALSE,NULL);
INSERT INTO afu_geotope.petrografie (seq,iliCode,itfCode,dispName,inactive,description) VALUES (NULL,'Sandstein',4,'Sandstein',FALSE,NULL);
INSERT INTO afu_geotope.petrografie (seq,iliCode,itfCode,dispName,inactive,description) VALUES (NULL,'mergeliger_Sandstein',5,'mergeliger Sandstein',FALSE,NULL);
INSERT INTO afu_geotope.petrografie (seq,iliCode,itfCode,dispName,inactive,description) VALUES (NULL,'Tonstein',6,'Tonstein',FALSE,NULL);
INSERT INTO afu_geotope.petrografie (seq,iliCode,itfCode,dispName,inactive,description) VALUES (NULL,'Hochterrassenschotter',7,'Hochterrassenschotter',FALSE,NULL);
INSERT INTO afu_geotope.petrografie (seq,iliCode,itfCode,dispName,inactive,description) VALUES (NULL,'Niederterrassenschotter',8,'Niederterrassenschotter',FALSE,NULL);
INSERT INTO afu_geotope.petrografie (seq,iliCode,itfCode,dispName,inactive,description) VALUES (NULL,'Konglomerat',9,'Konglomerat',FALSE,NULL);
INSERT INTO afu_geotope.petrografie (seq,iliCode,itfCode,dispName,inactive,description) VALUES (NULL,'Serizitgneis',10,'Serizitgneis',FALSE,NULL);
INSERT INTO afu_geotope.petrografie (seq,iliCode,itfCode,dispName,inactive,description) VALUES (NULL,'unbekannt',11,'unbekannt',FALSE,NULL);
INSERT INTO afu_geotope.petrografie (seq,iliCode,itfCode,dispName,inactive,description) VALUES (NULL,'Amphibolit',12,'Amphibolit',FALSE,NULL);
INSERT INTO afu_geotope.petrografie (seq,iliCode,itfCode,dispName,inactive,description) VALUES (NULL,'Biotitgneis',13,'Biotitgneis',FALSE,NULL);
INSERT INTO afu_geotope.petrografie (seq,iliCode,itfCode,dispName,inactive,description) VALUES (NULL,'Chloritgneis',14,'Chloritgneis',FALSE,NULL);
INSERT INTO afu_geotope.petrografie (seq,iliCode,itfCode,dispName,inactive,description) VALUES (NULL,'Granit',15,'Granit',FALSE,NULL);
INSERT INTO afu_geotope.petrografie (seq,iliCode,itfCode,dispName,inactive,description) VALUES (NULL,'Dolomit',16,'Dolomit',FALSE,NULL);
INSERT INTO afu_geotope.petrografie (seq,iliCode,itfCode,dispName,inactive,description) VALUES (NULL,'Gips',17,'Gips',FALSE,NULL);
INSERT INTO afu_geotope.petrografie (seq,iliCode,itfCode,dispName,inactive,description) VALUES (NULL,'Anhydrit',18,'Anhydrit',FALSE,NULL);
INSERT INTO afu_geotope.petrografie (seq,iliCode,itfCode,dispName,inactive,description) VALUES (NULL,'Boluston',19,'Boluston',FALSE,NULL);
INSERT INTO afu_geotope.petrografie (seq,iliCode,itfCode,dispName,inactive,description) VALUES (NULL,'Bohnerz',20,'Bohnerz',FALSE,NULL);
INSERT INTO afu_geotope.petrografie (seq,iliCode,itfCode,dispName,inactive,description) VALUES (NULL,'Quarzit',21,'Quarzit',FALSE,NULL);
INSERT INTO afu_geotope.petrografie (seq,iliCode,itfCode,dispName,inactive,description) VALUES (NULL,'Wechsellagerung',22,'Wechsellagerung',FALSE,NULL);
INSERT INTO afu_geotope.petrografie (seq,iliCode,itfCode,dispName,inactive,description) VALUES (NULL,'Quarzitischer_Aplit',23,'Quarzitischer Aplit',FALSE,NULL);
INSERT INTO afu_geotope.petrografie (seq,iliCode,itfCode,dispName,inactive,description) VALUES (NULL,'Arollagneis',24,'Arollagneis',FALSE,NULL);
INSERT INTO afu_geotope.petrografie (seq,iliCode,itfCode,dispName,inactive,description) VALUES (NULL,'Smaragdit_Saussurit_Gabbro',25,'Smaragdit Saussurit Gabbro',FALSE,NULL);
INSERT INTO afu_geotope.petrografie (seq,iliCode,itfCode,dispName,inactive,description) VALUES (NULL,'Hornblendegneis',26,'Hornblendegneis',FALSE,NULL);
INSERT INTO afu_geotope.petrografie (seq,iliCode,itfCode,dispName,inactive,description) VALUES (NULL,'Penninischer_Gruenschiefer',27,'Penninischer Gruenschiefer',FALSE,NULL);
INSERT INTO afu_geotope.petrografie (seq,iliCode,itfCode,dispName,inactive,description) VALUES (NULL,'Vallorcine_Konglomerat',28,'Vallorcine Konglomerat',FALSE,NULL);
INSERT INTO afu_geotope.petrografie (seq,iliCode,itfCode,dispName,inactive,description) VALUES (NULL,'Schotter',29,'Schotter',FALSE,NULL);
INSERT INTO afu_geotope.petrografie (seq,iliCode,itfCode,dispName,inactive,description) VALUES (NULL,'Hornblendegranit',30,'Hornblendegranit',FALSE,NULL);
INSERT INTO afu_geotope.petrografie (seq,iliCode,itfCode,dispName,inactive,description) VALUES (NULL,'Casanaschiefer',31,'Casanaschiefer',FALSE,NULL);
INSERT INTO afu_geotope.petrografie (seq,iliCode,itfCode,dispName,inactive,description) VALUES (NULL,'Gneis_allgemein',32,'Gneis allgemein',FALSE,NULL);
INSERT INTO afu_geotope.petrografie (seq,iliCode,itfCode,dispName,inactive,description) VALUES (NULL,'Kalk_Glimmerschiefer',33,'Kalk Glimmerschiefer',FALSE,NULL);
INSERT INTO afu_geotope.oberflaechenform_aufschluss (seq,iliCode,itfCode,dispName,inactive,description) VALUES (NULL,'Abbaustelle',0,'Abbaustelle',FALSE,NULL);
INSERT INTO afu_geotope.oberflaechenform_aufschluss (seq,iliCode,itfCode,dispName,inactive,description) VALUES (NULL,'Harnisch',1,'Harnisch',FALSE,NULL);
INSERT INTO afu_geotope.oberflaechenform_aufschluss (seq,iliCode,itfCode,dispName,inactive,description) VALUES (NULL,'Tongrube',2,'Tongrube',FALSE,NULL);
INSERT INTO afu_geotope.oberflaechenform_aufschluss (seq,iliCode,itfCode,dispName,inactive,description) VALUES (NULL,'Steinbruch',3,'Steinbruch',FALSE,NULL);
INSERT INTO afu_geotope.oberflaechenform_aufschluss (seq,iliCode,itfCode,dispName,inactive,description) VALUES (NULL,'Gipsgrube',4,'Gipsgrube',FALSE,NULL);
INSERT INTO afu_geotope.oberflaechenform_aufschluss (seq,iliCode,itfCode,dispName,inactive,description) VALUES (NULL,'Aufschluss',5,'Aufschluss',FALSE,NULL);
INSERT INTO afu_geotope.oberflaechenform_aufschluss (seq,iliCode,itfCode,dispName,inactive,description) VALUES (NULL,'Abraumhalde',6,'Abraumhalde',FALSE,NULL);
INSERT INTO afu_geotope.oberflaechenform_aufschluss (seq,iliCode,itfCode,dispName,inactive,description) VALUES (NULL,'tektonische_Struktur',7,'tektonische Struktur',FALSE,NULL);
INSERT INTO afu_geotope.dokumententyp (seq,iliCode,itfCode,dispName,inactive,description) VALUES (NULL,'Literatur',0,'Literatur',FALSE,NULL);
INSERT INTO afu_geotope.dokumententyp (seq,iliCode,itfCode,dispName,inactive,description) VALUES (NULL,'Bericht',1,'Bericht',FALSE,NULL);
INSERT INTO afu_geotope.dokumententyp (seq,iliCode,itfCode,dispName,inactive,description) VALUES (NULL,'Foto',2,'Foto',FALSE,NULL);
INSERT INTO afu_geotope.dokumententyp (seq,iliCode,itfCode,dispName,inactive,description) VALUES (NULL,'RRB',3,'RRB',FALSE,NULL);
INSERT INTO afu_geotope.oberflaechenform_landschaftsform (seq,iliCode,itfCode,dispName,inactive,description) VALUES (NULL,'Antiklinale',0,'Antiklinale',FALSE,NULL);
INSERT INTO afu_geotope.oberflaechenform_landschaftsform (seq,iliCode,itfCode,dispName,inactive,description) VALUES (NULL,'Bacheinschnitt',1,'Bacheinschnitt',FALSE,NULL);
INSERT INTO afu_geotope.oberflaechenform_landschaftsform (seq,iliCode,itfCode,dispName,inactive,description) VALUES (NULL,'Blockstrom',2,'Blockstrom',FALSE,NULL);
INSERT INTO afu_geotope.oberflaechenform_landschaftsform (seq,iliCode,itfCode,dispName,inactive,description) VALUES (NULL,'Doline',3,'Doline',FALSE,NULL);
INSERT INTO afu_geotope.oberflaechenform_landschaftsform (seq,iliCode,itfCode,dispName,inactive,description) VALUES (NULL,'Drumlin',4,'Drumlin',FALSE,NULL);
INSERT INTO afu_geotope.oberflaechenform_landschaftsform (seq,iliCode,itfCode,dispName,inactive,description) VALUES (NULL,'Felswand',5,'Felswand',FALSE,NULL);
INSERT INTO afu_geotope.oberflaechenform_landschaftsform (seq,iliCode,itfCode,dispName,inactive,description) VALUES (NULL,'Grundmoraene',6,'Grundmoraene',FALSE,NULL);
INSERT INTO afu_geotope.oberflaechenform_landschaftsform (seq,iliCode,itfCode,dispName,inactive,description) VALUES (NULL,'Klus',7,'Klus',FALSE,NULL);
INSERT INTO afu_geotope.oberflaechenform_landschaftsform (seq,iliCode,itfCode,dispName,inactive,description) VALUES (NULL,'Kolk',8,'Kolk',FALSE,NULL);
INSERT INTO afu_geotope.oberflaechenform_landschaftsform (seq,iliCode,itfCode,dispName,inactive,description) VALUES (NULL,'Moraene',9,'Moraene',FALSE,NULL);
INSERT INTO afu_geotope.oberflaechenform_landschaftsform (seq,iliCode,itfCode,dispName,inactive,description) VALUES (NULL,'See',10,'See',FALSE,NULL);
INSERT INTO afu_geotope.oberflaechenform_landschaftsform (seq,iliCode,itfCode,dispName,inactive,description) VALUES (NULL,'Mulde',11,'Mulde',FALSE,NULL);
INSERT INTO afu_geotope.oberflaechenform_landschaftsform (seq,iliCode,itfCode,dispName,inactive,description) VALUES (NULL,'Nackental',12,'Nackental',FALSE,NULL);
INSERT INTO afu_geotope.oberflaechenform_landschaftsform (seq,iliCode,itfCode,dispName,inactive,description) VALUES (NULL,'Prallhang',13,'Prallhang',FALSE,NULL);
INSERT INTO afu_geotope.oberflaechenform_landschaftsform (seq,iliCode,itfCode,dispName,inactive,description) VALUES (NULL,'Seitenmoraene',14,'Seitenmoraene',FALSE,NULL);
INSERT INTO afu_geotope.oberflaechenform_landschaftsform (seq,iliCode,itfCode,dispName,inactive,description) VALUES (NULL,'Trockental',15,'Trockental',FALSE,NULL);
INSERT INTO afu_geotope.oberflaechenform_landschaftsform (seq,iliCode,itfCode,dispName,inactive,description) VALUES (NULL,'Gesteinszacken',16,'Gesteinszacken',FALSE,NULL);
INSERT INTO afu_geotope.oberflaechenform_landschaftsform (seq,iliCode,itfCode,dispName,inactive,description) VALUES (NULL,'Hochterrasse',17,'Hochterrasse',FALSE,NULL);
INSERT INTO afu_geotope.oberflaechenform_landschaftsform (seq,iliCode,itfCode,dispName,inactive,description) VALUES (NULL,'Dolinenreihe',18,'Dolinenreihe',FALSE,NULL);
INSERT INTO afu_geotope.oberflaechenform_landschaftsform (seq,iliCode,itfCode,dispName,inactive,description) VALUES (NULL,'Pinge',19,'Pinge',FALSE,NULL);
INSERT INTO afu_geotope.oberflaechenform_landschaftsform (seq,iliCode,itfCode,dispName,inactive,description) VALUES (NULL,'Klippe',20,'Klippe',FALSE,NULL);
INSERT INTO afu_geotope.oberflaechenform_landschaftsform (seq,iliCode,itfCode,dispName,inactive,description) VALUES (NULL,'Glaziallandschaft',21,'Glaziallandschaft',FALSE,NULL);
INSERT INTO afu_geotope.oberflaechenform_landschaftsform (seq,iliCode,itfCode,dispName,inactive,description) VALUES (NULL,'Gletschermuehle',22,'Gletschermuehle',FALSE,NULL);
INSERT INTO afu_geotope.oberflaechenform_landschaftsform (seq,iliCode,itfCode,dispName,inactive,description) VALUES (NULL,'tektonische_Struktur',23,'tektonische Struktur',FALSE,NULL);
INSERT INTO afu_geotope.oberflaechenform_landschaftsform (seq,iliCode,itfCode,dispName,inactive,description) VALUES (NULL,'Wasserfall',24,'Wasserfall',FALSE,NULL);
INSERT INTO afu_geotope.oberflaechenform_landschaftsform (seq,iliCode,itfCode,dispName,inactive,description) VALUES (NULL,'Halbklus',25,'Halbklus',FALSE,NULL);
INSERT INTO afu_geotope.oberflaechenform_landschaftsform (seq,iliCode,itfCode,dispName,inactive,description) VALUES (NULL,'Landschaft',26,'Landschaft',FALSE,NULL);
INSERT INTO afu_geotope.oberflaechenform_landschaftsform (seq,iliCode,itfCode,dispName,inactive,description) VALUES (NULL,'Altarm',27,'Altarm',FALSE,NULL);
INSERT INTO afu_geotope.oberflaechenform_landschaftsform (seq,iliCode,itfCode,dispName,inactive,description) VALUES (NULL,'Aue',28,'Aue',FALSE,NULL);
INSERT INTO afu_geotope.oberflaechenform_landschaftsform (seq,iliCode,itfCode,dispName,inactive,description) VALUES (NULL,'Bergsturzlandschaft',29,'Bergsturzlandschaft',FALSE,NULL);
INSERT INTO afu_geotope.oberflaechenform_landschaftsform (seq,iliCode,itfCode,dispName,inactive,description) VALUES (NULL,'Sackungslandschaft',30,'Sackungslandschaft',FALSE,NULL);
INSERT INTO afu_geotope.oberflaechenform_landschaftsform (seq,iliCode,itfCode,dispName,inactive,description) VALUES (NULL,'Erratiker',31,'Erratiker',FALSE,NULL);
INSERT INTO afu_geotope.oberflaechenform_landschaftsform (seq,iliCode,itfCode,dispName,inactive,description) VALUES (NULL,'unbekannt',32,'unbekannt',FALSE,NULL);
INSERT INTO afu_geotope.oberflaechenform_landschaftsform (seq,iliCode,itfCode,dispName,inactive,description) VALUES (NULL,'Rutschlandschaft',33,'Rutschlandschaft',FALSE,NULL);
INSERT INTO afu_geotope.petrografie_erratiker (seq,iliCode,itfCode,dispName,inactive,description) VALUES (NULL,'Kalk_Glimmerschiefer',0,'Kalk Glimmerschiefer',FALSE,NULL);
INSERT INTO afu_geotope.petrografie_erratiker (seq,iliCode,itfCode,dispName,inactive,description) VALUES (NULL,'Casanaschiefer_Ton_Talk_Glimmerschiefer',1,'Casanaschiefer Ton Talk Glimmerschiefer',FALSE,NULL);
INSERT INTO afu_geotope.petrografie_erratiker (seq,iliCode,itfCode,dispName,inactive,description) VALUES (NULL,'Hornblendegranit',2,'Hornblendegranit',FALSE,NULL);
INSERT INTO afu_geotope.petrografie_erratiker (seq,iliCode,itfCode,dispName,inactive,description) VALUES (NULL,'Schotter',3,'Schotter',FALSE,NULL);
INSERT INTO afu_geotope.petrografie_erratiker (seq,iliCode,itfCode,dispName,inactive,description) VALUES (NULL,'Vallorcine_Konglomerat',4,'Vallorcine Konglomerat',FALSE,NULL);
INSERT INTO afu_geotope.petrografie_erratiker (seq,iliCode,itfCode,dispName,inactive,description) VALUES (NULL,'Penninischer_Gruenschiefer',5,'Penninischer Gruenschiefer',FALSE,NULL);
INSERT INTO afu_geotope.petrografie_erratiker (seq,iliCode,itfCode,dispName,inactive,description) VALUES (NULL,'Hornblendegneis',6,'Hornblendegneis',FALSE,NULL);
INSERT INTO afu_geotope.petrografie_erratiker (seq,iliCode,itfCode,dispName,inactive,description) VALUES (NULL,'Smaragdit_Saussurit_Gabbro',7,'Smaragdit Saussurit Gabbro',FALSE,NULL);
INSERT INTO afu_geotope.petrografie_erratiker (seq,iliCode,itfCode,dispName,inactive,description) VALUES (NULL,'Arollagneis',8,'Arollagneis',FALSE,NULL);
INSERT INTO afu_geotope.petrografie_erratiker (seq,iliCode,itfCode,dispName,inactive,description) VALUES (NULL,'Quarzitischer_Aplit',9,'Quarzitischer Aplit',FALSE,NULL);
INSERT INTO afu_geotope.petrografie_erratiker (seq,iliCode,itfCode,dispName,inactive,description) VALUES (NULL,'Quarzit',10,'Quarzit',FALSE,NULL);
INSERT INTO afu_geotope.petrografie_erratiker (seq,iliCode,itfCode,dispName,inactive,description) VALUES (NULL,'Granit',11,'Granit',FALSE,NULL);
INSERT INTO afu_geotope.petrografie_erratiker (seq,iliCode,itfCode,dispName,inactive,description) VALUES (NULL,'Chloritgneis',12,'Chloritgneis',FALSE,NULL);
INSERT INTO afu_geotope.petrografie_erratiker (seq,iliCode,itfCode,dispName,inactive,description) VALUES (NULL,'Biotitgneis',13,'Biotitgneis',FALSE,NULL);
INSERT INTO afu_geotope.petrografie_erratiker (seq,iliCode,itfCode,dispName,inactive,description) VALUES (NULL,'Amphibolit',14,'Amphibolit',FALSE,NULL);
INSERT INTO afu_geotope.petrografie_erratiker (seq,iliCode,itfCode,dispName,inactive,description) VALUES (NULL,'unbekannt',15,'unbekannt',FALSE,NULL);
INSERT INTO afu_geotope.petrografie_erratiker (seq,iliCode,itfCode,dispName,inactive,description) VALUES (NULL,'Serizitgneis',16,'Serizitgneis',FALSE,NULL);
INSERT INTO afu_geotope.petrografie_erratiker (seq,iliCode,itfCode,dispName,inactive,description) VALUES (NULL,'Konglomerat',17,'Konglomerat',FALSE,NULL);
INSERT INTO afu_geotope.petrografie_erratiker (seq,iliCode,itfCode,dispName,inactive,description) VALUES (NULL,'Gneis_allgemein',18,'Gneis allgemein',FALSE,NULL);
INSERT INTO afu_geotope.petrografie_erratiker (seq,iliCode,itfCode,dispName,inactive,description) VALUES (NULL,'Kalkstein',19,'Kalkstein',FALSE,NULL);
INSERT INTO afu_geotope.geologische_stufe (seq,iliCode,itfCode,dispName,inactive,description) VALUES (NULL,'Aalenien',0,'Aalenien',FALSE,NULL);
INSERT INTO afu_geotope.geologische_stufe (seq,iliCode,itfCode,dispName,inactive,description) VALUES (NULL,'Bajocien',1,'Bajocien',FALSE,NULL);
INSERT INTO afu_geotope.geologische_stufe (seq,iliCode,itfCode,dispName,inactive,description) VALUES (NULL,'Bathonien',2,'Bathonien',FALSE,NULL);
INSERT INTO afu_geotope.geologische_stufe (seq,iliCode,itfCode,dispName,inactive,description) VALUES (NULL,'Callovien',3,'Callovien',FALSE,NULL);
INSERT INTO afu_geotope.geologische_stufe (seq,iliCode,itfCode,dispName,inactive,description) VALUES (NULL,'Hettangien',4,'Hettangien',FALSE,NULL);
INSERT INTO afu_geotope.geologische_stufe (seq,iliCode,itfCode,dispName,inactive,description) VALUES (NULL,'Sinemurien_Pliensbachien',5,'Sinemurien Pliensbachien',FALSE,NULL);
INSERT INTO afu_geotope.geologische_stufe (seq,iliCode,itfCode,dispName,inactive,description) VALUES (NULL,'Toarcien',6,'Toarcien',FALSE,NULL);
INSERT INTO afu_geotope.geologische_stufe (seq,iliCode,itfCode,dispName,inactive,description) VALUES (NULL,'Argovien',7,'Argovien',FALSE,NULL);
INSERT INTO afu_geotope.geologische_stufe (seq,iliCode,itfCode,dispName,inactive,description) VALUES (NULL,'Rauracien',8,'Rauracien',FALSE,NULL);
INSERT INTO afu_geotope.geologische_stufe (seq,iliCode,itfCode,dispName,inactive,description) VALUES (NULL,'Oxfordien',9,'Oxfordien',FALSE,NULL);
INSERT INTO afu_geotope.geologische_stufe (seq,iliCode,itfCode,dispName,inactive,description) VALUES (NULL,'Sequanien',10,'Sequanien',FALSE,NULL);
INSERT INTO afu_geotope.geologische_stufe (seq,iliCode,itfCode,dispName,inactive,description) VALUES (NULL,'Bartonien',11,'Bartonien',FALSE,NULL);
INSERT INTO afu_geotope.geologische_stufe (seq,iliCode,itfCode,dispName,inactive,description) VALUES (NULL,'Lutetien',12,'Lutetien',FALSE,NULL);
INSERT INTO afu_geotope.geologische_stufe (seq,iliCode,itfCode,dispName,inactive,description) VALUES (NULL,'Priabonien',13,'Priabonien',FALSE,NULL);
INSERT INTO afu_geotope.geologische_stufe (seq,iliCode,itfCode,dispName,inactive,description) VALUES (NULL,'Aquitanien',14,'Aquitanien',FALSE,NULL);
INSERT INTO afu_geotope.geologische_stufe (seq,iliCode,itfCode,dispName,inactive,description) VALUES (NULL,'Burdigalien_OMM',15,'Burdigalien OMM',FALSE,NULL);
INSERT INTO afu_geotope.geologische_stufe (seq,iliCode,itfCode,dispName,inactive,description) VALUES (NULL,'Helvetien_OMM',16,'Helvetien OMM',FALSE,NULL);
INSERT INTO afu_geotope.geologische_stufe (seq,iliCode,itfCode,dispName,inactive,description) VALUES (NULL,'Sarmatien_OSM',17,'Sarmatien OSM',FALSE,NULL);
INSERT INTO afu_geotope.geologische_stufe (seq,iliCode,itfCode,dispName,inactive,description) VALUES (NULL,'Tortonien_OSM',18,'Tortonien OSM',FALSE,NULL);
INSERT INTO afu_geotope.geologische_stufe (seq,iliCode,itfCode,dispName,inactive,description) VALUES (NULL,'Chattien_USM',19,'Chattien USM',FALSE,NULL);
INSERT INTO afu_geotope.geologische_stufe (seq,iliCode,itfCode,dispName,inactive,description) VALUES (NULL,'Rupelien_UMM',20,'Rupelien UMM',FALSE,NULL);
INSERT INTO afu_geotope.geologische_stufe (seq,iliCode,itfCode,dispName,inactive,description) VALUES (NULL,'Stampien_UMM_USM',21,'Stampien UMM USM',FALSE,NULL);
INSERT INTO afu_geotope.geologische_stufe (seq,iliCode,itfCode,dispName,inactive,description) VALUES (NULL,'Danien',22,'Danien',FALSE,NULL);
INSERT INTO afu_geotope.geologische_stufe (seq,iliCode,itfCode,dispName,inactive,description) VALUES (NULL,'Selandien',23,'Selandien',FALSE,NULL);
INSERT INTO afu_geotope.geologische_stufe (seq,iliCode,itfCode,dispName,inactive,description) VALUES (NULL,'Thanetien',24,'Thanetien',FALSE,NULL);
INSERT INTO afu_geotope.geologische_stufe (seq,iliCode,itfCode,dispName,inactive,description) VALUES (NULL,'Mittlerer_Unterer_Buntsandstein',25,'Mittlerer Unterer Buntsandstein',FALSE,NULL);
INSERT INTO afu_geotope.geologische_stufe (seq,iliCode,itfCode,dispName,inactive,description) VALUES (NULL,'Oberer_Buntsandstein',26,'Oberer Buntsandstein',FALSE,NULL);
INSERT INTO afu_geotope.geologische_stufe (seq,iliCode,itfCode,dispName,inactive,description) VALUES (NULL,'Mittlerer_Keuper',27,'Mittlerer Keuper',FALSE,NULL);
INSERT INTO afu_geotope.geologische_stufe (seq,iliCode,itfCode,dispName,inactive,description) VALUES (NULL,'Oberer_Keuper',28,'Oberer Keuper',FALSE,NULL);
INSERT INTO afu_geotope.geologische_stufe (seq,iliCode,itfCode,dispName,inactive,description) VALUES (NULL,'Unterer_Keuper',29,'Unterer Keuper',FALSE,NULL);
INSERT INTO afu_geotope.geologische_stufe (seq,iliCode,itfCode,dispName,inactive,description) VALUES (NULL,'Mittlerer_Muschelkalk',30,'Mittlerer Muschelkalk',FALSE,NULL);
INSERT INTO afu_geotope.geologische_stufe (seq,iliCode,itfCode,dispName,inactive,description) VALUES (NULL,'Oberer_Muschelkalk',31,'Oberer Muschelkalk',FALSE,NULL);
INSERT INTO afu_geotope.geologische_stufe (seq,iliCode,itfCode,dispName,inactive,description) VALUES (NULL,'Unterer_Muschelkalk',32,'Unterer Muschelkalk',FALSE,NULL);
INSERT INTO afu_geotope.geologische_stufe (seq,iliCode,itfCode,dispName,inactive,description) VALUES (NULL,'Eem_Warmzeit',33,'Eem Warmzeit',FALSE,NULL);
INSERT INTO afu_geotope.geologische_stufe (seq,iliCode,itfCode,dispName,inactive,description) VALUES (NULL,'Guenz_Vergletscherung',34,'Guenz Vergletscherung',FALSE,NULL);
INSERT INTO afu_geotope.geologische_stufe (seq,iliCode,itfCode,dispName,inactive,description) VALUES (NULL,'Holstein_Warmzeit',35,'Holstein Warmzeit',FALSE,NULL);
INSERT INTO afu_geotope.geologische_stufe (seq,iliCode,itfCode,dispName,inactive,description) VALUES (NULL,'Mindel_Vergletscherung',36,'Mindel Vergletscherung',FALSE,NULL);
INSERT INTO afu_geotope.geologische_stufe (seq,iliCode,itfCode,dispName,inactive,description) VALUES (NULL,'Riss_Vergletscherung',37,'Riss Vergletscherung',FALSE,NULL);
INSERT INTO afu_geotope.geologische_stufe (seq,iliCode,itfCode,dispName,inactive,description) VALUES (NULL,'Wuerm_Vergletscherung',38,'Wuerm Vergletscherung',FALSE,NULL);
INSERT INTO afu_geotope.geologische_stufe (seq,iliCode,itfCode,dispName,inactive,description) VALUES (NULL,'unbekannt',39,'unbekannt',FALSE,NULL);
INSERT INTO afu_geotope.geologische_stufe (seq,iliCode,itfCode,dispName,inactive,description) VALUES (NULL,'undifferenziert',40,'undifferenziert',FALSE,NULL);
INSERT INTO afu_geotope.geologische_stufe (seq,iliCode,itfCode,dispName,inactive,description) VALUES (NULL,'Latdorfien_Sannoisien',41,'Latdorfien Sannoisien',FALSE,NULL);
INSERT INTO afu_geotope.geologische_stufe (seq,iliCode,itfCode,dispName,inactive,description) VALUES (NULL,'Kimmeridgien',42,'Kimmeridgien',FALSE,NULL);
INSERT INTO afu_geotope.geologische_stufe (seq,iliCode,itfCode,dispName,inactive,description) VALUES (NULL,'Zanclien',43,'Zanclien',FALSE,NULL);
INSERT INTO afu_geotope.geologische_stufe (seq,iliCode,itfCode,dispName,inactive,description) VALUES (NULL,'Piacenzien',44,'Piacenzien',FALSE,NULL);
INSERT INTO afu_geotope.geologische_stufe (seq,iliCode,itfCode,dispName,inactive,description) VALUES (NULL,'Portlandien',45,'Portlandien',FALSE,NULL);
INSERT INTO afu_geotope.geologische_serie (seq,iliCode,itfCode,dispName,inactive,description) VALUES (NULL,'Dogger',0,'Dogger',FALSE,NULL);
INSERT INTO afu_geotope.geologische_serie (seq,iliCode,itfCode,dispName,inactive,description) VALUES (NULL,'Lias',1,'Lias',FALSE,NULL);
INSERT INTO afu_geotope.geologische_serie (seq,iliCode,itfCode,dispName,inactive,description) VALUES (NULL,'Malm',2,'Malm',FALSE,NULL);
INSERT INTO afu_geotope.geologische_serie (seq,iliCode,itfCode,dispName,inactive,description) VALUES (NULL,'Eozaen',3,'Eozaen',FALSE,NULL);
INSERT INTO afu_geotope.geologische_serie (seq,iliCode,itfCode,dispName,inactive,description) VALUES (NULL,'Miozaen',4,'Miozaen',FALSE,NULL);
INSERT INTO afu_geotope.geologische_serie (seq,iliCode,itfCode,dispName,inactive,description) VALUES (NULL,'Oligozaen',5,'Oligozaen',FALSE,NULL);
INSERT INTO afu_geotope.geologische_serie (seq,iliCode,itfCode,dispName,inactive,description) VALUES (NULL,'Palaeozaen',6,'Palaeozaen',FALSE,NULL);
INSERT INTO afu_geotope.geologische_serie (seq,iliCode,itfCode,dispName,inactive,description) VALUES (NULL,'Pliozaen',7,'Pliozaen',FALSE,NULL);
INSERT INTO afu_geotope.geologische_serie (seq,iliCode,itfCode,dispName,inactive,description) VALUES (NULL,'Bundsandstein',8,'Bundsandstein',FALSE,NULL);
INSERT INTO afu_geotope.geologische_serie (seq,iliCode,itfCode,dispName,inactive,description) VALUES (NULL,'Keuper',9,'Keuper',FALSE,NULL);
INSERT INTO afu_geotope.geologische_serie (seq,iliCode,itfCode,dispName,inactive,description) VALUES (NULL,'Muschelkalk',10,'Muschelkalk',FALSE,NULL);
INSERT INTO afu_geotope.geologische_serie (seq,iliCode,itfCode,dispName,inactive,description) VALUES (NULL,'Holozaen',11,'Holozaen',FALSE,NULL);
INSERT INTO afu_geotope.geologische_serie (seq,iliCode,itfCode,dispName,inactive,description) VALUES (NULL,'Pleistozaen',12,'Pleistozaen',FALSE,NULL);
INSERT INTO afu_geotope.geologische_serie (seq,iliCode,itfCode,dispName,inactive,description) VALUES (NULL,'unbekannt',13,'unbekannt',FALSE,NULL);
INSERT INTO afu_geotope.zustand (seq,iliCode,itfCode,dispName,inactive,description) VALUES (NULL,'nicht_beeintraechtigt',0,'nicht beeintraechtigt',FALSE,NULL);
INSERT INTO afu_geotope.zustand (seq,iliCode,itfCode,dispName,inactive,description) VALUES (NULL,'gering_beeintraechtigt',1,'gering beeintraechtigt',FALSE,NULL);
INSERT INTO afu_geotope.zustand (seq,iliCode,itfCode,dispName,inactive,description) VALUES (NULL,'stark_beeintraechtigt',2,'stark beeintraechtigt',FALSE,NULL);
INSERT INTO afu_geotope.zustand (seq,iliCode,itfCode,dispName,inactive,description) VALUES (NULL,'zerstoert',3,'zerstoert',FALSE,NULL);
INSERT INTO afu_geotope.zustand (seq,iliCode,itfCode,dispName,inactive,description) VALUES (NULL,'unbekannt',4,'unbekannt',FALSE,NULL);
INSERT INTO afu_geotope.anthropogene_gefaehrdung (seq,iliCode,itfCode,dispName,inactive,description) VALUES (NULL,'unbekannt',0,'unbekannt',FALSE,NULL);
INSERT INTO afu_geotope.anthropogene_gefaehrdung (seq,iliCode,itfCode,dispName,inactive,description) VALUES (NULL,'keine',1,'keine',FALSE,NULL);
INSERT INTO afu_geotope.anthropogene_gefaehrdung (seq,iliCode,itfCode,dispName,inactive,description) VALUES (NULL,'gering',2,'gering',FALSE,NULL);
INSERT INTO afu_geotope.anthropogene_gefaehrdung (seq,iliCode,itfCode,dispName,inactive,description) VALUES (NULL,'erheblich',3,'erheblich',FALSE,NULL);
INSERT INTO afu_geotope.anthropogene_gefaehrdung (seq,iliCode,itfCode,dispName,inactive,description) VALUES (NULL,'akut',4,'akut',FALSE,NULL);
INSERT INTO afu_geotope.bedeutung (seq,iliCode,itfCode,dispName,inactive,description) VALUES (NULL,'unbekannt',0,'unbekannt',FALSE,NULL);
INSERT INTO afu_geotope.bedeutung (seq,iliCode,itfCode,dispName,inactive,description) VALUES (NULL,'national',1,'national',FALSE,NULL);
INSERT INTO afu_geotope.bedeutung (seq,iliCode,itfCode,dispName,inactive,description) VALUES (NULL,'regional',2,'regional',FALSE,NULL);
INSERT INTO afu_geotope.bedeutung (seq,iliCode,itfCode,dispName,inactive,description) VALUES (NULL,'lokal',3,'lokal',FALSE,NULL);
INSERT INTO afu_geotope.rechtsstatus (seq,iliCode,itfCode,dispName,inactive,description) VALUES (NULL,'inKraft',0,'inKraft',FALSE,NULL);
INSERT INTO afu_geotope.rechtsstatus (seq,iliCode,itfCode,dispName,inactive,description) VALUES (NULL,'laufendeAenderung',1,'laufendeAenderung',FALSE,NULL);
INSERT INTO afu_geotope.T_ILI2DB_COLUMN_PROP (tablename,subtype,columnname,tag,setting) VALUES ('geotope_aufschluss',NULL,'geologische_schicht_von','ch.ehi.ili2db.foreignKey','lithostratigrphie_geologische_schicht');
INSERT INTO afu_geotope.T_ILI2DB_COLUMN_PROP (tablename,subtype,columnname,tag,setting) VALUES ('geotope_fundstelle_grabung_fachbereich',NULL,'fundstelle_grabung','ch.ehi.ili2db.foreignKey','geotope_fundstelle_grabung');
INSERT INTO afu_geotope.T_ILI2DB_COLUMN_PROP (tablename,subtype,columnname,tag,setting) VALUES ('geotope_aufschluss_fachbereich',NULL,'fachbereich','ch.ehi.ili2db.foreignKey','geotope_fachbereich');
INSERT INTO afu_geotope.T_ILI2DB_COLUMN_PROP (tablename,subtype,columnname,tag,setting) VALUES ('geotope_aufschluss',NULL,'geologisches_system_von','ch.ehi.ili2db.foreignKey','lithostratigrphie_geologisches_system');
INSERT INTO afu_geotope.T_ILI2DB_COLUMN_PROP (tablename,subtype,columnname,tag,setting) VALUES ('geotope_hoehle_dokument',NULL,'dokument','ch.ehi.ili2db.foreignKey','geotope_dokument');
INSERT INTO afu_geotope.T_ILI2DB_COLUMN_PROP (tablename,subtype,columnname,tag,setting) VALUES ('geotope_fundstelle_grabung',NULL,'beschreibung','ch.ehi.ili2db.textKind','MTEXT');
INSERT INTO afu_geotope.T_ILI2DB_COLUMN_PROP (tablename,subtype,columnname,tag,setting) VALUES ('geotope_fundstelle_grabung',NULL,'geologische_serie_bis','ch.ehi.ili2db.foreignKey','lithostratigrphie_geologische_serie');
INSERT INTO afu_geotope.T_ILI2DB_COLUMN_PROP (tablename,subtype,columnname,tag,setting) VALUES ('geotope_aufschluss',NULL,'geologische_schicht_bis','ch.ehi.ili2db.foreignKey','lithostratigrphie_geologische_schicht');
INSERT INTO afu_geotope.T_ILI2DB_COLUMN_PROP (tablename,subtype,columnname,tag,setting) VALUES ('geotope_fundstelle_grabung_dokument',NULL,'fundstelle_grabung','ch.ehi.ili2db.foreignKey','geotope_fundstelle_grabung');
INSERT INTO afu_geotope.T_ILI2DB_COLUMN_PROP (tablename,subtype,columnname,tag,setting) VALUES ('geotope_landform_fachbereich',NULL,'landform','ch.ehi.ili2db.foreignKey','geotope_landschaftsform');
INSERT INTO afu_geotope.T_ILI2DB_COLUMN_PROP (tablename,subtype,columnname,tag,setting) VALUES ('geotope_erratiker',NULL,'zustaendige_stelle','ch.ehi.ili2db.foreignKey','geotope_zustaendige_stelle');
INSERT INTO afu_geotope.T_ILI2DB_COLUMN_PROP (tablename,subtype,columnname,tag,setting) VALUES ('geotope_fundstelle_grabung',NULL,'geometrie','ch.ehi.ili2db.c1Max','2870000.000');
INSERT INTO afu_geotope.T_ILI2DB_COLUMN_PROP (tablename,subtype,columnname,tag,setting) VALUES ('geotope_fundstelle_grabung',NULL,'geometrie','ch.ehi.ili2db.c1Min','2460000.000');
INSERT INTO afu_geotope.T_ILI2DB_COLUMN_PROP (tablename,subtype,columnname,tag,setting) VALUES ('geotope_fundstelle_grabung',NULL,'geometrie','ch.ehi.ili2db.coordDimension','2');
INSERT INTO afu_geotope.T_ILI2DB_COLUMN_PROP (tablename,subtype,columnname,tag,setting) VALUES ('geotope_fundstelle_grabung',NULL,'geometrie','ch.ehi.ili2db.c2Max','1310000.000');
INSERT INTO afu_geotope.T_ILI2DB_COLUMN_PROP (tablename,subtype,columnname,tag,setting) VALUES ('geotope_fundstelle_grabung',NULL,'geometrie','ch.ehi.ili2db.geomType','POINT');
INSERT INTO afu_geotope.T_ILI2DB_COLUMN_PROP (tablename,subtype,columnname,tag,setting) VALUES ('geotope_fundstelle_grabung',NULL,'geometrie','ch.ehi.ili2db.c2Min','1045000.000');
INSERT INTO afu_geotope.T_ILI2DB_COLUMN_PROP (tablename,subtype,columnname,tag,setting) VALUES ('geotope_fundstelle_grabung',NULL,'geometrie','ch.ehi.ili2db.srid','2056');
INSERT INTO afu_geotope.T_ILI2DB_COLUMN_PROP (tablename,subtype,columnname,tag,setting) VALUES ('geotope_fundstelle_grabung',NULL,'geologische_serie_von','ch.ehi.ili2db.foreignKey','lithostratigrphie_geologische_serie');
INSERT INTO afu_geotope.T_ILI2DB_COLUMN_PROP (tablename,subtype,columnname,tag,setting) VALUES ('geotope_quelle',NULL,'zustaendige_stelle','ch.ehi.ili2db.foreignKey','geotope_zustaendige_stelle');
INSERT INTO afu_geotope.T_ILI2DB_COLUMN_PROP (tablename,subtype,columnname,tag,setting) VALUES ('geotope_aufschluss',NULL,'geologische_stufe_bis','ch.ehi.ili2db.foreignKey','lithostratigrphie_geologische_stufe');
INSERT INTO afu_geotope.T_ILI2DB_COLUMN_PROP (tablename,subtype,columnname,tag,setting) VALUES ('geotope_aufschluss',NULL,'geologische_serie_bis','ch.ehi.ili2db.foreignKey','lithostratigrphie_geologische_serie');
INSERT INTO afu_geotope.T_ILI2DB_COLUMN_PROP (tablename,subtype,columnname,tag,setting) VALUES ('geotope_landschaftsform',NULL,'zustaendige_stelle','ch.ehi.ili2db.foreignKey','geotope_zustaendige_stelle');
INSERT INTO afu_geotope.T_ILI2DB_COLUMN_PROP (tablename,subtype,columnname,tag,setting) VALUES ('geotope_landform_dokument',NULL,'landform','ch.ehi.ili2db.foreignKey','geotope_landschaftsform');
INSERT INTO afu_geotope.T_ILI2DB_COLUMN_PROP (tablename,subtype,columnname,tag,setting) VALUES ('geotope_hoehle_dokument',NULL,'hoehle','ch.ehi.ili2db.foreignKey','geotope_hoehle');
INSERT INTO afu_geotope.T_ILI2DB_COLUMN_PROP (tablename,subtype,columnname,tag,setting) VALUES ('geotope_erratiker_dokument',NULL,'dokument','ch.ehi.ili2db.foreignKey','geotope_dokument');
INSERT INTO afu_geotope.T_ILI2DB_COLUMN_PROP (tablename,subtype,columnname,tag,setting) VALUES ('geotope_quelle',NULL,'beschreibung','ch.ehi.ili2db.textKind','MTEXT');
INSERT INTO afu_geotope.T_ILI2DB_COLUMN_PROP (tablename,subtype,columnname,tag,setting) VALUES ('geotope_quelle',NULL,'geometrie','ch.ehi.ili2db.c1Max','2870000.000');
INSERT INTO afu_geotope.T_ILI2DB_COLUMN_PROP (tablename,subtype,columnname,tag,setting) VALUES ('geotope_quelle',NULL,'geometrie','ch.ehi.ili2db.c1Min','2460000.000');
INSERT INTO afu_geotope.T_ILI2DB_COLUMN_PROP (tablename,subtype,columnname,tag,setting) VALUES ('geotope_quelle',NULL,'geometrie','ch.ehi.ili2db.coordDimension','2');
INSERT INTO afu_geotope.T_ILI2DB_COLUMN_PROP (tablename,subtype,columnname,tag,setting) VALUES ('geotope_quelle',NULL,'geometrie','ch.ehi.ili2db.c2Max','1310000.000');
INSERT INTO afu_geotope.T_ILI2DB_COLUMN_PROP (tablename,subtype,columnname,tag,setting) VALUES ('geotope_quelle',NULL,'geometrie','ch.ehi.ili2db.geomType','POINT');
INSERT INTO afu_geotope.T_ILI2DB_COLUMN_PROP (tablename,subtype,columnname,tag,setting) VALUES ('geotope_quelle',NULL,'geometrie','ch.ehi.ili2db.c2Min','1045000.000');
INSERT INTO afu_geotope.T_ILI2DB_COLUMN_PROP (tablename,subtype,columnname,tag,setting) VALUES ('geotope_quelle',NULL,'geometrie','ch.ehi.ili2db.srid','2056');
INSERT INTO afu_geotope.T_ILI2DB_COLUMN_PROP (tablename,subtype,columnname,tag,setting) VALUES ('geotope_landschaftsform',NULL,'geometrie','ch.ehi.ili2db.c1Max','2870000.000');
INSERT INTO afu_geotope.T_ILI2DB_COLUMN_PROP (tablename,subtype,columnname,tag,setting) VALUES ('geotope_landschaftsform',NULL,'geometrie','ch.ehi.ili2db.c1Min','2460000.000');
INSERT INTO afu_geotope.T_ILI2DB_COLUMN_PROP (tablename,subtype,columnname,tag,setting) VALUES ('geotope_landschaftsform',NULL,'geometrie','ch.ehi.ili2db.coordDimension','2');
INSERT INTO afu_geotope.T_ILI2DB_COLUMN_PROP (tablename,subtype,columnname,tag,setting) VALUES ('geotope_landschaftsform',NULL,'geometrie','ch.ehi.ili2db.c2Max','1310000.000');
INSERT INTO afu_geotope.T_ILI2DB_COLUMN_PROP (tablename,subtype,columnname,tag,setting) VALUES ('geotope_landschaftsform',NULL,'geometrie','ch.ehi.ili2db.geomType','MULTIPOLYGON');
INSERT INTO afu_geotope.T_ILI2DB_COLUMN_PROP (tablename,subtype,columnname,tag,setting) VALUES ('geotope_landschaftsform',NULL,'geometrie','ch.ehi.ili2db.c2Min','1045000.000');
INSERT INTO afu_geotope.T_ILI2DB_COLUMN_PROP (tablename,subtype,columnname,tag,setting) VALUES ('geotope_landschaftsform',NULL,'geometrie','ch.ehi.ili2db.srid','2056');
INSERT INTO afu_geotope.T_ILI2DB_COLUMN_PROP (tablename,subtype,columnname,tag,setting) VALUES ('geotope_erratiker_dokument',NULL,'erratiker','ch.ehi.ili2db.foreignKey','geotope_erratiker');
INSERT INTO afu_geotope.T_ILI2DB_COLUMN_PROP (tablename,subtype,columnname,tag,setting) VALUES ('geotope_hoehle',NULL,'zustaendige_stelle','ch.ehi.ili2db.foreignKey','geotope_zustaendige_stelle');
INSERT INTO afu_geotope.T_ILI2DB_COLUMN_PROP (tablename,subtype,columnname,tag,setting) VALUES ('geotope_aufschluss',NULL,'geologische_stufe_von','ch.ehi.ili2db.foreignKey','lithostratigrphie_geologische_stufe');
INSERT INTO afu_geotope.T_ILI2DB_COLUMN_PROP (tablename,subtype,columnname,tag,setting) VALUES ('geotope_aufschluss',NULL,'geologisches_system_bis','ch.ehi.ili2db.foreignKey','lithostratigrphie_geologisches_system');
INSERT INTO afu_geotope.T_ILI2DB_COLUMN_PROP (tablename,subtype,columnname,tag,setting) VALUES ('surfacestructure',NULL,'multisurface_surfaces','ch.ehi.ili2db.foreignKey','multisurface');
INSERT INTO afu_geotope.T_ILI2DB_COLUMN_PROP (tablename,subtype,columnname,tag,setting) VALUES ('geotope_aufschluss',NULL,'zustaendige_stelle','ch.ehi.ili2db.foreignKey','geotope_zustaendige_stelle');
INSERT INTO afu_geotope.T_ILI2DB_COLUMN_PROP (tablename,subtype,columnname,tag,setting) VALUES ('geotope_hoehle',NULL,'beschreibung','ch.ehi.ili2db.textKind','MTEXT');
INSERT INTO afu_geotope.T_ILI2DB_COLUMN_PROP (tablename,subtype,columnname,tag,setting) VALUES ('geotope_landschaftsform',NULL,'beschreibung','ch.ehi.ili2db.textKind','MTEXT');
INSERT INTO afu_geotope.T_ILI2DB_COLUMN_PROP (tablename,subtype,columnname,tag,setting) VALUES ('geotope_hoehle',NULL,'geometrie','ch.ehi.ili2db.c1Max','2870000.000');
INSERT INTO afu_geotope.T_ILI2DB_COLUMN_PROP (tablename,subtype,columnname,tag,setting) VALUES ('geotope_hoehle',NULL,'geometrie','ch.ehi.ili2db.c1Min','2460000.000');
INSERT INTO afu_geotope.T_ILI2DB_COLUMN_PROP (tablename,subtype,columnname,tag,setting) VALUES ('geotope_hoehle',NULL,'geometrie','ch.ehi.ili2db.coordDimension','2');
INSERT INTO afu_geotope.T_ILI2DB_COLUMN_PROP (tablename,subtype,columnname,tag,setting) VALUES ('geotope_hoehle',NULL,'geometrie','ch.ehi.ili2db.c2Max','1310000.000');
INSERT INTO afu_geotope.T_ILI2DB_COLUMN_PROP (tablename,subtype,columnname,tag,setting) VALUES ('geotope_hoehle',NULL,'geometrie','ch.ehi.ili2db.geomType','POINT');
INSERT INTO afu_geotope.T_ILI2DB_COLUMN_PROP (tablename,subtype,columnname,tag,setting) VALUES ('geotope_hoehle',NULL,'geometrie','ch.ehi.ili2db.c2Min','1045000.000');
INSERT INTO afu_geotope.T_ILI2DB_COLUMN_PROP (tablename,subtype,columnname,tag,setting) VALUES ('geotope_hoehle',NULL,'geometrie','ch.ehi.ili2db.srid','2056');
INSERT INTO afu_geotope.T_ILI2DB_COLUMN_PROP (tablename,subtype,columnname,tag,setting) VALUES ('geotope_quelle_fachbereich',NULL,'fachbereich','ch.ehi.ili2db.foreignKey','geotope_fachbereich');
INSERT INTO afu_geotope.T_ILI2DB_COLUMN_PROP (tablename,subtype,columnname,tag,setting) VALUES ('geotope_aufschluss',NULL,'geometrie','ch.ehi.ili2db.c1Max','2870000.000');
INSERT INTO afu_geotope.T_ILI2DB_COLUMN_PROP (tablename,subtype,columnname,tag,setting) VALUES ('geotope_aufschluss',NULL,'geometrie','ch.ehi.ili2db.c1Min','2460000.000');
INSERT INTO afu_geotope.T_ILI2DB_COLUMN_PROP (tablename,subtype,columnname,tag,setting) VALUES ('geotope_aufschluss',NULL,'geometrie','ch.ehi.ili2db.coordDimension','2');
INSERT INTO afu_geotope.T_ILI2DB_COLUMN_PROP (tablename,subtype,columnname,tag,setting) VALUES ('geotope_aufschluss',NULL,'geometrie','ch.ehi.ili2db.c2Max','1310000.000');
INSERT INTO afu_geotope.T_ILI2DB_COLUMN_PROP (tablename,subtype,columnname,tag,setting) VALUES ('geotope_aufschluss',NULL,'geometrie','ch.ehi.ili2db.geomType','MULTIPOLYGON');
INSERT INTO afu_geotope.T_ILI2DB_COLUMN_PROP (tablename,subtype,columnname,tag,setting) VALUES ('geotope_aufschluss',NULL,'geometrie','ch.ehi.ili2db.c2Min','1045000.000');
INSERT INTO afu_geotope.T_ILI2DB_COLUMN_PROP (tablename,subtype,columnname,tag,setting) VALUES ('geotope_aufschluss',NULL,'geometrie','ch.ehi.ili2db.srid','2056');
INSERT INTO afu_geotope.T_ILI2DB_COLUMN_PROP (tablename,subtype,columnname,tag,setting) VALUES ('geotope_fundstelle_grabung',NULL,'geologisches_system_bis','ch.ehi.ili2db.foreignKey','lithostratigrphie_geologisches_system');
INSERT INTO afu_geotope.T_ILI2DB_COLUMN_PROP (tablename,subtype,columnname,tag,setting) VALUES ('geotope_fundstelle_grabung',NULL,'geologische_stufe_von','ch.ehi.ili2db.foreignKey','lithostratigrphie_geologische_stufe');
INSERT INTO afu_geotope.T_ILI2DB_COLUMN_PROP (tablename,subtype,columnname,tag,setting) VALUES ('geotope_fundstelle_grabung_fachbereich',NULL,'fachbereich','ch.ehi.ili2db.foreignKey','geotope_fachbereich');
INSERT INTO afu_geotope.T_ILI2DB_COLUMN_PROP (tablename,subtype,columnname,tag,setting) VALUES ('geotope_erratiker',NULL,'geometrie','ch.ehi.ili2db.c1Max','2870000.000');
INSERT INTO afu_geotope.T_ILI2DB_COLUMN_PROP (tablename,subtype,columnname,tag,setting) VALUES ('geotope_erratiker',NULL,'geometrie','ch.ehi.ili2db.c1Min','2460000.000');
INSERT INTO afu_geotope.T_ILI2DB_COLUMN_PROP (tablename,subtype,columnname,tag,setting) VALUES ('geotope_erratiker',NULL,'geometrie','ch.ehi.ili2db.coordDimension','2');
INSERT INTO afu_geotope.T_ILI2DB_COLUMN_PROP (tablename,subtype,columnname,tag,setting) VALUES ('geotope_erratiker',NULL,'geometrie','ch.ehi.ili2db.c2Max','1310000.000');
INSERT INTO afu_geotope.T_ILI2DB_COLUMN_PROP (tablename,subtype,columnname,tag,setting) VALUES ('geotope_erratiker',NULL,'geometrie','ch.ehi.ili2db.geomType','POINT');
INSERT INTO afu_geotope.T_ILI2DB_COLUMN_PROP (tablename,subtype,columnname,tag,setting) VALUES ('geotope_erratiker',NULL,'geometrie','ch.ehi.ili2db.c2Min','1045000.000');
INSERT INTO afu_geotope.T_ILI2DB_COLUMN_PROP (tablename,subtype,columnname,tag,setting) VALUES ('geotope_erratiker',NULL,'geometrie','ch.ehi.ili2db.srid','2056');
INSERT INTO afu_geotope.T_ILI2DB_COLUMN_PROP (tablename,subtype,columnname,tag,setting) VALUES ('lithostratigrphie_geologische_stufe',NULL,'geologische_serie','ch.ehi.ili2db.foreignKey','lithostratigrphie_geologische_serie');
INSERT INTO afu_geotope.T_ILI2DB_COLUMN_PROP (tablename,subtype,columnname,tag,setting) VALUES ('surfacestructure',NULL,'surface','ch.ehi.ili2db.c1Max','2870000.000');
INSERT INTO afu_geotope.T_ILI2DB_COLUMN_PROP (tablename,subtype,columnname,tag,setting) VALUES ('surfacestructure',NULL,'surface','ch.ehi.ili2db.c1Min','2460000.000');
INSERT INTO afu_geotope.T_ILI2DB_COLUMN_PROP (tablename,subtype,columnname,tag,setting) VALUES ('surfacestructure',NULL,'surface','ch.ehi.ili2db.coordDimension','2');
INSERT INTO afu_geotope.T_ILI2DB_COLUMN_PROP (tablename,subtype,columnname,tag,setting) VALUES ('surfacestructure',NULL,'surface','ch.ehi.ili2db.c2Max','1310000.000');
INSERT INTO afu_geotope.T_ILI2DB_COLUMN_PROP (tablename,subtype,columnname,tag,setting) VALUES ('surfacestructure',NULL,'surface','ch.ehi.ili2db.geomType','POLYGON');
INSERT INTO afu_geotope.T_ILI2DB_COLUMN_PROP (tablename,subtype,columnname,tag,setting) VALUES ('surfacestructure',NULL,'surface','ch.ehi.ili2db.c2Min','1045000.000');
INSERT INTO afu_geotope.T_ILI2DB_COLUMN_PROP (tablename,subtype,columnname,tag,setting) VALUES ('surfacestructure',NULL,'surface','ch.ehi.ili2db.srid','2056');
INSERT INTO afu_geotope.T_ILI2DB_COLUMN_PROP (tablename,subtype,columnname,tag,setting) VALUES ('geotope_aufschluss_dokument',NULL,'aufschluss','ch.ehi.ili2db.foreignKey','geotope_aufschluss');
INSERT INTO afu_geotope.T_ILI2DB_COLUMN_PROP (tablename,subtype,columnname,tag,setting) VALUES ('geotope_landform_dokument',NULL,'dokument','ch.ehi.ili2db.foreignKey','geotope_dokument');
INSERT INTO afu_geotope.T_ILI2DB_COLUMN_PROP (tablename,subtype,columnname,tag,setting) VALUES ('geotope_erratiker_fachbereich',NULL,'fachbereich','ch.ehi.ili2db.foreignKey','geotope_fachbereich');
INSERT INTO afu_geotope.T_ILI2DB_COLUMN_PROP (tablename,subtype,columnname,tag,setting) VALUES ('geotope_fundstelle_grabung',NULL,'geologische_schicht_von','ch.ehi.ili2db.foreignKey','lithostratigrphie_geologische_schicht');
INSERT INTO afu_geotope.T_ILI2DB_COLUMN_PROP (tablename,subtype,columnname,tag,setting) VALUES ('lithostratigrphie_geologische_schicht',NULL,'geologische_stufe','ch.ehi.ili2db.foreignKey','lithostratigrphie_geologische_stufe');
INSERT INTO afu_geotope.T_ILI2DB_COLUMN_PROP (tablename,subtype,columnname,tag,setting) VALUES ('geotope_hoehle_fachbereich',NULL,'hoehle','ch.ehi.ili2db.foreignKey','geotope_hoehle');
INSERT INTO afu_geotope.T_ILI2DB_COLUMN_PROP (tablename,subtype,columnname,tag,setting) VALUES ('geotope_quelle_dokument',NULL,'dokument','ch.ehi.ili2db.foreignKey','geotope_dokument');
INSERT INTO afu_geotope.T_ILI2DB_COLUMN_PROP (tablename,subtype,columnname,tag,setting) VALUES ('geotope_aufschluss',NULL,'beschreibung','ch.ehi.ili2db.textKind','MTEXT');
INSERT INTO afu_geotope.T_ILI2DB_COLUMN_PROP (tablename,subtype,columnname,tag,setting) VALUES ('geotope_aufschluss',NULL,'geologische_serie_von','ch.ehi.ili2db.foreignKey','lithostratigrphie_geologische_serie');
INSERT INTO afu_geotope.T_ILI2DB_COLUMN_PROP (tablename,subtype,columnname,tag,setting) VALUES ('geotope_erratiker',NULL,'beschreibung','ch.ehi.ili2db.textKind','MTEXT');
INSERT INTO afu_geotope.T_ILI2DB_COLUMN_PROP (tablename,subtype,columnname,tag,setting) VALUES ('geotope_erratiker_fachbereich',NULL,'erratiker','ch.ehi.ili2db.foreignKey','geotope_erratiker');
INSERT INTO afu_geotope.T_ILI2DB_COLUMN_PROP (tablename,subtype,columnname,tag,setting) VALUES ('geotope_quelle_fachbereich',NULL,'quelle','ch.ehi.ili2db.foreignKey','geotope_quelle');
INSERT INTO afu_geotope.T_ILI2DB_COLUMN_PROP (tablename,subtype,columnname,tag,setting) VALUES ('geotope_quelle_dokument',NULL,'quelle','ch.ehi.ili2db.foreignKey','geotope_quelle');
INSERT INTO afu_geotope.T_ILI2DB_COLUMN_PROP (tablename,subtype,columnname,tag,setting) VALUES ('geotope_fundstelle_grabung',NULL,'geologisches_system_von','ch.ehi.ili2db.foreignKey','lithostratigrphie_geologisches_system');
INSERT INTO afu_geotope.T_ILI2DB_COLUMN_PROP (tablename,subtype,columnname,tag,setting) VALUES ('geotope_aufschluss_dokument',NULL,'dokument','ch.ehi.ili2db.foreignKey','geotope_dokument');
INSERT INTO afu_geotope.T_ILI2DB_COLUMN_PROP (tablename,subtype,columnname,tag,setting) VALUES ('geotope_hoehle_fachbereich',NULL,'fachbereich','ch.ehi.ili2db.foreignKey','geotope_fachbereich');
INSERT INTO afu_geotope.T_ILI2DB_COLUMN_PROP (tablename,subtype,columnname,tag,setting) VALUES ('geotope_aufschluss_fachbereich',NULL,'aufschluss','ch.ehi.ili2db.foreignKey','geotope_aufschluss');
INSERT INTO afu_geotope.T_ILI2DB_COLUMN_PROP (tablename,subtype,columnname,tag,setting) VALUES ('geotope_fundstelle_grabung_dokument',NULL,'dokument','ch.ehi.ili2db.foreignKey','geotope_dokument');
INSERT INTO afu_geotope.T_ILI2DB_COLUMN_PROP (tablename,subtype,columnname,tag,setting) VALUES ('geotope_landform_fachbereich',NULL,'fachbereich','ch.ehi.ili2db.foreignKey','geotope_fachbereich');
INSERT INTO afu_geotope.T_ILI2DB_COLUMN_PROP (tablename,subtype,columnname,tag,setting) VALUES ('lithostratigrphie_geologische_serie',NULL,'geologisches_system','ch.ehi.ili2db.foreignKey','lithostratigrphie_geologisches_system');
INSERT INTO afu_geotope.T_ILI2DB_COLUMN_PROP (tablename,subtype,columnname,tag,setting) VALUES ('geotope_fundstelle_grabung',NULL,'geologische_schicht_bis','ch.ehi.ili2db.foreignKey','lithostratigrphie_geologische_schicht');
INSERT INTO afu_geotope.T_ILI2DB_COLUMN_PROP (tablename,subtype,columnname,tag,setting) VALUES ('geotope_fundstelle_grabung',NULL,'zustaendige_stelle','ch.ehi.ili2db.foreignKey','geotope_zustaendige_stelle');
INSERT INTO afu_geotope.T_ILI2DB_COLUMN_PROP (tablename,subtype,columnname,tag,setting) VALUES ('geotope_fundstelle_grabung',NULL,'geologische_stufe_bis','ch.ehi.ili2db.foreignKey','lithostratigrphie_geologische_stufe');
INSERT INTO afu_geotope.T_ILI2DB_TABLE_PROP (tablename,tag,setting) VALUES ('anthropogene_gefaehrdung','ch.ehi.ili2db.tableKind','ENUM');
INSERT INTO afu_geotope.T_ILI2DB_TABLE_PROP (tablename,tag,setting) VALUES ('landschaftstyp','ch.ehi.ili2db.tableKind','ENUM');
INSERT INTO afu_geotope.T_ILI2DB_TABLE_PROP (tablename,tag,setting) VALUES ('schutzwuerdigkeit','ch.ehi.ili2db.tableKind','ENUM');
INSERT INTO afu_geotope.T_ILI2DB_TABLE_PROP (tablename,tag,setting) VALUES ('geotope_aufschluss','ch.ehi.ili2db.tableKind','CLASS');
INSERT INTO afu_geotope.T_ILI2DB_TABLE_PROP (tablename,tag,setting) VALUES ('geotope_hoehle_dokument','ch.ehi.ili2db.tableKind','ASSOCIATION');
INSERT INTO afu_geotope.T_ILI2DB_TABLE_PROP (tablename,tag,setting) VALUES ('geotope_quelle','ch.ehi.ili2db.tableKind','CLASS');
INSERT INTO afu_geotope.T_ILI2DB_TABLE_PROP (tablename,tag,setting) VALUES ('geotope_erratiker_fachbereich','ch.ehi.ili2db.tableKind','ASSOCIATION');
INSERT INTO afu_geotope.T_ILI2DB_TABLE_PROP (tablename,tag,setting) VALUES ('gesteinsart','ch.ehi.ili2db.tableKind','ENUM');
INSERT INTO afu_geotope.T_ILI2DB_TABLE_PROP (tablename,tag,setting) VALUES ('geologische_schicht','ch.ehi.ili2db.tableKind','ENUM');
INSERT INTO afu_geotope.T_ILI2DB_TABLE_PROP (tablename,tag,setting) VALUES ('oberflaechenform_aufschluss','ch.ehi.ili2db.tableKind','ENUM');
INSERT INTO afu_geotope.T_ILI2DB_TABLE_PROP (tablename,tag,setting) VALUES ('lithostratigrphie_geologische_stufe','ch.ehi.ili2db.tableKind','CLASS');
INSERT INTO afu_geotope.T_ILI2DB_TABLE_PROP (tablename,tag,setting) VALUES ('geotope_aufschluss_fachbereich','ch.ehi.ili2db.tableKind','ASSOCIATION');
INSERT INTO afu_geotope.T_ILI2DB_TABLE_PROP (tablename,tag,setting) VALUES ('lithostratigrphie_geologische_schicht','ch.ehi.ili2db.tableKind','CLASS');
INSERT INTO afu_geotope.T_ILI2DB_TABLE_PROP (tablename,tag,setting) VALUES ('geotope_zustaendige_stelle','ch.ehi.ili2db.tableKind','CLASS');
INSERT INTO afu_geotope.T_ILI2DB_TABLE_PROP (tablename,tag,setting) VALUES ('lithostratigrphie_geologisches_system','ch.ehi.ili2db.tableKind','CLASS');
INSERT INTO afu_geotope.T_ILI2DB_TABLE_PROP (tablename,tag,setting) VALUES ('oberflaechenform_landschaftsform','ch.ehi.ili2db.tableKind','ENUM');
INSERT INTO afu_geotope.T_ILI2DB_TABLE_PROP (tablename,tag,setting) VALUES ('geotope_aufschluss_dokument','ch.ehi.ili2db.tableKind','ASSOCIATION');
INSERT INTO afu_geotope.T_ILI2DB_TABLE_PROP (tablename,tag,setting) VALUES ('geotope_hoehle','ch.ehi.ili2db.tableKind','CLASS');
INSERT INTO afu_geotope.T_ILI2DB_TABLE_PROP (tablename,tag,setting) VALUES ('geotope_quelle_dokument','ch.ehi.ili2db.tableKind','ASSOCIATION');
INSERT INTO afu_geotope.T_ILI2DB_TABLE_PROP (tablename,tag,setting) VALUES ('geotope_fachbereich','ch.ehi.ili2db.tableKind','CLASS');
INSERT INTO afu_geotope.T_ILI2DB_TABLE_PROP (tablename,tag,setting) VALUES ('geotope_fundstelle_grabung_fachbereich','ch.ehi.ili2db.tableKind','ASSOCIATION');
INSERT INTO afu_geotope.T_ILI2DB_TABLE_PROP (tablename,tag,setting) VALUES ('geotope_landform_dokument','ch.ehi.ili2db.tableKind','ASSOCIATION');
INSERT INTO afu_geotope.T_ILI2DB_TABLE_PROP (tablename,tag,setting) VALUES ('geotope_dokument','ch.ehi.ili2db.tableKind','CLASS');
INSERT INTO afu_geotope.T_ILI2DB_TABLE_PROP (tablename,tag,setting) VALUES ('geotope_hoehle_fachbereich','ch.ehi.ili2db.tableKind','ASSOCIATION');
INSERT INTO afu_geotope.T_ILI2DB_TABLE_PROP (tablename,tag,setting) VALUES ('zustand','ch.ehi.ili2db.tableKind','ENUM');
INSERT INTO afu_geotope.T_ILI2DB_TABLE_PROP (tablename,tag,setting) VALUES ('geotope_quelle_fachbereich','ch.ehi.ili2db.tableKind','ASSOCIATION');
INSERT INTO afu_geotope.T_ILI2DB_TABLE_PROP (tablename,tag,setting) VALUES ('rechtsstatus','ch.ehi.ili2db.tableKind','ENUM');
INSERT INTO afu_geotope.T_ILI2DB_TABLE_PROP (tablename,tag,setting) VALUES ('geotope_fundstelle_grabung','ch.ehi.ili2db.tableKind','CLASS');
INSERT INTO afu_geotope.T_ILI2DB_TABLE_PROP (tablename,tag,setting) VALUES ('petrografie','ch.ehi.ili2db.tableKind','ENUM');
INSERT INTO afu_geotope.T_ILI2DB_TABLE_PROP (tablename,tag,setting) VALUES ('multisurface','ch.ehi.ili2db.tableKind','STRUCTURE');
INSERT INTO afu_geotope.T_ILI2DB_TABLE_PROP (tablename,tag,setting) VALUES ('geotope_landschaftsform','ch.ehi.ili2db.tableKind','CLASS');
INSERT INTO afu_geotope.T_ILI2DB_TABLE_PROP (tablename,tag,setting) VALUES ('geotope_erratiker_dokument','ch.ehi.ili2db.tableKind','ASSOCIATION');
INSERT INTO afu_geotope.T_ILI2DB_TABLE_PROP (tablename,tag,setting) VALUES ('eiszeit','ch.ehi.ili2db.tableKind','ENUM');
INSERT INTO afu_geotope.T_ILI2DB_TABLE_PROP (tablename,tag,setting) VALUES ('surfacestructure','ch.ehi.ili2db.tableKind','STRUCTURE');
INSERT INTO afu_geotope.T_ILI2DB_TABLE_PROP (tablename,tag,setting) VALUES ('petrografie_erratiker','ch.ehi.ili2db.tableKind','ENUM');
INSERT INTO afu_geotope.T_ILI2DB_TABLE_PROP (tablename,tag,setting) VALUES ('geowissenschaftlicher_wert','ch.ehi.ili2db.tableKind','ENUM');
INSERT INTO afu_geotope.T_ILI2DB_TABLE_PROP (tablename,tag,setting) VALUES ('geotope_erratiker','ch.ehi.ili2db.tableKind','CLASS');
INSERT INTO afu_geotope.T_ILI2DB_TABLE_PROP (tablename,tag,setting) VALUES ('geologische_serie','ch.ehi.ili2db.tableKind','ENUM');
INSERT INTO afu_geotope.T_ILI2DB_TABLE_PROP (tablename,tag,setting) VALUES ('bedeutung','ch.ehi.ili2db.tableKind','ENUM');
INSERT INTO afu_geotope.T_ILI2DB_TABLE_PROP (tablename,tag,setting) VALUES ('entstehung','ch.ehi.ili2db.tableKind','ENUM');
INSERT INTO afu_geotope.T_ILI2DB_TABLE_PROP (tablename,tag,setting) VALUES ('dokumententyp','ch.ehi.ili2db.tableKind','ENUM');
INSERT INTO afu_geotope.T_ILI2DB_TABLE_PROP (tablename,tag,setting) VALUES ('geologisches_system','ch.ehi.ili2db.tableKind','ENUM');
INSERT INTO afu_geotope.T_ILI2DB_TABLE_PROP (tablename,tag,setting) VALUES ('regionalgeologische_einheit','ch.ehi.ili2db.tableKind','ENUM');
INSERT INTO afu_geotope.T_ILI2DB_TABLE_PROP (tablename,tag,setting) VALUES ('geotope_landform_fachbereich','ch.ehi.ili2db.tableKind','ASSOCIATION');
INSERT INTO afu_geotope.T_ILI2DB_TABLE_PROP (tablename,tag,setting) VALUES ('geologische_stufe','ch.ehi.ili2db.tableKind','ENUM');
INSERT INTO afu_geotope.T_ILI2DB_TABLE_PROP (tablename,tag,setting) VALUES ('geotope_fundstelle_grabung_dokument','ch.ehi.ili2db.tableKind','ASSOCIATION');
INSERT INTO afu_geotope.T_ILI2DB_TABLE_PROP (tablename,tag,setting) VALUES ('lithostratigrphie_geologische_serie','ch.ehi.ili2db.tableKind','CLASS');
INSERT INTO afu_geotope.T_ILI2DB_MODEL (filename,iliversion,modelName,content,importDate) VALUES ('CoordSys-20151124.ili','2.3','CoordSys','!! File CoordSys.ili Release 2015-11-24

INTERLIS 2.3;

!! 2015-11-24 Cardinalities adapted (line 122, 123, 124, 132, 133, 134, 142, 143,
!!                                   148, 149, 163, 164, 168, 169, 206 and 207)
!!@precursorVersion = 2005-06-16

REFSYSTEM MODEL CoordSys (en) AT "http://www.interlis.ch/models"
  VERSION "2015-11-24" =

  UNIT
    Angle_Degree = 180 / PI [INTERLIS.rad];
    Angle_Minute = 1 / 60 [Angle_Degree];
    Angle_Second = 1 / 60 [Angle_Minute];

  STRUCTURE Angle_DMS_S =
    Degrees: -180 .. 180 CIRCULAR [Angle_Degree];
    CONTINUOUS SUBDIVISION Minutes: 0 .. 59 CIRCULAR [Angle_Minute];
    CONTINUOUS SUBDIVISION Seconds: 0.000 .. 59.999 CIRCULAR [Angle_Second];
  END Angle_DMS_S;

  DOMAIN
    Angle_DMS = FORMAT BASED ON Angle_DMS_S (Degrees ":" Minutes ":" Seconds);
    Angle_DMS_90 EXTENDS Angle_DMS = "-90:00:00.000" .. "90:00:00.000";


  TOPIC CoordsysTopic =

    !! Special space aspects to be referenced
    !! **************************************

    CLASS Ellipsoid EXTENDS INTERLIS.REFSYSTEM =
      EllipsoidAlias: TEXT*70;
      SemiMajorAxis: MANDATORY 6360000.0000 .. 6390000.0000 [INTERLIS.m];
      InverseFlattening: MANDATORY 0.00000000 .. 350.00000000;
      !! The inverse flattening 0 characterizes the 2-dim sphere
      Remarks: TEXT*70;
    END Ellipsoid;

    CLASS GravityModel EXTENDS INTERLIS.REFSYSTEM =
      GravityModAlias: TEXT*70;
      Definition: TEXT*70;
    END GravityModel;

    CLASS GeoidModel EXTENDS INTERLIS.REFSYSTEM =
      GeoidModAlias: TEXT*70;
      Definition: TEXT*70;
    END GeoidModel;


    !! Coordinate systems for geodetic purposes
    !! ****************************************

    STRUCTURE LengthAXIS EXTENDS INTERLIS.AXIS =
      ShortName: TEXT*12;
      Description: TEXT*255;
    PARAMETER
      Unit (EXTENDED): NUMERIC [INTERLIS.LENGTH];
    END LengthAXIS;

    STRUCTURE AngleAXIS EXTENDS INTERLIS.AXIS =
      ShortName: TEXT*12;
      Description: TEXT*255;
    PARAMETER
      Unit (EXTENDED): NUMERIC [INTERLIS.ANGLE];
    END AngleAXIS;

    CLASS GeoCartesian1D EXTENDS INTERLIS.COORDSYSTEM =
      Axis (EXTENDED): LIST {1} OF LengthAXIS;
    END GeoCartesian1D;

    CLASS GeoHeight EXTENDS GeoCartesian1D =
      System: MANDATORY (
        normal,
        orthometric,
        ellipsoidal,
        other);
      ReferenceHeight: MANDATORY -10000.000 .. +10000.000 [INTERLIS.m];
      ReferenceHeightDescr: TEXT*70;
    END GeoHeight;

    ASSOCIATION HeightEllips =
      GeoHeightRef -- {*} GeoHeight;
      EllipsoidRef -- {1} Ellipsoid;
    END HeightEllips;

    ASSOCIATION HeightGravit =
      GeoHeightRef -- {*} GeoHeight;
      GravityRef -- {1} GravityModel;
    END HeightGravit;

    ASSOCIATION HeightGeoid =
      GeoHeightRef -- {*} GeoHeight;
      GeoidRef -- {1} GeoidModel;
    END HeightGeoid;

    CLASS GeoCartesian2D EXTENDS INTERLIS.COORDSYSTEM =
      Definition: TEXT*70;
      Axis (EXTENDED): LIST {2} OF LengthAXIS;
    END GeoCartesian2D;

    CLASS GeoCartesian3D EXTENDS INTERLIS.COORDSYSTEM =
      Definition: TEXT*70;
      Axis (EXTENDED): LIST {3} OF LengthAXIS;
    END GeoCartesian3D;

    CLASS GeoEllipsoidal EXTENDS INTERLIS.COORDSYSTEM =
      Definition: TEXT*70;
      Axis (EXTENDED): LIST {2} OF AngleAXIS;
    END GeoEllipsoidal;

    ASSOCIATION EllCSEllips =
      GeoEllipsoidalRef -- {*} GeoEllipsoidal;
      EllipsoidRef -- {1} Ellipsoid;
    END EllCSEllips;


    !! Mappings between coordinate systems
    !! ***********************************

    ASSOCIATION ToGeoEllipsoidal =
      From -- {0..*} GeoCartesian3D;
      To -- {0..*} GeoEllipsoidal;
      ToHeight -- {0..*} GeoHeight;
    MANDATORY CONSTRAINT
      ToHeight -> System == #ellipsoidal;
    MANDATORY CONSTRAINT
      To -> EllipsoidRef -> Name == ToHeight -> EllipsoidRef -> Name;
    END ToGeoEllipsoidal;

    ASSOCIATION ToGeoCartesian3D =
      From2 -- {0..*} GeoEllipsoidal;
      FromHeight-- {0..*} GeoHeight;
      To3 -- {0..*} GeoCartesian3D;
    MANDATORY CONSTRAINT
      FromHeight -> System == #ellipsoidal;
    MANDATORY CONSTRAINT
      From2 -> EllipsoidRef -> Name == FromHeight -> EllipsoidRef -> Name;
    END ToGeoCartesian3D;

    ASSOCIATION BidirectGeoCartesian2D =
      From -- {0..*} GeoCartesian2D;
      To -- {0..*} GeoCartesian2D;
    END BidirectGeoCartesian2D;

    ASSOCIATION BidirectGeoCartesian3D =
      From -- {0..*} GeoCartesian3D;
      To2 -- {0..*} GeoCartesian3D;
      Precision: MANDATORY (
        exact,
        measure_based);
      ShiftAxis1: MANDATORY -10000.000 .. 10000.000 [INTERLIS.m];
      ShiftAxis2: MANDATORY -10000.000 .. 10000.000 [INTERLIS.m];
      ShiftAxis3: MANDATORY -10000.000 .. 10000.000 [INTERLIS.m];
      RotationAxis1: Angle_DMS_90;
      RotationAxis2: Angle_DMS_90;
      RotationAxis3: Angle_DMS_90;
      NewScale: 0.000001 .. 1000000.000000;
    END BidirectGeoCartesian3D;

    ASSOCIATION BidirectGeoEllipsoidal =
      From4 -- {0..*} GeoEllipsoidal;
      To4 -- {0..*} GeoEllipsoidal;
    END BidirectGeoEllipsoidal;

    ASSOCIATION MapProjection (ABSTRACT) =
      From5 -- {0..*} GeoEllipsoidal;
      To5 -- {0..*} GeoCartesian2D;
      FromCo1_FundPt: MANDATORY Angle_DMS_90;
      FromCo2_FundPt: MANDATORY Angle_DMS_90;
      ToCoord1_FundPt: MANDATORY -10000000 .. +10000000 [INTERLIS.m];
      ToCoord2_FundPt: MANDATORY -10000000 .. +10000000 [INTERLIS.m];
    END MapProjection;

    ASSOCIATION TransverseMercator EXTENDS MapProjection =
    END TransverseMercator;

    ASSOCIATION SwissProjection EXTENDS MapProjection =
      IntermFundP1: MANDATORY Angle_DMS_90;
      IntermFundP2: MANDATORY Angle_DMS_90;
    END SwissProjection;

    ASSOCIATION Mercator EXTENDS MapProjection =
    END Mercator;

    ASSOCIATION ObliqueMercator EXTENDS MapProjection =
    END ObliqueMercator;

    ASSOCIATION Lambert EXTENDS MapProjection =
    END Lambert;

    ASSOCIATION Polyconic EXTENDS MapProjection =
    END Polyconic;

    ASSOCIATION Albus EXTENDS MapProjection =
    END Albus;

    ASSOCIATION Azimutal EXTENDS MapProjection =
    END Azimutal;

    ASSOCIATION Stereographic EXTENDS MapProjection =
    END Stereographic;

    ASSOCIATION HeightConversion =
      FromHeight -- {0..*} GeoHeight;
      ToHeight -- {0..*} GeoHeight;
      Definition: TEXT*70;
    END HeightConversion;

  END CoordsysTopic;

END CoordSys.

','2020-07-22 13:58:58.182');
INSERT INTO afu_geotope.T_ILI2DB_MODEL (filename,iliversion,modelName,content,importDate) VALUES ('Units-20120220.ili','2.3','Units','!! File Units.ili Release 2012-02-20

INTERLIS 2.3;

!! 2012-02-20 definition of "Bar [bar]" corrected
!!@precursorVersion = 2005-06-06

CONTRACTED TYPE MODEL Units (en) AT "http://www.interlis.ch/models"
  VERSION "2012-02-20" =

  UNIT
    !! abstract Units
    Area (ABSTRACT) = (INTERLIS.LENGTH*INTERLIS.LENGTH);
    Volume (ABSTRACT) = (INTERLIS.LENGTH*INTERLIS.LENGTH*INTERLIS.LENGTH);
    Velocity (ABSTRACT) = (INTERLIS.LENGTH/INTERLIS.TIME);
    Acceleration (ABSTRACT) = (Velocity/INTERLIS.TIME);
    Force (ABSTRACT) = (INTERLIS.MASS*INTERLIS.LENGTH/INTERLIS.TIME/INTERLIS.TIME);
    Pressure (ABSTRACT) = (Force/Area);
    Energy (ABSTRACT) = (Force*INTERLIS.LENGTH);
    Power (ABSTRACT) = (Energy/INTERLIS.TIME);
    Electric_Potential (ABSTRACT) = (Power/INTERLIS.ELECTRIC_CURRENT);
    Frequency (ABSTRACT) = (INTERLIS.DIMENSIONLESS/INTERLIS.TIME);

    Millimeter [mm] = 0.001 [INTERLIS.m];
    Centimeter [cm] = 0.01 [INTERLIS.m];
    Decimeter [dm] = 0.1 [INTERLIS.m];
    Kilometer [km] = 1000 [INTERLIS.m];

    Square_Meter [m2] EXTENDS Area = (INTERLIS.m*INTERLIS.m);
    Cubic_Meter [m3] EXTENDS Volume = (INTERLIS.m*INTERLIS.m*INTERLIS.m);

    Minute [min] = 60 [INTERLIS.s];
    Hour [h] = 60 [min];
    Day [d] = 24 [h];

    Kilometer_per_Hour [kmh] EXTENDS Velocity = (km/h);
    Meter_per_Second [ms] = 3.6 [kmh];
    Newton [N] EXTENDS Force = (INTERLIS.kg*INTERLIS.m/INTERLIS.s/INTERLIS.s);
    Pascal [Pa] EXTENDS Pressure = (N/m2);
    Joule [J] EXTENDS Energy = (N*INTERLIS.m);
    Watt [W] EXTENDS Power = (J/INTERLIS.s);
    Volt [V] EXTENDS Electric_Potential = (W/INTERLIS.A);

    Inch [in] = 2.54 [cm];
    Foot [ft] = 0.3048 [INTERLIS.m];
    Mile [mi] = 1.609344 [km];

    Are [a] = 100 [m2];
    Hectare [ha] = 100 [a];
    Square_Kilometer [km2] = 100 [ha];
    Acre [acre] = 4046.873 [m2];

    Liter [L] = 1 / 1000 [m3];
    US_Gallon [USgal] = 3.785412 [L];

    Angle_Degree = 180 / PI [INTERLIS.rad];
    Angle_Minute = 1 / 60 [Angle_Degree];
    Angle_Second = 1 / 60 [Angle_Minute];

    Gon = 200 / PI [INTERLIS.rad];

    Gram [g] = 1 / 1000 [INTERLIS.kg];
    Ton [t] = 1000 [INTERLIS.kg];
    Pound [lb] = 0.4535924 [INTERLIS.kg];

    Calorie [cal] = 4.1868 [J];
    Kilowatt_Hour [kWh] = 0.36E7 [J];

    Horsepower = 746 [W];

    Techn_Atmosphere [at] = 98066.5 [Pa];
    Atmosphere [atm] = 101325 [Pa];
    Bar [bar] = 100000 [Pa];
    Millimeter_Mercury [mmHg] = 133.3224 [Pa];
    Torr = 133.3224 [Pa]; !! Torr = [mmHg]

    Decibel [dB] = FUNCTION // 10**(dB/20) * 0.00002 // [Pa];

    Degree_Celsius [oC] = FUNCTION // oC+273.15 // [INTERLIS.K];
    Degree_Fahrenheit [oF] = FUNCTION // (oF+459.67)/1.8 // [INTERLIS.K];

    CountedObjects EXTENDS INTERLIS.DIMENSIONLESS;

    Hertz [Hz] EXTENDS Frequency = (CountedObjects/INTERLIS.s);
    KiloHertz [KHz] = 1000 [Hz];
    MegaHertz [MHz] = 1000 [KHz];

    Percent = 0.01 [CountedObjects];
    Permille = 0.001 [CountedObjects];

    !! ISO 4217 Currency Abbreviation
    USDollar [USD] EXTENDS INTERLIS.MONEY;
    Euro [EUR] EXTENDS INTERLIS.MONEY;
    SwissFrancs [CHF] EXTENDS INTERLIS.MONEY;

END Units.

','2020-07-22 13:58:58.182');
INSERT INTO afu_geotope.T_ILI2DB_MODEL (filename,iliversion,modelName,content,importDate) VALUES ('SO_AFU_Geotope_20200312.ili','2.3','SO_AFU_Geotope_20200312{ GeometryCHLV95_V1}','INTERLIS 2.3;

/** !!------------------------------------------------------------------------------ 
 *  !! Version    | wer | Aenderung 
 *  !!------------------------------------------------------------------------------ 
 *  !! 2018-04-30 | AL  | Erstfassung 
 *  !! 2018-12-03 | NS  | Anpassungen gemaess Rueckmeldungen
 *  !! 2018-12-19 | NS  | Beschreibung vergroessert,
 *  !!                    Aufschluesse und Landschaftsform: Polygon zu Multipolygon
 *  !! 2018-12-19 | NS  | Tippfehler korrigiert
 *  !! 2019-01-03 | NS  | Enumeration geowissenschaftlicher_Wert korrigiert
 *  !! 2019-01-17 | NS  | Enumeration geologisches_System korrigiert,
 *  !!                    Topic Lithostratigraphie ergaenzt,
 *  !!                    OEREB optimiert 
 *  !! 2019-02-05 | NS  | Tippfehler korrigiert
 *  !! 2019-02-11 | NS  | zustaendige_Stelle in Klasse ausgelagert
 *  !! 2019-03-13 | NS  | weitere Schichten und Stufen hinzugefuegt,
 *  !!                    Gneis_allgemein bei Gesteinsart, Petrografie und Petrografie_Erratiker ergaenzt
 *  !!                    unbekannt bei Oberflaechenform_Landschaftsform ergaenzt,
 *  !!                    Nummer aus Class Geotop entfernt
 *  !! 2020-03-12 | MS  | INGESO_OID hinzugefuegt
 * !!==============================================================================
 */
!!@ technicalContact=agi@so.ch
MODEL SO_AFU_Geotope_20200312 (de)
AT "http://www.geo.so.ch/models/AFU"
VERSION "2020-03-12"  =
  IMPORTS GeometryCHLV95_V1;

  DOMAIN

    Bedeutung = (
      unbekannt,
      national,
      regional,
      lokal
    );

    Dokumententyp = (
      Literatur,
      Bericht,
      Foto,
      RRB
    );

    /** Name der Eiszeit
     */
    Eiszeit = (
      unbekannt,
      /** vor 115''000 - 10''000 Jahren
       */
      Wuerm,
      /** vor 300''000 - 130''000 Jahren
       */
      Riss,
      /** vor 460''000 - 400''000 Jahren
       */
      Mindel,
      /** vor 600''000 - 800''000 Jahren
       */
      Guenz
    );

    Oberflaechenform_Aufschluss = (
      Abbaustelle,
      Harnisch,
      Tongrube,
      Steinbruch,
      Gipsgrube,
      Aufschluss,
      Abraumhalde,
      tektonische_Struktur
    );

    Petrografie_Erratiker = (
      Kalk_Glimmerschiefer,
      Casanaschiefer_Ton_Talk_Glimmerschiefer,
      Hornblendegranit,
      Schotter,
      Vallorcine_Konglomerat,
      Penninischer_Gruenschiefer,
      Hornblendegneis,
      Smaragdit_Saussurit_Gabbro,
      Arollagneis,
      Quarzitischer_Aplit,
      Quarzit,
      Granit,
      Chloritgneis,
      Biotitgneis,
      Amphibolit,
      unbekannt,
      Serizitgneis,
      Konglomerat,
      Gneis_allgemein,
      Kalkstein
    );

    /** Rechtsstatus
     */
    Rechtsstatus = (
      inKraft,
      laufendeAenderung
    );

    geologische_Schicht = (
      Murchisonae_Schichten,
      Opalinuston,
      Blagdeni_Schichten,
      Humphriesi_Schichten,
      Unterer_Hauptrogenstein,
      Maeandrina_Schichten,
      Sowerbyi_Sauzei_Schichten,
      Ferrugineus_Oolith,
      Homomyen_Mergel,
      Movelier_Schichten,
      Oberer_Hauptrogenstein,
      Varians_Schichten,
      Anceps_Athleta_Schichten,
      Callovien_Ton,
      Dalle_nacree,
      Macrocephalus_Schichten,
      Insekten_Mergel,
      Arieten_Kalk,
      Opliqua_Spinatus_Schichten,
      Obtusus_Ton,
      Posidonien_Schiefer,
      Birmenstorfer_Schichten,
      Korallenkalk,
      Liesberg_Schichten,
      Rauracien_Oolith,
      Oxford_Mergel,
      Renggeri_Ton,
      Terrain_a_chailles,
      Effinger_Schichten,
      Humeralis_Schichten,
      Natica_Schichten,
      Verena_Schichten,
      Siderolithikum,
      OMM,
      OSM,
      USM,
      UMM,
      UMM_USM,
      Quarzsandsteine,
      Roet,
      Plattensandstein,
      Gansinger_Dolomit,
      Gipskeuper,
      Obere_Bunte_Mergel,
      Schilfsandstein,
      Untere_Bunte_Mergel,
      Rhaet,
      Lettenkohle,
      Anhydritgruppe,
      Dolomitzone,
      Salzlager,
      Sulfatzone,
      Hauptmuschelkalk,
      Plattenkalk,
      Trigonodus_Dolomit,
      Trochitenkalk,
      Orbicularis_Mergel,
      Wellendolomit,
      Wellenkalk,
      Wellengebirge,
      Hochterrasse,
      Grundmoraene,
      Niederterrasse,
      Sander,
      Seitenmoraene,
      U_Tal,
      unbekannt,
      undifferenziert,
      Vorbourg_Kalke,
      Erratiker,
      Moraene,
      Glaziallandschaft,
      Balsthaler_Formation,
      Wallmoraene,
      Holzflue_Schicht
    );

    geologische_Stufe = (
      Aalenien,
      Bajocien,
      Bathonien,
      Callovien,
      Hettangien,
      Sinemurien_Pliensbachien,
      Toarcien,
      Argovien,
      Rauracien,
      Oxfordien,
      Sequanien,
      Bartonien,
      Lutetien,
      Priabonien,
      Aquitanien,
      Burdigalien_OMM,
      Helvetien_OMM,
      Sarmatien_OSM,
      Tortonien_OSM,
      Chattien_USM,
      Rupelien_UMM,
      Stampien_UMM_USM,
      Danien,
      Selandien,
      Thanetien,
      Mittlerer_Unterer_Buntsandstein,
      Oberer_Buntsandstein,
      Mittlerer_Keuper,
      Oberer_Keuper,
      Unterer_Keuper,
      Mittlerer_Muschelkalk,
      Oberer_Muschelkalk,
      Unterer_Muschelkalk,
      Eem_Warmzeit,
      Guenz_Vergletscherung,
      Holstein_Warmzeit,
      Mindel_Vergletscherung,
      Riss_Vergletscherung,
      Wuerm_Vergletscherung,
      unbekannt,
      undifferenziert,
      Latdorfien_Sannoisien,
      Kimmeridgien,
      Zanclien,
      Piacenzien,
      Portlandien
    );

    geologisches_System = (
      Tertiaer,
      unbekannt,
      Quartaer,
      Trias,
      Jura
    );

    geologische_Serie = (
      Dogger,
      Lias,
      Malm,
      Eozaen,
      Miozaen,
      Oligozaen,
      Palaeozaen,
      Pliozaen,
      Bundsandstein,
      Keuper,
      Muschelkalk,
      Holozaen,
      Pleistozaen,
      unbekannt
    );

    Gesteinsart = (
      Granit,
      Mergel,
      Penninischer_Gruenschiefer,
      Porphyrischer_Granit,
      Sandstein,
      Ton,
      Vallorcine_Konglomerat,
      Wechsellagerung,
      unbekannt,
      Kalkstein,
      Oolithischer_Kalkstein,
      Quelltuff,
      Chloritgneis,
      Gips,
      Dolomit,
      Arollagneis,
      Muschelsandstein,
      Kalkglimmerschiefer,
      Boluston,
      Bohnerz,
      Sparit,
      Quarzitischer_Aplit,
      Smaragdit_Saussurit_Gabbro,
      Kalktuff,
      Quarzit,
      Echinodermen,
      Hornblendegneis,
      Stromatolith,
      Gneis_allgemein,
      Schotter
    );

  TOPIC Lithostratigraphie =

    /** Geologische Schicht/Formation (Lithostrati)
     */
    CLASS geologische_Schicht =
      /** Name der geologische Schicht
       */
      Bezeichnung : MANDATORY SO_AFU_Geotope_20200312.geologische_Schicht;
    END geologische_Schicht;

    /** Geologische Serie (Chronostrati)
     */
    CLASS geologische_Serie =
      /** Name der geologischen Serie
       */
      Bezeichnung : MANDATORY SO_AFU_Geotope_20200312.geologische_Serie;
    END geologische_Serie;

    /** Geologische Stufe (Chronostrati)
     */
    CLASS geologische_Stufe =
      /** Name der geologischen Stufe
       */
      Bezeichnung : MANDATORY SO_AFU_Geotope_20200312.geologische_Stufe;
    END geologische_Stufe;

    /** Geologisches System (Chronostrati)
     */
    CLASS geologisches_System =
      /** Name des geologischen Systems
       */
      Bezeichnung : MANDATORY SO_AFU_Geotope_20200312.geologisches_System;
    END geologisches_System;

    ASSOCIATION geologische_Serie_geologische_Stufe =
      /** Fremdschluessel zu geologische_Serie
       */
      geologische_Serie -- {1} geologische_Serie;
      /** Fremdschluessel zu geologische_Stufe
       */
      geologische_Stufe -- {0..*} geologische_Stufe;
    END geologische_Serie_geologische_Stufe;

    ASSOCIATION geologische_Stufe_geologische_Schicht =
      /** Fremdschluessel zu geologische_Stufe
       */
      geologische_Stufe -- {1} geologische_Stufe;
      /** Fremdschluessel zu geologische_Schicht
       */
      geologische_Schicht -- {0..*} geologische_Schicht;
    END geologische_Stufe_geologische_Schicht;

    ASSOCIATION geologisches_System_geologische_Serie =
      /** Fremdschluessel zu geologisches System
       */
      geologisches_System -- {1} geologisches_System;
      /** Fremdschluessel zu geologische_Serie
       */
      geologische_Serie -- {0..*} geologische_Serie;
    END geologisches_System_geologische_Serie;

  END Lithostratigraphie;

  DOMAIN

    Entstehung = (
      natuerlich,
      anthropogen,
      unbekannt
    );

    Oberflaechenform_Landschaftsform = (
      Antiklinale,
      Bacheinschnitt,
      Blockstrom,
      Doline,
      Drumlin,
      Felswand,
      Grundmoraene,
      Klus,
      Kolk,
      Moraene,
      See,
      Mulde,
      Nackental,
      Prallhang,
      Seitenmoraene,
      Trockental,
      Gesteinszacken,
      Hochterrasse,
      Dolinenreihe,
      Pinge,
      Klippe,
      Glaziallandschaft,
      Gletschermuehle,
      tektonische_Struktur,
      Wasserfall,
      Halbklus,
      Landschaft,
      Altarm,
      Aue,
      Bergsturzlandschaft,
      Sackungslandschaft,
      Erratiker,
      unbekannt,
      Rutschlandschaft
    );

    Petrografie = (
      Kalkstein,
      oolithischer_Kalkstein,
      mergeliger_Kalkstein,
      sandiger_Kalkstein,
      Sandstein,
      mergeliger_Sandstein,
      Tonstein,
      Hochterrassenschotter,
      Niederterrassenschotter,
      Konglomerat,
      Serizitgneis,
      unbekannt,
      Amphibolit,
      Biotitgneis,
      Chloritgneis,
      Granit,
      Dolomit,
      Gips,
      Anhydrit,
      Boluston,
      Bohnerz,
      Quarzit,
      Wechsellagerung,
      Quarzitischer_Aplit,
      Arollagneis,
      Smaragdit_Saussurit_Gabbro,
      Hornblendegneis,
      Penninischer_Gruenschiefer,
      Vallorcine_Konglomerat,
      Schotter,
      Hornblendegranit,
      Casanaschiefer,
      Gneis_allgemein,
      Kalk_Glimmerschiefer
    );

    Regionalgeologische_Einheit = (
      Tafeljura,
      Faltenjura,
      Mittelland,
      unbekannt
    );

    Schutzwuerdigkeit = (
      geschuetzt,
      schutzwuerdig,
      erhaltenswert,
      unbedeutend,
      unbekannt
    );

    /** Anthropogene Gefaehrdung
     */
    Anthropogene_Gefaehrdung = (
      unbekannt,
      keine,
      gering,
      erheblich,
      akut
    );

    geowissenschaftlicher_Wert = (
      geringwertig,
      bedeutend,
      wertvoll,
      besonders_wertvoll,
      unbekannt
    );

    Zustand = (
      nicht_beeintraechtigt,
      gering_beeintraechtigt,
      stark_beeintraechtigt,
      zerstoert,
      unbekannt
    );

    Landschaftstyp = (
      Glaziallandschaft,
      Moraene,
      Schlucht_Klus_Halbklus,
      Fluviallandschaft,
      Karstlandschaft,
      Gebirgslandschaft,
      unbekannt,
      Tal
    );

  TOPIC Geotope =
    OID AS INTERLIS.UUIDOID;
    DEPENDS ON SO_AFU_Geotope_20200312.Lithostratigraphie;

    CLASS Dokument =
      /** Dokumentenname
       */
      Titel : MANDATORY TEXT*100;
      /** offizieller Titel des Dokuments
       */
      offizieller_Titel : MANDATORY TEXT*255;
      /** Abkuerzung des Dokuments
       */
      Abkuerzung : TEXT*20;
      /** Pfad zum Dokument
       */
      Pfad : TEXT;
      /** Dokumententyp
       */
      Typ : MANDATORY SO_AFU_Geotope_20200312.Dokumententyp;
      /** offizielle Nummer des Gesetzes oder des RRBs
       */
      offizielle_Nr : TEXT*100;
      /** Rechtsstatus des Dokuments
       */
      Rechtsstatus : MANDATORY SO_AFU_Geotope_20200312.Rechtsstatus;
      /** Datum, ab dem das Dokument in Kraft tritt
       */
      publiziert_ab : INTERLIS.XMLDate;
      UNIQUE Pfad;
    END Dokument;

    /** Name des Fachbereichs beim AfU
     */
    CLASS Fachbereich =
      Fachbereichsname : MANDATORY TEXT*20;
    END Fachbereich;

    /** abstrakte Klasse Geotop
     */
    CLASS Geotop (ABSTRACT) =
      /** Name des Geotops
       */
      Objektname : MANDATORY TEXT*200;
      /** Zuordnung des Geotops zu einer Gesamtheit der wichtigsten geologischen Merkmale einer Region
       */
      regionalgeologische_Einheit : MANDATORY SO_AFU_Geotope_20200312.Regionalgeologische_Einheit;
      /** Bedeutung des Geotops
       */
      Bedeutung : MANDATORY SO_AFU_Geotope_20200312.Bedeutung;
      /** Verfassung des Geotops
       */
      Zustand : MANDATORY SO_AFU_Geotope_20200312.Zustand;
      /** kurze Beschreibung
       */
      Beschreibung : MTEXT*2048;
      /** Schutzwuerdigkeit des Geotops
       */
      Schutzwuerdigkeit : MANDATORY SO_AFU_Geotope_20200312.Schutzwuerdigkeit;
      /** Bedeutung des Geotops in der Geowissenschaft
       */
      geowissenschaftlicher_Wert : MANDATORY SO_AFU_Geotope_20200312.geowissenschaftlicher_Wert;
      /** durch den Mensch verursachte Bedrohung des Geotops
       */
      anthropogene_Gefaehrdung : MANDATORY SO_AFU_Geotope_20200312.Anthropogene_Gefaehrdung;
      /** Lokalname der Fundstelle des Geotops
       */
      Lokalname : MANDATORY TEXT*255;
      /** Ist das Geotop durch den Kanton geschuetzt?
       */
      kant_geschuetztes_Objekt : MANDATORY BOOLEAN;
      /** alte Ingeso-Nummer
       */
      alte_Inventar_Nummer : TEXT*10;
      /** OID des INGESO-Systems
       */
      INGESO_OID : TEXT*20;
      /** Hinweise auf Literatur, welche nicht digital vorhanden ist
       */
      Hinweis_Literatur : TEXT*512;
      /** Rechtsstatus des Geotops
       */
      Rechtsstatus : MANDATORY SO_AFU_Geotope_20200312.Rechtsstatus;
      /** Datum an dem das Geotop in Kraft tritt
       */
      publiziert_ab : INTERLIS.XMLDate;
      /** Ist das Geotop ein Teil des OEREB-Katasters?
       */
      Oereb_Objekt : MANDATORY BOOLEAN;
    END Geotop;

    /** fuer das Geotop zustaendige Stelle
     */
    CLASS zustaendige_Stelle =
      /** Name des Amts / der zustaendigen Stelle
       */
      Amtsname : MANDATORY TEXT*255;
      /** Webseite des Amts / der zustaendigen Stelle
       */
      Amt_im_Web : MANDATORY TEXT*255;
    END zustaendige_Stelle;

    /** Steinbloecke, die durch seltenere geophysikalische Prozesse oder menschliches Zutun nicht dort liegen, wo sie erwartet wuerden
     */
    CLASS Erratiker
    EXTENDS Geotop =
      /** Punktgeometrie des Erratikers
       */
      Geometrie : MANDATORY GeometryCHLV95_V1.Coord2;
      /** Groesse des Erratikers (Laenge x Breite x Hoehe in [cm] oder Volumen in [m3])
       */
      Groesse : MANDATORY TEXT*100;
      /** Eiszeit aus welcher der Erratiker stammt
       */
      Eiszeit : MANDATORY SO_AFU_Geotope_20200312.Eiszeit;
      /** Herkunft des Erratikers
       */
      Herkunft : MANDATORY TEXT*100;
      /** Handelt es sich beim Erratiker um einen Schalenstein? ja/nein
       */
      Schalenstein : BOOLEAN;
      /** Aufenthaltsort des Erratikers
       */
      Aufenthaltsort : TEXT*200;
      /** mineralische und chemische Zusammensetzung der Gesteine und ihrer Gefuege
       */
      Petrografie : MANDATORY SO_AFU_Geotope_20200312.Petrografie_Erratiker;
      /** Entstehung des Erratikers
       */
      Entstehung : MANDATORY SO_AFU_Geotope_20200312.Entstehung;
    END Erratiker;

    /** Erweiterung der abstrakten Klasse Geotop
     */
    CLASS Geotop_plus (ABSTRACT)
    EXTENDS Geotop =
    END Geotop_plus;

    /** natuerlich entstandener unterirdischer Hohlraum
     */
    CLASS Hoehle
    EXTENDS Geotop =
      /** Punktgeometrie der Hoehle
       */
      Geometrie : MANDATORY GeometryCHLV95_V1.Coord2;
    END Hoehle;

    /** Form der Landschaft
     */
    CLASS Landschaftsform
    EXTENDS Geotop =
      /** Flaechengeometrie der Landschaftsform
       */
      Geometrie : MANDATORY GeometryCHLV95_V1.MultiSurface;
      /** Art der Landschaftsform
       */
      Landschaftstyp : MANDATORY SO_AFU_Geotope_20200312.Landschaftstyp;
      /** Entstehung der Landschaftsform
       */
      Entstehung : MANDATORY SO_AFU_Geotope_20200312.Entstehung;
      /** oberflaechige Form der Landschaftsform
       */
      Oberflaechenform : MANDATORY SO_AFU_Geotope_20200312.Oberflaechenform_Landschaftsform;
    END Landschaftsform;

    /** Ort, an dem dauerhaft oder zeitweise Grundwasser auf natuerliche Weise an der Gelaendeoberflaeche austritt
     */
    CLASS Quelle
    EXTENDS Geotop =
      /** Punktgeometrie der Quelle
       */
      Geometrie : MANDATORY GeometryCHLV95_V1.Coord2;
    END Quelle;

    ASSOCIATION zustaendige_Stelle_Geotop =
      /** Fremdschluessel zu zustaendige_Stelle
       */
      zustaendige_Stelle -- {1} zustaendige_Stelle;
      /** Fremdschluessel zu Geotop
       */
      Geotop -- {0..*} Geotop;
    END zustaendige_Stelle_Geotop;

    /** Stelle an der Erdoberflaeche, an der Gestein unverhuellt zu Tage tritt
     */
    CLASS Aufschluss
    EXTENDS Geotop_plus =
      /** Flaechengeometrie des Aufschlusses
       */
      Geometrie : MANDATORY GeometryCHLV95_V1.MultiSurface;
      /** mineralische und chemische Zusammensetzung der Gesteine und ihrer Gefuege
       */
      Petrografie : MANDATORY SO_AFU_Geotope_20200312.Petrografie;
      /** Entstehung des Aufschlusses
       */
      Entstehung : MANDATORY SO_AFU_Geotope_20200312.Entstehung;
      /** oberflaechige Form des Aufschlusses
       */
      Oberflaechenform : MANDATORY SO_AFU_Geotope_20200312.Oberflaechenform_Aufschluss;
    END Aufschluss;

    /** Stelle an dem ein Fund gemacht wurde oder gegraben wurde
     */
    CLASS Fundstelle_Grabung
    EXTENDS Geotop_plus =
      /** Punktgeometrie der Fundstelle oder der Grabung
       */
      Geometrie : MANDATORY GeometryCHLV95_V1.Coord2;
      /** Aufenthaltsort der Funde
       */
      Aufenthaltsort : MANDATORY TEXT*200;
      /** gefundene Gegenstaende
       */
      Fundgegenstaende : MANDATORY TEXT*200;
      /** mineralische und chemische Zusammensetzung der Gesteine und ihrer Gefuege
       */
      Petrografie : MANDATORY SO_AFU_Geotope_20200312.Petrografie;
    END Fundstelle_Grabung;

    ASSOCIATION Erratiker_Dokument =
      Dokument -- {0..*} Dokument;
      Erratiker -- {0..*} Erratiker;
    END Erratiker_Dokument;

    ASSOCIATION Erratiker_Fachbereich =
      Erratiker -- {0..*} Erratiker;
      /** Ein Erratiker hat im Minimum ein Fachbereich
       */
      Fachbereich -- {1..*} Fachbereich;
    END Erratiker_Fachbereich;

    ASSOCIATION geologische_Schicht_bis_Geotop_plus =
      Geotop_plus -- {0..*} Geotop_plus;
      geologische_Schicht_bis (EXTERNAL) -- {1} SO_AFU_Geotope_20200312.Lithostratigraphie.geologische_Schicht;
    END geologische_Schicht_bis_Geotop_plus;

    ASSOCIATION geologische_Schicht_von_Geotop_plus =
      /** Fremdschluessel zu geologische_Schicht
       */
      geologische_Schicht_von (EXTERNAL) -- {1} SO_AFU_Geotope_20200312.Lithostratigraphie.geologische_Schicht;
      /** Fremdschluessel zu Geotop_plus
       */
      Geotop_plus -- {0..*} Geotop_plus;
    END geologische_Schicht_von_Geotop_plus;

    ASSOCIATION geologische_Serie_bis_Geotop_plus =
      /** Fremdschluessel zu Geotop_plus
       */
      Geotop_plus -- {0..*} Geotop_plus;
      /** Fremdschluessel zu geologische Serie
       */
      geologische_Serie_bis (EXTERNAL) -- {1} SO_AFU_Geotope_20200312.Lithostratigraphie.geologische_Serie;
    END geologische_Serie_bis_Geotop_plus;

    ASSOCIATION geologische_Serie_von_Geotop_plus =
      /** Fremdschluessel zu geologische_Serie
       */
      geologische_Serie_von (EXTERNAL) -- {1} SO_AFU_Geotope_20200312.Lithostratigraphie.geologische_Serie;
      /** Fremdschluessel zu Geotop_plus
       */
      Geotop_plus -- {0..*} Geotop_plus;
    END geologische_Serie_von_Geotop_plus;

    ASSOCIATION geologische_Stufe_bis_Geotop_plus =
      /** Fremdschluessel zu Geotop_plus
       */
      Geotop_plus -- {0..*} Geotop_plus;
      /** Fremdschluessel zu geologische_Stufe
       */
      geologische_Stufe_bis (EXTERNAL) -- {1} SO_AFU_Geotope_20200312.Lithostratigraphie.geologische_Stufe;
    END geologische_Stufe_bis_Geotop_plus;

    ASSOCIATION geologische_Stufe_von_Geotop_plus =
      /** Fremdschluessel zu Geotop_plus
       */
      Geotop_plus -- {0..*} Geotop_plus;
      /** Fremdschluessel zu geologische_Stufe
       */
      geologische_Stufe_von (EXTERNAL) -- {1} SO_AFU_Geotope_20200312.Lithostratigraphie.geologische_Stufe;
    END geologische_Stufe_von_Geotop_plus;

    ASSOCIATION geologisches_System_bis_Geotop_plus =
      /** Fremdschluessel zu Geotop_plus
       */
      Geotop_plus -- {0..*} Geotop_plus;
      /** Fremdschluessel zu geologisches System
       */
      geologisches_System_bis (EXTERNAL) -- {1} SO_AFU_Geotope_20200312.Lithostratigraphie.geologisches_System;
    END geologisches_System_bis_Geotop_plus;

    ASSOCIATION geologisches_System_von_Geotop_plus =
      /** Fremdschluessel zu Geotop_plus
       */
      Geotop_plus -- {0..*} Geotop_plus;
      /** Fremdschluessel zu geologisches_System
       */
      geologisches_System_von (EXTERNAL) -- {1} SO_AFU_Geotope_20200312.Lithostratigraphie.geologisches_System;
    END geologisches_System_von_Geotop_plus;

    ASSOCIATION Hoehle_Dokument =
      Hoehle -- {0..*} Hoehle;
      Dokument -- {0..*} Dokument;
    END Hoehle_Dokument;

    /** Eine Hoehle hat im Minimum ein Fachbereich
     */
    ASSOCIATION Hoehle_Fachbereich =
      Hoehle -- {0..*} Hoehle;
      /** Eine Hoehle hat im Minimum ein Fachbereich
       */
      Fachbereich -- {1..*} Fachbereich;
    END Hoehle_Fachbereich;

    ASSOCIATION Landform_Dokument =
      Landform -- {0..*} Landschaftsform;
      Dokument -- {0..*} Dokument;
    END Landform_Dokument;

    ASSOCIATION Landform_Fachbereich =
      Landform -- {0..*} Landschaftsform;
      /** Eine Landform hat im Minimum ein Fachbereich
       */
      Fachbereich -- {1..*} Fachbereich;
    END Landform_Fachbereich;

    ASSOCIATION Quelle_Dokument =
      Quelle -- {0..*} Quelle;
      Dokument -- {0..*} Dokument;
    END Quelle_Dokument;

    ASSOCIATION Quelle_Fachbereich =
      Quelle -- {0..*} Quelle;
      Fachbereich -- {1..*} Fachbereich;
    END Quelle_Fachbereich;

    ASSOCIATION Aufschluss_Dokument =
      Aufschluss -- {0..*} Aufschluss;
      Dokument -- {0..*} Dokument;
    END Aufschluss_Dokument;

    /** Ein Aufschluss hat im Minimum ein Fachbereich
     */
    ASSOCIATION Aufschluss_Fachbereich =
      Aufschluss -- {0..*} Aufschluss;
      Fachbereich -- {1..*} Fachbereich;
    END Aufschluss_Fachbereich;

    ASSOCIATION Fundstelle_Grabung_Dokument =
      Fundstelle_Grabung -- {0..*} Fundstelle_Grabung;
      Dokument -- {0..*} Dokument;
    END Fundstelle_Grabung_Dokument;

    /** Eine Fundstelle hat im Minimum ein Fachbereich
     */
    ASSOCIATION Fundstelle_Grabung_Fachbereich =
      Fundstelle_Grabung -- {0..*} Fundstelle_Grabung;
      Fachbereich -- {1..*} Fachbereich;
    END Fundstelle_Grabung_Fachbereich;

  END Geotope;

END SO_AFU_Geotope_20200312.
','2020-07-22 13:58:58.182');
INSERT INTO afu_geotope.T_ILI2DB_MODEL (filename,iliversion,modelName,content,importDate) VALUES ('CHBase_Part1_GEOMETRY_20110830.ili','2.3','GeometryCHLV03_V1{ INTERLIS CoordSys Units} GeometryCHLV95_V1{ INTERLIS CoordSys Units}','/* ########################################################################
   CHBASE - BASE MODULES OF THE SWISS FEDERATION FOR MINIMAL GEODATA MODELS
   ======
   BASISMODULE DES BUNDES           MODULES DE BASE DE LA CONFEDERATION
   FÜR MINIMALE GEODATENMODELLE     POUR LES MODELES DE GEODONNEES MINIMAUX
   
   PROVIDER: GKG/KOGIS - GCS/COSIG             CONTACT: models@geo.admin.ch
   PUBLISHED: 2011-0830
   ########################################################################
*/

INTERLIS 2.3;

/* ########################################################################
   ########################################################################
   PART I -- GEOMETRY
   - Package GeometryCHLV03
   - Package GeometryCHLV95
*/

!! ########################################################################

!! Version    | Who   | Modification
!!------------------------------------------------------------------------------
!! 2015-02-20 | KOGIS | WITHOUT OVERLAPS added (line 57, 58, 65 and 66)
!! 2015-11-12 | KOGIS | WITHOUT OVERLAPS corrected (line 57 and 58)
!! 2017-11-27 | KOGIS | Meta-Attributes @furtherInformation adapted and @CRS added (line 31, 44 and 50)
!! 2017-12-04 | KOGIS | Meta-Attribute @CRS corrected

!!@technicalContact=models@geo.admin.ch
!!@furtherInformation=https://www.geo.admin.ch/de/geoinformation-schweiz/geobasisdaten/geodata-models.html
TYPE MODEL GeometryCHLV03_V1 (en)
  AT "http://www.geo.admin.ch" VERSION "2017-12-04" =

  IMPORTS UNQUALIFIED INTERLIS;
  IMPORTS Units;
  IMPORTS CoordSys;

  REFSYSTEM BASKET BCoordSys ~ CoordSys.CoordsysTopic
    OBJECTS OF GeoCartesian2D: CHLV03
    OBJECTS OF GeoHeight: SwissOrthometricAlt;

  DOMAIN
    !!@CRS=EPSG:21781
    Coord2 = COORD
      460000.000 .. 870000.000 [m] {CHLV03[1]},
       45000.000 .. 310000.000 [m] {CHLV03[2]},
      ROTATION 2 -> 1;

    !!@CRS=EPSG:21781
    Coord3 = COORD
      460000.000 .. 870000.000 [m] {CHLV03[1]},
       45000.000 .. 310000.000 [m] {CHLV03[2]},
        -200.000 ..   5000.000 [m] {SwissOrthometricAlt[1]},
      ROTATION 2 -> 1;

    Surface = SURFACE WITH (STRAIGHTS, ARCS) VERTEX Coord2 WITHOUT OVERLAPS > 0.001;
    Area = AREA WITH (STRAIGHTS, ARCS) VERTEX Coord2 WITHOUT OVERLAPS > 0.001;
    Line = POLYLINE WITH (STRAIGHTS, ARCS) VERTEX Coord2;
    DirectedLine EXTENDS Line = DIRECTED POLYLINE;
    LineWithAltitude = POLYLINE WITH (STRAIGHTS, ARCS) VERTEX Coord3;
    DirectedLineWithAltitude = DIRECTED POLYLINE WITH (STRAIGHTS, ARCS) VERTEX Coord3;
    
    /* minimal overlaps only (2mm) */
    SurfaceWithOverlaps2mm = SURFACE WITH (STRAIGHTS, ARCS) VERTEX Coord2 WITHOUT OVERLAPS > 0.002;
    AreaWithOverlaps2mm = AREA WITH (STRAIGHTS, ARCS) VERTEX Coord2 WITHOUT OVERLAPS > 0.002;

    Orientation = 0.00000 .. 359.99999 CIRCULAR [Units.Angle_Degree] <Coord2>;

    Accuracy = (cm, cm50, m, m10, m50, vague);
    Method = (measured, sketched, calculated);

    STRUCTURE LineStructure = 
      Line: Line;
    END LineStructure;

    STRUCTURE DirectedLineStructure =
      Line: DirectedLine;
    END DirectedLineStructure;

    STRUCTURE MultiLine =
      Lines: BAG {1..*} OF LineStructure;
    END MultiLine;

    STRUCTURE MultiDirectedLine =
      Lines: BAG {1..*} OF DirectedLineStructure;
    END MultiDirectedLine;

    STRUCTURE SurfaceStructure =
      Surface: Surface;
    END SurfaceStructure;

    STRUCTURE MultiSurface =
      Surfaces: BAG {1..*} OF SurfaceStructure;
    END MultiSurface;

END GeometryCHLV03_V1.

!! ########################################################################

!! Version    | Who   | Modification
!!------------------------------------------------------------------------------
!! 2015-02-20 | KOGIS | WITHOUT OVERLAPS added (line 135, 136, 143 and 144)
!! 2015-11-12 | KOGIS | WITHOUT OVERLAPS corrected (line 135 and 136)
!! 2017-11-27 | KOGIS | Meta-Attributes @furtherInformation adapted and @CRS added (line 109, 122 and 128)
!! 2017-12-04 | KOGIS | Meta-Attribute @CRS corrected

!!@technicalContact=models@geo.admin.ch
!!@furtherInformation=https://www.geo.admin.ch/de/geoinformation-schweiz/geobasisdaten/geodata-models.html
TYPE MODEL GeometryCHLV95_V1 (en)
  AT "http://www.geo.admin.ch" VERSION "2017-12-04" =

  IMPORTS UNQUALIFIED INTERLIS;
  IMPORTS Units;
  IMPORTS CoordSys;

  REFSYSTEM BASKET BCoordSys ~ CoordSys.CoordsysTopic
    OBJECTS OF GeoCartesian2D: CHLV95
    OBJECTS OF GeoHeight: SwissOrthometricAlt;

  DOMAIN
    !!@CRS=EPSG:2056
    Coord2 = COORD
      2460000.000 .. 2870000.000 [m] {CHLV95[1]},
      1045000.000 .. 1310000.000 [m] {CHLV95[2]},
      ROTATION 2 -> 1;

    !!@CRS=EPSG:2056
    Coord3 = COORD
      2460000.000 .. 2870000.000 [m] {CHLV95[1]},
      1045000.000 .. 1310000.000 [m] {CHLV95[2]},
         -200.000 ..   5000.000 [m] {SwissOrthometricAlt[1]},
      ROTATION 2 -> 1;

    Surface = SURFACE WITH (STRAIGHTS, ARCS) VERTEX Coord2 WITHOUT OVERLAPS > 0.001;
    Area = AREA WITH (STRAIGHTS, ARCS) VERTEX Coord2 WITHOUT OVERLAPS > 0.001;
    Line = POLYLINE WITH (STRAIGHTS, ARCS) VERTEX Coord2;
    DirectedLine EXTENDS Line = DIRECTED POLYLINE;
    LineWithAltitude = POLYLINE WITH (STRAIGHTS, ARCS) VERTEX Coord3;
    DirectedLineWithAltitude = DIRECTED POLYLINE WITH (STRAIGHTS, ARCS) VERTEX Coord3;
    
    /* minimal overlaps only (2mm) */
    SurfaceWithOverlaps2mm = SURFACE WITH (STRAIGHTS, ARCS) VERTEX Coord2 WITHOUT OVERLAPS > 0.002;
    AreaWithOverlaps2mm = AREA WITH (STRAIGHTS, ARCS) VERTEX Coord2 WITHOUT OVERLAPS > 0.002;

    Orientation = 0.00000 .. 359.99999 CIRCULAR [Units.Angle_Degree] <Coord2>;

    Accuracy = (cm, cm50, m, m10, m50, vague);
    Method = (measured, sketched, calculated);

    STRUCTURE LineStructure = 
      Line: Line;
    END LineStructure;

    STRUCTURE DirectedLineStructure =
      Line: DirectedLine;
    END DirectedLineStructure;

    STRUCTURE MultiLine =
      Lines: BAG {1..*} OF LineStructure;
    END MultiLine;

    STRUCTURE MultiDirectedLine =
      Lines: BAG {1..*} OF DirectedLineStructure;
    END MultiDirectedLine;

    STRUCTURE SurfaceStructure =
      Surface: Surface;
    END SurfaceStructure;

    STRUCTURE MultiSurface =
      Surfaces: BAG {1..*} OF SurfaceStructure;
    END MultiSurface;

END GeometryCHLV95_V1.

!! ########################################################################
','2020-07-22 13:58:58.182');
INSERT INTO afu_geotope.T_ILI2DB_SETTINGS (tag,setting) VALUES ('ch.ehi.ili2db.createMetaInfo','True');
INSERT INTO afu_geotope.T_ILI2DB_SETTINGS (tag,setting) VALUES ('ch.ehi.ili2db.multiPointTrafo','coalesce');
INSERT INTO afu_geotope.T_ILI2DB_SETTINGS (tag,setting) VALUES ('ch.ehi.ili2db.nameOptimization','topic');
INSERT INTO afu_geotope.T_ILI2DB_SETTINGS (tag,setting) VALUES ('ch.ehi.ili2db.multiSurfaceTrafo','coalesce');
INSERT INTO afu_geotope.T_ILI2DB_SETTINGS (tag,setting) VALUES ('ch.ehi.ili2db.maxSqlNameLength','60');
INSERT INTO afu_geotope.T_ILI2DB_SETTINGS (tag,setting) VALUES ('ch.ehi.ili2db.beautifyEnumDispName','underscore');
INSERT INTO afu_geotope.T_ILI2DB_SETTINGS (tag,setting) VALUES ('ch.ehi.ili2db.multiLineTrafo','coalesce');
INSERT INTO afu_geotope.T_ILI2DB_SETTINGS (tag,setting) VALUES ('ch.ehi.ili2db.jsonTrafo','coalesce');
INSERT INTO afu_geotope.T_ILI2DB_SETTINGS (tag,setting) VALUES ('ch.ehi.ili2db.StrokeArcs','enable');
INSERT INTO afu_geotope.T_ILI2DB_SETTINGS (tag,setting) VALUES ('ch.ehi.ili2db.createForeignKey','yes');
INSERT INTO afu_geotope.T_ILI2DB_SETTINGS (tag,setting) VALUES ('ch.ehi.ili2db.uniqueConstraints','create');
INSERT INTO afu_geotope.T_ILI2DB_SETTINGS (tag,setting) VALUES ('ch.ehi.sqlgen.createGeomIndex','True');
INSERT INTO afu_geotope.T_ILI2DB_SETTINGS (tag,setting) VALUES ('ch.ehi.ili2db.uuidDefaultValue','uuid_generate_v4()');
INSERT INTO afu_geotope.T_ILI2DB_SETTINGS (tag,setting) VALUES ('ch.ehi.ili2db.multilingualTrafo','expand');
INSERT INTO afu_geotope.T_ILI2DB_SETTINGS (tag,setting) VALUES ('ch.ehi.ili2db.defaultSrsAuthority','EPSG');
INSERT INTO afu_geotope.T_ILI2DB_SETTINGS (tag,setting) VALUES ('ch.ehi.ili2db.arrayTrafo','coalesce');
INSERT INTO afu_geotope.T_ILI2DB_SETTINGS (tag,setting) VALUES ('ch.ehi.ili2db.catalogueRefTrafo','coalesce');
INSERT INTO afu_geotope.T_ILI2DB_SETTINGS (tag,setting) VALUES ('ch.ehi.ili2db.defaultSrsCode','2056');
INSERT INTO afu_geotope.T_ILI2DB_SETTINGS (tag,setting) VALUES ('ch.ehi.ili2db.createForeignKeyIndex','yes');
INSERT INTO afu_geotope.T_ILI2DB_SETTINGS (tag,setting) VALUES ('ch.ehi.ili2db.createEnumDefs','multiTable');
INSERT INTO afu_geotope.T_ILI2DB_SETTINGS (tag,setting) VALUES ('ch.ehi.ili2db.inheritanceTrafo','smart1');
INSERT INTO afu_geotope.T_ILI2DB_SETTINGS (tag,setting) VALUES ('ch.ehi.ili2db.sender','ili2pg-4.3.1-23b1f79e8ad644414773bb9bd1a97c8c265c5082');
INSERT INTO afu_geotope.T_ILI2DB_SETTINGS (tag,setting) VALUES ('ch.ehi.ili2db.numericCheckConstraints','create');
INSERT INTO afu_geotope.T_ILI2DB_SETTINGS (tag,setting) VALUES ('ch.ehi.ili2db.localisedTrafo','expand');
INSERT INTO afu_geotope.T_ILI2DB_SETTINGS (tag,setting) VALUES ('ch.interlis.ili2c.ilidirs','%ILI_FROM_DB;%XTF_DIR;http://models.interlis.ch/;%JAR_DIR');
INSERT INTO afu_geotope.T_ILI2DB_META_ATTRS (ilielement,attr_name,attr_value) VALUES ('SO_AFU_Geotope_20200312','technicalContact','agi@so.ch');
