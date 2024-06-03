data "azurerm_resource_group" "this" {
  name = var.resource_group_name
}

data "azurerm_subnet" "this" {
  name                 = var.subnet["name"]
  virtual_network_name = var.subnet["network_name"]
  resource_group_name  = var.subnet["network_resource_group_name"]
}
