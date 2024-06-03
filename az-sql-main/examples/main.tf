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

module "my_sql" {
  source = "../"
  providers = {
    azurerm        = azurerm,
    azurerm.common = azurerm,
  }

  global_subscription_id      = var.ARM_SUBSCRIPTION_ID
  global_stage                = var.global_stage
  global_hyperscaler          = var.global_hyperscaler
  global_hyperscaler_location = var.global_hyperscaler_location

  materna_customer_name  = var.materna_customer_name
  materna_project_number = var.materna_project_number
  materna_cost_center    = var.materna_cost_center

  resource_group_name = module.resource_group.rg_name

  sql_instance = 1

  sql_server       = var.sql_server
  private_endpoint = var.private_endpoint

  sql_databases = var.sql_databases

  tags = var.tags
}
