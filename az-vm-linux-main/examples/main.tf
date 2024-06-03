



module "my_vm-linux" {
  source = "../"

  global_subscription_id   = local.global_subscription_id
  global_stage             = local.global_stage
  global_hyperscaler       = local.global_hyperscaler
  materna_customer_name    = local.materna_customer_name
  materna_project_number   = local.materna_project_number
  vm_resource_group_name   = "azgw-mat-rg-testvm-dev-01"
  materna_cost_center      = local.materna_cost_center
  virtual_machine_instance = 3
  vm_admin_username        = "matadmin"
  materna_workload         = local.materna_workload
  vm_admin_password        = "ZVE6uSkRza2IzsT6!"
  subnet = {
    name                        = "testvm"
    network_name                = "network"
    network_resource_group_name = "network"
  }

  tags = local.tags
}
