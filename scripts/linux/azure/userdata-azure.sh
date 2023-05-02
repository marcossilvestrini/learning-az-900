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
if [[ "$DISTRO" == *"Debian"* ]]; then    
    curl -sL https://aka.ms/InstallAzureCLIDeb | sudo bash
else    
    rpm --import https://packages.microsoft.com/keys/microsoft.asc
    dnf install -y https://packages.microsoft.com/config/rhel/9.0/packages-microsoft-prod.rpm
fi

# Check install
az --version
