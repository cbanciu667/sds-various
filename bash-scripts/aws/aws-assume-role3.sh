#!/bin/bash

OUT=$(aws sts assume-role --role-arn "ROLE_ARN" --role-session-name "SESSION_NAME")
echo $OUT
export AWS_ACCESS_KEY_ID=$(echo $OUT | cut -d '"' -f 6 )
export AWS_SECRET_ACCESS_KEY=$(echo $OUT | cut -d '"' -f 10 )
export AWS_SESSION_TOKEN=$(echo $OUT | cut -d '"' -f 14 )