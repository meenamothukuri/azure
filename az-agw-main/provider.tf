terraform {
  # 1. Required Version Terraform
  required_version = ">= 0.13"
  # 2. Required Terraform Providers  
  required_providers {
    azurerm = {
      source = "hashicorp/azurerm"
      # https://github.com/hashicorp/terraform-provider-azurerm/issues/21224
      version = "~>3.51"
      configuration_aliases = [
        azurerm.common
      ]
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
      configuration_aliases = [
        acme.staging,
        acme.prod
      ]
    }
  }
}
