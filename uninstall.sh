wget https://s3.amazonaws.com/vast.ai/uninstall.py
sudo python3 uninstall.py
sudo userdel vastai_kaalia
sudo rm -rf /var/lib/vastai_kaalia
sudo rm /etc/systemd/system/vastai_bouncer.service
