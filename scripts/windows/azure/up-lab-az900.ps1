<#
.Synopsis
    Script for up lab
.DESCRIPTION
   Script for up lab for learning AZ-900 in Azure Cloud
   .PREREQUISITES    
    ./azure-functions.ps1
.EXAMPLE
    ./up-lab-az900.ps1
#>

# Script path
$scriptPath = $PSScriptRoot

# Install Azure Powershell
# if(! (Get-Module -Name Az -ListAvailable)){Install-Module -Name Az -AllowClobber -Scope CurrentUser -Force}
# Else{Write-Host "Azure Powershell found."}

# Import my modules\functions
. "$scriptPath/azure-functions.ps1"

# Install CLI
az --version | Select-String -Pattern "azure-cli"
if(! ($?)){Install-CLI > $null}

# Variablçes
$groupName = "labs"
$location="eastus"
$priority="Spot"
$authenticationType = "all"
$image="Debian:debian-11:11-backports-gen2:latest"
$vmName = "lab-az900"
$adminUsername = "vagrant"
$adminPassword = "Vagrant@123456789"

# Create resource group
az group create `
--resource-group $groupName `
--location $location
if($?){Write-Host -ForegroundColor Green "Ressource group for Az-900 has create successfully!!"}
Else{Write-Host -ForegroundColor Red "Error in create Labs for Az-900. Please check in your Azure Dashboard"}

# Create Virtual machine
az vm create `
--resource-group $groupName `
--image $image `
--name $vmName `
--computer-name $vmName `
--priority $priority `
--admin-username $adminUsername  `
--admin-password $adminPassword `
--generate-ssh-keys `
--authentication-type 'all'        
if($?){Write-Host -ForegroundColor Green "VM for Az-900 has create successfully!!"}
Else{Write-Host -ForegroundColor Red "Error in create Labs for Az-900. Please check in your Azure Dashboard"}


