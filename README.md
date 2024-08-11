[Vast installation](#initial-setup)

[Test machine](#testing)

# Initial setup

### Install Ubuntu 20.04

* Partitions during installation:
    - 8 gb swap on boot drive
    - full-size ext4 on SSD, boot drive
    - (optional) raid from NVME drives
* Configure ip addr (disable unused adapter)
* Add openssh server
* Reboot


```
# Install necessary packages
sudo apt-get install curl wget mc python3 -y

# Configure SSH
sudo sed -i 's/#Port 22/Port 22222/' /etc/ssh/sshd_config # optional
sudo sed -i 's/#PasswordAuthentication yes/PasswordAuthentication no/' /etc/ssh/sshd_config
sudo systemctl restart ssh

# disable automaic updates
sudo apt purge --auto-remove unattended-upgrades -y
sudo systemctl disable apt-daily-upgrade.timer
sudo systemctl mask apt-daily-upgrade.service 
sudo systemctl disable apt-daily.timer
sudo systemctl mask apt-daily.service

# [OPTION 1] create and mount /var/lib/docker on /dev/nvme0n1
sudo mkfs.xfs /dev/nvme0n1 -f
sudo mkdir -p /var/lib/docker

# Add the disk to fstab with discard and nofail options
sudo bash -c 'uuid=$(sudo blkid -s UUID -o value /dev/nvme0n1); echo "UUID=$uuid /var/lib/docker xfs rw,auto,pquota,discard,nofail 0 0" >> /etc/fstab'

# [OPTION 2] create and mount /var/lib/docker on raid /dev/md0
# Create XFS filesystem on the RAID array
sudo mkfs.xfs /dev/md0 -f
sudo mkdir -p /var/lib/docker

# Add the RAID array to fstab with appropriate options
sudo bash -c 'uuid=$(sudo blkid -s UUID -o value /dev/md0); echo "UUID=$uuid /var/lib/docker xfs rw,auto,pquota,discard,nofail 0 0" >> /etc/fstab'

# Mount all filesystems
sudo mount -a

# Check that the RAID array is mounted to /var/lib/docker/
df -h
```
  
### Install nvidia drivers
```
# check the latest driver version 
sudo apt search nvidia-driver | grep nvidia-driver | sort -r
```
```
sudo apt-get install nvidia-headless-550-server nvidia-utils-550-server -y
sudo reboot now
```

### Setup vast
Copy command from vast site
```
https://cloud.vast.ai/host/setup/
```

### Install miniforge and create conda environment
```
CONDA_ENV="vast"

curl -L -O "https://github.com/conda-forge/miniforge/releases/latest/download/Miniforge3-$(uname)-$(uname -m).sh"
bash Miniforge3-$(uname)-$(uname -m).sh -b
source "${HOME}/miniforge3/etc/profile.d/conda.sh"
source "${HOME}/miniforge3/etc/profile.d/mamba.sh"
conda activate

mamba env create -n $CONDA_ENV -f env.yml
conda run -n $CONDA_ENV python -m ipykernel install --user --name $CONDA_ENV
conda activate $CONDA_ENV
```

### Configure SSH
Create public key and copy to remote server
```
ssh-keygen -C user@domain
```

Disable password login
```
sudo sed -i 's/#Port 22/Port 22222/' /etc/ssh/sshd_config # optional
sudo sed -i 's/#PasswordAuthentication yes/PasswordAuthentication no/' /etc/ssh/sshd_config
sudo systemctl restart ssh
```

# Testing

### GPU burn
```
sudo docker run --gpus all --rm oguzpastirmaci/gpu-burn 60
```

### CPU burn
```
sudo apt-get install stress -y -qq; stress --cpu 64 -t 60
```

### Test open ports
```
curl -O https://raw.githubusercontent.com/alkorolyov/vast-tools/main/test_ports.py; python3 test_ports.py
```

### Get PCI slots info
```
curl -O https://raw.githubusercontent.com/alkorolyov/vast-tools/main/pci_info.sh; bash pci_info.sh
```

### Create instance
```
./vast show machines | grep machine_id
./vast search offers 'machine_id = xxx'
./vast create instance xxx --image pytorch/pytorch --disk 8 --jupyter --jupyter-lab
```

### Monitor gpu
```
watch nvidia-smi --query-gpu=index,temperature.gpu,fan.speed,power.draw.instant,clocks.sm,clocks.mem --format=csv
```

### Test pytorch on all gpus
```
curl -O https://raw.githubusercontent.com/alkorolyov/vast-tools/main/gpu_test_run.py; python3 gpu_test_run.py
```


### Uninstall vast
```
curl -O https://raw.githubusercontent.com/alkorolyov/vast-tools/main/uninstall.sh; bash uninstall.sh
```



