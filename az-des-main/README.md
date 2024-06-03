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


module "key_vault" {
  providers = {
    azurerm        = azurerm,
    azurerm.common = azurerm.common
  }
  #source = "git@gitlab.prd.materna.digital:components/terraform/azure/az-kv"
  source = "git@gitlab.prd.materna.work:components/terraform/azure/az-kv"

  global_subscription_id      = local.global_subscription_id
  global_stage                = local.global_stage
  global_tenant_id            = local.global_tenant_id
  global_hyperscaler          = local.global_hyperscaler
  global_hyperscaler_location = local.global_hyperscaler_location

  materna_customer_name  = local.materna_customer_name
  materna_project_number = local.materna_project_number
  materna_cost_center    = local.materna_cost_center

  resource_group_name = module.resource_group.rg_name

  tags = local.tags

  key_vault_instance = 1

  private_endpoint = {
    instance = 1
  }
}



module "disk_encryption_set" {
  providers = {
    azurerm        = azurerm,
    azurerm.common = azurerm.common
  }
  source = "../"

  global_subscription_id      = local.global_subscription_id
  global_stage                = local.global_stage
  global_hyperscaler          = local.global_hyperscaler
  global_hyperscaler_location = local.global_hyperscaler_location

  materna_customer_name  = local.materna_customer_name
  materna_project_number = local.materna_project_number
  materna_cost_center    = local.materna_cost_center

  resource_group_name = module.resource_group.rg_name

  tags = local.tags

  disk_encryption_set_instance = 1
  key_vault_key_instance       = 1

  key_vault = {
    name                = module.key_vault.kv_name
    resource_group_name = module.key_vault.rg_name
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
	 global_stage  = 
	 key_vault  = 
	 materna_cost_center  = 
	 materna_customer_name  = 
	 materna_project_number  = 
	 resource_group_name  = 
	 tags  = 

	 # Optional variables
	 disk_encryption_set_instance  = 1
	 global_subscription_id  = ""
	 key_vault_key_instance  = 1
}
```

#### Providers

| Name | Version |
|------|---------|
| <a name="provider_azurecaf"></a> [azurecaf](#provider_azurecaf) | 1.2.23 |
| <a name="provider_azurerm"></a> [azurerm](#provider_azurerm) | ~>3.28 |
| <a name="provider_azurerm.common"></a> [azurerm.common](#provider_azurerm.common) | ~>3.28 |

#### Inputs

| Name | Description | Type |
|------|-------------|------|
| <a name="input_global_hyperscaler"></a> [global_hyperscaler](#input_global_hyperscaler) | Kennzeichen für den Hyperscaler | `string` |
| <a name="input_global_hyperscaler_location"></a> [global_hyperscaler_location](#input_global_hyperscaler_location) | Kennzeichen für den Hyperscaler Region | `string` |
| <a name="input_global_stage"></a> [global_stage](#input_global_stage) | Staging Umgebung | `string` |
| <a name="input_key_vault"></a> [key_vault](#input_key_vault) | Key Vault parameters | <pre>object({<br>    name                = string<br>    resource_group_name = string<br>    }<br>  )</pre> |
| <a name="input_materna_cost_center"></a> [materna_cost_center](#input_materna_cost_center) | Materna cost center | `string` |
| <a name="input_materna_customer_name"></a> [materna_customer_name](#input_materna_customer_name) | Name of the customer (max. 5 characters). | `string` |
| <a name="input_materna_project_number"></a> [materna_project_number](#input_materna_project_number) | Materna internal project nummer | `string` |
| <a name="input_resource_group_name"></a> [resource_group_name](#input_resource_group_name) | Resource group name to create the key vault in | `string` |
| <a name="input_tags"></a> [tags](#input_tags) | Tags for the deployment | `map(any)` |
| <a name="input_disk_encryption_set_instance"></a> [disk_encryption_set_instance](#input_disk_encryption_set_instance) | Die Instanz-ID des Disk encryption sets | `number` |
| <a name="input_global_subscription_id"></a> [global_subscription_id](#input_global_subscription_id) | n/a | `string` |
| <a name="input_key_vault_key_instance"></a> [key_vault_key_instance](#input_key_vault_key_instance) | Die Instanz-ID des Key Vaults Keys | `number` |



#### Resources

- resource.azurecaf_name.disk_encryption_set (main.tf#1)
- resource.azurecaf_name.key_vault_key (main.tf#8)
- resource.azurerm_disk_encryption_set.this (main.tf#43)
- resource.azurerm_key_vault_key.this (main.tf#18)
- resource.azurerm_role_assignment.des (main.tf#61)
- data source.azurerm_key_vault.key_vault (references.tf#5)
- data source.azurerm_resource_group.rg (references.tf#1)


<!-- END_TF_DOCS -->