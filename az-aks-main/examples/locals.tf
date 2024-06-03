locals {
  common_global_subscription_id = "441564b2-a7bc-432b-9f10-d30d428a4dff"

  global_subscription_id           = "b665dde9-99ce-4dfe-980a-60aa599d2129"
  global_tenant_id                 = "169c5641-0ac7-4da9-8cfa-85ace16b4f69"

  global_stage                     = "dev"
  global_hyperscaler               = "az"
  global_hyperscaler_location      = "gw"
  global_hyperscaler_location_long = "germanywestcentral"

  materna_project_number = "40b01000"
  materna_cost_center    = "40b01000"
  materna_customer_name  = "poc"

  agic_service_principal_name = "azgw-mat-sp-agic01-prd"
  vnet_name                   = "network"
  network_resource_group_name = "network"

  tags = {
    owner   = "mirco.schoenewolf@materna.de"
    project = "test"
  }
}
