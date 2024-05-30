###############################################################
#####################       Locals        #####################
###############################################################

# Defines compositions of inputs
locals {
  aks_offset = 2
  pe_offset  = 5

  hub_fw_ip = "10.158.0.68"

  #### Merge die Nodepool Konfiguration von jedem Nodepool mit der Konfig des passenden Subnetzes
  app_node_pool_input = { for key, value in var.aks_additional_app_node_pools : key =>
    merge(value.node_pool_config,
      {
        subnet = {
          name                        = module.subnet_aks_app["${key}"].snet_name
          network_name                = module.subnet_aks_app["${key}"].vnet_name
          network_resource_group_name = module.subnet_aks_app["${key}"].rg_name
        }
    })
  }

  subscription_name_map = split("-", var.materna_sbs_name)

  global_hyperscaler          = substr(local.subscription_name_map[0], 0, 2)
  global_hyperscaler_location = substr(local.subscription_name_map[0], 2, 4)
  global_hyperscaler_location_long = {
    we : "westeurope"
    ne : "northeurope"
    gw : "germanywestcentral"
  }
  global_stage = local.subscription_name_map[4]

  #https://dev.azure.com/MaternaGroup/Azure-Aufbau/_git/repo-hub-mat-group/commit/6e2910f42c37e994d0f90a6f19f4858f81bb0bb3?refName=refs%2Fheads%2Fmain
  vnet_suffix = var.use_deprecated_vnet_naming ? "00" : "${local.subscription_name_map[4]}-${local.subscription_name_map[5]}"

  sbs_vnet = var.custom_sbs_vnet != null ? var.custom_sbs_vnet : {
    network_name                = "${local.subscription_name_map[0]}-${local.subscription_name_map[1]}-vnet-${local.subscription_name_map[3]}-${local.vnet_suffix}"
    network_resource_group_name = "${local.subscription_name_map[0]}-${local.subscription_name_map[1]}-rg-network-${local.subscription_name_map[4]}-00"
  }

  agic_service_principal_name = "${local.subscription_name_map[0]}-${local.subscription_name_map[1]}-lzsp-${local.subscription_name_map[3]}agic-${local.subscription_name_map[4]}-${local.subscription_name_map[5]}"
  aks_private_dns_zone_id     = "/subscriptions/${var.global_subscription_id}/resourceGroups/${local.subscription_name_map[0]}-${local.subscription_name_map[1]}-rg-dns-${local.subscription_name_map[4]}-00/providers/Microsoft.Network/privateDnsZones/${local.subscription_name_map[3]}${local.subscription_name_map[4]}${local.subscription_name_map[5]}.privatelink.westeurope.azmk8s.io"

  disk_encryption_set = var.custom_disk_encryption_set != null ? var.custom_disk_encryption_set : {
    name                = "${local.subscription_name_map[0]}-${local.subscription_name_map[1]}-des-${local.subscription_name_map[3]}-${local.subscription_name_map[4]}-${local.subscription_name_map[5]}"
    resource_group_name = "${local.subscription_name_map[0]}-${local.subscription_name_map[1]}-rg-des-${local.subscription_name_map[4]}-00"
  }

  dns_service_principal_name = "${local.subscription_name_map[0]}-${local.subscription_name_map[1]}-lzsp-${local.subscription_name_map[3]}dns-${local.subscription_name_map[4]}-${local.subscription_name_map[5]}"

  private_endpoint_custom_config = var.custom_private_endpoint_config != null ? var.custom_private_endpoint_config : {
    resource_group_name = "${local.subscription_name_map[0]}-${local.subscription_name_map[1]}-rg-pe-${local.global_stage}-00"
    subnet = {
      name                        = "${local.subscription_name_map[0]}-${local.subscription_name_map[1]}-snet-pe-${local.global_stage}-00"
      network_name                = local.sbs_vnet.network_name
      network_resource_group_name = local.sbs_vnet.network_resource_group_name
    }
  }
}

