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
LOCATION="eastus"
RESOURCEGROUP="labs"
STORAGEACCOUNTNAME="labsaz900123456"
KIND="StorageV2"
SKU="Standard_LRS"
TAG="labsz900"
SHARENAME="az900"
ACCESSTIER="TransactionOptimized"
FILE="scripts/linux/azure/create-storage-blob-container.sh"


# Login i Azure Cloud
LoginAzurePortal

# Create resource group
if [ $(az group exists --name "$RESOURCEGROUP") = false ];
then
    if az group create --only-show-errors \
        --resource-group "$RESOURCEGROUP" \
        --location "$LOCATION" \
        --tags $TAG \
        --output none;
    then
        echo "Ressource group $RESOURCEGROUP has create successfully!!"
        echo "Ressource group $RESOURCEGROUP has create successfully!!" >>"$LOGFUNCTIONS"
        echo "----------------------------------------------------"
    else
        echo "Error in create group $RESOURCEGROUP. Please check in your Azure Dashboard"
        echo "Error in create group $RESOURCEGROUP. Please check in your Azure Dashboard" >>"$LOGFUNCTIONS"
        echo "----------------------------------------------------"
    fi
else
    echo "Ressource group $RESOURCEGROUP has create successfully!!"
    echo "Ressource group $RESOURCEGROUP has create successfully!!" >>"$LOGFUNCTIONS"
    echo "----------------------------------------------------"
fi

# Create storage  account
if [ "$(az storage account list --resource-group $RESOURCEGROUP -o table --only-show-errors)" = "" ];
then
    if az storage account create --only-show-errors \
        --resource-group "$RESOURCEGROUP" \
        --location "$LOCATION" \
        --name "$STORAGEACCOUNTNAME" \
        --sku "$SKU" \
        --kind "$KIND" \
        --enable-large-file-share \
        --output none;
     then
        echo "Storage Account $STORAGEACCOUNTNAME has create successfully!!"
        echo "Storage Account $STORAGEACCOUNTNAME has create successfully!!" >>"$LOGFUNCTIONS"
        echo "----------------------------------------------------"
    else
        echo "Error in create Storage Account $STORAGEACCOUNTNAME. Please check in your Azure Dashboard"
        echo "Error in create Storage Account $STORAGEACCOUNTNAME. Please check in your Azure Dashboard" >>"$LOGFUNCTIONS"
        echo "----------------------------------------------------"
    fi
else
        echo "Storage Account $STORAGEACCOUNTNAME has create successfully!!"
        echo "Storage Account $STORAGEACCOUNTNAME has create successfully!!" >>"$LOGFUNCTIONS"
        echo "----------------------------------------------------"
fi

# Enable large file shares on an existing account
az storage account update \
    --name "$STORAGEACCOUNTNAME" \
    --resource-group "$RESOURCEGROUP" \
    --enable-large-file-share \
    --output none

az storage share-rm create \
    --resource-group "$RESOURCEGROUP" \
    --storage-account "$STORAGEACCOUNTNAME" \
    --name "$SHARENAME" \
    --access-tier "$ACCESSTIER" \
    --quota 1024 \
    --output none

# Create file share
if [ "$(az storage share-rm exists -o tsv --resource-group $RESOURCEGROUP --storage-account $STORAGEACCOUNTNAME --name $SHARENAME)" = False ];
then    
    if az storage share-rm create \
    --resource-group "$RESOURCEGROUP" \
    --storage-account "$STORAGEACCOUNTNAME" \
    --name "$SHARENAME" \
    --access-tier "$ACCESSTIER" \
    --quota 1024 \
    --output none;        
    then
        echo "Storage File Share $SHARENAME has create successfully!!"
        echo "Storage File Share $SHARENAME has create successfully!!" >>"$LOGFUNCTIONS"
        echo "----------------------------------------------------"
    else
        echo "Error in create Storage File Share $SHARENAME. Please check in your Azure Dashboard"
        echo "Error in create Storage File Share $SHARENAME. Please check in your Azure Dashboard" >>"$LOGFUNCTIONS"
        echo "----------------------------------------------------"
    fi
else
        echo "Storage File Share $SHARENAME has create successfully!!"
        echo "Storage File Share $SHARENAME has create successfully!!" >>"$LOGFUNCTIONS"
        echo "----------------------------------------------------"
fi

# Get storage account key
STORAGEACCOUNTKEY=$(az storage account keys list \
    -n "$STORAGEACCOUNTNAME" \
    -g "$RESOURCEGROUP" \
    --query "[0].value" -o tsv | tr -d '"')

# # Upload file for test share
echo "Start Test Upload file to Storage File Share $SHARENAME"
echo "Start Upload file to Storage File Share $SHARENAME" >>"$LOGFUNCTIONS"

if az storage file upload \
    --no-progress \
    --timeout 30 \
    --account-name "$STORAGEACCOUNTNAME" \
    --account-key "$STORAGEACCOUNTKEY" \
    --share-name "$SHARENAME" \
    --source "$FILE" \
    --output none;
then
    echo "Upload file in Storage File Share $CONTAINERNAME has successfully!!!"
    echo "Upload file in Storage File Share $CONTAINERNAME has successfully!!!" >> "$LOGFUNCTIONS"
else
    echo "Error in Upload file in Storage File Share $CONTAINERNAME. Please check in your Azure Dashboard"
    echo "Error in Upload file in Storage File Share $CONTAINERNAME. Please check in your Azure Dashboard" >> "$LOGFUNCTIONS"
    exit 1
fi

echo "Check file in Storage File Share $SHARENAME"
echo "Check file in Storage File Share $SHARENAME" >>"$LOGFUNCTIONS"
az storage file list \
    --account-name "$STORAGEACCOUNTNAME" \
    --share-name "$SHARENAME" \
    --account-key "$STORAGEACCOUNTKEY" \
    --output table

# Mount file share local
# https://learn.microsoft.com/en-us/azure/storage/files/storage-how-to-use-files-linux?tabs=Ubuntu%2Csmb311
MNT_ROOT="/mount"
MNT_PATH="$MNT_ROOT/$STORAGEACCOUNTNAME/$SHARENAME"
mkdir -p $MNT_PATH
# This command assumes you have logged in with az login
HTTP_ENDPOINT=$(az storage account show \
    --resource-group $RESOURCEGROUP \
    --name $STORAGEACCOUNTNAME \
    --query "primaryEndpoints.file" --output tsv | tr -d '"')
SMB_PATH=$(echo "$HTTP_ENDPOINT" | cut -c7-${#HTTP_ENDPOINT})$SHARENAME
echo "Mount Local File Share $MNT_PATH"
echo "Mount Local File Share $MNT_PATH" >>"$LOGFUNCTIONS"
mount -t cifs "$SMB_PATH" $MNT_PATH -o username=$STORAGEACCOUNTNAME,password=$STORAGEACCOUNTKEY,serverino,nosharesock,actimeo=30,mfsymlinks
echo "Check Local File Share $MNT_PATH"
echo "Check Local File Share $MNT_PATH" >>"$LOGFUNCTIONS"
ls "$MNT_PATH"

# Logout in Azure Cloud
LogoutAzurePortal
