#!/usr/bin/env bash

<<'SCRIPT'
    .Synopsis
        Script for up app 
    .DESCRIPTION
        Script for create azure function for node app service  in Azure Cloud
    .PREREQUISITES    
        ./azure-functions.sh
    .EXAMPLE
        ./create-app-function-az900.sh
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
STORAGEACCOUNT="labaz900123456"
APPFOLDER="/opt/azure/apps"
APPNAME="app-az900"
RUNTIME="node"
RUNTIMEVERSION="18"
ROLE="Owner"
FUNCTIONNAME="FuncAz900"
FUNCVERSION="4"
TAG="create-function-app-consumption"
URILOCAL="http://localhost:7071/api/$FUNCTIONNAME?name=Marcos Silvestrini"
URIREMOTE="https://app-az900.azurewebsites.net/api/funcaz900?name=Marcos Silvestrini"

# Login i Azure Cloud
LoginAzurePortal

# Create resource group
if [ $(az group exists --name "$RESOURCEGROUP") = false ]; then
    if az group create \
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

# Create Storage Account
if [ "$(az storage account check-name --name $STORAGEACCOUNT | grep -o true)" = "true" ];
then
    if az storage account create \
        --name $STORAGEACCOUNT \
        --resource-group $RESOURCEGROUP >/dev/null; then
        # Waiting for storage account resource to be created
        echo "Waiting for storage account resource $STORAGEACCOUNT to be created"
        x=1
        while [ $x -le 30 ]; do
            sleep 1
            x=$(($x + 1))
        done
        echo "Storage Account $STORAGEACCOUNT has create successfully!!"
        echo "Storage Account $STORAGEACCOUNT has create successfully!!" >>"$LOGFUNCTIONS"
        echo "----------------------------------------------------"
    else
        echo "Error in create Storage Account $STORAGEACCOUNT. Please check in your Azure Dashboard"
        echo "Error in create Storage Account $STORAGEACCOUNT. Please check in your Azure Dashboard" >>"$LOGFUNCTIONS"
        echo "----------------------------------------------------"
    fi
else
    echo "Storage Account $STORAGEACCOUNT has create successfully!!"
    echo "Storage Account $STORAGEACCOUNT has create successfully!!" >>"$LOGFUNCTIONS"
    echo "----------------------------------------------------"
fi

# Create a local Azure Function Project
echo "Create Local Project Function $FUNCTIONNAME" 
echo "Create Local Project Function $FUNCTIONNAME"  >>"$LOGFUNCTIONS"
echo "----------------------------------------------------"
if [ -d "$APPFOLDER" ]; then
    rm -rf "$APPFOLDER"
fi
mkdir -p "$APPFOLDER"
chown -R  vagrant:vagrant $APPFOLDER
chmod -R 777 $APPFOLDER
cd $APPFOLDER || exit
mkdir "$FUNCTIONNAME"
cd $FUNCTIONNAME || exit
func init . --model V3 --worker-runtime node >/dev/null
func azure storage fetch-connection-string $STORAGEACCOUNT
func new --template "Http Trigger" --name "$FUNCTIONNAME" --authlevel "anonymous" >/dev/null

# Up local Function for testing purposes
echo "Starting Local Function $FUNCTIONNAME"
echo echo "Starting Local Function $FUNCTIONNAME"  >>"$LOGFUNCTIONS"
echo "----------------------------------------------------"
cd /home/vagrant || exit
lsof | grep '\/opt\/azure\/apps\/FuncAz900' | awk '{print $2}' | xargs kill -9 >/dev/null 2>&1
cd "$APPFOLDER/$FUNCTIONNAME" || exit
nohup func start &
sleep 10

# Test local function
echo "Test Local Function [$FUNCTIONNAME]" 
echo "Test Local Function [$FUNCTIONNAME]" >>"$LOGFUNCTIONS"
echo "URI: [$URILOCAL]"
echo "URI: [$URILOCAL]" >>"$LOGFUNCTIONS"
echo "Result:  $(curl -s http://localhost:7071/api/$FUNCTIONNAME?name=Marcos Silvestrini)"
echo "Result:  $(curl -s http://localhost:7071/api/$FUNCTIONNAME?name=Marcos Silvestrini)" >> "$LOGFUNCTIONS"
echo "----------------------------------------------------"

# Create Azure App function
if [ "$(az functionapp list --query "[].{hostName: defaultHostName, state: state}" | grep -o "$APPNAME")" = "" ];
then
    if az functionapp create \
        --name $APPNAME \
        --storage-account $STORAGEACCOUNT \
        --consumption-plan-location "$LOCATION" \
        --resource-group $RESOURCEGROUP \
        --role $ROLE \
        --runtime $RUNTIME \
        --runtime-version $RUNTIMEVERSION \
        --functions-version $FUNCVERSION >/dev/null;
    then
        echo "Waiting for function app $APPNAME to be created"
        x=1
        while [ $x -le 30 ]; do
            sleep 1
            x=$(($x + 1))
        done
        echo "App Function $APPNAME has create successfully!!"
        echo "App Function $APPNAME has create successfully!!" >>"$LOGFUNCTIONS"
        echo "----------------------------------------------------"
    else
        echo "Error in create App Function $APPNAME. Please check in your Azure Dashboard"
        echo echo "Error in create App Function $APPNAME. Please check in your Azure Dashboard" >>"$LOGFUNCTIONS"
        echo "----------------------------------------------------"
    fi
else
    echo "App Function $APPNAME has create successfully!!"
    echo "App Function $APPNAME has create successfully!!" >>"$LOGFUNCTIONS"
    echo "----------------------------------------------------"
fi

# Publish function in Azure Cloud
echo "Publish Local Project Function $FUNCTIONNAME in Azure Cloud"
echo "Publish Local Project Function $FUNCTIONNAME in Azure Cloud" >>"$LOGFUNCTIONS"
echo "----------------------------------------------------"
func azure functionapp publish $APPNAME --force >/dev/null

# Set App Function for new function
echo "Config App Function with function $FUNCTIONNAME in Azure Cloud"
echo "Config App Function with function $FUNCTIONNAME in Azure Cloud" >>"$LOGFUNCTIONS"
echo "----------------------------------------------------"
az functionapp config appsettings set \
    --name $APPNAME \
    --resource-group $RESOURCEGROUP \
    --settings AzureWebJobsFeatureFlags=EnableWorkerIndexing >/dev/null

# Start App Function
echo "Starting Remote Function $FUNCTIONNAME"
echo "Starting Remote Function $FUNCTIONNAME"  >>"$LOGFUNCTIONS"
echo "----------------------------------------------------"
az functionapp restart --name $APPNAME --resource-group $RESOURCEGROUP
sleep 30

# Test local function
echo "Test Local Function [$FUNCTIONNAME]" 
echo "Test Local Function [$FUNCTIONNAME]" >>"$LOGFUNCTIONS"
echo "URI: [$URIREMOTE]"
echo "URI: [$URIREMOTE]" >>"$LOGFUNCTIONS"
echo "Result:  $(curl -s http://localhost:7071/api/$FUNCTIONNAME?name=Marcos Silvestrini)"
echo "Result:  $(curl -s http://localhost:7071/api/$FUNCTIONNAME?name=Marcos Silvestrini)" >> "$LOGFUNCTIONS"
echo "----------------------------------------------------"

# Logout in Azure Cloud
LogoutAzurePortal
