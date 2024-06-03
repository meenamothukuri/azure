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

variable "subnet_instance" {
  description = "Die Instanz-ID für das Subnetz."
  default     = 1
  type        = number
}

variable "vnet_name" {
  description = "Network name of the subnet"
  type        = string
}

variable "address_prefix" {
  description = "Prefix to use for subnet"
  type        = string
}

variable "resource_group_name" {
  description = "Resource group of the network"
  type        = string
}
variable "associated_route_table" {
  description = "Route table to associate with subnet"
  default     = null
  type = object({
    name                = string
    resource_group_name = string
  })
}
variable "service_endpoints" {
  description = "The list of Service endpoints to associate with the subnet. Possible values include: Microsoft.AzureActiveDirectory, Microsoft.AzureCosmosDB, Microsoft.ContainerRegistry, Microsoft.EventHub, Microsoft.KeyVault, Microsoft.ServiceBus, Microsoft.Sql, Microsoft.Storage, and Microsoft.Web"
  default     = ["Microsoft.Storage", "Microsoft.ContainerRegistry"]
  type        = list(string)
}

variable "private_link_service_network_policies_enabled" {
  description = "Enable or Disable network policies for the private link service on the subnet"
  default     = true
  type        = bool
}

variable "private_endpoint_network_policies_enabled" {
  description = "Enable or Disable network policies for the private endpoints on the subnet"
  default     = true
  type        = bool
}

variable "nat_gateway" {
  description = "NAT Gateway association"
  default     = null
  type = object({
    name                = string
    resource_group_name = string
  })
}

variable "bastion_host_subnet" {
  default = false
  type    = bool
}
