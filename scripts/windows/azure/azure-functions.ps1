<#
.Synopsis
   Script with powershell functions for use in Azure 
.DESCRIPTION
   Script with powershell functions for use in Azure. Contain some functions for managment Azure cloud services.
.EXAMPLE
   ./azure-functions.ps1
#>

# # Execute script as root\administrator
# if (-NOT ([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole] "Administrator"))  
# {  
#   $arguments = "& '" +$myinvocation.mycommand.definition + "'"
#   Start-Process -Wait powershell -Verb runAs -WindowStyle Hidden -ArgumentList $arguments
#   Break
# }

# Scriptpath
$scriptPath = $PSScriptRoot
$basepath = (($scriptPath | Split-Path -Parent) | Split-Path -Parent) | Split-Path -Parent

# Log for functions
$logFunctions = "$scriptPath\azure-functions.log"
Out-File $logFunctions 
"############### Begin Log ###################" >>$logFunctions
$date = "Date: " + (get-date).ToString("dd-MM-yyyy HH:mm:ss")
$date >>$logFunctions

# Variables
$json = [ordered]@{}
(Get-Content $basepath\security\.azure-secrets -Raw | ConvertFrom-Json).PSObject.Properties |
ForEach-Object { $json[$_.Name] = $_.Value }

# Function Install-CLI
Function Install-CLI {
   <#
    .Synopsis
        Install azure cli
    .DESCRIPTION
        Function for install azure cli in windows
    .EXAMPLE
         ./azure-functions.ps1
         Install-CLI
   #>           
   Add-Content -Value "Install azure CLI.Please waiting..." -Path $logFunctions
   winget install -e --id Microsoft.AzureCLI  >>$logFunctions  
   If ($?) { "Install CLI success!!!" >>$logFunctions }
   Else { "Please check log for details." >>$logFunctions }
}

# Login-AzurePortal
Function LoginAzurePortal {
   # Use az cli   
   az login --only-show-errors `
      --service-principal `
      --username $json.clientId `
      --password $json.clientSecret `
      --tenant $json.tenantId
   
   # Use Azure Powershell
   <#
   (Get-Credential).password | ConvertFrom-SecureString | set-content “D:\Password\password.txt”
   # The password in the D:\password\password.txt is encrypted. In this way, we are providing another layer of security.
   $file = “D:\Password\password.txt”
   $UserName = “prashanth@abc.com”
   $Password = Get-Content $file | ConvertTo-SecureString
   $credential = New-Object System.Management.Automation.PsCredential($UserName, $Password)
   # Login to the Azure console
   Login-AzAccount -Credential $credential
   #>
   If ($?) { 
      Write-Host -ForegroundColor Green "Login in Azure Portal success!!!" 
      "Login in Azure Portal success!!!" >>$logFunctions 
      Write-Host "----------------------------------------------------"
   }
   Else { 
      Write-Host -ForegroundColor Red "Login in Azure Portal success!!!"       
      "Please check log for details." >>$logFunctions 
      Write-Host "----------------------------------------------------"
   }
}

# Functio for logout in Azure Portal
Function LogoutAzurePortal{    
   az logout --only-show-errors `
      --username $json.username
   if ($?) { 
      Write-Host -ForegroundColor Green "Logout Azure Cloud Successfully!!"
      "Logout Azure Cloud Successfully!!" >> $logFunctions
      Write-Host "----------------------------------------------------"
   }
   Else { 
      Write-Host -ForegroundColor Red "Error in create VM $VMNAME. Please check in your Azure Dashboard" 
      "Error in create VM $VMNAME. Please check in your Azure Dashboard" >> $logFunctions
      Write-Host "----------------------------------------------------"
   }
   "############### End Log ###################" >>$logFunctions
}
