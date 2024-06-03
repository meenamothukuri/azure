resource "azurecaf_name" "nsg" {
  resource_type = "azurerm_network_security_group"
  prefixes      = [format("%s%s", var.global_hyperscaler, var.global_hyperscaler_location), var.materna_customer_name]
  suffixes      = [var.materna_project_number, var.global_stage, format("%02d", var.nsg_instance)]
  clean_input   = true
}


resource "azurerm_network_security_group" "this" {
  name                = azurecaf_name.nsg.result
  location            = data.azurerm_resource_group.rg.location
  resource_group_name = data.azurerm_resource_group.rg.name

  tags = merge(local.common_tags, var.tags)
}


resource "azurerm_network_security_rule" "this" {

  for_each = merge(var.nsg_inbound_rules, var.nsg_outbound_rules)

  name                       = each.key
  priority                   = each.value["priority"]
  direction                  = each.value["direction"]
  access                     = each.value["access"]
  protocol                   = each.value["protocol"]
  source_port_range          = each.value["source_port_range"]
  destination_port_range     = each.value["destination_port_range"]
  source_address_prefix      = each.value["source_address_prefix"]
  destination_address_prefix = each.value["destination_address_prefix"]
  description                = each.value["description"]

  resource_group_name         = data.azurerm_resource_group.rg.name
  network_security_group_name = azurerm_network_security_group.this.name
}


resource "azurerm_subnet_network_security_group_association" "this" {
  subnet_id                 = data.azurerm_subnet.snet.id
  network_security_group_id = azurerm_network_security_group.this.id
}