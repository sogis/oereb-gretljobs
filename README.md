# oereb-gretljobs

Contains GRETL jobs for publishing data to OEREB-Kataster

## Running a GRETL job locally using the GRETL wrapper script

For running a GRETL job using the GRETL wrapper script, see the `start-gretl.sh` command example below. Set any DB connection parameter environment variables before running the command.

If you want to set up development databases for developing new GRETL jobs, use the following `docker-compose` command before running your GRETL job in order to prepare the necessary DBs.

Start two DBs ("oereb" and "edit"), import data required for the data transformation (the so called legal basis data and some more files) into the "oereb" DB, and import demo data into the "edit" DB.

XTF files that are not available in this repo (Geotope, Denkmalschutz) contain not public data and are downloaded from a private S3 bucket.

Setup development environment for the various themes: see DEVELOP.md

Set environment variables containing the DB connection parameters and names of other resources:
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



