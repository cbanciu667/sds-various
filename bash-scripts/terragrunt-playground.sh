#!/bin/bash

# optimisations
export TERRAGRUNT_FETCH_DEPENDENCY_OUTPUT_FROM_STATE=true # can speed up things, supported only with s3 backend, experimental
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
#
#
# Use "-terragrunt-log-level debug" to debug
#
#
terragrunt run-all plan --terragrunt-source-update --terragrunt-non-interactive --auto-approve
terragrunt run-all apply --terragrunt-source-update --terragrunt-non-interactive

# CAHE
find . -type d -name ".terragrunt-cache" -prune -exec rm -rf {} \;
export TERRAGRUNT_DOWNLOAD='/Users/USERNAME/.terragrunt-cache'
export TF_PLUGIN_CACHE_DIR="$HOME/.terraform.d/plugin-cache"

#DEBUGING
terragrunt plan render-json
terragrunt destroy --auto-approve -terragrunt-log-level debug

# PARALLELISM
terragrunt run-all apply --terragrunt-parallelism 4 # for "text file busy" error
