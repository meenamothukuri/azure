module "resource_group" {
  #source = "git@gitlab.prd.materna.digital:components/terraform/azure/az-rg"
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

  tags = var.tags
}

module "subnet" {
  #source = "git@gitlab.prd.materna.digital:components/terraform/azure/az-snet"
  source  = "gitlab.prd.materna.work/registries/az-snet/azure"
  version = "1.0.0"

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

module "my_vm-windows" {
  source = "../"

  global_subscription_id   = var.ARM_SUBSCRIPTION_ID
  global_stage             = var.global_stage
  global_hyperscaler       = var.global_hyperscaler
  materna_customer_name    = var.materna_customer_name
  materna_project_number   = var.materna_project_number
  vm_resource_group_name   = module.resource_group.rg_name
  materna_cost_center      = var.materna_cost_center
  virtual_machine_instance = 1
  vm_admin_username        = "matadmin"
  vm_size                  = "Standard_B2ms"
  materna_workload         = var.materna_project_number
  vm_admin_password        = "ZVE6uSkRza2IzsT6!"
  subnet = {
    name                        = module.subnet.snet_name
    network_name                = module.subnet.vnet_name
    network_resource_group_name = module.subnet.rg_name
  }
  vm_source_image_reference = {
    publisher = "MicrosoftWindowsServer"
    offer     = "WindowsServer"
    sku       = "2022-datacenter-azure-edition"
    version   = "latest"
  }

  commands_to_execute = var.commands_to_execute

  tags = var.tags
}
