data "azurerm_resource_group" "rg" {
  name = var.resource_group_name
}
data "azurerm_client_config" "current" {}

data "azuread_service_principal" "hashicorp_vault" {
  count        = var.hashicorp_vault == null ? 0 : 1
  display_name = var.hashicorp_vault["service_principal_name"]
}

data "azuread_application" "hashicorp_vault" {
  count          = var.hashicorp_vault == null ? 0 : 1
  application_id = data.azuread_service_principal.hashicorp_vault[0].application_id
}
