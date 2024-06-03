module "resource_group_network" {
  source  = "gitlab.prd.materna.work/registries/az-rg/azure"
  version = "1.0.0"

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


module "network" {
  source  = "gitlab.prd.materna.work/registries/az-vnet/azure"
  version = "1.0.0"

  global_subscription_id      = local.global_subscription_id
  global_stage                = local.global_stage
  global_hyperscaler          = local.global_hyperscaler
  global_hyperscaler_location = local.global_hyperscaler_location

  materna_customer_name  = local.materna_customer_name
  materna_project_number = local.materna_project_number
  materna_cost_center    = local.materna_cost_center

  resource_group_name = module.resource_group_network.rg_name
  address_space       = "10.50.0.0/16"

  tags = local.tags
}

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

  resource_group_location = local.global_hyperscaler_location_long
  resource_group_instance = 2

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


module "public_ip" {
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
    name                = module.public_ip.pip_name
    resource_group_name = module.public_ip.rg_name
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

  #  resource_group_name = local.network_resource_group_name
  resource_group_name = module.network.rg_name
  subnet_instance     = 1
  #  vnet_name           = local.vnet_name
  vnet_name = module.network.vnet_name
  #  address_prefix      = "10.26.6.160/27" #10.26.6.161 - 10.26.6.190; 30 IPs, Kafka HDInsight needs 17
  address_prefix                                = "10.50.1.0/24"
  private_link_service_network_policies_enabled = false


  associated_route_table = {
    name                = module.route_table.route_name
    resource_group_name = module.route_table.rg_name
  }

  nat_gateway = {
    name                = module.nat_gateway.ngw_name
    resource_group_name = module.nat_gateway.rg_name
  }
}

module "my_kafka" {
  source = "../"
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

  kafka_cluster_instance                                       = 1
  kafka_cluster_storage_account_instance                       = 1
  kafka_cluster_private_endpoint_storage_account_blob_instance = 1
  kafka_cluster_private_endpoint_storage_account_file_instance = 2
  kafka_security_group_instance                                = 1

  subnet = {
    name                        = module.subnet.snet_name
    network_name                = module.subnet.vnet_name
    network_resource_group_name = module.subnet.rg_name
  }

  private_endpoint_gateway = {
    instance      = 3
    custom_config = local.private_endpoint_config
  }

  private_endpoint_headnode = {
    instance      = 4
    custom_config = local.private_endpoint_config

  }
  tags = local.tags

}
