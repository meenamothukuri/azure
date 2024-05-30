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

variable "application_gateway_instance" {
  description = "Die Instanz-ID für das Application Gateway."
  default     = 1
  type        = number
}

variable "resource_group_name" {
  description = "Resource group name to create the agw in"
  type        = string
}

variable "tags" {
  description = "Tags for the deployment"
  type        = map(any)
}

variable "frontend_port" {
  type        = number
  description = "Port of frontend"
  default     = 80
}

variable "public_ip_name" {
  type        = string
  description = "Name of public ip. Setting it to null disables the public frontend. At least one of 'public_ip_name' and 'private_endpoint' must be set."
}

variable "subnet" {
  description = "Gateway subnet parameters."
  type = object({
    name                        = string
    network_name                = string
    network_resource_group_name = string
  })
}

# https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/application_gateway#sku
variable "sku" {
  description = "Sku Parameters. Can also be used to enable/disable the firewall. In case of name='WAF_v2' the corresponding firewall policy will created - otherwise not."
  type = object({
    capacity = optional(number, 2)
    name     = optional(string, "WAF_v2")
    tier     = optional(string, "WAF_v2")
  })
  default = {}
}

variable "agic_service_principal_name" {
  description = "Service principal that has Reader rights to the resource group of the application gateway and Contributor right to the application gateway"
  type        = string
  default     = null
}

variable "enable_agic_network_role_assignment" {
  type    = bool
  default = true
}

variable "waf_owasp_exclusions" {
  type = map(object({
    rule_group_name = string
    rule_ids        = list(string)
  }))
  default = {}
}

variable "private_endpoint" {
  description = "Private endpoint parameters. At least one of 'public_ip_name' and 'private_endpoint' must be set."
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
  default = null
}

variable "create_updatable_agw" {
  default = false # In den meisten Fällen soll TF das AGW nicht konfigurieren. AGIC übernimmt dies. Nur sinnig in Verbindung mit 'backend_config'
  type    = bool
}

variable "ssl_certificate_config" {
  type = object({
    email_address   = string
    type            = string # "prod, staging"
    pre_check_delay = optional(number, 0)
    dns_zone = object({
      name                       = string
      resource_group_name        = string
      subscription_id            = string
      dns_service_principal_name = string
      }
    )
  })
  default = null
}

variable "backend_config" {
  type = map(object({
    ip_addresses          = optional(list(string), null) # One of 'ip_addresses' and 'fqdns' must be set
    fqdns                 = optional(list(string), null) # One of 'ip_addresses' and 'fqdns' must be set
    port                  = number
    hostname              = string
    cookie_based_affinity = optional(bool, false)
    path                  = optional(string, "/")
    request_timeout       = optional(number, 30)
    health_check_path     = optional(string)
    priority              = optional(number, 20000) # 1 (highest) - 20000 (lowest)
  }))
  default = null
}

variable "waf_restrict_for_ips" {
  description = "Only allow these specific IP addresses for access"
  type        = list(string)
  default     = null
}

variable "waf_enable_request_body_check" {
  description = "Enable request body check"
  type        = bool
  default     = true
}

variable "waf_enable_prevention_mode" {
  description = "Switch from prevention to detection mode"
  type        = bool
  default     = true
}

variable "waf_enable_max_request_body_size" {
  description = "Limit request body size"
  type        = bool
  default     = true
}


variable "enable_http2" {
  description = "Enable HTTP2"
  type        = bool
  default     = false
}


variable "waf_custom_rules" {
  description = "WAF custom rules"
  type = map(object({
    enabled   = bool
    rule_name = string
    priority  = number
    rule_type = string
    match_conditions = map(object({
      match_variables = map(object({
        variable_name = string
        selector      = optional(string, null)
      }))
      match_values       = list(string)
      operator           = string
      negation_condition = bool
      transforms         = optional(list(string), null)
    }))
    action               = string
    rate_limit_duration  = optional(string, null) #Specifies the duration at which the rate limit policy will be applied. Should be used with RateLimitRule rule type. Possible values are FiveMins and OneMin.
    rate_limit_threshold = optional(number, null) #Specifies the threshold value for the rate limit policy. Must be greater than or equal to 1 if provided.
    group_rate_limit_by  = optional(string, null) #Specifies what grouping the rate limit will count requests by. Possible values are GeoLocation, ClientAddr and None.
  }))
  default = null
}
