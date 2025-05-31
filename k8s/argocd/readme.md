# ArgoCD Setup Instructions

This directory contains the necessary files to set up ArgoCD and deploy applications using GitOps.

## Quick Setup

Run the consolidated setup script:

```bash
./k8s/argocd/setup-argocd.sh
```

This script will:
1. Create the ArgoCD namespace
2. Install ArgoCD using Helm
3. Generate an SSH key for GitHub access
4. Create the repository secret
5. Apply the project and application configurations
6. Display the ArgoCD admin password

## Manual Setup Steps

If you prefer to run the steps manually:

1. Create the ArgoCD namespace:
   ```bash
   kubectl create namespace argocd
   ```

2. Install ArgoCD using Helm:
   ```bash
   helm repo add argo https://argoproj.github.io/argo-helm
   helm repo update
   helm install argocd argo/argo-cd \
     --namespace argocd \
     --version 7.9.0 \
     --set server.service.type=LoadBalancer \
     --set server.extraArgs[0]=--insecure \
     --set redis.enabled=true \
     --set dex.enabled=false
   ```

3. Generate SSH key for GitHub:
   ```bash
   ssh-keygen -t rsa -b 4096 -C "argocd@example.com" -f /tmp/argocd_ssh_key -N ""
   ```

4. Add the public key to your GitHub repository as a deploy key:
   ```bash
   cat /tmp/argocd_ssh_key.pub
   ```

5. Create the repository secret:
   ```bash
   ssh-keyscan github.com > /tmp/known_hosts
   kubectl create secret generic github-repo-secret \
     --namespace argocd \
     --from-file=sshPrivateKey=/tmp/argocd_ssh_key \
     --from-file=known_hosts=/tmp/known_hosts \
     --from-literal=url=git@github.com:makanist/Docker_k8s_demo.git \
     --from-literal=type=git \
     --dry-run=client -o yaml | \
     kubectl label --local -f - argocd.argoproj.io/secret-type=repository --overwrite -o yaml | \
     kubectl apply -f -
   ```

6. Apply the project and application:
   ```bash
   kubectl apply -f k8s/argocd/project.yaml
   kubectl apply -f k8s/argocd/application.yaml
   ```

7. Get the ArgoCD admin password:
   ```bash
   kubectl -n argocd get secret argocd-initial-admin-secret -o jsonpath="{.data.password}" | base64 -d
   ```

## Accessing the ArgoCD UI

Use port forwarding to access the ArgoCD UI:

```bash
kubectl port-forward svc/argocd-server -n argocd 8080:80
```

Then open http://localhost:8080 in your browser.

## Files in this Directory

- `setup-argocd.sh`: Consolidated setup script
- `project.yaml`: ArgoCD project definition
- `application.yaml`: Application definition for deployment
- `README.md`: This documentation file