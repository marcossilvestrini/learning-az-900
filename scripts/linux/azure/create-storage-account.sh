#!/usr/bin/env bash

<<'SCRIPT'
    .Synopsis
        Script for up app 
    .DESCRIPTION
        Script for create azure storage account in Azure Cloud
    .PREREQUISITES    
        ./azure-functions.sh
    .EXAMPLE
        ./create-storage-account.sh
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


# Login i Azure Cloud
LoginAzurePortal

# Create resource group
if [ $(az group exists --name "$RESOURCEGROUP") = false ]; then
    if az group create --only-show-errors \
        --resource-group $RESOURCEGROUP \
        --location $LOCATION \
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

# Create resource group
if [ "$(az storage account list --resource-group $RESOURCEGROUP -o table)" = "" ];
then
    if az storage account create --only-show-errors \
        --resource-group $RESOURCEGROUP \
        --location $LOCATION \
        --name $STORAGEACCOUNTNAME \
        --sku $SKU \
        --kind $KIND >/dev/null;
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

# Logout in Azure Cloud
LogoutAzurePortal
