# As a MIKROTIK fan, i have built some IPSEC tunnels between all my devices
#
# References: 
# https://www.youtube.com/watch?v=uVag_e475zc
# https://mivilisnet.wordpress.com/2016/11/29/site-to-site-mikrotik-ipsec-tunnel/
# 
#
# IMPORTANT:
# Make sure your Mikrotik router has hardware support for the chosen encryption parameters. Check Hardware acceleration section here:
# https://wiki.mikrotik.com/wiki/Manual:IP/IPsec

# Clear logs and configure ipsec debuggging
/system logging action
set 0 memory-lines=0 # (or system >> logging >> Actions >> Memory >> 0) - this will clear the logs
set 0 memory-lines=1000 # (or system >> logging >> Actions >> Memory >> 1000) - this will restore the number of lines

/system logging
add prefix=ipsec topics=ipsec # debugging set for ipsec

# Configure Firewall
/ip firewall filter
add action=accept chain=input protocol=ipsec-esp comment="allow L2TP VPN (ipsec-esp)"
add action=accept chain=input dst-port=1701 protocol=udp comment="allow L2TP VPN (1701/udp)"
add action=accept chain=input dst-port=4500 protocol=udp comment="allow L2TP VPN (4500/udp)"
add action=accept chain=input dst-port=500 protocol=udp comment="allow L2TP VPN (500/udp)"
# forward remote lan traffic
add action=accept chain=forward src-address=REMOTE_LAN_CIDR dst-address=LOCAL_LAN_CIDR comment="Forward remote traffic"
# optional remote ping to external address
add action=accept chain=input src-address=REMOTE_WAN_IP protocol=icmp comment="Forward remote traffic"

# Configure essential NAT rule and place it on number 0 !!!!
/ip firewall nat
add chain=srcnat action=accept place-before=0 src-address=LOCAL_LAN_CIDR dst-address=REMOTE_LAN_CIDR

# Optional, maybe not required - to reduce cpu load
/ip firewall raw
add action=notrack chain=prerouting src-address=LOCAL_LAN_CIDR dst-address=REMOTE_LAN_CIDR
add action=notrack chain=prerouting src-address=LOCAL_LAN_CIDR dst-address=REMOTE_LAN_CIDR

# IPSEC configuration - similar on both routers
/ip ipsec profile add name=TARGET_NAME-ipsec-profile enc-algorithm=aes-256 hash-algorithm=sha256 dh-group=modp2048
/ip ipsec peer add name=TARGET_NAME profile=TARGET_NAME-ipsec-profile exchange-mode=ike2 address=REMOTE_INTERNET_IP
/ip ipsec identity add peer=TARGET_NAME auth-method=pre-shared-key generate-policy=port-strict secret=TUNNEL_SECRET_PASSWORD
/ip ipsec proposal update name=default auth-algorithms=sha256 enc-algorithms=aes-256-cbc pfs-group=modp2048
/ip ipsec policy add peer=TARGET_NAME tunnel=yes src-address=REMOTE_LAN_CIDR dst-address=LOCAL_LAN_CIDR proposal=default action=encrypt