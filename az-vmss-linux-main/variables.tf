variable "global_subscription_id" {
  type    = string
  default = ""
  validation {
    condition     = can(regex("^[[:alnum:]]{8}-[[:alnum:]]{4}-[[:alnum:]]{4}-[[:alnum:]]{4}-[[:alnum:]]{12}$", var.global_subscription_id))
    error_message = "Must be an valid Subscription-ID."
  }
}

variable "global_hyperscaler" {
  description = "Kennzeichen für den Hyperscaler"
  type        = string
  validation {
    condition     = contains(["az", "dl", "aw", "gc", "io"], var.global_hyperscaler)
    error_message = "Must be either az, dl, aw, gc or io"
  }
}

variable "global_hyperscaler_location" {
  description = "Kennzeichen für den Hyperscaler Region"
  type        = string
  validation {
    condition     = contains(["gw", "gn", "we", "ne", "io"], var.global_hyperscaler_location)
    error_message = "Muss eine definierte Hyperscaler Region sein."
  }
}


variable "materna_customer_name" {
  description = "Name of the customer (max. 5 characters)."
  type        = string
  validation {
    condition     = can(regex("^[a-z0-9]{3}$", var.materna_customer_name))
    error_message = "Muss ein Kundenkürzel sein (max. 3 Zeichen)."
  }
}

variable "global_stage" {
  description = "Staging Umgebung"
  type        = string
  validation {
    condition     = contains(["dev", "tst", "prd", "qas", "sbx"], var.global_stage)
    error_message = "Must be either dev, tst, qas, sbx or prd"
  }
}

variable "vmss_id" {
  description = "Die Instanz-ID für die Virtuelle Maschine"
  default     = 1
  type        = number
}



variable "resource_group_name" {
  description = "Resource group für die vmss"
  type        = string
}

variable "materna_project_number" {
  type        = string
  description = "Materna internal project nummer"
}


variable "vmss_size" {
  description = "SKU, die für diese virtuelle Maschine verwendet werden soll"
  type        = string
  default     = "Standard_B1S"
}

variable "vmss_instances" {
  description = "the number of instances"
  default     = 1
}



variable "vmss_admin_username" {
  description = "username für die vm"
  type        = string
  default     = "matadmin"
  validation {
    condition     = (var.vmss_admin_username != "Admin") && (var.vmss_admin_username != "Administrator") && (var.vmss_admin_username != "root")
    error_message = "Must not be Administrator, Admin or root"
  }

}


variable "subnet" {
  description = "Subnet parameters"
  type = object({
    name                        = string
    network_name                = string
    network_resource_group_name = string
  })
}

variable "vmss_source_image_id" {
  description = "Custom VM Image ID in Azure"
  default     = null
}

variable "vmss_source_image_reference" {
  description = "Vm-Image Eigenschaften"
  type = object({
    publisher = string
    offer     = string
    sku       = string
    version   = string
  })
  default = null
}


variable "vmss_os_disk" {
  description = "OS-Disk parameters"
  type = object({
    caching              = string
    storage_account_type = string
    disk_size_gb         = string
  })
  default = {
    caching              = "ReadWrite"
    storage_account_type = "Standard_LRS"
    disk_size_gb         = null
  }
  validation {
    condition     = contains(["ReadWrite", "None", "ReadOnly"], var.vmss_os_disk.caching) || var.vmss_os_disk.caching == null
    error_message = "Must be either ReadWrite, None, ReadOnly"
  }
  validation {
    condition     = contains(["Standard_LRS", "StandardSSD_LRS", "Premium_LRS", "StandardSSD_ZRS", "Premium_ZRS"], var.vmss_os_disk.storage_account_type)
    error_message = "Must be either Standard_LRS, StandardSSD_LRS, Premium_LRS, StandardSSD_ZRS, Premium_ZRS"
  }
}

variable "license_type" {
  type        = string
  description = "Must be either RHEL_BYOS, SLES_BYOS, none"
  default     = "none"
  validation {
    condition     = contains(["RHEL_BYOS", "SLES_BYOS", "none"], var.license_type)
    error_message = "Must be either RHEL_BYOS, SLES_BYOS, none"
  }
}

variable "auto_start" {
  description = "Startor shutdown the VMSS at specific time"
  type = object({
    timezone = string
    days     = list(string)
    hours    = list(number)
    minutes  = list(number)
  })
  default = null
}

variable "auto_stop" {
  description = "Shutdown the VMSS at specific time"
  type = object({
    timezone = string
    days     = list(string)
    hours    = list(number)
    minutes  = list(number)
  })
  default = null
}


variable "tags" {
  description = "Tags for the deployment"
  type        = map(any)
}

variable "materna_cost_center" {
  type        = string
  description = "Materna cost center"
}


variable "vmss_admin_password" {
  description = "password für die vm"
  type        = string
  default     = null
}

