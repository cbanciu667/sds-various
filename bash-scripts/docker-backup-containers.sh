#!/bin/bash

# usage: ./backup_containers.sh CONTAINER_NAME

timestamp=`date '+%Y%m%d_%H%M%S'`
container_id=$(docker ps -aqf ancestor=$1)
backup_name=$1_backup_$timestamp
echo "$timestamp: Starting backup for container based on ancestor $1 with container id $container_id" >> backup-containers.log
echo "$timestamp: Backup name is $backup_name" >> backup-containers.log
docker commit -p $container_id $backup_name
docker save -o $backup_name.tar $backup_name
aws s3 cp ./$backup_name.tar  s3://docker-vol-backup/
echo "$timestamp: Cleaning up image base, tar archive and s3 archives older than 30 days..." >> backup-containers.log
rm -f ./$backup_name.tar
docker rmi  $backup_name

aws s3 ls docker-vol-backup/ | while read -r line;
   do
       createDate=`echo $line|awk {'print $1" "$2'}`
       createDate=`date -d"$createDate" +%s`
       olderThan=`date --date "30 days ago" +%s`
       if [[ $createDate -lt $olderThan ]]
           then
               fileName=`echo $line|awk {'print $4'}`
                   if [[ $fileName != "" ]]
                       then
                           aws s3 rm BUCKETNAME/$fileName
                   fi
       fi
done;
echo "$timestamp: Finished backup for container based on $1"
