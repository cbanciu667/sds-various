# As a MIKROTIK fan, i played around with a script that performs backups back in 2019 :)
#
# Reference: https://help.mikrotik.com/docs/display/ROS/Scripting

# Mikrotik Terminal
# /system ssh 172.19.3.12 "/interface ethernet disable ether5"
# /system script run disable_ether5
# /log info message="Backup run";
# /system backup save name=backup/auto.backup; 
# /log info message="pre SSH"; 
# /system ssh user=<user> address=<host> command="ftp ftp://<backup_user>:<pass>@router/%2Fbackup%2Fauto.backup -o /<path to backup>/auto-`date +%F`.backup"
# /log info message="post SSH"; 

:local SetInterface do={
	:local interfaces [:toarray $1];
	:local mode [:tostr $2];
	:local host $3;
	:local user [:tostr $4];
	:local cmd;
	#Set diabled bollean (true/false)
	:local disabled; :if ($mode="disable") do={:set $disabled true;} else {:set $disabled false;}
	#If host not set, interfaces are local
	if ([:typeof $host]="nothing") do={
		#Host wasn't set, then set local interfaces
		foreach interface in=[:toarray $interfaces] do={
			if ([:len [/interface find name=$interface]]>0) do={
				if ([/interface get value=disabled $interface]!=$disabled) do={
					/interface set disabled=$disabled $interface
					:log info ([/system clock get time]." '$interface' has been ".$mode."d.\r\n");										
				}
			} else {
				:log info ([/system clock get time]." '$interface' not exists.\r\n");
			}
		}
	} else {
		#Host has been set, then create ssh's command for sending
		foreach interface in=[:toarray $interfaces] do={
			:set $cmd ($cmd."if ([:len [/interface find name=$interface]]>0) do={	if ([/interface get value=disabled $interface]!=[:tobool $disabled]) do={		/interface set disabled=[:tobool $disabled] $interface;		:log info \"'$interface' $mode command has been received from '$[/system identity get name]' (via ssh).\"		} else {			:log warning \"$mode command from '$[/system identity get name]' (via ssh) was denied, '$interface' already $mode.\" 		}} else { :log error \"$mode command from '$[/system identity get name]' (via ssh) was failed, '$interface' not exists.\" }\r\n");
			:log info ([/system clock get time]." '$interface' $mode command has been sent to '$host' via ssh ($user).\r\n");
		}
		#Check if host responding
		if ([/ping $host count=1]>0) do={
			#Host response, connect to host and send command
			do {
				/system ssh $host user=$user command=$cmd
			} on-error={
				#Error caold not connect to host
				:log info ([/system clock get time]." $mode command was not sent, could not connect to 'host'.\r\n");
			}
		} else {
			#Host not respoding
			:log info ([/system clock get time]." $mode command was not sent, 'host' not responding.\r\n");
		}		
	}
}
$SetInterface $router2interfaces disable $router2address $router2username


# MIKROTIK COMMANDS EXAMPLES
/system logging action set memory memory-lines=1
/ user set 0 name = mono
/ user set 0 password = "my secret"
/ password
/log print
/log print follow where topics~".info"
/system logging action
/ip route add dst-address=192.168.0.0/24 gateway=192.168.1.1
/ip firewall nat add action=masquerade chain=srcnat comment="NATing lan network" out-interface=INTERFACE

/ip firewall nat
add chain=dstnat src-address=INTERNET_IP dst-port=21 protocol=tcp action=dst-nat to-addresses=LAN_IP to-ports=21

/ip firewall nat
add action=dst-nat chain=dstnat comment="FTP server - command" disabled=no  src-address=INTERNET_IP dst-port=21 in-interface=pppoe-out1 protocol=tcp to-addresses=LAN_IP to-ports=21
add action=dst-nat chain=dstnat comment="FTP server - data" disabled=no src-address=INTERNET_IP dst-port=30000-31000 in-interface=pppoe-out1 protocol=tcp to-addresses=LAN_IP to-ports=30000-31000

/export hide-sensitive

/ip firewall address-list
add address=INTERNET_IP list=AllowList
add address=INTERNET_IP list=AllowList

/ip firewall filter
add action=accept chain=forward comment="Port Forward 80" dst-address=INTERNET_IP dst-address-list=AllowList dst-port=80 protocol=tcp

/ip firewall nat
add action=dst-nat chain=dstnat comment="Port Forward 80" dst-address-list=\
AllowList dst-port=80 in-interface=ether1 protocol=tcp to-addresses=INTERNET_IP to-ports=80

/system clock set time-zone-name=Europe/Athens;/system ntp client set enabled=yes mode=unicast primary-ntp=NTP_SERVER_IP secondary-ntp=NTP_SERVER_IP
add chain=forward protocol=tcp dst-address=LAN_IP drop comment="Block this IP"

/ip firewall address-list
add list=blacklist address=1.1.1.1
add list=blacklist address=2.2.2.2
add list=blacklist address=3.3.0.0/16

/system reboot

/log print
/user-manager user print
/system package disable hotspot
/system reboot
/system scheduler set [find name=netwatchsch1] set start-time=([/sys clock get time] + 0:0:1)

# some hardening commands
/user set [find name=admin] password=Password123
/user set [find name=admin] name=test
/interface print
/interface set [find name=ether4] disabled=yes
/ip service print
/ip service set [find name=telnet] disabled=yes
/tool mac-server print
/tool mac-server set [find interface=all] disabled=yes
/tool mac-server print
/tool mac-server mac-winbox print
/tool mac-server mac-winbox set [find interface=all] disabled=yes
/tool mac-server ping print
/tool mac-server ping set enabled=no
/tool mac-server ping print
/ip neighbor discovery print
/ip neighbor discovery set [find name=ether5] discover=no
/ip neighbor discovery print
/ip ssh print
/ip ssh set strong-crypto=yes
/ip ssh print
/ip settings print
/ip settings set rp-filter=strict
/ip socks print
/ip socks set enabled=no
/tool bandwidth-server print
/tool bandwidth-server set enabled=no
/tool bandwidth-server print
/ip dns print
/ip dns set allow-remote-requests=no
/system scheduler
/system script add name=test
/system script edit [/system script find name=test] source


# SSL Certificates
# Upload all 4 files created by letsencrypt
#
/certificate import file-name=fullchain.pem passphrase=""
/certificate import file-name=privkey.pem passphrase=""
/file remove fullchain.pem
/file remove privkey.pem
# Activate certificates with
/certificate print
/ip service set www-ssl certificate=fullchain.pem_0
/ip service set api-ssl certificate=fullchain.pem_0
# Choose cert.pem in the services area