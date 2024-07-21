#!/bin/bash

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

# DOCKER INSTALL
# Add Docker's official GPG key:
sudo apt-get update -qq
sudo apt-get install ca-certificates curl -qq
sudo install -m 0755 -d /etc/apt/keyrings
sudo curl -fsSL https://download.docker.com/linux/ubuntu/gpg -o /etc/apt/keyrings/docker.asc
sudo chmod a+r /etc/apt/keyrings/docker.asc

# Add the repository to Apt sources:
echo \
  "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.asc] https://download.docker.com/linux/ubuntu \
  $(. /etc/os-release && echo "$VERSION_CODENAME") stable" | \
  sudo tee /etc/apt/sources.list.d/docker.list > /dev/null
sudo apt-get update -qq

# install docker
sudo apt-get install docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin nvidia-container-runtime
