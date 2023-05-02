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

# Log for functions
$logFunctions="$scriptPath\azure-functions.log"
Out-File $logFunctions 
"###############Begin Log ###################" >>$logFunctions
$date="Date: " + (get-date).ToString("dd-MM-yyyy-HH:mm:ss")
$date >>$logFunctions


# Function Install-CLI
Function Install-CLI{
  <#
    .Synopsis
        Install azure cli
    .DESCRIPTION
        Function for install azure cli in windows
    .EXAMPLE
         ./azure-functions.ps1
         Install-CLI
   #>        
   $logFunctions
   Add-Content -Value "Install azure CLI.Please waiting..." -Path $logFunctions
   winget install -e --id Microsoft.AzureCLI  >>$logFunctions  
   If ($?){"Install CLI success!!!" >>$logFunctions}
   Else{"Please check log." >>$logFunctions}
}