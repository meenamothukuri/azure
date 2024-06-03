module "resource_group" {
  #source = "git@gitlab.prd.materna.digital:components/terraform/azure/az-rg"
  source = "git@gitlab.prd.materna.work:components/terraform/azure/az-rg"

  global_subscription_id      = local.global_subscription_id
  global_stage                = local.global_stage
  global_hyperscaler          = local.global_hyperscaler
  global_hyperscaler_location = local.global_hyperscaler_location

  materna_customer_name  = local.materna_customer_name
  materna_project_number = local.materna_project_number
  materna_cost_center    = local.materna_cost_center

  resource_group_location = "germanywestcentral"
  resource_group_instance = 1

  tags = local.tags
}

module "resource_group_network" {
  #source = "git@gitlab.prd.materna.digital:components/terraform/azure/az-rg"
  source = "git@gitlab.prd.materna.work:components/terraform/azure/az-rg"

  global_subscription_id      = local.global_subscription_id
  global_stage                = local.global_stage
  global_hyperscaler          = local.global_hyperscaler
  global_hyperscaler_location = local.global_hyperscaler_location

  materna_customer_name  = local.materna_customer_name
  materna_project_number = local.materna_project_number
  materna_cost_center    = local.materna_cost_center

  resource_group_location = "germanywestcentral"
  resource_group_instance = 2

  tags = local.tags
}

module "network" {
  #source = "git@gitlab.prd.materna.digital:components/terraform/azure/az-vnet"
  source = "git@gitlab.prd.materna.work:components/terraform/azure/az-vnet"

  global_subscription_id      = local.global_subscription_id
  global_stage                = local.global_stage
  global_hyperscaler          = local.global_hyperscaler
  global_hyperscaler_location = local.global_hyperscaler_location

  materna_customer_name  = local.materna_customer_name
  materna_project_number = local.materna_project_number
  materna_cost_center    = local.materna_cost_center

  resource_group_name = module.resource_group_network.rg_name
  address_space       = "10.50.0.0/16"

  tags = local.tags
}

module "subnet" {
  #source = "git@gitlab.prd.materna.digital:components/terraform/azure/az-snet"
  source = "git@gitlab.prd.materna.work:components/terraform/azure/az-snet"

  global_subscription_id      = local.global_subscription_id
  global_stage                = local.global_stage
  global_hyperscaler          = local.global_hyperscaler
  global_hyperscaler_location = local.global_hyperscaler_location

  materna_customer_name  = local.materna_customer_name
  materna_project_number = local.materna_project_number
  materna_cost_center    = local.materna_cost_center

  resource_group_name = module.network.rg_name
  subnet_instance     = 1
  vnet_name           = module.network.vnet_name
  address_prefix      = "10.50.1.0/24"
}


resource "azurecaf_name" "cr" {
  resource_type = "azurerm_container_registry"
  prefixes      = [format("%s%s", local.global_hyperscaler, local.global_hyperscaler_location), local.materna_customer_name]
  suffixes      = [local.materna_project_number, local.global_stage, format("%02d", 1)]
  clean_input   = true
}

resource "azurerm_container_registry" "this" {
  name                          = lower(azurecaf_name.cr.result)
  resource_group_name           = module.resource_group.rg_name
  location                      = module.resource_group.rg_location
  sku                           = "Premium" # Needed for private endpoints
  admin_enabled                 = false
  public_network_access_enabled = false
  tags                          = local.tags
}



module "private_dns_zone" {
  #source = "git@gitlab.prd.materna.digital:components/terraform/azure/az-pdns"
  source = "git@gitlab.prd.materna.work:components/terraform/azure/az-pdns"


  global_subscription_id           = local.global_subscription_id
  global_stage                     = local.global_stage
  global_hyperscaler               = local.global_hyperscaler
  global_hyperscaler_location      = local.global_hyperscaler_location
  global_hyperscaler_location_long = local.global_hyperscaler_location_long

  materna_customer_name  = local.materna_customer_name
  materna_project_number = local.materna_project_number
  materna_cost_center    = local.materna_cost_center

  resource_group_name = module.resource_group.rg_name
  tags                = local.tags
  networks = {
    n1 = {
      name                     = module.subnet.vnet_name
      resource_group_name      = module.subnet.rg_name
      network_link_instance_id = 1
    }
  }
}


module "my_private_endpoint" {
  source = "../"

  global_subscription_id      = local.global_subscription_id
  global_stage                = local.global_stage
  global_hyperscaler          = local.global_hyperscaler
  global_hyperscaler_location = local.global_hyperscaler_location

  materna_customer_name  = local.materna_customer_name
  materna_project_number = local.materna_project_number
  materna_cost_center    = local.materna_cost_center

  resource_group_name = module.resource_group.rg_name

  subnet = {
    name                        = module.subnet.snet_name
    network_name                = module.subnet.vnet_name
    network_resource_group_name = module.subnet.rg_name
  }
  private_dns_zone = {
    resource_group_name = module.private_dns_zone.rg_name
    id                  = module.private_dns_zone.pdns_id
    name                = module.private_dns_zone.pdns_name
  }

  private_connection_resource_id = azurerm_container_registry.this.id

  is_manual_connection = false
  subresource_names    = ["registry"]

  tags = local.tags
}
