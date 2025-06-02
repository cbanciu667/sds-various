#!/bin/bash

# Permission to search for
PERMISSION="PutBucketNotification"
PROFILE="MYAWSPROFILE"  # AWS CLI Profile

# List all SCPs and extract their IDs
scp_ids=$(aws organizations list-policies --filter "SERVICE_CONTROL_POLICY" --query 'Policies[*].Id' --output text --profile $PROFILE)

# Loop through each SCP ID
for scp_id in $scp_ids; do
    # Get the SCP content
    scp_content=$(aws organizations describe-policy --policy-id $scp_id --query 'Policy.Content' --output text --profile $PROFILE)
    echo "SCP ID: $scp_id"
    # Check if the SCP content contains the specified permission
    if echo $scp_content | grep -q "$PERMISSION"; then
        # Get the name of the SCP
        scp_name=$(aws organizations describe-policy --policy-id $scp_id --query 'Policy.PolicySummary.Name' --output text --profile $PROFILE)
        echo "Permission found in SCP: $scp_name"
    fi
done
