data "azurerm_resource_group" "rg" {
  name = var.resource_group_name
}

data "azurerm_subnet" "subnets" {
  for_each             = var.associated_subnets
  name                 = each.value["name"]
  virtual_network_name = each.value["network_name"]
  resource_group_name  = each.value["network_resource_group_name"]
}
