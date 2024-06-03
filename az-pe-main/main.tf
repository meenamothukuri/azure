resource "azurecaf_name" "private_endpoint" {
  resource_type = "azurerm_private_endpoint"
  prefixes      = [format("%s%s", var.global_hyperscaler, var.global_hyperscaler_location), var.materna_customer_name]
  suffixes      = [var.materna_project_number, var.global_stage, format("%02d", var.private_endpoint_instance)]
  clean_input   = true
}

resource "azurerm_private_endpoint" "this" {
  name                = azurecaf_name.private_endpoint.result
  location            = data.azurerm_resource_group.rg.location
  resource_group_name = data.azurerm_resource_group.rg.name
  subnet_id           = data.azurerm_subnet.subnet.id

  private_service_connection {
    name                           = azurecaf_name.private_endpoint.result
    private_connection_resource_id = var.private_connection_resource_id
    is_manual_connection           = var.is_manual_connection
    subresource_names              = var.subresource_names
  }

  dynamic "private_dns_zone_group" {
    for_each = local.private_dns_zones
    content {
      name                 = private_dns_zone_group.value.name
      private_dns_zone_ids = private_dns_zone_group.value.private_dns_zone_ids
    }
  }

  tags = merge(local.common_tags, var.tags)

  lifecycle {
    ignore_changes = [
      location,
      subnet_id,
      private_dns_zone_group
    ]
  }
}


resource "azurerm_private_dns_a_record" "this" {
  count               = var.manual_private_dns_zone_entry == null || var.private_dns_zone == null ? 0 : 1
  name                = var.manual_private_dns_zone_entry["name"]
  zone_name           = var.private_dns_zone["name"]
  resource_group_name = var.private_dns_zone["resource_group_name"]
  ttl                 = 300
  records             = [azurerm_private_endpoint.this.private_service_connection[0].private_ip_address]
}
