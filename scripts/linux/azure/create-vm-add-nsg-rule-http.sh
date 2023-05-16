<<'SCRIPT'
    .Synopsis
        Script for up lab
    .DESCRIPTION
    Script for up virtual machine and configure NSG http rule for learning AZ-900 in Azure Cloud
    .PREREQUISITES    
        ./azure-functions.sh
    .EXAMPLE
        ./create-vm-add-nsg-rule-http.sh
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

# Install ngin in azure virtual machine
echo "Install Nginx in VM $VMNAME for test NSG roule HTTP|HTTPS."
echo "Install Nginx in VM $VMNAME for test NSG roule HTTP|HTTPS." >>"$LOGFUNCTIONS"
echo "----------------------------------------------------"
VMPUBLICIP=$(az vm show -d --resource-group $RESOURCEGROUP --name $VMNAME --query publicIps -o tsv)
ssh -o StrictHostKeyChecking=no < ./scripts/linux/azure/install-nginx.sh vagrant@$VMPUBLICIP "bash -s -- '<--time bye>' '<end>'" 2>/dev/null

# Update nsg ssh rule (recommended)

## Get public IP
MYPUBLICIP=$(curl -s https://ipinfo.io | jq -r ".ip")

## Find Network Security Group Name
NSGNAME=$(az network nsg list --resource-group $RESOURCEGROUP --query "[].name" -o tsv | grep  NSG)

## Find Network Security Group Rule Names SSH
SSHROLENAME=$(az network nsg rule list --resource-group $RESOURCEGROUP --nsg-name $NSGNAME --query "[].name" -o tsv | grep ssh)

## Get my private ip
#MYPRIVATEIP=$(hostname -I |grep -Eo "[1-9]{3}\.[1-8]{3}.0.[0-9]{1,3}")

## Update Network Security Group Rule SSH
if [ "$(az network nsg rule list --resource-group $RESOURCEGROUP --nsg-name $NSGNAME --query "[0].sourceAddressPrefix" -o tsv)" != "$MYPUBLICIP" ];
then
    if az network nsg rule update \
        --resource-group "$RESOURCEGROUP" \
        --nsg-name "$NSGNAME" \
        --name "$SSHROLENAME" \
        --source-address-prefixes "$MYPUBLICIP" \
        --output none;
    then
        echo "Update Network Security Group Rule $SSHROLENAME successfully"
        echo "Update Network Security Group Rule $SSHROLENAME successfully" >>"$LOGFUNCTIONS"
        echo "----------------------------------------------------"
    else 
        echo "Error Update Network Security Group Rule $SSHROLENAME. Please check in your Azure Dashboard"
        echo "Error Update Network Security Group Rule $SSHROLENAME. Please check in your Azure Dashboard" >>"$LOGFUNCTIONS"
        echo "----------------------------------------------------"
    fi    
else
    echo "Update Network Security Group Rule $SSHROLENAME successfully"
    echo "Update Network Security Group Rule $SSHROLENAME successfully" >>"$LOGFUNCTIONS"
    echo "----------------------------------------------------"
fi

# Create http NSG
# https://www.jhanley.com/blog/azure-update-network-security-group-rule-with-my-ip-address/
# NSGHTTP="az900-http"

# ## Creating the Virtual Network security group rules
# if [ "$(az network nsg list --resource-group $RESOURCEGROUP --query "[].name" -o tsv | grep $NSGHTTP)" = "" ];
# then
#     if az network nsg create \
#         --resource-group "$RESOURCEGROUP" \
#         --name "$NSGHTTP" \
#         --output none;
#     then
#         echo "Create Network Security Group $NSGHTTP successfully"
#         echo "Create Network Security Group $NSGHTTP successfully" >>"$LOGFUNCTIONS"
#         echo "----------------------------------------------------"
#     else 
#         echo "Error Create Network Security Group $NSGHTTP. Please check in your Azure Dashboard"
#         echo "Error Create Network Security Group $NSGHTTP. Please check in your Azure Dashboard" >>"$LOGFUNCTIONS"
#         echo "----------------------------------------------------"
#     fi
# else
#     echo "Create Network Security Group $NSGHTTP successfully"
#     echo "Create Network Security Group $NSGHTTP successfully" >>"$LOGFUNCTIONS"
#     echo "----------------------------------------------------"
# fi    

# Create NSG rule to allow incoming port 80/HTTP and 443/HTTPS
HTTPROLENAME="allow-http-https"
if [ "$(az network nsg rule list --resource-group $RESOURCEGROUP --nsg-name $NSGNAME --query "[].name" -o tsv | grep "$HTTPROLENAME")" = "" ];
then
    if az network nsg rule create \
    --resource-group "$RESOURCEGROUP" \
    --nsg-name "$NSGNAME" \
    --name "$HTTPROLENAME" \
    --priority 100 \
    --direction Inbound \
    --source-address-prefixes "$MYPUBLICIP" \
    --source-port-ranges '*' \
    --destination-address-prefixes '10.0.0.0/24' \
    --destination-port-ranges 80 443 \
    --protocol Tcp \
    --output none;
    then
        echo "Create Network Security Group Role  $HTTPROLENAME successfully"
        echo "Create Network Security Group Role  $HTTPROLENAME successfully" >>"$LOGFUNCTIONS"
        echo "----------------------------------------------------"
    else 
        echo "Error Create Network Security Group Role $HTTPROLENAME. Please check in your Azure Dashboard"
        echo "Create Network Security Group Role $HTTPROLENAME. Please check in your Azure Dashboard" >>"$LOGFUNCTIONS"
        echo "----------------------------------------------------"
    fi
 else
    echo "Create Network Security Group Role  $HTTPROLENAME successfully"
    echo "Create Network Security Group Role  $HTTPROLENAME successfully" >>"$LOGFUNCTIONS"
    echo "----------------------------------------------------"
fi    



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


# Get public ip for azure vm
#az vm show -d -g $RESOURCEGROUP -n $VMNAME --query publicIps -o tsv

# Logout in Azure Cloud
 LogoutAzurePortal
