# Aurora clone and export runbook

Because the `SELECT OUTFILE` command is atomic and potentially locking, we would be wise to run it against a DB clone.

## Clone Aurora

Clone your database as described in the docs [here](https://docs.aws.amazon.com/AmazonRDS/latest/AuroraUserGuide/Aurora.Managing.Clone.html)

## Set up S3 buckets

The buckets you will need to set up: 

* CSV bucket: This is the bucket where the initial CSV export
* JSON bucket: The bucket into which we will put the converted JSON

## Set up permissions

Since the data can be sensitive, we should be sure to have a limited set of permissions for the buckets and the Aurora clusters.

There need to be 4 sets of permissions:

* Auroa expoter: the `SELECT INTO OUTFILE S3` statement requires permissions described [here](https://docs.aws.amazon.com/AmazonRDS/latest/AuroraUserGuide/AuroraMySQL.Integrating.Authorizing.IAM.S3CreatePolicy.html)
* CSV expoter: The expoter job needs access to Aurora. This may not be necessary inside K8s, but somehting to investigate.
* CSV-to-JSON formatter: the formatter will need list, and read premissions to the CSV bucket; and list, read, and writer persmissions to the JSON bucket
* JSON bucket reader: this bucket will contain sensitive data and needs to have limited permissions.
  
## Run the exporter

Deploying the exporter will run the job, but there's some minimal setup that needs to happen.

### Env vars

The container needs to know what to connect to and the way the script works is it gets the values from its env. Here's what you need to set up:

* `DB_HOST`: The *CLONED* host to run the script against.
* `DB_USER`: The user of the host allowed to run `SELECT OUTFILE INTO S3` against all the databases
* `DB_PASS`: The password for `DB_USER`
* `PPREFIX`[optional]: The prefix for databases to be scanned. So, like, if you name all your databases `fun_objects`, `fun_properties`, etc, you would set the `PREFIX` to be `fun` and the bootstrapper will omit any on-prefixed databases. Helpful if you don't want to export `information_schema`, `performance_schema` and `innodb`

## Run the converter

Once the export is completed and your CSV is all good to go, you will need to convert that raw data into consumable JSON.

*NOTE*: The converter will run against the specified folder and all subfolders.

### Env vars

The exporter needs to know what data to process and where to process it into. It gets the values from the env. Here's what you need to set up:

* `INPUT_CSV_PATH`: the full `s3://bukkit/path/to/source/parent/dir` of the directory that will be recursively converted.
* `EXPORT_JSON_PATH`: the full `s3://bukkit/path/to/target/parent/dir` of the directory that will receive all the converted files with identical directory strucuture as the source

## Delete the clone

This has to be done manually and by a member of the Platform team. So go ask them. 