#!/bin/bash

echo 'Some Postgres related commands:'

# Kubernetes PG:
# run "echo $POSTGRES_PASSWORD" on the Postgres POD
# Reset Bitnami container postgres user
kubectl exec -i -t -n dev postgres-dev-postgresql-0 -c postgresql -- sh
sed -ibak 's/^\([^#]*\)md5/\1trust/g' /opt/bitnami/postgresql/conf/pg_hba.conf
pg_ctl reload
psql -U postgres
postgres=# alter user postgres with password 'NEW_PASSWORD';
postgresl=# \q
sed -i 's/^\([^#]*\)trust/\1md5/g' /opt/bitnami/postgresql/conf/pg_hba.conf
pg_ctl reload

# Install pg_dump. Example:
sudo apt install dirmngr ca-certificates software-properties-common apt-transport-https lsb-release
curl -ycurl -fSsL https://www.postgresql.org/media/keys/ACCC4CF8.asc | gpg --dearmor | sudo tee /usr/share/keyrings/postgresql.gpg > /dev/null
echo deb [arch=amd64,arm64,ppc64el signed-by=/usr/share/keyrings/postgresql.gpg] http://apt.postgresql.org/pub/repos/apt/ $(lsb_release -cs)-pgdg main | sudo tee /etc/apt/sources.list.d/postgresql.list
sudo apt update
sudo apt install postgresql-client-15 postgresql-15

# Install extensions for AWS RDS Databases
CREATE EXTENSION aws_s3 CASCADE;
CREATE EXTENSION IF NOT EXISTS dblink;
CREATE EXTENSION IF NOT EXISTS pg_stat_statements;
CREATE EXTENSION IF NOT EXISTS pg_trgm;

# pg_dump examples:
PGPASSWORD="$DB_PASSWORD" pg_dump -h "$DB_HOST" -U "$DB_USER" -d "$DB_NAME" -t "${schema_name}.*" -Fd -j 15 -Z0 -O -x -f "$dump_file" "${schema_name}.*" >/dev/null # using parallelism and not archiving
PGPASSWORD="$DB_PASSWORD" pg_dump -h "$DB_HOST" -U "$DB_USER" -d "$DB_NAME" -j 15 -Z 0 -O -x -F d "$schema_name" # simple dump
PGPASSWORD="$DB_PASSWORD" pg_dump -h "$DB_HOST" -U "$DB_USER" -d "$DB_NAME" -s -t "${schema_name}.*" -Fc -O -x -f "$dump_file.sql" >/dev/null
pg_dump -h DB_DNS -U DB_USER -d DB_NAME -j 15 -Z 0 -O -x -F d -f FILE_NAME
pg_restore -h DB_DNS -U DB_USER -d DB_NAME -j 15 -O -x -Fd ./DIR_NAME >/dev/null 2>%1
pg_restore -h DB_DNS -U DB_USER -d DB_NAME -j 15 -O -x -F d /path/to/DB_NAME
pg_restore -h DB_DNS -U DB_USER -d DB_NAME -j 15 -O -x -F d /path/to/DB_NAME >/dev/null 2>&1
# example for firefly db migration
pg_dump -h old_host -U your_user -d fireflydb -F c -f /path/to/firefly_backup.dump
pg_restore -h new_host -U your_user -d fireflydb -F c /path/to/firefly_backup.dump


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

# Migration from RDS Aurora to standard RDS
PGPASSWORD="$DB_PASSWORD" pg_dump -h "$DB_HOST" -U "$DB_USER" -d "$DB_NAME" --schema-only -Fd -O -x -n "public" -f "public" > /dev/null
PGPASSWORD="$DB_PASSWORD" pg_dump -h "$DB_HOST" -U "$DB_USER" -d "$DB_NAME" --schema-only -Fd -O -x -f "${DB_NAME}" > /dev/null
pg_restore -h "$DB_HOST" -U "$DB_USER" -d "$DB_NAME" -Fd -n "public" "public" > /dev/null
pg_restore -h "$DB_HOST" -U "$DB_USER" -d "$DB_NAME" -Fd "$DB_NAME" > /dev/null
echo "Run data migration scripts and compare schemas."

# pg_dump and schema names with capital letters
echo "Specify schema names with capital leters like": "\"eXample\""

# list dbs
SELECT datname FROM pg_database;

# Using a DBLINK
CREATE EXTENSION dblink;

SELECT symbol, date, revenue
FROM dblink(
    'dbname=mydb host=mydb.myhost.com user=mydbuser password=myexamplepsw',
    'SELECT symbol, date, revenue 
     FROM "normalized".example_table
     LIMIT 1'
) AS remote_table(
    symbol TEXT,
    date DATE,
    revenue NUMERIC
);
