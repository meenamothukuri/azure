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

module "private_dns_zone" {
  #source = "git@gitlab.prd.materna.digital:components/terraform/azure/az-pdns"
  source = "git@gitlab.prd.materna.work:components/terraform/azure/az-pdns"

  global_subscription_id           = local.global_subscription_id
  global_stage                     = local.global_stage
  global_hyperscaler               = local.global_hyperscaler
  global_hyperscaler_location      = local.global_hyperscaler_location
  global_hyperscaler_location_long = local.global_hyperscaler_location_long

  materna_customer_name  = local.materna_customer_name
  materna_project_number = local.materna_project_number
  materna_cost_center    = local.materna_cost_center

  domain_name         = "mydomain.internal"
  resource_group_name = module.resource_group.rg_name

  tags = local.tags
}

module "my_vnet" {
  source = "../"

  global_subscription_id      = local.global_subscription_id
  global_stage                = local.global_stage
  global_hyperscaler          = local.global_hyperscaler
  global_hyperscaler_location = local.global_hyperscaler_location

  materna_customer_name  = local.materna_customer_name
  materna_project_number = local.materna_project_number
  materna_cost_center    = local.materna_cost_center

  resource_group_name = module.resource_group.rg_name
  address_space       = "10.50.0.0/16"

  # remote_vnet_id = "/subscriptions/b0982181-36b0-4670-bc0f-17b25f49c6b6/resourceGroups/Mat-connectivity-rg/providers/Microsoft.Network/virtualNetworks/hub-vnet"

  tags = local.tags

  private_dns_zones = {
    z1 = {
      name                     = module.private_dns_zone.pdns_name
      resource_group_name      = module.private_dns_zone.rg_name
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
	 address_space  = 
	 global_hyperscaler  = 
	 global_hyperscaler_location  = 
	 global_stage  = 
	 materna_cost_center  = 
	 materna_customer_name  = 
	 materna_project_number  = 
	 resource_group_name  = 
	 tags  = 

	 # Optional variables
	 dns_server  = []
	 global_subscription_id  = ""
	 network_peering  = {}
	 private_dns_zones  = {}
	 vnet_instance  = 1
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
| <a name="input_address_space"></a> [address_space](#input_address_space) | Virtual network address space | `string` |
| <a name="input_global_hyperscaler"></a> [global_hyperscaler](#input_global_hyperscaler) | Kennzeichen für den Hyperscaler | `string` |
| <a name="input_global_hyperscaler_location"></a> [global_hyperscaler_location](#input_global_hyperscaler_location) | Kennzeichen für den Hyperscaler Region | `string` |
| <a name="input_global_stage"></a> [global_stage](#input_global_stage) | Staging Umgebung | `string` |
| <a name="input_materna_cost_center"></a> [materna_cost_center](#input_materna_cost_center) | Materna cost center | `string` |
| <a name="input_materna_customer_name"></a> [materna_customer_name](#input_materna_customer_name) | Name of the customer (max. 5 characters). | `string` |
| <a name="input_materna_project_number"></a> [materna_project_number](#input_materna_project_number) | Materna internal project nummer | `string` |
| <a name="input_resource_group_name"></a> [resource_group_name](#input_resource_group_name) | Resource group name to create the network in | `string` |
| <a name="input_tags"></a> [tags](#input_tags) | Tags for the deployment | `map(any)` |
| <a name="input_dns_server"></a> [dns_server](#input_dns_server) | DNS Server | `list(string)` |
| <a name="input_global_subscription_id"></a> [global_subscription_id](#input_global_subscription_id) | n/a | `string` |
| <a name="input_network_peering"></a> [network_peering](#input_network_peering) | n/a | <pre>map(object({<br>    instance                = string<br>    remote_vnet_id          = string<br>    allow_forwarded_traffic = bool<br>  }))</pre> |
| <a name="input_private_dns_zones"></a> [private_dns_zones](#input_private_dns_zones) | Private DNS Zones | <pre>map(object({<br>    name                     = string<br>    resource_group_name      = string<br>    network_link_instance_id = number<br>  }))</pre> |
| <a name="input_vnet_instance"></a> [vnet_instance](#input_vnet_instance) | Die Instanz-ID für das virtuelle Netwerk. | `number` |



#### Resources

- resource.azurecaf_name.vnet (main.tf#9)
- resource.azurecaf_name.vnet_peering (main.tf#1)
- resource.azurerm_private_dns_zone_virtual_network_link.this (main.tf#46)
- resource.azurerm_virtual_network.this (main.tf#16)
- resource.azurerm_virtual_network_dns_servers.this (main.tf#29)
- resource.azurerm_virtual_network_peering.this (main.tf#35)
- data source.azurerm_private_dns_zone.this (references.tf#5)
- data source.azurerm_resource_group.rg (references.tf#1)


<!-- END_TF_DOCS -->