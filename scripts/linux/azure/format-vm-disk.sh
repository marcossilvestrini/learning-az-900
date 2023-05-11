<<'SCRIPT'
    .Synopsis
        Script for up lab
    .DESCRIPTION
        Script for partition and format disk in azure virtual machine remote
    .PREREQUISITES    
        Login in azure cloud
    .EXAMPLE
        ./format-vm-disk.sh
SCRIPT

# Clear screen
clear

# Set language/locale and encoding
export LANG=C

# Variables
VMNAME="lab-az900"
DISKNAME="labs-az900"
date=$(date '+%Y-%m-%d %H:%M:%S')

# Format and mount the disk 
echo "Format and Mount Disk $DISKNAME in VM $VMNAME."
echo "Date: $date"
echo "---------------------------------------------------"
echo "Install packages..."
sudo apt install -y parted util-linux xfsprogs >/dev/null
echo "---------------------------------------------------"
echo "Umount disk $DISKNAME"
sudo umount /$DISKNAME >/dev/null 2>&1 
echo "---------------------------------------------------"
echo "Create Partition Disk $DISKNAME"
sudo parted /dev/sdc --script rm 1 >/dev/null 2>&1
sudo parted /dev/sdc --script mklabel gpt mkpart xfspart xfs 0% 100%
sudo partprobe /dev/sdc1
echo "---------------------------------------------------"
echo "Create Filesystem for $DISKNAME"
sudo mkfs.xfs -f /dev/sdc1 >/dev/null
echo "---------------------------------------------------"
echo "Create Mount Point for $DISKNAME"
sudo mkdir /$DISKNAME >/dev/null 2>&1
echo "---------------------------------------------------"
echo "Mount Disk $DISKNAME"
sudo mount /dev/sdc1 /$DISKNAME
sudo chmod -R 777 /$DISKNAME
echo "---------------------------------------------------"
echo "Check Mount Point $DISKNAME"
sudo lsblk -o NAME,HCTL,SIZE,MOUNTPOINT | grep -i "sdc"
echo "---------------------------------------------------"
echo "Create file for test in $DISKNAME"
echo "This disk has created, attached and formatted by Marcos Silvestrini in course about AZ-900" > /$DISKNAME/test-lab-az900-attach-disk.txt
ls -lt /$DISKNAME/test-lab-az900-attach-disk.txt
cat /$DISKNAME/test-lab-az900-attach-disk.txt
echo "---------------------------------------------------"
