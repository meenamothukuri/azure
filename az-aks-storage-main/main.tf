resource "azurecaf_name" "role_definition_disk_operations" {
  resource_type = "azurerm_role_definition"
  prefixes      = [format("%s%s", var.global_hyperscaler, var.global_hyperscaler_location), var.materna_customer_name]
  suffixes      = [var.materna_project_number, var.global_stage, format("%02d", var.aks["instance_id"])]
  clean_input   = true
}


resource "azurerm_role_definition" "disk_operations" {
  count = var.enable_full_subscription_contributor_rights == true ? 0 : (var.disk_access_endpoint == null ? 0 : 1)

  name        = azurecaf_name.role_definition_disk_operations.result
  scope       = data.azurerm_subscription.this.id
  description = "Disk Operations"

  permissions {
    actions = [
      "Microsoft.Compute/disks/read",
      "Microsoft.Compute/disks/write",
      "Microsoft.Compute/disks/delete"
    ]
    not_actions = []
  }
  assignable_scopes = [
    data.azurerm_subscription.this.id,
  ]
  lifecycle {
    ignore_changes = [
      scope,
    ]
  }
}


resource "azurerm_role_assignment" "da" {
  count = var.disk_access_endpoint == null ? 0 : 1

  scope                = module.disk_access[0].da_id
  role_definition_name = "Reader"
  principal_id         = data.azurerm_user_assigned_identity.this.principal_id
  lifecycle {
    ignore_changes = [
      scope,
      principal_id
    ]
  }
}

resource "azurerm_role_assignment" "st" {
  count                = var.storage_account_endpoint == null ? 0 : 1
  scope                = module.storage_account[0].st_id
  role_definition_name = "Contributor"
  principal_id         = data.azurerm_user_assigned_identity.this.principal_id
  lifecycle {
    ignore_changes = [
      scope,
      principal_id
    ]
  }
}

resource "azurerm_role_assignment" "disk_operations" {
  count = var.disk_access_endpoint == null ? 0 : 1

  scope                = data.azurerm_subscription.this.id
  role_definition_id   = var.enable_full_subscription_contributor_rights == false ? azurerm_role_definition.disk_operations[0].role_definition_resource_id : null
  role_definition_name = var.enable_full_subscription_contributor_rights == false ? null : "Contributor"
  principal_id         = data.azurerm_user_assigned_identity.this.principal_id
  lifecycle {
    ignore_changes = [
      scope,
      principal_id
    ]
  }
}

module "disk_access" {
  count = var.disk_access_endpoint == null ? 0 : 1
  providers = {
    azurerm        = azurerm,
    azurerm.common = azurerm.common
  }

  source  = "gitlab.prd.materna.work/registries/az-da/azure"
  version = "1.1.0"
  #source = "git@gitlab.prd.materna.work:components/terraform/azure/az-da.git"

  global_subscription_id      = data.azurerm_subscription.this.subscription_id
  global_stage                = var.global_stage
  global_hyperscaler          = var.global_hyperscaler
  global_hyperscaler_location = var.global_hyperscaler_location

  materna_customer_name  = var.materna_customer_name
  materna_project_number = var.materna_project_number
  materna_cost_center    = var.materna_cost_center

  resource_group_name = var.aks["resource_group_name"]

  private_endpoint = {
    instance                = var.disk_access_endpoint["instance"]
    custom_private_dns_zone = var.disk_access_endpoint["custom_private_dns_zone"]
    custom_config           = var.disk_access_endpoint["custom_config"]
  }

  tags = var.tags
}

module "storage_account" {
  count = var.storage_account_endpoint == null ? 0 : 1
  providers = {
    azurerm        = azurerm,
    azurerm.common = azurerm.common
  }

  source  = "gitlab.prd.materna.work/registries/az-st/azure"
  version = "1.1.0"
  #source = "git@gitlab.prd.materna.work:components/terraform/azure/az-st.git"

  global_subscription_id      = data.azurerm_subscription.this.subscription_id
  global_stage                = var.global_stage
  global_hyperscaler          = var.global_hyperscaler
  global_hyperscaler_location = var.global_hyperscaler_location

  materna_customer_name  = var.materna_customer_name
  materna_project_number = var.materna_project_number
  materna_cost_center    = var.materna_cost_center

  resource_group_name = var.aks["resource_group_name"]

  storage_account_instance = var.storage_account_instance

  private_endpoint_blob = {
    instance                = var.storage_account_endpoint["blob_instance"]
    custom_private_dns_zone = var.storage_account_endpoint["custom_private_dns_zone"]
    custom_config           = var.storage_account_endpoint["custom_config"]
  }

  private_endpoint_file = {
    instance                = var.storage_account_endpoint["file_instance"]
    custom_private_dns_zone = var.storage_account_endpoint["custom_private_dns_zone"]
    custom_config           = var.storage_account_endpoint["custom_config"]
  }

  tags = var.tags
}


################################################################
################# Remove Default Storage Class #################
################################################################
resource "kubernetes_annotations" "default_storageclass" {
  count = var.apply_kubernetes == false ? 0 : (var.disk_access_endpoint == null && var.storage_account_endpoint == null ? 0 : 1)

  api_version = "storage.k8s.io/v1"
  kind        = "StorageClass"
  force       = "true"

  metadata {
    name = "default"
  }
  annotations = {
    "storageclass.kubernetes.io/is-default-class" = "false"
  }
}

################################################################
##################### Disk Storage Classes #####################
################################################################

resource "kubernetes_storage_class_v1" "disk_retain_immediate" {
  count = var.apply_kubernetes == false ? 0 : (var.disk_access_endpoint == null ? 0 : 1)

  metadata {
    name = "j2cp-disk-storage-retain-immediate"
    annotations = {
      "storageclass.kubernetes.io/is-default-class" = "true"
    }
  }
  storage_provisioner    = "kubernetes.io/azure-disk"
  reclaim_policy         = "Retain"
  volume_binding_mode    = "Immediate"
  allow_volume_expansion = true
  parameters = {
    diskAccessID        = module.disk_access[0].da_id
    resourceGroup       = data.azurerm_resource_group.this.name
    location            = data.azurerm_resource_group.this.location
    networkAccessPolicy = "AllowPrivate"
    skuName             = "StandardSSD_LRS" # Premium_LRS uses Premium SSD
    diskEncryptionSetID = var.encryption == null ? null : data.azurerm_disk_encryption_set.des[0].id

  }
  lifecycle {
    ignore_changes = [
      parameters
    ]
  }
}

resource "kubernetes_storage_class_v1" "disk_retain_wait_for_first_consumer" {
  count = var.apply_kubernetes == false ? 0 : (var.disk_access_endpoint == null ? 0 : 1)

  metadata {
    name = "j2cp-disk-storage-retain-waitforfirstconsumer"
  }
  storage_provisioner    = "kubernetes.io/azure-disk"
  reclaim_policy         = "Retain"
  volume_binding_mode    = "WaitForFirstConsumer"
  allow_volume_expansion = true
  parameters = {
    diskAccessID        = module.disk_access[0].da_id
    resourceGroup       = data.azurerm_resource_group.this.name
    location            = data.azurerm_resource_group.this.location
    networkAccessPolicy = "AllowPrivate"
    skuName             = "StandardSSD_LRS" # Premium_LRS uses Premium SSD
    diskEncryptionSetID = var.encryption == null ? null : data.azurerm_disk_encryption_set.des[0].id
  }
  lifecycle {
    ignore_changes = [
      parameters
    ]
  }
}


resource "kubernetes_storage_class_v1" "disk_delete_immediate" {
  count = var.apply_kubernetes == false ? 0 : (var.disk_access_endpoint == null ? 0 : 1)

  metadata {
    name = "j2cp-disk-storage-delete-immediate"
  }
  storage_provisioner    = "kubernetes.io/azure-disk"
  reclaim_policy         = "Delete"
  volume_binding_mode    = "Immediate"
  allow_volume_expansion = true
  parameters = {
    diskAccessID        = module.disk_access[0].da_id
    resourceGroup       = data.azurerm_resource_group.this.name
    location            = data.azurerm_resource_group.this.location
    networkAccessPolicy = "AllowPrivate"
    skuName             = "StandardSSD_LRS" # Premium_LRS uses Premium SSD
    diskEncryptionSetID = var.encryption == null ? null : data.azurerm_disk_encryption_set.des[0].id
  }
  lifecycle {
    ignore_changes = [
      parameters
    ]
  }
}

resource "kubernetes_storage_class_v1" "disk_delete_wait_for_first_consumer" {
  count = var.apply_kubernetes == false ? 0 : (var.disk_access_endpoint == null ? 0 : 1)

  metadata {
    name = "j2cp-disk-storage-delete-waitforfirstconsumer"
  }
  storage_provisioner    = "kubernetes.io/azure-disk"
  reclaim_policy         = "Delete"
  volume_binding_mode    = "WaitForFirstConsumer"
  allow_volume_expansion = true
  parameters = {
    diskAccessID        = module.disk_access[0].da_id
    resourceGroup       = data.azurerm_resource_group.this.name
    location            = data.azurerm_resource_group.this.location
    networkAccessPolicy = "AllowPrivate"
    skuName             = "StandardSSD_LRS" # Premium_LRS uses Premium SSD
    diskEncryptionSetID = var.encryption == null ? null : data.azurerm_disk_encryption_set.des[0].id
  }
  lifecycle {
    ignore_changes = [
      parameters
    ]
  }
}

################################################################
##################### File Storage Classes #####################
################################################################
resource "kubernetes_storage_class_v1" "file_retain_immediate" {
  count = var.apply_kubernetes == false ? 0 : (var.storage_account_endpoint == null ? 0 : 1)

  metadata {
    name = "j2cp-file-storage-retain-immediate"
    annotations = {
      "storageclass.kubernetes.io/is-default-class" = var.disk_access_endpoint == null ? "true" : "false"
    }
  }
  storage_provisioner    = "kubernetes.io/azure-file"
  reclaim_policy         = "Retain"
  volume_binding_mode    = "Immediate"
  allow_volume_expansion = true
  parameters = {
    resourceGroup  = data.azurerm_resource_group.this.name
    location       = data.azurerm_resource_group.this.location
    storageAccount = module.storage_account[0].st_name
    skuName        = "Standard_LRS"
  }
  lifecycle {
    ignore_changes = [
      parameters
    ]
  }
}

resource "kubernetes_storage_class_v1" "file_retain_wait_for_first_consumer" {
  count = var.apply_kubernetes == false ? 0 : (var.storage_account_endpoint == null ? 0 : 1)

  metadata {
    name = "j2cp-file-storage-retain-waitforfirstconsumer"
  }
  storage_provisioner    = "kubernetes.io/azure-file"
  reclaim_policy         = "Retain"
  volume_binding_mode    = "WaitForFirstConsumer"
  allow_volume_expansion = true
  parameters = {
    resourceGroup  = data.azurerm_resource_group.this.name
    location       = data.azurerm_resource_group.this.location
    storageAccount = module.storage_account[0].st_name
    skuName        = "Standard_LRS"
  }
  lifecycle {
    ignore_changes = [
      parameters
    ]
  }
}


resource "kubernetes_storage_class_v1" "file_delete_immediate" {
  count = var.apply_kubernetes == false ? 0 : (var.storage_account_endpoint == null ? 0 : 1)

  metadata {
    name = "j2cp-file-storage-delete-immediate"
  }
  storage_provisioner    = "kubernetes.io/azure-file"
  reclaim_policy         = "Delete"
  volume_binding_mode    = "Immediate"
  allow_volume_expansion = true
  parameters = {
    resourceGroup  = data.azurerm_resource_group.this.name
    location       = data.azurerm_resource_group.this.location
    storageAccount = module.storage_account[0].st_name
    skuName        = "Standard_LRS"
  }
  lifecycle {
    ignore_changes = [
      parameters
    ]
  }
}

resource "kubernetes_storage_class_v1" "file_delete_wait_for_first_consumer" {
  count = var.apply_kubernetes == false ? 0 : (var.storage_account_endpoint == null ? 0 : 1)

  metadata {
    name = "j2cp-file-storage-delete-waitforfirstconsumer"
  }
  storage_provisioner    = "kubernetes.io/azure-file"
  reclaim_policy         = "Delete"
  volume_binding_mode    = "WaitForFirstConsumer"
  allow_volume_expansion = true
  parameters = {
    resourceGroup  = data.azurerm_resource_group.this.name
    location       = data.azurerm_resource_group.this.location
    storageAccount = module.storage_account[0].st_name
    skuName        = "Standard_LRS"
  }
  lifecycle {
    ignore_changes = [
      parameters
    ]
  }
}
