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

variable "address_space" {
  description = "Virtual network address space"
  type        = string
}

variable "dns_server" {
  description = "DNS Server"
  default     = []
  type        = list(string)
}

variable "vnet_instance" {
  description = "Die Instanz-ID für das virtuelle Netwerk."
  default     = 1
  type        = number
}

variable "resource_group_name" {
  description = "Resource group name to create the network in"
  type        = string
}

variable "tags" {
  description = "Tags for the deployment"
  type        = map(any)
}


variable "private_dns_zones" {
  description = "Private DNS Zones"
  type = map(object({
    name                     = string
    resource_group_name      = string
    network_link_instance_id = number
  }))
  default = {}
}

variable "network_peering" {
  type = map(object({
    instance                = string
    remote_vnet_id          = string
    allow_forwarded_traffic = bool
  }))
  default = {}

}
