#!/bin/bash

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
