data "azurerm_resource_group" "this" {
  name = var.vm_resource_group_name
}

data "azurerm_subnet" "this" {
  name                 = var.subnet["name"]
  virtual_network_name = var.subnet["network_name"]
  resource_group_name  = var.subnet["network_resource_group_name"]
}

data "azuread_user" "bastion_user" {
  for_each            = toset(var.bastion_host_users)
  user_principal_name = each.key
}

data "azuread_group" "bastion_group" {
  for_each     = toset(var.bastion_host_groups)
  display_name = each.key
}

data "azurerm_public_ip" "this" {
  count               = var.public_ip == null ? 0 : 1
  name                = var.public_ip["name"]
  resource_group_name = var.public_ip["resource_group_name"]
}
