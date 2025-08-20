#!/bin/bash
sudo -i -u ubuntu bash << 'EOF'


# ---------------------------------
# Docker Installation and Setup
# ---------------------------------
sudo apt update -y
sudo apt install -y docker.io
sudo systemctl start docker
sudo systemctl enable docker
sudo usermod -aG docker $USER
# Apply group changes without new shell
newgrp docker  # Better alternative to chmod 666 on docker.sock

# ---------------------------------
# Minikube, Kubectl, and Helm Installation
# ---------------------------------
# Install dependencies
curl -LO "https://dl.k8s.io/release/$(curl -L -s https://dl.k8s.io/release/stable.txt)/bin/linux/amd64/kubectl"
sudo install -o root -g root -m 0755 kubectl /usr/local/bin/kubectl


# Install minikube
MINIKUBE_VERSION="v1.36.0"  # Pinned version
curl -LO https://github.com/kubernetes/minikube/releases/download/${MINIKUBE_VERSION}/minikube-linux-amd64
sudo install minikube-linux-amd64 /usr/local/bin/minikube && rm minikube-linux-amd64

# Install helm
sudo snap install helm --classic

# ---------------------------------
# Minikube Cluster Setup
# ---------------------------------
# Start Minikube with none driver
minikube start

minikube addons enable ingress

# Verify cluster is running
kubectl cluster-info

# ---------------------------------
# Helm Repositories
# ---------------------------------
helm repo add argo https://argoproj.github.io/argo-helm


helm repo update



# ---------------------------------
# Install ArgoCD
# ---------------------------------
kubectl create namespace argocd
helm install argocd argo/argo-cd \
  --namespace argocd \
  --set server.service.type=NodePort  # Avoid needing LoadBalancer

# Wait for ArgoCD to be ready
echo "Waiting for ArgoCD to be ready..."
kubectl wait --for=condition=available deployment/argocd-server -n argocd --timeout=300s

# Get ArgoCD password
ARGO_PASSWORD=$(kubectl -n argocd get secret argocd-initial-admin-secret -o jsonpath="{.data.password}" | base64 -d)
echo "ArgoCD initial admin password: $ARGO_PASSWORD"

# Port-forward ArgoCD (alternative to tunnel)
echo "To access ArgoCD UI, run: kubectl port-forward svc/argocd-server -n argocd 8080:443 &"

# ---------------------------------
# Create and Apply ArgoCD Application
# ---------------------------------

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
    path: helm-chart
  destination:
    server: https://kubernetes.default.svc
    namespace: default
  syncPolicy:
    automated:
      prune: true
      selfHeal: true
EOF


kubectl apply -f argocd-application.yaml

echo "Setup completed successfully!"

sleep 200

kubectl port-forward service/argocd-server -n argocd  8080:443 --address=0.0.0.0 &
kubectl port-forward service/my-application-helm-chart 8000:80 --address=0.0.0.0 &
kubectl port-forward svc/prometheus-2-grafana -n monitoring 3000:80 --address=0.0.0.0 &
kubectl port-forward svc/prometheus-2-kube-promethe-prometheus -n monitoring 9090:9090 --address=0.0.0.0 &