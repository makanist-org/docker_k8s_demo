# Docker and Kubernetes Demo

This repository contains a demonstration of Docker and Kubernetes deployment for a Node.js application.

## Project Structure

- `app/` - Node.js application source code
- `k8s/` - Kubernetes configuration files
  - `argocd/` - ArgoCD setup files
  - `helm-argocd/` - Helm charts for ArgoCD
  - `ingress/` - Ingress controller setup
  - `manifests/` - Application manifests (deployment, service, ingress, kustomization)
  - `namespaces.yaml` - Namespace definitions

## Prerequisites

- Docker Desktop with Kubernetes enabled
- kubectl
- Helm
- Git

## Setup Instructions

### 1. Clone the Repository

```bash
git clone git@github.com:makanist-org/docker_k8s_demo.git
cd docker_k8s_demo
```

### 2. Create Namespaces

```bash
kubectl apply -f k8s/namespaces.yaml
```

### 3. Deploy ArgoCD

```bash
./k8s/argocd/setup-argocd.sh
```

This script will:
- Install ArgoCD in the `argocd` namespace
- Generate SSH keys for Git repository access
- Create the necessary secrets and configurations
- Display the ArgoCD admin password

After running the script, add the displayed SSH public key to your GitHub repository's deploy keys.

### 4. Deploy ArgoCD Image Updater

```bash
kubectl apply -f k8s/argocd/image-updater.yaml
```

This will install the ArgoCD Image Updater, which automatically updates your application when new Docker images are pushed.

### 5. Deploy the Application

```bash
kubectl apply -f k8s/argocd/project.yaml
kubectl apply -f k8s/argocd/application.yaml
```

### 6. Access ArgoCD UI

```bash
kubectl port-forward svc/argocd-server -n argocd 8080:80
```

Then open http://localhost:8080 in your browser.
- Username: admin
- Password: (displayed during setup)

### 7. Access the Application

The application is deployed in the `docker-demo-namespace` namespace. To access it:

```bash
kubectl port-forward svc/nodejs-app -n docker-demo-namespace 3000:80
```

Then open http://localhost:3000/contacts in your browser.

## CI/CD Pipeline

This project uses:

1. GitHub Actions for CI/CD:
   - Automatically builds and pushes Docker images when code is pushed to the main branch
   - Increments version numbers automatically

2. ArgoCD for GitOps:
   - Automatically deploys changes when the Git repository is updated
   - Manages the application lifecycle

3. ArgoCD Image Updater:
   - Automatically updates the application when new Docker images are pushed
   - Uses semantic versioning to determine which images to deploy

## Troubleshooting

If you encounter issues:

1. Check pod status:
   ```bash
   kubectl get pods -n docker-demo-namespace
   ```

2. Check pod logs:
   ```bash
   kubectl logs -n docker-demo-namespace <pod-name>
   ```

3. Check ArgoCD application status:
   ```bash
   kubectl get application -n argocd
   ```

4. Check ArgoCD Image Updater logs:
   ```bash
   kubectl logs -n argocd -l app.kubernetes.io/name=argocd-image-updater
   ```