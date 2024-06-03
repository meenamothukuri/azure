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
