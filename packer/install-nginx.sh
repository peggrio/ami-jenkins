#!/bin/bash
export DEBIAN_FRONTEND=noninteractive
sudo apt-get update
sudo apt-get upgrade
sudo apt-get install nginx -y
sudo systemctl start nginx

# Configures the Nginx service to start automatically at boot time
echo "================================="
echo "Configures the Nginx service to start automatically at boot time"
echo "================================="
sudo systemctl enable nginx

# Installs Certbot, which helps in obtaining and installing SSL certificates
echo "================================="
echo "Installs Certbot"
echo "================================="
sudo apt-get install certbot python3-certbot-nginx -y


sudo systemctl status nginx