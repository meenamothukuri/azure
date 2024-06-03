
module "resource_group" {
  depends_on = [module.subnet]

  #source = "https://gitlab.prd.materna.work/components/terraform/azure/az-rg"
  source  = "gitlab.prd.materna.work/registries/az-rg/azure"
  version = "1.0.0"


  global_subscription_id      = var.ARM_SUBSCRIPTION_ID
  global_stage                = var.global_stage
  global_hyperscaler          = var.global_hyperscaler
  global_hyperscaler_location = var.global_hyperscaler_location

  materna_customer_name  = var.materna_customer_name
  materna_project_number = var.materna_project_number
  materna_cost_center    = var.materna_cost_center

  resource_group_location = var.global_hyperscaler_location_long
  resource_group_instance = 1
  tags                    = var.tags
}

module "subnet" {
  #source = "git@gitlab.prd.materna.digital:components/terraform/azure/az-snet"
  source  = "gitlab.prd.materna.work/registries/az-snet/azure"
  version = "1.1.0"

  global_subscription_id      = var.ARM_SUBSCRIPTION_ID
  global_stage                = var.global_stage
  global_hyperscaler          = var.global_hyperscaler
  global_hyperscaler_location = var.global_hyperscaler_location

  materna_customer_name  = var.materna_customer_name
  materna_project_number = var.materna_project_number
  materna_cost_center    = var.materna_cost_center

  resource_group_name = var.network["resource_group_name"]
  subnet_instance     = 1
  vnet_name           = var.network["name"]
  address_prefix      = var.subnet_address_prefix
}



module "vmss_linux" {
  source = "../"


  global_subscription_id      = var.ARM_SUBSCRIPTION_ID
  global_stage                = var.global_stage
  global_hyperscaler          = var.global_hyperscaler
  global_hyperscaler_location = var.global_hyperscaler_location
  materna_customer_name       = var.materna_customer_name
  materna_project_number      = var.materna_project_number
  resource_group_name         = module.resource_group.rg_name
  materna_cost_center         = var.materna_cost_center
  vmss_admin_username         = "matadmin"
  vmss_admin_password         = "ZVE6uSkRza2IzsT6!"
  #vmss_source_image_id        = var.vmss_source_image_id
  vmss_source_image_reference = var.vmss_source_image_reference

  auto_start = var.auto_start
  auto_stop  = var.auto_stop

  subnet = {
    name                        = module.subnet.snet_name
    network_name                = module.subnet.vnet_name
    network_resource_group_name = module.subnet.rg_name
  }

  tags = var.tags
}
