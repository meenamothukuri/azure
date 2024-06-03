module "my_rg" {
  source = "../"

  global_stage                = var.global_stage
  global_hyperscaler          = var.global_hyperscaler
  global_hyperscaler_location = var.global_hyperscaler_location

  materna_customer_name  = var.materna_customer_name
  materna_project_number = var.materna_project_number
  materna_cost_center    = var.materna_cost_center

  resource_group_instance = 1
  resource_group_location = var.global_hyperscaler_location_long

  tags = var.tags
}
