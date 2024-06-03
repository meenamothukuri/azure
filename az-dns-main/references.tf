data "azurerm_resource_group" "rg" {
  name = var.resource_group_name
}

data "azuread_service_principal" "external_dns" {
  count        = var.external_dns_service_principal_name == null ? 0 : 1
  display_name = var.external_dns_service_principal_name
}
