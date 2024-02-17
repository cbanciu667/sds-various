#!/bin/bash

echo 'Sample AWS cli commands:'
aws ssm start-session --target i-xxxxxx --profile profile
aws lambda add-layer-version-permission --layer-name Psycopg2Layer_Python_3_10 --version-number 3 --principal AWS_ACCOUNT_ID --statement-id AllowUsageByAccountXXXXXX --action lambda:GetLayerVersion