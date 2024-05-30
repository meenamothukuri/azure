module "global_constants" {
  source  = "gitlab.prd.materna.work/registries/az-global-constants/azure"
  version = "1.1.0"

  global_hyperscaler = var.global_hyperscaler

  private_dns_zone = var.private_endpoint["custom_private_dns_zone"]
  private_endpoint = var.private_endpoint["custom_config"]
}


resource "azurecaf_name" "key_vault" {
  resource_type = "azurerm_key_vault"
  prefixes      = [format("%s%s", var.global_hyperscaler, var.global_hyperscaler_location), var.materna_customer_name]
  suffixes      = [var.materna_project_number, var.global_stage, format("%02d", var.key_vault_instance)]
  clean_input   = true
  separator     = "" # Max 24 Characters
}


resource "azurerm_key_vault" "this" {
  name                            = lower(azurecaf_name.key_vault.result)
  location                        = data.azurerm_resource_group.rg.location
  resource_group_name             = data.azurerm_resource_group.rg.name
  enabled_for_disk_encryption     = true
  enabled_for_deployment          = true
  enabled_for_template_deployment = true
  enable_rbac_authorization       = true
  tenant_id                       = var.global_tenant_id
  soft_delete_retention_days      = 7

  # Needs to be enabled: "validating Key Vault "XXX" (Resource Group "XXX") for Disk Encryption Set: Purge Protection must be enabled but it isn't!"
  purge_protection_enabled      = true
  public_network_access_enabled = var.public_endpoint_enabled


  # When enabledForDiskEncryption is true, networkAcls.bypass must include "AzureServices".
  network_acls {
    bypass         = "AzureServices"
    default_action = var.source_ip_filter == null ? "Allow" : "Deny"
    ip_rules       = var.source_ip_filter
  }

  sku_name = var.sku_tier

  tags = merge(local.common_tags, var.tags)

  lifecycle {
    ignore_changes = [
      location
    ]
  }

}

resource "azurerm_role_assignment" "admin" {
  scope                = azurerm_key_vault.this.id
  role_definition_name = "Key Vault Administrator"
  principal_id         = data.azurerm_client_config.current.object_id
  lifecycle {
    ignore_changes = [
      principal_id
    ]
  }
}

resource "azurerm_role_assignment" "hashicorp_vault_kvsu" {
  count = var.hashicorp_vault == null ? 0 : 1

  scope                = azurerm_key_vault.this.id
  role_definition_name = "Key Vault Secrets User"
  principal_id         = data.azuread_service_principal.hashicorp_vault[0].id
  lifecycle {
    ignore_changes = [
      principal_id
    ]
  }
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

  private_dns_zone = module.global_constants.private_dns_zone["service"]["key_vault"]["id"] != null ? {
    resource_group_name = module.global_constants.private_dns_zone["resource_group_name"]
    id                  = module.global_constants.private_dns_zone["service"]["key_vault"]["id"]
    name                = module.global_constants.private_dns_zone["service"]["key_vault"]["name"]
  } : null

  private_connection_resource_id = azurerm_key_vault.this.id
  is_manual_connection           = false
  subresource_names              = ["vault"]


  tags = var.tags
}
