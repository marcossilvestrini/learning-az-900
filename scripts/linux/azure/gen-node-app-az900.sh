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
LOGFUNCTIONS="$SCRIPT_PATH/generate-node-az900.log"
echo "###############Begin Log ###################" >"$LOGFUNCTIONS"
date=$(date '+%Y-%m-%d %H:%M:%S')
echo "Date: $date">> "$LOGFUNCTIONS"

# Create Node App for deploy in Azure Cloud
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
npm start &

# Copý artefacts to vagrant shared folder 
# cd /home/vagrant || exit
# cp -Rl /opt/azure/app-services/app-node-az900 apps/