variable "ARM_SUBSCRIPTION_ID" {
  type    = string
  default = ""
  validation {
    condition     = can(regex("^[[:alnum:]]{8}-[[:alnum:]]{4}-[[:alnum:]]{4}-[[:alnum:]]{4}-[[:alnum:]]{12}$", var.ARM_SUBSCRIPTION_ID))
    error_message = "Must be an valid Subscription-ID."
  }
}

variable "ARM_TENANT_ID" {
  type = string
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

variable "global_hyperscaler_location_long" {
  type        = string
  description = "Kennzeichen für den Hyperscaler Region"
}

variable "materna_project_number" {
  type        = string
  description = "Materna project number"
}

variable "materna_cost_center" {
  type        = string
  description = "Materna cost center"
}

variable "materna_customer_name" {
  description = "Name of the customer (max. 5 characters)."
  type        = string
  validation {
    condition     = can(regex("^[a-z0-9]{3}$", var.materna_customer_name))
    error_message = "Muss ein Kundenkürzel sein (max. 3 Zeichen)."
  }
}

variable "agic_service_principal_name" {
  type        = string
  description = "AGIC SP Name"
  default     = null
}

variable "subnet_agw_address_prefix" {
  type        = string
  description = "Subnet prefix"
}
variable "create_updatable_agw" {
  type        = bool
  description = "Create updatable agw"
}

variable "tags" {
  type = map(any)
}

variable "network" {
  type = object({
    name                = string
    resource_group_name = string
  })
}

variable "ssl_certificate_config" {
  type = object({
    email_address = string
    type          = string # "prod, staging"
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
