#!/usr/bin/env bash

### For postgres put the script to run under postgres user in order to work! ###

readonly PROGNAME=$(basename "$0")
readonly LOCKFILE_DIR=/tmp
readonly LOCK_FD=200
readonly LOCK_FILE=$LOCKFILE_DIR/$PROGNAME.lock

# directory to put the backup files
BACKUP_DIR=/opt/backup-mysql

# MYSQL Parameters
MYSQL_UNAME=root
MYSQL_PWORD=

# Don't backup databases with these names
# Example: starts with mysql (^mysql) or ends with _schema (_schema$)
IGNORE_DB="(^mysql|_schema$)"

# include mysql and mysqldump binaries for cron bash user
PATH=$PATH:/usr/local/mysql/bin

# Number of days to keep backups
KEEP_BACKUPS_FOR=7 #days
# YYYY-MM-DD
TIMESTAMP=$(date +%F)


### PG Setup ###
# Location to place backups.
pg_backup_dir="/var/lib/postgresql/backups"
# Location of the backup logfile.
pg_logfile="$pg_backup_dir/postgres_backup.log"
# Allocated time
pg_timeslot=$(date +%F)
# Host of postgres server
pg_host=127.0.0.1

### MongoDB Setup ###
mongo_backup_dir="/opt/bakup-mongodb"
mongo_log_file="backup_mongodb.log"
mongo_uname="admin"
mongo_pwd=""

function lock() {
    local prefix=$1
    local fd=${2:-$LOCK_FD}
    echo "Obtaining lock $LOCK_FILE"

    # create lock file
    eval "exec $fd>$LOCK_FILE"

    # acquier the lock
    flock -n $fd \
        && return 0 \
        || return 1
}

function eexit() {
    local error_str="$@"
    echo $error_str
    exit 1
}

function delete_old_backups()
{
  echo "Deleting $BACKUP_DIR/*.sql.gz older than $KEEP_BACKUPS_FOR days"
  find $BACKUP_DIR -type f -name "*.sql.gz" -mtime +$KEEP_BACKUPS_FOR -exec rm {} \;
}

function mysql_login() {
  local mysql_login="-u $MYSQL_UNAME"
  if [ -n "$MYSQL_PWORD" ]; then
    local mysql_login+=" -p$MYSQL_PWORD"
  fi
  echo $mysql_login
}

function database_list() {
  local show_databases_sql="SHOW DATABASES WHERE \`Database\` NOT REGEXP '$IGNORE_DB'"
  echo $(mysql $(mysql_login) -e "$show_databases_sql"|awk -F " " '{if (NR!=1) print $1}')
}

function echo_status(){
  printf '\r';
  printf ' %0.s' {0..100}
  printf '\r';
  printf "$1"'\r'
}

function backup_database(){
    backup_file="$BACKUP_DIR/$TIMESTAMP.$database.sql.gz"
    output+="$database => $backup_file\n"
    echo_status "...backing up $count of $total databases: $database"
    $(mysqldump $(mysql_login) $database | gzip -9 > $backup_file)
}

function backup_databases(){
  local databases=$(database_list)
  local total=$(echo $databases | wc -w | xargs)
  local output=""
  local count=1
  for database in $databases; do
    backup_database
    local count=$((count+1))
  done
  echo -ne $output | column -t
}

function pg_delete_old_backups() {
  if [ "$(whoami)" != "postgres" ]; then
      echo "Script must be run as user: postgres" >> $pg_logfile
      exit -1
  fi
  echo "Deleting $pg_backup_dir/*.gz older than $KEEP_BACKUPS_FOR days"
  find $pg_backup_dir -type f -name "*.gz" -mtime +$KEEP_BACKUPS_FOR -exec rm {} \;
}

function backup_pg_databases(){
  if [ "$(whoami)" != "postgres" ]; then
        echo "Script must be run as user: postgres" >> $pg_logfile
        exit -1
  fi
  mkdir -p $pg_backup_dir
  touch $pg_logfile
  databases=`psql --list|grep UTF8|awk '{ print $1 }' | head -n -2`

  for i in $databases; do
        echo "Backup and Vacuum complete in $pg_timeslot for time slot $pg_timeslot on database: $i " >> $pg_logfile
        /usr/bin/vacuumdb -z $i >/dev/null 2>&1
        /usr/bin/pg_dump $i | gzip > "$pg_backup_dir/postgresql-$i-$pg_timeslot-database.gz"
  done

}

function mongo_delete_old_backups() {
  echo "Deleting $mongo_backup_dir/*.tar.gz older than $KEEP_BACKUPS_FOR days"
  find $mongo_backup_dir -type f -name "*.tar.gz" -mtime +$KEEP_BACKUPS_FOR -exec rm {} \;
}

function backup_mongo_databases() {
  mkdir -p $mongo_backup_dir
  touch $mongo_backup_dir/$mongo_log_file
  /usr/bin/mongodump --username $mongo_uname --password $mongo_pwd --out $mongo_backup_dir/mongodump-$(date +%F) >> $mongo_backup_dir/$mongo_log_file
  tar -czvf $mongo_backup_dir/mongodump-$(date +%F).tar.gz $mongo_backup_dir/mongodump-$(date +%F) >> $mongo_backup_dir/$mongo_log_file
  rm -rf $mongo_backup_dir/mongodump-$(date +%F) >> $mongo_backup_dir/$mongo_log_file
  $TIMESTAMP >> $mongo_backup_dir/$mongo_log_file
}


function info_print(){
  printf '=%.0s' {1..100}
  printf "\n"
}

lock $PROGNAME || eexit "$PROGNAME is already running"
trap 'rm -f "$LOCK_FILE"; exit $?' INT TERM EXIT

#### Your Code

#MongoDB
if [ $1 == "mongo" ]; then
    echo "Backing up mongo"
    backup_mongo_databases
    mongo_delete_old_backups
elif [ $1 == "postgres" ]; then
### Postgres backup
    echo "Backing up postgres"
    backup_pg_databases
    pg_delete_old_backups
elif [ $1 == "mysql" ]; then
### MySQL backup
    mkdir -p $BACKUP_DIR
    touch $BACKUP_DIR/backup.log
    delete_old_backups >> $BACKUP_DIR/backup.log
    info_print >> $BACKUP_DIR/backup.log
    backup_databases >> $BACKUP_DIR/backup.log
    info_print >> $BACKUP_DIR/backup.log
    echo $TIMESTAMP >> $BACKUP_DIR/backup.log
    printf "All backed up!\n\n" >> $BACKUP_DIR/backup.log
else
    echo "Please try to run ./backup.sh [mongo, postgres, mysql]"
fi