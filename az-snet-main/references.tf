data "azurerm_resource_group" "rg" {
  name = var.resource_group_name
}

data "azurerm_virtual_network" "vnet" {
  name                = var.vnet_name
  resource_group_name = data.azurerm_resource_group.rg.name
}

data "azurerm_route_table" "route_table" {
  count               = var.associated_route_table == null ? 0 : 1
  name                = var.associated_route_table["name"]
  resource_group_name = var.associated_route_table["resource_group_name"]
}

data "azurerm_nat_gateway" "nat_gateway" {
  count               = var.nat_gateway == null ? 0 : 1
  name                = var.nat_gateway["name"]
  resource_group_name = var.nat_gateway["resource_group_name"]
}
