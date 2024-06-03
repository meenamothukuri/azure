<!-- BEGIN_TF_DOCS -->



### Examples

```hcl
module "resource_group" {
  source = "git@gitlab.prd.materna.work:components/terraform/azure/az-rg.git"

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
  source = "git@gitlab.prd.materna.work:components/terraform/azure/az-vnet.git"
  
  global_subscription_id      = local.global_subscription_id
  global_stage                = local.global_stage
  global_hyperscaler          = local.global_hyperscaler
  global_hyperscaler_location = local.global_hyperscaler_location

  materna_customer_name  = local.materna_customer_name
  materna_project_number = local.materna_project_number
  materna_cost_center    = local.materna_cost_center

  resource_group_name = module.resource_group.rg_name
  address_space       = "10.50.0.0/16"
  tags                = local.tags
}


module "subnet" {
  source = "git@gitlab.prd.materna.work:components/terraform/azure/az-snet.git"

  global_subscription_id      = local.global_subscription_id
  global_stage                = local.global_stage
  global_hyperscaler          = local.global_hyperscaler
  global_hyperscaler_location = local.global_hyperscaler_location

  materna_customer_name  = local.materna_customer_name
  materna_project_number = local.materna_project_number
  materna_cost_center    = local.materna_cost_center

  resource_group_name = module.network.rg_name
  vnet_name           = module.network.vnet_name
  address_prefix      = "10.50.1.0/24"
}


module "nsg" {
  source = "../"

  global_subscription_id      = local.global_subscription_id
  global_stage                = local.global_stage
  global_hyperscaler          = local.global_hyperscaler
  global_hyperscaler_location = local.global_hyperscaler_location

  materna_customer_name  = local.materna_customer_name
  materna_project_number = local.materna_project_number
  materna_cost_center    = local.materna_cost_center

  resource_group_name = module.network.rg_name
  nsg_instance        = 1

  subnet              = {
    name                        = module.subnet.snet_name
    network_name                = module.network.vnet_name
    network_resource_group_name = module.network.rg_name
  }

  nsg_inbound_rules   = var.nsg_inbound_rules
  nsg_outbound_rules  = var.nsg_outbound_rules
  
  tags                = local.tags
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
	 nsg_inbound_rules  = 
	 nsg_outbound_rules  = 
	 resource_group_name  = 
	 subnet  = 
	 tags  = 

	 # Optional variables
	 global_subscription_id  = ""
	 nsg_instance  = 1
}
```

#### Providers

| Name | Version |
|------|---------|
| <a name="provider_azurecaf"></a> [azurecaf](#provider_azurecaf) | 1.2.23 |
| <a name="provider_azurerm"></a> [azurerm](#provider_azurerm) | ~>3.28 |

#### Inputs

| Name | Description | Type |
|------|-------------|------|
| <a name="input_global_hyperscaler"></a> [global_hyperscaler](#input_global_hyperscaler) | Kennzeichen für den Hyperscaler | `string` |
| <a name="input_global_hyperscaler_location"></a> [global_hyperscaler_location](#input_global_hyperscaler_location) | Kennzeichen für den Hyperscaler Region | `string` |
| <a name="input_global_stage"></a> [global_stage](#input_global_stage) | Staging Umgebung | `string` |
| <a name="input_materna_cost_center"></a> [materna_cost_center](#input_materna_cost_center) | Materna cost center | `string` |
| <a name="input_materna_customer_name"></a> [materna_customer_name](#input_materna_customer_name) | Name of the customer (max. 5 characters). | `string` |
| <a name="input_materna_project_number"></a> [materna_project_number](#input_materna_project_number) | Materna internal project nummer | `string` |
| <a name="input_nsg_inbound_rules"></a> [nsg_inbound_rules](#input_nsg_inbound_rules) | Inbound rules of the NSG | <pre>map(object({<br>    priority                   = number<br>    direction                  = string<br>    access                     = string<br>    protocol                   = string<br>    source_port_range          = string<br>    destination_port_range     = string<br>    source_address_prefix      = string<br>    destination_address_prefix = string<br>    description                = string<br>  }))</pre> |
| <a name="input_nsg_outbound_rules"></a> [nsg_outbound_rules](#input_nsg_outbound_rules) | Outbound rules of the NSG | <pre>map(object({<br>    priority                   = number<br>    direction                  = string<br>    access                     = string<br>    protocol                   = string<br>    source_port_range          = string<br>    destination_port_range     = string<br>    source_address_prefix      = string<br>    destination_address_prefix = string<br>    description                = string<br>  }))</pre> |
| <a name="input_resource_group_name"></a> [resource_group_name](#input_resource_group_name) | Resource group of the nsg | `string` |
| <a name="input_subnet"></a> [subnet](#input_subnet) | Subnet parameters | <pre>object({<br>    name                        = string<br>    network_name                = string<br>    network_resource_group_name = string<br>  })</pre> |
| <a name="input_tags"></a> [tags](#input_tags) | Tags for the deployment | `map(any)` |
| <a name="input_global_subscription_id"></a> [global_subscription_id](#input_global_subscription_id) | n/a | `string` |
| <a name="input_nsg_instance"></a> [nsg_instance](#input_nsg_instance) | Instance number of the NSG | `number` |



#### Resources

- resource.azurecaf_name.nsg (main.tf#1)
- resource.azurerm_network_security_group.this (main.tf#9)
- resource.azurerm_network_security_rule.this (main.tf#18)
- resource.azurerm_subnet_network_security_group_association.this (main.tf#38)
- data source.azurerm_resource_group.rg (references.tf#1)
- data source.azurerm_subnet.snet (references.tf#6)


<!-- END_TF_DOCS -->