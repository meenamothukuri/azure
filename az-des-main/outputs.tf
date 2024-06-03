output "des_name" {
  value = azurerm_disk_encryption_set.this.name
}

output "des_id" {
  value = azurerm_disk_encryption_set.this.id
}

output "kvk_name" {
  value = azurerm_key_vault_key.this.name
}

output "kvk_id" {
  value = azurerm_key_vault_key.this.id
}

output "kvk_resource_versionless_id" {
  value = azurerm_key_vault_key.this.resource_versionless_id
}

output "kvk_resource_id" {
  value = azurerm_key_vault_key.this.resource_id
}

output "rg_id" {
  value = data.azurerm_resource_group.rg.id
}

output "rg_name" {
  value = data.azurerm_resource_group.rg.name
}
