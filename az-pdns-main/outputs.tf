output "pdns_name" {
  value = azurerm_private_dns_zone.this.name
}

output "pdns_id" {
  value = azurerm_private_dns_zone.this.id
}

output "rg_id" {
  value = data.azurerm_resource_group.rg.id
}

output "rg_name" {
  value = data.azurerm_resource_group.rg.name
}
