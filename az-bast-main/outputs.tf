output "bast_name" {
  value = azurerm_bastion_host.this.name
}

output "bast_id" {
  value = azurerm_bastion_host.this.id
}

output "rg_id" {
  value = data.azurerm_resource_group.rg.id
}

output "rg_name" {
  value = data.azurerm_resource_group.rg.name
}
