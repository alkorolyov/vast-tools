sudo apt-get install fail2ban -y
sudo tee /etc/fail2ban/jail.local > /dev/null <<EOL
[DEFAULT]
maxretry = 3
bantime.increment = true

[sshd]
bantime = 1h
enabled = true

EOL
sudo sed -i '0,/port\s*=\s*ssh/s//port    = 22222/' /etc/fail2ban/jail.conf  # replace ssh with custom port
sudo fail2ban-client reload
