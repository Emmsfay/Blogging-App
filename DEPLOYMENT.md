# Deployment Guide

## Prerequisites

- AWS account with credentials configured
- Terraform >= 1.0
- AWS CLI
- kubectl
- Docker
- Jenkins (for CI/CD)

## Step 1: Deploy Infrastructure (15-20 minutes)

```bash
cd terraform

# Initialize Terraform
terraform init

# Review planned changes
terraform plan

# Deploy infrastructure
terraform apply

# Configure kubectl
aws eks update-kubeconfig --region us-east-1 --name blogging-app-cluster
kubectl get nodes
```

**Resources Created:**

- VPC with 2 public subnets
- EKS cluster (Kubernetes v1.29)
- Node group (2x t3.medium)
- ECR repository

## Step 2: Build Docker Image (10-15 minutes)

```bash
cd FullStack-Blogging-App

# Build image
docker build -t blogging-app:latest .

# Get ECR URL
ECR_URL=$(cd ../terraform && terraform output -raw ecr_repository_url)
echo $ECR_URL

# Tag image
docker tag blogging-app:latest $ECR_URL:latest

# Login to ECR
aws ecr get-login-password --region us-east-1 | docker login --username AWS --password-stdin $ECR_URL

# Push to ECR
docker push $ECR_URL:latest
```

## Step 3: Deploy to Kubernetes (5-10 minutes)

```bash
# Apply manifests
kubectl apply -f kubernetes/

# Verify deployment
kubectl get pods -n blogging-app
kubectl get svc -n blogging-app

# Wait for LoadBalancer IP
kubectl get svc blogging-app-service -n blogging-app --watch
```

## Step 4: Access Application

```bash
# Get LoadBalancer DNS
LB_DNS=$(kubectl get svc blogging-app-service -n blogging-app \
  -o jsonpath='{.status.loadBalancer.ingress[0].hostname}')

echo "Application URL: http://$LB_DNS"
```

## Verification

```bash
# Check pod health
kubectl get pods -n blogging-app -o wide

# View pod logs
kubectl logs -n blogging-app -l app=blogging-app --tail=50

# Check deployment status
kubectl describe deployment blogging-app -n blogging-app
```

## Troubleshooting

### Pods in Pending state

```bash
kubectl describe pod <pod-name> -n blogging-app
```

Check if nodes have capacity or if image pull is failing.

### LoadBalancer IP Pending

```bash
# May take 2-3 minutes to provision
kubectl get svc blogging-app-service -n blogging-app --watch
```

### Application not responding

```bash
# Check pod logs
kubectl logs -n blogging-app -l app=blogging-app -f

# Verify health probes
kubectl describe pod <pod-name> -n blogging-app | grep -A 5 "Liveness"
```

## Jenkins CI/CD Pipeline

The Jenkinsfile automates: build → test → docker build → ECR push → EKS deploy

### Configure Jenkins

1. Add AWS credentials as `aws-account-id`
2. Point to this repository
3. Trigger pipeline

Pipeline stages:

- Build & Test
- Build Docker Image
- Push to ECR
- Deploy to EKS
- Verify

## Cleanup

```bash
# Delete Kubernetes resources
kubectl delete namespace blogging-app

# Destroy infrastructure
cd terraform
terraform destroy
```

## Cost

- **EKS**: ~$73/month
- **EC2 (2x t3.medium)**: ~$30/month
- **Total**: ~$103/month
