#!/bin/bash

echo 'Some Redis related commands:'

# for Kubernetes hosted redis run:
# echo $(kubectl -n prod get secret redis-prod -o jsonpath="{.data.redis-password}" | base64 -d; echo)

# Amazon Linux
sudo yum install -y gcc
wget http://download.redis.io/redis-stable.tar.gz && tar xvzf redis-stable.tar.gz && cd redis-stable && make
sudo cp src/redis-cli /usr/bin/
redis-cli -h REDIS_DNS --user default -p 6379 PING.   (—tls)
redis-cli -u redis://REDIS_USER:REDIS_PSW@REDIS_DNS:16379/0 PING