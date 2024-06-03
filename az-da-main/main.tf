module "global_constants" {
  source  = "gitlab.prd.materna.work/registries/az-global-constants/azure"
  version = "1.1.0"

  global_hyperscaler = var.global_hyperscaler

  private_dns_zone = var.private_endpoint["custom_private_dns_zone"]
  private_endpoint = var.private_endpoint["custom_config"]
}
/*
resource "azurecaf_name" "disk_access" {
  resource_type = "azurerm_disk_access"
  prefixes      = [format("%s%s", var.global_hyperscaler, var.global_hyperscaler_location), var.materna_customer_name]
  suffixes      = [var.materna_project_number, var.global_stage, format("%02d", var.disk_access_instance)]
  clean_input   = true
}*/

resource "azurerm_disk_access" "this" {
  name                = local.disk_access_name
  location            = data.azurerm_resource_group.rg.location
  resource_group_name = data.azurerm_resource_group.rg.name

  tags = merge(local.common_tags, var.tags)
  lifecycle {
    ignore_changes = [
      location,
    ]
  }

}

module "private_endpoint_disk_access" {
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

  private_dns_zone = module.global_constants.private_dns_zone["service"]["storage_account_blob"]["id"] != null ? {
    resource_group_name = module.global_constants.private_dns_zone["resource_group_name"]
    id                  = module.global_constants.private_dns_zone["service"]["storage_account_blob"]["id"]
    name                = module.global_constants.private_dns_zone["service"]["storage_account_blob"]["name"]
  } : null

  private_connection_resource_id = azurerm_disk_access.this.id
  is_manual_connection           = false
  subresource_names              = ["disks"]

  tags = var.tags
}
