#!/usr/bin/env bash

<<'SCRIPT'
    .Synopsis
        Script for up app 
    .DESCRIPTION
        Script for create azure SQL Single Database in Azure Cloud
    .PREREQUISITES    
        ./azure-functions.sh
    .EXAMPLE
        ./create-sql-single-database.sh
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
let "RANDOMIDENTIFIER=$RANDOM*$RANDOM"
LOCATION="eastus"
RESOURCEGROUP="labs"
SERVER="lab-az900"
DATABASE="lab-az900"
LOGIN="vagrant"
PASSWORD="Pa$$w0rD-$RANDOMIDENTIFIER"
STARTIP=0.0.0.0
ENDIP=0.0.0.0
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

# Create a server
if [ "$(az sql server list -o tsv --resource-group $RESOURCEGROUP)" = "" ];
then
    if az sql server create \
        --name "$SERVER" \
        --resource-group "$RESOURCEGROUP" \
        --location "$LOCATION" \
        --admin-user "$LOGIN" \
        --admin-password "$PASSWORD" \
        --output none;
    then
        echo "SQL Server $SERVER has create successfully!!"
        echo "SQL Server $SERVER has create successfully!!" >>"$LOGFUNCTIONS"
        echo "----------------------------------------------------"
    else
        echo "Error in create group $RESOURCEGROUP. Please check in your Azure Dashboard"
        echo "Error in create group $RESOURCEGROUP. Please check in your Azure Dashboard" >>"$LOGFUNCTIONS"
        echo "----------------------------------------------------"
    fi
else
    echo "SQL Server $SERVER has create successfully!!"
    echo "SQL Server $SERVER has create successfully!!" >>"$LOGFUNCTIONS"
    echo "----------------------------------------------------"
fi

# Configure a server-based firewall rule
if [ "$(az sql server firewall-rule list -o tsv  -g "$RESOURCEGROUP" -s "$SERVER")" = "" ];
then
    if az sql server firewall-rule create \
        --resource-group "$RESOURCEGROUP" \
        --server "$SERVER" -n AllowYourIp \
        --start-ip-address "$STARTIP" \
        --end-ip-address "$ENDIP" \
        --output none;
    then
        echo "Configure Firewall Rule has create successfully!!"
        echo "Configure Firewall Rule has create successfully!!" >>"$LOGFUNCTIONS"
        echo "----------------------------------------------------"
    else
        echo "Configure Firewall Rule. Please check in your Azure Dashboard"
        echo "Configure Firewall Rule. Please check in your Azure Dashboard" >>"$LOGFUNCTIONS"
        echo "----------------------------------------------------"
    fi
else
    echo "Configure Firewall Rule has create successfully!!"
    echo "Configure Firewall Rule has create successfully!!" >>"$LOGFUNCTIONS"
    echo "----------------------------------------------------"
fi

# Create a single database
if [ "$(az sql db list -o tsv --resource-group $RESOURCEGROUP --server $SERVER --query "[].name" | grep $DATABASE)" = "" ];
then
    if az sql db create \
        --resource-group "$RESOURCEGROUP" \
        --server "$SERVER" \
        --name "$DATABASE" \
        --sample-name AdventureWorksLT \
        --edition GeneralPurpose \
        --compute-model Serverless \
        --family Gen5 \
        --capacity 2 \
        --tags "$TAG" \
        --yes \
        --output none;
    then
        echo "Create a Single Database $DATABASE has create successfully!!"
        echo "Create a Single Database $DATABASE has create successfully!!" >>"$LOGFUNCTIONS"
        echo "----------------------------------------------------"
    else
        echo "Error in create group $DATABASE. Please check in your Azure Dashboard"
        echo "Error in create group $DATABASE. Please check in your Azure Dashboard" >>"$LOGFUNCTIONS"
        echo "----------------------------------------------------"
    fi
else
    echo "Create a Single Database $DATABASE has create successfully!!"
    echo "Create a Single Database $DATABASE has create successfully!!" >>"$LOGFUNCTIONS"
    echo "----------------------------------------------------"
fi

# Create Table in Single Database
sqlcmd -S server_name -U username -P password -i /home/usr/columns.sql -o /home/usr/columns.txt
sqlcmd -S $SERVER -U $LOGIN -P $PASSWORD -i scripts/sql/create-table.sql  -o /home/vagrant/create-table-az900.txt

# Logout in Azure Cloud
LogoutAzurePortal
