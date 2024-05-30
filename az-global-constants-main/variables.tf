variable "global_hyperscaler" {
  description = "Kennzeichen für den Hyperscaler"
  type        = string
  validation {
    condition     = contains(["az", "dl"], var.global_hyperscaler)
    error_message = "Must be either az or dl"
  }
}

variable "private_dns_zone" {
  description = "Private dns zone parameters"
  default     = null
  type = object({
    resource_group_name = optional(string, null)
    aks = optional(object({
      id = string
    }), null)
    }
  )
}

variable "private_endpoint" {
  description = "Private endpoint parameters"
  default     = null
  type = object({
    resource_group_name = string
    subnet = object({
      name                        = string
      network_name                = string
      network_resource_group_name = string
      }
    )
    }
  )
}
