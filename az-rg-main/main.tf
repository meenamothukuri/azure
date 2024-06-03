resource "azurecaf_name" "rg" {
  resource_type = "azurerm_resource_group"
  prefixes      = [format("%s%s", var.global_hyperscaler, var.global_hyperscaler_location), var.materna_customer_name]
  suffixes      = [var.materna_project_number, var.global_stage, format("%02d", var.resource_group_instance)]
  clean_input   = true
}

resource "azurerm_resource_group" "this" {
  name     = lower(azurecaf_name.rg.result)
  location = var.resource_group_location
  tags     = merge(local.common_tags, var.tags)

  lifecycle {
    ignore_changes = [
      tags
    ]
  }
}
