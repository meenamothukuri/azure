variable "global_subscription_id" {
  type    = string
  default = ""
  validation {
    condition     = can(regex("^[[:alnum:]]{8}-[[:alnum:]]{4}-[[:alnum:]]{4}-[[:alnum:]]{4}-[[:alnum:]]{12}$", var.global_subscription_id))
    error_message = "Must be an valid Subscription-ID."
  }
}

variable "global_tenant_id" {
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

variable "aks_instance_id" {
  description = "Internal deployment number for resource group."
  type        = number
  default     = 1
}

variable "aks_resourcegroup_name" {
  description = "Name of the ResourceGroup to use."
  type        = string
}

variable "aks_kubernetes_version" {
  description = "Version of Kubernetes, if a fixed version should deployed"
  default     = null
  type        = string
}

variable "resource_group_location" {
  description = "The location for the AKS Cluster."
  default     = "GermanyWestCentral"
  type        = string
}

variable "aks_cluster_admins" {
  description = "Display Name of the Activce Directory Group unsed for Kubernetes Cluster Admins."
  type        = list(string)
  default     = []
}

variable "cluster_dns_prefix" {
  type        = string
  description = "DNS prefix in kubernets cluster."
  default     = "k8s"
}

variable "tags" {
  description = "Tags for the deployment"
  type        = map(any)
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

variable "aks_pod_cidr" {
  description = "Cidr block for pods"
  default     = "10.244.0.0/16"
  type        = string
}

variable "aks_local_account_disabled" {
  description = "Local accounts will be disabled. Possible values are true or [false]"
  type        = bool
  default     = false
}

variable "aks_azure_policy_enabled" {
  description = "Enable azure aks policy. https://learn.microsoft.com/en-ie/azure/governance/policy/concepts/policy-for-kubernetes"
  type        = bool
  default     = false
}

variable "system_node_pool" {
  description = "System node pool parameters"
  default     = null
  type = object({
    type                 = optional(string, "VirtualMachineScaleSets") # [AvailabilitySet | VirtualMachineScaleSets]
    orchestrator_version = optional(string, null)
    ultra_ssd_enabled    = optional(bool, false)
    node_count           = optional(number, 3)
    node_min_count       = optional(number, 3)
    node_max_count       = optional(number, 10)
    enable_auto_scaling  = optional(bool, false)
    os_disk_type         = optional(string, "Managed") # [Ephemeral | Managed]
    os_disk_size_gb      = optional(number)
    vm_size              = optional(string, "Standard_B2s")
    max_pods             = optional(number, 40)
    name_extension       = optional(string, "system")
    enable_public_ip     = optional(bool, false)
    subnet = object({
      name                        = string
      network_name                = string
      network_resource_group_name = string
    })
  })
}

variable "additional_node_pools" {
  description = "Additional node pools"
  default     = {}
  type = map(object({
    vm_size                = optional(string, "Standard_B2s")
    node_count             = optional(number, 1)
    max_pods               = optional(number, 40)
    enable_auto_scaling    = optional(bool, false)
    node_min_count         = optional(number, null)
    node_max_count         = optional(number, null)
    scale_down_mode        = optional(string, "Delete") # Delete | Deallocate
    enable_host_encryption = optional(bool, false)
    kubelet_disk_type      = optional(string, "OS")     # OS | Temporary --- Failure for 'Temporary': Preview feature Microsoft.ContainerService/KubeletDisk not registered.
    mode                   = optional(string, "User")   # System | User
    node_taints            = optional(list(string), []) # e.g. key=value:NoSchedule
    node_labels            = optional(map(string), {})
    orchestrator_version   = optional(string, null)
    os_disk_size_gb        = optional(number)
    os_disk_type           = optional(string, "Managed") # Ephemeral | Managed
    ultra_ssd_enabled      = optional(bool, false)
    subnet = object({
      name                        = string
      network_name                = string
      network_resource_group_name = string
    })
    kubelet_config = optional(object({
      allowed_unsafe_sysctls    = optional(list(string), [])
      container_log_max_line    = optional(number, null) # > 2
      container_log_max_size_mb = optional(number, null)
      cpu_cfs_quota_enabled     = optional(bool, null)
      cpu_cfs_quota_period      = optional(string, null)
      cpu_manager_policy        = optional(string, null) # none | static
      image_gc_high_threshold   = optional(number, null) # 0-100
      image_gc_low_threshold    = optional(number, null) # 0-100
      pod_max_pid               = optional(number, null)
      topology_manager_policy   = optional(string, null) # none | best-effort | restricted | single-numa-node
      }), {}
    )
  }))
}

variable "resource_group_kubernetes_nodes_instance" {
  description = "Instance of resource group which Kubernetes will create"
  default     = 2
  type        = string
}

variable "resource_group_kubernetes_nodes_materna_project_number" {
  description = "Define separate project number for Kubernetes node resource group"
  default     = null
  type        = string
}

variable "route_table_id" {
  description = "Route table id of subnet"
  type        = string
}

variable "agic_service_principal_name" {
  description = "Service principal that has Reader rights to the resource group of the application gateway and Contributor right to the application gateway"
  type        = string
}

variable "container_registry" {
  description = "Container registry to connect AKS cluster to"
  default     = null
  type = object({
    name                = string
    resource_group_name = string
    }
  )
}

variable "application_gateway" {
  description = "Application Gateway parameters for agic"
  type = object({
    name                = string
    resource_group_name = string
    subscription_id     = string
    shared              = optional(bool, true)
    private             = optional(bool, false)
    }
  )
}

variable "encryption" {
  description = "Encryption parameters"
  default     = null
  type = object({
    disk_encryption_set = object({
      name                = string
      resource_group_name = string
    })
    }
  )
}

variable "create_nginx" {
  description = "create nginx controller"
  default     = false
  type        = bool
}
variable "nginx_version" {
  description = "NGINX Helm chart version"
  default     = "4.8.3"
  type        = string
}

variable "install_agic" {
  description = "Apply Helm Chart for agic"
  default     = true
  type        = bool
}

variable "agic_version" {
  description = "AGIC Helm chart version"
  default     = "1.7.2"
  type        = string
}

variable "dns_zone" {
  description = "DNS Zone"
  default     = null
  type = object({
    resource_group_name                 = string
    subscription_id                     = string
    external_dns_service_principal_name = string
    }
  )
}

variable "enable_network_policy" {
  default = true
  type    = bool
}

variable "create_breakglass_account" {
  description = "Breakglass-Konto erstellen"
  default     = true
  type        = bool
}

variable "private_dns_zone_id" {
  default = null
  type    = string
}

variable "aks_taint_system_node_pool" {
  description = "Taint nodes of system node pool so that user applications will start on app node pools and only bootstrap components start on system nodes."
  default     = true
  type        = bool
}

variable "aks_automatic_upgrade" {
  description = "Configure automatic upgrade of AKS cluster version. null disables automatic upgrades."
  default     = null
  type        = string
  validation {
    condition = (
      var.aks_automatic_upgrade == null ? true : (
        contains(["patch", "rapid", "node-image", "stable"], var.aks_automatic_upgrade)
      )
    )
    error_message = "Must be either patch, rapid, node-image or stable"
  }
}

variable "hashicorp_vault" {
  description = "Init Hashicorp Vault on cluster. If set, credentials are created and stored into K8s. Also a Key Vault key is generated."
  default     = null
  type = object({
    key_vault_resource_group_name = string
    key_vault_name                = string
    service_principal_name        = string
    }
  )
}

variable "create_secret_namespace" {
  default = true
  type    = bool
}


