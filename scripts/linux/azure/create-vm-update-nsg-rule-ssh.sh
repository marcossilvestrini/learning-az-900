<<'SCRIPT'
    .Synopsis
        Script for up lab
    .DESCRIPTION
    Script for up virtual machine and update NSG ssh rule for learning AZ-900 in Azure Cloud
    .PREREQUISITES    
        ./azure-functions.sh
    .EXAMPLE
        ./create-vm-update-nsg-rule-ssh.sh
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

# Update nsg ssh rule
# https://www.jhanley.com/blog/azure-update-network-security-group-rule-with-my-ip-address/

## Find Network Security Group Name
NSGNAME=$(az network nsg list --resource-group $RESOURCEGROUP --query "[].name" -o tsv)

## Find Network Security Group Rule Names
NSGROLENAME=$(az network nsg rule list --resource-group $RESOURCEGROUP --nsg-name $NSGNAME --query "[].name" -o tsv)

## Get my private ip
MYPRIVATEIP=$(hostname -I |grep -Eo "[1-9]{3}\.[1-8]{3}.0.[0-9]{1,3}")

## Get public IP
MYPUBLICIP=$(curl -s https://ipinfo.io | jq -r ".ip")

## List Network Security Group Rule Names, Direction, and Priority
echo "List Network Security Group Rule Names"
echo "List Network Security Group Rule Names" >>"$LOGFUNCTIONS"
echo "----------------------------------------------------"
az network nsg rule list \
    --resource-group "$RESOURCEGROUP" \
    --nsg-name "$NSGNAME" \
    --include-default \
    --query "[].{Name:name, Direction:direction Priority:priority}" \
    --output table

## Update Network Security Group Rule 
echo "Update Network Security Group Rule $NSGROLENAME"
echo "Update Network Security Group Rule $NSGROLENAME" >>"$LOGFUNCTIONS"
if az network nsg rule update \
    --resource-group "$RESOURCEGROUP" \
    --nsg-name "$NSGNAME" \
    --name "$NSGROLENAME" \
    --source-address-prefixes "$MYPUBLICIP" \
    --output none;
then
    echo "Update Network Security Group Rule $NSGROLENAME successfully"
    echo "Update Network Security Group Rule $NSGROLENAME successfully" >>"$LOGFUNCTIONS"
    echo "----------------------------------------------------"
else 
    echo "Error Update Network Security Group Rule $NSGROLENAME. Please check in your Azure Dashboard"
    echo "Error Update Network Security Group Rule $NSGROLENAME. Please check in your Azure Dashboard" >>"$LOGFUNCTIONS"
    echo "----------------------------------------------------"
fi    

# Get public ip for azure vm
#az vm show -d -g $RESOURCEGROUP -n $VMNAME --query publicIps -o tsv

# Logout in Azure Cloud
 LogoutAzurePortal
