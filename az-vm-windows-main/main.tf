resource "random_password" "this" {
  length      = 16
  special     = true
  min_lower   = 1
  min_numeric = 1
  min_special = 1
  min_upper   = 1

  override_special = "!#$%&*()-_=+[]{}<>:?"
}

resource "azurerm_network_interface" "this" {
  name                    = lower(format("%s%s%s%s%02d-nic00", var.global_hyperscaler, var.materna_customer_name, substr(var.global_stage, 0, 1), var.materna_workload, var.virtual_machine_instance))
  location                = data.azurerm_resource_group.this.location
  resource_group_name     = data.azurerm_resource_group.this.name
  internal_dns_name_label = lower(format("%s%s%s%s%02d", var.global_hyperscaler, var.materna_customer_name, substr(var.global_stage, 0, 1), var.materna_workload, var.virtual_machine_instance))
  ip_configuration {
    name                          = "internal"
    subnet_id                     = data.azurerm_subnet.this.id
    private_ip_address_allocation = "Dynamic"
  }
}

resource "azurerm_windows_virtual_machine" "this" {
  name                = lower(format("%s%s%s%s%02d", var.global_hyperscaler, var.materna_customer_name, substr(var.global_stage, 0, 1), var.materna_workload, var.virtual_machine_instance))
  resource_group_name = data.azurerm_resource_group.this.name
  location            = data.azurerm_resource_group.this.location
  size                = var.vm_size
  admin_username      = var.vm_admin_username # kann überschrieben werden
  admin_password      = var.vm_admin_password == null ? random_password.this.result : var.vm_admin_password
  license_type        = var.license_type != "none" ? var.license_type : null
  //disable_password_authentication = false
  encryption_at_host_enabled = false
  // timezone = var.timezone
  network_interface_ids = [
    azurerm_network_interface.this.id,
  ]

  enable_automatic_updates = var.enable_automatic_updates

  os_disk {
    name                 = lower(format("%s%s%s%s%02d-dsk00", var.global_hyperscaler, var.materna_customer_name, substr(var.global_stage, 0, 1), var.materna_workload, var.virtual_machine_instance))
    caching              = var.vm_os_disk.caching
    storage_account_type = var.vm_os_disk.storage_account_type
    disk_size_gb         = var.vm_os_disk.disk_size_gb

  }

  dynamic "identity" {
    for_each = toset(var.identity_ids == null ? [] : ["1"])
    content {
      type         = "UserAssigned"
      identity_ids = var.identity_ids
    }
  }

  source_image_reference {
    publisher = var.vm_source_image_reference.publisher
    offer     = var.vm_source_image_reference.offer
    sku       = var.vm_source_image_reference.sku
    version   = var.vm_source_image_reference.version
  }
  tags = merge(local.common_tags, var.tags)

  depends_on = [
    azurerm_network_interface.this,
  ]
}

resource "azurerm_virtual_machine_extension" "script_execute" {
  for_each = var.commands_to_execute

  name                 = each.key
  virtual_machine_id   = azurerm_windows_virtual_machine.this.id
  publisher            = "Microsoft.Compute"
  type                 = "CustomScriptExtension"
  type_handler_version = "1.9"

  settings = jsonencode({ "commandToExecute" = each.value })

}
