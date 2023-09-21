# As an Ubiquiti UNIFI fan, i have built a script to manage my controlles with docker
#
# https://help.ui.com/hc/en-us/articles/11444786290071-Connecting-to-UniFi-and-Remote-Management

# In case you migrate, you have to backup and restore the unifi controller from the old one

docker run -d \
  --name=unifi-controller-home \
  -e PUID=1000 \
  -e PGID=1000 \
  -p 8443:8443 \
  -p 3478:3478/udp \
  -p 10001:10001/udp \
  -p 8080:8080 \
  -p 1900:1900/udp  \
  -p 8843:8843  \
  -p 8880:8880  \
  -p 6789:6789  \
  -p 5514:5514/udp  \
  -v /Users/cbanciu/unifi-storage/home/config:/config \
  --restart unless-stopped \
  lscr.io/linuxserver/unifi-controller:latest


# Now access the UniFi Controller web UI using the URL https://IP_Address:8443
# Now for UniFi Controller to adopt your devices such as access points, you need to change the inform IP address. This can be done by navigating to Settings > System Settings > Other configurations.
# Enable network discovery and check the Override inform host. Also, provide your IP Address or hostname on which the container is running as shown.

# on APs:
ssh ubnt@$device-IP
set-inform http://$address:8080/inform

# Note, if you are on a restricted MacOS, STOP MacOS firewall TEMPORARELY!