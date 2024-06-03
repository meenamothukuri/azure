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

variable "sql_instance" {
  description = "Die Instanz-ID die Route Tabelle"
  default     = 1
  type        = number
}

variable "resource_group_name" {
  description = "Resource group name to create database in"
  type        = string
}

variable "tags" {
  description = "Tags for the deployment"
  type        = map(any)
}

variable "sql_server" {
  description = "SQL server config"
  type = object({
    version                              = string
    admin_username                       = string
    admin_password                       = string
    min_tls_version                      = optional(string, "1.2")
    public_network_access_enabled        = optional(string, false)
    outbound_network_restriction_enabled = optional(string, false)
  })
}

variable "sql_databases" {
  description = "SQL databases to create on SQL server"
  type = map(object({
    custom_name = optional(string, null)
    short_term_retention_policy = optional(object({
      retention_days           = optional(number, 7)  # Between 7 and 35
      backup_interval_in_hours = optional(number, 12) # 12 or 24
    }), null)
    long_term_retention_policy = optional(object({
      weekly_retention  = optional(string, null) # ISO 8601 Format - z.B. P1Y, P1M, P1W, P7D (Between 1-520 weeks)
      monthly_retention = optional(string, null) # ISO 8601 Format - z.B. P1Y, P1M, P4W, P30D (Between 1-120 month)
      yearly_retention  = optional(string, null) # ISO 8601 Format - z.B. P1Y, P12M, P52W, P365D (Between 1-10 years)
      week_of_year      = optional(number, null) # Week of year for yearly backup (1-52)
    }), null)
    storage_account_type           = optional(string, "Local") # Used to store backups - Geo, Local, Zone
    sku_name                       = optional(string, "GP_S_Gen5_1")
    restore_dropped_database_id    = optional(string, null) # Only applicable when 'create_mode' = 'Restore'
    recover_database_id            = optional(string, null) # Only applicable when 'create_mode' = 'Recovery'
    restore_point_in_time          = optional(string, null) # ISO 8601 Point in Time - Only applicable when 'create_mode' = 'PointInTimeRestore'
    min_capacity                   = optional(number, 0.5)
    max_size_gb                    = optional(number, 100)
    license_type                   = optional(string, null) # LicenseIncluded or BasePrice - null for serverless
    ledger_enabled                 = optional(bool, false)
    maintenance_configuration_name = optional(string, "SQL_WestEurope_DB_2")
    collation                      = optional(string, "SQL_Latin1_General_CP1_CS_AS")
    creation_source_database_id    = optional(string, null)      # Source db from which to create the new db
    create_mode                    = optional(string, "Default") # Copy, Default, OnlineSecondary, PointInTimeRestore, Recovery, Restore, RestoreLongTermRetentionBackup
    auto_pause_delay_in_minutes    = optional(number, 60)        # Only for serverless; -1 disables automatic pause
  }))
  default = {}
}

variable "private_endpoint" {
  description = "Private endpoint parameters"
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

