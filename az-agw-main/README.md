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

  tags = local.tags
}


module "my_agw" {
  source = "../"

  global_subscription_id      = local.global_subscription_id
  global_stage                = local.global_stage
  global_hyperscaler          = local.global_hyperscaler
  global_hyperscaler_location = local.global_hyperscaler_location

  materna_customer_name  = local.materna_customer_name
  materna_project_number = local.materna_project_number
  materna_cost_center    = local.materna_cost_center

  resource_group_name         = module.resource_group.rg_name
  public_ip_name              = module.public_ip.pip_name
  agic_service_principal_name = local.agic_service_principal_name

  subnet = {
    name                        = module.subnet.snet_name
    network_name                = module.subnet.vnet_name
    network_resource_group_name = module.subnet.rg_name
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
	 agic_service_principal_name  = 
	 global_hyperscaler  = 
	 global_hyperscaler_location  = 
	 global_stage  = 
	 materna_cost_center  = 
	 materna_customer_name  = 
	 materna_project_number  = 
	 public_ip_name  = 
	 resource_group_name  = 
	 subnet  = 
	 tags  = 

	 # Optional variables
	 application_gateway_instance  = 1
	 frontend_port  = 80
	 global_subscription_id  = ""
	 log_analytics_workspace  = null
	 sku  = {}
	 waf_owasp_exclusions  = {}
}
```
#### Providers

| Name | Version |
|------|---------|
| <a name="provider_azuread"></a> [azuread](#provider_azuread) | ~> 2.29 |
| <a name="provider_azurecaf"></a> [azurecaf](#provider_azurecaf) | 1.2.23 |
| <a name="provider_azurerm"></a> [azurerm](#provider_azurerm) | 3.49 |
#### Inputs

| Name | Description | Type |
|------|-------------|------|
| <a name="input_agic_service_principal_name"></a> [agic_service_principal_name](#input_agic_service_principal_name) | Service principal that has Reader rights to the resource group of the application gateway and Contributor right to the application gateway | `string` |
| <a name="input_global_hyperscaler"></a> [global_hyperscaler](#input_global_hyperscaler) | Kennzeichen für den Hyperscaler | `string` |
| <a name="input_global_hyperscaler_location"></a> [global_hyperscaler_location](#input_global_hyperscaler_location) | Kennzeichen für den Hyperscaler Region | `string` |
| <a name="input_global_stage"></a> [global_stage](#input_global_stage) | Staging Umgebung | `string` |
| <a name="input_materna_cost_center"></a> [materna_cost_center](#input_materna_cost_center) | Materna cost center | `string` |
| <a name="input_materna_customer_name"></a> [materna_customer_name](#input_materna_customer_name) | Name of the customer (max. 5 characters). | `string` |
| <a name="input_materna_project_number"></a> [materna_project_number](#input_materna_project_number) | Materna internal project nummer | `string` |
| <a name="input_public_ip_name"></a> [public_ip_name](#input_public_ip_name) | Name of public ip | `string` |
| <a name="input_resource_group_name"></a> [resource_group_name](#input_resource_group_name) | Resource group name to create the public ip in | `string` |
| <a name="input_subnet"></a> [subnet](#input_subnet) | Subnet parameters | <pre>object({<br>    name                        = string<br>    network_name                = string<br>    network_resource_group_name = string<br>  })</pre> |
| <a name="input_tags"></a> [tags](#input_tags) | Tags for the deployment | `map(any)` |
| <a name="input_application_gateway_instance"></a> [application_gateway_instance](#input_application_gateway_instance) | Die Instanz-ID für das Application Gateway. | `number` |
| <a name="input_frontend_port"></a> [frontend_port](#input_frontend_port) | Port of frontend | `number` |
| <a name="input_global_subscription_id"></a> [global_subscription_id](#input_global_subscription_id) | n/a | `string` |
| <a name="input_log_analytics_workspace"></a> [log_analytics_workspace](#input_log_analytics_workspace) | Log Analytics Workspace | <pre>object({<br>    name                = string<br>    resource_group_name = string<br>  })</pre> |
| <a name="input_sku"></a> [sku](#input_sku) | Sku Parameters | <pre>object({<br>    capacity = optional(number, 2)<br>  })</pre> |
| <a name="input_waf_owasp_exclusions"></a> [waf_owasp_exclusions](#input_waf_owasp_exclusions) | n/a | <pre>map(object({<br>    rule_group_name = string<br>    rule_ids        = list(string)<br>  }))</pre> |

#### Resources

- resource.azurecaf_name.agw (main.tf#1)
- resource.azurerm_application_gateway.this (main.tf#54)
- resource.azurerm_monitor_diagnostic_setting.mds (main.tf#119)
- resource.azurerm_role_assignment.agic_rg (main.tf#9)
- resource.azurerm_web_application_firewall_policy.waf_fw_policy (main.tf#16)
- data source.azuread_service_principal.agic (references.tf#16)
- data source.azurerm_log_analytics_workspace.log (references.tf#20)
- data source.azurerm_public_ip.pip (references.tf#11)
- data source.azurerm_resource_group.rg (references.tf#1)
- data source.azurerm_subnet.snet (references.tf#5)
<!-- END_TF_DOCS -->