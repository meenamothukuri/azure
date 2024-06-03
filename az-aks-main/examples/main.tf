module "resource_group" {
  #source = "git@gitlab.prd.materna.digital:components/terraform/azure/az-rg"
  source = "git@gitlab.prd.materna.work:components/terraform/azure/az-rg"

  global_subscription_id      = local.global_subscription_id
  global_stage                = local.global_stage
  global_hyperscaler          = local.global_hyperscaler
  global_hyperscaler_location = local.global_hyperscaler_location

  materna_customer_name  = local.materna_customer_name
  materna_project_number = local.materna_project_number
  materna_cost_center    = local.materna_cost_center

  resource_group_location = local.global_hyperscaler_location_long
  resource_group_instance = 1

  tags = local.tags
}

module "route_table" {
  #source = "git@gitlab.prd.materna.digital:components/terraform/azure/az-route"
  source = "git@gitlab.prd.materna.work:components/terraform/azure/az-route"


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
  #source = "git@gitlab.prd.materna.digital:components/terraform/azure/az-pip"
  source = "git@gitlab.prd.materna.work:components/terraform/azure/az-pip"

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
  #source = "git@gitlab.prd.materna.digital:components/terraform/azure/az-ngw"
  source = "git@gitlab.prd.materna.work:components/terraform/azure/az-ngw"

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
  #source = "git@gitlab.prd.materna.digital:components/terraform/azure/az-snet"
  source = "git@gitlab.prd.materna.work:components/terraform/azure/az-snet"

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

module "subnet_2" {
  #source = "git@gitlab.prd.materna.digital:components/terraform/azure/az-snet"
  source = "git@gitlab.prd.materna.work:components/terraform/azure/az-snet"

  global_subscription_id      = local.global_subscription_id
  global_stage                = local.global_stage
  global_hyperscaler          = local.global_hyperscaler
  global_hyperscaler_location = local.global_hyperscaler_location

  materna_customer_name  = local.materna_customer_name
  materna_project_number = local.materna_project_number
  materna_cost_center    = local.materna_cost_center

  resource_group_name = local.network_resource_group_name
  subnet_instance     = 3
  vnet_name           = local.vnet_name
  address_prefix      = "10.26.6.160/28"

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
  #source = "git@gitlab.prd.materna.digital:components/terraform/azure/az-snet"
  source = "git@gitlab.prd.materna.work:components/terraform/azure/az-snet"

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
  #source = "git@gitlab.prd.materna.digital:components/terraform/azure/az-pip"
  source = "git@gitlab.prd.materna.work:components/terraform/azure/az-pip"

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
  #source = "git@gitlab.prd.materna.digital:components/terraform/azure/az-agw"
  source = "git@gitlab.prd.materna.work:components/terraform/azure/az-agw"


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


module "cr" {
  #source = "git@gitlab.prd.materna.digital:components/terraform/azure/az-cr"
  source = "git@gitlab.prd.materna.work:components/terraform/azure/az-cr"

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
  tags                = local.tags


  container_registry_instance = 1

  private_endpoint = {
    instance = 1
  }
}

module "key_vault" {
  providers = {
    azurerm        = azurerm,
    azurerm.common = azurerm.common
  }
  #source = "git@gitlab.prd.materna.digital:components/terraform/azure/az-kv"
  source = "git@gitlab.prd.materna.work:components/terraform/azure/az-kv"

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
    instance = 3
  }
}

module "disk_encryption_set" {
  #source = "git@gitlab.prd.materna.digital:components/terraform/azure/az-des"
  source = "git@gitlab.prd.materna.work:components/terraform/azure/az-des"


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
  # Route table association requiered at this point
  depends_on = [
    module.subnet,
    module.subnet_2,
    module.disk_encryption_set,
    module.key_vault
  ]

  providers = {
    helm       = helm.this,
    kubernetes = kubernetes.this,
  }

  source = "../../"

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
  create_nginx                = false
  nginx_version               = "4.8.3"
  system_node_pool = {
    subnet = {
      name                        = module.subnet.snet_name
      network_name                = module.subnet.vnet_name
      network_resource_group_name = module.subnet.rg_name
    }
  }

  additional_node_pools = {
    p1 = {
      subnet = {
        name                        = module.subnet_2.snet_name
        network_name                = module.subnet_2.vnet_name
        network_resource_group_name = module.subnet_2.rg_name
      }
    }
  }

  container_registry = {
    name                = module.cr.cr_name
    resource_group_name = module.cr.rg_name
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


