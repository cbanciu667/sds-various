#!/bin/bash

# Check if gedit is running
# -x flag only match processes whose name (or command line if -f is
# specified) exactly match the pattern.

# touch /etc/openvpn/start_vpn.log

if pgrep -x "openvpn" > /dev/null
then
    echo ${date}  >> /etc/openvpn/start_vpn.log
    echo -e " openvpn already running\n" >> /var/log/start_vpn.log
else
    echo ${date} >> /etc/openvpn/start_vpn.log
    echo -e " starting vpn\n" >> /var/log/start_vpn.log
    openvpn /etc/openvpn/host.conf &
fi
