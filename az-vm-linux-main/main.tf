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
    public_ip_address_id          = var.public_ip == null ? null : data.azurerm_public_ip.this[0].id
  }
}

resource "azurerm_linux_virtual_machine" "this" {
  name                            = lower(format("%s%s%s%s%02d", var.global_hyperscaler, var.materna_customer_name, substr(var.global_stage, 0, 1), var.materna_workload, var.virtual_machine_instance))
  resource_group_name             = data.azurerm_resource_group.this.name
  location                        = data.azurerm_resource_group.this.location
  size                            = var.vm_size
  admin_username                  = var.vm_admin_username # kann überschrieben werden
  admin_password                  = var.vm_admin_password == null ? random_password.this.result : var.vm_admin_password
  license_type                    = var.license_type != "none" ? var.license_type : null
  disable_password_authentication = false
  encryption_at_host_enabled      = false
  // timezone = var.timezone
  network_interface_ids = [
    azurerm_network_interface.this.id,
  ]

  os_disk {
    name                 = lower(format("%s%s%s%s%02d-dsk00", var.global_hyperscaler, var.materna_customer_name, substr(var.global_stage, 0, 1), var.materna_workload, var.virtual_machine_instance))
    caching              = var.vm_os_disk.caching
    storage_account_type = var.vm_os_disk.storage_account_type
    disk_size_gb         = var.vm_os_disk.disk_size_gb

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

resource "azurerm_role_assignment" "bastion_user_read_vm" {
  for_each             = toset(var.bastion_host_users)
  scope                = azurerm_linux_virtual_machine.this.id
  role_definition_name = "Reader"
  principal_id         = data.azuread_user.bastion_user[each.key].object_id
}

resource "azurerm_role_assignment" "bastion_user_read_nic" {
  for_each             = toset(var.bastion_host_users)
  scope                = azurerm_network_interface.this.id
  role_definition_name = "Reader"
  principal_id         = data.azuread_user.bastion_user[each.key].object_id
}

resource "azurerm_role_assignment" "bastion_group_read_vm" {
  for_each             = toset(var.bastion_host_groups)
  scope                = azurerm_linux_virtual_machine.this.id
  role_definition_name = "Reader"
  principal_id         = data.azuread_group.bastion_group[each.key].object_id
}

resource "azurerm_role_assignment" "bastion_group_read_nic" {
  for_each             = toset(var.bastion_host_groups)
  scope                = azurerm_network_interface.this.id
  role_definition_name = "Reader"
  principal_id         = data.azuread_group.bastion_group[each.key].object_id
}
