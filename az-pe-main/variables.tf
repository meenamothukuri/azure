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

variable "private_endpoint_instance" {
  description = "Die Instanz-ID für den privaten Endpoint"
  default     = 1
  type        = number
}


variable "resource_group_name" {
  description = "Resource group name to create the disk access in"
  type        = string
}

variable "tags" {
  description = "Tags for the deployment"
  type        = map(any)
}

variable "subnet" {
  description = "Subnet for the private endpoint"
  type = object({
    name                        = string
    network_name                = string
    network_resource_group_name = string
  })
}

variable "private_connection_resource_id" {
  description = "The ID of the Private Link Enabled Remote Resource which this Private Endpoint should be connected to"
  type        = string

}
variable "is_manual_connection" {
  description = "Does the Private Endpoint require Manual Approval from the remote resource owner? Changing this forces a new resource to be created."
  type        = bool

}
variable "subresource_names" {
  description = "A list of subresource names which the Private Endpoint is able to connect to"
  type        = list(string)
  default     = null
}

variable "private_dns_zone" {
  description = "Private DNS zone for endpoint"
  default     = null
  type = object({
    name                = string
    id                  = string
    resource_group_name = string
  })
}

variable "manual_private_dns_zone_entry" {
  description = "Needed when DNS config is not working for a specifig config. e.g. Kafka"
  default     = null
  type = object({
    name = string
  })
}
