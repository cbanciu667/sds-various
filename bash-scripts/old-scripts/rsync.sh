#!/bin/bash

rsync -razv --ignore-existing /mnt/volume/volume/FOLDER/ /mediaFOLDERbackup01/FOLDER/
rsync -razv --ignore-existing --exclude 'FOLDER' /mnt/volume/volume/ /mediaFOLDERbackup02/

timestamp=`date '+%Y%m%d_%H%M%S'`

tar -zcvf /home/username/data/backups/home-username-$timestamp.tar.gz \
--exclude='/home/username/data' \
--exclude='/home/username/temp' \
--exclude='/home/username/VirtualBox\ VMs' \
--exclude='/home/username/.local' \
--exclude='/home/username/.cache' \
--exclude='/home/username/.config' \
--exclude='/home/username/.gradle' \
--exclude='/home/username/snap' \
--exclude='/home/username/Downloads' \
--exclude-backups \
--exclude-caches-all \
 /home/username


# r - recursive v - verbose c - checksum check not time and size
rsync -rvc --progress --delete --force --no-perms --no-owner --no-group --log-file=appkits_sync.log /home/username/data/appkits username@host:/data
rsync -rvc --progress --delete --force --no-perms --no-owner --no-group --log-file=backups_sync.log /home/username/data/backups username@host:/data
rsync -rvc --progress --delete --force --no-perms --no-owner --no-group --log-file=books_sync.log /home/username/data/books username@host:/data
rsync -rvc --progress --delete --force --no-perms --no-owner --no-group --log-file=iso_sync.log /home/username/data/iso username@host:/data
rsync -rvc --progress --delete --force --no-perms --no-owner --no-group --log-file=music_sync.log /home/username/data/music username@host:/data
rsync -rvc --progress --no-perms --no-owner --no-group --log-file=pictures_sync.log /home/username/data/music username@host:/data