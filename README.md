[Vast installation](#initial-setup)

[Test machine](#testing)

[Logs](#logs)

# Initial setup

### Install Ubuntu 20.04

* Partitions during installation:
    - 8 gb swap on boot drive
    - full-size ext4 on SSD, boot drive
    - (optional) raid from NVME drives, partions unmounted, unformated
* Configure ip addr (disable unused adapter)
* Add openssh server
* Reboot

```
# for KVM download and install 
https://download.huihoo.com/java/javase/7/jdk-7u21-linux-x64.tar.gz

To setup raid:
- set both drives as boot
- create partition but leave unformated
- create raid
- then format raid to your needs: 
- 192GB for / ext4
- 8GB for /swap
- rest for /var/lib/docker xfs

```


```
# Install necessary packages
sudo apt-get install curl wget mc python3 -y

# Configure SSH
# Generate keys on your client machine
ssh-keygen -C user@domain
# copy public key to host
/.ssh/authorized_keys

# Disable password login and change port
sudo sed -i -E 's/^#?Port 22/Port 22222/' /etc/ssh/sshd_config # optional
sudo sed -i -E 's/^#?PasswordAuthentication yes/PasswordAuthentication no/' /etc/ssh/sshd_config
sudo sed -i -E 's/^#?UsePAM yes/UsePAM no/' /etc/ssh/sshd_config
sudo rm -rf /etc/ssh/sshd_config.d/*
sudo systemctl restart ssh

# optinal fail2ban
wget https://raw.githubusercontent.com/alkorolyov/vast-tools/main/fail2ban.sh; bash fail2ban.sh

# disable automaic updates
sudo apt purge --auto-remove unattended-upgrades -y
sudo systemctl disable apt-daily-upgrade.timer
sudo systemctl mask apt-daily-upgrade.service 
sudo systemctl disable apt-daily.timer
sudo systemctl mask apt-daily.service

# create /var/lib/docker
sudo mkdir -p /var/lib/docker

# [OPTION 1] mount on /dev/nvme0n1
echo -e "n\n\n\n\n\n\nw\n" | sudo cfdisk /dev/nvme0n1
sudo mkfs.xfs /dev/nvme0n1
uuid=$(sudo blkid -s UUID -o value /dev/nvme0n1)

# [OPTION 2] mount on raid /dev/md0
sudo mkfs.xfs /dev/md0 -f
uuid=$(sudo blkid -s UUID -o value /dev/md0)

# Add the disk to fstab with discard and nofail options
sudo bash -c "echo 'UUID=\"$uuid\" /var/lib/docker/ xfs rw,auto,pquota 0 0' >> /etc/fstab"

# Mount all filesystems
sudo mount -a

# Check that the /var/lib/docker/ is mounted correctly
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

```
sudo add-apt-repository ppa:graphics-drivers/ppa -y
sudo apt update
sudo apt install nvidia-driver-570-open
```

### Install fail2ban [optional]
```
curl -O https://raw.githubusercontent.com/alkorolyov/vast-tools/main/fail2ban.sh; bash fail2ban.sh
```

### Setup vast
(Optinal) Copy machine, BEFORE vast install
```
sudo su
mkdir /var/lib/vastai_kaalia
echo -n 'YOUR_MACHINE_ID' > /var/lib/vastai_kaalia/machine_id
```

Setup port range
```
sudo bash -c 'echo "40000-40399" > /var/lib/vastai_kaalia/host_port_range'
```

Copy command from vast site
```
https://cloud.vast.ai/host/setup/
```

In case nvml error
```
wget https://raw.githubusercontent.com/alkorolyov/vast-tools/main/nvml_fix.py; sudo python3 nvml_fix.py
```

Speedtest
```
cd /var/lib/vastai_kaalia/
sudo rm latest/speedtest-cli
sudo ./send_mach_info.py --speedtest
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

# Logs

### Usefull logs
```
cat /var/log/syslog | grep -iF "error"
```
```
dmesg -T
```
```
grep error /var/lib/vastai_kaalia/kaalia.*log | less
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
./vast search offers 'machine_id = xxx verified = any'
./vast create instance xxx --image pytorch/pytorch --disk 8 --direct --jupyter --jupyter-lab
```

### Monitor gpu
```
watch nvidia-smi --query-gpu=index,temperature.gpu,fan.speed,power.draw.instant,clocks.sm,clocks.mem --format=csv
```

### IPMICFG
```
curl -O https://raw.githubusercontent.com/alkorolyov/vast-tools/main/ipmicfg.sh; bash ipmicfg.sh
```

### Test pytorch on all gpus
```
sudo docker run --rm --gpus all -it pytorch/pytorch:latest bash -c "apt-get update && apt-get install -y sudo curl && curl -O https://raw.githubusercontent.com/alkorolyov/vast-tools/main/gpu_test_run.py && python gpu_test_run.py"
```
```
curl -O https://raw.githubusercontent.com/alkorolyov/vast-tools/main/gpu_test_run.py; python3 gpu_test_run.py
```


### Uninstall vast
```
curl -O https://raw.githubusercontent.com/alkorolyov/vast-tools/main/uninstall.sh; bash uninstall.sh
```



