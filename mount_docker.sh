#!/bin/bash
############### INTRODUCTION AND WARNING ###########################
echo "WARNING: This script will modify your disk(s) and may result in data loss."
echo "Please ensure that you have backups of any important data before proceeding."
echo
echo "You have two options:"
echo "1. Mount /var/lib/docker on a single disk (/dev/nvme0n1)."
echo "2. Create a RAID 0 array using /dev/nvme0n1 and /dev/nvme1n1 and mount /var/lib/docker on it."
echo
read -p "Select an option (1/2) or cancel (n): " OPTION

if [ "$OPTION" = "1" ]; then
    echo "You have selected to mount /var/lib/docker on /dev/nvme0n1."
    echo "WARNING: IF YOUR OS IS ON /dev/nvme0n1 IT WILL BE WIPED."
    read -p "Continue (y/n)? " CONT
    if [ "$CONT" = "y" ]; then
        # Create the XFS partition and write it to the disk /dev/nvme0n1
        echo -e "n\n\n\n\n\n\nw\n" | sudo cfdisk /dev/nvme0n1
        sudo mkfs.xfs /dev/nvme0n1p1
        sudo mkdir -p /var/lib/docker

        # Add the partition to fstab with discard and nofail options
        sudo bash -c 'uuid=$(sudo xfs_admin -lu /dev/nvme0n1p1 | sed -n "2p" | awk \'{print $NF}\'); echo "UUID=$uuid /var/lib/docker xfs rw,auto,pquota,discard,nofail 0 0" >> /etc/fstab'

        # Mount the filesystem
        sudo mount -a

        # Check that /dev/nvme0n1p1 is mounted to /var/lib/docker/
        df -h
    else
        echo "Operation canceled."
    fi

elif [ "$OPTION" = "2" ]; then
    echo "You have selected to create a RAID 0 array using /dev/nvme0n1 and /dev/nvme1n1."
    echo "WARNING: ALL DATA ON /dev/nvme0n1 AND /dev/nvme1n1 WILL BE WIPED."
    read -p "Continue (y/n)? " CONT
    if [ "$CONT" = "y" ]; then
        # Create partitions on both disks /dev/nvme0n1 and /dev/nvme1n1
        echo -e "n\n\n\n\n\n\nw\n" | sudo cfdisk /dev/nvme0n1
        echo -e "n\n\n\n\n\n\nw\n" | sudo cfdisk /dev/nvme1n1

        # Create RAID 0 array from the partitions
        sudo mdadm --create --verbose /dev/md0 --level=0 --raid-devices=2 /dev/nvme0n1p1 /dev/nvme1n1p1

        # Create XFS filesystem on the RAID 0 array
        sudo mkfs.xfs /dev/md0

        # Create directory for Docker
        sudo mkdir -p /var/lib/docker

        # Add the RAID array to mdadm configuration file to ensure it's recognized on boot
        sudo bash -c 'mdadm --detail --scan >> /etc/mdadm/mdadm.conf'

        # Update initramfs to include the new mdadm configuration
        sudo update-initramfs -u

        # Add the RAID array to fstab with appropriate options
        sudo bash -c 'uuid=$(sudo blkid -s UUID -o value /dev/md0); echo "UUID=$uuid /var/lib/docker xfs rw,auto,pquota,discard,nofail 0 0" >> /etc/fstab'

        # Mount all filesystems
        sudo mount -a

        # Check that the RAID array is mounted to /var/lib/docker/
        df -h
    else
        echo "Operation canceled."
    fi

else
    echo "No valid option selected. Operation canceled."
fi
