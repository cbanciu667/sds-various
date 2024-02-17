#!/bin/bash

umount /mnt/datastore1
mount -t cifs //smb/datastore1$ /mnt/datastore1 -o username=shareusr@HOST.com,password=PASSWORD
mount -t cifs --verbose -o user=USER //IP_ADDRESS/home/gdrive/ /mnt/gdrive/
