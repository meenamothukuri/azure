resource "azurerm_private_dns_zone" "this" {
  name                = var.enable_aks_usage == true ? "${local.domain_name}.privatelink.${var.global_hyperscaler_location_long}.azmk8s.io" : local.domain_name
  resource_group_name = data.azurerm_resource_group.rg.name

  tags = merge(local.common_tags, var.tags)
  lifecycle {
    ignore_changes = [
      tags
    ]
  }

}

resource "azurerm_private_dns_a_record" "this" {
  for_each            = var.pdns_a_records
  name                = each.value["name"]
  zone_name           = azurerm_private_dns_zone.this.name
  resource_group_name = azurerm_private_dns_zone.this.resource_group_name
  ttl                 = each.value["ttl"]
  records             = each.value["records"]

  tags = merge(local.common_tags, var.tags)

  lifecycle {
    ignore_changes = [
      tags
    ]
  }
}


resource "azurerm_private_dns_zone_virtual_network_link" "this" {
  for_each              = var.networks
  name                  = "${var.global_hyperscaler}${var.global_hyperscaler_location}-${var.materna_customer_name}-pdnsvnl-${var.materna_project_number}-${var.global_stage}-${format("%02d", var.networks[each.key].network_link_instance_id)}"
  resource_group_name   = azurerm_private_dns_zone.this.resource_group_name
  private_dns_zone_name = azurerm_private_dns_zone.this.name
  virtual_network_id    = data.azurerm_virtual_network.this[each.key].id
}


resource "azurerm_private_dns_zone_virtual_network_link" "this_external" {
  for_each              = var.external_networks
  name                  = "${var.global_hyperscaler}${var.global_hyperscaler_location}-${var.materna_customer_name}-pdnsvnl-${var.materna_project_number}-${var.global_stage}-${format("%02d", each.value["network_link_instance_id"])}"
  resource_group_name   = azurerm_private_dns_zone.this.resource_group_name
  private_dns_zone_name = azurerm_private_dns_zone.this.name
  virtual_network_id    = each.value["id"]
}
