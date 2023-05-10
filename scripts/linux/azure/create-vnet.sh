#!/usr/bin/env bash

<<'SCRIPT'
    .Synopsis
        Script for up app 
    .DESCRIPTION
        Script for create azure virtual network  in Azure Cloud
    .PREREQUISITES    
        ./azure-functions.sh
    .EXAMPLE
        ./create-vnet.sh
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
# let "randomIdentifier=$RANDOM*$RANDOM"
LOCATION="eastus"
RESOURCEGROUP="labs"
VNETNAME="vnet-az900"
SUBNETNAME="subnet-az900"
VNETPREFIX="10.0.0.0/16"
SUBNETPREFIX="10.0.0.0/24"
TAG="labs-az900"


# Login i Azure Cloud
LoginAzurePortal

# Create resource group
if [ $(az group exists --name "$RESOURCEGROUP") = false ]; then
    if az group create \
        --resource-group $RESOURCEGROUP \
        --location $LOCATION \
        --tags $TAG >/dev/null; then
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

# Create virtual network
if [ "$(az network vnet list -o table --query "[?contains(addressSpace.addressPrefixes, '10.0.0.0/16')]")" = "" ];
then
    if az network vnet create \
        --resource-group $RESOURCEGROUP \
        --location $LOCATION \
        --name $VNETNAME \
        --subnet-name $SUBNETNAME \
        --address-prefix $VNETPREFIX  \
        --subnet-prefixes $SUBNETPREFIX >/dev/null;
     then
        echo "VirtualNetwork $VNETNAME has create successfully!!"
        echo "VirtualNetwork $VNETNAME has create successfully!!" >>"$LOGFUNCTIONS"
        echo "----------------------------------------------------"
    else
        echo "Error in create Virtual Network $VNETNAME. Please check in your Azure Dashboard"
        echo "Error in create Virtual Network $VNETNAME. Please check in your Azure Dashboard" >>"$LOGFUNCTIONS"
        echo "----------------------------------------------------"
    fi
else
        echo "VirtualNetwork $VNETNAME has create successfully!!"
        echo "VirtualNetwork $VNETNAME has create successfully!!" >>"$LOGFUNCTIONS"
        echo "----------------------------------------------------"
fi

# Logout in Azure Cloud
LogoutAzurePortal
