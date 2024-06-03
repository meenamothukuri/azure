resource "azurerm_dns_zone" "this" {
  name                = var.domain_name
  resource_group_name = data.azurerm_resource_group.rg.name

  tags = merge(local.common_tags, var.tags)
}

resource "azurerm_dns_a_record" "this" {
  for_each            = var.dns_a_records
  name                = each.value["name"]
  zone_name           = azurerm_dns_zone.this.name
  resource_group_name = azurerm_dns_zone.this.resource_group_name
  ttl                 = each.value["ttl"]
  records             = each.value["records"]

  tags = merge(local.common_tags, var.tags)
}

resource "azurerm_dns_ns_record" "this" {
  for_each            = var.dns_ns_records
  name                = each.value["name"]
  zone_name           = azurerm_dns_zone.this.name
  resource_group_name = azurerm_dns_zone.this.resource_group_name
  ttl                 = each.value["ttl"]
  records             = each.value["records"]

  tags = merge(local.common_tags, var.tags)
}


# https://github.com/kubernetes-sigs/external-dns/blob/master/docs/tutorials/azure.md#assign-the-rights-for-the-service-principal 
resource "azurerm_role_assignment" "external_dns_zone_contributor" {
  count                = var.external_dns_service_principal_name == null ? 0 : 1
  scope                = azurerm_dns_zone.this.id
  role_definition_name = "Contributor"
  principal_id         = data.azuread_service_principal.external_dns[0].object_id
  lifecycle {
    ignore_changes = [
      scope,
      principal_id
    ]
  }
}

resource "azurerm_role_assignment" "external_dns_rg_reader" {
  count                = var.external_dns_service_principal_name == null ? 0 : 1
  scope                = data.azurerm_resource_group.rg.id
  role_definition_name = "Reader"
  principal_id         = data.azuread_service_principal.external_dns[0].object_id
  lifecycle {
    ignore_changes = [
      scope,
      principal_id
    ]
  }
}
