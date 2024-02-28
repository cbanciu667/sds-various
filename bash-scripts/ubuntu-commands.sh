#!/bin/bash

base64 -w 0 < my_ssh_key
base64 < my_ssh_key # macos

shasum -a 256 file.tar
sha256sum file.tar

lshw -C memory

stat -c '%A %a %n' /etc/passwd

echo $(curl -s ifconfig.me) && curl ipinfo.io/ip

curl wttr.in/Bucharest

curl -K (--insecure) -I (--inspect)

find. -name *.png -type f -print | xargs tar -cvzf images.tar.gz

pbcopy < ~/.ssh/id_rsa.pub

ssh-copy-id user@hostname.example.com

cat SSH_PUBLIC_KEY.pub > ~/.ssh/authorized_keys && chmod 644 ~/.ssh.authorized_keys 

ssh -N -L 5900:0.0.0.0:5900 user@computer.net -i ~/.ssh/id_rsa

sudo -H -u OTHER_USER bash -c 'COMMAND' 
usermod -aG sudo username
visudo && nano /etc/sudoer

cat /etc/passwd | column -t -s

watch df –h
watch "du -skh /your-directory"

# background processes
nohup wget site.com/file.zi
nohup bash -c "(time bash executeScript 1 input fileOutput > scrOutput) &> timeUse.txt" &
# or use hapless: 
curl -i https://bmwlog.pp.ua/hapless-easily-run-and-manage-background-processes/watch 

hdparm -I /dev/sda
hdparm -T /dev/sda1
lsblk /dev/sda
smartctl -i /dev/sdc 
hddtemp /dev/sda1
grep -i sda /var/log/syslog*

netstat -tulpn

dpkg -r (-i) package.dpkg

tar -cvzf file.tar /folder/to/archive
tar -zcvf my-compressed.tar.gz /path/to/dir1/ /path/to/dir2/
tar -cvf - file1 file2 dir3 | gzip > archive.tar.gz
tar -jcvf my-compressed.tar.bz2 /path/to/dir1/
tar -zxvf archive.tar.gz -C /tmp
tar -zxvf archive.tar.gz
ssh user@box tar czf - /dir1/ > /destination/file.tar.gz
ssh user@box 'cd /dir1/ && tar -cf - file | gzip -9' >file.tar.gz
tar zcvf - /wwwdata | ssh vivek@192.168.1.201 "cat > /backup/wwwdata.tar.gz"
tar -xzvf file.tar

cat /etc/os-release
lsb release -a
lsb_release -cs

uname -r
mkdir -p

ls -alth

pssh -h pssh-hosts -l SSH_USER -i "df -h /"

find . -name "*.bak" -type f
find . -name "*.bak" -type f -delete
find . -name ‘\*.DS_Store’ -type f -delete
find ./ -type f -exec grep -H 'INFO' {} \;
find /directory_path -mtime -1 -ls
find . -mtime +15 -type f -delete
find /<directory> -newermt "-24 hours" -ls
find /u01/elasticsearch -type f -size +1000000k -exec ls -lh {} \; | awk '{ print $9 ":" $5 }'
find . -type f -name '*.md' | while read f; do mv "$f" "${f%.txt}"; done
find . -type f -exec du -h {} + | sort -hr # order files by size in a folder and its subfolders

ls | grep plugins | xargs rm -rf

du -ah /* 2>/dev/null | sort -rh | head -n 10

grep -rnw . -e 'cladmin'  || grep -rnw . -e 'rdsadmin'

multitail [-i] file1 [-i] file2

ps aux | grep php-fpm | cut -c 81 | sort | wc -l
ps aux | sort -rnk 4

kill $(ps aux | grep "$search_terms" | grep -v 'grep' | awk '{print $2}')

lsof /var/log/openvpn.log

ls /proc | less
pidof firefox
ps -p PID -o format
ps -p 2523 -o comm=

# ansible
ansible-vault encrypt user.pub  --vault-password-file ~/.ssh/id_rsa
ansible-vault decrypt user.pub  --vault-password-file ~/.ssh/id_rsa
ansible-playbook -i 'IP,' -c local
ansible-playbook -i 'localhost,' -c local deploy.yml --vault-password-file vault_key.pem
ansible-playbook -i inventory/inventory_01 test.yml --private-key ~/.ssh/my_ssh_key.pem --vault-password-file ~/.ssh/my_ssh_key.pem
ansible-galaxy init test-role-1
ansible speedup: set pipelinening = true, use strategy:free in playbooks or forks=20 in ansible.cfg

# openssl examples
openssl pkcs12 -in filename.pfx -out cert.pem -nodes
openssl pkcs12 -in filename.pfx -nocerts -out key.pem
openssl pkcs12 -in filename.pfx -clcerts -nokeys -out cert.pem
openssl rsa -in key.pem -out server.key
openssl enc -nosalt -aes-256-cbc -k hello-aes -P
openssl enc -nosalt -aes-256-cbc -k aes-secret -P -pass pass:'test1234!'
openssl enc -nosalt -aes-256-cbc -in wildcard_blockworks_ch.crt -out wildcard_certificate.crt.enc -base64 -K AFF3B77D5D9B9 -iv AAAAA
openssl enc -nosalt -aes-256-cbc -d -in wildcard_certificate.crt.enc -base64 -K AFF3BE1DFB77D5D9B9 -iv AAAAAAA
openssl req -new -config etc/client.conf -out certs/my_cert.csr -keyout certs/my_key.key
openssl ca -config etc/signing-ca.conf -in certs/my_cert.csr -out certs/my_cert.crt -extensions client_ext
openssl req -x509 -nodes -days 365 -newkey rsa:4096 -keyout /etc/keystore/server.key -out /etc/keystore/server.crt
openssl req -nodes -newkey rsa:2048 -keyout example.key -out example.csr -subj "/C=GB/ST=London/L=London/O=Global Security/OU=IT Department/CN=example.com"
openssl req -new -key example.key -out example.csr -subj "/C=GB/ST=London/L=London/O=Global Security/OU=IT Department/CN=example.com"
openssl genrsa -out key.pem 2048
openssl rsa -in key.pem -outform PEM -pubout -out public.pem
openssl genrsa -des3 -out private.pem 2048
openssl rsa -in private.pem -outform PEM -pubout -out public.pem
openssl ecparam -name prime256v1 -genkey -noout -out key.pem
openssl ec -in key.pem -pubout -out public.pem
openssl rsa -in private.pem -out private_unencrypted.pem -outform PEM

# iptables examples
iptables -t nat -A POSTROUTING -s 10.10.0.0/24 -d 192.168.1.0/24 -j MASQUERADE
iptables -t nat -A POSTROUTING -s 192.168.12.0/24 -o tun0 -j MASQUERADE
iptables -vL -t nat --line-numbers
iptables -F
iptables --flush
iptables --table nat --flush
iptables --delete-chain
iptables --table nat --delete-chain
iptables -vL -t filter
iptables -vL -t nat
iptables -vL -t mangle
iptables -vL -t raw
iptables -vL -t security
iptables -A INPUT -i tun0 -j ACCEPT 
iptables -A FORWARD -i tun0 -j ACCEPT
iptables -A FORWARD -o tun0 -j ACCEPT
iptables -A OUTPUT -o tun0 -j ACCEPT 
iptables -A FORWARD -i tun0 -o enp4s0 -s 172.16.2.0/255.255.255.0 -j ACCEPT 
iptables -t nat -A POSTROUTING -o enp4s0 -s 172.16.2.0/255.255.255.0 -j MASQUERADE


# Unattended Ubuntu updates
echo $(less /etc/apt/apt.conf.d/20auto-upgrades)
sudo dpkg-reconfigure -plow unattended-upgrades
sudo nano /etc/apt/apt.conf.d/50unattended-upgrades
sudo systemctl restart unattended-upgrades && sudo systemctl status unattended-upgrades
sudo systemctl status apt-daily.timer
sudo systemctl status apt-daily.service
sudo systemctl status apt-daily-upgrade.timer
sudo systemctl status apt-daily-upgrade.service
apt-config dump APT::Periodic::Update-Package-Lists && apt-config dump APT::Periodic::Unattended-Upgrade

# kubernetes - add apt on ubuntu
Kubernetes repos for Ubuntu/Debian:echo "deb [signed-by=/etc/apt/keyrings/kubernetes-apt-keyring.gpg] https://pkgs.k8s.io/core:/stable:/v1.28/deb/ /" | sudo tee /etc/apt/sources.list.d/kubernetes.list
curl -fsSL https://pkgs.k8s.io/core:/stable:/v1.28/deb/Release.key | sudo gpg --dearmor -o /etc/apt/keyrings/kubernetes-apt-keyring.gpgapt update

# RabbitMQ requirements
ulimit -n 65536 && echo 'fs.file-max=65535' | sudo tee -a /etc/sysctl.conf && sudo sysctl -p

# Minio S3 storage
mc alias set sds-minio-dev https://minio-dev.soliddistributedsystems.io/ AccessKeyId AccessKeySecret
mc admin info sds-minio-dev
mc cp --recursive ~/test.file sds-minio-dev/test-data/

# Routing related - checking and updating routes
# activate modules
sudo modprobe ip6table_filter -v
sudo modprobe xt_socket -v
sudo modprobe iptable_raw -v
sudo modprobe iptable_nat -v
sudo modprobe iptable_filter -v
sudo modprobe iptable_mangle -v
# install tracert
sudo apt install traceroute -y
# check routing table
netstat -rn
route -n
# check route to IP or DNS name
traceroute IP/DNS_NAME
# check with a protocol
traceroute -I ICMP IP/DNS_NAME
# check cilium BGP routes
cilium bgp routes