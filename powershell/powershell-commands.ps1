# Enabling remote PowerShell
Enable-PSRemoting -Force
Get-Service WinRM
Start-Service WinRM
Set-Item WSMan:\localhost\Service\AllowUnencrypted -Value $true
Set-Item WSMan:\localhost\Client\TrustedHosts -Value '*'  # You can specify your Mac's IP instead of '*'
New-NetFirewallRule -Name "WinRM HTTP" -DisplayName "Windows Remote Management (HTTP-In)" -Enabled True -Direction Inbound -Protocol TCP -LocalPort 5985 -Action Allow
Enable-WSManCredSSP -Role Server -Force
pwsh

# connect to remote PowerShell
$cred = Get-Credential
Enter-PSSession -ComputerName <WindowsServer_IP> -Credential $cred -Authentication Negotiate
Enter-PSSession -ComputerName 192.168.1.100 -Credential Administrator -Authentication Negotiate
Enter-PSSession -ComputerName 192.168.1.100 -Credential $cred -UseSSL
Invoke-Command -ComputerName 192.168.1.100 -Credential $cred -ScriptBlock { Get-Process }

# connect to remote PowerShell with OpenSSH
Get-WindowsFeature -Name OpenSSH*
Add-WindowsFeature -Name OpenSSH-Server
Start-Service sshd
Set-Service -Name sshd -StartupType Automatic
New-NetFirewallRule -Name "OpenSSH-Server" -DisplayName "OpenSSH Server" -Enabled True -Direction Inbound -Protocol TCP -LocalPort 22 -Action Allow
pwsh

Enter-PSSession -HostName sds-hw-node1.soliddistributedsystems.io -UserName Administrator
Enter-PSSession -ComputerName sds-hw-node1.soliddistributedsystems.io -Credential Administrator -Authentication Negotiate

# add admin to local ssh
ssh Administrator@sds-hw-node1.soliddistributedsystems.io

# complete OpenSSH configuration
Get-WindowsCapability -Online | Where-Object Name -like 'OpenSSH*'
Add-WindowsCapability -Online -Name OpenSSH.Server~~~~0.0.1.0
Start-Service sshd
Set-Service -Name sshd -StartupType Automatic
Get-Service sshd
notepad C:\ProgramData\ssh\sshd_config
# Find and uncomment (or add) this line at the bottom:
Subsystem powershell C:\Program Files\PowerShell\7\pwsh.exe -sshs -NoLogo -NoProfile
Subsystem powershell C:\Windows\System32\WindowsPowerShell\v1.0\powershell.exe -sshs -NoLogo -NoProfile

Restart-Service sshd

notepad C:\ProgramData\ssh\sshd_config
# Add (or uncomment) the following lines:
PermitRootLogin yes
PasswordAuthentication yes
AllowUsers Administrator

Restart-Service sshd

Enter-PSSession -HostName sds-hw-node1.soliddistributedsystems.io -UserName Administrator
OR
ssh Administrator@sds-hw-node1.soliddistributedsystems.io
OR
ssh Administrator@sds-hw-node1.soliddistributedsystems.io "pwsh -sshs"

# Get current IP addresses
Get-NetIPAddress | Where-Object { $_.AddressFamily -eq "IPv4" -and $_.InterfaceAlias -notlike "*Loopback*" } | Select-Object IPAddress

# Get external IP
(Invoke-WebRequest -Uri "http://ifconfig.me").Content

# Get Powershell version
$PSVersionTable.PSVersion