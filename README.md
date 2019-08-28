# oereb-gretljobs
Contains GRETL jobs for publishing data to OEREB-Kataster

## Running a GRETL job locally

## Using docker-compose only

```
docker-compose run --rm --user $UID -v $(pwd)/oereb_testjob:/home/gradle/project gretl "cd /home/gradle/project && gretl"
```

## Using the GRETL wrapper script

```
docker-compose up
./start-gretl.sh --docker-image sogis/gretl-runtime:latest --docker-network oerebgretljobs_oerebgretljobs --job-directory $(pwd)/oereb_testjob/ testSqlEXecutor
```
