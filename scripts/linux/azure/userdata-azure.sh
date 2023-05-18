#!/bin/bash

<<'MULTILINE-COMMENT'
    Requirments: none
    Description: Script for install and configure Azure Tools and some packages for labs.
    Author: Marcos Silvestrini
    Date: 18/04/2023
MULTILINE-COMMENT

# Set language/locale and encoding
export LANG=C
cd /home/vagrant || exit

# Variables
DISTRO=$(cat /etc/*release | grep -ws NAME=)

# Check if distribution is Debian
if [[ "$DISTRO" == *"Debian"* ]]; then    
    echo "Distribution is Debian...Congratulations!!!"
else    
    echo "This script is not available for RPM distributions!!!";exit 1;
fi

# Install packages
apt install -y jq

# Install Node.js
curl -sL https://deb.nodesource.com/setup_14.x | sudo bash -
apt update -y
apt install -y nodejs npm

# Install Azure CLI

## Install packages
curl -sL https://aka.ms/InstallAzureCLIDeb | sudo bash

## Check CLI install
az --version | grep -ws "azure-cli"

## Install the Azure Functions Core Tools
curl https://packages.microsoft.com/keys/microsoft.asc | gpg --dearmor > microsoft.gpg
mv microsoft.gpg /etc/apt/trusted.gpg.d/microsoft.gpg
sh -c 'echo "deb [arch=amd64] https://packages.microsoft.com/debian/$(lsb_release -rs | \
cut -d'.' -f 1)/prod $(lsb_release -cs) main" > /etc/apt/sources.list.d/dotnetdev.list'
apt-get -y update
apt-get install azure-functions-core-tools-4

# Install Powershell 7

## Install system components
apt update && apt install -y curl gnupg apt-transport-https

## Import the public repository GPG keys
curl https://packages.microsoft.com/keys/microsoft.asc | apt-key add -

## Register the Microsoft Product feed
sh -c 'echo "deb [arch=amd64] https://packages.microsoft.com/repos/microsoft-debian-bullseye-prod bullseye main" > /etc/apt/sources.list.d/microsoft.list'

## Install PowerShell
apt update -y && apt install -y powershell

# Install Azure Powershell
pwsh -Command "Install-Module -Name Az -Repository PSGallery -Force"


# Install VScode
apt-get install wget gpg apt-transport-https
wget -qO- https://packages.microsoft.com/keys/microsoft.asc | gpg --dearmor > packages.microsoft.gpg
install -D -o root -g root -m 644 packages.microsoft.gpg /etc/apt/keyrings/packages.microsoft.gpg
sh -c 'echo "deb [arch=amd64,arm64,armhf signed-by=/etc/apt/keyrings/packages.microsoft.gpg] \
 https://packages.microsoft.com/repos/code stable main" > /etc/apt/sources.list.d/vscode.list'
 rm -f packages.microsoft.gpg
 apt update -y
 sudo apt install -y code
code --no-sandbox --user-data-dir /home/vagrant --install-extension ms-vscode.vscode-node-azure-pack

# Install chrome
wget -qO - https://dl.google.com/linux/linux_signing_key.pub |
    gpg --dearmor -o /usr/share/keyrings/googlechrome-linux-keyring.gpg
echo "deb [arch=amd64 signed-by=/usr/share/keyrings/googlechrome-linux-keyring.gpg] http://dl.google.com/linux/chrome/deb/ stable main" |
    tee /etc/apt/sources.list.d/google-chrome.list
apt update -y
apt install -y google-chrome-stable