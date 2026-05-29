# Terraform Configuration for AWS EKS

Deploys VPC, EKS cluster, ECR repository, and Kubernetes namespace.

## Quick Start

```bash
# Initialize Terraform
terraform init

# Plan deployment
terraform plan

# Apply configuration
terraform apply

# Configure kubectl
aws eks update-kubeconfig --region us-east-1 --name blogging-app-cluster
kubectl get nodes
```

## Resources Created

- VPC with 2 public subnets
- EKS cluster (v1.29) with managed node group (2x t3.medium)
- ECR repository (blogging-app)
- Kubernetes namespace (blogging-app)

## Variables

Edit `terraform.tfvars` to customize:

```hcl
aws_region    = "us-east-1"        # AWS region
app_name      = "blogging-app"      # Application name
vpc_cidr      = "10.0.0.0/16"      # VPC CIDR block
eks_version   = "1.29"             # Kubernetes version
instance_type = "t3.medium"        # Node instance type
node_count    = 2                  # Number of nodes
```

## Cleanup

```bash
terraform destroy
```

```bash
terraform destroy
```

## Cost Optimization Tips

1. **Use Spot Instances**: Set `enable_spot_instances = true` for ~70% savings
2. **Rightsize Instances**: Change `instance_types` to smaller types for dev
3. **Configure Autoscaling**: Use Karpenter for better bin packing
4. **Use VPC Endpoints**: Reduce NAT Gateway costs

Example for dev environment:

```hcl
instance_types            = ["t3.small"]
desired_size              = 1
enable_spot_instances     = true
```

## Monitoring

```bash
# View cluster logs
kubectl logs -f deployment/blogging-app -n blogging-app

# Check pod status
kubectl get pods -n blogging-app

# Describe pod for troubleshooting
kubectl describe pod <pod-name> -n blogging-app
```

## Remote State (Production)

To use remote state, uncomment the backend configuration in `provider.tf` and create an S3 bucket:

```bash
# Create S3 bucket for state
aws s3api create-bucket --bucket your-terraform-state-bucket --region us-east-1

# Enable versioning
aws s3api put-bucket-versioning --bucket your-terraform-state-bucket \
  --versioning-configuration Status=Enabled

# Create DynamoDB table for locks
aws dynamodb create-table \
  --table-name terraform-locks \
  --attribute-definitions AttributeName=LockID,AttributeType=S \
  --key-schema AttributeName=LockID,KeyType=HASH \
  --provisioned-throughput ReadCapacityUnits=5,WriteCapacityUnits=5
```

## Support

For issues, refer to:

- [Terraform AWS Provider](https://registry.terraform.io/providers/hashicorp/aws/latest/docs)
- [EKS Best Practices Guide](https://aws.github.io/aws-eks-best-practices/)
