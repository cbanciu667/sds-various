#!/bin/bash

AWS_CLI_PROFILE="aws-profile"
TERM="search_term"

for role_name in $(aws iam list-roles --query "Roles[?contains(RoleName, $TERM)].RoleName" --output text --profile $AWS_CLI_PROFILE); do
  # Detach all attached policies
  for policy_arn in $(aws iam list-attached-role-policies --role-name $role_name --query "AttachedPolicies[].PolicyArn" --output text --profile $AWS_CLI_PROFILE); do
    aws iam detach-role-policy --role-name $role_name --policy-arn $policy_arn --profile $AWS_CLI_PROFILE
  done
  
  # Delete inline policies
  for policy_name in $(aws iam list-role-policies --role-name $role_name --query "PolicyNames[]" --output text --profile $AWS_CLI_PROFILE); do
    aws iam delete-role-policy --role-name $role_name --policy-name $policy_name --profile $AWS_CLI_PROFILE
  done
  
  # Remove role from instance profiles
  for instance_profile_name in $(aws iam list-instance-profiles-for-role --role-name $role_name --query "InstanceProfiles[].InstanceProfileName" --output text --profile $AWS_CLI_PROFILE); do
    aws iam remove-role-from-instance-profile --instance-profile-name $instance_profile_name --role-name $role_name --profile $AWS_CLI_PROFILE
  done
  
  # Delete the role
  aws iam delete-role --role-name $role_name --profile $AWS_CLI_PROFILE
done

for policy_arn in $(aws iam list-policies --query "Policies[?contains(PolicyName, $TERM)].Arn" --output text --profile $AWS_CLI_PROFILE); do
  aws iam delete-policy --policy-arn $policy_arn --profile $AWS_CLI_PROFILE
done
