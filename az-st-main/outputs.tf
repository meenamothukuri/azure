output "st_name" {
  value = azurerm_storage_account.this.name
  depends_on = [
    module.private_endpoint_file.pe_id,
    module.private_endpoint_blob.pe_id
  ]
}

output "st_id" {
  value = azurerm_storage_account.this.id
  depends_on = [
    module.private_endpoint_file.pe_id,
    module.private_endpoint_blob.pe_id
  ]
}


output "st_primary_access_key" {
  value = azurerm_storage_account.this.primary_access_key
  depends_on = [
    module.private_endpoint_file.pe_id,
    module.private_endpoint_blob.pe_id
  ]
}
