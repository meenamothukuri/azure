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
