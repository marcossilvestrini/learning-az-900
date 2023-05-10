#!/usr/bin/env bash

<<'SCRIPT'
    .Synopsis
        Script for up app 
    .DESCRIPTION
        Script for create azure storage container in Azure Cloud
    .PREREQUISITES    
        ./azure-functions.sh
    .EXAMPLE
        ./create-storage-container.sh
SCRIPT

# Clear screen
clear

# Set language/locale and encoding
export LANG=C

cd /home/vagrant || exit

# Scriptpath
path=$(readlink -f "${BASH_SOURCE:-$0}")
DIR_PATH=$(dirname "$path")

# Log functions
LOGFUNCTIONS="$DIR_PATH/azure-functions.log"

# Import my modules\functions
source "$DIR_PATH/azure-functions.sh"

# Variabels
#let "RANDOMIDENTIFIER=$RANDOM*$RANDOM"
JSON=security/.azure-secrets
SUBSCRIPTION="$(jq -r .subscriptionId $JSON)"
CLIENT_ID=$(jq -r .clientId $JSON)
LOCATION="eastus"
RESOURCEGROUP="labs"
STORAGEACCOUNTNAME="labsaz900123456"
KIND="StorageV2"
SKU="Standard_LRS"
TAG="labsz900"
CONTAINERNAME="az900"

echo $SUBSCRIPTION

az role assignment create \
    --assignee-principal-type ServicePrincipal \
    --assignee-object-id "$CLIENT_ID"  \
    --role "Storage Blob Data Contributor"\
    --scope "/subscriptions/$SUBSCRIPTION/resourceGroups/$RESOURCEGROUP/providers/Microsoft.Storage/storageAccounts/$STORAGEACCOUNTNAME/blobServices/default/containers/$CONTAINERNAME" >/dev/null    