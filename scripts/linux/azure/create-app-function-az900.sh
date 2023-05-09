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
<<<<<<< HEAD
FUNCVERSION="4"
TAG="create-function-app-consumption"
URILOCAL="http://localhost:7071/api/$FUNCTIONNAME?name=Marcos Silvestrini"
URIREMOTE="https://app-az900.azurewebsites.net/api/funcaz900?name=Marcos Silvestrini"
=======
>>>>>>> 1b5c4cf5267d60f9590e9ccd1bf2eb3451d50e09

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
<<<<<<< HEAD
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
=======
mkdir -p /opt/azure/app-services/$APPNODENAME/functions
chmod 777 -R /opt/azure/app-services/$APPNODENAME
func init /opt/azure/app-services/$APPNODENAME/functions --model V4 --worker-runtime node
cd /opt/azure/app-services/$APPNODENAME/functions || exit
func new --template "Http Trigger" --name "$FUNCTIONNAME" --authlevel "anonymous"
func azure functionapp publish $FUNCTIONNAME

# # Create the web application on the plan
# # Specify the node version your app requires
# if [ "$(az webapp list -o table --query "[?name=='$APPNAME']")" = "" ]; then
#     if az webapp create \
#         --role "$ROLE" \
#         --name "$APPNAME" \
#         --plan "$PLANNAME" \
#         --resource-group "$RESOURCEGROUP" \
#         --runtime "$RUNTIMEWEBAPP"; then
#         echo "Webapp $APPNAME has create successfully!!"
#         echo "Webapp $APPNAME has create successfully!!" >>"$LOGFUNCTIONS"
#         echo "----------------------------------------------------"
#     else
#         echo "Error in create webapp $APPNAME. Please check in your Azure Dashboard"
#         echo "Error in create webapp $APPNAME. Please check in your Azure Dashboard" >>"$LOGFUNCTIONS"
#         echo "----------------------------------------------------"
#     fi
# else
#     echo "Webapp $APPNAME has create successfully!!"
#     echo "Webapp $APPNAME has create successfully!!" >>"$LOGFUNCTIONS"
#     echo "----------------------------------------------------"
# fi

# # To set up deployment from a local git repository, uncomment the following commands.
# # first, set the username and password (use environment variables!)
# if [ "$(az webapp deployment user show | grep publishingUserName | cut -c 24-34)" != "$USERNAME" ];
# then
#     if az webapp deployment user set \
#         --user-name "$USERNAME" \
#         --password "$PASSWORD"; then
#         echo "Deployment user $USERNAME set with successful!!"
#         echo "Deployment user $USERNAME set with successful!!" >>"$LOGFUNCTIONS"
#         echo "----------------------------------------------------"
#     else
#         echo "Error in Deployment user $USERNAME set. Please check in your Azure Dashboard"
#         echo "Error in Deployment user $USERNAME set. Please check in your Azure Dashboard" >>"$LOGFUNCTIONS"
#         echo "----------------------------------------------------"
#     fi
# else
#     echo "Deployment user $USERNAME set with successful!!"
#     echo "Deployment user $USERNAME set with successful!!" >>"$LOGFUNCTIONS"
#     echo "----------------------------------------------------"
# fi

# # # now, configure the site for deployment. in this case, we will deploy from the local git repository
# # # you can also configure your site to be deployed from a remote git repository or set up a CI/CD workflow
# if [ "$(az webapp deployment source show --name $APPNAME --resource-group $RESOURCEGROUP 2>&1 | grep "Code: ResourceGroupNotFound")" != "" ];
# then
#     if az webapp deployment source config-local-git \
#         --name "$APPNAME" \
#         --resource-group "$RESOURCEGROUP"; then
#         echo "Deployment Source for site $APPNAME set with successful!!"
#         echo "Deployment Source for site $APPNAME set with successful!!" >>"$LOGFUNCTIONS"
#         echo "----------------------------------------------------"
#     else
#         echo "Error in Deployment Source for Site $APPNAME. Please check in your Azure Dashboard"
#         echo "Error in Deployment Source for Site $APPNAME. Please check in your Azure Dashboard" >>"$LOGFUNCTIONS"
#         echo "----------------------------------------------------"
#     fi
# else
#     echo "Deployment Source for Site $APPNAME set with successful!!"
#     echo "Deployment Source for Site $APPNAME set with successful!!" >>"$LOGFUNCTIONS"
#     echo "----------------------------------------------------"
# fi

# # Create Node App local for deploy in Azure App Service
# if [ -d "/opt/azure/app-services" ]; then
#     rm -rf /opt/azure/app-services
# fi
# mkdir -p /opt/azure/app-services
# npm config set prefix '/opt/azure/app-services'
# cd /opt/azure/app-services || exit
# npx --yes express-generator $APPNODENAME --view pug --git
# export PATH=/opt/azure/app-services/$APPNODENAME/bin:$PATH
# cd $APPNODENAME || exit
# npm install -y
# DATE=$(date '+%Y-%m-%d %H:%M:%S')
# sed -i "s/Express/LAB AZ-900 - DEPLOY APP SERVICE IN AZURE CLOUD - MARCOS SILVESTRINI - $DATE /g" /opt/azure/app-services/$APPNODENAME/routes/index.js
# chmod 777 -R /opt/azure/app-services/$APPNODENAME/
#(teste localhost:3000)
#npm start &

# # Create a local Azure Function Project
# # https://learn.microsoft.com/en-us/azure/azure-functions/create-first-function-vs-code-node?pivots=nodejs-model-v4
# mkdir -p /opt/azure/app-services/$APPNODENAME/functions
# chmod 777 -R /opt/azure/app-services/$APPNODENAME
# func init /opt/azure/app-services/$APPNODENAME/functions --model V4 --worker-runtime node
# cd /opt/azure/app-services/$APPNODENAME/functions || exit
# func new --template "Http Trigger" --name "$FUNCTIONNAME" --authlevel "anonymous"
# func azure functionapp publish $FUNCTIONNAME


# # the previous command returned the git remote to deploy to
# # use this to set up a new remote named "azure"
# cd /opt/azure/app-services/$APPNODENAME || exit
# if [ -d ".git" ]; then
#     rm -rf .git
# fi

# git config --global --add safe.directory .
# git init 
# git config --global user.name "$USERNAME"
# git config --global user.mail "$USERNAME@outlook.com"
# git remote add origin "https://$USERNAME@$APPNAME.scm.azurewebsites.net/$APPNAME.git"
# git remote set-url origin "https://$USERNAME:$PASSWORD@$APPNAME.scm.azurewebsites.net/$APPNAME.git"
# git config credential.helper store;

# # Add and Commit files
# git add .
# git commit -m "Deployment site $APPNAME"

# # Push master to azure for deploy the site
# if git push -f origin master; then
#     echo "Set remote repository for deployment site $APPNAME with successful!!"
#     echo "Set remote repository for deployment site $APPNAME with successful!!" >>"$LOGFUNCTIONS"
#     echo "----------------------------------------------------"
# else
#     echo "Error in set remote repository for deployment site $APPNAME.Please check in your Azure Dashboard"
#     echo "Error in set remote repository for deployment site $APPNAME.Please check in your Azure Dashboard" >>"$LOGFUNCTIONS"
#     echo "----------------------------------------------------"
# fi
>>>>>>> 1b5c4cf5267d60f9590e9ccd1bf2eb3451d50e09

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
