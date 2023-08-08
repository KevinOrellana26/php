variable "namespace" {
  default = "php"
  type = string
}

/////////////////// Provider

terraform {
  required_providers {
    kubernetes = {
      source  = "hashicorp/kubernetes"
      version = ">=2.21.1"
    }
  }
}

provider "kubernetes" {
}

provider "aws" {
}

//////////////////// Namespace
resource "kubernetes_namespace" "default" {
  metadata {
    name = var.namespace
  }
}

//////////////////// Deployment
resource "kubernetes_deployment" "php_deploy" {
  depends_on = [
    kubernetes_namespace.default
  ]
  metadata {
    name      = "php"
    namespace = var.namespace
  }
  spec {
    selector {
      match_labels = {
        app = "php"
      }
    }
    replicas = 1
    template {
      metadata {
        labels = {
          app = "php"
        }
      }
      spec {
        container {
          name  = "php"
          image = "kevinorellana/php:v1"
          port {
            container_port = 80
          }
          image_pull_policy = "Always"
        }
      }
    }
  }
}

//////////////////// Service
resource "kubernetes_manifest" "php_service" {
  depends_on = [
    kubernetes_namespace.default,
  ]
  manifest = yamldecode(templatefile(
    "${path.module}/manifests/php-service.tpl.yaml",
    {
      "namespace" = var.namespace
    }
  ))
}

//////////////////// Ingress
resource "kubernetes_manifest" "php_ingress" {
  depends_on = [
    kubernetes_namespace.default,
  ]
  manifest = yamldecode(templatefile(
    "${path.module}/manifests/php-ingress.tpl.yaml",
    {
      "namespace" = var.namespace
    }
  ))
}

output "ingress_host" {
  value = kubernetes_manifest.php_ingress.metadata.annotations["nginx.ingress.kubernetes.io/rewrite-target"]
}