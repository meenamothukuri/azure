output "agw_name" {
  value = var.create_updatable_agw ? azurerm_application_gateway.this_updatable[0].name : azurerm_application_gateway.this[0].name
}

output "agw_id" {
  value = var.create_updatable_agw ? azurerm_application_gateway.this_updatable[0].id : azurerm_application_gateway.this[0].id
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
