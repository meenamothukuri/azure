moved {
  from = module.private_endpoint_disk_access[0].azurecaf_name.private_endpoint
  to   = module.disk_access[0].module.private_endpoint_disk_access.azurecaf_name.private_endpoint
}

moved {
  from = module.private_endpoint_disk_access[0].azurerm_private_endpoint.this
  to   = module.disk_access[0].module.private_endpoint_disk_access.azurerm_private_endpoint.this
}
