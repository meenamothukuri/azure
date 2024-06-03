data "azurerm_resource_group" "rg" {
  name = var.resource_group_name
}

data "azurerm_virtual_network" "this" {
  for_each            = var.networks
  name                = each.value["name"]
  resource_group_name = each.value["resource_group_name"]
}
