#!/usr/bin/env bash

<<'SCRIPT'
    .Synopsis
        Script for up app 
    .DESCRIPTION
        Script for create azure storage file share in Azure Cloud
    .PREREQUISITES    
        ./azure-functions.sh
    .EXAMPLE
        ./create-storage-file-share.sh
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
LOCATION="eastus"
RESOURCEGROUP="labs"
STORAGEACCOUNTNAME="labsaz900123456"
KIND="StorageV2"
SKU="Standard_LRS"
TAG="labsz900"
SHARENAME="az900"
FILE="scripts/linux/azure/create-storage-blob-container.sh"

# Login i Azure Cloud
LoginAzurePortal

# Create file share
if [ "$(az storage share-rm exists -o tsv --resource-group $RESOURCEGROUP --storage-account $STORAGEACCOUNTNAME --name $SHARENAME)" = False ]; then
    echo "Storage Container $SHARENAME not existing"
else
    echo "Storage Container $SHARENAME existing"    
fi

# Logout in Azure Cloud
LogoutAzurePortal
