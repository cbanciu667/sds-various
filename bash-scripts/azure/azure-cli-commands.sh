#!/bin/bash

echo 'Sample Azure cli commands:'
az login --user myUsername@myCompany.com --password myPassword
az login --tenant myTenantID
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
az group create --name MyResourceGroup --location eastus
az group delete --name StorageGroups
az group lock create --name "Cannot delete resource group" --lock-type CanNotDelete
az account list-locations
az config set defaults.group=MyResourceGroup
az group create -n resourcegroupname -l eastus2
az storage account create -n StorageAccountName -g resourcegroupname -l eastus2 --sku Standard_LRS
az storage container create -n StorageContainerName
az ad sp create-for-rbac --name Serviceprincipalname
az storage blob upload --account-name <storage-account-name> --container-name <container-name> --name <blob-name> --file <local-file-path>
