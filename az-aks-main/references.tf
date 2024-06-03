# Read the AD group for manageing the cluster, needed for rbac_aad_admin_group_object_ids
data "azuread_group" "this" {
  for_each     = toset(var.aks_cluster_admins)
  display_name = each.value
}

data "azurerm_kubernetes_service_versions" "this" {
  location        = data.azurerm_resource_group.this.location
  include_preview = false
}

data "azurerm_resource_group" "this" {
  name = var.aks_resourcegroup_name
}

data "azurerm_subscription" "this" {
  subscription_id = var.global_subscription_id
}

data "azurerm_virtual_network" "system_node_pool" {
  name                = var.system_node_pool["subnet"]["network_name"]
  resource_group_name = var.system_node_pool["subnet"]["network_resource_group_name"]
}

data "azurerm_subnet" "system_node_pool" {
  name                 = var.system_node_pool["subnet"]["name"]
  virtual_network_name = var.system_node_pool["subnet"]["network_name"]
  resource_group_name  = var.system_node_pool["subnet"]["network_resource_group_name"]
}

data "azuread_service_principal" "agic" {
  display_name = var.agic_service_principal_name
}

data "azuread_application" "agic" {
  client_id = data.azuread_service_principal.agic.client_id
}

data "azurerm_subnet" "additional_node_pools" {
  for_each             = var.additional_node_pools
  name                 = try(each.value["subnet"]["name"], var.system_node_pool["subnet"]["name"])
  virtual_network_name = try(each.value["subnet"]["network_name"], var.system_node_pool["subnet"]["network_name"])
  resource_group_name  = try(each.value["subnet"]["network_resource_group_name"], var.system_node_pool["subnet"]["network_resource_group_name"])
}

data "azurerm_container_registry" "cr" {
  count               = var.container_registry == null ? 0 : 1
  name                = var.container_registry["name"]
  resource_group_name = var.container_registry["resource_group_name"]
}

data "azurerm_disk_encryption_set" "des" {
  count = var.encryption == null ? 0 : 1

  name                = var.encryption["disk_encryption_set"]["name"]
  resource_group_name = var.encryption["disk_encryption_set"]["resource_group_name"]
}

data "azuread_service_principal" "external_dns" {
  count        = var.dns_zone == null ? 0 : 1
  display_name = var.dns_zone["external_dns_service_principal_name"]
}

data "azuread_application" "external_dns" {
  count     = var.dns_zone == null ? 0 : 1
  client_id = data.azuread_service_principal.external_dns[0].client_id
}

data "azuread_service_principal" "hashicorp_vault" {
  count        = var.hashicorp_vault == null ? 0 : 1
  display_name = var.hashicorp_vault["service_principal_name"]
}

data "azuread_application" "hashicorp_vault" {
  count     = var.hashicorp_vault == null ? 0 : 1
  client_id = data.azuread_service_principal.hashicorp_vault[0].client_id
}

data "azurerm_key_vault" "hashicorp_vault" {
  count = var.hashicorp_vault == null ? 0 : 1

  name                = var.hashicorp_vault["key_vault_name"]
  resource_group_name = var.hashicorp_vault["key_vault_resource_group_name"]
}




