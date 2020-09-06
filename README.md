# Bootstrapping Aurora to S3

The fastest way we found to get full table data out of Aurora into S3 is to use the Aurora feature of `SELECT INTO OUTFILE S3`. This repo automates this process to some degree.

## Exporter

The expoter logs into the specified aurora instance, scans the databases, and their tables, and exports the lot into S3 in a newline separated JSON format that matches Maxwell's Daemon JSON format.

```json
{ "database": "my_database",
  "table": "my_table",
  "type": "backfill",
  "ts": 1567041664,
  "data": {
    "id": 1,
    // ...etc.
  }
} 

```

## Running tests

The tests run inside a dockerized db, so you will need to

```bash
# start the database
$ docker-compose up -d
# load the fixtures into it
$ ./bin/test_setup
$ bundle install --gemfile=Gemfile.testing
$ bundle exec --gemfile=Gemfile.testing rake test
```

## Runbook

In order to get the scripts to run there's a few things that need to be set up. The runbook can be found [here](/runbook.md)