data "azurerm_resource_group" "rg" {
  name = var.resource_group_name
}

data "azurerm_public_ip" "pip" {
  name                = var.public_ip["name"]
  resource_group_name = var.public_ip["resource_group_name"]
}
