#!/bin/bash

# To change DNS server update /etc/netplan/*.conf and add for for your network interface:
# 
#       nameservers:
#         addresses: [8.8.8.8, 8.8.4.4]

netplan apply --debug
systemctl restart systemd-resolved
systemd-resolve --status