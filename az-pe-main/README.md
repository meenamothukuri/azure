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

  resource_group_location = "germanywestcentral"
  resource_group_instance = 2

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

  resource_group_name = module.network.rg_name
  subnet_instance     = 1
  vnet_name           = module.network.vnet_name
  address_prefix      = "10.50.1.0/24"
}


resource "azurecaf_name" "cr" {
  resource_type = "azurerm_container_registry"
  prefixes      = [format("%s%s", local.global_hyperscaler, local.global_hyperscaler_location), local.materna_customer_name]
  suffixes      = [local.materna_project_number, local.global_stage, format("%02d", 1)]
  clean_input   = true
}

resource "azurerm_container_registry" "this" {
  name                          = lower(azurecaf_name.cr.result)
  resource_group_name           = module.resource_group.rg_name
  location                      = module.resource_group.rg_location
  sku                           = "Premium" # Needed for private endpoints
  admin_enabled                 = false
  public_network_access_enabled = false
  tags                          = local.tags
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

  resource_group_name = module.resource_group.rg_name
  tags                = local.tags
  networks = {
    n1 = {
      name                     = module.subnet.vnet_name
      resource_group_name      = module.subnet.rg_name
      network_link_instance_id = 1
    }
  }
}


module "my_private_endpoint" {
  source = "../"

  global_subscription_id      = local.global_subscription_id
  global_stage                = local.global_stage
  global_hyperscaler          = local.global_hyperscaler
  global_hyperscaler_location = local.global_hyperscaler_location

  materna_customer_name  = local.materna_customer_name
  materna_project_number = local.materna_project_number
  materna_cost_center    = local.materna_cost_center

  resource_group_name = module.resource_group.rg_name

  subnet = {
    name                        = module.subnet.snet_name
    network_name                = module.subnet.vnet_name
    network_resource_group_name = module.subnet.rg_name
  }
  private_dns_zone = {
    resource_group_name = module.private_dns_zone.rg_name
    id                  = module.private_dns_zone.pdns_id
    name                = module.private_dns_zone.pdns_name
  }

  private_connection_resource_id = azurerm_container_registry.this.id

  is_manual_connection = false
  subresource_names    = ["registry"]

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
	 is_manual_connection  = 
	 materna_cost_center  = 
	 materna_customer_name  = 
	 materna_project_number  = 
	 private_connection_resource_id  = 
	 resource_group_name  = 
	 subnet  = 
	 tags  = 

	 # Optional variables
	 global_subscription_id  = ""
	 manual_private_dns_zone_entry  = null
	 private_dns_zone  = null
	 private_endpoint_instance  = 1
	 subresource_names  = null
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
| <a name="input_is_manual_connection"></a> [is_manual_connection](#input_is_manual_connection) | Does the Private Endpoint require Manual Approval from the remote resource owner? Changing this forces a new resource to be created. | `bool` |
| <a name="input_materna_cost_center"></a> [materna_cost_center](#input_materna_cost_center) | Materna cost center | `string` |
| <a name="input_materna_customer_name"></a> [materna_customer_name](#input_materna_customer_name) | Name of the customer (max. 5 characters). | `string` |
| <a name="input_materna_project_number"></a> [materna_project_number](#input_materna_project_number) | Materna internal project nummer | `string` |
| <a name="input_private_connection_resource_id"></a> [private_connection_resource_id](#input_private_connection_resource_id) | The ID of the Private Link Enabled Remote Resource which this Private Endpoint should be connected to | `string` |
| <a name="input_resource_group_name"></a> [resource_group_name](#input_resource_group_name) | Resource group name to create the disk access in | `string` |
| <a name="input_subnet"></a> [subnet](#input_subnet) | Subnet for the private endpoint | <pre>object({<br>    name                        = string<br>    network_name                = string<br>    network_resource_group_name = string<br>  })</pre> |
| <a name="input_tags"></a> [tags](#input_tags) | Tags for the deployment | `map(any)` |
| <a name="input_global_subscription_id"></a> [global_subscription_id](#input_global_subscription_id) | n/a | `string` |
| <a name="input_manual_private_dns_zone_entry"></a> [manual_private_dns_zone_entry](#input_manual_private_dns_zone_entry) | Needed when DNS config is not working for a specifig config. e.g. Kafka | <pre>object({<br>    name = string<br>  })</pre> |
| <a name="input_private_dns_zone"></a> [private_dns_zone](#input_private_dns_zone) | Private DNS zone for endpoint | <pre>object({<br>    name                = string<br>    id                  = string<br>    resource_group_name = string<br>  })</pre> |
| <a name="input_private_endpoint_instance"></a> [private_endpoint_instance](#input_private_endpoint_instance) | Die Instanz-ID für den privaten Endpoint | `number` |
| <a name="input_subresource_names"></a> [subresource_names](#input_subresource_names) | A list of subresource names which the Private Endpoint is able to connect to | `list(string)` |



#### Resources

- resource.azurecaf_name.private_endpoint (main.tf#1)
- resource.azurerm_private_dns_a_record.this (main.tf#41)
- resource.azurerm_private_endpoint.this (main.tf#8)
- data source.azurerm_resource_group.rg (references.tf#1)
- data source.azurerm_subnet.subnet (references.tf#5)


<!-- END_TF_DOCS -->