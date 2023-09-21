#!/bin/bash

set -e
role_arn=$1
session_name="${2}-`date +%Y%m%d`"
echo 'Assuming role...'
sts=( $(
    aws sts assume-role \
    --role-arn "$role_arn" \
    --role-session-name "$session_name" \
    --query 'Credentials.[AccessKeyId,SecretAccessKey,SessionToken]' \
    --output text
) )
export AWS_ACCESS_KEY_ID=${sts[0]}
export AWS_SECRET_ACCESS_KEY=${sts[1]}
export AWS_SESSION_TOKEN=${sts[2]}

aws configure set aws_access_key_id $AWS_ACCESS_KEY_ID
aws configure set aws_secret_access_key $AWS_SECRET_ACCESS_KEY
aws configure set region $AWS_REGION --profile default
aws configure set profile.sandbox.role_arn "${role_arn}"
aws configure set profile.sandbox.source_profile default