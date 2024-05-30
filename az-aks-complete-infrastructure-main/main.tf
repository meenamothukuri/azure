

################################################################
#####################        Network      ######################
################################################################

module "route_table_aks" {
  source  = "gitlab.prd.materna.work/registries/az-route/azure"
  version = "1.0.1"

  global_subscription_id      = var.global_subscription_id
  global_stage                = local.global_stage
  global_hyperscaler          = local.global_hyperscaler
  global_hyperscaler_location = local.global_hyperscaler_location

  materna_customer_name  = var.materna_customer_name
  materna_project_number = "${var.materna_project_number}aks"
  materna_cost_center    = var.materna_cost_center

  #### Instance muss vermutlich mit wachsen aufgrund der Anforderung ggf. mehr Versionen dieses Moduls zu deployen
  route_table_instance = var.global_instance_id

  routes = {
    AnyToFirewall = {
      address_prefix         = "0.0.0.0/0"
      next_hop_type          = "VirtualAppliance"
      next_hop_in_ip_address = local.hub_fw_ip
    }
  }

  resource_group_name = local.sbs_vnet.network_resource_group_name

  tags = var.tags
}

module "route_table_agw" {
  source                      = "gitlab.prd.materna.work/registries/az-route/azure"
  version                     = "1.0.1"
  count                       = var.agw_enable == false ? 0 : 1
  global_subscription_id      = var.global_subscription_id
  global_stage                = local.global_stage
  global_hyperscaler          = local.global_hyperscaler
  global_hyperscaler_location = local.global_hyperscaler_location

  materna_customer_name  = var.materna_customer_name
  materna_project_number = "${var.materna_project_number}agw"
  materna_cost_center    = var.materna_cost_center

  #### Instance muss vermutlich mit wachsen aufgrund der Anforderung ggf. mehr Versionen dieses Moduls zu deployen
  route_table_instance = var.global_instance_id

  # Ggf. in Variable überführen
  routes = var.agw_routes

  resource_group_name = local.sbs_vnet.network_resource_group_name

  tags = var.tags
}

#########################################
##########          AGW        ##########
#########################################

module "subnet_agw" {
  source                      = "gitlab.prd.materna.work/registries/az-snet/azure"
  version                     = "1.1.0"
  count                       = var.agw_enable == false ? 0 : 1
  global_subscription_id      = var.global_subscription_id
  global_stage                = local.global_stage
  global_hyperscaler          = local.global_hyperscaler
  global_hyperscaler_location = local.global_hyperscaler_location

  materna_customer_name  = var.materna_customer_name
  materna_project_number = "${var.materna_project_number}agw"
  materna_cost_center    = var.materna_cost_center

  resource_group_name = local.sbs_vnet.network_resource_group_name
  vnet_name           = local.sbs_vnet.network_name
  address_prefix      = var.agw_address_prefix
  subnet_instance     = var.global_instance_id

  private_link_service_network_policies_enabled = !var.agw_enable_private_frontend
  private_endpoint_network_policies_enabled     = !var.agw_enable_private_frontend

  associated_route_table = {
    name                = module.route_table_agw[0].route_name
    resource_group_name = module.route_table_agw[0].rg_name
  }
}

module "public_ip_agw" {
  count   = var.agw_enable_public_frontend == false ? 0 : 1
  source  = "gitlab.prd.materna.work/registries/az-pip/azure"
  version = "1.0.0"
  #count   = var.agw_enable == false ? 0 : 1
  global_subscription_id      = var.global_subscription_id
  global_stage                = local.global_stage
  global_hyperscaler          = local.global_hyperscaler
  global_hyperscaler_location = local.global_hyperscaler_location

  materna_customer_name  = var.materna_customer_name
  materna_project_number = "${var.materna_project_number}agw"
  materna_cost_center    = var.materna_cost_center

  public_ip_instance = var.global_instance_id

  resource_group_name = module.resource_group_agw[0].rg_name

  tags = var.tags
}

#########################################
##########          AKS        ##########
#########################################

module "subnet_aks_sys" {
  source  = "gitlab.prd.materna.work/registries/az-snet/azure"
  version = "1.1.0"

  global_subscription_id      = var.global_subscription_id
  global_stage                = var.aks_stage
  global_hyperscaler          = local.global_hyperscaler
  global_hyperscaler_location = local.global_hyperscaler_location

  materna_customer_name  = var.materna_customer_name
  materna_project_number = "${var.aks_system_node_pool.name_prefix}sys"
  materna_cost_center    = var.materna_cost_center

  resource_group_name = local.sbs_vnet.network_resource_group_name
  vnet_name           = local.sbs_vnet.network_name
  address_prefix      = var.aks_system_node_pool.address_prefix
  subnet_instance     = var.global_instance_id

  associated_route_table = {
    name                = module.route_table_aks.route_name
    resource_group_name = module.route_table_aks.rg_name
  }
}


module "subnet_aks_app" {
  source   = "gitlab.prd.materna.work/registries/az-snet/azure"
  version  = "1.1.0"
  for_each = var.aks_additional_app_node_pools

  global_subscription_id      = var.global_subscription_id
  global_stage                = var.aks_stage
  global_hyperscaler          = local.global_hyperscaler
  global_hyperscaler_location = local.global_hyperscaler_location

  materna_customer_name  = var.materna_customer_name
  materna_project_number = each.value["name_prefix"] == null ? "${each.key}app" : "${each.value["name_prefix"]}app"
  materna_cost_center    = var.materna_cost_center

  resource_group_name = local.sbs_vnet.network_resource_group_name
  vnet_name           = local.sbs_vnet.network_name

  address_prefix  = each.value["subnet_cidr"]
  subnet_instance = each.value["nodepool_instance"]

  associated_route_table = {
    name                = module.route_table_aks.route_name
    resource_group_name = module.route_table_aks.rg_name
  }
}

################################################################
##################### Application Gateway ######################
################################################################

module "resource_group_agw" {
  source                      = "gitlab.prd.materna.work/registries/az-rg/azure"
  version                     = "1.0.0"
  count                       = var.agw_enable == false ? 0 : 1
  global_subscription_id      = var.global_subscription_id
  global_stage                = local.global_stage
  global_hyperscaler          = local.global_hyperscaler
  global_hyperscaler_location = local.global_hyperscaler_location

  materna_customer_name  = var.materna_customer_name
  materna_project_number = "${var.materna_project_number}agw"
  materna_cost_center    = var.materna_cost_center

  resource_group_location = local.global_hyperscaler_location_long[local.global_hyperscaler_location]
  resource_group_instance = var.global_instance_id

  tags = var.tags
}

module "agw" {
  source  = "gitlab.prd.materna.work/registries/az-agw/azure"
  version = "4.1.0" #"3.0.1"
  providers = {
    azurerm        = azurerm,
    azurerm.common = azurerm,
    acme.prod      = acme.prod,
    acme.staging   = acme.staging,
  }
  count                       = var.agw_enable == false ? 0 : 1
  global_subscription_id      = var.global_subscription_id
  global_stage                = local.global_stage
  global_hyperscaler          = local.global_hyperscaler
  global_hyperscaler_location = local.global_hyperscaler_location

  materna_customer_name  = var.materna_customer_name
  materna_project_number = var.materna_project_number
  materna_cost_center    = var.materna_cost_center

  resource_group_name                 = module.resource_group_agw[0].rg_name
  public_ip_name                      = var.agw_enable_public_frontend == false ? null : module.public_ip_agw[0].pip_name
  agic_service_principal_name         = local.agic_service_principal_name
  enable_agic_network_role_assignment = var.set_agic_sp_network_role_assignment
  application_gateway_instance        = var.global_instance_id

  private_endpoint = var.agw_enable_private_frontend != true ? null : {
    instance      = ((var.global_instance_id - 1) * local.pe_offset + 1) + 1
    custom_config = local.private_endpoint_custom_config
  }
  subnet = {
    name                        = module.subnet_agw[0].snet_name
    network_name                = module.subnet_agw[0].vnet_name
    network_resource_group_name = module.subnet_agw[0].rg_name
  }

  sku = var.agw_sku

  enable_http2 = true

  waf_owasp_exclusions          = var.agw_waf_owasp_exclusions
  waf_enable_request_body_check = var.agw_waf_enable_request_body_check
  waf_enable_prevention_mode    = var.agw_waf_enable_prevention_mode
  waf_custom_rules              = var.agw_waf_custom_rules

  waf_enable_max_request_body_size = var.agw_waf_enable_max_request_body_size

  tags = var.tags
}

################################################################
#####################          AKS        ######################
################################################################

module "resource_group_aks" {
  source  = "gitlab.prd.materna.work/registries/az-rg/azure"
  version = "1.0.0"

  global_subscription_id      = var.global_subscription_id
  global_stage                = var.aks_stage
  global_hyperscaler          = local.global_hyperscaler
  global_hyperscaler_location = local.global_hyperscaler_location

  materna_customer_name  = var.materna_customer_name
  materna_project_number = "${var.materna_project_number}aks"
  materna_cost_center    = var.materna_cost_center

  resource_group_location = local.global_hyperscaler_location_long[local.global_hyperscaler_location]
  resource_group_instance = ((var.global_instance_id - 1) * local.aks_offset + 1)

  tags = var.tags
}

module "aks" {
  source  = "gitlab.prd.materna.work/registries/az-aks/azure"
  version = "5.6.3"

  depends_on = [
    module.subnet_aks_sys
  ]

  global_subscription_id = var.global_subscription_id

  global_tenant_id            = var.global_tenant_id
  global_stage                = var.aks_stage
  global_hyperscaler          = local.global_hyperscaler
  global_hyperscaler_location = local.global_hyperscaler_location

  materna_customer_name  = var.materna_customer_name
  materna_project_number = var.materna_project_number
  materna_cost_center    = var.materna_cost_center

  aks_resourcegroup_name = module.resource_group_aks.rg_name
  aks_cluster_admins     = var.aks_cluster_admins
  aks_kubernetes_version = var.aks_k8s_version
  aks_pod_cidr           = var.aks_pod_cidr == "" ? null : var.aks_pod_cidr

  private_dns_zone_id = local.aks_private_dns_zone_id

  agic_service_principal_name = local.agic_service_principal_name

  create_nginx  = var.aks_create_nginx
  nginx_version = var.aks_nginx_version

  dns_zone = var.dns_zone == null ? null : var.dns_zone["create"] == false ? null : {
    resource_group_name                 = module.dns_zone[0].rg_name
    subscription_id                     = var.global_subscription_id
    external_dns_service_principal_name = local.dns_service_principal_name
  }

  system_node_pool = merge(var.aks_system_node_pool.node_pool_config, {
    subnet = {
      name                        = module.subnet_aks_sys.snet_name
      network_name                = module.subnet_aks_sys.vnet_name
      network_resource_group_name = module.subnet_aks_sys.rg_name
    }
  })

  aks_sku_tier = var.aks_sku_tier

  additional_node_pools = local.app_node_pool_input

  encryption = {
    disk_encryption_set = local.disk_encryption_set
  }

  application_gateway = var.agw_enable == false ? null : {
    name                = module.agw[0].agw_name
    resource_group_name = module.agw[0].rg_name
    subscription_id     = module.agw[0].subscription_id
    shared              = false
    private             = var.agw_enable_private_frontend
  }

  route_table_id = module.route_table_aks.route_id

  aks_instance_id                          = var.global_instance_id
  resource_group_kubernetes_nodes_instance = ((var.global_instance_id - 1) * local.aks_offset + 1) + 1

  install_agic = var.agw_enable
  agic_version = var.aks_agic_version

  aks_automatic_upgrade = var.aks_automatic_upgrade

  aks_taint_system_node_pool = var.aks_taint_system_node_pool

  hashicorp_vault = var.hashicorp_vault == null ? null : {
    key_vault_resource_group_name = module.key_vault_hashicorp_vault[0].rg_name
    key_vault_name                = module.key_vault_hashicorp_vault[0].kv_name
    service_principal_name        = var.hashicorp_vault["service_principal_name"]
  }

  tags = var.tags
}

module "aks_storage" {
  source  = "gitlab.prd.materna.work/registries/az-aks-storage/azure"
  version = "1.1.0"

  providers = {
    azurerm        = azurerm,
    azurerm.common = azurerm,
  }

  global_subscription_id      = var.global_subscription_id
  global_stage                = var.aks_stage
  global_hyperscaler          = local.global_hyperscaler
  global_hyperscaler_location = local.global_hyperscaler_location

  materna_customer_name  = var.materna_customer_name
  materna_project_number = "${var.materna_project_number}aks"
  materna_cost_center    = var.materna_cost_center

  tags = var.tags

  storage_account_instance = var.global_instance_id
  aks = {
    instance_id                 = module.aks.aks_instance_id
    resource_group_name         = module.aks.rg_name
    user_assigned_identity_name = module.aks.managed_identity_name
  }

  disk_access_endpoint = {
    instance      = ((var.global_instance_id - 1) * local.pe_offset + 1)
    custom_config = local.private_endpoint_custom_config
  }

  storage_account_endpoint = var.aks_storage_account_usage == true ? {
    file_instance = ((var.global_instance_id - 1) * local.pe_offset + 1) + 2
    blob_instance = ((var.global_instance_id - 1) * local.pe_offset + 1) + 3
    custom_config = local.private_endpoint_custom_config
  } : null

  encryption = {
    disk_encryption_set = local.disk_encryption_set
  }
  apply_kubernetes                            = true
  enable_full_subscription_contributor_rights = true
}


module "aks_argocd" {
  count = var.argocd_enable == true ? 1 : 0

  depends_on = [
    module.aks_storage,
    module.aks,
  ]
  source  = "gitlab.prd.materna.work/registries/az-aks-argocd/azure"
  version = "2.1.1"

  aks_cluster = {
    name                  = module.aks.aks_name
    server                = var.aks_public_host == null ? module.aks.kubeconfig[0].host : var.aks_public_host
    ca_certificate_base64 = module.aks.kubeconfig[0].cluster_ca_certificate
    tls_server_name       = var.argocd_external_connection == true ? "10.0.0.1" : null
  }

  projects = var.argocd_projects

  dns_zone_name = var.dns_zone == null ? "" : var.dns_zone["create"] == false ? "" : module.dns_zone[0].dns_name

  bootstrap = var.argocd_bootstrap
}

module "resource_group_hashicorp_vault" {
  count = var.hashicorp_vault == null ? 0 : 1

  source  = "gitlab.prd.materna.work/registries/az-rg/azure"
  version = "1.0.0"

  global_subscription_id      = var.global_subscription_id
  global_stage                = local.global_stage
  global_hyperscaler          = local.global_hyperscaler
  global_hyperscaler_location = local.global_hyperscaler_location

  materna_customer_name  = var.materna_customer_name
  materna_project_number = "${var.materna_project_number}vault"
  materna_cost_center    = var.materna_cost_center

  resource_group_location = local.global_hyperscaler_location_long[local.global_hyperscaler_location]
  resource_group_instance = var.global_instance_id

  tags = var.tags
}

module "key_vault_hashicorp_vault" {
  count = var.hashicorp_vault == null ? 0 : 1

  providers = {
    azurerm        = azurerm,
    azurerm.common = azurerm
  }
  #source = "git@gitlab.prd.materna.work:components/terraform/azure/az-kv"
  source  = "gitlab.prd.materna.work/registries/az-kv/azure"
  version = "1.3.0"

  global_subscription_id      = var.global_subscription_id
  global_stage                = local.global_stage
  global_tenant_id            = var.global_tenant_id
  global_hyperscaler          = local.global_hyperscaler
  global_hyperscaler_location = local.global_hyperscaler_location

  materna_customer_name  = var.materna_customer_name
  materna_project_number = "${var.materna_project_number}kvvault"
  materna_cost_center    = var.materna_cost_center

  resource_group_name = module.resource_group_hashicorp_vault[0].rg_name

  tags = var.tags

  key_vault_instance = var.global_instance_id

  hashicorp_vault = {
    service_principal_name = var.hashicorp_vault["service_principal_name"]
  }

  private_endpoint = {
    instance      = ((var.global_instance_id - 1) * local.pe_offset + 1) + 4
    custom_config = local.private_endpoint_custom_config
  }
}


################################################################
#####################     DNS ZONE        ######################
################################################################

module "resource_group_dns" {
  count = var.dns_zone == null ? 0 : var.dns_zone["create"] == false ? 0 : 1

  source  = "gitlab.prd.materna.work/registries/az-rg/azure"
  version = "1.0.0"

  global_subscription_id      = var.global_subscription_id
  global_stage                = local.global_stage
  global_hyperscaler          = local.global_hyperscaler
  global_hyperscaler_location = local.global_hyperscaler_location

  materna_customer_name  = var.materna_customer_name
  materna_project_number = "${var.materna_project_number}dns"
  materna_cost_center    = var.materna_cost_center

  resource_group_location = local.global_hyperscaler_location_long[local.global_hyperscaler_location]
  resource_group_instance = var.global_instance_id

  tags = var.tags
}

module "dns_zone" {
  count = var.dns_zone == null ? 0 : var.dns_zone["create"] == false ? 0 : 1

  source  = "gitlab.prd.materna.work/registries/az-dns/azure"
  version = "1.1.0"

  global_stage        = local.global_stage
  materna_cost_center = var.materna_cost_center

  external_dns_service_principal_name = local.dns_service_principal_name

  resource_group_name = module.resource_group_dns[0].rg_name
  tags                = var.tags
  domain_name         = var.dns_zone["custom_name"] == null ? "${var.materna_project_number}-${local.global_stage}${format("%02d", var.global_instance_id)}.${local.global_hyperscaler}${local.global_hyperscaler_location}.materna.work" : var.dns_zone["custom_name"]
}




module "general_cluster_init" {
  source  = "gitlab.prd.materna.work/registries/gc-init/generalcluster"
  version = "1.3.3"

  count = var.cluster_init_enable ? 1 : 0

  cluster_name = module.aks.aks_name

  enable_keycloak_integration = var.cluster_init_enable_keycloak_integration
  keycloak_url                = var.cluster_init_keycloak_url
  keycloak_realm              = var.cluster_init_keycloak_realm


  cluster_connection = {
    tls_ca_cert = module.aks.kubeconfig[0].cluster_ca_certificate
    api_server  = module.aks.kubeconfig[0].host
  }

  argocd_connection = var.argocd_enable == false ? null : {
    tls_ca_cert         = module.aks.kubeconfig[0].cluster_ca_certificate
    tls_server_name     = var.argocd_external_connection == true ? "10.0.0.1" : null
    token               = module.aks_argocd[0].bearer_token
    api_server          = var.aks_public_host == null ? module.aks.kubeconfig[0].host : var.aks_public_host
    argocd_reference_id = "central-shared"
  }

  cluster_environment = {
    dns_zone           = var.dns_zone == null ? "" : var.dns_zone["create"] == false ? "" : module.dns_zone[0].dns_name
    hyperscaler_region = local.global_hyperscaler_location
    hyperscaler        = local.global_hyperscaler
    ingress            = var.agw_enable == true ? "agw" : var.aks_create_nginx == true ? "nginx" : ""
  }

  bootstrap = var.argocd_bootstrap

  bootstrap_application_certmanager                   = var.cluster_init_bootstrap_applications["certmanager"]
  bootstrap_application_cronjobs                      = var.cluster_init_bootstrap_applications["cronjobs"]
  bootstrap_application_externaldns                   = var.cluster_init_bootstrap_applications["externaldns"]
  bootstrap_application_fluentbit                     = var.cluster_init_bootstrap_applications["fluentbit"]
  bootstrap_application_grafana                       = var.cluster_init_bootstrap_applications["grafana"]
  bootstrap_application_kanister                      = var.cluster_init_bootstrap_applications["kanister"]
  bootstrap_application_kubeprometheusstack           = var.cluster_init_bootstrap_applications["kubeprometheusstack"]
  bootstrap_application_kyverno                       = var.cluster_init_bootstrap_applications["kyverno"]
  bootstrap_application_kyvernopolicies               = var.cluster_init_bootstrap_applications["kyvernopolicies"]
  bootstrap_application_loki                          = var.cluster_init_bootstrap_applications["loki"]
  bootstrap_application_minio                         = var.cluster_init_bootstrap_applications["minio"]
  bootstrap_application_networkpolicies               = var.cluster_init_bootstrap_applications["networkpolicies"]
  bootstrap_application_opentelemetrycollectoragent   = var.cluster_init_bootstrap_applications["opentelemetrycollectoragent"]
  bootstrap_application_opentelemetrycollectorgateway = var.cluster_init_bootstrap_applications["opentelemetrycollectorgateway"]
  bootstrap_application_prometheus                    = var.cluster_init_bootstrap_applications["prometheus"]
  bootstrap_application_tempo                         = var.cluster_init_bootstrap_applications["tempo"]
  bootstrap_application_trivyoperator                 = var.cluster_init_bootstrap_applications["trivyoperator"]
  bootstrap_application_velero                        = var.cluster_init_bootstrap_applications["velero"]

}
