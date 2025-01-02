#!/bin/bash
# Update system
sudo dnf update -y

# Install Java 17
sudo dnf install java-17-amazon-corretto -y

# Install Jenkins
sudo wget -O /etc/yum.repos.d/jenkins.repo https://pkg.jenkins.io/redhat-stable/jenkins.repo
sudo rpm --import https://pkg.jenkins.io/redhat-stable/jenkins.io-2023.key
sudo dnf install jenkins -y

# Install Docker
sudo dnf install docker -y
sudo systemctl start docker
sudo systemctl enable docker
sudo usermod -aG docker ec2-user
sudo usermod -aG docker jenkins

# Install Git
sudo dnf install git -y

# Install AWS CLI
sudo dnf install awscli -y

# Install kubectl
curl -LO "https://dl.k8s.io/release/$(curl -L -s https://dl.k8s.io/release/stable.txt)/bin/linux/amd64/kubectl"
sudo install -o root -g root -m 0755 kubectl /usr/local/bin/kubectl

# Start Jenkins
sudo systemctl start jenkins
sudo systemctl enable jenkins

# Save initial admin password to file
sudo cat /var/lib/jenkins/secrets/initialAdminPassword > /home/ec2-user/jenkins-initial-password
sudo chown ec2-user:ec2-user /home/ec2-user/jenkins-initial-password#!/bin/bash
# Update system
sudo dnf update -y

# Install Java 17
sudo dnf install java-17-amazon-corretto -y

# Install Jenkins
sudo wget -O /etc/yum.repos.d/jenkins.repo https://pkg.jenkins.io/redhat-stable/jenkins.repo
sudo rpm --import https://pkg.jenkins.io/redhat-stable/jenkins.io-2023.key
sudo dnf install jenkins -y

# Install Docker
sudo dnf install docker -y
sudo systemctl start docker
sudo systemctl enable docker
sudo usermod -aG docker ec2-user
sudo usermod -aG docker jenkins

# Install Git
sudo dnf install git -y

# Install AWS CLI
sudo dnf install awscli -y

# Install kubectl
curl -LO "https://dl.k8s.io/release/$(curl -L -s https://dl.k8s.io/release/stable.txt)/bin/linux/amd64/kubectl"
sudo install -o root -g root -m 0755 kubectl /usr/local/bin/kubectl

# Start Jenkins
sudo systemctl start jenkins
sudo systemctl enable jenkins

# Wait for Jenkins to start up
sleep 30

# Get Jenkins initial admin password
JENKINS_ADMIN_PASSWORD=$(sudo cat /var/lib/jenkins/secrets/initialAdminPassword)
echo $JENKINS_ADMIN_PASSWORD > /home/ec2-user/jenkins-initial-password
sudo chown ec2-user:ec2-user /home/ec2-user/jenkins-initial-password

# Download Jenkins CLI
wget http://localhost:8080/jnlpJars/jenkins-cli.jar

# Install Jenkins plugins
JENKINS_PLUGINS=(
    "git"
    "workflow-aggregator"
    "docker-workflow"
    "kubernetes"
    "amazon-ecr"
    "aws-credentials"
    "pipeline-aws"
    "configuration-as-code"
    "job-dsl"
    "blueocean"
    "docker-pipeline"
    "kubernetes-cli"
    "credentials-binding"
    "pipeline-utility-steps"
    "timestamper"
    "workflow-basic-steps"
    "ws-cleanup"
)

for plugin in "${JENKINS_PLUGINS[@]}"; do
    java -jar jenkins-cli.jar -s http://localhost:8080/ -auth admin:$JENKINS_ADMIN_PASSWORD install-plugin $plugin
done

# Create Jenkins configuration directory
sudo mkdir -p /var/lib/jenkins/init.groovy.d/

# Create basic security script
cat << EOF | sudo tee /var/lib/jenkins/init.groovy.d/basic-security.groovy
#!groovy

import jenkins.model.*
import hudson.security.*
import jenkins.security.s2m.AdminWhitelistRule

def instance = Jenkins.getInstance()

def hudsonRealm = new HudsonPrivateSecurityRealm(false)
hudsonRealm.createAccount("admin", "$JENKINS_ADMIN_PASSWORD")
instance.setSecurityRealm(hudsonRealm)

def strategy = new FullControlOnceLoggedInAuthorizationStrategy()
instance.setAuthorizationStrategy(strategy)
instance.save()

Jenkins.instance.getInjector().getInstance(AdminWhitelistRule.class).setMasterKillSwitch(false)
EOF

# Restart Jenkins to apply changes
sudo systemctl restart jenkins

# Wait for Jenkins to come back up
sleep 30

echo "Jenkins installation and configuration completed!"
echo "Initial admin password: $JENKINS_ADMIN_PASSWORD"