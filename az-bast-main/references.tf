data "azurerm_resource_group" "rg" {
  name = var.resource_group_name
}

data "azurerm_subnet" "snet" {
  name                 = var.subnet["name"]
  virtual_network_name = var.subnet["network_name"]
  resource_group_name  = var.subnet["network_resource_group_name"]
}

data "azurerm_public_ip" "pip" {
  name                = var.public_ip_name
  resource_group_name = data.azurerm_resource_group.rg.name
}

data "azuread_group" "reader_groups" {
  for_each     = toset(var.reader_groups)
  display_name = each.key
}
