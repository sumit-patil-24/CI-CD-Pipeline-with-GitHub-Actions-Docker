#!/bin/bash
# user_data.sh
# This script is executed on the EC2 instance at launch to set up the CD environment.

# ---------------------------------
# Docker Installation
# ---------------------------------
sudo apt-get update
sudo apt-get install -y docker.io
sudo systemctl start docker
sudo systemctl enable docker
sudo usermod -aG docker ubuntu

# ---------------------------------
# Minikube, Kubectl, and Helm Installation
# ---------------------------------
sudo apt-get install -y conntrack
curl -LO https://storage.googleapis.com/minikube/releases/latest/minikube-linux-amd64
sudo install minikube-linux-amd64 /usr/local/bin/minikube

curl -LO "https://dl.k8s.io/release/$(curl -L -s https://dl.k8s.io/release/stable.txt)/bin/linux/amd64/kubectl"
sudo install -o root -g root -m 0755 kubectl /usr/local/bin/kubectl

curl -fsSL https://raw.githubusercontent.com/helm/helm/main/scripts/get-helm-3 | bash

# ---------------------------------
# Minikube Cluster Setup
# ---------------------------------
minikube start --driver=docker
# Add the host's DNS to the minikube cluster to allow outbound requests.
minikube addons enable ingress

# ---------------------------------
# ArgoCD, Grafana, and Prometheus Installation (via Helm)
# ---------------------------------

# Add the ArgoCD Helm repository
helm repo add argo https://argoproj.io/argo-helm

# Add the Prometheus community Helm repository
helm repo add prometheus-community https://prometheus-community.github.io/helm-charts

# Update Helm repositories
helm repo update

# Install Prometheus and Grafana for monitoring
helm install prometheus prometheus-community/kube-prometheus-stack --namespace monitoring --create-namespace

# Install ArgoCD for GitOps deployment
helm install argocd argo/argo-cd --namespace argocd --create-namespace

# Wait for ArgoCD to be ready
sleep 60
ARGO_PASSWORD=$(kubectl -n argocd get secret argocd-initial-admin-secret -o jsonpath="{.data.password}" | base64 -d)
echo "ArgoCD initial admin password: $ARGO_PASSWORD"

# Expose ArgoCD with Minikube tunnel
minikube tunnel &

# ---------------------------------
# Create and Apply ArgoCD Manifest
# ---------------------------------
# We use a heredoc to create the file locally without a clone or URL.
cat <<EOF > argocd-application.yaml
apiVersion: argoproj.io/v1alpha1
kind: Application
metadata:
  name: my-application
  namespace: argocd
spec:
  project: default
  source:
    repoURL: https://github.com/sumit-patil-24/Zero_Touch_Automation_Project.git
    targetRevision: HEAD
    path: helm
  destination:
    server: https://kubernetes.default.svc
    namespace: default
  syncPolicy:
    automated:
      prune: true
      selfHeal: true
EOF

# Apply the ArgoCD application manifest
kubectl apply -f argocd-application.yaml
