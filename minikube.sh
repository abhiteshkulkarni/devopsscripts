#!/bin/bash

# Update system
sudo apt update -y
sudo apt upgrade -y

# Install dependencies
sudo apt install -y curl wget apt-transport-https

# Install Docker
sudo apt install -y docker.io
sudo systemctl enable --now docker

# Add current user to docker group (important)
sudo usermod -aG docker $USER

# Download latest Minikube
curl -LO https://storage.googleapis.com/minikube/releases/latest/minikube-linux-amd64

# Install Minikube binary
sudo install minikube-linux-amd64 /usr/local/bin/minikube

# Print Minikube version
minikube version

# Install kubectl
sudo snap install kubectl --classic
kubectl version --client

#After exit root user run as a normal user 
#minikube start --nodes 4
