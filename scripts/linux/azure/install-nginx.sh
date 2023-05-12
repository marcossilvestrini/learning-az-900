<<'SCRIPT'
    .Synopsis
        Script for up lab
    .DESCRIPTION
        Script for install Nginx in azure virtual machine remote
    .PREREQUISITES    
        Login in azure cloud
    .EXAMPLE
        ./install-nginx.sh
SCRIPT

# Clear screen
clear

# Set language/locale and encoding
export LANG=C

# Variables
VMNAME="lab-az900"
date=$(date '+%Y-%m-%d %H:%M:%S')

# Format and mount the disk 
echo "Install Nginx in VM $VMNAME."
echo "Date: $date"
echo "---------------------------------------------------"
sudo apt install -y nginx >/dev/null
