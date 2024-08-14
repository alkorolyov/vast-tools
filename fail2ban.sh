sudo apt-get install fail2ban
sudo tee /etc/fail2ban/jail.local > /dev/null <<EOL
[DEFAULT]
maxretry = 3
findtime = 5m

[ssh]
bantime = 1h
enabled = true
port = 22222  # Your custom SSH port
EOL
sudo systemctl restart fail2ban
