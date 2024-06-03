output "ngw_name" {
  value = azurerm_nat_gateway.this.name
}

output "ngw_id" {
  value = azurerm_nat_gateway.this.id
}

output "rg_name" {
  value = data.azurerm_resource_group.rg.name
}

output "rg_id" {
  value = data.azurerm_resource_group.rg.id
}
