data "azurerm_resource_group" "rg" {
  name = var.resource_group_name
}

data "azurerm_private_dns_zone" "this" {
  for_each            = var.private_dns_zones
  name                = each.value["name"]
  resource_group_name = each.value["resource_group_name"]
}
