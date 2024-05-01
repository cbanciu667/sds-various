#!/bin/bash

# installation tested on Ubuntu Server LTS
# easy-rsa
mkdir ~/easy-rsa
ln -s /usr/share/easy-rsa/* ~/easy-rsa/
sudo chown  myuser ~/easy-rsa
chmod 700 ~/easy-rsa
cd ~/easy-rsa
# add env vard
nano vars 
set_var EASYRSA_ALGO "ec"
set_var EASYRSA_DIGEST "sha512"
# run
./easyrsa init-pki
./easyrsa build-ca nopass
./easyrsa gen-req vpnsrv nopass
./easyrsa sign-req server vpnsrv
openvpn --genkey --secret ta.key
sudo cp /home/myuser/easy-rsa/pki/private/vpnsrv.key /etc/openvpn/server/
sudo cp /home/myuser/easy-rsa/pki/issued/vpnsrv.crt /etc/openvpn/server/
sudo cp /home/myuser/easy-rsa/pki/ca.crt /etc/openvpn/server/
sudo cp ta.key /etc/openvpn/server/

# revocation list for OpenVPN clients
./easyrsa revoke client_name
./easyrsa gen-crl
sudo cp /etc/openvpn/easy-rsa/pki/crl.pem /etc/openvpn/
sudo systemctl restart openvpn-server@server.service

sudo nano /etc/openvpn/server/server.conf
tcp 449
proto tcp
dev tun
ca ca.crt
cert vpnsrv.crt
key vpnsrv.key
tls-auth ta.key 1
server 10.10.10.0 255.255.255.0
push "route 10.100.100.0 255.255.240.0"
push "route 10.101.101.0 255.255.240.0"
; socket-flags TCP_NODELAY  # if using TCP, uncomment this to reduce latency
float                       # accept authenticated packets from any IP to allow clients to roam
keepalive 10 60             # send keepalive pings every 10 seconds, disconnect clients after 60 seconds of no traffic
user nobody
group nogroup
persist-key                 # keep the key in memory, don't reread it from disk
persist-tun                 # keep the virtual network device open between restarts
tls-version-min 1.3
tls-version-max 1.3         # use the highest available TLS version, you can add "or-highest" after 1.3
cipher AES-128-GCM          # data channel cipher
# TLS 1.3 encryption settings - USE ONLY TLS 1.3
tls-ciphersuites TLS_CHACHA20_POLY1305_SHA256:TLS_AES_128_GCM_SHA256
dh none                     # disable static Diffie-Hellman parameters since we're using ECDHE
ecdh-curve secp384r1        # use the NSA's recommended curve
# tls-server                  # this tells OpenVPN which side of the TLS handshake it is, use tls-client on clients
key-direction 1             # related to ta.key
crl-verify crl.pem          # must be updated after each revocation
remote-cert-tls client      # require client certificates to have the correct extended key usage
verify-client-cert require  # reject connections without certificates
tls-cert-profile preferred
log-append  /var/log/openvpn/openvpn.log
verb 4
mute 20
explicit-exit-notify 1
# client-cert-not-required
plugin /usr/lib/aarch64-linux-gnu/openvpn/plugins/openvpn-plugin-auth-pam.so login

sudo nano /etc/sysctl.conf
add:
net.ipv4.ip_forward = 1
sudo sysctl -p

sudo systemctl -f enable openvpn-server@server.service
sudo systemctl start openvpn-server@server.service
sudo systemctl status openvpn-server@server.service

# openvpn clients
under normal user:
cd ~/easy-rsa
./easyrsa gen-req VPN_USER nopass
sudo ./easyrsa sign-req client VPN_USER
cp /home/myuser/easy-rsa/pki/private/VPN_USER.key ~/vpn-clients/
cp /home/myuser/easy-rsa/pki/issued/VPN_USER.crt ~/vpn-clients/
sudo cp /etc/openvpn/server/ta.key ~/vpn-clients/
sudo cp /etc/openvpn/server/ca.crt ~/vpn-clients/

# on the client
sudo apt install openvpn -y

sudo nano /etc/default/openvpn and uncomment AUTOSTART="all"
sudo mv /etc/openvpn/sds-vpn-client.conf /etc/openvpn/client.conf

cp ca.crt ta.key sds-host.crt sds.host  /etc/client/

nano /etc/openvpn/client.conf
client
proto tcp
port 449
remote vpn.domain.com
dev tun
ca ca.crt
cert /etc/client/client.crt
key /etc/client/client.key
tls-auth ta.key 1
key-direction 1
nobind
user nobody
group nogroup
persist-key
persist-tun
remote-cert-tls server
resolv-retry infinite
tls-version-min 1.3
tls-version-max 1.3 
cipher AES-128-GCM
# TLS 1.3 encryption settings - USE ONLY TLS 1.3
tls-ciphersuites TLS_CHACHA20_POLY1305_SHA256:TLS_AES_128_GCM_SHA256
ecdh-curve secp384r1 # use the NSA-'s recommended curve
# tls-client #be the client side of the TLS handshake
tls-cert-profile preferred #require certificates to use modern key sizes and signatures
auth-nocache # don't cache credentials in memory
setenv ALLOW_PASSWORD_SAVE 0 #disallow saving of passwords
log-append  /var/log/openvpn/openvpn.log
verb 4
mute 20

sudo systemctl enable openvpn@client.service
sudo systemctl daemon-reload
sudo service openvpn@client start
ip addr

# revoking openvpn clients
cd ~/easy-rsa
./easyrsa revoke VPN_USER
./easyrsa gen-crl
sudo cp /home/myuser/easy-rsa/pki/crl.pem /etc/openvpn/server/

# routing - give access to openvpn clients to network behind vpn server
# add push route command into the openvpn server config and run:
iptables -t nat -A POSTROUTING -s LAN_SUBNET_CIDR -o eth0 -j MASQUERADE

# what is missing to access from lan to lan, IPTables on iroute client to allow cross-network:
# https://forums.openvpn.net/viewtopic.php?t=27152
