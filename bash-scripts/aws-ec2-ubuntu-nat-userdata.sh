#!/bin/bash

set -ex
apt update
echo iptables-persistent iptables-persistent/autosave_v4 boolean true | sudo debconf-set-selections
echo iptables-persistent iptables-persistent/autosave_v6 boolean true | sudo debconf-set-selections
apt -y install iptables-persistent
echo net.ipv4.ip_forward=1 >> /etc/sysctl.conf
echo net.ipv6.conf.all.forwarding=1 >> /etc/sysctl.conf
iptables -t nat -A POSTROUTING -o ens5 -s ${VPCCidr} -j MASQUERADE
iptables -t nat -A POSTROUTING -o ens5 -s ${VPCCidr} -j MASQUERADE
sysctl -p
mkdir -p /etc/sysconfig/
/sbin/iptables-save > /etc/sysconfig/iptables
# echo 'iptables-restore < /etc/iptables.conf' > /etc/rc.local
cat <<EOF > /etc/rc.local
#!/bin/sh -ex
#
# rc.local
#
# This script is executed at the end of each multiuser runlevel.
# Make sure that the script will "exit 0" on success or any other
# value on error.
#
# In order to enable or disable this script just change the execution
# bits.
#
# By default this script does nothing.
iptables-restore < /etc/sysconfig/iptables
exit 0
EOF

hostnamectl set-hostname ec2-nat-instance
echo `curl http://169.254.169.254/latest/meta-data/local-ipv4` ec2-nat-instance >> /etc/hosts
region=$(curl http://169.254.169.254/latest/dynamic/instance-identity/document | grep region | awk -F\" '{print $4}')
echo $region
export DEBIAN_FRONTEND=noninteractive
export DEBCONF_NONINTERACTIVE_SEEN=true

apt install -y apt-transport-https ca-certificates software-properties-common wget curl unzip git htop zip jq tzdata rsync python3.8 python3-setuptools python3-pip

ln -fs /usr/share/zoneinfo/Europe/Bucharest /etc/localtime
dpkg-reconfigure --frontend noninteractive tzdata

reboot