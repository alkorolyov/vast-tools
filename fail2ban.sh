sudo apt-get install fail2ban
sudo tee /etc/fail2ban/jail.local > /dev/null <<EOL
[DEFAULT]
maxretry = 3
findtime = 5m

[sshd]
bantime = 1h
enabled = true
EOL
sed -i 's/port     = ssh/port     = 22222/1' /etc/fail2ban/jail.local
sudo systemctl restart fail2ban
