<<'SCRIPT'
    .Synopsis
        Script for up lab
    .DESCRIPTION
        Script for up kubernets cluster for learning AZ-900 in Azure Cloud
    .PREREQUISITES    
        ./azure-functions.sh
    .EXAMPLE
        ./create-kubernets-app.sh
SCRIPT

# Set language/locale and encoding
export LANG=C

# Clear screen
clear

cd /home/vagrant || exit

# Scriptpath
path=$(readlink -f "${BASH_SOURCE:-$0}")
DIR_PATH=$(dirname "$path")

# Log functions
LOGFUNCTIONS="$DIR_PATH/azure-functions.log"

# Import my modules\functions
source "$DIR_PATH/azure-functions.sh"

# Variablçes
RESOURCEGROUP="labs"
NAME="app-az900"
LOCATION="eastus"

# Login i Azure Cloud
LoginAzurePortal

# Create resource group
if [ $(az group exists --name "$RESOURCEGROUP") = false ];
 then
    if az group create --only-show-errors \
        --resource-group $RESOURCEGROUP \
        --location $LOCATION >/dev/null;
    then
        echo "Ressource group $RESOURCEGROUP has create successfully!!"
        echo "Ressource group $RESOURCEGROUP has create successfully!!" >>"$LOGFUNCTIONS"
        echo "----------------------------------------------------"
    else 
        echo  "Error in create group $RESOURCEGROUP. Please check in your Azure Dashboard"
        echo  "Error in create group $RESOURCEGROUP. Please check in your Azure Dashboard" >>"$LOGFUNCTIONS"
        echo "----------------------------------------------------"
    fi
else
    echo "Ressource group $RESOURCEGROUP has create successfully!!"
    echo "Ressource group $RESOURCEGROUP has create successfully!!" >>"$LOGFUNCTIONS"
    echo "----------------------------------------------------"
fi

# Create Kubernets Instance
if [ "$(az aks show --name $NAME --resource-group $RESOURCEGROUP 2>&1 | grep dnsPrefix)" = "" ];
then
    if az aks create --only-show-errors \
        --name "$NAME" \
        --resource-group "$RESOURCEGROUP" \
        --generate-ssh-keys >/dev/null;
    then
        echo "Kubernets Cluster $NAME has create successfully!!"
        echo "Kubernets Cluster $NAME has create successfully!!">>"$LOGFUNCTIONS"
        echo "----------------------------------------------------"
    else 
        echo "Error in create Kubernets Cluster $NAME. Please check in your Azure Dashboard" >>"$LOGFUNCTIONS"
        echo "Error in create Kubernets Cluster $NAME. Please check in your Azure Dashboard" >>"$LOGFUNCTIONS"
        echo "----------------------------------------------------"
    fi    
else    
    echo "Kubernets Cluster $NAME has create successfully!!"
    echo "Kubernets Cluster $NAME has create successfully!!" >>"$LOGFUNCTIONS"
    echo "----------------------------------------------------"
fi

# Logout in Azure Cloud
 LogoutAzurePortal
