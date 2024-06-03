output "cr_name" {
  value = azurerm_container_registry.this.name
}

output "cr_id" {
  value = azurerm_container_registry.this.id
}

output "cr_pe_id" {
  value = module.private_endpoint.pe_id
}

output "rg_id" {
  value = data.azurerm_resource_group.rg.id
}

output "rg_name" {
  value = data.azurerm_resource_group.rg.name
}
