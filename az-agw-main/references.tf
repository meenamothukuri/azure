data "azurerm_resource_group" "rg" {
  name = var.resource_group_name
}

data "azurerm_subnet" "snet_gateway" {
  name                 = var.subnet["name"]
  virtual_network_name = var.subnet["network_name"]
  resource_group_name  = var.subnet["network_resource_group_name"]
}

data "azurerm_virtual_network" "vnet_gateway" {
  name                = var.subnet["network_name"]
  resource_group_name = var.subnet["network_resource_group_name"]
}

data "azuread_service_principal" "agic" {
  count = var.agic_service_principal_name == null ? 0 : 1

  display_name = var.agic_service_principal_name
}

data "azuread_service_principal" "dns" {
  count        = var.ssl_certificate_config == null ? 0 : 1
  display_name = var.ssl_certificate_config["dns_zone"]["dns_service_principal_name"]
}

data "azuread_application" "dns" {
  count     = var.ssl_certificate_config == null ? 0 : 1
  client_id = data.azuread_service_principal.dns[0].client_id
}

