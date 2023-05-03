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