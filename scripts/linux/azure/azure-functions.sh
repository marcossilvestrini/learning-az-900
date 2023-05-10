#!/bin/bash

<<'MULTILINE-COMMENT'
    Requirments: none
    Description: Script for azure automations
    Author: Marcos Silvestrini
    Date: 18/04/2023
MULTILINE-COMMENT

# Set language/locale and encoding
export LANG=C

# Scriptpath
path=$(readlink -f "${BASH_SOURCE:-$0}")
DIR_PATH=$(dirname "$path")

# Log functions
LOGFUNCTIONS="$DIR_PATH/azure-functions.log"
echo "############### Begin Log ###################" >"$LOGFUNCTIONS"
date=$(date '+%Y-%m-%d %H:%M:%S')
echo "Date: $date">> "$LOGFUNCTIONS"

# Variables
JSON=security/.azure-secrets
CLIENT_ID=$(jq -r .clientId $JSON)
CLIENT_SECRET=$(jq -r .clientSecret $JSON)
TENANT=$(jq -r  .tenantId $JSON)
USERNAME=$(jq -r .username $JSON)

# Functio for login in Azure Portal
LoginAzurePortal(){
    cd /home/vagrant || exit    
    if az login --only-show-errors  \
    --service-principal \
    --username "$CLIENT_ID" \
    --password "$CLIENT_SECRET"  \
    --tenant  "$TENANT">/dev/null;
    then    
        echo "Login in Azure Portal success !!!"        
        echo "Login in Azure Portal success !!!" >>"$LOGFUNCTIONS"
        echo "----------------------------------------------------"
   else 
        echo "Please check log for details."
        echo "Please check log for details." >>"$LOGFUNCTIONS"
        echo "----------------------------------------------------"
   fi
}

# Functio for logout in Azure Portal
LogoutAzurePortal(){    
    if az logout --only-show-errors \
        --username "$USERNAME";
    then
        echo "Logout Azure Cloud Successfully!!"
        echo "Logout Azure Cloud Successfully!!" >>"$LOGFUNCTIONS"
        echo "----------------------------------------------------"
    else
        echo "Logout Azure Cloud Failed!!!"    
        echo "Logout Azure Cloud Failed!!!" >>"$LOGFUNCTIONS"
        echo "----------------------------------------------------"
    fi
    echo "############### End Log ###################" >>"$LOGFUNCTIONS"
}
