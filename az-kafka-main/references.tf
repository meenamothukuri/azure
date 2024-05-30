data "azurerm_resource_group" "rg" {
  name = var.resource_group_name
}

data "azurerm_subnet" "snet" {
  name                 = var.subnet["name"]
  virtual_network_name = var.subnet["network_name"]
  resource_group_name  = var.subnet["network_resource_group_name"]
}


data "azurerm_virtual_network" "vnet" {
  name                = var.subnet["network_name"]
  resource_group_name = var.subnet["network_resource_group_name"]
}
