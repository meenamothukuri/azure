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
    publisher = "MicrosoftWindowsServer"
    offer     = "WindowsServer"
    sku       = "2016-Datacenter"
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
  description = "Must be either Windows_Client, Windows_Server, none"
  default     = "none"
  validation {
    condition     = contains(["Windows_Client", "Windows_Server", "none"], var.license_type)
    error_message = "Must be either Windows_Client, Windows_Server, none"
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
  /*validation {
    condition     = can(regex("^[a-zA-Z\\-\\_0-9]{16,}$", var.vm_admin_password)) || var.vm_admin_password == null
    error_message = "Muss mindestens 16 Zeichen, eine Buchstabe, eine Zahl und ein Sonderzeichen enhalten."
  }*/
  validation {
    condition     = length(var.vm_admin_password) >= 16
    error_message = "Passwort Muss min 16 Zeichen."
  }

  validation {
    condition     = can(regex("[A-Z]", var.vm_admin_password))
    error_message = "Passwort Muss min eine Großbuchstabe enthalten."
  }

  validation {
    condition     = can(regex("[a-z]", var.vm_admin_password))
    error_message = "Passwort Muss min eine Kleinbuchstabe enthalten."
  }

  validation {
    condition     = can(regex("[^a-zA-Z0-9]", var.vm_admin_password))
    error_message = "Das Passwort muss mindestens ein Zeichen enthalten, das weder ein Buchstabe noch eine Ziffer ist."
  }

  validation {
    condition     = can(regex("[0-9]", var.vm_admin_password))
    error_message = "Das Passwort muss mindestens eine Ziffer enthalten."
  }
}

variable "identity_ids" {
  description = "Identity IDs"
  type        = list(string)
  default     = null
}

variable "commands_to_execute" {
  description = "Execute command post deployment"
  type        = map(string)
  default     = {}
}

variable "enable_automatic_updates" {
  type    = bool
  default = true
}
