resource "azurecaf_name" "vnet_peering" {
  for_each      = var.network_peering
  resource_type = "azurerm_virtual_network_peering"
  prefixes      = [format("%s%s", var.global_hyperscaler, var.global_hyperscaler_location), var.materna_customer_name]
  suffixes      = [var.materna_project_number, var.global_stage, format("%02d", each.value["instance"])]
  clean_input   = true
}

resource "azurecaf_name" "vnet" {
  resource_type = "azurerm_virtual_network"
  prefixes      = [format("%s%s", var.global_hyperscaler, var.global_hyperscaler_location), var.materna_customer_name]
  suffixes      = [var.materna_project_number, var.global_stage, format("%02d", var.vnet_instance)]
  clean_input   = true
}

resource "azurerm_virtual_network" "this" {
  name                = lower(azurecaf_name.vnet.result)
  location            = data.azurerm_resource_group.rg.location
  resource_group_name = data.azurerm_resource_group.rg.name
  address_space       = [var.address_space]

  # https://learn.microsoft.com/en-us/troubleshoot/azure/azure-kubernetes/error-code-outboundconnfailvmextensionerror
  # https://learn.microsoft.com/en-us/azure/virtual-network/what-is-ip-address-168-63-129-16
  #dns_servers = ["168.63.129.16"]

  tags = merge(local.common_tags, var.tags)
}

resource "azurerm_virtual_network_dns_servers" "this" {
  count              = length(var.dns_server) > 0 ? 1 : 0
  virtual_network_id = azurerm_virtual_network.this.id
  dns_servers        = var.dns_server
}

resource "azurerm_virtual_network_peering" "this" {
  for_each                     = var.network_peering
  name                         = lower(azurecaf_name.vnet_peering[each.key].result)
  resource_group_name          = data.azurerm_resource_group.rg.name
  virtual_network_name         = azurerm_virtual_network.this.name
  remote_virtual_network_id    = each.value["remote_vnet_id"]
  allow_virtual_network_access = true
  allow_forwarded_traffic      = each.value["allow_forwarded_traffic"]
  allow_gateway_transit        = false
}

resource "azurerm_private_dns_zone_virtual_network_link" "this" {
  for_each              = var.private_dns_zones
  name                  = "${var.global_hyperscaler}${var.global_hyperscaler_location}-${var.materna_customer_name}-pdnsvnl-${var.materna_project_number}-${var.global_stage}-${format("%02d", var.private_dns_zones[each.key].network_link_instance_id)}"
  resource_group_name   = data.azurerm_private_dns_zone.this[each.key].resource_group_name
  private_dns_zone_name = data.azurerm_private_dns_zone.this[each.key].name
  virtual_network_id    = azurerm_virtual_network.this.id
}
