#!/bin/bash

sudo yum install jq -y
curl -H "Authorization: $AWS_CONTAINER_AUTHORIZATION_TOKEN" $AWS_CONTAINER_CREDENTIALS_FULL_URI 2>/dev/null > /tmp/credentials
ACCESS_KEY=`cat /tmp/credentials| jq -r .AccessKeyId`
SECRET_KEY=`cat /tmp/credentials| jq -r .SecretAccessKey`
SESSION_TOKEN=`cat /tmp/credentials| jq -r .Token`
echo -ne "\nThis is ${ROLE_NAME} temporary credential.\nPaste them in your shell! \n\nexport AWS_ACCESS_KEY_ID=${ACCESS_KEY};\nexport AWS_SECRET_ACCESS_KEY=${SECRET_KEY};\nexport AWS_SESSION_TOKEN=${SESSION_TOKEN};\n\n"
export AWS_ACCESS_KEY_ID=XXXXXXXXXXXXXXXXXXXXXXXX;
export AWS_SECRET_ACCESS_KEY=XXXXXXXXXXXXXXXXXXXXXXXX;
export AWS_SESSION_TOKEN=XXXXXXXXXXXXXXXXXXXXXXXX;