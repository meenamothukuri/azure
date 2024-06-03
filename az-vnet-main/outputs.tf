output "vnet_name" {
  value = azurerm_virtual_network.this.name
}

output "vnet_id" {
  value = azurerm_virtual_network.this.id
}

output "rg_id" {
  value = data.azurerm_resource_group.rg.id
}

output "rg_name" {
  value = data.azurerm_resource_group.rg.name
}
