
variable "aks_cluster" {
  description = "AKS Cluster"
  default     = null
  type = object({
    name                  = string
    server                = string
    ca_certificate_base64 = string
    tls_server_name       = optional(string, null)
    }
  )
}

variable "projects" {
  description = "Projects that should be deployed via ArgoCD. Use Gitlab repository id as key of map objects."
  type = map(object({
    repository = string
    branch     = string
  }))
  default = {
  }
}

variable "dns_zone_name" {
  description = "DNS Zone Name for ingresses"
  type    = string
  default = ""
}



variable "bootstrap" {
  description = "Bootstrap of cluster. 'none' disables bootstrapping. 'stable' uses main branch and 'dev' uses develop branch of bootstrap repo."
  type        = string
  default     = "stable"
  validation {
    condition = (
      contains(["stable", "dev", "none"], var.bootstrap)
    )
    error_message = "Must be either stable, dev or none"
  }
}
