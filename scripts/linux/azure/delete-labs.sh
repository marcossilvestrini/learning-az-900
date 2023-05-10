<<'SCRIPT'
    .Synopsis
        Script for delete lab
    .DESCRIPTION
    Script for delete all resources of lab for learning AZ-900 in Azure Cloud
    .PREREQUISITES    
        ./azure-functions.sh
    .EXAMPLE
        ./delete-lab.sh
SCRIPT

# Set language/locale and encoding
export LANG=C

cd /home/vagrant || exit

# Scriptpath
path=$(readlink -f "${BASH_SOURCE:-$0}")
DIR_PATH=$(dirname "$path")

# Log functions
LOGFUNCTIONS="$DIR_PATH/azure-functions.log"

# Import my modules\functions
source "$DIR_PATH/azure-functions.sh"

# Variables
RESOURCEGROUP="labs"

# Login i Azure Cloud
LoginAzurePortal

# SDelete resource group labs
if [ $(az group exists --name "$RESOURCEGROUP") = true ];
then
    if az group delete --resource-group "$RESOURCEGROUP" --yes && az group delete --resource-group NetworkWatcherRG --yes;
    then
        echo "Ressource for Labs Az-900 has deleted successfully!!"
        echo "Ressource for Labs Az-900 has deleted successfully!!" >> "$LOGFUNCTIONS"
        echo "----------------------------------------------------"
    else
    echo "Error in delete Ressources for Labs Az-900. Please check in your Azure Dashboard"
    echo "Error in delete Ressources for Labs Az-900. Please check in your Azure Dashboard" >> "$LOGFUNCTIONS"
    echo "----------------------------------------------------"
    fi
else
    echo "Ressource for Labs Az-900 has deleted successfully!!"
    echo "Ressource for Labs Az-900 has deleted successfully!!" >> "$LOGFUNCTIONS"
    echo "----------------------------------------------------"
fi

# Logout in Azure Cloud
  LogoutAzurePortal