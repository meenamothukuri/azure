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

variable "global_hyperscaler_location_long" {
  description = "Kennzeichen für den Hyperscaler Region"
  type        = string
  validation {
    condition     = contains(["germanywestcentral", "westeurope"], var.global_hyperscaler_location_long)
    error_message = "Muss eine definierte Hyperscaler Region sein."
  }
}

variable "tags" {
  description = "Tags for the deployment"
  type        = map(any)
}

variable "enable_aks_usage" {
  description = "Defines if private DNS zone should be able to be used in AKS cluster. Results in different domain name"
  type        = bool
  default     = true
}

variable "resource_group_name" {
  description = "Resource group name to create the network in"
  type        = string
}


variable "domain_name" {
  description = "Set the domain name"
  type        = string
  default     = null
}

variable "private_dns_zone_instance" {
  description = "Instance count of private DNS zone"
  type        = number
  default     = 1
}

variable "networks" {
  description = "Network associations"
  type = map(object({
    name                     = string
    resource_group_name      = string
    network_link_instance_id = number
  }))
  default = {}
}

variable "external_networks" {
  description = "External network associations"
  type = map(object({
    id                       = string
    network_link_instance_id = number
  }))
  default = {}
}

variable "pdns_a_records" {
  type = map(object({
    name    = string
    ttl     = optional(number, 900)
    records = list(string)
    })
  )
  default = {}
}
