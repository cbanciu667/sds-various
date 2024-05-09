#!/bin/bash

rm -f ~/.aws/credentials
rm -f ~/.aws/config
rm -f ~/.aws/credentials_source
echo [default] >> ~/.aws/credentials
echo [profile default] >> ~/.aws/config
echo region = eu-central-1 >> ~/.aws/config
echo output = json >> ~/.aws/config
aws sts assume-role --role-arn "ROLE_ARN" --role-session-name SESSION_NAME --output text --query '[Credentials.AccessKeyId,Credentials.SecretAccessKey,Credentials.SessionToken]' >> ~/.aws/credentials_source
filename=~/.aws/credentials_source
while read -r line
do
    read -ra arr <<<"$line"
    echo "aws_access_key_id="${arr[0]} >> ~/.aws/credentials
    echo "aws_secret_access_key="${arr[1]} >> ~/.aws/credentials
    echo "aws_session_token="${arr[2]} >> ~/.aws/credentials
    export AWS_ACCESS_KEY_ID=${arr[0]}
    export AWS_SECRET_ACCESS_KEY=${arr[1]}
    export AWS_SESSION_TOKEN=${arr[1]}
    export AWS_DEFAULT_REGION=eu-central-1
done < "$filename"