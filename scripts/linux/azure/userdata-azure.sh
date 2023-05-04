#!/bin/bash

<<'MULTILINE-COMMENT'
    Requirments: none
    Description: Script for generate certificates for apache
    Author: Marcos Silvestrini
    Date: 18/04/2023
MULTILINE-COMMENT

export LANG=C
cd /home/vagrant || exit

# Variables
DISTRO=$(cat /etc/*release | grep -ws NAME=)

# install Common Packages
apt install -y nodejs npm
apt install -y jq

# Install Azure CLI

## Install packages
if [[ "$DISTRO" == *"Debian"* ]]; then    
    curl -sL https://aka.ms/InstallAzureCLIDeb | sudo bash
else    
    rpm --import https://packages.microsoft.com/keys/microsoft.asc
    dnf install -y https://packages.microsoft.com/config/rhel/9.0/packages-microsoft-prod.rpm
fi

## Check CLI install
az --version | grep -ws "azure-cli"

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