module "resource_group" {
  source  = "gitlab.prd.materna.work/registries/az-rg/azure"
  version = "1.0.0"

  global_subscription_id      = local.global_subscription_id
  global_stage                = local.global_stage
  global_hyperscaler          = local.global_hyperscaler
  global_hyperscaler_location = local.global_hyperscaler_location

  materna_customer_name  = local.materna_customer_name
  materna_project_number = local.materna_project_number
  materna_cost_center    = local.materna_cost_center

  resource_group_location = "germanywestcentral"
  resource_group_instance = 1

  tags = local.tags
}

module "route_table" {
  source  = "gitlab.prd.materna.work/registries/az-route/azure"
  version = "1.0.1"

  global_subscription_id      = local.global_subscription_id
  global_stage                = local.global_stage
  global_hyperscaler          = local.global_hyperscaler
  global_hyperscaler_location = local.global_hyperscaler_location

  materna_customer_name  = local.materna_customer_name
  materna_project_number = local.materna_project_number
  materna_cost_center    = local.materna_cost_center

  resource_group_name = module.resource_group.rg_name

  tags = local.tags
}

module "public_ip_ngw" {
  source  = "gitlab.prd.materna.work/registries/az-pip/azure"
  version = "1.0.0"

  global_subscription_id      = local.global_subscription_id
  global_stage                = local.global_stage
  global_hyperscaler          = local.global_hyperscaler
  global_hyperscaler_location = local.global_hyperscaler_location

  materna_customer_name  = local.materna_customer_name
  materna_project_number = local.materna_project_number
  materna_cost_center    = local.materna_cost_center

  resource_group_name = module.resource_group.rg_name
  public_ip_instance  = 2

  tags = local.tags
}


module "nat_gateway" {
  source  = "gitlab.prd.materna.work/registries/az-ngw/azure"
  version = "1.0.0"

  global_subscription_id      = local.global_subscription_id
  global_stage                = local.global_stage
  global_hyperscaler          = local.global_hyperscaler
  global_hyperscaler_location = local.global_hyperscaler_location

  materna_customer_name  = local.materna_customer_name
  materna_project_number = local.materna_project_number
  materna_cost_center    = local.materna_cost_center

  resource_group_name = module.resource_group.rg_name

  public_ip = {
    name                = module.public_ip_ngw.pip_name
    resource_group_name = module.public_ip_ngw.rg_name
  }

  nat_gateway_instance = 1

  tags = local.tags
}

module "subnet" {
  source  = "gitlab.prd.materna.work/registries/az-snet/azure"
  version = "1.0.0"

  global_subscription_id      = local.global_subscription_id
  global_stage                = local.global_stage
  global_hyperscaler          = local.global_hyperscaler
  global_hyperscaler_location = local.global_hyperscaler_location

  materna_customer_name  = local.materna_customer_name
  materna_project_number = local.materna_project_number
  materna_cost_center    = local.materna_cost_center

  resource_group_name = local.network_resource_group_name
  subnet_instance     = 1
  vnet_name           = local.vnet_name
  address_prefix      = "10.26.6.192/28"

  associated_route_table = {
    name                = module.route_table.route_name
    resource_group_name = module.route_table.rg_name
  }
  nat_gateway = {
    name                = module.nat_gateway.ngw_name
    resource_group_name = module.nat_gateway.rg_name
  }
}


module "subnet_agw" {
  source  = "gitlab.prd.materna.work/registries/az-snet/azure"
  version = "1.0.0"

  global_subscription_id      = local.global_subscription_id
  global_stage                = local.global_stage
  global_hyperscaler          = local.global_hyperscaler
  global_hyperscaler_location = local.global_hyperscaler_location

  materna_customer_name  = local.materna_customer_name
  materna_project_number = local.materna_project_number
  materna_cost_center    = local.materna_cost_center

  resource_group_name = local.network_resource_group_name
  subnet_instance     = 2
  vnet_name           = local.vnet_name
  address_prefix      = "10.26.6.176/29"

  associated_route_table = {
    name                = module.route_table.route_name
    resource_group_name = module.route_table.rg_name
  }
}


module "public_ip_agw" {
  source  = "gitlab.prd.materna.work/registries/az-pip/azure"
  version = "1.0.0"

  global_subscription_id      = local.global_subscription_id
  global_stage                = local.global_stage
  global_hyperscaler          = local.global_hyperscaler
  global_hyperscaler_location = local.global_hyperscaler_location

  materna_customer_name  = local.materna_customer_name
  materna_project_number = local.materna_project_number
  materna_cost_center    = local.materna_cost_center

  resource_group_name = module.resource_group.rg_name
  public_ip_instance  = 1


  tags = local.tags
}

module "agw" {
  source  = "gitlab.prd.materna.work/registries/az-agw/azure"
  version = "1.0.0"

  global_subscription_id      = local.global_subscription_id
  global_stage                = local.global_stage
  global_hyperscaler          = local.global_hyperscaler
  global_hyperscaler_location = local.global_hyperscaler_location

  materna_customer_name  = local.materna_customer_name
  materna_project_number = local.materna_project_number
  materna_cost_center    = local.materna_cost_center

  resource_group_name         = module.resource_group.rg_name
  public_ip_name              = module.public_ip_agw.pip_name
  agic_service_principal_name = local.agic_service_principal_name

  subnet = {
    name                        = module.subnet_agw.snet_name
    network_name                = module.subnet_agw.vnet_name
    network_resource_group_name = module.subnet_agw.rg_name
  }
  tags = local.tags

}

module "key_vault" {
  providers = {
    azurerm        = azurerm,
    azurerm.common = azurerm.common
  }
  source  = "gitlab.prd.materna.work/registries/az-kv/azure"
  version = "1.1.0"

  global_subscription_id      = local.global_subscription_id
  global_stage                = local.global_stage
  global_tenant_id            = local.global_tenant_id
  global_hyperscaler          = local.global_hyperscaler
  global_hyperscaler_location = local.global_hyperscaler_location

  materna_customer_name  = local.materna_customer_name
  materna_project_number = local.materna_project_number
  materna_cost_center    = local.materna_cost_center

  resource_group_name = module.resource_group.rg_name

  tags = local.tags

  key_vault_instance = 1

  private_endpoint = {
    instance      = 4
    custom_config = local.private_endpoint_config
  }
}

module "disk_encryption_set" {
  source  = "gitlab.prd.materna.work/registries/az-des/azure"
  version = "1.0.0"
  providers = {
    azurerm        = azurerm,
    azurerm.common = azurerm.common
  }

  global_subscription_id      = local.global_subscription_id
  global_stage                = local.global_stage
  global_hyperscaler          = local.global_hyperscaler
  global_hyperscaler_location = local.global_hyperscaler_location

  materna_customer_name  = local.materna_customer_name
  materna_project_number = local.materna_project_number
  materna_cost_center    = local.materna_cost_center

  resource_group_name = module.resource_group.rg_name

  tags = local.tags

  disk_encryption_set_instance = 1
  key_vault_key_instance       = 1

  key_vault = {
    name                = module.key_vault.kv_name
    resource_group_name = module.key_vault.rg_name
  }
}


module "aks" {
  source  = "gitlab.prd.materna.work/registries/az-aks/azure"
  version = "1.0.0"

  # Route table association requiered at this point
  depends_on = [
    module.subnet,
    module.nat_gateway,
    module.disk_encryption_set,
    module.key_vault
  ]
  providers = {
    helm           = helm.this,
    azurerm        = azurerm,
    azurerm.common = azurerm.common
  }
  global_subscription_id      = local.global_subscription_id
  global_tenant_id            = local.global_tenant_id
  global_stage                = local.global_stage
  global_hyperscaler          = local.global_hyperscaler
  global_hyperscaler_location = local.global_hyperscaler_location

  materna_customer_name  = local.materna_customer_name
  materna_project_number = local.materna_project_number
  materna_cost_center    = local.materna_cost_center

  aks_resourcegroup_name      = module.resource_group.rg_name
  aks_cluster_admins          = ["j2cp-aks-admin", "j2cp-aks-contributor"]
  aks_kubernetes_version      = "1.25.5"
  agic_service_principal_name = local.agic_service_principal_name

  system_node_pool = {
    subnet = {
      name                        = module.subnet.snet_name
      network_name                = module.subnet.vnet_name
      network_resource_group_name = module.subnet.rg_name
    }
  }

  application_gateway = {
    name                = module.agw.agw_name
    resource_group_name = module.agw.rg_name
    subscription_id     = module.agw.subscription_id
  }

  encryption = {
    disk_encryption_set = {
      name                = module.disk_encryption_set.des_name
      resource_group_name = module.disk_encryption_set.rg_name
    }
    key_vault = {
      name                = module.key_vault.kv_name
      resource_group_name = module.key_vault.rg_name
      key_vault_key = {
        name = module.disk_encryption_set.kvk_name
      }
    }
  }

  route_table_id = module.route_table.route_id

  aks_instance_id                          = 1
  resource_group_kubernetes_nodes_instance = 2

  tags = local.tags
}


module "aks_storage" {
  source = "../"
  depends_on = [
    module.disk_encryption_set,
  ]
  providers = {
    azurerm        = azurerm,
    azurerm.common = azurerm.common,
    kubernetes     = kubernetes.this
  }

  global_subscription_id      = local.global_subscription_id
  global_stage                = local.global_stage
  global_hyperscaler          = local.global_hyperscaler
  global_hyperscaler_location = local.global_hyperscaler_location

  materna_customer_name  = local.materna_customer_name
  materna_project_number = local.materna_project_number
  materna_cost_center    = local.materna_cost_center

  tags = local.tags

  aks = {
    instance_id                 = module.aks.aks_instance_id
    resource_group_name         = module.aks.rg_name
    user_assigned_identity_name = module.aks.managed_identity_name
  }

  disk_access_endpoint = {
    instance      = 1
    custom_config = local.private_endpoint_config
  }

  storage_account_endpoint = {
    file_instance = 2
    blob_instance = 3
    custom_config = local.private_endpoint_config
  }

  encryption = {
    disk_encryption_set = {
      name                = module.disk_encryption_set.des_name
      resource_group_name = module.disk_encryption_set.rg_name
    }
  }

}
