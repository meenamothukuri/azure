data "azurerm_resource_group" "rg" {
  name = var.resource_group_name
}

data "azurerm_key_vault" "key_vault" {
  provider = azurerm.common

  name                = var.key_vault["name"]
  resource_group_name = var.key_vault["resource_group_name"]
}
