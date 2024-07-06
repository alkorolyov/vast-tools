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

### Uninstall vast
```
wget https://s3.amazonaws.com/vast.ai/uninstall.py
sudo python uninstall.py
sudo userdel vastai_kaalia
sudo rm -rf /var/lib/vastai_kaalia
sudo rm /etc/systemd/system/vastai_bouncer.service
```



