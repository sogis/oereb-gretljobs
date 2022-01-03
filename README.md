# oereb-gretljobs

Contains GRETL jobs for publishing data to OEREB-Kataster

## Running a GRETL job locally using the GRETL wrapper script

For running a GRETL job using the GRETL wrapper script, see the `start-gretl.sh` command example below. Set any DB connection parameter environment variables before running the command.

If you want to set up development databases for developing new GRETL jobs, use the following `docker-compose` command before running your GRETL job in order to prepare the necessary DBs.

Start two DBs ("oereb" and "edit"), import data required for the data transformation (the so called legal basis data and some more files) into the "oereb" DB, and import demo data into the "edit" DB.

**TODO:** Ist das immer noch so?! Wahrscheinlich wegen geschützten Daten im Thema?!
XTF files that are not available on https://gitlab.com/sogis/oereb-v2/oereb-gretljobs/-/tree/main/development_dbs should be directly exported from the database into the GRETL-Job directory (development_dbs):

Denkmalschutz:
```
java -jar /usr/local/ili2pg-4.3.1/ili2pg.jar --export --dbhost geodb.rootso.org --dbdatabase edit --dbusr $USER --dbpwd $(awk -v dbhost=$DBHOST -F ':' '$1~dbhost{print $5}' ~/.pgpass) --disableValidation --models SO_ADA_Denkmal_20191128 --dbschema ada_denkmalschutz ada_denkmalschutz1.xtf
```

Geotope:
```
java -jar /usr/local/ili2pg-4.3.1/ili2pg.jar --export --dbhost geodb.rootso.org --dbdatabase edit --dbusr $USER --dbpwd $(awk -v dbhost=$DBHOST -F ':' '$1~dbhost{print $5}' ~/.pgpass) --disableValidation --models SO_AFU_Geotope_20200312 --dbschema afu_geotope afu_geotope.xtf
```

**TODO**: Fix gretl task names
When working on other OEREB topics, replace `createSchemaLandUsePlans replaceDataLandUsePlans` with the Gradle task names that handle your current OEREB topic:
``` 
docker-compose down # (this command is optional; it's just for cleaning up any already existing DB containers)
docker-compose run --rm --user $UID -v $PWD/development_dbs:/home/gradle/project gretl "sleep 20 && cd /home/gradle && gretl -b project/build-dev.gradle importFederalLegalBasisToOereb importCantonalLegalBasisToOereb createSchemaLandUsePlans replaceDataLandUsePlans"
```

Set environment variables containing the DB connection parameters åand names of other resources:
```
export ORG_GRADLE_PROJECT_dbUriEdit="jdbc:postgresql://edit-db/edit"
export ORG_GRADLE_PROJECT_dbUserEdit="gretl"
export ORG_GRADLE_PROJECT_dbPwdEdit="gretl"
export ORG_GRADLE_PROJECT_dbUriOereb="jdbc:postgresql://oereb-db/oereb"
export ORG_GRADLE_PROJECT_dbUserOereb="gretl"
export ORG_GRADLE_PROJECT_dbPwdOereb="gretl"
export ORG_GRADLE_PROJECT_geoservicesHostName="geo-t.so.ch"
export ORG_GRADLE_PROJECT_gretlEnvironment="dev"
export ORG_GRADLE_PROJECT_awsAccessKeyAgi="xy"
export ORG_GRADLE_PROJECT_awsSecretAccessKeyAgi="yx"
```

Start the GRETL job (use the --job-directory option to point to the desired GRETL job; find out the names of your Docker networks by running `docker network ls`):
```
./start-gretl.sh --docker-image sogis/gretl-runtime:latest --docker-network oereb-gretljobs_default --job-directory $PWD/oereb_nutzungsplanung/ importDataToStage refreshOerebWMSTablesStage
```
