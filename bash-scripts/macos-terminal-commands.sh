#!/bin/bash

# Routing related
# add temporary route
sudo route -n add -net 192.168.2.0/24 192.168.1.1
# delete temporary static route
sudo route -n delete 192.168.2.0/24
# verify routes
netstat -rn | grep 192.168.2.
# add routes permanently
sudo networksetup -setadditionalroutes "USB 10/100/1000 LAN" 192.168.2.0 255.255.255.0 192.168.1.1
# delete permanent route
sudo networksetup -setadditionalroutes "USB 10/100/1000 LAN"
# list network adapters
networksetup -listallnetworkservices
# list devices with numbers
networksetup -listnetworkserviceorder

# DNS related
# clear MACOS DNS cache
sudo killall -9 mDNSResponderHelper mDNSResponder

# Ports
sudo lsof -i -P | grep LISTEN | grep :$PORT

# Mount NFS volumes
sudo mount -t nfs -o resvport,rw 192.168.3.1:/dest_mount /private/nfs

# Kill apps
sudo kill -9 `pgrep -f GlobalProtect` && sudo rm -rf /Applications/GlobalProtect.app

# Kill MACOS extensions
kextstat | grep -v com.apple
kextfind -b com.checkpoint.cpfw -print
sudo rm -rf /Library/Extensions/cpfw.kext

# list packages installed with brew
brew leaves | xargs brew desc --eval-all

# init
# Setup Zsh + Oh my Zsh + Powerlevel10k
# Brew install and updates
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install.sh)"
brew install argocd aws-sam-cli azure-cli ansible bzip2 curl dapr-cli gcc git git-lfs gnupg go google-cloud-sdk gawk \
     guile helm htop jq terraform terraform-ls iamlive kubernetes-cli krew kubeseal kustomize libffi make jwt-cli node nano openjdk openvpn pyenv \
     redis rust sops tektoncd-cli terragrunt telnet tree watch eksctl wget wakeonlan yarn yq zlibzsh-syntax-highlighting kubeconform
brew update && brew upgrade
# list installed apps
ls -lah /Applications