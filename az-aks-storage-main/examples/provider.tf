provider "azurerm" {
  features {
  }

  subscription_id = local.global_subscription_id
  tenant_id       = local.global_tenant_id
}

provider "azurerm" {
  alias = "common"

  features {
  }

  subscription_id = local.common_global_subscription_id
  tenant_id       = local.global_tenant_id
}

provider "helm" {
  alias = "this"
  kubernetes {
    host                   = module.aks.kubeconfig.0.host
    token                  = module.aks.kubeconfig.0.password
    client_certificate     = base64decode(module.aks.kubeconfig.0.client_certificate)
    client_key             = base64decode(module.aks.kubeconfig.0.client_key)
    cluster_ca_certificate = base64decode(module.aks.kubeconfig.0.cluster_ca_certificate)
  }
}

provider "kubernetes" {
  alias                  = "this"
  host                   = module.aks.kubeconfig.0.host
  token                  = module.aks.kubeconfig.0.password
  client_certificate     = base64decode(module.aks.kubeconfig.0.client_certificate)
  client_key             = base64decode(module.aks.kubeconfig.0.client_key)
  cluster_ca_certificate = base64decode(module.aks.kubeconfig.0.cluster_ca_certificate)

}

terraform {
  # 1. Required Version Terraform
  required_version = ">= 0.13"
  # 2. Required Terraform Providers  
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~>3.28"
    }
    azuread = {
      source  = "hashicorp/azuread"
      version = "~> 2.29"
    }
    random = {
      source  = "hashicorp/random"
      version = "~> 3.0"
    }
    azurecaf = {
      source  = "aztfmod/azurecaf"
      version = "1.2.23"
    }
    kubernetes = {
      source  = "hashicorp/kubernetes"
      version = "2.18.1"
    }
  }

}
