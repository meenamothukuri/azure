locals {
  global_subscription_id = "8d0c1468-bc5a-4da8-a3ac-e40c4a49ecb4"
  global_tenant_id       = "b0c58e2e-5974-4759-ba52-4e2aed0fa372"
  global_stage           = "dev"
  global_hyperscaler     = "az"
  global_hyperscaler_location      = "we"
  global_hyperscaler_location_long = "westeurope"

  materna_project_number = "40b01000"
  materna_cost_center    = "40b01000"
  materna_customer_name  = "nrw"
  materna_workload       = "test"
  
  tags = {
    owner   = "diego.ballen-cantor@materna.group"
    project = "test"
  }
}
