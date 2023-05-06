<#
.Synopsis
    Script for up lab
.DESCRIPTION
    Script for create conteiner instance for learning AZ-900 in Azure Cloud
   .PREREQUISITES    
    ./azure-functions.ps1
.EXAMPLE
    ./create-conteiner-app-az900.ps1
#>

# Script path
$scriptPath = $PSScriptRoot
$basepath = (($scriptPath | Split-Path -Parent) | Split-Path -Parent) | Split-Path -Parent

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
$name="app-az900"
$dnslabel="app-az900"
$location="eastus"
$image="mcr.microsoft.com/oss/nginx/nginx:1.9.15-alpine"

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

# Create Conteiner Instance
if ("$(az container show -o table --resource-group "$resourcegroup" --name "$NAME" --query "{FQDN:ipAddress.fqdn,ProvisioningState:provisioningState}")" -eq "") {
    az container create `
        --resource-group "$resourcegroup" `
        --name "$NAME" `
        --image "$IMAGE" `
        --dns-name-label "$DNSLABEL" `
        --ports 80;
    if ($?) { 
        Write-Host -ForegroundColor Green "Conteiner Instance $NAME has create successfully!!"
        "Conteiner Instance $NAME has create successfully!!" >>$logFunctions
        Write-Host "----------------------------------------------------"
     }
    Else { 
        Write-Host -ForegroundColor Red "Error in create Conteiner Instance $NAME. Please check in your Azure Dashboard"
        "Error in create Conteiner Instance $NAME. Please check in your Azure Dashboard" >>$logFunctions
        Write-Host "----------------------------------------------------"
    }
}
Else { 
    Write-Host -ForegroundColor Green "Conteiner Instance $NAME has create successfully!!"
    "Conteiner Instance $NAME has create successfully!!" >> $logFunctions
    Write-Host "----------------------------------------------------"
}

# Logout i Azure Cloud
LogoutAzurePortal