# Developing ÖREB-GRETL-Jobs

## Env Vars
```
export ORG_GRADLE_PROJECT_dbUriEdit="jdbc:postgresql://edit-db/edit"
export ORG_GRADLE_PROJECT_dbUserEdit="gretl"
export ORG_GRADLE_PROJECT_dbPwdEdit="gretl"
export ORG_GRADLE_PROJECT_dbUriOerebV2="jdbc:postgresql://oereb-db/oereb"
export ORG_GRADLE_PROJECT_dbUserOerebV2="gretl"
export ORG_GRADLE_PROJECT_dbPwdOerebV2="gretl"
export ORG_GRADLE_PROJECT_geoservicesHostName="geo-t.so.ch"
export ORG_GRADLE_PROJECT_gretlEnvironment="dev"
export ORG_GRADLE_PROJECT_awsAccessKeyAgi="xy"
export ORG_GRADLE_PROJECT_awsSecretAccessKeyAgi="yx"
export ORG_GRADLE_PROJECT_awsAccessKeyAda="foo"
export ORG_GRADLE_PROJECT_awsSecretAccessKeyAda="bar"
```

## Test data
Für die meisten Themen sind Testdaten im Github-Repo im Ordner `development_dbs` vorhanden. Für einige Themen beinhalten die Originaldaten geschützte Informationen. Diese Testdaten sind momentan auf S3 im Bucket "ch.so.agi.oereb.data4dev-restricted" gespeichert.

## Setup Dev-Umgebung

- Bestückt die Edit-DB.
- Funktioniert auch mit `start-gretl.sh`.

Konfiguration:
```
docker compose run --rm --user $UID gretl -b build-dev.gradle --project-dir=development_dbs replaceResponsibleOfficesToEdit replaceCantonalLegalBasisToEdit replaceCantonalThemesToEdit replaceCantonalLogosToEdit replaceCantonalTextToEdit replaceAvailabilityToEdit replaceSubunitOfLandRegisterToEdit
```

Amtliche Vermessung:
```
docker compose run --rm --user $UID gretl -b build-dev.gradle --project-dir=development_dbs replaceCadastralSurveying
```

Gewässerschutz:
```
docker compose run --rm --user $UID gretl -b build-dev.gradle --project-dir=development_dbs replaceDataGroundwaterProtection
```

Naturreservate (Einzelschutz)
```
docker compose run --rm --user $UID gretl -b build-dev.gradle --project-dir=development_dbs replaceDataEinzelschutzNaturreservat
```

Geotope (Einzelschutz):
```
docker compose run --rm --user $UID gretl -b build-dev.gradle --project-dir=development_dbs replaceDataEinzelschutzGeotop
```

Denkmal (Einzelschutz):
```
docker compose run --rm --user $UID gretl -b build-dev.gradle --project-dir=development_dbs replaceDataEinzelschutzDenkmal
```

Nutzungsplanung (auch für Planungszonen und Gewässerraum)
```
docker compose run --rm -u $UID gretl -b build-dev.gradle --project-dir=development_dbs replaceDataLandUsePlans replaceCantonalDataLandUsePlans
```

Statische Waldgrenzen:
``` 
docker compose down # (this command is optional; it's just for cleaning up any already existing DB containers)
docker compose run --rm --user $UID gretl -b build-dev.gradle --project-dir=development_dbs replaceDataStaticForestPerimeters
```

Waldreservate:
```
docker compose run --rm --user $UID gretl -b build-dev.gradle --project-dir=development_dbs replaceDataWaldreservate
```

## GRETL-Job

Start the GRETL job (use the --job-directory option to point to the desired GRETL job; find out the names of your Docker networks by running `docker network ls`):

Bundesgesetze:
```
docker compose run --rm -u $UID gretl --project-dir=oerebv2_bundesgesetze downloadData importData
```

Bundeskonfiguration:
```
docker compose run --rm -u $UID gretl --project-dir=oerebv2_bundeskonfiguration importFederalThemes importFederalLogos importFederalText
```

Zuständige Stellen:
```
docker compose run --rm -u $UID gretl --project-dir=oerebv2_konfiguration_zustaendigestellen/ exportData validateData importData uploadXtfToS3Geodata
```

Kantonale Gesetze:
```
docker compose run --rm -u $UID gretl --project-dir=oerebv2_konfiguration_gesetze/ exportData validateData importData uploadXtfToS3Geodata
```

Kantonale Themen:
```
docker compose run --rm -u $UID gretl --project-dir=oerebv2_konfiguration_themen/ exportData validateData importData uploadXtfToS3Geodata
```

Kantonale Logos:
```
docker compose run --rm -u $UID gretl --project-dir=oerebv2_konfiguration_logo/ exportData validateData importData uploadXtfToS3Geodata
```

Kantonale Texte:
```
docker compose run --rm -u $UID gretl --project-dir=oerebv2_konfiguration_text/ exportData validateData importData uploadXtfToS3Geodata
```

Verfügbarkeit:
```
docker compose run --rm -u $UID gretl --project-dir=oerebv2_konfiguration_verfuegbarkeit/ exportData validateData importData uploadXtfToS3Geodata
```

Grundbuchkreis:
```
docker compose run --rm -u $UID gretl --project-dir=oerebv2_konfiguration_grundbuchkreis/ exportData validateData importData uploadXtfToS3Geodata
```

Bundesdaten:
```
docker compose run --rm -u $UID gretl --project-dir=oerebv2_bundesdaten importData
```

PLZ/Ortschaft:
```
docker compose run --rm -u $UID gretl --project-dir=oerebv2_plzo/ importPLZO
```

KbS:
```
docker compose run --rm -u $UID gretl --project-dir=oerebv2_belastete_standorte/ unzipData validateData importDataToStage refreshOerebWMSTablesStage importDataToLive refreshOerebWMSTablesLive uploadXtfToS3Geodata
```

Grundwasserschutz:
```
docker compose run --rm -u $UID gretl --project-dir=oerebv2_grundwasserschutz/ deleteFromOereb importResponsibleOfficesToOereb importSymbolsToOereb importEmptyTransferToOereb transferData exportData replaceWmsServer validateData importDataToStage refreshOerebWMSTablesStage importDataToLive refreshOerebWMSTablesLive zipXtfFile uploadXtfToS3Geodata
```

Naturreservat (Einzelschutz):
```
docker compose run --rm -u $UID gretl --project-dir=oerebv2_einzelschutz_naturreservat/ deleteFromOereb importResponsibleOfficesToOereb importSymbolsToOereb importEmptyTransferToOereb transferData exportData replaceWmsServer validateData importDataToStage refreshOerebWMSTablesStage importDataToLive refreshOerebWMSTablesLive zipXtfFile uploadXtfToS3Geodata
```

Geotope (Einzelschutz):
```
docker compose run --rm -u $UID gretl --project-dir=oerebv2_einzelschutz_geotop/ deleteFromOereb importResponsibleOfficesToOereb importSymbolsToOereb importEmptyTransferToOereb transferData validateData importDataToStage refreshOerebWMSTablesStage importDataToLive refreshOerebWMSTablesLive zipXtfFile uploadXtfToS3Geodata
```

Denkmal (Einzelschutz):
```
docker compose run --rm -u $UID gretl --project-dir=oerebv2_einzelschutz_denkmal/ deleteFromOereb importResponsibleOfficesToOereb importSymbolsToOereb importEmptyTransferToOereb transferData exportData replaceWmsServer validateData exportPdfFromDatabase uploadPdfToS3Stage importDataToStage refreshOerebWMSTablesStage copyPdfToS3Live importDataToLive refreshOerebWMSTablesLive zipXtfFile uploadXtfToS3Geodata
```

Waldgrenzen:
```
docker compose run --rm -u $UID gretl --project-dir=oerebv2_waldgrenzen/ deleteFromOereb importResponsibleOfficesToOereb importSymbolsToOereb importEmptyTransferToOereb transferData exportData validateData importDataToStage refreshOerebWMSTablesStage importDataToLive refreshOerebWMSTablesLive zipXtfFile uploadXtfToS3Geodata
```

Amtliche Vermessung:
```
docker compose run --rm -u $UID gretl --project-dir=oerebv2_av/ transferAV_live
```

Planungszonen:
```
docker compose run --rm -u $UID gretl --project-dir=oerebv2_planungszonen/ deleteFromOereb importResponsibleOfficesToOereb importSymbolsToOereb importEmptyTransferToOereb transferData exportData replaceWmsServer validateData importDataToStage refreshOerebWMSTablesStage importDataToLive refreshOerebWMSTablesLive zipXtfFile uploadXtfToS3Geodata
```

Waldreservate:
```
docker compose run --rm -u $UID gretl --project-dir=oerebv2_waldreservate/ deleteFromOereb importResponsibleOfficesToOereb importSymbolsToOereb importEmptyTransferToOereb transferData exportData replaceWmsServer importDataToStage refreshOerebWMSTablesStage importDataToLive refreshOerebWMSTablesLive zipXtfFile uploadXtfToS3Geodata
........
```

Gewässerraum:
```
docker compose run --rm -u $UID gretl --project-dir=oerebv2_gewaesserraum/ deleteFromOereb importResponsibleOfficesToOereb importSymbolsToOereb importEmptyTransferToOereb transferData exportData replaceWmsServer validateData importDataToStage refreshOerebWMSTablesStage importDataToLive refreshOerebWMSTablesLive zipXtfFile uploadXtfToS3Geodata
```

Nutzungsplanung:

Mit der Umstellung auf eine gemeindeweise Publikation muss zusätzlich die BFS Nummer als Parameter übergeben werden mit `-Pbfsnr=XXXX`.
```
docker compose run --rm -u $UID gretl -Pbfsnr=2527 --project-dir=oerebv2_nutzungsplanung deleteFromOereb importResponsibleOfficesToOereb importSymbolsToOereb importEmptyTransferToOereb transferData exportData replaceWmsServer validateData importDataToStage refreshOerebWMSTablesStage importDataToLive refreshOerebWMSTablesLive zipXtfFile uploadXtfToS3Geodata
```

Nutzungsplanung kantonal:
```
docker compose run --rm -u $UID gretl --project-dir=oerebv2_nutzungsplanung_kanton/ deleteFromOereb importResponsibleOfficesToOereb importSymbolsToOereb importEmptyTransferToOereb transferData exportData replaceWmsServer validateData importDataToStage refreshOerebWMSTablesStage importDataToLive refreshOerebWMSTablesLive zipXtfFile uploadXtfToS3Geodata
```

## Import config data into gdi db

Einmaliger Import in die Edit-DB. Nachführung wird in der Datenbank gemacht. Import in die oereb-DB wird ausgehend von der Edit-DB gemacht.

**TODO** Betriebshandbuch

```
java -jar apps/ili2pg-4.3.1/ili2pg-4.3.1.jar --dbhost geodb-t.rootso.org --dbport 5432 --dbdatabase edit --dbusr USERNAME --dbpwd PASSWORD --dbschema agi_konfiguration_oerebv2 --importTid --importBid --models OeREBKRM_V2_0 --dataset zustaendigestellen --dbparams Downloads/db.properties --replace Downloads/oereb_konfiguration/ch.so.agi.oereb_zustaendigestellen_V2_0.xtf

java -jar apps/ili2pg-4.3.1/ili2pg-4.3.1.jar --dbhost geodb-t.rootso.org --dbport 5432 --dbdatabase edit --dbusr USERNAME --dbpwd PASSWORD --dbschema agi_konfiguration_oerebv2 --importTid --importBid --models OeREBKRM_V2_0 --dataset gesetze --dbparams Downloads/db.properties --replace Downloads/oereb_konfiguration/ch.so.sk.oereb_gesetze_V2_0.xtf

java -jar apps/ili2pg-4.3.1/ili2pg-4.3.1.jar --dbhost geodb-t.rootso.org --dbport 5432 --dbdatabase edit --dbusr USERNAME --dbpwd PASSWORD --dbschema agi_konfiguration_oerebv2 --importTid --importBid --models OeREBKRM_V2_0 --dataset ch.admin.v_d.oereb_gesetze --dbparams Downloads/db.properties --replace Downloads/oereb_konfiguration/OeREBKRM_V2_0_Gesetze_20210414.xml

java -jar apps/ili2pg-4.3.1/ili2pg-4.3.1.jar --dbhost geodb-t.rootso.org --dbport 5432 --dbdatabase edit --dbusr USERNAME --dbpwd PASSWORD --dbschema agi_konfiguration_oerebv2 --importTid --importBid --models OeREBKRMkvs_V2_0 --dataset ch.admin.v_d.oereb_themen --dbparams Downloads/db.properties --replace Downloads/oereb_konfiguration/OeREBKRM_V2_0_Themen_20220301.xml

java -jar apps/ili2pg-4.3.1/ili2pg-4.3.1.jar --dbhost geodb-t.rootso.org --dbport 5432 --dbdatabase edit --dbusr USERNAME --dbpwd PASSWORD --dbschema agi_konfiguration_oerebv2 --importTid --importBid --models OeREBKRMkvs_V2_0 --dataset themen --dbparams Downloads/db.properties --replace Downloads/oereb_konfiguration/ch.so.agi.oereb_themen_V2_0.xtf

java -jar apps/ili2pg-4.3.1/ili2pg-4.3.1.jar --dbhost geodb-t.rootso.org --dbport 5432 --dbdatabase edit --dbusr USERNAME --dbpwd PASSWORD --dbschema agi_konfiguration_oerebv2 --importTid --importBid --models OeREBKRMkvs_V2_0 --dataset logo --dbparams Downloads/db.properties --replace Downloads/oereb_konfiguration/ch.so.agi.oereb_logo_V2_0.xtf

java -jar apps/ili2pg-4.3.1/ili2pg-4.3.1.jar --dbhost geodb-t.rootso.org --dbport 5432 --dbdatabase edit --dbusr USERNAME --dbpwd PASSWORD --dbschema agi_konfiguration_oerebv2 --importTid --importBid --models OeREBKRMkvs_V2_0 --dataset text --dbparams Downloads/db.properties --replace Downloads/oereb_konfiguration/ch.so.agi.oereb_text_V2_0.xtf

java -jar apps/ili2pg-4.3.1/ili2pg-4.3.1.jar --dbhost geodb-t.rootso.org --dbport 5432 --dbdatabase edit --dbusr USERNAME --dbpwd PASSWORD --dbschema agi_konfiguration_oerebv2 --importTid --importBid --models OeREBKRMkvs_V2_0 --dataset verfuegbarkeit --dbparams Downloads/db.properties --replace Downloads/oereb_konfiguration/ch.so.agi.oereb_verfuegbarkeit_V2_0.xtf

java -jar apps/ili2pg-4.3.1/ili2pg-4.3.1.jar --dbhost geodb-t.rootso.org --dbport 5432 --dbdatabase edit --dbusr USERNAME --dbpwd PASSWORD --dbschema agi_konfiguration_oerebv2 --importTid --importBid --models OeREBKRMkvs_V2_0 --dataset grundbuchkreis --dbparams Downloads/db.properties --replace Downloads/oereb_konfiguration/ch.so.agi.oereb_grundbuchkreis_V2_0.xtf
```

```
java -jar ../apps/ili2pg-4.3.1/ili2pg-4.3.1.jar --dbhost geodb-t.rootso.org --dbport 5432 --dbdatabase edit --dbusr USERNAME --dbpwd PASSWORD --dbschema arp_waldreservate_v1 --models SO_ARP_Waldreservate_20220607 --dbparams db.properties --import ch.so.arp.waldreservate_edit.xtf
```
