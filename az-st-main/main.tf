module "global_constants_blob" {
  source  = "gitlab.prd.materna.work/registries/az-global-constants/azure"
  version = "1.1.0"

  global_hyperscaler = var.global_hyperscaler

  private_dns_zone = var.private_endpoint_blob["custom_private_dns_zone"]
  private_endpoint = var.private_endpoint_blob["custom_config"]
}

module "global_constants_file" {
  source  = "gitlab.prd.materna.work/registries/az-global-constants/azure"
  version = "1.1.0"

  global_hyperscaler = var.global_hyperscaler

  private_dns_zone = var.private_endpoint_file["custom_private_dns_zone"]
  private_endpoint = var.private_endpoint_file["custom_config"]
}

resource "azurecaf_name" "storage_account" {
  resource_type = "azurerm_storage_account"
  prefixes      = [format("%s%s", var.global_hyperscaler, var.global_hyperscaler_location), var.materna_customer_name]
  suffixes      = [var.materna_project_number, var.global_stage, format("%02d", var.storage_account_instance)]
  clean_input   = true
}

resource "azurerm_storage_account" "this" {
  name                     = azurecaf_name.storage_account.result
  resource_group_name      = data.azurerm_resource_group.rg.name
  location                 = data.azurerm_resource_group.rg.location
  account_tier             = var.account_tier
  account_replication_type = var.account_replication_type

  allow_nested_items_to_be_public = false
  public_network_access_enabled   = var.public_network_access_enabled

  tags = merge(local.common_tags, var.tags)
}


module "private_endpoint_file" {
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

  resource_group_name       = module.global_constants_file.private_endpoint["resource_group_name"]
  private_endpoint_instance = var.private_endpoint_file["instance"]

  subnet = {
    name                        = module.global_constants_file.private_endpoint["subnet"]["name"]
    network_name                = module.global_constants_file.private_endpoint["subnet"]["network_name"]
    network_resource_group_name = module.global_constants_file.private_endpoint["subnet"]["network_resource_group_name"]
  }

  private_dns_zone = module.global_constants_file.private_dns_zone["service"]["storage_account_file"]["id"] != null ? {
    resource_group_name = module.global_constants_file.private_dns_zone["resource_group_name"]
    id                  = module.global_constants_file.private_dns_zone["service"]["storage_account_file"]["id"]
    name                = module.global_constants_file.private_dns_zone["service"]["storage_account_file"]["name"]
  } : null

  private_connection_resource_id = azurerm_storage_account.this.id
  is_manual_connection           = false
  subresource_names              = ["file"]

  tags = var.tags
}

module "private_endpoint_blob" {
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

  resource_group_name       = module.global_constants_blob.private_endpoint["resource_group_name"]
  private_endpoint_instance = var.private_endpoint_blob["instance"]

  subnet = {
    name                        = module.global_constants_blob.private_endpoint["subnet"]["name"]
    network_name                = module.global_constants_blob.private_endpoint["subnet"]["network_name"]
    network_resource_group_name = module.global_constants_blob.private_endpoint["subnet"]["network_resource_group_name"]
  }

  private_dns_zone = module.global_constants_blob.private_dns_zone["service"]["storage_account_blob"]["id"] != null ? {
    resource_group_name = module.global_constants_blob.private_dns_zone["resource_group_name"]
    id                  = module.global_constants_blob.private_dns_zone["service"]["storage_account_blob"]["id"]
    name                = module.global_constants_blob.private_dns_zone["service"]["storage_account_blob"]["name"]
  } : null

  private_connection_resource_id = azurerm_storage_account.this.id
  is_manual_connection           = false
  subresource_names              = ["blob"]

  tags = var.tags

}
