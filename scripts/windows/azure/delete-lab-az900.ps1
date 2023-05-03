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

# Import my modules\functions
. "$scriptPath/azure-functions.ps1"

# Install CLI
az --version | Select-String -Pattern "azure-cli"
if(! ($?)){Install-CLI > $null}

# Variables
$groupName = "labs"

# delete resource group
$groupName = "labs"
if( (az group exists -n $groupName) -eq $true){
    az group delete --resource-group $groupName --yes 
    az group delete --resource-group NetworkWatcherRG --yes
}
if($?){Write-Host -ForegroundColor Green "Labs for Az-900 has deleted successfully!!"}
Else{Write-Host -ForegroundColor Red "Error in delete Labs for Az-900. Please check in your Azure Dashboard"}
