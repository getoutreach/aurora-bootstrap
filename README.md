# Bootstrapping Aurora to S3

The fastest way we found to get full table data out of Aurora into S3 is to use the Aurora feature of `SELECT INTO OUTFILE S3`. This repo automates this process to some degree. There are 2 scripts and a runbook for them.

## Scripts

There's a couple scripts here that do the automated listing: the expoter and the converter.

### Exporter

The expoter logs into the specified aurora instance, scans the databases, and their tables, and exports the lot into S3 in a CSV format.

### Converter

The converter takes the exported CSV format and turns it into JSON in a different bucket.

## Runbook

In order to get the scripts to run there's a few things that need to be set up. The runbook can be found [here](/getoutreach/aurora-bootstrap/blob/master/runbook.md)