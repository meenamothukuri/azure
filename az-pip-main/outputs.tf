output "pip_name" {
  value = azurerm_public_ip.this.name
}

output "pip_id" {
  value = azurerm_public_ip.this.id
}

output "pip_ip_version" {
  value = azurerm_public_ip.this.ip_version
}

output "ip_address" {
  value = azurerm_public_ip.this.ip_address
}

output "rg_name" {
  value = data.azurerm_resource_group.rg.name
}

output "rg_id" {
  value = data.azurerm_resource_group.rg.id
}
