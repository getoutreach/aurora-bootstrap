# Aurora clone and export runbook

Because the `SELECT OUTFILE` command is atomic and potentially locking, we would be wise to run it against read-only DB hosts. 

## Set up S3 buckets

The buckets you will need to set up: 

* JSON bucket: This is the bucket where the JSON will export

## Set up permissions

Since the data can be sensitive, we should be sure to have a limited set of permissions for the buckets and the Aurora clusters.

All we have to do is set up the Aurora permissions for the `SELECT INTO OUTFILE S3` statement requires permissions described [here](https://docs.aws.amazon.com/AmazonRDS/latest/AuroraUserGuide/AuroraMySQL.Integrating.Authorizing.IAM.S3CreatePolicy.html)
  
## Run the exporter

Deploying the exporter will run the job, but there's some minimal setup that needs to happen.

### Env vars

The container needs to know what to connect to and the way the script works is it gets the values from its env. Here's what you need to set up:

* `DB_HOST`: The __READONLY__ host to run the script against.
* `DB_USER`: The user of the host allowed to run `SELECT OUTFILE INTO S3` against all the databases
* `DB_PASS`: The password for `DB_USER`
* `PPREFIX`*[optional]*: The prefix for databases to be scanned. So, like, if you name all your databases `fun_objects`, `fun_properties`, etc, you would set the `PREFIX` to be `fun` and the bootstrapper will omit any on-prefixed databases. Helpful if you don't want to export `information_schema`, `performance_schema` and `innodb`
* `EXPORT_BUCKET`: The name of the bucket into which the CSV will go
* `BLACKLISTED_TABLES`*[optional]*: If you want to omit tables, you can list them here in a comma separated format. We support db-agnostic tables (e.g. `super_sensitive_data` will be ignored in every db scanned) as well as db-specific(e.g. `users.photos` will only ignore `photos` in the `users` database, but nowhere else (`kittens.photos` will still backfill)). You can also specify the tables in a regular expression starting and wnding with a `/` (e.g. `/.*password.*/` will filter out any table with `password` in its or its database's name)
* `BLACKLISTED_FIELDS`*[optional]*: Similarly to the table blacklisting, if you wanted to blacklist fields, you can list them in the same format as the tables, including the regexp.