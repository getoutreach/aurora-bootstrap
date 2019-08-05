# Aurora clone and export runbook

This document contains all the steps necessary to 

## Clone Aurora

## Set up S3 buckets

## Set up S3 permissions

## Set up cluster permissions
  
## Run the exporter

### Deploy the container to the appropriate namespace

### Set up the env vars

The container needs to know what to connect to and the way the script works is it gets the values from its env. Here's what you need to set up:

* `DB_HOST`: The *CLONED* host to run the script against.
* `DB_USER`: The user of the host allowed to run `SELECT OUTFILE INTO S3` against all the databases
* `DB_PASS`: The password for `DB_USER`
* `PPREFIX`[optional]: The prefix for databases to be scanned. So, like, if you name all your databases `fun_objects`, `fun_properties`, etc, you would set the `PREFIX` to be `fun` and the bootstrapper will omit any on-prefixed databases. Helpful if you don't want to export `information_schema`, `performance_schema` and `innodb`

## Run the converter

Once the export is completed and your CSV is all good to go, you will need to convert that raw data into consumable JSON.

*NOTE*: The converter will run against the specified folder and all subfolders.

### Set up env vars

The exporter needs to know what data to process and where to process it into. It gets the values from the env. Here's what you need to set up:

* `INPUT_CSV_PATH`: the full `s3://bukkit/path/to/source/parent/dir` of the directory that will be recursively converted.
* `EXPORT_JSON_PATH`: the full `s3://bukkit/path/to/target/parent/dir` of the directory that will receive all the converted files with identical directory strucuture as the source

## Delete the clone

This has to be done manually and by a member of the Platform team. So go ask them. 