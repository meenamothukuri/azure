output "route_name" {
  value = azurerm_route_table.this.name
}

output "route_id" {
  value = azurerm_route_table.this.id
}

output "rg_name" {
  value = data.azurerm_resource_group.rg.name
}

output "rg_id" {
  value = data.azurerm_resource_group.rg.id
}
