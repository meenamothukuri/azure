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

  resource_group_location = local.global_hyperscaler_location_long
  resource_group_instance = 1

  tags = local.tags
}

module "dns" {
  source = "../"

  global_stage        = local.global_stage
  materna_cost_center = local.materna_cost_center

  resource_group_name = module.resource_group.rg_name
  tags                = local.tags
  domain_name         = "test.public"

  dns_a_records = {
    r1 = {
      name    = "google"
      ttl     = 900
      records = ["8.8.8.8"]
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
	 global_stage  = 
	 materna_cost_center  = 
	 resource_group_name  = 
	 tags  = 

	 # Optional variables
	 dns_a_records  = {}
	 dns_ns_records  = {}
	 domain_name  = null
}
```

#### Providers

| Name | Version |
|------|---------|
| <a name="provider_azurerm"></a> [azurerm](#provider_azurerm) | ~>3.28 |

#### Inputs

| Name | Description | Type |
|------|-------------|------|
| <a name="input_global_stage"></a> [global_stage](#input_global_stage) | Staging Umgebung | `string` |
| <a name="input_materna_cost_center"></a> [materna_cost_center](#input_materna_cost_center) | Materna cost center | `string` |
| <a name="input_resource_group_name"></a> [resource_group_name](#input_resource_group_name) | Resource group name to create the dns zone in | `string` |
| <a name="input_tags"></a> [tags](#input_tags) | Tags for the deployment | `map(any)` |
| <a name="input_dns_a_records"></a> [dns_a_records](#input_dns_a_records) | n/a | <pre>map(object({<br>    name    = string<br>    ttl     = optional(number, 900)<br>    records = list(string)<br>    })<br>  )</pre> |
| <a name="input_dns_ns_records"></a> [dns_ns_records](#input_dns_ns_records) | n/a | <pre>map(object({<br>    name    = string<br>    ttl     = optional(number, 900)<br>    records = list(string)<br>    })<br>  )</pre> |
| <a name="input_domain_name"></a> [domain_name](#input_domain_name) | Domain name to use | `string` |



#### Resources

- resource.azurerm_dns_a_record.this (main.tf#8)
- resource.azurerm_dns_ns_record.this (main.tf#19)
- resource.azurerm_dns_zone.this (main.tf#1)
- data source.azurerm_resource_group.rg (references.tf#1)


<!-- END_TF_DOCS -->