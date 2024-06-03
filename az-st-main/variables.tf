variable "global_subscription_id" {
  type    = string
  default = ""
  validation {
    condition     = can(regex("^[[:alnum:]]{8}-[[:alnum:]]{4}-[[:alnum:]]{4}-[[:alnum:]]{4}-[[:alnum:]]{12}$", var.global_subscription_id))
    error_message = "Must be an valid Subscription-ID."
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


variable "materna_project_number" {
  type        = string
  description = "Materna internal project nummer"
}

variable "materna_cost_center" {
  type        = string
  description = "Materna cost center"
}

variable "storage_account_instance" {
  description = "Die Instanz-ID für den Storage Account"
  default     = 1
  type        = number
}

variable "account_tier" {
  description = "Defines the Tier to use for this storage account. Valid options are Standard and Premium. For BlockBlobStorage and FileStorage accounts only Premium is valid."
  default     = "Standard"
  type        = string
}

variable "account_replication_type" {
  description = "Defines the type of replication to use for this storage account. Valid options are LRS, GRS, RAGRS, ZRS, GZRS and RAGZRS"
  default     = "LRS"
  type        = string
}

variable "resource_group_name" {
  description = "Resource group name to create the disk access in"
  type        = string
}

variable "tags" {
  description = "Tags for the deployment"
  type        = map(any)
}

variable "public_network_access_enabled" {
  description = "Enable public network access"
  default     = false
  type        = bool
}

variable "private_endpoint_file" {
  description = "Private endpoint parameters for storage account file"
  type = object({
    instance = number
    custom_config = optional(object({
      resource_group_name = string
      subnet = object({
        name                        = string
        network_name                = string
        network_resource_group_name = string
      })
    }), null)
    custom_private_dns_zone = optional(object({
      resource_group_name = string
    }), null)
    }
  )
}

variable "private_endpoint_blob" {
  description = "Private endpoint parameters for storage account blob"
  type = object({
    instance = number
    custom_config = optional(object({
      resource_group_name = string
      subnet = object({
        name                        = string
        network_name                = string
        network_resource_group_name = string
      })
    }), null)
    custom_private_dns_zone = optional(object({
      resource_group_name = string
    }), null)
    }
  )
}

