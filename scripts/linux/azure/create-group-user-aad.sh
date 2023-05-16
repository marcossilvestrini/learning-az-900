<<'SCRIPT'
    .Synopsis
        Script for up lab
    .DESCRIPTION
        Script for create group and user in Azure Active Directory for learning AZ-900
    .PREREQUISITES    
        ./azure-functions.sh
    .EXAMPLE
        ./create-group-user-aad.sh
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
AADGROUPNAME="labs-az900"
AADGROUPDESCRIPTION="Group for learning Az-900"
AADUSERNAME="terraform"
AADPASSWORD="My@Password@User@Azure@123456"
AADPRIMARYDOMAIN=$(az rest --method get --url 'https://graph.microsoft.com/v1.0/domains?$select=id' -o yaml | grep id: | cut -d ":" -f 2 |awk '{$1=$1};1')

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

# Create Azure Active Directory Group
if [ "$(az ad group list -o tsv)" = "" ];
 then
    if az ad group create \
    --display-name "$AADGROUPNAME"\
    --mail-nickname "$AADGROUPNAME" \
    --description "$AADGROUPDESCRIPTION" \
    --force true \
    --output none;        
    then
        echo "Group $AADGROUPNAME in Azure Active Directory has create successfully!!"
        echo "Group $AADGROUPNAME in Azure Active Directory has create successfully!!" >>"$LOGFUNCTIONS"
        echo "----------------------------------------------------"
    else 
        echo  "Error in create Group $AADGROUPNAME in Azure Active Directory. Please check in your Azure Dashboard"
        echo  "Error in create Group $AADGROUPNAME in Azure Active Directory. Please check in your Azure Dashboard" >>"$LOGFUNCTIONS"
        echo "----------------------------------------------------"
    fi
else
        echo "Group $AADGROUPNAME in Azure Active Directory has create successfully!!"
        echo "Group $AADGROUPNAME in Azure Active Directory has create successfully!!" >>"$LOGFUNCTIONS"
        echo "----------------------------------------------------"
fi

# Create Azure Active Directory User
if [ "$(az ad user list --query "[].displayName" -o tsv | grep -o $AADUSERNAME)" = "" ];
 then
    if az ad user create \
    --display-name "$AADUSERNAME" \
    --password "$AADPASSWORD" \
    --user-principal-name "$AADUSERNAME@$AADPRIMARYDOMAIN" \
    --force-change-password-next-sign-in false\
    --mail-nickname "$AADUSERNAME" \
    --output none;
    then
        echo "User $AADUSERNAME in Azure Active Directory has create successfully!!"
        echo "User $AADUSERNAME in Azure Active Directory has create successfully!!" >>"$LOGFUNCTIONS"
        echo "----------------------------------------------------"
    else 
        echo  "Error in create User $AADUSERNAME in Azure Active Directory. Please check in your Azure Dashboard"
        echo  "Error in create User $AADUSERNAME in Azure Active Directory. Please check in your Azure Dashboard" >>"$LOGFUNCTIONS"
        echo "----------------------------------------------------"
    fi
else
        echo "User $AADUSERNAME in Azure Active Directory has create successfully!!"
        echo "User $AADUSERNAME in Azure Active Directory has create successfully!!" >>"$LOGFUNCTIONS"
        echo "----------------------------------------------------"
fi

# Add user to Azure Active Directory Group
MEMBERID=$(az ad user list --display-name $AADUSERNAME --query "[].id" -o tsv)
# Create Azure Active Directory Group
if [ "$(az ad group member list --group $AADGROUPNAME -o tsv | grep "$AADUSERNAME")" = "" ];
 then    
    if az ad group member add \
        --group "$AADGROUPNAME" \
        --member-id "$MEMBERID" \
    --output none;        
    then
        echo "User $AADUSERNAME in Group $AADGROUPNAME in Azure Active Directory has add successfully!!"
        echo "User $AADUSERNAME in Group $AADGROUPNAME in Azure Active Directory has add successfully!!" >>"$LOGFUNCTIONS"
        echo "----------------------------------------------------"
    else 
        echo  "Error in add User $AADUSERNAME in Group $AADGROUPNAME in Azure Active Directory. Please check in your Azure Dashboard"
        echo  "Error in add User $AADUSERNAME in Group $AADGROUPNAME in Azure Active Directory. Please check in your Azure Dashboard" >>"$LOGFUNCTIONS"
        echo "----------------------------------------------------"
    fi
else
        echo "User $AADUSERNAME in Group $AADGROUPNAME in Azure Active Directory has add successfully!!"
        echo "User $AADUSERNAME in Group $AADGROUPNAME in Azure Active Directory has add successfully!!" >>"$LOGFUNCTIONS"
        echo "----------------------------------------------------"
fi

# Logout in Azure Cloud
 LogoutAzurePortal
