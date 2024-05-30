resource "azurerm_nat_gateway" "this" {
  name                    = local.nat_gateway_name
  resource_group_name     = data.azurerm_resource_group.rg.name
  location                = data.azurerm_resource_group.rg.location
  sku_name                = "Standard"
  idle_timeout_in_minutes = 4
  tags                    = merge(local.common_tags, var.tags)
}

resource "azurerm_nat_gateway_public_ip_association" "this" {
  nat_gateway_id       = azurerm_nat_gateway.this.id
  public_ip_address_id = data.azurerm_public_ip.pip.id
}
