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

variable "virtual_machine_instance" {
  description = "Die Instanz-ID für die Virtuelle Maschine"
  default     = 1
  type        = number
}



variable "vm_resource_group_name" {
  description = "Resource group für die vm"
  type        = string
}

variable "materna_project_number" {
  type        = string
  description = "Materna internal project nummer"
}


variable "vm_size" {
  description = "SKU, die für diese virtuelle Maschine verwendet werden soll"
  type        = string
  default     = "Standard_F2"
}

variable "vm_admin_username" {
  description = "username für die vm"
  type        = string
  default     = "matadmin"
  validation {
    condition     = (var.vm_admin_username != "Admin") && (var.vm_admin_username != "Administrator") && (var.vm_admin_username != "root")
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

variable "vm_source_image_reference" {
  description = "Vm-Image Eigenschaften"
  type = object({
    publisher = string
    offer     = string
    sku       = string
    version   = string
  })
  default = {
    publisher = "Canonical"
    offer     = "UbuntuServer"
    sku       = "16.04-LTS"
    version   = "latest"
  }
}


variable "vm_os_disk" {
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
    condition     = contains(["ReadWrite", "None", "ReadOnly"], var.vm_os_disk.caching) || var.vm_os_disk.caching == null
    error_message = "Must be either ReadWrite, None, ReadOnly"
  }
  validation {
    condition     = contains(["Standard_LRS", "StandardSSD_LRS", "Premium_LRS", "StandardSSD_ZRS", "Premium_ZRS"], var.vm_os_disk.storage_account_type)
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

variable "tags" {
  description = "Tags for the deployment"
  type        = map(any)
}

variable "materna_cost_center" {
  type        = string
  description = "Materna cost center"
}

variable "materna_workload" {
  type        = string
  description = "Materna vm workload(min 3 Zeichen und max 7 Zeichen)."
  validation {
    condition     = can(regex("^[a-zA-Z0-9]{3,7}$", var.materna_workload))
    error_message = "Muss min 3 Zeichen und max 7 Zeichen sein."
  }
}

variable "vm_admin_password" {
  description = "password für die vm"
  type        = string
  default     = null
}

variable "bastion_host_groups" {
  type    = list(string)
  default = []
}
variable "bastion_host_users" {
  type    = list(string)
  default = []
}


variable "public_ip" {
  description = "Public ip paramaters"
  default     = null
  type = object({
    name                = string
    resource_group_name = string
  })
}
