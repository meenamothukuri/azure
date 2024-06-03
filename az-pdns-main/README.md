<!-- BEGIN_TF_DOCS -->



### Examples

```hcl
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

  resource_group_location = "germanywestcentral"
  resource_group_instance = 1

  tags = local.tags
}


module "vnet" {
  #source = "git@gitlab.prd.materna.digital:components/terraform/azure/az-vnet"
  source = "git@gitlab.prd.materna.work:components/terraform/azure/az-vnet"


  global_subscription_id      = local.global_subscription_id
  global_stage                = local.global_stage
  global_hyperscaler          = local.global_hyperscaler
  global_hyperscaler_location = local.global_hyperscaler_location

  materna_customer_name  = local.materna_customer_name
  materna_project_number = local.materna_project_number
  materna_cost_center    = local.materna_cost_center

  resource_group_name = module.resource_group.rg_name
  address_space       = "10.50.0.0/16"

  tags = local.tags
}

module "pdns" {
  source = "../"

  global_subscription_id           = local.global_subscription_id
  global_stage                     = local.global_stage
  global_hyperscaler               = local.global_hyperscaler
  global_hyperscaler_location      = local.global_hyperscaler_location
  global_hyperscaler_location_long = local.global_hyperscaler_location_long

  materna_customer_name  = local.materna_customer_name
  materna_project_number = local.materna_project_number
  materna_cost_center    = local.materna_cost_center

  resource_group_name = module.resource_group.rg_name
  tags                = local.tags
  networks = {
    n1 = {
      name                     = module.vnet.vnet_name
      resource_group_name      = module.vnet.rg_name
      network_link_instance_id = 1
    }
  }
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
	 global_hyperscaler_location_long  = 
	 global_stage  = 
	 materna_cost_center  = 
	 materna_customer_name  = 
	 materna_project_number  = 
	 resource_group_name  = 
	 tags  = 

	 # Optional variables
	 domain_name  = null
	 enable_aks_usage  = true
	 external_networks  = {}
	 global_subscription_id  = ""
	 networks  = {}
	 private_dns_zone_instance  = 1
}
```

#### Providers

| Name | Version |
|------|---------|
| <a name="provider_azurerm"></a> [azurerm](#provider_azurerm) | ~>3.28 |

#### Inputs

| Name | Description | Type |
|------|-------------|------|
| <a name="input_global_hyperscaler"></a> [global_hyperscaler](#input_global_hyperscaler) | Kennzeichen für den Hyperscaler | `string` |
| <a name="input_global_hyperscaler_location"></a> [global_hyperscaler_location](#input_global_hyperscaler_location) | Kennzeichen für den Hyperscaler Region | `string` |
| <a name="input_global_hyperscaler_location_long"></a> [global_hyperscaler_location_long](#input_global_hyperscaler_location_long) | Kennzeichen für den Hyperscaler Region | `string` |
| <a name="input_global_stage"></a> [global_stage](#input_global_stage) | Staging Umgebung | `string` |
| <a name="input_materna_cost_center"></a> [materna_cost_center](#input_materna_cost_center) | Materna cost center | `string` |
| <a name="input_materna_customer_name"></a> [materna_customer_name](#input_materna_customer_name) | Name of the customer (max. 5 characters). | `string` |
| <a name="input_materna_project_number"></a> [materna_project_number](#input_materna_project_number) | Materna internal project nummer | `string` |
| <a name="input_resource_group_name"></a> [resource_group_name](#input_resource_group_name) | Resource group name to create the network in | `string` |
| <a name="input_tags"></a> [tags](#input_tags) | Tags for the deployment | `map(any)` |
| <a name="input_domain_name"></a> [domain_name](#input_domain_name) | Set the domain name | `string` |
| <a name="input_enable_aks_usage"></a> [enable_aks_usage](#input_enable_aks_usage) | Defines if private DNS zone should be able to be used in AKS cluster. Results in different domain name | `bool` |
| <a name="input_external_networks"></a> [external_networks](#input_external_networks) | External network associations | <pre>map(object({<br>    id                       = string<br>    network_link_instance_id = number<br>  }))</pre> |
| <a name="input_global_subscription_id"></a> [global_subscription_id](#input_global_subscription_id) | n/a | `string` |
| <a name="input_networks"></a> [networks](#input_networks) | Network associations | <pre>map(object({<br>    name                     = string<br>    resource_group_name      = string<br>    network_link_instance_id = number<br>  }))</pre> |
| <a name="input_private_dns_zone_instance"></a> [private_dns_zone_instance](#input_private_dns_zone_instance) | Instance count of private DNS zone | `number` |



#### Resources

- resource.azurerm_private_dns_zone.this (main.tf#1)
- resource.azurerm_private_dns_zone_virtual_network_link.this (main.tf#15)
- resource.azurerm_private_dns_zone_virtual_network_link.this_external (main.tf#24)
- data source.azurerm_resource_group.rg (references.tf#1)
- data source.azurerm_virtual_network.this (references.tf#5)


<!-- END_TF_DOCS -->