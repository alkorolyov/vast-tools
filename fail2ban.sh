sudo apt-get install fail2ban -y
sudo tee /etc/fail2ban/jail.local > /dev/null <<EOL
[DEFAULT]
maxretry = 3
findtime = 10m
bantime.increment = true

[sshd]
bantime = 1h
enabled = true

EOL
sudo sed -i '0,/port\s*=\s*ssh/s//port    = 22222/' /etc/fail2ban/jail.conf
sudo systemctl restart fail2ban
