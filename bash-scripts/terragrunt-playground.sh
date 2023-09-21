#!/bin/bash

# optimisations
export TERRAGRUNT_FETCH_DEPENDENCY_OUTPUT_FROM_STATE=true
export TERRAGRUNT_USE_PARTIAL_PARSE_CONFIG_CACHE=true

terragrunt destroy --auto-approve
terragrunt plan --terragrunt-source-update && terragrunt apply --auto-approve
terragrunt run-all apply --auto-approve --terragrunt-non-interactive
terragrunt run-all plan --terragrunt-source-update --terragrunt-non-interactive
terragrunt run-all plan  --terragrunt-non-interactive --terragrunt-ignore-external-dependencies

# run with local modules
TERRAFORM_LOCAL=true
terragrunt plan

# dynamic blocks
# dynamic "subnet_mapping" {
#   for_each = toset(var.nlb_ip_targets)
#   content {
#     subnet_id            = var.subnet_ids[index(var.nlb_ip_targets, subnet_mapping.value)]
#     private_ipv4_address = subnet_mapping.value
#   }
# }