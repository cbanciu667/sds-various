#!/bin/bash

aws secretsmanager create-secret --name secrets-$1 --description "Environment variables for $1" --secret-string file://secrets-$1.json --profile $2 --region $3
aws secretsmanager get-secret-value --secret-id test-secret --version-stage AWSCURRENT | jq --raw-output '.SecretString' | jq '."route53-domain-name"' | sed '/null/d' | sed 's/"//g'

# Binary files
aws secretsmanager create-secret --name binary-test --secret-binary fileb://~/private_key.key
aws secretsmanager get-secret-value --secret-id binary-test  --query SecretBinary --output text | base64 --decode > myretrievedsecret.file

# Force permanent removal
aws secretsmanager delete-secret --secret-id your-secret-name --force-delete-without-recovery --region $3
aws secretsmanager describe-secret --secret-id your-secret-name --region $3

# Build env var file
aws secretsmanager get-secret-value --secret-id secret-1 --region $3 --query SecretString --output text tmp-out.json
aws secretsmanager get-secret-value --secret-id secret-2 --region $3 --query SecretString --output text >> tmp-out.json
aws secretsmanager get-secret-value --secret-id secret-3 --region $3 --query SecretString --output text >> tmp-out.json
jq -c 'keys[] as $k | "\($k)=\(.[$k] | .)"' tmp-out.json | while read i; do echo ${i:1} | sed 's/=/="/' >> env-vars; done
rm tmp-out.json
source env-vars

# fetch secret value
aws secretsmanager get-secret-value --secret-id secrets-part1 --profile AWS_PROFILE --region eu-central-1 --query SecretString --output text > tmp-out-part1.json 
jq -c 'keys[] as $k | "\($k)=\(.[$k] | .)"' tmp-out-part1.json | while read i; do echo ${i:1} | sed 's/=/="/' >> env-vars; done
source env-vars