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
