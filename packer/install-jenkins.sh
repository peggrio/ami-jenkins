#!/bin/bash
export DEBIAN_FRONTEND=noninteractive
sudo apt-get update -y
sudo apt-get upgrade -y
wget -O - https://packages.adoptium.net/artifactory/api/gpg/key/public |sudo tee /etc/apt/keyrings/adoptium.asc
echo "deb [signed-by=/etc/apt/keyrings/adoptium.asc] https://packages.adoptium.net/artifactory/deb $(awk -F= '/^VERSION_CODENAME/{print$2}' /etc/os-release) main" |sudo tee /etc/apt/sources.list.d/adoptium.list

# Installing Java 11
echo "================================="
echo "Installing Java 11"
echo "================================="
sudo apt-get update -y
sudo apt-get install -y openjdk-17-jre
/usr/bin/java --version

# Add Jenkins Repository
echo "================================="
echo "Adding Jenkins Repository, install Jenkins"
echo "================================="
curl -fsSL https://pkg.jenkins.io/debian-stable/jenkins.io-2023.key | sudo tee /usr/share/keyrings/jenkins-keyring.asc > /dev/null

echo deb [signed-by=/usr/share/keyrings/jenkins-keyring.asc] https://pkg.jenkins.io/debian-stable binary/ | sudo tee /etc/apt/sources.list.d/jenkins.list > /dev/null
sudo apt-get update -y
sudo apt-get install jenkins -y


# Install Jenkins Plugins
echo "================================="
echo "Installing Jenkins Plugins"
echo "================================="
wget https://github.com/jenkinsci/plugin-installation-manager-tool/releases/download/2.12.13/jenkins-plugin-manager-2.12.13.jar
sudo chmod +x jenkins-plugin-manager-2.12.13.jar
sudo java -jar ~/jenkins-plugin-manager-2.12.13.jar --war /usr/share/java/jenkins.war --plugin-file /tmp/plugins.txt --plugin-download-directory /var/lib/jenkins/plugins/
sudo chmod +x /var/lib/jenkins/plugins/*.jpi

# Skip Jenkins setup wizard and start Jenkins
echo "================================="
echo "Skip the plugins installation, starting Jenkins Agent"
echo "================================="

# Set JAVA_OPTS to skip setup wizard
export JAVA_OPTS="-Djenkins.install.runSetupWizard=false -Djenkins.install.UpgradeWizard.state=2"

# Create systemd override directory if it doesn't exist
sudo mkdir -p /etc/systemd/system/jenkins.service.d

# Create systemd override file to set JAVA_OPTS
sudo tee /etc/systemd/system/jenkins.service.d/override.conf > /dev/null <<EOL
[Service]
Environment="JAVA_OPTS=-Djenkins.install.runSetupWizard=false -Djenkins.install.UpgradeWizard.state=2"
EOL

# Reload systemd daemon and start Jenkins
sudo systemctl daemon-reload

sudo systemctl start jenkins
sudo systemctl status jenkins

# Get Jenkins initial password
echo "================================="
echo "Getting Jenkins initial password"
echo "================================="
sudo cat /var/lib/jenkins/secrets/initialAdminPassword