locals {
  common_global_subscription_id = "8486ce6c-269b-4a8f-88a3-0785951dbe54"

  global_subscription_id      = "8486ce6c-269b-4a8f-88a3-0785951dbe54"
  global_tenant_id            = "72e67b6b-5fe2-4c81-ba51-be2b36a693a0"
  global_stage                = "dev"
  global_hyperscaler          = "az"
  global_hyperscaler_location = "we"
  materna_project_number      = "test"
  materna_cost_center         = "test"
  materna_customer_name       = "poc"
  private_endpoint_config = {
    resource_group_name = "mafo-pe-test-00"
    subnet = {
      name                        = "mafo-pe-test-00"
      network_name                = "azwe-mat-vnet-efitopstests-00"
      network_resource_group_name = "azwe-mat-rg-network-tst-00"
    }
  }
  tags = {
    owner   = "mark.forjahn@materna.group"
    project = "test"
  }
}
