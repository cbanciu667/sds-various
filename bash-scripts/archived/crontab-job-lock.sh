#!/bin/bash

readonly PROGNAME=$(basename "$0")
readonly LOCKFILE_DIR=/tmp
readonly LOCK_FD=200
readonly LOCK_FILE=$LOCKFILE_DIR/$PROGNAME.lock

lock() {
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

eexit() {
    local error_str="$@"
    echo $error_str
    exit 1
}

lock $PROGNAME || eexit "$PROGNAME is already running"
trap 'rm -f "$LOCK_FILE"; exit $?' INT TERM EXIT

#### Your Code

while true; do
   echo "doing my thing "
   sleep 1
done
