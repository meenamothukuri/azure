module "resource_group" {
  source  = "gitlab.prd.materna.work/registries/az-rg/azure"
  version = "1.0.0"

  global_subscription_id      = local.global_subscription_id
  global_stage                = local.global_stage
  global_hyperscaler          = local.global_hyperscaler
  global_hyperscaler_location = local.global_hyperscaler_location

  materna_customer_name  = local.materna_customer_name
  materna_project_number = local.materna_project_number
  materna_cost_center    = local.materna_cost_center

  resource_group_location = "westeurope"
  resource_group_instance = 1

  tags = local.tags
}


module "key_vault" {
  providers = {
    azurerm        = azurerm,
    azurerm.common = azurerm.common
  }
  source = "../"

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
    instance      = 1
    custom_config = local.private_endpoint_config
  }

}
