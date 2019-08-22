# oereb-gretljobs
Contains GRETL jobs for publishing data to OEREB-Kataster

## Running a GRETL job locally

docker-compose run --rm --user $UID -v $(pwd)/[JOBDIRECTORY]:/home/gradle/project gretl "cd /home/gradle/project && gretl"
