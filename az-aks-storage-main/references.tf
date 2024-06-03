data "azurerm_resource_group" "this" {
  name = var.aks["resource_group_name"]
}

data "azurerm_subscription" "this" {
  subscription_id = var.global_subscription_id
}

data "azurerm_user_assigned_identity" "this" {
  name                = var.aks["user_assigned_identity_name"]
  resource_group_name = data.azurerm_resource_group.this.name
}

data "azurerm_disk_encryption_set" "des" {
  count = var.encryption == null ? 0 : 1

  name                = var.encryption["disk_encryption_set"]["name"]
  resource_group_name = var.encryption["disk_encryption_set"]["resource_group_name"]
}
