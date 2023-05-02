<#
.Synopsis
    Install cli
.DESCRIPTION
   Script for install azure cli in windows
   .PREREQUISITES
    ./azure-functions.ps1
.EXAMPLE
    Install-CLI   
#>

# Script path
$scriptPath = $PSScriptRoot

# Import functions
. "$scriptPath/azure-functions.ps1"

# Install cli
Install-CLI

# Test azure cli
az --version >>azure-functions.log