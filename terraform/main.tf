# Kubernetes Namespace
resource "kubernetes_namespace" "main" {
  metadata {
    name = var.app_name
  }
}

