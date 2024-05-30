module "global_constants_headnode" {
  source  = "gitlab.prd.materna.work/registries/az-global-constants/azure"
  version = "1.1.0"

  global_hyperscaler = var.global_hyperscaler

  private_dns_zone = var.private_endpoint_gateway["custom_private_dns_zone"]
  private_endpoint = var.private_endpoint_gateway["custom_config"]
}

module "global_constants_gateway" {
  source  = "gitlab.prd.materna.work/registries/az-global-constants/azure"
  version = "1.1.0"

  global_hyperscaler = var.global_hyperscaler

  private_dns_zone = var.private_endpoint_headnode["custom_private_dns_zone"]
  private_endpoint = var.private_endpoint_headnode["custom_config"]
}

resource "azurecaf_name" "kafka_cluster" {
  resource_type = "azurerm_hdinsight_kafka_cluster"
  prefixes      = [format("%s%s", var.global_hyperscaler, var.global_hyperscaler_location), var.materna_customer_name]
  suffixes      = [var.materna_project_number, var.global_stage, format("%02d", var.kafka_cluster_instance)]
  clean_input   = true
}

resource "azurecaf_name" "storage_container" {
  resource_type = "azurerm_storage_container"
  prefixes      = [format("%s%s", var.global_hyperscaler, var.global_hyperscaler_location), var.materna_customer_name]
  suffixes      = [var.materna_project_number, var.global_stage, format("%02d", 1)]
  clean_input   = true
}

resource "azurecaf_name" "kafka_security_group" {
  resource_type = "azurerm_network_security_group"
  prefixes      = [format("%s%s", var.global_hyperscaler, var.global_hyperscaler_location), var.materna_customer_name]
  suffixes      = [var.materna_project_number, var.global_stage, format("%02d", var.kafka_security_group_instance)]
  clean_input   = true
}

resource "azurerm_network_security_group" "kafka" {
  name                = lower(azurecaf_name.kafka_security_group.result)
  resource_group_name = data.azurerm_resource_group.rg.name
  location            = data.azurerm_resource_group.rg.location
}

resource "azurerm_subnet_network_security_group_association" "kafka" {
  subnet_id                 = data.azurerm_subnet.snet.id
  network_security_group_id = azurerm_network_security_group.kafka.id
}


module "storage_account" {
  source  = "gitlab.prd.materna.work/registries/az-st/azure"
  version = "1.1.0"
  #source = "git@gitlab.prd.materna.work:components/terraform/azure/az-st.git"


  providers = {
    azurerm        = azurerm,
    azurerm.common = azurerm.common
  }
  global_subscription_id      = var.global_subscription_id
  global_stage                = var.global_stage
  global_hyperscaler          = var.global_hyperscaler
  global_hyperscaler_location = var.global_hyperscaler_location

  materna_customer_name  = var.materna_customer_name
  materna_project_number = var.materna_project_number
  materna_cost_center    = var.materna_cost_center

  resource_group_name = data.azurerm_resource_group.rg.name

  public_network_access_enabled = false

  storage_account_instance = var.kafka_cluster_storage_account_instance

  private_endpoint_blob = {
    instance                = var.kafka_cluster_private_endpoint_storage_account_blob_instance
    custom_private_dns_zone = var.private_endpoint_headnode["custom_private_dns_zone"]
    custom_config           = var.private_endpoint_headnode["custom_config"]
  }

  private_endpoint_file = {
    instance                = var.kafka_cluster_private_endpoint_storage_account_file_instance
    custom_private_dns_zone = var.private_endpoint_headnode["custom_private_dns_zone"]
    custom_config           = var.private_endpoint_headnode["custom_config"]
  }

  tags = var.tags
}

resource "azurerm_storage_container" "this" {
  name                  = lower(azurecaf_name.storage_container.result)
  storage_account_name  = module.storage_account.st_name
  container_access_type = "private"
}

resource "random_password" "gateway" {
  length           = 16
  special          = true
  min_lower        = 1
  min_upper        = 1
  min_special      = 1
  min_numeric      = 1
  override_special = "!#$%&*()-_=+[]{}<>:?"
}

resource "random_password" "vm_head" {
  length           = 16
  special          = true
  min_lower        = 1
  min_upper        = 1
  min_special      = 1
  min_numeric      = 1
  override_special = "!#$%&*()-_=+[]{}<>:?"
}

resource "random_password" "vm_worker" {
  length           = 16
  special          = true
  min_lower        = 1
  min_upper        = 1
  min_special      = 1
  min_numeric      = 1
  override_special = "!#$%&*()-_=+[]{}<>:?"
}

resource "random_password" "vm_zookeeper" {
  length           = 16
  special          = true
  min_lower        = 1
  min_upper        = 1
  min_special      = 1
  min_numeric      = 1
  override_special = "!#$%&*()-_=+[]{}<>:?"
}

resource "azurerm_hdinsight_kafka_cluster" "this" {
  depends_on = [
    azurerm_subnet_network_security_group_association.kafka
  ]
  name                = lower(azurecaf_name.kafka_cluster.result)
  resource_group_name = data.azurerm_resource_group.rg.name
  location            = data.azurerm_resource_group.rg.location
  cluster_version     = var.kafka_cluster_version
  tier                = var.kafka_cluster_tier

  component_version {
    kafka = var.kafka_cluster_component_version
  }

  gateway {
    username = "gateway"
    password = random_password.gateway.result
  }

  storage_account {
    storage_resource_id  = module.storage_account.st_id
    storage_container_id = azurerm_storage_container.this.id
    storage_account_key  = module.storage_account.st_primary_access_key
    is_default           = true
  }
  network {
    # To enable the private link the connection_direction must be set to Outbound.
    connection_direction = "Outbound"
    private_link_enabled = true
  }

  roles {
    head_node {
      vm_size            = var.kafka_cluster_head_node_vm_size
      username           = "vm"
      password           = random_password.vm_head.result
      subnet_id          = data.azurerm_subnet.snet.id
      virtual_network_id = data.azurerm_virtual_network.vnet.id
    }

    worker_node {
      vm_size                  = var.kafka_cluster_worker_node_vm_size
      username                 = "vm"
      password                 = random_password.vm_worker.result
      number_of_disks_per_node = var.kafka_cluster_worker_node_number_of_disks
      target_instance_count    = var.kafka_cluster_worker_node_instances
      subnet_id                = data.azurerm_subnet.snet.id
      virtual_network_id       = data.azurerm_virtual_network.vnet.id
    }

    zookeeper_node {
      vm_size            = var.kafka_cluster_zookeeper_node_vm_size
      username           = "vm"
      password           = random_password.vm_zookeeper.result
      subnet_id          = data.azurerm_subnet.snet.id
      virtual_network_id = data.azurerm_virtual_network.vnet.id

    }
  }
  tags = merge(local.common_tags, var.tags)
}


module "private_endpoint_gateway" {
  providers = {
    azurerm = azurerm.common
  }

  source  = "gitlab.prd.materna.work/registries/az-pe/azure"
  version = "1.0.0"
  #source = "git@gitlab.prd.materna.work:components/terraform/azure/az-pe.git"

  global_subscription_id      = var.global_subscription_id
  global_stage                = var.global_stage
  global_hyperscaler          = var.global_hyperscaler
  global_hyperscaler_location = var.global_hyperscaler_location

  materna_customer_name  = var.materna_customer_name
  materna_project_number = var.materna_project_number
  materna_cost_center    = var.materna_cost_center

  resource_group_name       = module.global_constants_gateway.private_endpoint["resource_group_name"]
  private_endpoint_instance = var.private_endpoint_gateway["instance"]

  subnet = {
    name                        = module.global_constants_gateway.private_endpoint["subnet"]["name"]
    network_name                = module.global_constants_gateway.private_endpoint["subnet"]["network_name"]
    network_resource_group_name = module.global_constants_gateway.private_endpoint["subnet"]["network_resource_group_name"]
  }

  private_dns_zone = module.global_constants_gateway.private_dns_zone["service"]["hdinsight"]["id"] != null ? {
    resource_group_name = module.global_constants_gateway.private_dns_zone["resource_group_name"]
    id                  = module.global_constants_gateway.private_dns_zone["service"]["hdinsight"]["id"]
    name                = module.global_constants_gateway.private_dns_zone["service"]["hdinsight"]["name"]
  } : null

  manual_private_dns_zone_entry = {
    name = azurerm_hdinsight_kafka_cluster.this.name
  }

  private_connection_resource_id = azurerm_hdinsight_kafka_cluster.this.id
  is_manual_connection           = false
  subresource_names              = ["gateway"]

  tags = var.tags
}


module "private_endpoint_headnode" {
  providers = {
    azurerm = azurerm.common
  }

  source  = "gitlab.prd.materna.work/registries/az-pe/azure"
  version = "1.0.0"
  #source = "git@gitlab.prd.materna.work:components/terraform/azure/az-pe.git"

  global_subscription_id      = var.global_subscription_id
  global_stage                = var.global_stage
  global_hyperscaler          = var.global_hyperscaler
  global_hyperscaler_location = var.global_hyperscaler_location

  materna_customer_name  = var.materna_customer_name
  materna_project_number = var.materna_project_number
  materna_cost_center    = var.materna_cost_center

  resource_group_name       = module.global_constants_headnode.private_endpoint["resource_group_name"]
  private_endpoint_instance = var.private_endpoint_headnode["instance"]

  subnet = {
    name                        = module.global_constants_headnode.private_endpoint["subnet"]["name"]
    network_name                = module.global_constants_headnode.private_endpoint["subnet"]["network_name"]
    network_resource_group_name = module.global_constants_headnode.private_endpoint["subnet"]["network_resource_group_name"]
  }

  private_dns_zone = module.global_constants_headnode.private_dns_zone["service"]["hdinsight"]["id"] != null ? {
    resource_group_name = module.global_constants_headnode.private_dns_zone["resource_group_name"]
    id                  = module.global_constants_headnode.private_dns_zone["service"]["hdinsight"]["id"]
    name                = module.global_constants_headnode.private_dns_zone["service"]["hdinsight"]["name"]
  } : null


  manual_private_dns_zone_entry = {
    name = "${azurerm_hdinsight_kafka_cluster.this.name}-ssh"
  }

  private_connection_resource_id = azurerm_hdinsight_kafka_cluster.this.id
  is_manual_connection           = false
  subresource_names              = ["headnode"]

  tags = var.tags
}
