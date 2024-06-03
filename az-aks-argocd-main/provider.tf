terraform {
  # 1. Required Version Terraform
  required_version = ">= 0.13"
  # 2. Required Terraform Providers  
  required_providers {
    kubernetes = {
      source  = "hashicorp/kubernetes"
      version = ">= 2.18.1, < 3.0.0"
    }
    argocd = {
      source  = "oboukili/argocd"
      version = ">= 6.0.1, < 7.0.0"
    }
  }
}
