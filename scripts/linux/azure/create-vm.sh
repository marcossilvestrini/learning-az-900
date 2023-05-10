<<'SCRIPT'
    .Synopsis
        Script for up lab
    .DESCRIPTION
    Script for up virtual machine for learning AZ-900 in Azure Cloud
    .PREREQUISITES    
        ./azure-functions.sh
    .EXAMPLE
        ./create-vm.sh
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
JSON=security/.azure-secrets
USERNAME=$(jq -r .username $JSON)
RESOURCEGROUP="labs"
LOCATION="eastus"
PRIORITY="Spot"
IMAGE="Debian:debian-11:11-backports-gen2:latest"
VMNAME="lab-az900"
AUTHENTICATIONTYPE="all"
SSHKEYNAME="id_rsa_$VMNAME"
ADMINUSERNAME="vagrant"
ADMINPASSWORD="Vagrant@123456"

# Login i Azure Cloud
LoginAzurePortal

# Create resource group
if [ $(az group exists --name "$RESOURCEGROUP") = false ];
 then
    if az group create \
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

# Create Virtual machine
if [ "$(az vm list -d -o table --query "[?name=='$VMNAME']")" = "" ];
then
    if az vm create \
        --resource-group "$RESOURCEGROUP" \
        --public-ip-sku Standard \
        --image "$IMAGE" \
        --name "$VMNAME" \
        --computer-name "$VMNAME" \
        --priority "$PRIORITY" \
        --admin-username "$ADMINUSERNAME"  \
        --admin-password "$ADMINPASSWORD" \
        --generate-ssh-keys \
        --ssh-key-name "$SSHKEYNAME" \
        --authentication-type "$AUTHENTICATIONTYPE" >/dev/null;
        then
            echo "VM $VMNAME has create successfully!!"
            echo "----------------------------------------------------"
    else 
        echo "Error in create VM $VMNAME. Please check in your Azure Dashboard" >>"$LOGFUNCTIONS"
        echo "Error in create VM $VMNAME. Please check in your Azure Dashboard" >>"$LOGFUNCTIONS"
        echo "----------------------------------------------------"
    fi    
else    
    echo "VM $VMNAME has create successfully!!"
    echo "VM $VMNAME has create successfully!!" >>"$LOGFUNCTIONS"
    echo "----------------------------------------------------"
fi

# Logout in Azure Cloud
 LogoutAzurePortal
