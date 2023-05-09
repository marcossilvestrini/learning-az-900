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
JSON=security/.azure-secrets
USERNAME=$(jq -r .usernameDeploy $JSON)
PASSWORD=$(jq -r .passwordDeploy $JSON)
RESOURCEGROUP="labs"
LOCATION="eastus"
PLANNAME="app-az900"
APPNAME="app-az900"
APPNODENAME="app-node-az900"
ROLE="Owner"
RUNTIMEWEBAPP="NODE:18-lts"
OSTYPE="Linux"
FUNCTIONNAME="FuncAz900"

# Login i Azure Cloud
LoginAzurePortal

# Create resource group
if [ $(az group exists --name "$RESOURCEGROUP") = false ]; then
    if az group create \
        --resource-group $RESOURCEGROUP \
        --location $LOCATION; then
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

# Create Appservice Plan
if [ "$(az appservice plan list -o table --query "[?name=='$PLANNAME']" | grep $PLANNAME | sed -n 1p | cut -c 1-9)" != "$PLANNAME" ];
then
    echo "Starting create appservice plan now..."
    echo "Starting create appservice plan now..." >>"$LOGFUNCTIONS"
    if az appservice plan create \
        --is-linux \
        --name "$PLANNAME" \
        --location "$LOCATION" \
        --resource-group "$RESOURCEGROUP"; then
        echo "Appservice Plan $PLANNAME has create successfully!!"
        echo "Appservice Plan $PLANNAME has create successfully!!" >>"$LOGFUNCTIONS"
        echo "----------------------------------------------------"
    else
        echo "Error in create Appservice Plan $PLANNAME. Please check in your Azure Dashboard"
        echo "Error in create Appservice Plan $PLANNAME. Please check in your Azure Dashboard" >>"$LOGFUNCTIONS"
        echo "----------------------------------------------------"
    fi
else
    echo "Appservice Plan $PLANNAME has create successfully!!"
    echo "Appservice Plan $PLANNAME has create successfully!!" >>"$LOGFUNCTIONS"
    echo "----------------------------------------------------"
fi

# Create a local Azure Function Project
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

# browse to the site
# az webapp browse --name $APPNAME --resource-group $RESOURCEGROUP

# Logout in Azure Cloud
LogoutAzurePortal

