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

variable "tags" {
  description = "Tags for the deployment"
  type        = map(any)
}


variable "storage_account_instance" {
  description = "Storage account instance"
  type        = number
  default     = 1
}

variable "aks" {
  description = "AKS cluster parameters"
  type = object({
    instance_id                 = number
    resource_group_name         = string
    user_assigned_identity_name = string
  })
}

variable "disk_access_endpoint" {
  description = "Endpoint for disk access endpoint"
  default     = null
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

variable "storage_account_endpoint" {
  description = "Endpoints for storage account file endpoint"
  default     = null
  type = object({
    file_instance = number
    blob_instance = number
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

variable "encryption" {
  description = "Encryption parameters"
  default     = null
  type = object({
    disk_encryption_set = object({
      name                = string
      resource_group_name = string
    })
    }
  )
}

variable "apply_kubernetes" {
  description = "Storage class definitions on Kubernetes"
  default     = true
  type        = bool
}

variable "enable_full_subscription_contributor_rights" {
  description = "Needed when role definitions cannot be created. Disk read,write,delete access is needed"
  default     = false
  type        = bool
}
