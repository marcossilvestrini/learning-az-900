#!/usr/bin/env bash

<<'SCRIPT'
    .Synopsis
        Script for up app 
    .DESCRIPTION
    Script for up node app service  in Azure Cloud
    .PREREQUISITES    
        ./azure-functions.sh
    .EXAMPLE
        ./create-app-az900.sh
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
GROUPNAME="labs"
LOCATION="eastus"
PLANNAME="app-az900"
PLANSKU="F1"
SITENAME="app-az900"
ROLE="Owner"
RUNTIME="NODE:18-lts"

# Login i Azure Cloud
LoginAzurePortal

# Create resource group
if [ $(az group exists --name "$GROUPNAME") = false ];
 then
    if az group create \
        --resource-group $GROUPNAME \
        --location $LOCATION;
    then
        echo "Ressource group $GROUPNAME has create successfully!!"
        echo "Ressource group $GROUPNAME has create successfully!!" >>"$LOGFUNCTIONS"
        echo "----------------------------------------------------"
    else 
        echo  "Error in create group $GROUPNAME. Please check in your Azure Dashboard"
        echo  "Error in create group $GROUPNAME. Please check in your Azure Dashboard" >>"$LOGFUNCTIONS"
        echo "----------------------------------------------------"
    fi
else
    echo "Ressource group $GROUPNAME has create successfully!!"
    echo "Ressource group $GROUPNAME has create successfully!!" >>"$LOGFUNCTIONS"
    echo "----------------------------------------------------"
fi

# Create Appservice Plan
if [ "$(az appservice plan list -o table  --query "[?name=='$PLANNAME']")" = "" ];
then
    if az appservice plan create \
    --is-linux \
    --name $PLANNAME \
    --location $LOCATION \
    --sku $PLANSKU \
    --resource-group $GROUPNAME;
    then
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

# Create the web application on the plan
# Specify the node version your app requires
if [ "$(az webapp list -o table  --query "[?name=='$SITENAME']")" = "" ];
then
    if az webapp create \
    --role $ROLE \
    --name $SITENAME \
    --plan $PLANNAME \
    --resource-group $GROUPNAME \
    --runtime $RUNTIME;
    then
        echo "Webapp $SITENAME has create successfully!!"
        echo "Webapp $SITENAME has create successfully!!" >>"$LOGFUNCTIONS"
        echo "----------------------------------------------------"
    else 
        echo "Error in create webapp $SITENAME. Please check in your Azure Dashboard"
        echo "Error in create webapp $SITENAME. Please check in your Azure Dashboard" >>"$LOGFUNCTIONS"
        echo "----------------------------------------------------"
    fi    
else    
    echo "Webapp $SITENAME has create successfully!!"
    echo "Webapp $SITENAME has create successfully!!" >>"$LOGFUNCTIONS"
    echo "----------------------------------------------------"
fi

# To set up deployment from a local git repository, uncomment the following commands.
# first, set the username and password (use environment variables!)
# USERNAME=""
# PASSWORD=""
# az webapp deployment user set --user-name $USERNAME --password $PASSWORD

# now, configure the site for deployment. in this case, we will deploy from the local git repository
# you can also configure your site to be deployed from a remote git repository or set up a CI/CD workflow
# az webapp deployment source config-local-git --name $SITENAME --resource-group $RESOURCEGROUP

# the previous command returned the git remote to deploy to
# use this to set up a new remote named "azure"
# git remote add azure "https://$USERNAME@$SITENAME.scm.azurewebsites.net/$SITENAME.git"
# push master to deploy the site
# git push azure master

# browse to the site
# az webapp browse --name $SITENAME --resource-group $RESOURCEGROUP


# Logout in Azure Cloud
 LogoutAzurePortal

