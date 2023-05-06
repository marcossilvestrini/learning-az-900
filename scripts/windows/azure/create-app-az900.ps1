<#
.Synopsis
    Script for up lab
.DESCRIPTION
   Script for up node web app for learning AZ-900 in Azure Cloud
   .PREREQUISITES    
    ./azure-functions.ps1
.EXAMPLE
    ./create-app-az900.ps1
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
$json = [ordered]@{}
(Get-Content $basepath\security\.azure-secrets -Raw | ConvertFrom-Json).PSObject.Properties |
ForEach-Object { $json[$_.Name] = $_.Value }
$subscription="labs"
$resourcegroup = "labs"
$location = "eastus"
$planname="app-az900"
$plansku="F1"
$sitename="app-az900"
$runtime="NODE:18-lts"
$role="Owner"


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
# Create Appservice Plan
if ("$(az appservice plan list -o table  --query "[?name=='$planname']")" -eq "") {
az appservice plan create `
    --is-linux `
    --name $planname `
    --location $location `
    --sku $plansku `
    --resource-group $resourcegroup 
    if ($?) { 
        Write-Host -ForegroundColor Green "Appservice Plan $planname has create successfully!!"
        "Appservice Plan $planname has create successfully!!" >>$logFunctions
        Write-Host "----------------------------------------------------"
     }
    Else { 
        Write-Host -ForegroundColor Red "Error in create Appservice Plan $panname. Please check in your Azure Dashboard" 
        "Error in create Appservice Plan $panname. Please check in your Azure Dashboard" >>$logFunctions
        Write-Host "----------------------------------------------------"
    }
}
Else { 
    Write-Host -ForegroundColor Green "Appservice Plan $planname has create successfully!!"
    "Appservice Plan $planname has create successfully!!" >> $logFunctions
    Write-Host "----------------------------------------------------"
}


# Create the web application on the plan
# Specify the node version your app requires
if ("$(az webapp list -o table  --query "[?name=='$sitename']")" -eq "") {
az webapp create `
    --role $role `
    --name $sitename `
    --plan $planname `
    --resource-group $resourcegroup `
    --runtime $runtime
    if ($?) { 
        Write-Host -ForegroundColor Green "Webapp $sitename has create successfully!!"
        "Webapp $sitename has create successfully!!" >>$logFunctions
        Write-Host "----------------------------------------------------"
     }
    Else { 
        Write-Host -ForegroundColor Red "Error in create webapp $sitename. Please check in your Azure Dashboard" 
        "Error in create webapp $sitename. Please check in your Azure Dashboard"  >>$logFunctions
        Write-Host "----------------------------------------------------"
    }
}
Else { 
    Write-Host -ForegroundColor Green "Webapp $sitename has create successfully!!"
    "Webapp $sitename has create successfully!!" >> $logFunctions
    Write-Host "----------------------------------------------------"
}
# To set up deployment from a local git repository, uncomment the following commands.
# first, set the username and password (use environment variables!)
# USERNAME=""
# PASSWORD=""
# az webapp deployment user set --user-name $USERNAME --password $PASSWORD

# now, configure the site for deployment. in this case, we will deploy from the local git repository
# you can also configure your site to be deployed from a remote git repository or set up a CI/CD workflow
# az webapp deployment source config-local-git --name $SITENAME --resource-group $RESOURCEGROUP

# the previous command returned the git remote to deploy to
# use this to set up a new remote named "azure"
# git remote add azure "https://$USERNAME@$SITENAME.scm.azurewebsites.net/$SITENAME.git"
# push master to deploy the site
# git push azure master

# browse to the site
# az webapp browse --name $SITENAME --resource-group $RESOURCEGROUP

# Logout i Azure Cloud
LogoutAzurePortal