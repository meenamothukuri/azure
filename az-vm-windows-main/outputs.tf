output "vm_object" {
  value = azurerm_windows_virtual_machine.this
}

output "private_ip_address" {
  value = azurerm_network_interface.this.private_ip_address
}