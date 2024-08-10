#!/bin/bash
############### mount docker on /dev/nvme0n1 ###########################
# Create and mount docker folder on nvme
read -p "MOUNT /var/lib/docker on /dev/nvme0n1\nWARNING: IF YOUR OS IS ON /dev/nvme0n1 IT WILL BE WIPED\nContinue (y/n)? " CONT
if [ "$CONT" = "y" ]; then
  # This is one command that will create the xfs partition and write it to the disk /dev/nvme0n1.
  echo -e "n\n\n\n\n\n\nw\n" | sudo cfdisk /dev/nvme0n1 && sudo mkfs.xfs /dev/nvme0n1p1
  sudo mkdir -p /var/lib/docker

  # Added discard so that the SSD is trimmed by Ubuntu and nofail if there is some problem with the drive the system will still boot.
  sudo bash -c 'uuid=$(sudo xfs_admin -lu /dev/nvme0n1p1 | sed -n "2p" | awk \'{print $NF}\'); echo "UUID=$uuid /var/lib/docker/ xfs rw,auto,pquota,discard,nofail 0 0" >> /etc/fstab'

  sudo mount -a

  # Check that /dev/nvme0n1p1 is mounted to /var/lib/docker/
  df -h
fi


############### mount docker on raid0 /dev/nvme0n1 and /dev/nvme1n1 ###########################
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
