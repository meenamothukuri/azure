variable "global_stage" {
  description = "Staging Umgebung"
  type        = string
  validation {
    condition     = contains(["dev", "tst", "prd", "qas", "sbx"], var.global_stage)
    error_message = "Must be either dev, tst, qas, sbx or prd"
  }
}

variable "materna_cost_center" {
  type        = string
  description = "Materna cost center"
}

variable "domain_name" {
  description = "Domain name to use"
  type        = string
  default     = null
}

variable "tags" {
  description = "Tags for the deployment"
  type        = map(any)
}

variable "resource_group_name" {
  description = "Resource group name to create the dns zone in"
  type        = string
}

variable "external_dns_service_principal_name" {
  description = "Name of the external dns sp"
  type        = string
  default     = null
}

variable "dns_a_records" {
  type = map(object({
    name    = string
    ttl     = optional(number, 900)
    records = list(string)
    })
  )
  default = {}
}

variable "dns_ns_records" {
  type = map(object({
    name    = string
    ttl     = optional(number, 900)
    records = list(string)
    })
  )
  default = {}
}
