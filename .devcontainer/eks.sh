#!/bin/bash
set -e  # Exit immediately if a command exits with a non-zero status

# Check if AWS credentials are set
if [ -z "$AWS_ACCESS_KEY_ID" ] || [ -z "$AWS_SECRET_ACCESS_KEY" ]; then
    echo "AWS_ACCESS_KEY_ID and AWS_SECRET_ACCESS_KEY must be set."
    exit 1
fi

sudo apt-get update -y

# Install AWS CLI
sudo apt-get install -y awscli

# Install eksctl
curl --silent --location "https://github.com/weaveworks/eksctl/releases/download/v0.130.0/eksctl_Linux_amd64.tar.gz" | tar xz -C /tmp
sudo mv /tmp/eksctl /usr/local/bin

# Install kubectl
curl -o /tmp/kubectl https://s3.us-west-2.amazonaws.com/amazon-eks/1.21.2/2021-07-26/bin/linux/amd64/kubectl
chmod +x /tmp/kubectl
sudo mv /tmp/kubectl /usr/local/bin

# Configure AWS CLI with the provided credentials
#aws configure set aws_access_key_id "$value_of_access"
#aws configure set aws_secret_access_key "$value_of_secret"
aws configure set default.region us-east-1
aws configure set output json

# Verify installations
aws --version
eksctl version
kubectl version --client

echo "AWS CLI, eksctl, and kubectl have been installed and configured successfully."
