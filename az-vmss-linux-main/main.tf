resource "random_password" "this" {
  length      = 16
  special     = true
  min_lower   = 1
  min_numeric = 1
  min_special = 1
  min_upper   = 1

  override_special = "!#$%&*()-_=+[]{}<>:?"
}

resource "azurecaf_name" "azurerm_linux_virtual_machine_scale_set" {
  resource_type = "azurerm_linux_virtual_machine_scale_set"
  prefixes      = [format("%s%s", var.global_hyperscaler, var.global_hyperscaler_location), var.materna_customer_name]
  suffixes      = [var.materna_project_number, var.global_stage, format("%02d", var.vmss_id)]
  clean_input   = true
}

resource "azurerm_linux_virtual_machine_scale_set" "this" {
  name                = azurecaf_name.azurerm_linux_virtual_machine_scale_set.result
  resource_group_name = data.azurerm_resource_group.this.name
  location            = data.azurerm_resource_group.this.location
  sku                 = var.vmss_size
  instances           = var.vmss_instances
  admin_username      = var.vmss_admin_username
  admin_password      = var.vmss_admin_password
  #checkov:skip=CKV_AZURE_149:Ensure that Virtual machine does not enable password authentication
  #checkov:skip=CKV_AZURE_179:Ensure VM agent is installed
  #checkov:skip=CKV_AZURE_97:Ensure that Virtual machine scale sets have encryption at host enabled
  #checkov:skip=CKV_AZURE_49:Ensure Azure linux scale set does not use basic authentication(Use SSH Key Instead)
  #checkov:skip=CKV_AZURE_178:Ensure Windows VM enables SSH with keys for secure communication

  source_image_id = var.vmss_source_image_id

  dynamic "source_image_reference" {
    for_each = toset(var.vmss_source_image_reference == null ? [] : ["1"])
    content {
      publisher = var.vmss_source_image_reference.publisher
      offer     = var.vmss_source_image_reference.offer
      sku       = var.vmss_source_image_reference.sku
      version   = var.vmss_source_image_reference.version
    }
  }

  disable_password_authentication = false

  os_disk {
    storage_account_type = var.vmss_os_disk.storage_account_type
    caching              = var.vmss_os_disk.caching
  }

  network_interface {
    name    = "primary"
    primary = true

    ip_configuration {
      name      = "internal"
      subnet_id = data.azurerm_subnet.this.id
    }
  }
}

resource "azurecaf_name" "azurerm_monitor_autoscale_setting" {
  count = var.auto_start != null || var.auto_stop != null ? 1 : 0

  resource_type = "azurerm_monitor_autoscale_setting"
  prefixes      = [format("%s%s", var.global_hyperscaler, var.global_hyperscaler_location), var.materna_customer_name]
  suffixes      = [var.materna_project_number, var.global_stage, format("%02d", var.vmss_id)]
  clean_input   = true
}

resource "azurerm_monitor_autoscale_setting" "this" {
  count = var.auto_start != null || var.auto_stop != null ? 1 : 0

  name                = azurecaf_name.azurerm_monitor_autoscale_setting[0].result
  enabled             = true
  resource_group_name = data.azurerm_resource_group.this.name
  location            = data.azurerm_resource_group.this.location
  target_resource_id  = azurerm_linux_virtual_machine_scale_set.this.id

  dynamic "profile" {
    for_each = toset(var.auto_stop == null ? [] : ["1"])
    content {
      name = "VM-Down"

      capacity {
        default = 0
        minimum = 0
        maximum = 0
      }

      rule {
        metric_trigger {
          metric_name        = "Percentage CPU"
          metric_resource_id = azurerm_linux_virtual_machine_scale_set.this.id
          time_grain         = "PT1M"
          statistic          = "Average"
          time_window        = "PT5M"
          time_aggregation   = "Average"
          operator           = "LessThan"
          threshold          = 99
        }

        scale_action {
          direction = "Decrease"
          type      = "ChangeCount"
          value     = "0"
          cooldown  = "PT1M"
        }
      }

      recurrence {
        timezone = var.auto_stop["timezone"]
        days     = var.auto_stop["days"]
        hours    = var.auto_stop["hours"]
        minutes  = var.auto_stop["minutes"]
      }
    }
  }


  dynamic "profile" {
    for_each = toset(var.auto_start == null ? [] : ["1"])
    content {
      name = "VM-Up"

      capacity {
        default = 1
        minimum = 1
        maximum = 1
      }

      rule {
        metric_trigger {
          metric_name        = "Percentage CPU"
          metric_resource_id = azurerm_linux_virtual_machine_scale_set.this.id
          time_grain         = "PT1M"
          statistic          = "Average"
          time_window        = "PT5M"
          time_aggregation   = "Average"
          operator           = "LessThan"
          threshold          = 99
        }

        scale_action {
          direction = "Increase"
          type      = "ChangeCount"
          value     = "1"
          cooldown  = "PT1M"
        }
      }

      recurrence {
        timezone = var.auto_start["timezone"]
        days     = var.auto_start["days"]
        hours    = var.auto_start["hours"]
        minutes  = var.auto_start["minutes"]
      }
    }
  }
}
