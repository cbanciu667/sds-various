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

# further rsync commands
rsync -azP --delete --ignore-existing -e "ssh -i ~/.ssh/id_rsa_sync" /mnt/data host:/mnt
rsync -rtv /Users/ciu/workspace/ /Users/username/Google\ Drive/workspace_work --delete #### fast rsync command
rsync -raz --progress /var/www 10.1.1.1:/var
rsync --ignore-existing -raz --progress /var/www 10.1.1.1:/var
rsync --update -raz --progress /var/www 10.1.1.1:/var
rsync --dry-run --update -raz --progress /var/www 10.1.1.1:/var
rsync -e "ssh -i $HOME/.ssh/id_rsa_sync"  --ignore-existing --delete -raz --progress /mnt/data/filme USER@HOST:/mnt/data
rsync -e "ssh -i $HOME/.ssh/id_rsa_sync" --ignore-existing --delete -raz --progress /mnt/data USER@HOST:/mnt