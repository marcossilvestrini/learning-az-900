#!/usr/bin/env bash

<<'SCRIPT'
    .Synopsis
        Script for up app 
    .DESCRIPTION
    Script for up node app service  in Azure Cloud
    .PREREQUISITES    
        ./azure-functions.sh
    .EXAMPLE
        ./create-app-service.sh
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
PLANSKU="F1"
SITENAME="app-az900"
ROLE="Owner"
RUNTIME="NODE:18-lts"

# Create Node App local for deploy in Azure Cloud
if [ -d "/opt/azure/app-services" ];
then
    rm -rf /opt/azure/app-services
fi
mkdir -p  /opt/azure/app-services
npm config set prefix '/opt/azure/app-services'
cd /opt/azure/app-services || exit
npx --yes express-generator app-node-az900 --view pug --git
export PATH=/opt/azure/app-services/app-node-az900/bin:$PATH
cd app-node-az900 || exit
npm install -y
sed -i "s/Express/LAB AZ-900 - DEPLOY APP SERVICE IN AZURE CLOUD /g" /opt/azure/app-services/app-node-az900/routes/index.js
chmod 777 -R /opt/azure/app-services/app-node-az900/
#(teste localhost:3000)
#npm start &


# Login i Azure Cloud
LoginAzurePortal

# Create resource group
if [ $(az group exists --name "$RESOURCEGROUP") = false ];
 then
    if az group create --only-show-errors \
        --resource-group $RESOURCEGROUP \
        --location $LOCATION >/dev/null;
    then
        echo "Ressource group $RESOURCEGROUP has create successfully!!"
        echo "Ressource group $RESOURCEGROUP has create successfully!!" >>"$LOGFUNCTIONS"
        echo "----------------------------------------------------"
    else 
        echo  "Error in create group $RESOURCEGROUP. Please check in your Azure Dashboard"
        echo  "Error in create group $RESOURCEGROUP. Please check in your Azure Dashboard" >>"$LOGFUNCTIONS"
        echo "----------------------------------------------------"
    fi
else
    echo "Ressource group $RESOURCEGROUP has create successfully!!"
    echo "Ressource group $RESOURCEGROUP has create successfully!!" >>"$LOGFUNCTIONS"
    echo "----------------------------------------------------"
fi

# Create Appservice Plan
if [ "$(az appservice plan list -o table  --query "[?name=='$PLANNAME']")" = "" ];
then
    if az appservice plan create --only-show-errors \
    --is-linux \
    --name $PLANNAME \
    --location $LOCATION \
    --sku $PLANSKU \
    --resource-group $RESOURCEGROUP >/dev/null;
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
    if az webapp create --only-show-errors \
    --role $ROLE \
    --name $SITENAME \
    --plan $PLANNAME \
    --resource-group $RESOURCEGROUP \
    --runtime $RUNTIME  >/dev/null;
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
if az webapp deployment user set --only-show-errors \
     --user-name "$USERNAME" \
     --password "$PASSWORD" >/dev/null;
    then
        echo "Deployment user $USERNAME set with successful!!"
        echo "Deployment user $USERNAME set with successful!!" >>"$LOGFUNCTIONS"
        echo "----------------------------------------------------"
    else 
        echo "Error in Deployment user $USERNAME set. Please check in your Azure Dashboard"
        echo "Error in Deployment user $USERNAME set. Please check in your Azure Dashboard" >>"$LOGFUNCTIONS"
        echo "----------------------------------------------------"
fi    

# now, configure the site for deployment. in this case, we will deploy from the local git repository
# you can also configure your site to be deployed from a remote git repository or set up a CI/CD workflow
if az webapp deployment source config-local-git --only-show-errors \
    --name $SITENAME \
    --resource-group $RESOURCEGROUP >/dev/null;
    then
        echo "Deployment site $SITENAME set with successful!!"
        echo  "Deployment site $SITENAME set with successful!!" >>"$LOGFUNCTIONS"
        echo "----------------------------------------------------"
    else 
        echo "Error in Deployment site $SITENAME. Please check in your Azure Dashboard"
        echo "Error in Deployment site $SITENAME. Please check in your Azure Dashboard" >>"$LOGFUNCTIONS"
        echo "----------------------------------------------------"
fi    

# the previous command returned the git remote to deploy to
# use this to set up a new remote named "azure"
cd /opt/azure/app-services/app-node-az900 || exit
if git config --global --add safe.directory . && \
    git config --global user.name "$USERNAME" && \
    git config --global user.mail "$USERNAME@outlook.com" && \
    git init && \
    git remote add origin "https://$USERNAME@$SITENAME.scm.azurewebsites.net/$SITENAME.git" && \
    git remote set-url origin "https://$USERNAME:$PASSWORD@$SITENAME.scm.azurewebsites.net/$SITENAME.git";
    git config credential.helper store;    
    then
        echo "Set remote repository for deployment site $SITENAME with successful!!"
        echo  "Set remote repository for deployment site $SITENAME with successful!!" >>"$LOGFUNCTIONS"
        echo "----------------------------------------------------"
    else 
        echo "Error in set remote repository for deployment site $SITENAME. Please check in your Azure Dashboard"
        echo "Error in set remote repository for deployment site $SITENAME. Please check in your Azure Dashboard" >>"$LOGFUNCTIONS"
        echo "----------------------------------------------------"
fi   

# Add and Commit files
git add .
git commit -m "Deployment site $SITENAME"

# push master to deploy the site
if git push origin master;
    then
        echo "Set remote repository for deployment site $SITENAME with successful!!"
        echo  "Set remote repository for deployment site $SITENAME with successful!!" >>"$LOGFUNCTIONS"
        echo "----------------------------------------------------"
    else 
        echo "Error in set remote repository for deployment site $SITENAME ". Please check in your Azure Dashboard"
        echo "Error in set remote repository for deployment site $SITENAME ". Please check in your Azure Dashboard" >>"$LOGFUNCTIONS"
        echo "----------------------------------------------------"
fi   

# browse to the site
# az webapp browse --name $SITENAME --resource-group $RESOURCEGROUP

# Logout in Azure Cloud
 LogoutAzurePortal

