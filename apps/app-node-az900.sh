#!/usr/bin/env bash

<<'SCRIPT'
    Requirments: none
    Description: Script for generate azure node app service
    Author: Marcos Silvestrini
    Date: 04/05/2023
SCRIPT

# Set language/locale and encoding
export LANG=C

# Base path
APP_ROOT=$(dirname $(dirname $(readlink -fm $0)))

# Scriptpath
path=$(readlink -f "${BASH_SOURCE:-$0}")
SCRIPT_PATH=$(dirname "$path")

# Log functions
LOGFUNCTIONS="$SCRIPT_PATH/azure-app-az900.log"
echo "###############Begin Log ###################" >"$LOGFUNCTIONS"
date=$(date '+%Y-%m-%d %H:%M:%S')
echo "Date: $date">> "$LOGFUNCTIONS"

# Import my modules\functions
source "$APP_ROOT/scripts/linux/azure/azure-functions.sh"

# Login in Azure
LoginAzurePortal

# Set folder for app
mkdir -p  /opt/azure/app-services
#chmod 777 -R apps/
npm config set prefix '/opt/azure/app-services'
#npm config set user 0
#npm config set unsafe-perm true

# Create App Service
cd //opt/azure/app-services || exit
npx --yes express-generator app-node-az900 --view pug --git
export PATH=/opt/azure/app-services/app-node-az900/bin:$PATH
cd app-node-az900 || exit
npm install -y
sed -i "s/Express/LAB AZ-900 - DEPLOY APP SERVICE IN AZURE CLOUD /g" /opt/azure/app-services/app-node-az900/routes/index.js
#(teste localhost:3000)
npm start &

# Logout Azure PortAL
LogoutAzurePortal