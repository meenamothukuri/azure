locals {
  common_global_subscription_id = "3a56d5e4-20ea-466a-bf24-a4ba65a31de2"

  global_subscription_id      = "3a56d5e4-20ea-466a-bf24-a4ba65a31de2"
  global_tenant_id            = "b0c58e2e-5974-4759-ba52-4e2aed0fa372"
  global_stage                = "dev"
  global_hyperscaler          = "dl"
  global_hyperscaler_location = "we"
  materna_project_number      = "test"
  materna_cost_center         = "40b01000"
  materna_customer_name       = "poc"

  tags = {
    owner   = "mark.forjahn@materna.group"
    project = "test"
  }
}
