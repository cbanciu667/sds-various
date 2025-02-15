#!/bin/bash

echo 'Sample AWS cli commands:'
aws ssm start-session --target i-xxxxxx --profile profile
aws lambda add-layer-version-permission --layer-name Psycopg2Layer_Python_3_10 --version-number 3 --principal AWS_ACCOUNT_ID --statement-id AllowUsageByAccountXXXXXX --action lambda:GetLayerVersion
# aws session manager tunnel
aws ssm start-session \
  --target <ec2-instance-id> \
  --document-name AWS-StartPortForwardingSessionToRemoteHost \
  --parameters '{"host":["<rds-endpoint>"],"portNumber":["5432"],"localPortNumber":["5432"]}'