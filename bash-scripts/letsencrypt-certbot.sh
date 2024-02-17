#!/bin/bash

echo 'Obtain new certificate:'
docker run -it --rm --name certbot-route53 \
--env AWS_ACCESS_KEY_ID=$AWS_ACCESS_KEY_ID \
--env AWS_SECRET_ACCESS_KEY=$AWS_SECRET_ACCESS_KEY \
-v "./storage/controller/nginx/letsencrypt:/etc/letsencrypt" \
-v "./storage/controller/nginx/letsencrypt:/var/lib/letsencrypt" \
-v "./storage/controller/nginx/letsencrypt/logs:/var/log/letsencrypt" \
certbot/dns-route53 certonly \
-d $PLATFORM_DOMAIN \
-d "*.$PLATFORM_DOMAIN" \
-m $PLATFORM_EMAIL_CONTACT \
--agree-tos --server https://acme-v02.api.letsencrypt.org/directory

echo 'Renew NGINX certificates:'
docker run -it --rm --name certbot \
    --env AWS_ACCESS_KEY_ID= \
    --env AWS_SECRET_ACCESS_KEY= \
    -v "/home/username/nfs-storage/controller/nginx/letsencrypt:/etc/letsencrypt" \
    -v "/home/username/nfs-storage/controller/nginx/letsencrypt:/var/lib/letsencrypt" \
    -v "/home/username/nfs-storage/controller/nginx/letsencrypt/logs:/var/log/letsencrypt" \
    certbot/dns-route53 certonly \
    -d domain.com \
    -d '*.domain.com' \
    -m mymail@icloud.com \
    --agree-tos \
    --server https://acme-v02.api.letsencrypt.org/directory