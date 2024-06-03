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