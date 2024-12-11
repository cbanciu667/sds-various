cd ~
sudo yum update -y

# install latest cloudflared agent on the EC2 proxy instance (AUTOMATED)
echo "check latest release on https://github.com/cloudflare/cloudflared/releases"
echo "Fixing UDP buffers bug https://github.com/quic-go/quic-go/wiki/UDP-Buffer-Sizes"
sudo sysctl -w net.core.rmem_max=2500000
sudo sysctl -w net.core.wmem_max=2500000
sudo sysctl -p

# install latest cloudflared agent on the EC2 proxy instance (AUTOMATED)
wget https://github.com/cloudflare/cloudflared/releases/download/2024.2.0/cloudflared-linux-aarch64.rpm
sudo rpm -i -U cloudflared-linux-aarch64.rpm
sudo mkdir /etc/cloudflared

# login to cloudflare to produce cert.pem
cloudflared tunnel login

# copy the tunnel authentication key
sudo cp /home/ssm-user/.cloudflared/cert.pem /etc/cloudflared/

# create the tunnel to Cloudflare and aknowledge the tunnel ID
cloudflared tunnel create name-tunnel

# copy the tunnel definition file
sudo cp /home/ssm-user/.cloudflared/b224db2e-b875-4e83-94d6-146574df49ff.json /etc/cloudflared/

# Configure cloudflared as per example bellow
sudo nano /etc/cloudflared/config.yml

# Example:
tunnel: b224db2e-b875-4e83-94d6-zxxxxxxx
credentials-file: /etc/cloudflared/b224db2e-b875-4e83-94d6-146574df49ff.json
warp-routing:
    enabled: true

# install, enable start cloudflared the service
sudo cloudflared service install
sudo systemctl enable cloudflared.service
sudo systemctl start cloudflared.service

# check that cloudflared service is running ok
sudo systemctl status cloudflared.service

# add the routing configuration for the tunnel
# CIDR is the VPC one
cloudflared tunnel route ip add 10.0.0.0/16 b224db2e-b875-4e83-94d6-zzzzzzzzz

# check the routing configuration
cloudflared tunnel route ip show

# reboot
sudo reboot

# Upgrade cloudflared
cd ~
sudo yum update -y
echo "check latest release on https://github.com/cloudflare/cloudflared/releases"
echo "Fixing UDP buffers bug https://github.com/quic-go/quic-go/wiki/UDP-Buffer-Sizes"
sudo sysctl -w net.core.rmem_max=2500000
sudo sysctl -w net.core.wmem_max=2500000
sudo sysctl -p
wget https://github.com/cloudflare/cloudflared/releases/download/2023.10.0/cloudflared-linux-aarch64.rpm
sudo rpm -i -U cloudflared-linux-aarch64.rpm
sleep 2
sudo systemctl restart cloudflared.service
sleep 2
cloudflared --version
sleep 2
sudo systemctl status cloudflared.service
sudo reboot
