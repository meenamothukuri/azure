resource "azurecaf_name" "public_ip" {
  resource_type = "azurerm_public_ip"
  prefixes      = [format("%s%s", var.global_hyperscaler, var.global_hyperscaler_location), var.materna_customer_name]
  suffixes      = [var.materna_project_number, var.global_stage, format("%02d", var.public_ip_instance)]
  clean_input   = true
}


resource "azurerm_public_ip" "this" {
  name                    = lower(azurecaf_name.public_ip.result)
  resource_group_name     = data.azurerm_resource_group.rg.name
  location                = data.azurerm_resource_group.rg.location
  allocation_method       = "Static"
  ddos_protection_mode    = "VirtualNetworkInherited"
  ddos_protection_plan_id = null
  sku                     = "Standard"
  sku_tier                = "Regional"

  tags = merge(local.common_tags, var.tags)
}
