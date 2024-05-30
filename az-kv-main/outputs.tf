output "kv_name" {
  value = azurerm_key_vault.this.name

  depends_on = [
    module.private_endpoint.pe_id,
    azurerm_role_assignment.admin
  ]
}

output "kv_id" {
  value = azurerm_key_vault.this.id

  depends_on = [
    module.private_endpoint.pe_id,
    azurerm_role_assignment.admin
  ]
}

output "kv_pe_id" {
  value = module.private_endpoint.pe_id

}

output "rg_id" {
  value = data.azurerm_resource_group.rg.id
}

output "rg_name" {
  value = data.azurerm_resource_group.rg.name
}

