#!/bin/bash

/interface/wireguard add listen-port=WG_PORT name=main-wireguard
/interface/wireguard print
/interface/wireguard/peers add allowed-address=WG_CIDR,LAN_CIDR endpoint-address=b8fe0b6dad8d.sn.mynetname.net endpoint-port=WG_PORT interface=main-wireguard public-key="WG_PUBLIC_KEY"
/ip/address add address=WG_SERVER_IP/30 interface=main-wireguard network=WG_CIDR
/ip/route add dst-address=WG_CIDR gateway=main-wireguard
/ip/firewall/filter add action=accept chain=input dst-port=WG_PORT protocol=udp comment="Wireguard" place-before=2
/ip/firewall/filter add action=accept chain=input comment="Internal WireGuard traffic" src-address=WG_CIDR place-before=2
/ip/firewall/filter add action=accept chain=forward comment="Wireguard to LAN" in-interface=main-wireguard dst-address=LAN_CIDR place-before=2