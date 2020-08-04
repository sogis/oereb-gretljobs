CREATE SCHEMA IF NOT EXISTS ada_denkmalschutz;
CREATE SEQUENCE ada_denkmalschutz.t_ili2db_seq;;
-- SO_ADA_Denkmal_20191128.Fachapplikation.Denkmal
CREATE TABLE ada_denkmalschutz.fachapplikation_denkmal (
  T_Id bigint PRIMARY KEY DEFAULT nextval('ada_denkmalschutz.t_ili2db_seq')
  ,id integer NOT NULL
  ,objektname varchar(4000) NOT NULL
  ,gemeindename varchar(4000) NOT NULL
  ,gemeindeteil varchar(4000) NULL
  ,adr_strasse varchar(4000) NULL
  ,adr_hausnummer varchar(4000) NULL
  ,objektart_code varchar(4000) NULL
  ,objektart_text varchar(4000) NULL
  ,schutzstufe_code varchar(4000) NOT NULL
  ,schutzstufe_text varchar(4000) NOT NULL
  ,schutzdurchgemeinde boolean NOT NULL
  ,geometrie geometry(POINT,2056) NOT NULL
)
;
CREATE INDEX fachapplikation_denkmal_geometrie_idx ON ada_denkmalschutz.fachapplikation_denkmal USING GIST ( geometrie );
COMMENT ON TABLE ada_denkmalschutz.fachapplikation_denkmal IS 'In ArtPlus gefuerte Informationen zu einem Denkmal.';
COMMENT ON COLUMN ada_denkmalschutz.fachapplikation_denkmal.id IS 'Interner Schluessel des Denkmals in Artplus. Ist stabil und eindeutig.

ArtPlusAttribut: Objekte.ID';
COMMENT ON COLUMN ada_denkmalschutz.fachapplikation_denkmal.objektname IS 'ArtPlusAttribut: Objekt.Objektname';
COMMENT ON COLUMN ada_denkmalschutz.fachapplikation_denkmal.gemeindename IS 'Name der Gemeinde, in welcher das Denkmal liegt

ArtPlusAttribut: Objekt.Gemeinde';
COMMENT ON COLUMN ada_denkmalschutz.fachapplikation_denkmal.gemeindeteil IS 'Name der Gemeinde, in welcher das Denkmal liegt

ArtPlusAttribut: Objekt.Gemeindeteil';
COMMENT ON COLUMN ada_denkmalschutz.fachapplikation_denkmal.adr_strasse IS 'Adresse: Strassenname

ArtPlusAttribut: Objekte.Strasse';
COMMENT ON COLUMN ada_denkmalschutz.fachapplikation_denkmal.adr_hausnummer IS 'Adresse: Hausnummer und Suffix

ArtPlusAttribut: Objekte.Hausnummer';
COMMENT ON COLUMN ada_denkmalschutz.fachapplikation_denkmal.objektart_code IS 'Code fuer die Art des Objektes. Bsp.: Schloss, Ruine, Portal, ...

ArtPlusAttribut: Objekte.Gattung/Typo';
COMMENT ON COLUMN ada_denkmalschutz.fachapplikation_denkmal.objektart_text IS 'Sprechender Text fuer die Art des Objektes.

ArtPlusAttribut: Objekte.Gattung/Typo';
COMMENT ON COLUMN ada_denkmalschutz.fachapplikation_denkmal.schutzstufe_code IS 'Code fuer die kantonale Schutzstufe des Objektes.
(geschuetzt, schuetzenswert, erhaltenswert, ...)

ArtPlusAttribut: Objekte.Grunddaten.Einstufung Kanton';
COMMENT ON COLUMN ada_denkmalschutz.fachapplikation_denkmal.schutzstufe_text IS 'Sprechender Text fuer die kantonale Schutzstufe des Objektes.

ArtPlusAttribut: Objekte.Grunddaten.Einstufung Kanton';
COMMENT ON COLUMN ada_denkmalschutz.fachapplikation_denkmal.schutzdurchgemeinde IS 'Gibt an, ob das Denkmal kommunal geschuetzt ist.

ArtPlusAttribut: Objekte.Grunddaten.Schutz Gemeinde';
COMMENT ON COLUMN ada_denkmalschutz.fachapplikation_denkmal.geometrie IS 'In ArtPlus gefuerte "Zentrumskoordinaten" zu einem Denkmal.

Sie bestehen, da die GIS-Koordinaten nur kostspielig in die
ArtPlus-Reports etc. einzubinden sind.
Fuer ein im GIS als Einzelpunkt repraesentiertes Denkmal sind
die Koordinaten redundant.

ArtPlusAttribute: Objekte.Koordinaten';
-- SO_ADA_Denkmal_20191128.Fachapplikation.Rechtsvorschrift_Link
CREATE TABLE ada_denkmalschutz.fachapplikation_rechtsvorschrift_link (
  T_Id bigint PRIMARY KEY DEFAULT nextval('ada_denkmalschutz.t_ili2db_seq')
  ,denkmal_id integer NOT NULL
  ,multimedia_id integer NULL
  ,multimedia_link varchar(1023) NULL
  ,titel varchar(4000) NOT NULL
  ,nummer varchar(4000) NULL
  ,datum date NULL
  ,bfsnummer integer NULL
  ,dummygeometrie geometry(POINT,2056) NULL
)
;
CREATE INDEX fachpplktn_rcvrschrft_link_dummygeometrie_idx ON ada_denkmalschutz.fachapplikation_rechtsvorschrift_link USING GIST ( dummygeometrie );
COMMENT ON TABLE ada_denkmalschutz.fachapplikation_rechtsvorschrift_link IS 'Link-Tabelle auf die Rechtsvorschrift.

In ArtPlus sind die Informationen zu einer Schutzverfuegung
(= Rechtsvorschrift) n:1 zu einem Denkmal modelliert.
Bei allen Rechtsvorschriften mit Bezug zu mehr als einem Denkmal
sind die Informationen in dieser Klasse folglich mehrfach vorhanden.';
COMMENT ON COLUMN ada_denkmalschutz.fachapplikation_rechtsvorschrift_link.denkmal_id IS 'Fremdschluessel auf Denkmal';
COMMENT ON COLUMN ada_denkmalschutz.fachapplikation_rechtsvorschrift_link.multimedia_id IS 'Fremdschluessel auf die im Multimedia-Modul von
ArtPlus abgelegte Datei der Rechtsvorschrift.

ArtPlusAttribut: Multimedia.ID';
COMMENT ON COLUMN ada_denkmalschutz.fachapplikation_rechtsvorschrift_link.multimedia_link IS 'URL, unter welcher die entsprechende Schutzverfuegung
mittels HTTP(S) geladen werden kann.

ArtPlusAttribut: Keines (dynamisch generiert)';
COMMENT ON COLUMN ada_denkmalschutz.fachapplikation_rechtsvorschrift_link.titel IS 'Titel der Schutzverfuegung.

Wird aufgrund der bestehenden Feldverwendung in ArtPlus auf
das Bemerkungsfeld gemappt.

ArtPlusAttribut: Objekte.Grunddaten.Schutzverfuegung.Titel';
COMMENT ON COLUMN ada_denkmalschutz.fachapplikation_rechtsvorschrift_link.nummer IS 'Nummer der Schutzverfuegung (so vorhanden).

Falls Schutzverfuegung = RRB --> RRB-Nr.

ArtPlusAttribut: Objekte.Grunddaten.Schutzverfuegung.RRB-Nr';
COMMENT ON COLUMN ada_denkmalschutz.fachapplikation_rechtsvorschrift_link.datum IS 'Datum, an welchem die Rechtsvorschrift beschlossen wurde.
Bei RRB: Datum der RRB-Sitzung, an welcher der Beschluss gefasst wurde.
Kann bei vorbereiteten Daten NULL sein (Bsp. Wenn Einsprachefrist laeuft).

ArtPlusAttribut: Objekte.Grunddaten.Schutzverfuegung.Datum';
COMMENT ON COLUMN ada_denkmalschutz.fachapplikation_rechtsvorschrift_link.bfsnummer IS 'Bei von Gemeinde erlassener Schutzverfuegung: BfS-Nummer der Gemeinde

ArtPlusAttribut: Objekte.Grunddaten.Schutzverfuegung.BfS-Nummer';
COMMENT ON COLUMN ada_denkmalschutz.fachapplikation_rechtsvorschrift_link.dummygeometrie IS 'Dummy: Workaround um AGDI regression. Tabellen ohne Geometrie koennen nicht mehr erfasst werden.';
-- SO_ADA_Denkmal_20191128.GIS.Geometrie
CREATE TABLE ada_denkmalschutz.gis_geometrie (
  T_Id bigint PRIMARY KEY DEFAULT nextval('ada_denkmalschutz.t_ili2db_seq')
  ,denkmal_id integer NOT NULL
  ,apolygon geometry(POLYGON,2056) NULL
  ,punkt geometry(POINT,2056) NULL
)
;
CREATE INDEX gis_geometrie_apolygon_idx ON ada_denkmalschutz.gis_geometrie USING GIST ( apolygon );
CREATE INDEX gis_geometrie_punkt_idx ON ada_denkmalschutz.gis_geometrie USING GIST ( punkt );
COMMENT ON TABLE ada_denkmalschutz.gis_geometrie IS 'Enthaelt die Geometrie in der Form von Polygonen oder Punkten:
- Polygon beispielsweise bei Gebaeuden.
- Punkt beispielsweise bei Wirtshaus-Schild.
Fuer beispielsweise Kreuzwege koennen mehrere Punkte dem gleichen
Denkmal (= ganzer Kreuzweg) zugewiesen werden.';
COMMENT ON COLUMN ada_denkmalschutz.gis_geometrie.denkmal_id IS 'Fremdschluessel auf das Denkmal.';
COMMENT ON COLUMN ada_denkmalschutz.gis_geometrie.apolygon IS 'Denkmalgeometrie, falls als Polygon abgebildet';
COMMENT ON COLUMN ada_denkmalschutz.gis_geometrie.punkt IS 'Denkmalgeometrie, falls als Point abgebildet';
CREATE TABLE ada_denkmalschutz.T_ILI2DB_BASKET (
  T_Id bigint PRIMARY KEY
  ,dataset bigint NULL
  ,topic varchar(200) NOT NULL
  ,T_Ili_Tid varchar(200) NULL
  ,attachmentKey varchar(200) NOT NULL
  ,domains varchar(1024) NULL
)
;
CREATE INDEX T_ILI2DB_BASKET_dataset_idx ON ada_denkmalschutz.t_ili2db_basket ( dataset );
CREATE TABLE ada_denkmalschutz.T_ILI2DB_DATASET (
  T_Id bigint PRIMARY KEY
  ,datasetName varchar(200) NULL
)
;
CREATE TABLE ada_denkmalschutz.T_ILI2DB_INHERITANCE (
  thisClass varchar(1024) PRIMARY KEY
  ,baseClass varchar(1024) NULL
)
;
CREATE TABLE ada_denkmalschutz.T_ILI2DB_SETTINGS (
  tag varchar(60) PRIMARY KEY
  ,setting varchar(1024) NULL
)
;
CREATE TABLE ada_denkmalschutz.T_ILI2DB_TRAFO (
  iliname varchar(1024) NOT NULL
  ,tag varchar(1024) NOT NULL
  ,setting varchar(1024) NOT NULL
)
;
CREATE TABLE ada_denkmalschutz.T_ILI2DB_MODEL (
  filename varchar(250) NOT NULL
  ,iliversion varchar(3) NOT NULL
  ,modelName text NOT NULL
  ,content text NOT NULL
  ,importDate timestamp NOT NULL
  ,PRIMARY KEY (iliversion,modelName)
)
;
CREATE TABLE ada_denkmalschutz.T_ILI2DB_CLASSNAME (
  IliName varchar(1024) PRIMARY KEY
  ,SqlName varchar(1024) NOT NULL
)
;
CREATE TABLE ada_denkmalschutz.T_ILI2DB_ATTRNAME (
  IliName varchar(1024) NOT NULL
  ,SqlName varchar(1024) NOT NULL
  ,ColOwner varchar(1024) NOT NULL
  ,Target varchar(1024) NULL
  ,PRIMARY KEY (ColOwner,SqlName)
)
;
CREATE TABLE ada_denkmalschutz.T_ILI2DB_COLUMN_PROP (
  tablename varchar(255) NOT NULL
  ,subtype varchar(255) NULL
  ,columnname varchar(255) NOT NULL
  ,tag varchar(1024) NOT NULL
  ,setting varchar(1024) NOT NULL
)
;
CREATE TABLE ada_denkmalschutz.T_ILI2DB_TABLE_PROP (
  tablename varchar(255) NOT NULL
  ,tag varchar(1024) NOT NULL
  ,setting varchar(1024) NOT NULL
)
;
CREATE TABLE ada_denkmalschutz.T_ILI2DB_META_ATTRS (
  ilielement varchar(255) NOT NULL
  ,attr_name varchar(1024) NOT NULL
  ,attr_value varchar(1024) NOT NULL
)
;
CREATE UNIQUE INDEX fachapplikation_denkmal_id_key ON ada_denkmalschutz.fachapplikation_denkmal (id)
;
ALTER TABLE ada_denkmalschutz.fachapplikation_denkmal ADD CONSTRAINT fachapplikation_denkmal_id_check CHECK( id BETWEEN 1 AND 2147483647);
ALTER TABLE ada_denkmalschutz.fachapplikation_rechtsvorschrift_link ADD CONSTRAINT fachpplktn_rvrschrft_link_denkmal_id_check CHECK( denkmal_id BETWEEN 1 AND 2147483647);
ALTER TABLE ada_denkmalschutz.fachapplikation_rechtsvorschrift_link ADD CONSTRAINT fachpplktn_rvrschrft_link_multimedia_id_check CHECK( multimedia_id BETWEEN 1 AND 2147483647);
ALTER TABLE ada_denkmalschutz.fachapplikation_rechtsvorschrift_link ADD CONSTRAINT fachpplktn_rvrschrft_link_bfsnummer_check CHECK( bfsnummer BETWEEN 0 AND 2147483647);
ALTER TABLE ada_denkmalschutz.gis_geometrie ADD CONSTRAINT gis_geometrie_denkmal_id_check CHECK( denkmal_id BETWEEN 1 AND 2147483647);
ALTER TABLE ada_denkmalschutz.T_ILI2DB_BASKET ADD CONSTRAINT T_ILI2DB_BASKET_dataset_fkey FOREIGN KEY ( dataset ) REFERENCES ada_denkmalschutz.T_ILI2DB_DATASET DEFERRABLE INITIALLY DEFERRED;
CREATE UNIQUE INDEX T_ILI2DB_DATASET_datasetName_key ON ada_denkmalschutz.T_ILI2DB_DATASET (datasetName)
;
CREATE UNIQUE INDEX T_ILI2DB_MODEL_iliversion_modelName_key ON ada_denkmalschutz.T_ILI2DB_MODEL (iliversion,modelName)
;
CREATE UNIQUE INDEX T_ILI2DB_ATTRNAME_ColOwner_SqlName_key ON ada_denkmalschutz.T_ILI2DB_ATTRNAME (ColOwner,SqlName)
;
INSERT INTO ada_denkmalschutz.T_ILI2DB_CLASSNAME (IliName,SqlName) VALUES ('SO_ADA_Denkmal_20191128.Fachapplikation.Rechtsvorschrift_Link','fachapplikation_rechtsvorschrift_link');
INSERT INTO ada_denkmalschutz.T_ILI2DB_CLASSNAME (IliName,SqlName) VALUES ('SO_ADA_Denkmal_20191128.Fachapplikation.Denkmal','fachapplikation_denkmal');
INSERT INTO ada_denkmalschutz.T_ILI2DB_CLASSNAME (IliName,SqlName) VALUES ('SO_ADA_Denkmal_20191128.GIS.Geometrie','gis_geometrie');
INSERT INTO ada_denkmalschutz.T_ILI2DB_ATTRNAME (IliName,SqlName,ColOwner,Target) VALUES ('SO_ADA_Denkmal_20191128.GIS.Geometrie.Polygon','apolygon','gis_geometrie',NULL);
INSERT INTO ada_denkmalschutz.T_ILI2DB_ATTRNAME (IliName,SqlName,ColOwner,Target) VALUES ('SO_ADA_Denkmal_20191128.Fachapplikation.Rechtsvorschrift_Link.BfsNummer','bfsnummer','fachapplikation_rechtsvorschrift_link',NULL);
INSERT INTO ada_denkmalschutz.T_ILI2DB_ATTRNAME (IliName,SqlName,ColOwner,Target) VALUES ('SO_ADA_Denkmal_20191128.Fachapplikation.Denkmal.Objektart_Text','objektart_text','fachapplikation_denkmal',NULL);
INSERT INTO ada_denkmalschutz.T_ILI2DB_ATTRNAME (IliName,SqlName,ColOwner,Target) VALUES ('SO_ADA_Denkmal_20191128.Fachapplikation.Rechtsvorschrift_Link.Denkmal_ID','denkmal_id','fachapplikation_rechtsvorschrift_link',NULL);
INSERT INTO ada_denkmalschutz.T_ILI2DB_ATTRNAME (IliName,SqlName,ColOwner,Target) VALUES ('SO_ADA_Denkmal_20191128.Fachapplikation.Denkmal.Objektname','objektname','fachapplikation_denkmal',NULL);
INSERT INTO ada_denkmalschutz.T_ILI2DB_ATTRNAME (IliName,SqlName,ColOwner,Target) VALUES ('SO_ADA_Denkmal_20191128.Fachapplikation.Rechtsvorschrift_Link.Datum','datum','fachapplikation_rechtsvorschrift_link',NULL);
INSERT INTO ada_denkmalschutz.T_ILI2DB_ATTRNAME (IliName,SqlName,ColOwner,Target) VALUES ('SO_ADA_Denkmal_20191128.GIS.Geometrie.Denkmal_ID','denkmal_id','gis_geometrie',NULL);
INSERT INTO ada_denkmalschutz.T_ILI2DB_ATTRNAME (IliName,SqlName,ColOwner,Target) VALUES ('SO_ADA_Denkmal_20191128.Fachapplikation.Rechtsvorschrift_Link.Multimedia_Link','multimedia_link','fachapplikation_rechtsvorschrift_link',NULL);
INSERT INTO ada_denkmalschutz.T_ILI2DB_ATTRNAME (IliName,SqlName,ColOwner,Target) VALUES ('SO_ADA_Denkmal_20191128.Fachapplikation.Denkmal.Gemeindename','gemeindename','fachapplikation_denkmal',NULL);
INSERT INTO ada_denkmalschutz.T_ILI2DB_ATTRNAME (IliName,SqlName,ColOwner,Target) VALUES ('SO_ADA_Denkmal_20191128.Fachapplikation.Denkmal.Gemeindeteil','gemeindeteil','fachapplikation_denkmal',NULL);
INSERT INTO ada_denkmalschutz.T_ILI2DB_ATTRNAME (IliName,SqlName,ColOwner,Target) VALUES ('SO_ADA_Denkmal_20191128.Fachapplikation.Rechtsvorschrift_Link.DummyGeometrie','dummygeometrie','fachapplikation_rechtsvorschrift_link',NULL);
INSERT INTO ada_denkmalschutz.T_ILI2DB_ATTRNAME (IliName,SqlName,ColOwner,Target) VALUES ('SO_ADA_Denkmal_20191128.GIS.Geometrie.Punkt','punkt','gis_geometrie',NULL);
INSERT INTO ada_denkmalschutz.T_ILI2DB_ATTRNAME (IliName,SqlName,ColOwner,Target) VALUES ('SO_ADA_Denkmal_20191128.Fachapplikation.Denkmal.Objektart_Code','objektart_code','fachapplikation_denkmal',NULL);
INSERT INTO ada_denkmalschutz.T_ILI2DB_ATTRNAME (IliName,SqlName,ColOwner,Target) VALUES ('SO_ADA_Denkmal_20191128.Fachapplikation.Rechtsvorschrift_Link.Titel','titel','fachapplikation_rechtsvorschrift_link',NULL);
INSERT INTO ada_denkmalschutz.T_ILI2DB_ATTRNAME (IliName,SqlName,ColOwner,Target) VALUES ('SO_ADA_Denkmal_20191128.Fachapplikation.Rechtsvorschrift_Link.Multimedia_ID','multimedia_id','fachapplikation_rechtsvorschrift_link',NULL);
INSERT INTO ada_denkmalschutz.T_ILI2DB_ATTRNAME (IliName,SqlName,ColOwner,Target) VALUES ('SO_ADA_Denkmal_20191128.Fachapplikation.Denkmal.Schutzstufe_Code','schutzstufe_code','fachapplikation_denkmal',NULL);
INSERT INTO ada_denkmalschutz.T_ILI2DB_ATTRNAME (IliName,SqlName,ColOwner,Target) VALUES ('SO_ADA_Denkmal_20191128.Fachapplikation.Rechtsvorschrift_Link.Nummer','nummer','fachapplikation_rechtsvorschrift_link',NULL);
INSERT INTO ada_denkmalschutz.T_ILI2DB_ATTRNAME (IliName,SqlName,ColOwner,Target) VALUES ('SO_ADA_Denkmal_20191128.Fachapplikation.Denkmal.Adr_Hausnummer','adr_hausnummer','fachapplikation_denkmal',NULL);
INSERT INTO ada_denkmalschutz.T_ILI2DB_ATTRNAME (IliName,SqlName,ColOwner,Target) VALUES ('SO_ADA_Denkmal_20191128.Fachapplikation.Denkmal.Schutzstufe_Text','schutzstufe_text','fachapplikation_denkmal',NULL);
INSERT INTO ada_denkmalschutz.T_ILI2DB_ATTRNAME (IliName,SqlName,ColOwner,Target) VALUES ('SO_ADA_Denkmal_20191128.Fachapplikation.Denkmal.SchutzDurchGemeinde','schutzdurchgemeinde','fachapplikation_denkmal',NULL);
INSERT INTO ada_denkmalschutz.T_ILI2DB_ATTRNAME (IliName,SqlName,ColOwner,Target) VALUES ('SO_ADA_Denkmal_20191128.Fachapplikation.Denkmal.ID','id','fachapplikation_denkmal',NULL);
INSERT INTO ada_denkmalschutz.T_ILI2DB_ATTRNAME (IliName,SqlName,ColOwner,Target) VALUES ('SO_ADA_Denkmal_20191128.Fachapplikation.Denkmal.Geometrie','geometrie','fachapplikation_denkmal',NULL);
INSERT INTO ada_denkmalschutz.T_ILI2DB_ATTRNAME (IliName,SqlName,ColOwner,Target) VALUES ('SO_ADA_Denkmal_20191128.Fachapplikation.Denkmal.Adr_Strasse','adr_strasse','fachapplikation_denkmal',NULL);
INSERT INTO ada_denkmalschutz.T_ILI2DB_TRAFO (iliname,tag,setting) VALUES ('SO_ADA_Denkmal_20191128.Fachapplikation.Rechtsvorschrift_Link','ch.ehi.ili2db.inheritance','newAndSubClass');
INSERT INTO ada_denkmalschutz.T_ILI2DB_TRAFO (iliname,tag,setting) VALUES ('SO_ADA_Denkmal_20191128.Fachapplikation.Denkmal','ch.ehi.ili2db.inheritance','newAndSubClass');
INSERT INTO ada_denkmalschutz.T_ILI2DB_TRAFO (iliname,tag,setting) VALUES ('SO_ADA_Denkmal_20191128.GIS.Geometrie','ch.ehi.ili2db.inheritance','newAndSubClass');
INSERT INTO ada_denkmalschutz.T_ILI2DB_INHERITANCE (thisClass,baseClass) VALUES ('SO_ADA_Denkmal_20191128.GIS.Geometrie',NULL);
INSERT INTO ada_denkmalschutz.T_ILI2DB_INHERITANCE (thisClass,baseClass) VALUES ('SO_ADA_Denkmal_20191128.Fachapplikation.Rechtsvorschrift_Link',NULL);
INSERT INTO ada_denkmalschutz.T_ILI2DB_INHERITANCE (thisClass,baseClass) VALUES ('SO_ADA_Denkmal_20191128.Fachapplikation.Denkmal',NULL);
INSERT INTO ada_denkmalschutz.T_ILI2DB_COLUMN_PROP (tablename,subtype,columnname,tag,setting) VALUES ('fachapplikation_rechtsvorschrift_link',NULL,'dummygeometrie','ch.ehi.ili2db.c1Max','2870000.000');
INSERT INTO ada_denkmalschutz.T_ILI2DB_COLUMN_PROP (tablename,subtype,columnname,tag,setting) VALUES ('fachapplikation_rechtsvorschrift_link',NULL,'dummygeometrie','ch.ehi.ili2db.c1Min','2460000.000');
INSERT INTO ada_denkmalschutz.T_ILI2DB_COLUMN_PROP (tablename,subtype,columnname,tag,setting) VALUES ('fachapplikation_rechtsvorschrift_link',NULL,'dummygeometrie','ch.ehi.ili2db.coordDimension','2');
INSERT INTO ada_denkmalschutz.T_ILI2DB_COLUMN_PROP (tablename,subtype,columnname,tag,setting) VALUES ('fachapplikation_rechtsvorschrift_link',NULL,'dummygeometrie','ch.ehi.ili2db.c2Max','1310000.000');
INSERT INTO ada_denkmalschutz.T_ILI2DB_COLUMN_PROP (tablename,subtype,columnname,tag,setting) VALUES ('fachapplikation_rechtsvorschrift_link',NULL,'dummygeometrie','ch.ehi.ili2db.geomType','POINT');
INSERT INTO ada_denkmalschutz.T_ILI2DB_COLUMN_PROP (tablename,subtype,columnname,tag,setting) VALUES ('fachapplikation_rechtsvorschrift_link',NULL,'dummygeometrie','ch.ehi.ili2db.c2Min','1045000.000');
INSERT INTO ada_denkmalschutz.T_ILI2DB_COLUMN_PROP (tablename,subtype,columnname,tag,setting) VALUES ('fachapplikation_rechtsvorschrift_link',NULL,'dummygeometrie','ch.ehi.ili2db.srid','2056');
INSERT INTO ada_denkmalschutz.T_ILI2DB_COLUMN_PROP (tablename,subtype,columnname,tag,setting) VALUES ('fachapplikation_denkmal',NULL,'geometrie','ch.ehi.ili2db.c1Max','2870000.000');
INSERT INTO ada_denkmalschutz.T_ILI2DB_COLUMN_PROP (tablename,subtype,columnname,tag,setting) VALUES ('fachapplikation_denkmal',NULL,'geometrie','ch.ehi.ili2db.c1Min','2460000.000');
INSERT INTO ada_denkmalschutz.T_ILI2DB_COLUMN_PROP (tablename,subtype,columnname,tag,setting) VALUES ('fachapplikation_denkmal',NULL,'geometrie','ch.ehi.ili2db.coordDimension','2');
INSERT INTO ada_denkmalschutz.T_ILI2DB_COLUMN_PROP (tablename,subtype,columnname,tag,setting) VALUES ('fachapplikation_denkmal',NULL,'geometrie','ch.ehi.ili2db.c2Max','1310000.000');
INSERT INTO ada_denkmalschutz.T_ILI2DB_COLUMN_PROP (tablename,subtype,columnname,tag,setting) VALUES ('fachapplikation_denkmal',NULL,'geometrie','ch.ehi.ili2db.geomType','POINT');
INSERT INTO ada_denkmalschutz.T_ILI2DB_COLUMN_PROP (tablename,subtype,columnname,tag,setting) VALUES ('fachapplikation_denkmal',NULL,'geometrie','ch.ehi.ili2db.c2Min','1045000.000');
INSERT INTO ada_denkmalschutz.T_ILI2DB_COLUMN_PROP (tablename,subtype,columnname,tag,setting) VALUES ('fachapplikation_denkmal',NULL,'geometrie','ch.ehi.ili2db.srid','2056');
INSERT INTO ada_denkmalschutz.T_ILI2DB_COLUMN_PROP (tablename,subtype,columnname,tag,setting) VALUES ('gis_geometrie',NULL,'apolygon','ch.ehi.ili2db.c1Max','2870000.000');
INSERT INTO ada_denkmalschutz.T_ILI2DB_COLUMN_PROP (tablename,subtype,columnname,tag,setting) VALUES ('gis_geometrie',NULL,'apolygon','ch.ehi.ili2db.c1Min','2460000.000');
INSERT INTO ada_denkmalschutz.T_ILI2DB_COLUMN_PROP (tablename,subtype,columnname,tag,setting) VALUES ('gis_geometrie',NULL,'apolygon','ch.ehi.ili2db.coordDimension','2');
INSERT INTO ada_denkmalschutz.T_ILI2DB_COLUMN_PROP (tablename,subtype,columnname,tag,setting) VALUES ('gis_geometrie',NULL,'apolygon','ch.ehi.ili2db.c2Max','1310000.000');
INSERT INTO ada_denkmalschutz.T_ILI2DB_COLUMN_PROP (tablename,subtype,columnname,tag,setting) VALUES ('gis_geometrie',NULL,'apolygon','ch.ehi.ili2db.geomType','POLYGON');
INSERT INTO ada_denkmalschutz.T_ILI2DB_COLUMN_PROP (tablename,subtype,columnname,tag,setting) VALUES ('gis_geometrie',NULL,'apolygon','ch.ehi.ili2db.c2Min','1045000.000');
INSERT INTO ada_denkmalschutz.T_ILI2DB_COLUMN_PROP (tablename,subtype,columnname,tag,setting) VALUES ('gis_geometrie',NULL,'apolygon','ch.ehi.ili2db.srid','2056');
INSERT INTO ada_denkmalschutz.T_ILI2DB_COLUMN_PROP (tablename,subtype,columnname,tag,setting) VALUES ('gis_geometrie',NULL,'punkt','ch.ehi.ili2db.c1Max','2870000.000');
INSERT INTO ada_denkmalschutz.T_ILI2DB_COLUMN_PROP (tablename,subtype,columnname,tag,setting) VALUES ('gis_geometrie',NULL,'punkt','ch.ehi.ili2db.c1Min','2460000.000');
INSERT INTO ada_denkmalschutz.T_ILI2DB_COLUMN_PROP (tablename,subtype,columnname,tag,setting) VALUES ('gis_geometrie',NULL,'punkt','ch.ehi.ili2db.coordDimension','2');
INSERT INTO ada_denkmalschutz.T_ILI2DB_COLUMN_PROP (tablename,subtype,columnname,tag,setting) VALUES ('gis_geometrie',NULL,'punkt','ch.ehi.ili2db.c2Max','1310000.000');
INSERT INTO ada_denkmalschutz.T_ILI2DB_COLUMN_PROP (tablename,subtype,columnname,tag,setting) VALUES ('gis_geometrie',NULL,'punkt','ch.ehi.ili2db.geomType','POINT');
INSERT INTO ada_denkmalschutz.T_ILI2DB_COLUMN_PROP (tablename,subtype,columnname,tag,setting) VALUES ('gis_geometrie',NULL,'punkt','ch.ehi.ili2db.c2Min','1045000.000');
INSERT INTO ada_denkmalschutz.T_ILI2DB_COLUMN_PROP (tablename,subtype,columnname,tag,setting) VALUES ('gis_geometrie',NULL,'punkt','ch.ehi.ili2db.srid','2056');
INSERT INTO ada_denkmalschutz.T_ILI2DB_TABLE_PROP (tablename,tag,setting) VALUES ('fachapplikation_denkmal','ch.ehi.ili2db.tableKind','CLASS');
INSERT INTO ada_denkmalschutz.T_ILI2DB_TABLE_PROP (tablename,tag,setting) VALUES ('gis_geometrie','ch.ehi.ili2db.tableKind','CLASS');
INSERT INTO ada_denkmalschutz.T_ILI2DB_TABLE_PROP (tablename,tag,setting) VALUES ('fachapplikation_rechtsvorschrift_link','ch.ehi.ili2db.tableKind','CLASS');
INSERT INTO ada_denkmalschutz.T_ILI2DB_MODEL (filename,iliversion,modelName,content,importDate) VALUES ('SO_ADA_Denkmal_20191128.ili','2.3','SO_ADA_Denkmal_20191128{ GeometryCHLV95_V1}','INTERLIS 2.3;

/** !! Seitenwagenmodell fuer die Fachapplikation
 * !! ArtPlus.
 * !! Auf die Verwendung von UUIDOID wurde aufgrund des
 * !! Anwendungsfalles bewusst verzichtet.
 * !! In den Attributen mit Suffix _Code sind die in der Fachapplikation
 * !! vergebenen Codes enthalten.
 * !!------------------------------------------------------------------------------
 * !! Version    | wer | Aenderung
 * !!------------------------------------------------------------------------------
 * !! 2019-11-29 | OJ  | Initial erstellt.
 */
!!@ technicalContact=mailto:agi@so.ch
MODEL SO_ADA_Denkmal_20191128 (de)
AT "http://geo.so.ch/models/ADA/"
VERSION "2019-11-28"  =
  IMPORTS GeometryCHLV95_V1;

  /** Umfasst die Klassen, deren Daten mittels Dataservice von
   * ArtPlus gepflegt werden. Datenoriginal in ArtPlus.
   */
  TOPIC Fachapplikation =

    /** In ArtPlus gefuerte Informationen zu einem Denkmal.
     */
    CLASS Denkmal =
      /** Interner Schluessel des Denkmals in Artplus. Ist stabil und eindeutig.
       * 
       * ArtPlusAttribut: Objekte.ID
       */
      ID : MANDATORY 1 .. 2147483647;
      /** ArtPlusAttribut: Objekt.Objektname
       */
      Objektname : MANDATORY TEXT*4000;
      /** Name der Gemeinde, in welcher das Denkmal liegt
       * 
       * ArtPlusAttribut: Objekt.Gemeinde
       */
      Gemeindename : MANDATORY TEXT*4000;
      /** Name der Gemeinde, in welcher das Denkmal liegt
       * 
       * ArtPlusAttribut: Objekt.Gemeindeteil
       */
      Gemeindeteil : TEXT*4000;
      /** Adresse: Strassenname
       * 
       * ArtPlusAttribut: Objekte.Strasse
       */
      Adr_Strasse : TEXT*4000;
      /** Adresse: Hausnummer und Suffix
       * 
       * ArtPlusAttribut: Objekte.Hausnummer
       */
      Adr_Hausnummer : TEXT*4000;
      /** Code fuer die Art des Objektes. Bsp.: Schloss, Ruine, Portal, ...
       * 
       * ArtPlusAttribut: Objekte.Gattung/Typo
       */
      Objektart_Code : TEXT*4000;
      /** Sprechender Text fuer die Art des Objektes.
       * 
       * ArtPlusAttribut: Objekte.Gattung/Typo
       */
      Objektart_Text : TEXT*4000;
      /** Code fuer die kantonale Schutzstufe des Objektes.
       * (geschuetzt, schuetzenswert, erhaltenswert, ...)
       * 
       * ArtPlusAttribut: Objekte.Grunddaten.Einstufung Kanton
       */
      Schutzstufe_Code : MANDATORY TEXT*4000;
      /** Sprechender Text fuer die kantonale Schutzstufe des Objektes.
       * 
       * ArtPlusAttribut: Objekte.Grunddaten.Einstufung Kanton
       */
      Schutzstufe_Text : MANDATORY TEXT*4000;
      /** Gibt an, ob das Denkmal kommunal geschuetzt ist.
       * 
       * ArtPlusAttribut: Objekte.Grunddaten.Schutz Gemeinde
       */
      SchutzDurchGemeinde : MANDATORY BOOLEAN;
      /** In ArtPlus gefuerte "Zentrumskoordinaten" zu einem Denkmal.
       * 
       * Sie bestehen, da die GIS-Koordinaten nur kostspielig in die
       * ArtPlus-Reports etc. einzubinden sind.
       * Fuer ein im GIS als Einzelpunkt repraesentiertes Denkmal sind
       * die Koordinaten redundant.
       * 
       * ArtPlusAttribute: Objekte.Koordinaten
       */
      Geometrie : MANDATORY GeometryCHLV95_V1.Coord2;
      UNIQUE ID;
    END Denkmal;

    /** Link-Tabelle auf die Rechtsvorschrift.
     * 
     * In ArtPlus sind die Informationen zu einer Schutzverfuegung
     * (= Rechtsvorschrift) n:1 zu einem Denkmal modelliert.
     * Bei allen Rechtsvorschriften mit Bezug zu mehr als einem Denkmal
     * sind die Informationen in dieser Klasse folglich mehrfach vorhanden.
     */
    CLASS Rechtsvorschrift_Link =
      /** Fremdschluessel auf Denkmal
       */
      Denkmal_ID : MANDATORY 1 .. 2147483647;
      /** Fremdschluessel auf die im Multimedia-Modul von
       * ArtPlus abgelegte Datei der Rechtsvorschrift.
       * 
       * ArtPlusAttribut: Multimedia.ID
       */
      Multimedia_ID : 1 .. 2147483647;
      /** URL, unter welcher die entsprechende Schutzverfuegung
       * mittels HTTP(S) geladen werden kann.
       * 
       * ArtPlusAttribut: Keines (dynamisch generiert)
       */
      Multimedia_Link : URI;
      /** Titel der Schutzverfuegung.
       * 
       * Wird aufgrund der bestehenden Feldverwendung in ArtPlus auf
       * das Bemerkungsfeld gemappt.
       * 
       * ArtPlusAttribut: Objekte.Grunddaten.Schutzverfuegung.Titel
       */
      Titel : MANDATORY TEXT*4000;
      /** Nummer der Schutzverfuegung (so vorhanden).
       * 
       * Falls Schutzverfuegung = RRB --> RRB-Nr.
       * 
       * ArtPlusAttribut: Objekte.Grunddaten.Schutzverfuegung.RRB-Nr
       */
      Nummer : TEXT*4000;
      /** Datum, an welchem die Rechtsvorschrift beschlossen wurde.
       * Bei RRB: Datum der RRB-Sitzung, an welcher der Beschluss gefasst wurde.
       * Kann bei vorbereiteten Daten NULL sein (Bsp. Wenn Einsprachefrist laeuft).
       * 
       * ArtPlusAttribut: Objekte.Grunddaten.Schutzverfuegung.Datum
       */
      Datum : INTERLIS.XMLDate;
      /** Bei von Gemeinde erlassener Schutzverfuegung: BfS-Nummer der Gemeinde
       * 
       * ArtPlusAttribut: Objekte.Grunddaten.Schutzverfuegung.BfS-Nummer
       */
      BfsNummer : 0 .. 2147483647;
      /** Dummy: Workaround um AGDI regression. Tabellen ohne Geometrie koennen nicht mehr erfasst werden.
       */
      DummyGeometrie : GeometryCHLV95_V1.Coord2;
    END Rechtsvorschrift_Link;

  END Fachapplikation;

  /** Umfasst die Klassen, deren Daten direkt mittels QGIS gepflegt werden
   * (Geometrie und "Soft-Referenz" auf die entsprechende Klasse im TOPIC ArtPlus).
   * Datenoriginal in der Edit-DB, mittels QGIS-Desktop gepflegt.
   */
  TOPIC GIS =

    /** Enthaelt die Geometrie in der Form von Polygonen oder Punkten:
     * - Polygon beispielsweise bei Gebaeuden.
     * - Punkt beispielsweise bei Wirtshaus-Schild.
     * Fuer beispielsweise Kreuzwege koennen mehrere Punkte dem gleichen
     * Denkmal (= ganzer Kreuzweg) zugewiesen werden.
     */
    CLASS Geometrie =
      /** Fremdschluessel auf das Denkmal.
       */
      Denkmal_ID : MANDATORY 1 .. 2147483647;
      /** Denkmalgeometrie, falls als Polygon abgebildet
       */
      Polygon : GeometryCHLV95_V1.Surface;
      /** Denkmalgeometrie, falls als Point abgebildet
       */
      Punkt : GeometryCHLV95_V1.Coord2;
      MANDATORY CONSTRAINT
        DEFINED (Polygon) OR DEFINED (Punkt);
    END Geometrie;

  END GIS;

END SO_ADA_Denkmal_20191128.
','2019-12-13 10:33:05.569');
INSERT INTO ada_denkmalschutz.T_ILI2DB_MODEL (filename,iliversion,modelName,content,importDate) VALUES ('CoordSys-20151124.ili','2.3','CoordSys','!! File CoordSys.ili Release 2015-11-24

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

','2019-12-13 10:33:05.569');
INSERT INTO ada_denkmalschutz.T_ILI2DB_MODEL (filename,iliversion,modelName,content,importDate) VALUES ('Units-20120220.ili','2.3','Units','!! File Units.ili Release 2012-02-20

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

','2019-12-13 10:33:05.569');
INSERT INTO ada_denkmalschutz.T_ILI2DB_MODEL (filename,iliversion,modelName,content,importDate) VALUES ('CHBase_Part1_GEOMETRY_20110830.ili','2.3','GeometryCHLV03_V1{ INTERLIS CoordSys Units} GeometryCHLV95_V1{ INTERLIS CoordSys Units}','/* ########################################################################
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
','2019-12-13 10:33:05.569');
INSERT INTO ada_denkmalschutz.T_ILI2DB_SETTINGS (tag,setting) VALUES ('ch.ehi.ili2db.createMetaInfo','True');
INSERT INTO ada_denkmalschutz.T_ILI2DB_SETTINGS (tag,setting) VALUES ('ch.ehi.ili2db.multiPointTrafo','coalesce');
INSERT INTO ada_denkmalschutz.T_ILI2DB_SETTINGS (tag,setting) VALUES ('ch.ehi.ili2db.nameOptimization','topic');
INSERT INTO ada_denkmalschutz.T_ILI2DB_SETTINGS (tag,setting) VALUES ('ch.ehi.ili2db.multiSurfaceTrafo','coalesce');
INSERT INTO ada_denkmalschutz.T_ILI2DB_SETTINGS (tag,setting) VALUES ('ch.ehi.ili2db.maxSqlNameLength','60');
INSERT INTO ada_denkmalschutz.T_ILI2DB_SETTINGS (tag,setting) VALUES ('ch.ehi.ili2db.beautifyEnumDispName','underscore');
INSERT INTO ada_denkmalschutz.T_ILI2DB_SETTINGS (tag,setting) VALUES ('ch.ehi.ili2db.multiLineTrafo','coalesce');
INSERT INTO ada_denkmalschutz.T_ILI2DB_SETTINGS (tag,setting) VALUES ('ch.ehi.ili2db.jsonTrafo','coalesce');
INSERT INTO ada_denkmalschutz.T_ILI2DB_SETTINGS (tag,setting) VALUES ('ch.ehi.ili2db.StrokeArcs','enable');
INSERT INTO ada_denkmalschutz.T_ILI2DB_SETTINGS (tag,setting) VALUES ('ch.ehi.ili2db.createForeignKey','yes');
INSERT INTO ada_denkmalschutz.T_ILI2DB_SETTINGS (tag,setting) VALUES ('ch.ehi.ili2db.uniqueConstraints','create');
INSERT INTO ada_denkmalschutz.T_ILI2DB_SETTINGS (tag,setting) VALUES ('ch.ehi.sqlgen.createGeomIndex','True');
INSERT INTO ada_denkmalschutz.T_ILI2DB_SETTINGS (tag,setting) VALUES ('ch.ehi.ili2db.uuidDefaultValue','uuid_generate_v4()');
INSERT INTO ada_denkmalschutz.T_ILI2DB_SETTINGS (tag,setting) VALUES ('ch.ehi.ili2db.multilingualTrafo','expand');
INSERT INTO ada_denkmalschutz.T_ILI2DB_SETTINGS (tag,setting) VALUES ('ch.ehi.ili2db.defaultSrsAuthority','EPSG');
INSERT INTO ada_denkmalschutz.T_ILI2DB_SETTINGS (tag,setting) VALUES ('ch.ehi.ili2db.arrayTrafo','coalesce');
INSERT INTO ada_denkmalschutz.T_ILI2DB_SETTINGS (tag,setting) VALUES ('ch.ehi.ili2db.catalogueRefTrafo','coalesce');
INSERT INTO ada_denkmalschutz.T_ILI2DB_SETTINGS (tag,setting) VALUES ('ch.ehi.ili2db.defaultSrsCode','2056');
INSERT INTO ada_denkmalschutz.T_ILI2DB_SETTINGS (tag,setting) VALUES ('ch.ehi.ili2db.createForeignKeyIndex','yes');
INSERT INTO ada_denkmalschutz.T_ILI2DB_SETTINGS (tag,setting) VALUES ('ch.ehi.ili2db.createEnumDefs','multiTable');
INSERT INTO ada_denkmalschutz.T_ILI2DB_SETTINGS (tag,setting) VALUES ('ch.ehi.ili2db.inheritanceTrafo','smart2');
INSERT INTO ada_denkmalschutz.T_ILI2DB_SETTINGS (tag,setting) VALUES ('ch.ehi.ili2db.sender','ili2pg-4.3.1-23b1f79e8ad644414773bb9bd1a97c8c265c5082');
INSERT INTO ada_denkmalschutz.T_ILI2DB_SETTINGS (tag,setting) VALUES ('ch.ehi.ili2db.numericCheckConstraints','create');
INSERT INTO ada_denkmalschutz.T_ILI2DB_SETTINGS (tag,setting) VALUES ('ch.ehi.ili2db.localisedTrafo','expand');
INSERT INTO ada_denkmalschutz.T_ILI2DB_SETTINGS (tag,setting) VALUES ('ch.interlis.ili2c.ilidirs','%ILI_FROM_DB;%XTF_DIR;http://models.interlis.ch/;%JAR_DIR');
INSERT INTO ada_denkmalschutz.T_ILI2DB_META_ATTRS (ilielement,attr_name,attr_value) VALUES ('SO_ADA_Denkmal_20191128','technicalContact','mailto:agi@so.ch');
