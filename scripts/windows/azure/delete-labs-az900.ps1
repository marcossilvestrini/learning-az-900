<#
.Synopsis
    Script for delete lab
.DESCRIPTION
   Script for delete all resources of lab for learning AZ-900 in Azure Cloud
   .PREREQUISITES    
    ./azure-functions.ps1
.EXAMPLE
    ./up-lab-az900.ps1
#>

# Script path
$scriptPath = $PSScriptRoot
$basepath = (($scriptPath | Split-Path -Parent) |Split-Path -Parent)|Split-Path -Parent

# Import my modules\functions
. "$scriptPath/azure-functions.ps1"

# Logging
$logFunctions = "$scriptPath\azure-functions.log"

# Install CLI
az --version | Select-String -Pattern "azure-cli"
if(! ($?)){Install-CLI > $null}

# Variables
$resourcegroup = "labs"
$json = [ordered]@{}
(Get-Content $basepath\security\.azure-secrets -Raw | ConvertFrom-Json).PSObject.Properties |
ForEach-Object { $json[$_.Name] = $_.Value }

# Login i Azure Cloud
LoginAzurePortal

# delete resource group
$resourcegroup = "labs"
if( (az group exists -n $resourcegroup) -eq $true){
    az group delete --resource-group $resourcegroup --yes 
    az group delete --resource-group NetworkWatcherRG --yes
}
if($?){
    Write-Host -ForegroundColor Green "Ressource for Labs Az-900 has deleted successfully!!"
    "Ressource for Labs Az-900 has deleted successfully!!" >> $logFunctions
    Write-Host "----------------------------------------------------"
}
Else{
    Write-Host -ForegroundColor Red "Error in delete Ressources for Labs Az-900. Please check in your Azure Dashboard"
    "Error in delete Ressources for Labs Az-900. Please check in your Azure Dashboard" >> $logFunctions
    Write-Host "----------------------------------------------------"
}

# Logout i Azure Cloud
LogoutAzurePortal