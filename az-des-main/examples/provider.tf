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
  }

}
