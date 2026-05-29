# Quick Start (5 Minutes to Deploy)

## Prerequisites

```bash
# Install these first
terraform init  # in terraform/
aws configure   # set up AWS credentials
kubectl version # verify kubectl
docker --version # verify docker
```

## Deploy in 3 Commands

### 1. Infrastructure (15 min)

```bash
cd terraform
terraform init
terraform apply -auto-approve
aws eks update-kubeconfig --region us-east-1 --name blogging-app-cluster
```

### 2. Docker & ECR (10 min)

```bash
cd ../FullStack-Blogging-App
docker build -t blogging-app:latest .

# Get ECR URL
ECR=$(cd ../terraform && terraform output -raw ecr_repository_url)

# Push
aws ecr get-login-password --region us-east-1 | docker login --username AWS --password-stdin $ECR
docker tag blogging-app:latest $ECR:latest
docker push $ECR:latest
```

### 3. Deploy (5 min)

```bash
cd ../kubernetes
kubectl apply -f .

# Wait for LoadBalancer
kubectl get svc blogging-app-service -n blogging-app --watch
```

## Access Application

```bash
# Get URL
kubectl get svc blogging-app-service -n blogging-app -o jsonpath='{.status.loadBalancer.ingress[0].hostname}'
# Open in browser: http://[URL]
```

## Cleanup

```bash
cd terraform
terraform destroy -auto-approve
```

---

## Troubleshooting

**Pod stuck in Pending?**

```bash
kubectl describe pod <name> -n blogging-app
```

**LoadBalancer IP pending?**

```bash
# May take 2-3 minutes
kubectl get svc blogging-app-service -n blogging-app --watch
```

**Image not found in ECR?**

```bash
# Verify push worked
aws ecr describe-images --repository-name blogging-app --region us-east-1
```

---

**See DEPLOYMENT.md for detailed steps**
