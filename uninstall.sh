wget https://s3.amazonaws.com/vast.ai/uninstall.py
sudo python3 uninstall.py
sudo userdel vastai_kaalia
sudo rm /etc/systemd/system/vastai_bouncer.service
rm uninstall.py
