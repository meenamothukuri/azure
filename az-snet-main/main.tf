resource "azurecaf_name" "subnet" {
  resource_type = "azurerm_subnet"
  prefixes      = [format("%s%s", var.global_hyperscaler, var.global_hyperscaler_location), var.materna_customer_name]
  suffixes      = [var.materna_project_number, var.global_stage, format("%02d", var.subnet_instance)]
  clean_input   = true
}

resource "azurerm_subnet" "this" {
  name                                          = var.bastion_host_subnet == true ? "AzureBastionSubnet" : azurecaf_name.subnet.result
  resource_group_name                           = data.azurerm_resource_group.rg.name
  virtual_network_name                          = data.azurerm_virtual_network.vnet.name
  address_prefixes                              = [var.address_prefix]
  service_endpoints                             = var.service_endpoints
  private_link_service_network_policies_enabled = var.private_link_service_network_policies_enabled
  private_endpoint_network_policies_enabled     = var.private_endpoint_network_policies_enabled
}

resource "azurerm_subnet_route_table_association" "this" {
  count          = var.associated_route_table == null ? 0 : 1
  subnet_id      = azurerm_subnet.this.id
  route_table_id = data.azurerm_route_table.route_table[0].id
}

resource "azurerm_subnet_nat_gateway_association" "this" {
  count          = var.nat_gateway == null ? 0 : 1
  subnet_id      = azurerm_subnet.this.id
  nat_gateway_id = data.azurerm_nat_gateway.nat_gateway[0].id
}
