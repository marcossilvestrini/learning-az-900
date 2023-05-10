<<'SCRIPT'
    .Synopsis
        Script for up lab
    .DESCRIPTION
        Script for up conteiner with nginx for learning AZ-900 in Azure Cloud
    .PREREQUISITES    
        ./azure-functions.sh
    .EXAMPLE
        ./create-conteiner-app.sh
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

# Variablçes
RESOURCEGROUP="labs"
NAME="app-az900"
DNSLABEL="app-az900"
LOCATION="eastus"
IMAGE="mcr.microsoft.com/oss/nginx/nginx:1.9.15-alpine"

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

# Create Conteiner Intance
if [ "$(az container show -o table --resource-group "$RESOURCEGROUP" --name "$NAME" --query "{FQDN:ipAddress.fqdn,ProvisioningState:provisioningState}")" = "" ];
then
    if az container create --only-show-errors \
    --resource-group "$RESOURCEGROUP" \
    --name "$NAME" \
    --image "$IMAGE" \
    --dns-name-label "$DNSLABEL" \
    --ports 80 >/dev/null;
    then
        echo "Conteiner Instance $NAME has create successfully!!"
        echo "Conteiner Instance $NAME has create successfully!!">>"$LOGFUNCTIONS"
        echo "----------------------------------------------------"
    else 
        echo "Error in create Conteiner Instance $NAME. Please check in your Azure Dashboard" >>"$LOGFUNCTIONS"
        echo "Error in create Conteiner Instance $NAME. Please check in your Azure Dashboard" >>"$LOGFUNCTIONS"
        echo "----------------------------------------------------"
    fi    
else    
    echo "Conteiner Instance $NAME has create successfully!!"
    echo "Conteiner Instance $NAME has create successfully!!" >>"$LOGFUNCTIONS"
    echo "----------------------------------------------------"
fi

# Logout in Azure Cloud
 LogoutAzurePortal
