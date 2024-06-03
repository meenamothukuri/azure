output "st_id" {
  value = var.storage_account_endpoint == null ? null : module.storage_account[0].st_id
}

output "da_id" {
  value = var.disk_access_endpoint == null ? null : module.disk_access[0].da_id
}
