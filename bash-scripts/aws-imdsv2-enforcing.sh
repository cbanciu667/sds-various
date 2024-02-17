#!/bin/bash 

echo "Creating IAM policy 'iam_policy'"
aws iam create-policy --policy-name "iam_policy" \
 --description "An IAM policy that prevents users from launching new EC2 Instances if they are not configured to use the new Instance Metadata Service (IMDSv2)" \
 --policy-document '{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Action": [
                "ec2:RunInstances"
            ],
            "Resource": [
                "arn:aws:ec2:*:*:instance/*"
            ],
            "Effect": "Deny",
            "Condition": {
                "StringNotEquals": {
                    "ec2:MetadataHttpTokens": "required"
                }
            }
        }
    ]
}'




{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Action": [
                "ec2:RunInstances"
            ],
            "Resource": [
                "arn:aws:ec2:*:*:instance/*"
            ],
            "Effect": "Deny",
            "Condition": {
                "StringNotEquals": {
                    "ec2:MetadataHttpTokens": "required"
                }
            }
        }
    ]
}