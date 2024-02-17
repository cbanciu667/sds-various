#!/bin/bash

echo 'Some Postgres related commands:'

# Kubernetes PG:
# run "echo $POSTGRES_PASSWORD" on the Postgres POD


# Install pg_dump. Example:
sudo apt install dirmngr ca-certificates software-properties-common apt-transport-https lsb-release
curl -ycurl -fSsL https://www.postgresql.org/media/keys/ACCC4CF8.asc | gpg --dearmor | sudo tee /usr/share/keyrings/postgresql.gpg > /dev/null
echo deb [arch=amd64,arm64,ppc64el signed-by=/usr/share/keyrings/postgresql.gpg] http://apt.postgresql.org/pub/repos/apt/ $(lsb_release -cs)-pgdg main | sudo tee /etc/apt/sources.list.d/postgresql.list
sudo apt update
sudo apt install postgresql-client-15 postgresql-15

# Create aws_s3 extension
CREATE EXTENSION aws_s3 CASCADE;

# pg_dump examples:
PGPASSWORD="$DB_PASSWORD" pg_dump -h "$DB_HOST" -U "$DB_USER" -d "$DB_NAME" -t "${schema_name}.*" -Fd -j 15 -Z0 -O -x -f "$dump_file" "${schema_name}.*" >/dev/null # using parallelism and not archiving
PGPASSWORD="$DB_PASSWORD" pg_dump -h "$DB_HOST" -U "$DB_USER" -d "$DB_NAME" -j 15 -Z 0 -O -x -F d "$schema_name" # simple dump
PGPASSWORD="$DB_PASSWORD" pg_dump -h "$DB_HOST" -U "$DB_USER" -d "$DB_NAME" -s -t "${schema_name}.*" -Fc -O -x -f "$dump_file.sql" >/dev/null
pg_dump -h DB_DNS -U DB_USER -d DB_NAME -j 15 -Z 0 -O -x -F d -f FILE_NAME
pg_restore -h DB_DNS -U DB_USER -d DB_NAME -j 15 -O -x -Fd ./DIR_NAME >/dev/null 2>%1
pg_restore -h DB_DNS -U DB_USER -d DB_NAME -j 15 -O -x -F d /path/to/DB_NAME
pg_restore -h DB_DNS -U DB_USER -d DB_NAME -j 15 -O -x -F d /path/to/DB_NAME >/dev/null 2>&1


# AWS import/export features
SELECT aws_s3.table_import_from_s3 (
     'schema.table'
     , ''
     , '(format csv, delimiter E''\t'')'
     , aws_commons_create_s3_uri('s3_bucket', 's3_object_prefix', 'aws_region')
);

SELECT aws_s3.query_export_to_s3 (
     'SELECT * FROM schema.table'
     , options := 'format csv, delimiter E''\t'''
     , aws_commons_create_s3_uri('s3_bucket', 's3_object_prefix', 'aws_region')
);