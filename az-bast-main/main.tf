resource "azurecaf_name" "bastion_host" {
  resource_type = "azurerm_bastion_host"
  prefixes      = [format("%s%s", var.global_hyperscaler, var.global_hyperscaler_location), var.materna_customer_name]
  suffixes      = [var.materna_project_number, var.global_stage, format("%02d", var.bastion_host_instance)]
  clean_input   = true
}

resource "azurerm_bastion_host" "this" {
  name                = lower(azurecaf_name.bastion_host.result)
  location            = data.azurerm_resource_group.rg.location
  resource_group_name = data.azurerm_resource_group.rg.name
  sku                 = "Standard"
  scale_units         = 2
  tunneling_enabled   = true

  ip_configuration {
    name                 = "configuration"
    subnet_id            = data.azurerm_subnet.snet.id
    public_ip_address_id = data.azurerm_public_ip.pip.id
  }
  tags = merge(local.common_tags, var.tags)

}

resource "azurerm_role_assignment" "reader_groups" {
  for_each             = toset(var.reader_groups)
  scope                = azurerm_bastion_host.this.id
  role_definition_name = "Reader"
  principal_id         = data.azuread_group.reader_groups[each.key].object_id
}
