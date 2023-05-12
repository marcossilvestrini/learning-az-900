#!/usr/bin/env bash

<<'SCRIPT'
    .Synopsis
        Script for up app 
    .DESCRIPTION
        Script for create azure Cosmos DB Database in Azure Cloud
    .PREREQUISITES    
        ./azure-functions.sh
    .EXAMPLE
        ./create-cosmosdb-database.sh
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
COSMOSACCOUNT="lab-az900"
COSMOSDATABASENAME="lab-az900"
COSMOSCONTEINERNAME="lab-az900"
TAG="labsz900"

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

# Creates a new Azure Cosmos DB database account.
if [ $(az cosmosdb check-name-exists --name $COSMOSACCOUNT) = false ];
then
    if az cosmosdb create \
        --resource-group "$RESOURCEGROUP" \
        --name "$COSMOSACCOUNT" \
        --tags "$TAG" \
        --output none;
    then
        echo "Cosmos DB Account $COSMOSACCOUNT has create successfully!!"
        echo "Cosmos DB Account $COSMOSACCOUNT has create successfully!!" >>"$LOGFUNCTIONS"
        echo "----------------------------------------------------"
    else
        echo "Cosmos DB Account $COSMOSACCOUNT. Please check in your Azure Dashboard"
        echo "Cosmos DB Account $COSMOSACCOUNT. Please check in your Azure Dashboard" >>"$LOGFUNCTIONS"
        echo "----------------------------------------------------"
    fi
else
    echo "Cosmos DB Account $COSMOSACCOUNT has create successfully!!"
    echo "Cosmos DB Account $COSMOSACCOUNT has create successfully!!" >>"$LOGFUNCTIONS"
    echo "----------------------------------------------------"
fi

# Creates an Azure Cosmos DB database.
if [ $(az cosmosdb sql database exists --account-name $COSMOSACCOUNT --name $COSMOSDATABASENAME --resource-group $RESOURCEGROUP) = false ];
then
    if az cosmosdb sql database create \
        --resource-group "$RESOURCEGROUP" \
        --account-name "$COSMOSACCOUNT" \
        --name "$COSMOSDATABASENAME" \
        --output none;
    then
        echo "Cosmos Database SQL $COSMOSDATABASENAME has create successfully!!"
        echo "Cosmos Database SQL $COSMOSDATABASENAME has create successfully!!" >>"$LOGFUNCTIONS"
        echo "----------------------------------------------------"
    else
        echo "Cosmos Database SQL $COSMOSDATABASENAME. Please check in your Azure Dashboard"
        echo "Cosmos Database SQL $COSMOSDATABASENAME. Please check in your Azure Dashboard" >>"$LOGFUNCTIONS"
        echo "----------------------------------------------------"
    fi
else
    echo "Cosmos Database SQL $COSMOSDATABASENAME has create successfully!!"
    echo "Cosmos Database SQL $COSMOSDATABASENAME has create successfully!!" >>"$LOGFUNCTIONS"
    echo "----------------------------------------------------"
fi

# Create an SQL container under an Azure Cosmos DB SQL database.
if [ $(az cosmosdb sql container exists --account-name $COSMOSACCOUNT --database-name $COSMOSDATABASENAME --name $COSMOSCONTEINERNAME --resource-group $RESOURCEGROUP) = false ];
then
    if az cosmosdb sql container create \
        --resource-group "$RESOURCEGROUP" \
        --account-name "$COSMOSACCOUNT" \
        --database-name "$COSMOSDATABASENAME" \
        --name "$COSMOSCONTEINERNAME" \
        --partition-key-path "/commandName/example" \
        --output none;
    then
        echo "Cosmos SQL Conteiner $COSMOSCONTEINERNAME has create successfully!!"
        echo "Cosmos SQL Conteiner $COSMOSCONTEINERNAME has create successfully!!" >>"$LOGFUNCTIONS"
        echo "----------------------------------------------------"
    else
        echo "Error in create group $RESOURCEGROUP. Please check in your Azure Dashboard"
        echo "Error in create group $RESOURCEGROUP. Please check in your Azure Dashboard" >>"$LOGFUNCTIONS"
        echo "----------------------------------------------------"
    fi
else
    echo "Cosmos SQL Conteiner $COSMOSCONTEINERNAME has create successfully!!"
    echo "Cosmos SQL Conteiner $COSMOSCONTEINERNAME has create successfully!!" >>"$LOGFUNCTIONS"
    echo "----------------------------------------------------"
fi

# Insert item in cosmos sql conteiner

# https://azuresdkdocs.blob.core.windows.net/$web/python/azure-cosmos/4.0.0b5/index.html#create-client
# https://azuresdkdocs.blob.core.windows.net/$web/python/azure-cosmos/4.0.0b5/index.html#insert-data

# Configure env variables for python
export ACCOUNT_URI=$(az cosmosdb show --resource-group $RESOURCEGROUP --name $COSMOSACCOUNT --query documentEndpoint --output tsv)
export ACCOUNT_KEY=$(az cosmosdb keys list --resource-group $RESOURCEGROUP --name $COSMOSACCOUNT --query primaryMasterKey --output tsv)

## Install python packages
pip install --pre azure-cosmos >/dev/null
pip install --upgrade pyinstaller >/dev/null

# Configure python
#python3 -m venv azure-cosmosdb-sdk-environment
#source azure-cosmosdb-sdk-environment/bin/activate
dos2unix -q scripts/python/insert-item-cosmos-container.py
dos2unix -q scripts/python/list-item-cosmos-container.py
chmod +x scripts/python/insert-item-cosmos-container.py
chmod +x scripts/python/list-item-cosmos-container.py

## Insert items in Cosmos Database Container
echo "Insert items in Cosmos SQL Conteiner $COSMOSCONTEINERNAME for test" >>"$LOGFUNCTIONS"
./scripts/python/insert-item-cosmos-container.py

## Check items in Cosmos Database Container
echo "Check items in Cosmos SQL Conteiner $COSMOSCONTEINERNAME for test" >>"$LOGFUNCTIONS"
./scripts/python/list-item-cosmos-container.py

# Logout in Azure Cloud
LogoutAzurePortal
