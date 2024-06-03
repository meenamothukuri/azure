output "dns_name" {
  value = azurerm_dns_zone.this.name
}

output "dns_id" {
  value = azurerm_dns_zone.this.id
}

output "rg_id" {
  value = data.azurerm_resource_group.rg.id
}

output "rg_name" {
  value = data.azurerm_resource_group.rg.name
}

output "name_servers" {
  value = azurerm_dns_zone.this.name_servers
}
