resource "azurecaf_name" "route_table" {
  resource_type = "azurerm_route_table"
  prefixes      = [format("%s%s", var.global_hyperscaler, var.global_hyperscaler_location), var.materna_customer_name]
  suffixes      = [var.materna_project_number, var.global_stage, format("%02d", var.route_table_instance)]
  clean_input   = true
}


resource "azurecaf_name" "routes" {
  for_each      = var.routes
  resource_type = "azurerm_route"
  prefixes      = [format("%s%s", var.global_hyperscaler, var.global_hyperscaler_location), var.materna_customer_name]
  suffixes      = [var.materna_project_number, var.global_stage, format("%02d", index(keys(var.routes), each.key) + 1)]
  clean_input   = true
}

resource "azurerm_route_table" "this" {
  name                = azurecaf_name.route_table.result
  location            = data.azurerm_resource_group.rg.location
  resource_group_name = data.azurerm_resource_group.rg.name
  tags                = merge(local.common_tags, var.tags)

  lifecycle {
    ignore_changes = [
      location
    ]
  }
}

resource "azurerm_route" "this" {
  for_each               = var.routes
  name                   = azurecaf_name.routes[each.key].result
  resource_group_name    = data.azurerm_resource_group.rg.name
  route_table_name       = azurerm_route_table.this.name
  address_prefix         = each.value["address_prefix"]                    # Can be CIDR (such as 10.1.0.0/16) or Azure Service Tag (such as ApiManagement, AzureBackup or AzureMonitor) format
  next_hop_type          = each.value["next_hop_type"]                     # VirtualNetworkGateway, VnetLocal, Internet, VirtualAppliance, None
  next_hop_in_ip_address = try(each.value["next_hop_in_ip_address"], null) # Only allowed when type = VirtualAppliance
}

resource "azurerm_subnet_route_table_association" "this" {
  for_each       = var.associated_subnets
  subnet_id      = data.azurerm_subnet.subnets[each.key].id
  route_table_id = azurerm_route_table.this.id
}
