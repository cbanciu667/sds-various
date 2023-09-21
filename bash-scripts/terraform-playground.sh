#!/bin/bash

# simple workflow example
export AWS_DEFAULT_PROFILE=$AWS_PROFILE_NAME
export PROJECT=$PROJECT_NAME
export MODULE=$TF_MODULE_NAME
export AWS_DEFAULT_REGION=$AWS_REGION

terraform init --upgrade -input=false -backend-config="bucket=tf-state-sds-$PROJECT" \
    -backend-config="key=codepipeline/$MODULE-state" \
    -backend-config="encrypt=true" \
    -backend-config="region=$AWS_DEFAULT_REGION"
terraform plan -out tf-plan-output-$MODULE -var-file="../parameters/$PROJECT/$MODULE.tfvars"  -var="project_name=$PROJECT" -var="region=$AWS_DEFAULT_REGION"
terraform apply -input=false  tf-plan-output-$MODULE
terraform destroy -auto-approve -var-file="../parameters/$PROJECT/$MODULE.tfvars" -var="project_name=$PROJECT"
rm -rf .terraform* tf-plan*

# import external changes
terraform plan -out tf-plan-output-$MODULE -var-file="../parameters/$PROJECT/$MODULE.tfvars" --refresh-only
terraform apply -refresh-only -var-file="../parameters/$PROJECT/$MODULE.tfvars" -auto-approve
terraform plan -out tf-plan-output-$MODULE -var-file="../parameters/$PROJECT/$MODULE.tfvars" --refresh-only

# terraform import
terraform import -var-file="../parameters/$PROJECT/$MODULE.tfvars" --var "project_name=$PROJECT" 'module.s3["prod"].module.db_deployments.aws_s3_bucket.this[0]' 's3-bucket-name'

# terrform debugging
TF_LOG=DEBUG terraform plan
export GODEBUG=asyncpreemptoff=1
export TF_LOG_PATH=/home/cosmin/tf.log

# move resources
terraform state mv 'module.db_dev[0].module.db_parameter_group.aws_db_parameter_group.this[0]'  'module.rds-db-1[0].module.db.module.db_parameter_group.aws_db_parameter_group.this[0]'
terraform state mv 'module.db_dev[0].module.db_subnet_group.aws_db_subnet_group.this[0]'  'module.rds-db-1[0].module.db.module.db_subnet_group.aws_db_subnet_group.this[0]'

# remove resources
terraform state rm 'module.s3["test"].module.db_deployments.aws_s3_bucket.this[0]'

# You can pass in a value for each variable by setting environment variables called TF_VAR_VAR-NAME