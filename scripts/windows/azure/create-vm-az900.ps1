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
$basepath = (($scriptPath | Split-Path -Parent) | Split-Path -Parent) | Split-Path -Parent

# Install Azure Powershell
# if(! (Get-Module -Name Az -ListAvailable)){Install-Module -Name Az -AllowClobber -Scope CurrentUser -Force}
# Else{Write-Host "Azure Powershell found."}

# Import my modules\functions
. "$scriptPath/azure-functions.ps1"

# Logging
$logFunctions = "$scriptPath\azure-functions.log"

# Install CLI
az --version | Select-String -Pattern "azure-cli"
if (! ($?)) { Install-CLI > $null }

# Variablçes
#$subscription_id=(Get-Content $basepath\security\.azure-secrets | Select-String -Pattern "subscription_id: ").ToString().Split()[1]
$json = [ordered]@{}
(Get-Content $basepath\security\.azure-secrets -Raw | ConvertFrom-Json).PSObject.Properties |
ForEach-Object { $json[$_.Name] = $_.Value }

$resourcegroup = "labs"
$location = "eastus"
$priority = "Spot"
$image = "Debian:debian-11:11-backports-gen2:latest"
$vmName = "lab-az900"
$authenticationType = "all"
$sshKeyName = "id_rsa_$vmName"
$adminUsername = "vagrant"
$adminPassword = "Vagrant@123456"

# Login i Azure Cloud
LoginAzurePortal

# Create resource group
if ( $(az group exists --name $resourcegroup) -eq "false") {
    az group create `
        --resource-group $resourcegroup `
        --location $location
    if ($?) { 
        Write-Host -ForegroundColor Green "Ressource group $resourcegroup has create successfully!!"
        "Ressource group $resourcegroup has create successfully!!" >>$logFunctions
        Write-Host "----------------------------------------------------"
     }
    Else { 
        Write-Host -ForegroundColor Red "Error in create group $resourcegroup. Please check in your Azure Dashboard" 
        "Error in create group $resourcegroup. Please check in your Azure Dashboard" >>$logFunctions
        Write-Host "----------------------------------------------------"
    }
}
else {
    if ($?) { 
        Write-Host -ForegroundColor Green "Ressource group $resourcegroup has create successfully!!"
        "Ressource group $resourcegroup has create successfully!!" >>$logFunctions
        Write-Host "----------------------------------------------------"
    }
    Else { 
        Write-Host -ForegroundColor Red "Error in create group $resourcegroup. Please check in your Azure Dashboard"
        "Error in create group $resourcegroup. Please check in your Azure Dashboard" >>$logFunctions
        Write-Host "----------------------------------------------------"
    }
}


# Create Virtual machine
if ("$(az vm list -d -o table --query "[?name=='$VMNAME']")" -eq "") {
    az vm create `
        --resource-group $resourcegroup `
        --public-ip-sku Standard `
        --image $image `
        --name $vmName `
        --computer-name $vmName `
        --priority $priority `
        --admin-username $adminUsername  `
        --admin-password $adminPassword `
        --generate-ssh-keys `
        --ssh-key-name $sshKeyName `
        --authentication-type $authenticationType
    if ($?) { 
        Write-Host -ForegroundColor Green "VM $vmname has create successfully!!"
        "VM $vmname has create successfully!!" >>$logFunctions
        Write-Host "----------------------------------------------------"
     }
    Else { 
        Write-Host -ForegroundColor Red "Error in create VM $VMNAME. Please check in your Azure Dashboard" 
        "Error in create VM $VMNAME. Please check in your Azure Dashboard" >>$logFunctions
        Write-Host "----------------------------------------------------"
    }
}
Else { 
    Write-Host -ForegroundColor Green "VM $vmname has create successfully!!"
    "VM $vmname has create successfully!!" >> $logFunctions
    Write-Host "----------------------------------------------------"
}

# Logout i Azure Cloud
LogoutAzurePortal