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

  resource_group_location = "germanywestcentral"
  resource_group_instance = 1

  tags = local.tags
}

module "resource_group_network" {
  source  = "gitlab.prd.materna.work/registries/az-rg/azure"
  version = "1.0.0"

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
  source  = "gitlab.prd.materna.work/registries/az-vnet/azure"
  version = "1.0.0"

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
  source  = "gitlab.prd.materna.work/registries/az-snet/azure"
  version = "1.0.0"

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



module "my_storage_account" {
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

  private_endpoint_file = {
    instance      = 1
    custom_config = local.private_endpoint_config

  }

  private_endpoint_blob = {
    instance      = 2
    custom_config = local.private_endpoint_config
  }

  tags = local.tags
}
