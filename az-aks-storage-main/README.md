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

module "public_ip_ngw" {
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
  public_ip_instance  = 2

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
    name                = module.public_ip_ngw.pip_name
    resource_group_name = module.public_ip_ngw.rg_name
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

  resource_group_name = local.network_resource_group_name
  subnet_instance     = 1
  vnet_name           = local.vnet_name
  address_prefix      = "10.26.6.192/28"

  associated_route_table = {
    name                = module.route_table.route_name
    resource_group_name = module.route_table.rg_name
  }
  nat_gateway = {
    name                = module.nat_gateway.ngw_name
    resource_group_name = module.nat_gateway.rg_name
  }
}


module "subnet_agw" {
  #source = "git@gitlab.prd.materna.digital:components/terraform/azure/az-snet"
  source = "git@gitlab.prd.materna.work:components/terraform/azure/az-snet"

  global_subscription_id      = local.global_subscription_id
  global_stage                = local.global_stage
  global_hyperscaler          = local.global_hyperscaler
  global_hyperscaler_location = local.global_hyperscaler_location

  materna_customer_name  = local.materna_customer_name
  materna_project_number = local.materna_project_number
  materna_cost_center    = local.materna_cost_center

  resource_group_name = local.network_resource_group_name
  subnet_instance     = 2
  vnet_name           = local.vnet_name
  address_prefix      = "10.26.6.176/29"

  associated_route_table = {
    name                = module.route_table.route_name
    resource_group_name = module.route_table.rg_name
  }
}


module "public_ip_agw" {
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

module "agw" {
  #source = "git@gitlab.prd.materna.digital:components/terraform/azure/az-agw"
  source = "git@gitlab.prd.materna.work:components/terraform/azure/az-agw"

  global_subscription_id      = local.global_subscription_id
  global_stage                = local.global_stage
  global_hyperscaler          = local.global_hyperscaler
  global_hyperscaler_location = local.global_hyperscaler_location

  materna_customer_name  = local.materna_customer_name
  materna_project_number = local.materna_project_number
  materna_cost_center    = local.materna_cost_center

  resource_group_name         = module.resource_group.rg_name
  public_ip_name              = module.public_ip_agw.pip_name
  agic_service_principal_name = local.agic_service_principal_name

  subnet = {
    name                        = module.subnet_agw.snet_name
    network_name                = module.subnet_agw.vnet_name
    network_resource_group_name = module.subnet_agw.rg_name
  }
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
    instance = 4
  }
}

module "disk_encryption_set" {
  #source = "git@gitlab.prd.materna.digital:components/terraform/azure/az-des"
  source = "git@gitlab.prd.materna.work:components/terraform/azure/az-des"

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


module "aks" {
  #source = "git@gitlab.prd.materna.digital:components/terraform/azure/az-aks"
  source = "git@gitlab.prd.materna.work:components/terraform/azure/az-aks"

  # Route table association requiered at this point
  depends_on = [
    module.subnet,
    module.nat_gateway,
    module.disk_encryption_set,
    module.key_vault
  ]
  providers = {
    helm = helm.this,
  }
  global_subscription_id      = local.global_subscription_id
  global_tenant_id            = local.global_tenant_id
  global_stage                = local.global_stage
  global_hyperscaler          = local.global_hyperscaler
  global_hyperscaler_location = local.global_hyperscaler_location

  materna_customer_name  = local.materna_customer_name
  materna_project_number = local.materna_project_number
  materna_cost_center    = local.materna_cost_center

  aks_resourcegroup_name      = module.resource_group.rg_name
  aks_cluster_admins          = ["j2cp-aks-admin", "j2cp-aks-contributor"]
  aks_kubernetes_version      = "1.25.5"
  agic_service_principal_name = local.agic_service_principal_name

  system_node_pool = {
    subnet = {
      name                        = module.subnet.snet_name
      network_name                = module.subnet.vnet_name
      network_resource_group_name = module.subnet.rg_name
    }
  }

  application_gateway = {
    name                = module.agw.agw_name
    resource_group_name = module.agw.rg_name
    subscription_id     = module.agw.subscription_id
  }

  encryption = {
    disk_encryption_set = {
      name                = module.disk_encryption_set.des_name
      resource_group_name = module.disk_encryption_set.rg_name
    }
    key_vault = {
      name                = module.key_vault.kv_name
      resource_group_name = module.key_vault.rg_name
      key_vault_key = {
        name = module.disk_encryption_set.kvk_name
      }
    }
  }

  route_table_id = module.route_table.route_id

  aks_instance_id                          = 1
  resource_group_kubernetes_nodes_instance = 2

  tags = local.tags
}


module "aks_storage" {
  source = "../"
  depends_on = [
    module.disk_encryption_set,
  ]
  providers = {
    azurerm        = azurerm,
    azurerm.common = azurerm.common,
    kubernetes     = kubernetes.this
  }

  global_subscription_id      = local.global_subscription_id
  global_stage                = local.global_stage
  global_hyperscaler          = local.global_hyperscaler
  global_hyperscaler_location = local.global_hyperscaler_location

  materna_customer_name  = local.materna_customer_name
  materna_project_number = local.materna_project_number
  materna_cost_center    = local.materna_cost_center

  tags = local.tags

  aks = {
    instance_id                 = module.aks.aks_instance_id
    resource_group_name         = module.aks.rg_name
    user_assigned_identity_name = module.aks.managed_identity_name
  }

  disk_access_endpoint = {
    instance = 1
  }

  storage_account_endpoint = {
    file_instance = 2
    blob_instance = 3
  }

  encryption = {
    disk_encryption_set = {
      name                = module.disk_encryption_set.des_name
      resource_group_name = module.disk_encryption_set.rg_name
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
	 aks  = 
	 global_hyperscaler  = 
	 global_hyperscaler_location  = 
	 global_stage  = 
	 materna_cost_center  = 
	 materna_customer_name  = 
	 materna_project_number  = 
	 tags  = 

	 # Optional variables
	 apply_kubernetes  = true
	 disk_access_endpoint  = null
	 enable_full_subscription_contributor_rights  = false
	 encryption  = null
	 global_subscription_id  = ""
	 storage_account_endpoint  = null
	 storage_account_instance  = 1
}
```

#### Providers

| Name | Version |
|------|---------|
| <a name="provider_azurecaf"></a> [azurecaf](#provider_azurecaf) | 1.2.23 |
| <a name="provider_azurerm"></a> [azurerm](#provider_azurerm) | ~>3.28 |
| <a name="provider_kubernetes"></a> [kubernetes](#provider_kubernetes) | 2.18.1 |

#### Inputs

| Name | Description | Type |
|------|-------------|------|
| <a name="input_aks"></a> [aks](#input_aks) | AKS cluster parameters | <pre>object({<br>    instance_id                 = number<br>    resource_group_name         = string<br>    user_assigned_identity_name = string<br>  })</pre> |
| <a name="input_global_hyperscaler"></a> [global_hyperscaler](#input_global_hyperscaler) | Kennzeichen für den Hyperscaler | `string` |
| <a name="input_global_hyperscaler_location"></a> [global_hyperscaler_location](#input_global_hyperscaler_location) | Kennzeichen für den Hyperscaler Region | `string` |
| <a name="input_global_stage"></a> [global_stage](#input_global_stage) | Staging Umgebung | `string` |
| <a name="input_materna_cost_center"></a> [materna_cost_center](#input_materna_cost_center) | Materna cost center | `string` |
| <a name="input_materna_customer_name"></a> [materna_customer_name](#input_materna_customer_name) | Name of the customer (max. 5 characters). | `string` |
| <a name="input_materna_project_number"></a> [materna_project_number](#input_materna_project_number) | Materna internal project nummer | `string` |
| <a name="input_tags"></a> [tags](#input_tags) | Tags for the deployment | `map(any)` |
| <a name="input_apply_kubernetes"></a> [apply_kubernetes](#input_apply_kubernetes) | Storage class definitions on Kubernetes | `bool` |
| <a name="input_disk_access_endpoint"></a> [disk_access_endpoint](#input_disk_access_endpoint) | Endpoint for disk access endpoint | <pre>object({<br>    instance = number<br>    }<br>  )</pre> |
| <a name="input_enable_full_subscription_contributor_rights"></a> [enable_full_subscription_contributor_rights](#input_enable_full_subscription_contributor_rights) | Needed when role definitions cannot be created. Disk read,write,delete access is needed | `bool` |
| <a name="input_encryption"></a> [encryption](#input_encryption) | Encryption parameters | <pre>object({<br>    disk_encryption_set = object({<br>      name                = string<br>      resource_group_name = string<br>    })<br>    }<br>  )</pre> |
| <a name="input_global_subscription_id"></a> [global_subscription_id](#input_global_subscription_id) | n/a | `string` |
| <a name="input_storage_account_endpoint"></a> [storage_account_endpoint](#input_storage_account_endpoint) | Endpoints for storage account file endpoint | <pre>object({<br>    file_instance = number<br>    blob_instance = number<br>    }<br>  )</pre> |
| <a name="input_storage_account_instance"></a> [storage_account_instance](#input_storage_account_instance) | Storage account instance | `number` |



#### Resources

- resource.azurecaf_name.role_definition_disk_operations (main.tf#1)
- resource.azurerm_role_assignment.da (main.tf#35)
- resource.azurerm_role_assignment.disk_operations (main.tf#62)
- resource.azurerm_role_assignment.st (main.tf#49)
- resource.azurerm_role_definition.disk_operations (main.tf#9)
- resource.kubernetes_annotations.default_storageclass (main.tf#145)
- resource.kubernetes_storage_class_v1.disk_delete_immediate (main.tf#219)
- resource.kubernetes_storage_class_v1.disk_delete_wait_for_first_consumer (main.tf#244)
- resource.kubernetes_storage_class_v1.disk_retain_immediate (main.tf#164)
- resource.kubernetes_storage_class_v1.disk_retain_wait_for_first_consumer (main.tf#193)
- resource.kubernetes_storage_class_v1.file_delete_immediate (main.tf#322)
- resource.kubernetes_storage_class_v1.file_delete_wait_for_first_consumer (main.tf#345)
- resource.kubernetes_storage_class_v1.file_retain_immediate (main.tf#272)
- resource.kubernetes_storage_class_v1.file_retain_wait_for_first_consumer (main.tf#298)
- data source.azurerm_disk_encryption_set.des (references.tf#14)
- data source.azurerm_resource_group.this (references.tf#1)
- data source.azurerm_subscription.this (references.tf#5)
- data source.azurerm_user_assigned_identity.this (references.tf#9)


<!-- END_TF_DOCS -->