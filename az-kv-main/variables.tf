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

variable "global_tenant_id" {
  type = string
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

variable "tags" {
  description = "Tags for the deployment"
  type        = map(any)
}

variable "resource_group_name" {
  description = "Resource group name to create the key vault in"
  type        = string
}

variable "key_vault_instance" {
  description = "Die Instanz-ID des Key Vaults"
  default     = 1
  type        = number
}

variable "public_endpoint_enabled" {
  description = "Make Key Vault public available"
  type        = bool
  default     = false
}

variable "source_ip_filter" {
  description = "Source IP filter"
  type        = list(string)
  default     = null
}

variable "sku_tier" {
  description = "The SKU Tier that should be used."
  type        = string
  default     = "standard"
  validation {
    condition     = contains(["standard", "premium"], var.sku_tier)
    error_message = "Must be either standard or premium"
  }
}

variable "private_endpoint" {
  description = "Private endpoint parameters for key vault"
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

variable "hashicorp_vault" {
  description = "Grant access for Hashicorp Vault"
  default     = null
  type = object({
    service_principal_name = string
    }
  )
}
