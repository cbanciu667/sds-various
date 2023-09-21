#!/bin/bash

aws kms get-key-policy  --policy-name default --key-id $1 --query Policy --output text > policy.txt
nano policy.txt # add ROLE_ARN
aws kms put-key-policy --policy-name default --key-id $1 --policy file://policy.txt