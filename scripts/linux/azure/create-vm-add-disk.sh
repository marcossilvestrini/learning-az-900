<<'SCRIPT'
    .Synopsis
        Script for up lab
    .DESCRIPTION
    Script for up virtual machine and new disk for data learning AZ-900 in Azure Cloud
    .PREREQUISITES    
        ./azure-functions.sh
    .EXAMPLE
        ./create-vm-add-disk.sh
SCRIPT

# Clear screen
clear

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
LOCATION="eastus"
PRIORITY="Spot"
IMAGE="Debian:debian-11:11-backports-gen2:latest"
VMNAME="lab-az900"
AUTHENTICATIONTYPE="all"
SSHKEYNAME="id_rsa_$VMNAME"
ADMINUSERNAME="vagrant"
ADMINPASSWORD="Vagrant@123456"
DISKNAME="labs-az900"
OSTYPE="Linux"
DISKSIZE=10
DISKSKU="Premium_LRS"
DISKTIER="P4"
TAG="labs-az900"

# Login i Azure Cloud
LoginAzurePortal

# Create resource group
if [ $(az group exists --name "$RESOURCEGROUP") = false ];
 then
    if az group create \
        --resource-group $RESOURCEGROUP \
        --location $LOCATION \
        --output none;
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


# Create disk
if [ "$(az disk list --resource-group  $RESOURCEGROUP --query "[].name" -o tsv)" != "$DISKNAME" ];
then
    if az disk create --only-show-errors\
        --location "$LOCATION" \
        --resource-group "$RESOURCEGROUP" \
        --name "$DISKNAME" \
        --os-type "$OSTYPE" \
        --public-network-access Enabled \
        --size-gb "$DISKSIZE" \
        --sku "$DISKSKU" \
        --tier "$DISKTIER" \
        --tags "$TAG" \
        --output none;
     then
        echo "Disk $DISKNAME has create successfully!!"
        echo "Disk $DISKNAME has create successfully!!" >>"$LOGFUNCTIONS"
        echo "----------------------------------------------------"
    else
        echo "Error in create Disk $DISKNAME. Please check in your Azure Dashboard"
        echo "Error in create Disk $DISKNAME. Please check in your Azure Dashboard" >>"$LOGFUNCTIONS"
        echo "----------------------------------------------------"
    fi
else
        echo "Disk $DISKNAME has create successfully!!"
        echo "Disk $DISKNAME has create successfully!!" >>"$LOGFUNCTIONS"
        echo "----------------------------------------------------"
fi

# Waiting for create a disk
echo "Waiting for Disk $DISKNAME has create online"
echo "Waiting for Disk $DISKNAME has create online" >>"$LOGFUNCTIONS"
az disk wait \
    --created --name "$DISKNAME" \
    --resource-group "$RESOURCEGROUP" \
    --timeout 120

# Attach the disk diskState: Attached
if [ "$(az disk list --resource-group  $RESOURCEGROUP --query "[0].diskState" -o tsv)" != "Attached" ];
then
    DISKID=$(az disk show --resource-group "$RESOURCEGROUP" --name "$DISKNAME" --query 'id' -o tsv)
    if az vm disk attach \
    --resource-group "$RESOURCEGROUP" \
    --vm-name "$VMNAME" \
    --name "$DISKID" \
    --output none;
    then
        echo "Disk $DISKNAME has attached successfully!!"
        echo "Disk $DISKNAME has attached successfully!!" >>"$LOGFUNCTIONS"
        echo "----------------------------------------------------"
    else
        echo "Error in attached Disk $DISKNAME. Please check in your Azure Dashboard"
        echo "Error in attached Disk $DISKNAME. Please check in your Azure Dashboard" >>"$LOGFUNCTIONS"
        echo "----------------------------------------------------"
    fi
else
        echo "Disk $DISKNAME has attached successfully!!"
        echo "Disk $DISKNAME has attached successfully!!" >>"$LOGFUNCTIONS"
        echo "----------------------------------------------------"
fi

# Format and mount the disk 
echo "Format and Mount Disk $DISKNAME in VM $VMNAME."
echo "Format and Mount Disk $DISKNAME in VM $VMNAME." >>"$LOGFUNCTIONS"
VMPUBLICIP=$(az vm show -d --resource-group $RESOURCEGROUP --name $VMNAME --query publicIps -o tsv)
ssh -o StrictHostKeyChecking=no  < ./scripts/linux/azure/format-vm-disk.sh vagrant@$VMPUBLICIP "bash -s -- '<--time bye>' '<end>'"

# Logout in Azure Cloud
LogoutAzurePortal
