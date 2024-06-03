output "sql_id" {
  value = azurerm_mssql_server.this.id
}

output "sql_name" {
  value = azurerm_mssql_server.this.name
}

output "sql_fqdn" {
  value = azurerm_mssql_server.this.fully_qualified_domain_name
}

output "rg_name" {
  value = data.azurerm_resource_group.rg.name
}

output "rg_id" {
  value = data.azurerm_resource_group.rg.id
}

output "subscription_id" {
  value = var.global_subscription_id
}

output "sqldb_id" {
  value = {
    for k, v in azurerm_mssql_database.this : k => v.id
  }
}

output "sqldb_name" {
  value = {
    for k, v in azurerm_mssql_database.this : k => v.name
  }
}
