# ECR Repository
resource "aws_ecr_repository" "main" {
  name                 = var.app_name
  image_tag_mutability = "MUTABLE"

  tags = {
    Name = "${var.app_name}-ecr"
  }
}

# ECR Repository Output
output "ecr_repository_url" {
  description = "ECR Repository URL"
  value       = aws_ecr_repository.main.repository_url
}
