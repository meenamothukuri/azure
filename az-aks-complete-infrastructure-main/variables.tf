##### Global Settings

variable "global_subscription_id" {
  type = string
  validation {
    condition     = can(regex("^[[:alnum:]]{8}-[[:alnum:]]{4}-[[:alnum:]]{4}-[[:alnum:]]{4}-[[:alnum:]]{12}$", var.global_subscription_id))
    error_message = "Must be an valid Subscription-ID."
  }
}
variable "global_tenant_id" {
  type = string
}

variable "global_instance_id" {
  type = number
}
variable "dns_zone" {
  description = "DNS Zone"
  type = object({
    create      = optional(bool, true)
    custom_name = optional(string, null)
    }
  )
  default = {}
}
##### Project Specific Variables
variable "materna_project_number" {
  type = string
}

variable "materna_cost_center" {
  type        = string
  description = "Materna cost center"
}

variable "materna_customer_name" {
  description = "Name of the customer (max. 3 characters)."
  type        = string
  validation {
    condition     = can(regex("^[a-z0-9]{3}$", var.materna_customer_name))
    error_message = "Muss ein Kundenkürzel sein (max. 3 Zeichen)."
  }
}
variable "custom_agic_service_principal_name" {
  type    = string
  default = null
}

##### ArgoCD Settings

variable "argocd_host" {
  description = "Hostname to use for ArgoCD Provider"
  type        = string
}

variable "argocd_username" {
  description = "Username to use for ArgoCD Provider"
  type        = string
}

variable "argocd_password" {
  description = "Password to use for ArgoCD Provider"
  type        = string
  sensitive   = true
}

### AGW Vars
variable "agw_address_prefix" {
  type = string
}

variable "agw_enable_private_frontend" {
  description = "At least one of 'agw_enable_private_frontend' and 'agw_enable_public_frontend' must be set to true."
  type        = bool
  default     = false
}

variable "agw_enable_public_frontend" {
  description = "At least one of 'agw_enable_private_frontend' and 'agw_enable_public_frontend' must be set to true."
  type        = bool
  default     = true
}

variable "agw_routes" {
  type = map(object({
    address_prefix         = string
    next_hop_type          = string
    next_hop_in_ip_address = string
  }))

  default = {}
}

variable "agw_sku" {
  description = "AGW Sku Parameters"
  type = object({
    capacity = optional(number, 2)
    name     = optional(string, "WAF_v2")
    tier     = optional(string, "WAF_v2")
  })
  default = {}
}


# variable "waf_owasp_exclusions" {
#   type = object({
#     type = any 
#   })
# }

### AKS Vars
variable "aks_stage" {
  description = "Staging Umgebung"
  type        = string
  validation {
    condition     = contains(["dev", "tst", "prd", "qas", "sbx"], var.aks_stage)
    error_message = "Must be either dev, tst, qas, sbx or prd"
  }
}

variable "aks_k8s_version" {
  description = "Kubernetes Version"
  type        = string
}

variable "aks_pod_cidr" {
  type    = string
  default = ""
}

variable "aks_cluster_admins" {
  type = list(string)
}

variable "aks_private_dns_zone_id" {
  default = null
  type    = string
}

variable "aks_sku_tier" {
  description = "The SKU Tier that should be used for this Kubernetes Cluster. Possible values are Free, Standard (which includes the Uptime SLA) and Premium."
  type        = string
  default     = "Standard"
  validation {
    condition     = contains(["Free", "Standard", "Premium"], var.aks_sku_tier)
    error_message = "Must be either Free, Standard or Premium"
  }
}

variable "aks_system_node_pool" {
  type = object({
    name_prefix    = string
    address_prefix = string

    node_pool_config = map(any)
  })
}

variable "aks_additional_app_node_pools" {
  type = map(object({
    # metadata
    name_prefix       = optional(string, "")
    subnet_cidr       = string
    nodepool_instance = number

    # Nodepool - Konfiguration
    node_pool_config = map(any)
    })
  )
  # validation {
  #   condition = can(
  #     alltrue([for key, value in var.additional_app_node_pools : regex("^((25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?).){3}(25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)(/(3[0-2]|2[0-9]|1[0-9]|[0-9]))?$", value.subnet_cidr)]) &&
  #     alltrue([for key, value in var.additional_app_node_pools : regex("^[[:alnum:]]{0,7}$", "${key}")]) &&
  #     alltrue([for key, value in var.additional_app_node_pools : regex("^[[:alnum:]]{0,7}$", value.name_prefix)])
  #     )
  #   error_message = "Object name can only be 0-7 Characters long ; name_prefix can only be 0-7 Characters long ; Subnet CIDR has to be in a Valid Format (XXX.XXX.XXX.XXX/XX)"
  # }
}

### Bestehendes VNET
variable "custom_sbs_vnet" {
  description = "Provided Virtual Network"
  type = object({
    rg_name   = string
    vnet_name = string
  })
  default = null
}


variable "custom_key_vault" {
  description = "Key Vault parameters"
  type = object({
    name                = string
    resource_group_name = string

    key_vault_key = object({
      name = string
    })
  })
  default = null
}

variable "custom_private_endpoint_config" {
  type = object({
    resource_group_name = string
    subnet = object({
      name                        = string
      network_name                = string
      network_resource_group_name = string
    })
  })
  default = null
}

variable "custom_disk_encryption_set" {
  type = object({
    name                = string
    resource_group_name = string
  })
  default = null
}

variable "aks_public_host" {
  description = "Host to use for ArgoCD in case of separate networks"
  type        = string
  default     = null
}

variable "aks_agic_version" {
  description = "AGIC Helm version"
  type        = string
  default     = "1.7.2"
}

variable "aks_taint_system_node_pool" {
  default = true
  type    = bool
}

variable "aks_automatic_upgrade" {
  default = null
  type    = string
  validation {
    condition = (
      var.aks_automatic_upgrade == null ? true : (
        contains(["patch", "rapid", "node-image", "stable"], var.aks_automatic_upgrade)
      )
    )
    error_message = "Must be either patch, rapid, node-image or stable"
  }
}



variable "tags" {
  type = map(any)
}

variable "materna_sbs_name" {
  type = string
}

variable "argocd_external_connection" {
  description = "Is the connection established over the internet"
  type        = bool
  default     = false
}

variable "argocd_projects" {
  description = "Projects that should be deployed"
  type = map(object({
    repository = string
    branch     = string
  }))
  default = {
  }
}

variable "argocd_bootstrap" {
  description = "Bootstrap of cluster. 'none' disables bootstrapping."
  type        = string
  default     = "stable"
  validation {
    condition = (
      contains(["stable", "dev", "none"], var.argocd_bootstrap)
    )
    error_message = "Must be either stable, dev or none"
  }
}

variable "argocd_enable" {
  description = "Register cluster on ArgoCD or not"
  type        = bool
  default     = true
}

variable "use_deprecated_vnet_naming" {
  description = "Vnet naming has changed: https://dev.azure.com/MaternaGroup/Azure-Aufbau/_git/repo-hub-mat-group/commit/6e2910f42c37e994d0f90a6f19f4858f81bb0bb3?refName=refs%2Fheads%2Fmain&path=%2Fmodules%2Finit%2F05_connectivity.tf&_a=compare"
  type        = bool
  default     = false
}

variable "set_agic_sp_network_role_assignment" {
  type    = bool
  default = true
}


variable "agw_waf_owasp_exclusions" {
  description = "Firewall exclusions"
  type = map(object({
    rule_group_name = string
    rule_ids        = list(string)
  }))
  default = {}
}

variable "hashicorp_vault" {
  description = "Hashicorp Vault parameters"
  type = object({
    service_principal_name = string
  })
  default = null
}

variable "aks_storage_account_usage" {
  default = false
  type    = bool
}
variable "aks_create_nginx" {
  description = "create nginx controller"
  default     = false
  type        = bool
}
variable "aks_nginx_version" {
  description = "NGINX Helm chart version"
  default     = "4.8.3"
  type        = string
}

variable "agw_enable" {
  description = "enable agw"
  default     = true
  type        = bool
}

variable "agw_waf_enable_request_body_check" {
  description = "Enable request body check"
  type        = bool
  default     = true
}

variable "agw_waf_enable_max_request_body_size" {
  description = "Limit request body size"
  type        = bool
  default     = true
}

variable "agw_waf_enable_prevention_mode" {
  description = "Switch from prevention to detection mode"
  type        = bool
  default     = true
}

variable "agw_waf_custom_rules" {
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

variable "cluster_init_enable" {
  description = "Init cluster with ArgoCD, Vault, etc"
  default     = false
  type        = bool
}

variable "cluster_init_bootstrap_applications" {
  type = object({
    certmanager = optional(object({
      enable = optional(bool, true)
    }), {})
    cronjobs = optional(object({
      enable = optional(bool, true)
    }), {})
    externaldns = optional(object({
      enable = optional(bool, true)
    }), {})
    fluentbit = optional(object({
      enable = optional(bool, true)
    }), {})
    grafana = optional(object({
      enable = optional(bool, true)
      oauth = optional(object({
        client_id     = optional(string, "")
        client_secret = optional(string, "")
      }), {})
      users = optional(object({
        admin = optional(object({
          password = optional(string, "")
        }), {})
      }), {})
    }), {})
    kanister = optional(object({
      enable = optional(bool, true)
    }), {})
    kubeprometheusstack = optional(object({
      enable = optional(bool, true)
      basic_auth = optional(object({
        password = optional(string, "")
      }), {})
    }), {})
    kyvernopolicies = optional(object({
      enable = optional(bool, true)
    }), {})
    kyverno = optional(object({
      enable = optional(bool, true)
    }), {})
    loki = optional(object({
      enable = optional(bool, true)
    }), {})
    minio = optional(object({
      enable = optional(bool, true)
      oauth = optional(object({
        client_id     = optional(string, "")
        client_secret = optional(string, "")
      }), {})
      users = optional(object({
        root = optional(object({
          password = optional(string, "")
        }), {})
        tempo = optional(object({
          password = optional(string, "")
        }), {})
        loki = optional(object({
          password = optional(string, "")
        }), {})
      }), {})
    }), {})
    networkpolicies = optional(object({
      enable = optional(bool, true)
    }), {})
    opentelemetrycollectoragent = optional(object({
      enable = optional(bool, true)
    }), {})
    opentelemetrycollectorgateway = optional(object({
      enable = optional(bool, true)
    }), {})
    prometheus = optional(object({
      enable = optional(bool, true)
      basic_auth = optional(object({
        password = optional(string, "")
      }), {})
    }), {})
    tempo = optional(object({
      enable = optional(bool, true)
    }), {})
    trivyoperator = optional(object({
      enable = optional(bool, true)
    }), {})
    velero = optional(object({
      enable = optional(bool, true)
    }), {})
  })
  default = {}
}

variable "cluster_init_enable_keycloak_integration" {
  description = "Enable bootstrap Keycloak integration"
  default     = true
  type        = bool
}

variable "cluster_init_keycloak_url" {
  type = string
}

variable "cluster_init_keycloak_realm" {
  type = string
}
