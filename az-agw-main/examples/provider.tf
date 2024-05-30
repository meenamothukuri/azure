provider "azurerm" {
  features {
  }

  subscription_id = var.ARM_SUBSCRIPTION_ID
  tenant_id       = var.ARM_TENANT_ID
}

provider "acme" {
  alias      = "staging"
  server_url = "https://acme-staging-v02.api.letsencrypt.org/directory"
}

provider "acme" {
  alias      = "prod"
  server_url = "https://acme-v02.api.letsencrypt.org/directory"
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
    acme = {
      source  = "vancluever/acme"
      version = "~> 2.18"
    }
  }
}
