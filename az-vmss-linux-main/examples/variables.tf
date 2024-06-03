variable "ARM_SUBSCRIPTION_ID" {
  type = string
  validation {
    condition     = can(regex("^[[:alnum:]]{8}-[[:alnum:]]{4}-[[:alnum:]]{4}-[[:alnum:]]{4}-[[:alnum:]]{12}$", var.ARM_SUBSCRIPTION_ID))
    error_message = "Must be an valid Subscription-ID."
  }
}

variable "ARM_TENANT_ID" {
  type = string
}

variable "global_stage" {
  description = "Staging Umgebung"
  type        = string
  validation {
    condition     = contains(["dev", "tst", "prd", "qas", "sbx"], var.global_stage)
    error_message = "Must be either dev, tst, qas, sbx or prd"
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

variable "global_hyperscaler_location_long" {
  type        = string
  description = "Kennzeichen für den Hyperscaler Region"
}

variable "materna_project_number" {
  type        = string
  description = "Materna project number"
}

variable "materna_cost_center" {
  type        = string
  description = "Materna cost center"
}

variable "materna_customer_name" {
  description = "Name of the customer (max. 5 characters)."
  type        = string
  validation {
    condition     = can(regex("^[a-z0-9]{3}$", var.materna_customer_name))
    error_message = "Muss ein Kundenkürzel sein (max. 3 Zeichen)."
  }
}

variable "tags" {
  description = "Tags for the deployment"
  type        = map(any)
}

variable "network" {
  type = object({
    name                = string
    resource_group_name = string
  })
}

variable "subnet_address_prefix" {
  type        = string
  description = "Subnet prefix"
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

/* variable "ACCESS_REGISTERY_MILAD" {
  description = "Token"
}
 */

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