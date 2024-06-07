#!/bin/bash
export DEBIAN_FRONTEND=noninteractive
sudo apt-get update -y
sudo apt-get upgrade -y
wget -O - https://packages.adoptium.net/artifactory/api/gpg/key/public | sudo tee /etc/apt/keyrings/adoptium.asc
echo "deb [signed-by=/etc/apt/keyrings/adoptium.asc] https://packages.adoptium.net/artifactory/deb $(awk -F= '/^VERSION_CODENAME/{print$2}' /etc/os-release) main" | sudo tee /etc/apt/sources.list.d/adoptium.list

# Installing Java 11
echo "================================="
echo "Installing Java 17"
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

echo "================================="
echo "Applying Jenkins Configuration as Code (Casc) for security settings"
echo "================================="

sudo mkdir -p /var/lib/jenkins/casc_configs
sudo cp /tmp/jenkins.yaml /var/lib/jenkins/casc_configs/
sudo cp /tmp/create_user_and_helloworld_job.groovy /var/lib/jenkins/casc_configs/
sudo chown -R jenkins:jenkins /var/lib/jenkins/casc_configs

echo "setting up CASC_JENKINS_CONFIG"

echo 'CASC_JENKINS_CONFIG="/var/lib/jenkins/casc_configs/jenkins.yaml"' | sudo tee -a /etc/environment
echo 'JAVA_OPTS="-Djenkins.install.runSetupWizard=false"' | sudo tee -a /etc/environment
sudo sed -i 's/\(JAVA_OPTS=-Djava\.awt\.headless=true\)/\1 -Djenkins.install.runSetupWizard=false/' /lib/systemd/system/jenkins.service
sudo sed -i '/Environment="JAVA_OPTS=-Djava.awt.headless=true -Djenkins.install.runSetupWizard=false"/a Environment="CASC_JENKINS_CONFIG=/var/lib/jenkins/casc_configs/jenkins.yaml"' /lib/systemd/system/jenkins.service


# Install Jenkins Plugins
echo "================================="
echo "Installing Jenkins Plugins"
echo "================================="
wget https://github.com/jenkinsci/plugin-installation-manager-tool/releases/download/2.12.13/jenkins-plugin-manager-2.12.13.jar
sudo chmod +x jenkins-plugin-manager-2.12.13.jar
sudo java -jar jenkins-plugin-manager-2.12.13.jar --war /usr/share/java/jenkins.war --plugin-file /tmp/plugins.txt --plugin-download-directory /var/lib/jenkins/plugins/
sudo chmod +x /var/lib/jenkins/plugins/*.jpi


# Reload systemd daemon and start Jenkins
sudo systemctl daemon-reload
sudo systemctl start jenkins
sudo systemctl status jenkins
