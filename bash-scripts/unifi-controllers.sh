echo 'docker compose for running the latest unifi controller:'

# services:
#   unifi-db-location:
#     image: docker.io/mongo:4.4
#     container_name: unifi-db-location
#     volumes:
#       - /Users/username/unifi-storage/location/mongodb/data:/data/db
#       - /Users/username/unifi-storage/location/mongodb/init-mongo.js:/docker-entrypoint-initdb.d/init-mongo.js:ro
#     restart: unless-stopped
#   unifi-network-application-location:
#     image: lscr.io/linuxserver/unifi-network-application:latest
#     container_name: unifi-network-application-location
#     environment:
#       - PUID=1000
#       - PGID=1000
#       - TZ=Etc/UTC
#       - MONGO_USER=unifi
#       - MONGO_PASS=jHCtNNbUZ4koFJ2BUQ
#       - MONGO_HOST=unifi-db-location
#       - MONGO_PORT=27017
#       - MONGO_DBNAME=unifi
#       - MEM_LIMIT=2048 #optional
#       - MEM_STARTUP=2048 #optional
#       # - MONGO_TLS= #optional
#       # - MONGO_AUTHSOURCE= #optional
#     volumes:
#       - /Users/username/unifi-storage/location/config:/config
#     ports:
#       - 8443:8443
#       - 3478:3478/udp
#       - 10001:10001/udp
#       - 8080:8080
#       - 1900:1900/udp #optional
#       - 8843:8843 #optional
#       - 8880:8880 #optional
#       - 6789:6789 #optional
#       - 5514:5514/udp #optional
#     restart: unless-stopped
#     depends_on:
#       - unifi-db-location%

echo 'connecting:'
# ssh ubnt@$device-IP
# set-inform https://localhost:8443