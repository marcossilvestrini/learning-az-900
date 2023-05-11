#!/usr/bin/env bash

<<'SCRIPT'
    .Synopsis
        Script for up app 
    .DESCRIPTION
        Script for create azure storage blob container in Azure Cloud
    .PREREQUISITES    
        ./azure-functions.sh
    .EXAMPLE
        ./create-storage-blob-container.sh
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
ASSIGNEE="ServicePrincipal"
ROLE="Storage Blob Data Contributor"
LOCATION="eastus"
RESOURCEGROUP="labs"
STORAGEACCOUNTNAME="labsaz900123456"
KIND="StorageV2"
SKU="Standard_LRS"
TAG="labsz900"
CONTAINERNAME="az900"
FILE="scripts/linux/azure/create-storage-blob-container.sh"


# Login i Azure Cloud
LoginAzurePortal

# Create resource group
if [ $(az group exists --name "$RESOURCEGROUP") = false ];
then
    if az group create --only-show-errors \
        --resource-group "$RESOURCEGROUP" \
        --location "$LOCATION" \
        --tags $TAG >/dev/null;
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
        --kind "$KIND" >/dev/null;
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


# Set permissions for container
az role assignment create \
    --assignee-principal-type "$ASSIGNEE" \
    --assignee-object-id "$CLIENT_ID"  \
    --role "$ROLE" \
    --scope "/subscriptions/$SUBSCRIPTION/resourceGroups/$RESOURCEGROUP/providers/Microsoft.Storage/storageAccounts/$STORAGEACCOUNTNAME/blobServices/default/containers/$CONTAINERNAME" > /dev/null

# Create container blob
if [ "$(az storage container exists -o tsv --auth-mode login --account-name "$STORAGEACCOUNTNAME" --name "$CONTAINERNAME" --timeout 10)" = False ];
then
    if az storage container create \
        --name "$CONTAINERNAME" \
        --account-name "$STORAGEACCOUNTNAME" \
        --resource-group "$RESOURCEGROUP" \
        --auth-mode login >/dev/null;        
     then
        echo "Storage Container $CONTAINERNAME has create successfully!!"
        echo "Storage Container $CONTAINERNAME has create successfully!!" >>"$LOGFUNCTIONS"
        echo "----------------------------------------------------"
    else
        echo "Error in create Storage Container $CONTAINERNAME. Please check in your Azure Dashboard"
        echo "Error in create Storage Container $CONTAINERNAME. Please check in your Azure Dashboard" >>"$LOGFUNCTIONS"
        echo "----------------------------------------------------"
    fi
else
        echo "Storage Container $CONTAINERNAME has create successfully!!"
        echo "Storage Container $CONTAINERNAME has create successfully!!" >>"$LOGFUNCTIONS"
        echo "----------------------------------------------------"
fi

# Get storage account key
STORAGEACCOUNTKEY=$(az storage account keys list \
    -n "$STORAGEACCOUNTNAME" \
    -g "$RESOURCEGROUP" \
    --query "[0].value" -o tsv)

# Upload file for test container
echo "Start Test Upload file to Storage Container $CONTAINERNAME"
echo echo "Start Upload file to Storage Container $CONTAINERNAME" >>"$LOGFUNCTIONS"
if az storage blob upload \
    --no-progress \
    --overwrite true \
    --timeout 30 \
    --tags $TAG \
    --account-name "$STORAGEACCOUNTNAME" \
    --account-key "$STORAGEACCOUNTKEY" \
    --container-name "$CONTAINERNAME" \
    --name create-storage-container.sh \
    --file "$FILE" >/dev/null;
then
    echo "Upload file in Storage Blob Container $CONTAINERNAME has successfully!!!"
    echo "Upload file in Storage Blob Container $CONTAINERNAME has successfully!!!" >> "$LOGFUNCTIONS"
else
    echo "Error in upload file in Storage Blob Container $CONTAINERNAME. Please check in your Azure Dashboard"
    echo "Error in upload file in Storage Blob Container $CONTAINERNAME. Please check in your Azure Dashboard" >> "$LOGFUNCTIONS"
    exit 1
fi

echo "Check file in Storage Container $CONTAINERNAME"
echo echo "Check file in Storage Container $CONTAINERNAME" >>"$LOGFUNCTIONS"
az storage blob list \
    --account-name $STORAGEACCOUNTNAME \
    --container-name $CONTAINERNAME \
    --output table \
    --account-key "$STORAGEACCOUNTKEY"

# Logout in Azure Cloud
LogoutAzurePortal
