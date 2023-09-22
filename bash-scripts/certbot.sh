#!/bin/bash

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

echo "Renewing NGINX certificates:"
docker run -it --rm --name certbot \
--env AWS_ACCESS_KEY_ID=$AWS_ACCESS_KEY_ID \
--env AWS_SECRET_ACCESS_KEY=$AWS_SECRET_ACCESS_KEY \
-v "../nginx/letsencrypt:/etc/letsencrypt" \
-v "../nginx/letsencrypt:/var/lib/letsencrypt" \
-v "../nginx/letsencrypt/logs:/var/log/letsencrypt" \
certbot/dns-route53 renew \
--agree-tos --server https://acme-v02.api.letsencrypt.org/directory