output "snet_id" {
  value = azurerm_subnet.this.id
}

output "snet_name" {
  value = azurerm_subnet.this.name
}

output "snet_address_prefix" {
  value = azurerm_subnet.this.address_prefixes[0]
}

output "vnet_id" {
  value = data.azurerm_virtual_network.vnet.id
}

output "vnet_name" {
  value = data.azurerm_virtual_network.vnet.name
}

output "rg_id" {
  value = data.azurerm_resource_group.rg.id
}

output "rg_name" {
  value = data.azurerm_resource_group.rg.name
}
