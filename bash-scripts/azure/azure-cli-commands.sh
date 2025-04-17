#!/bin/bash

# login or account related
az login --user myUsername@myCompany.com --password myPassword
az login --tenant myTenantID
az account set --subscription <your-subscription-id>
az logout
az login
az account show --output table
az account list --output table --all
az account list --query "[?isDefault]"
az account list --query "[?contains(name,'search phrase')].{SubscriptionName:name, SubscriptionID:id, TenantID:tenantId}" --output table
az account set --subscription "My Demos"
az account set --subscription "xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx"
subscriptionId="$(az account list --query "[?name=='my case sensitive subscription full name'].id" --output tsv)"
az account set --subscription $subscriptionId
az account management-group create --name Contoso01
az account management-group list
az account management-group subscription add --name Contoso01 --subscription "My Demos"
az account lock create --name "Cannot delete subscription" --lock-type CanNotDelete
az account lock list --output table
az account lock delete --name "Cannot delete subscription"

# resource group related
az group create --name MyResourceGroup --location eastus
az group delete --name StorageGroups
az group lock create --name "Cannot delete resource group" --lock-type CanNotDelete
az account list-locations
az config set defaults.group=MyResourceGroup
az group create -n resourcegroupname -l eastus2

# storage related
az storage account create -n StorageAccountName -g resourcegroupname -l eastus2 --sku Standard_LRS
az storage container create -n StorageContainerName
az ad sp create-for-rbac --name Serviceprincipalname
az storage blob upload --account-name <storage-account-name> --container-name <container-name> --name <blob-name> --file <local-file-path>
az account clear && az login
az role assignment list --assignee user@domain.com --all
az feature show \
  --namespace Microsoft.Subscription \
  --name AllowProgrammaticSubscriptionCreation \
  --query properties.state


# azure app creation
az ad app create --display-name "gh-actions-terraform" --query appId -o tsv
az ad app federated-credential create --id <appId> \
  --parameters '{
    "name": "GitHubActions",
    "issuer": "https://token.actions.githubusercontent.com",
    "subject": "repo:<your-org>/<your-repo>:ref:refs/heads/main",
    "description": "OIDC connection from GitHub Actions"
  }'

# assign permissions to the app
az ad sp create --id <appId>
az role assignment create \
  --assignee <appId> \
  --role "Contributor" \
  --scope /subscriptions/<your-subscription-id>

# fetch app ID
az ad app list --display-name "gh-actions-terraform" --query "[0].appId" -o tsv

# fetch tenant id or other billing info
az account show --query tenantId -o tsv
az account show --query "{tenantId:tenantId, subscriptionId:id, user:user.name}" -o table

# tenant billing info
az billing account list --query "[].{id:id, name:name, type:type}" -o table
az billing account show --name <billing_account_id> --query "{agreementType:properties.agreementType}" -o table

# fetch subscription id
az account show --query id -o tsv

# other info about current account
az account show --query "{tenantId:tenantId, subscriptionId:id, user:user.name}" -o table

# create subscriptions programatically unde Microsoft Customer Agreement  or Microsoft Enterprise Agreement
az feature list --namespace Microsoft.Subscription --query "[?contains(name, 'EnableSubscriptionCreation')].{Name:name, State:properties.state}"
az extension add --name subscription
az subscription create \
  --billing-account-name <billing_account_id> \
  --billing-profile-name <billing_profile_id> \
  --invoice-section-name <invoice_section_name> \
  --display-name "test-subscription"
az account show --subscription <subscription-id> --query "offerId"

# programatic subscription creation feature
az feature register \
  --namespace Microsoft.Subscription \
  --name AllowProgrammaticSubscriptionCreation
az feature show \
  --namespace Microsoft.Subscription \
  --name AllowProgrammaticSubscriptionCreation \
  --query properties.state
