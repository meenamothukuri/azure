locals {
  global_subscription_id = "b665dde9-99ce-4dfe-980a-60aa599d2129"
  global_tenant_id       = "169c5641-0ac7-4da9-8cfa-85ace16b4f69"
  global_stage           = "dev"
  global_hyperscaler     = "az"
  materna_project_number = "40b01000"
  materna_cost_center    = "40b01000"
  materna_customer_name  = "mat"
  materna_workload       = "test"
  tags = {
    owner   = "mario.lowa-nzeukeyo@materna.de"
    project = "test"
  }
}
