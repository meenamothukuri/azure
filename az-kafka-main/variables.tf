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

variable "tags" {
  description = "Tags for the deployment"
  type        = map(any)
}

variable "kafka_cluster_instance" {
  description = "Die Instanz-ID für das Kafka Cluster."
  default     = 1
  type        = number
}

variable "kafka_cluster_storage_account_instance" {
  description = "Die Instanz-ID für den Storage Account des Kafka Clusters."
  default     = 1
  type        = number
}

variable "kafka_cluster_private_endpoint_storage_account_blob_instance" {
  description = "Instance for storage account private endpoint"
  default     = 1
  type        = number
}


variable "kafka_cluster_private_endpoint_storage_account_file_instance" {
  description = "Instance for storage account private endpoint"
  default     = 2
  type        = number
}

variable "kafka_cluster_worker_node_vm_size" {
  description = "VM size of worker nodes"
  default     = "Standard_A2m_V2" # 2 Cores, 3 Instances -> 6 Cores
  type        = string
}

variable "kafka_cluster_worker_node_number_of_disks" {
  description = "Number of disks per worker node"
  default     = 1
  type        = number
}

variable "kafka_cluster_worker_node_instances" {
  description = "Number worker node instances"
  default     = 3
  type        = number
}

variable "kafka_cluster_head_node_vm_size" {
  description = "VM size of head nodes"
  default     = "Standard_E2_V3" # 2 Cores, 2 Instanzen -> 4 Cores
  type        = string
}

variable "kafka_cluster_zookeeper_node_vm_size" {
  description = "VM size of Zookeeper nodes"
  default     = "Standard_A1_V2" # 1 Cores, 3 Instanzen -> 3 Cores
  type        = string
}

variable "kafka_cluster_component_version" {
  description = "Kafka version"
  default     = "2.4"
  type        = string
}

variable "kafka_cluster_version" {
  description = "HDInsight Cluster version"
  default     = "5.0"
  type        = string
}

variable "kafka_cluster_tier" {
  description = "HDInsight Cluster version"
  default     = "Standard"
  type        = string
  validation {
    condition     = contains(["Standard", "Premium"], var.kafka_cluster_tier)
    error_message = "Must be either Standard or Premium"
  }
}

variable "subnet" {
  description = "Subnet parameters"
  type = object({
    name                        = string
    network_name                = string
    network_resource_group_name = string
  })
}

variable "resource_group_name" {
  description = "Resource group of the Kafka cluster"
  type        = string
}

variable "kafka_security_group_instance" {
  description = "Instance number for Kafka security group"
  type        = number
  default     = 1
}


variable "private_endpoint_gateway" {
  description = "Private endpoint parameters for Kafka Ambari endpoint"
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

variable "private_endpoint_headnode" {
  description = "Private endpoint parameters for Kafka SSH access"
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
