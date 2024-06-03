resource "azurecaf_name" "disk_encryption_set" {
  resource_type = "azurerm_disk_encryption_set"
  prefixes      = [format("%s%s", var.global_hyperscaler, var.global_hyperscaler_location), var.materna_customer_name]
  suffixes      = [var.materna_project_number, var.global_stage, format("%02d", var.disk_encryption_set_instance)]
  clean_input   = true
}

resource "azurecaf_name" "key_vault_key" {
  resource_type = "azurerm_key_vault_key"
  prefixes      = [format("%s%s", var.global_hyperscaler, var.global_hyperscaler_location), var.materna_customer_name]
  suffixes      = [var.materna_project_number, var.global_stage, format("%02d", var.key_vault_key_instance)]
  clean_input   = true
}


# DNS problem currently
# https://github.com/hashicorp/terraform-provider-azurerm/issues/9738
resource "azurerm_key_vault_key" "this" {
  provider = azurerm.common

  name         = lower(azurecaf_name.key_vault_key.result)
  key_vault_id = data.azurerm_key_vault.key_vault.id
  key_type     = "RSA"
  key_size     = 2048

  key_opts = [
    "decrypt",
    "encrypt",
    "sign",
    "unwrapKey",
    "verify",
    "wrapKey",
  ]
  tags = merge(local.common_tags, var.tags)
  lifecycle {
    ignore_changes = [
      key_vault_id
    ]
  }
}

# https://learn.microsoft.com/en-us/answers/questions/165678/how-to-configure-azure-disk-encryption-on-a-vm-wit
resource "azurerm_disk_encryption_set" "this" {
  name                = lower(azurecaf_name.disk_encryption_set.result)
  location            = data.azurerm_resource_group.rg.location
  resource_group_name = data.azurerm_resource_group.rg.name
  key_vault_key_id    = azurerm_key_vault_key.this.id

  identity {
    type = "SystemAssigned"
  }
  tags = merge(local.common_tags, var.tags)

  lifecycle {
    ignore_changes = [
      location
    ]
  }
}

resource "azurerm_role_assignment" "des" {
  scope                = azurerm_key_vault_key.this.resource_versionless_id
  role_definition_name = "Key Vault Crypto Service Encryption User"
  principal_id         = azurerm_disk_encryption_set.this.identity[0].principal_id
  lifecycle {
    ignore_changes = [
      principal_id,
      scope
    ]
  }
}
