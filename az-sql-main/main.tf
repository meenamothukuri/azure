module "global_constants" {
  source  = "gitlab.prd.materna.work/registries/az-global-constants/azure"
  version = "1.3.0"

  global_hyperscaler = var.global_hyperscaler

  private_dns_zone = var.private_endpoint == null ? null : var.private_endpoint["custom_private_dns_zone"]
  private_endpoint = var.private_endpoint == null ? null : var.private_endpoint["custom_config"]
}

resource "azurecaf_name" "mssql_server" {
  resource_type = "azurerm_mssql_server"
  prefixes      = [format("%s%s", var.global_hyperscaler, var.global_hyperscaler_location), var.materna_customer_name]
  suffixes      = [var.materna_project_number, var.global_stage, format("%02d", var.sql_instance)]
  clean_input   = true
}

resource "azurecaf_name" "mssql_databases" {
  for_each      = var.sql_databases
  resource_type = "azurerm_mssql_database"
  prefixes      = [format("%s%s", var.global_hyperscaler, var.global_hyperscaler_location), var.materna_customer_name]
  suffixes      = ["${var.materna_project_number}${each.key}", var.global_stage, format("%02d", var.sql_instance)]
  clean_input   = true
}

resource "azurecaf_name" "identity" {
  resource_type = "azurerm_user_assigned_identity"
  prefixes      = [format("%s%s", var.global_hyperscaler, var.global_hyperscaler_location), var.materna_customer_name]
  suffixes      = ["${var.materna_project_number}sql", var.global_stage, format("%02d", var.sql_instance)]
  clean_input   = true
}

resource "azurerm_user_assigned_identity" "identity" {
  name                = azurecaf_name.identity.result
  location            = data.azurerm_resource_group.rg.location
  resource_group_name = data.azurerm_resource_group.rg.name
}

resource "azurerm_mssql_server" "this" {
  name                         = azurecaf_name.mssql_server.result
  resource_group_name          = data.azurerm_resource_group.rg.name
  location                     = data.azurerm_resource_group.rg.location
  version                      = var.sql_server["version"]
  administrator_login          = var.sql_server["admin_username"]
  administrator_login_password = var.sql_server["admin_password"]
  minimum_tls_version          = var.sql_server["min_tls_version"]

  public_network_access_enabled        = var.sql_server["public_network_access_enabled"]
  outbound_network_restriction_enabled = var.sql_server["outbound_network_restriction_enabled"]

  azuread_administrator {
    login_username              = azurerm_user_assigned_identity.identity.name
    object_id                   = azurerm_user_assigned_identity.identity.principal_id
    azuread_authentication_only = false
  }

  identity {
    type         = "UserAssigned"
    identity_ids = [azurerm_user_assigned_identity.identity.id]
  }

  primary_user_assigned_identity_id = azurerm_user_assigned_identity.identity.id

  tags = merge(local.common_tags, var.tags)

}

resource "azurerm_mssql_database" "this" {
  depends_on = [module.private_endpoint]

  for_each                       = var.sql_databases
  name                           = each.value["custom_name"] == null ? azurecaf_name.mssql_databases[each.key].result : each.value["custom_name"]
  server_id                      = azurerm_mssql_server.this.id
  collation                      = each.value["collation"]
  license_type                   = each.value["license_type"]
  max_size_gb                    = each.value["max_size_gb"]
  read_scale                     = false
  sku_name                       = each.value["sku_name"]
  zone_redundant                 = false
  storage_account_type           = each.value["storage_account_type"]
  restore_dropped_database_id    = each.value["restore_dropped_database_id"]
  recover_database_id            = each.value["recover_database_id"]
  restore_point_in_time          = each.value["restore_point_in_time"]
  min_capacity                   = each.value["min_capacity"]
  ledger_enabled                 = each.value["ledger_enabled"]
  maintenance_configuration_name = each.value["maintenance_configuration_name"]
  creation_source_database_id    = each.value["creation_source_database_id"]
  create_mode                    = each.value["create_mode"]
  auto_pause_delay_in_minutes    = each.value["auto_pause_delay_in_minutes"]

  dynamic "short_term_retention_policy" {
    for_each = toset(each.value["short_term_retention_policy"] == null ? [] : ["1"])
    content {
      retention_days           = each.value["short_term_retention_policy"]["retention_days"]
      backup_interval_in_hours = each.value["short_term_retention_policy"]["backup_interval_in_hours"]
    }
  }

  dynamic "long_term_retention_policy" {
    for_each = toset(each.value["long_term_retention_policy"] == null ? [] : ["1"])
    content {
      weekly_retention  = each.value["long_term_retention_policy"]["weekly_retention"]
      monthly_retention = each.value["long_term_retention_policy"]["monthly_retention"]
      yearly_retention  = each.value["long_term_retention_policy"]["yearly_retention"]
      week_of_year      = each.value["long_term_retention_policy"]["week_of_year"]
    }
  }

  tags = merge(local.common_tags, var.tags)
}


module "private_endpoint" {
  providers = {
    azurerm = azurerm.common
  }
  source  = "gitlab.prd.materna.work/registries/az-pe/azure"
  version = "1.0.0"

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

  private_dns_zone = module.global_constants.private_dns_zone["service"]["sql_server"]["id"] != null ? {
    resource_group_name = module.global_constants.private_dns_zone["resource_group_name"]
    id                  = module.global_constants.private_dns_zone["service"]["sql_server"]["id"]
    name                = module.global_constants.private_dns_zone["service"]["sql_server"]["name"]
  } : null

  private_connection_resource_id = azurerm_mssql_server.this.id
  is_manual_connection           = false
  subresource_names              = ["sqlServer"]

  tags = var.tags
}


