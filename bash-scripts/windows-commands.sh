#!/bin/bash

# NEW WINDOWS11 HOST CONFIGURATION - example

1. Install latest PowerShell version:
winget search Microsoft.PowerShell
winget install --id Microsoft.Powershell --source winget

2. Start the latest PowerShell version terminal in Administrative mode and perform Windows configuration bellow
3. Run:
Set-ExecutionPolicy AllSigned
Set-ExecutionPolicy Bypass

4. Install choco: 
Set-ExecutionPolicy Bypass -Scope Process -Force; [System.Net.ServicePointManager]::SecurityProtocol = [System.Net.ServicePointManager]::SecurityProtocol -bor 3072; iex ((New-Object System.Net.WebClient).DownloadString('https://community.chocolatey.org/install.ps1'))

5. Activate choco global prompt confirmation:
choco feature enable -n=allowGlobalConfirmation

6. Install tools:
choco install dotnet python terraform awscli awssamcli awstools.powershell awscli-session-manager terragrunt git git-lfs vscode argocd-cli kubernetes-cli kubernetes-helm argocd-cli lens gpg4win putty

7. Configure ssh credentials by adding ssh key to .ssh , aws cli credentials aws --configure and kubectl credentials

8. Upgrade choco:
choco upgrade all

9. Enable Hyper-V:
Enable-WindowsOptionalFeature -Online -FeatureName Microsoft-Hyper-V-All

10. Install WSL
wsl --install -d Ubuntu-22.04
wsl --list -v

11. Install Docker Desktop and configure integration with WSL

12. Install Windows Admin Center to manage Hyper-V