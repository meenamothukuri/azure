output "pe_id" {
  value = azurerm_private_endpoint.this.id
}

output "pe_name" {
  value = azurerm_private_endpoint.this.name
}

output "rg_id" {
  value = data.azurerm_resource_group.rg.id
}

output "rg_name" {
  value = data.azurerm_resource_group.rg.name
}

output "snet_id" {
  value = data.azurerm_subnet.subnet.id
}

output "snet_name" {
  value = data.azurerm_subnet.subnet.name
}

output "vnet_name" {
  value = data.azurerm_subnet.subnet.virtual_network_name
}

output "vnet_rg_name" {
  value = data.azurerm_subnet.subnet.resource_group_name
}
