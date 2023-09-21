# As a MIKROTIK fan, i played around with a script that performs backups back in 2019 :)
#
# https://help.mikrotik.com/docs/display/ROS/Scripting

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
