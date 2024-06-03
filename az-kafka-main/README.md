<!-- BEGIN_TF_DOCS -->



### Examples

```hcl
module "resource_group_network" {
  #source = "git@gitlab.prd.materna.digital:components/terraform/azure/az-rg"
  source = "git@gitlab.prd.materna.work:components/terraform/azure/az-rg"

  global_subscription_id      = local.global_subscription_id
  global_stage                = local.global_stage
  global_hyperscaler          = local.global_hyperscaler
  global_hyperscaler_location = local.global_hyperscaler_location

  materna_customer_name  = local.materna_customer_name
  materna_project_number = local.materna_project_number
  materna_cost_center    = local.materna_cost_center

  resource_group_location = local.global_hyperscaler_location_long
  resource_group_instance = 1

  tags = local.tags
}


module "network" {
  #source = "git@gitlab.prd.materna.digital:components/terraform/azure/az-vnet"
  source = "git@gitlab.prd.materna.work:components/terraform/azure/az-vnet"

  global_subscription_id      = local.global_subscription_id
  global_stage                = local.global_stage
  global_hyperscaler          = local.global_hyperscaler
  global_hyperscaler_location = local.global_hyperscaler_location

  materna_customer_name  = local.materna_customer_name
  materna_project_number = local.materna_project_number
  materna_cost_center    = local.materna_cost_center

  resource_group_name = module.resource_group_network.rg_name
  address_space       = "10.50.0.0/16"

  tags = local.tags
}

module "resource_group" {
  #source = "git@gitlab.prd.materna.digital:components/terraform/azure/az-rg"
  source = "git@gitlab.prd.materna.work:components/terraform/azure/az-rg"

  global_subscription_id      = local.global_subscription_id
  global_stage                = local.global_stage
  global_hyperscaler          = local.global_hyperscaler
  global_hyperscaler_location = local.global_hyperscaler_location

  materna_customer_name  = local.materna_customer_name
  materna_project_number = local.materna_project_number
  materna_cost_center    = local.materna_cost_center

  resource_group_location = local.global_hyperscaler_location_long
  resource_group_instance = 2

  tags = local.tags
}

module "route_table" {
  #source = "git@gitlab.prd.materna.digital:components/terraform/azure/az-route"
  source = "git@gitlab.prd.materna.work:components/terraform/azure/az-route"

  global_subscription_id      = local.global_subscription_id
  global_stage                = local.global_stage
  global_hyperscaler          = local.global_hyperscaler
  global_hyperscaler_location = local.global_hyperscaler_location

  materna_customer_name  = local.materna_customer_name
  materna_project_number = local.materna_project_number
  materna_cost_center    = local.materna_cost_center

  resource_group_name = module.resource_group.rg_name

  tags = local.tags
}


module "public_ip" {
  #source = "git@gitlab.prd.materna.digital:components/terraform/azure/az-pip"
  source = "git@gitlab.prd.materna.work:components/terraform/azure/az-pip"

  global_subscription_id      = local.global_subscription_id
  global_stage                = local.global_stage
  global_hyperscaler          = local.global_hyperscaler
  global_hyperscaler_location = local.global_hyperscaler_location

  materna_customer_name  = local.materna_customer_name
  materna_project_number = local.materna_project_number
  materna_cost_center    = local.materna_cost_center

  resource_group_name = module.resource_group.rg_name
  public_ip_instance  = 1

  tags = local.tags
}


module "nat_gateway" {
  #source = "git@gitlab.prd.materna.digital:components/terraform/azure/az-ngw"
  source = "git@gitlab.prd.materna.work:components/terraform/azure/az-ngw"

  global_subscription_id      = local.global_subscription_id
  global_stage                = local.global_stage
  global_hyperscaler          = local.global_hyperscaler
  global_hyperscaler_location = local.global_hyperscaler_location

  materna_customer_name  = local.materna_customer_name
  materna_project_number = local.materna_project_number
  materna_cost_center    = local.materna_cost_center

  resource_group_name = module.resource_group.rg_name

  public_ip = {
    name                = module.public_ip.pip_name
    resource_group_name = module.public_ip.rg_name
  }

  nat_gateway_instance = 1

  tags = local.tags
}

module "subnet" {
  #source = "git@gitlab.prd.materna.digital:components/terraform/azure/az-snet"
  source = "git@gitlab.prd.materna.work:components/terraform/azure/az-snet"

  global_subscription_id      = local.global_subscription_id
  global_stage                = local.global_stage
  global_hyperscaler          = local.global_hyperscaler
  global_hyperscaler_location = local.global_hyperscaler_location

  materna_customer_name  = local.materna_customer_name
  materna_project_number = local.materna_project_number
  materna_cost_center    = local.materna_cost_center

  #  resource_group_name = local.network_resource_group_name
  resource_group_name = module.network.rg_name
  subnet_instance     = 1
  #  vnet_name           = local.vnet_name
  vnet_name = module.network.vnet_name
  #  address_prefix      = "10.26.6.160/27" #10.26.6.161 - 10.26.6.190; 30 IPs, Kafka HDInsight needs 17
  address_prefix                                = "10.50.1.0/24"
  private_link_service_network_policies_enabled = false


  associated_route_table = {
    name                = module.route_table.route_name
    resource_group_name = module.route_table.rg_name
  }

  nat_gateway = {
    name                = module.nat_gateway.ngw_name
    resource_group_name = module.nat_gateway.rg_name
  }
}

module "my_kafka" {
  source = "../"
  providers = {
    azurerm        = azurerm,
    azurerm.common = azurerm.common
  }
  global_subscription_id      = local.global_subscription_id
  global_stage                = local.global_stage
  global_hyperscaler          = local.global_hyperscaler
  global_hyperscaler_location = local.global_hyperscaler_location

  materna_customer_name  = local.materna_customer_name
  materna_project_number = local.materna_project_number
  materna_cost_center    = local.materna_cost_center

  resource_group_name = module.resource_group.rg_name

  kafka_cluster_instance                                       = 1
  kafka_cluster_storage_account_instance                       = 1
  kafka_cluster_private_endpoint_storage_account_blob_instance = 1
  kafka_cluster_private_endpoint_storage_account_file_instance = 2
  kafka_security_group_instance                                = 1

  subnet = {
    name                        = module.subnet.snet_name
    network_name                = module.subnet.vnet_name
    network_resource_group_name = module.subnet.rg_name
  }

  private_endpoint_gateway = {
    instance = 3
  }

  private_endpoint_headnode = {
    instance = 4
  }
  tags = local.tags

}
```

### Generic examples
copy this and fill with your values

```hcl
module "example" {
	 source  = "<module-path>"

	 # Required variables
	 global_hyperscaler  = 
	 global_hyperscaler_location  = 
	 global_stage  = 
	 materna_cost_center  = 
	 materna_customer_name  = 
	 materna_project_number  = 
	 private_endpoint_gateway  = 
	 private_endpoint_headnode  = 
	 resource_group_name  = 
	 subnet  = 
	 tags  = 

	 # Optional variables
	 global_subscription_id  = ""
	 kafka_cluster_component_version  = "2.4"
	 kafka_cluster_head_node_vm_size  = "Standard_E2_V3"
	 kafka_cluster_instance  = 1
	 kafka_cluster_private_endpoint_storage_account_blob_instance  = 1
	 kafka_cluster_private_endpoint_storage_account_file_instance  = 2
	 kafka_cluster_storage_account_instance  = 1
	 kafka_cluster_tier  = "Standard"
	 kafka_cluster_version  = "5.0"
	 kafka_cluster_worker_node_instances  = 3
	 kafka_cluster_worker_node_number_of_disks  = 1
	 kafka_cluster_worker_node_vm_size  = "Standard_A2m_V2"
	 kafka_cluster_zookeeper_node_vm_size  = "Standard_A1_V2"
	 kafka_security_group_instance  = 1
}
```

#### Providers

| Name | Version |
|------|---------|
| <a name="provider_azurecaf"></a> [azurecaf](#provider_azurecaf) | 1.2.23 |
| <a name="provider_azurerm"></a> [azurerm](#provider_azurerm) | ~>3.28 |
| <a name="provider_random"></a> [random](#provider_random) | ~> 3.0 |

#### Inputs

| Name | Description | Type |
|------|-------------|------|
| <a name="input_global_hyperscaler"></a> [global_hyperscaler](#input_global_hyperscaler) | Kennzeichen für den Hyperscaler | `string` |
| <a name="input_global_hyperscaler_location"></a> [global_hyperscaler_location](#input_global_hyperscaler_location) | Kennzeichen für den Hyperscaler Region | `string` |
| <a name="input_global_stage"></a> [global_stage](#input_global_stage) | Staging Umgebung | `string` |
| <a name="input_materna_cost_center"></a> [materna_cost_center](#input_materna_cost_center) | Materna cost center | `string` |
| <a name="input_materna_customer_name"></a> [materna_customer_name](#input_materna_customer_name) | Name of the customer (max. 5 characters). | `string` |
| <a name="input_materna_project_number"></a> [materna_project_number](#input_materna_project_number) | Materna internal project nummer | `string` |
| <a name="input_private_endpoint_gateway"></a> [private_endpoint_gateway](#input_private_endpoint_gateway) | Private endpoint parameters for Kafka Ambari endpoint | <pre>object({<br>    instance = number<br>    }<br>  )</pre> |
| <a name="input_private_endpoint_headnode"></a> [private_endpoint_headnode](#input_private_endpoint_headnode) | Private endpoint parameters for Kafka SSH access | <pre>object({<br>    instance = number<br>    }<br>  )</pre> |
| <a name="input_resource_group_name"></a> [resource_group_name](#input_resource_group_name) | Resource group of the Kafka cluster | `string` |
| <a name="input_subnet"></a> [subnet](#input_subnet) | Subnet parameters | <pre>object({<br>    name                        = string<br>    network_name                = string<br>    network_resource_group_name = string<br>  })</pre> |
| <a name="input_tags"></a> [tags](#input_tags) | Tags for the deployment | `map(any)` |
| <a name="input_global_subscription_id"></a> [global_subscription_id](#input_global_subscription_id) | n/a | `string` |
| <a name="input_kafka_cluster_component_version"></a> [kafka_cluster_component_version](#input_kafka_cluster_component_version) | Kafka version | `string` |
| <a name="input_kafka_cluster_head_node_vm_size"></a> [kafka_cluster_head_node_vm_size](#input_kafka_cluster_head_node_vm_size) | VM size of head nodes | `string` |
| <a name="input_kafka_cluster_instance"></a> [kafka_cluster_instance](#input_kafka_cluster_instance) | Die Instanz-ID für das Kafka Cluster. | `number` |
| <a name="input_kafka_cluster_private_endpoint_storage_account_blob_instance"></a> [kafka_cluster_private_endpoint_storage_account_blob_instance](#input_kafka_cluster_private_endpoint_storage_account_blob_instance) | Instance for storage account private endpoint | `number` |
| <a name="input_kafka_cluster_private_endpoint_storage_account_file_instance"></a> [kafka_cluster_private_endpoint_storage_account_file_instance](#input_kafka_cluster_private_endpoint_storage_account_file_instance) | Instance for storage account private endpoint | `number` |
| <a name="input_kafka_cluster_storage_account_instance"></a> [kafka_cluster_storage_account_instance](#input_kafka_cluster_storage_account_instance) | Die Instanz-ID für den Storage Account des Kafka Clusters. | `number` |
| <a name="input_kafka_cluster_tier"></a> [kafka_cluster_tier](#input_kafka_cluster_tier) | HDInsight Cluster version | `string` |
| <a name="input_kafka_cluster_version"></a> [kafka_cluster_version](#input_kafka_cluster_version) | HDInsight Cluster version | `string` |
| <a name="input_kafka_cluster_worker_node_instances"></a> [kafka_cluster_worker_node_instances](#input_kafka_cluster_worker_node_instances) | Number worker node instances | `number` |
| <a name="input_kafka_cluster_worker_node_number_of_disks"></a> [kafka_cluster_worker_node_number_of_disks](#input_kafka_cluster_worker_node_number_of_disks) | Number of disks per worker node | `number` |
| <a name="input_kafka_cluster_worker_node_vm_size"></a> [kafka_cluster_worker_node_vm_size](#input_kafka_cluster_worker_node_vm_size) | VM size of worker nodes | `string` |
| <a name="input_kafka_cluster_zookeeper_node_vm_size"></a> [kafka_cluster_zookeeper_node_vm_size](#input_kafka_cluster_zookeeper_node_vm_size) | VM size of Zookeeper nodes | `string` |
| <a name="input_kafka_security_group_instance"></a> [kafka_security_group_instance](#input_kafka_security_group_instance) | Instance number for Kafka security group | `number` |



#### Resources

- resource.azurecaf_name.kafka_cluster (main.tf#9)
- resource.azurecaf_name.kafka_security_group (main.tf#23)
- resource.azurecaf_name.storage_container (main.tf#16)
- resource.azurerm_hdinsight_kafka_cluster.this (main.tf#124)
- resource.azurerm_network_security_group.kafka (main.tf#30)
- resource.azurerm_storage_container.this (main.tf#78)
- resource.azurerm_subnet_network_security_group_association.kafka (main.tf#36)
- resource.random_password.gateway (main.tf#84)
- resource.random_password.vm_head (main.tf#94)
- resource.random_password.vm_worker (main.tf#104)
- resource.random_password.vm_zookeeper (main.tf#114)
- data source.azurerm_resource_group.rg (references.tf#1)
- data source.azurerm_subnet.snet (references.tf#5)
- data source.azurerm_virtual_network.vnet (references.tf#12)


<!-- END_TF_DOCS -->