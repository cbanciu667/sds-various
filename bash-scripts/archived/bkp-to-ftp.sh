#!/bin/bash

HOST="FTP_HOST"
USER="USER"
PASS="PASSWORD"
FTPURL="ftp://$USER:$PASS@$HOST"
LCD="/mnt/datastore"
RCD="/volume"

lftp -c "set ftp:list-options -a;
open '$FTPURL';
lcd $LCD;
cd $RCD;
mirror --reverse \
       --continue \
       --verbose \
       --exclude-glob temp/
#\
#       --exclude-glob a-file-to-exclude \
#       --exclude-glob a-file-group-to-exclude* \
#       --exclude-glob other-files-to-exclude"


HOST='FTP_SERVER'
USER='FTP_USER'
PASS='PASS'
TARGETFOLDER="/SOURCE FOLDER"
SOURCEFOLDER='/mnt/folder'

lftp -f "
set ftp:ssl-allow true
set ftp:ssl-force true
set ftp:ssl-protect-data true
set ftp:ssl-protect-list true
set file:charset utf8
set ftp:charset utf8
set mirror:set-permissions false
set log:enabled true
set log:file /root/backup_to_ftp.log
set log:level 3
open $HOST
user $USER $PASS
lcd $SOURCEFOLDER
mirror --reverse --delete --verbose $SOURCEFOLDER '${TARGETFOLDER}'
bye
"