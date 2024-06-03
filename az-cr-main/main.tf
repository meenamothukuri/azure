module "global_constants" {
  source  = "gitlab.prd.materna.work/registries/az-global-constants/azure"
  version = "1.0.0"
  #source = "git@gitlab.prd.materna.work:components/terraform/azure/az-global-constants.git"

  global_hyperscaler = var.global_hyperscaler
}

resource "azurecaf_name" "cr" {
  resource_type = "azurerm_container_registry"
  prefixes      = [format("%s%s", var.global_hyperscaler, var.global_hyperscaler_location), var.materna_customer_name]
  suffixes      = [var.materna_project_number, var.global_stage, format("%02d", var.container_registry_instance)]
  clean_input   = true
}

resource "azurerm_container_registry" "this" {
  name                          = lower(azurecaf_name.cr.result)
  resource_group_name           = data.azurerm_resource_group.rg.name
  location                      = data.azurerm_resource_group.rg.location
  sku                           = "Premium" # Needed for private endpoints
  admin_enabled                 = false
  public_network_access_enabled = true
  tags                          = merge(local.common_tags, var.tags)
}


module "private_endpoint" {
  providers = {
    azurerm = azurerm.common
  }

  source  = "gitlab.prd.materna.work/registries/az-pe/azure"
  version = "1.0.0"
  #source = "git@gitlab.prd.materna.work:components/terraform/azure/az-pe.git"

  global_subscription_id      = var.global_subscription_id
  global_stage                = var.global_stage
  global_hyperscaler          = var.global_hyperscaler
  global_hyperscaler_location = var.global_hyperscaler_location

  materna_customer_name  = var.materna_customer_name
  materna_project_number = var.materna_project_number
  materna_cost_center    = var.materna_cost_center

  resource_group_name       = module.global_constants.private_endpoint["resource_group_name"]
  private_endpoint_instance = var.private_endpoint["instance"]

  subnet = {
    name                        = module.global_constants.private_endpoint["subnet"]["name"]
    network_name                = module.global_constants.private_endpoint["subnet"]["network_name"]
    network_resource_group_name = module.global_constants.private_endpoint["subnet"]["network_resource_group_name"]
  }

  private_dns_zone = module.global_constants.private_dns_zone["service"]["container_registry"]["id"] != null ? {
    resource_group_name = module.global_constants.private_dns_zone["resource_group_name"]
    id                  = module.global_constants.private_dns_zone["service"]["container_registry"]["id"]
    name                = module.global_constants.private_dns_zone["service"]["container_registry"]["name"]
  } : null

  private_connection_resource_id = azurerm_container_registry.this.id
  is_manual_connection           = false
  subresource_names              = ["registry"]

  tags = var.tags
}
