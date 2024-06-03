module "global_constants" {
  source  = "gitlab.prd.materna.work/registries/az-global-constants/azure"
  version = "1.2.1"

  global_hyperscaler = var.global_hyperscaler
  private_dns_zone = var.private_dns_zone_id == null ? null : {
    aks = {
      id = var.private_dns_zone_id
    }
  }
}



resource "azurecaf_name" "aks" {
  resource_type = "azurerm_kubernetes_cluster"
  prefixes      = [format("%s%s", var.global_hyperscaler, var.global_hyperscaler_location), var.materna_customer_name]
  suffixes      = [var.materna_project_number, var.global_stage, format("%02d", var.aks_instance_id)]
  clean_input   = true
}

resource "azurecaf_name" "nginx" {
  resource_type = "azurerm_network_interface"
  prefixes      = [format("%s%s", var.global_hyperscaler, var.global_hyperscaler_location), var.materna_customer_name]
  suffixes      = ["nginx", var.materna_project_number, var.global_stage, format("%02d", var.aks_instance_id)]
  clean_input   = true
}

resource "azurecaf_name" "identity" {
  resource_type = "azurerm_user_assigned_identity"
  prefixes      = [format("%s%s", var.global_hyperscaler, var.global_hyperscaler_location), var.materna_customer_name, "aks"]
  suffixes      = [var.materna_project_number, var.global_stage, format("%02d", var.aks_instance_id)]
  clean_input   = true
}

resource "azurecaf_name" "resource_group_kubernetes_nodes" {
  resource_type = "azurerm_resource_group"
  prefixes      = [format("%s%s", var.global_hyperscaler, var.global_hyperscaler_location), var.materna_customer_name]
  suffixes      = [local.resource_group_kubernetes_nodes_materna_project_number, var.global_stage, format("%02d", var.resource_group_kubernetes_nodes_instance)]
  clean_input   = true
}

resource "azurerm_kubernetes_cluster" "this" {
  depends_on = [
    azurerm_role_assignment.route,
    azurerm_role_assignment.network,
    azurerm_role_assignment.private_dns,
    azurerm_role_assignment.des
  ]
  #checkov:skip=CKV_AZURE_117: will be implemented later
  #checkov:skip=CKV_AZURE_4: logging will be implemented later
  #checkov:skip=CKV_AZURE_7: will be implemented later
  name                              = azurecaf_name.aks.result
  location                          = data.azurerm_resource_group.this.location
  resource_group_name               = data.azurerm_resource_group.this.name
  dns_prefix                        = var.cluster_dns_prefix
  private_cluster_enabled           = true
  public_network_access_enabled     = false
  private_dns_zone_id               = module.global_constants.private_dns_zone["service"]["aks"][var.global_hyperscaler_location]["id"]
  node_resource_group               = azurecaf_name.resource_group_kubernetes_nodes.result
  role_based_access_control_enabled = true
  kubernetes_version                = local.aks_kubernetes_version
  automatic_channel_upgrade         = var.aks_automatic_upgrade
  local_account_disabled            = var.aks_local_account_disabled
  sku_tier                          = var.aks_sku_tier
  oidc_issuer_enabled               = true
  workload_identity_enabled         = true
  azure_policy_enabled              = var.aks_azure_policy_enabled

  # Changing this forces a new resource to be created.
  disk_encryption_set_id = var.encryption == null ? null : data.azurerm_disk_encryption_set.des[0].id

  # Key Management Service (KMS) etcd encryption to an AKS cluster.
  # Noch nicht funktional: Managed Cluster Name: "XXX": Code="InternalOperationError" Message="Internal server error"
  #dynamic "key_management_service" {
  #  for_each = local.key_management_service
  #  content {
  #    key_vault_key_id         = key_management_service.value.key_vault_key_id
  #    key_vault_network_access = key_management_service.value.key_vault_network_access
  #  }
  #}

  default_node_pool {
    name                         = lower(var.system_node_pool["name_extension"])
    orchestrator_version         = var.system_node_pool["orchestrator_version"] == null ? local.aks_kubernetes_version : var.system_node_pool["orchestrator_version"]
    node_count                   = var.system_node_pool["node_count"]
    vm_size                      = var.system_node_pool["vm_size"]
    os_disk_size_gb              = var.system_node_pool["os_disk_size_gb"]
    os_disk_type                 = var.system_node_pool["os_disk_type"]
    enable_node_public_ip        = var.system_node_pool["enable_public_ip"]
    max_pods                     = var.system_node_pool["max_pods"]
    only_critical_addons_enabled = var.aks_taint_system_node_pool
    enable_auto_scaling          = var.system_node_pool["enable_auto_scaling"]
    max_count                    = var.system_node_pool["enable_auto_scaling"] ? var.system_node_pool["node_max_count"] : null
    min_count                    = var.system_node_pool["enable_auto_scaling"] ? var.system_node_pool["node_min_count"] : null
    ultra_ssd_enabled            = var.system_node_pool["ultra_ssd_enabled"]
    type                         = var.system_node_pool["enable_auto_scaling"] ? "VirtualMachineScaleSets" : var.system_node_pool["type"]
    vnet_subnet_id               = data.azurerm_subnet.system_node_pool.id

    node_labels = {
      environment = var.global_stage
    }
  }

  storage_profile {
    disk_driver_enabled = true
    disk_driver_version = "v1"
    file_driver_enabled = true
    blob_driver_enabled = false
  }
  identity {
    type         = "UserAssigned"
    identity_ids = [azurerm_user_assigned_identity.this.id]
  }

  azure_active_directory_role_based_access_control {
    managed                = true
    admin_group_object_ids = local.cluster_admins
  }

  network_profile {
    network_plugin = "kubenet"
    # https://github.com/Azure/aks-engine/issues/4106#issuecomment-792615336
    outbound_type  = "userDefinedRouting"
    network_policy = var.enable_network_policy == null || var.enable_network_policy == false ? null : "calico"

    # https://techcommunity.microsoft.com/t5/azure/azure-how-to-create-standard-load-balancer-without-public-ip/m-p/2198503 - 
    # Error: Private cluster cannot be enabled with Basic loadbalancer.
    # load_balancer_sku = "basic"
    # outbound_type  = "loadBalancer"
    pod_cidr = var.aks_pod_cidr
  }
  tags = merge(local.common_tags, var.tags)

  lifecycle {
    ignore_changes = [
      tags,
      location,
      default_node_pool["vnet_subnet_id"],
      azure_active_directory_role_based_access_control["admin_group_object_ids"],
      disk_encryption_set_id,
      microsoft_defender["log_analytics_workspace_id"] # Can be set via policies in the backgroud and shouldn't be removed
    ]
  }
}

resource "azurerm_kubernetes_cluster_node_pool" "this" {
  for_each               = var.additional_node_pools
  name                   = each.key
  kubernetes_cluster_id  = azurerm_kubernetes_cluster.this.id
  vm_size                = each.value["vm_size"]
  node_count             = each.value["node_count"]
  enable_auto_scaling    = each.value["enable_auto_scaling"]
  max_count              = each.value["node_max_count"]
  min_count              = each.value["node_min_count"]
  enable_host_encryption = each.value["enable_host_encryption"]
  enable_node_public_ip  = false
  kubelet_disk_type      = each.value["kubelet_disk_type"]
  priority               = "Regular" # Regular | Spot
  message_of_the_day     = null
  max_pods               = each.value["max_pods"]
  mode                   = each.value["mode"]
  node_taints            = each.value["node_taints"]
  node_labels            = each.value["node_labels"]
  orchestrator_version   = each.value["orchestrator_version"] == null ? local.aks_kubernetes_version : each.value["orchestrator_version"]
  os_disk_size_gb        = each.value["os_disk_size_gb"]
  os_disk_type           = each.value["os_disk_type"]
  os_sku                 = "Ubuntu"
  os_type                = "Linux"
  scale_down_mode        = each.value["scale_down_mode"] # Delete | Reallocate
  ultra_ssd_enabled      = each.value["ultra_ssd_enabled"]
  vnet_subnet_id         = data.azurerm_subnet.additional_node_pools[each.key].id

  kubelet_config {
    allowed_unsafe_sysctls    = each.value["kubelet_config"]["allowed_unsafe_sysctls"]
    container_log_max_line    = each.value["kubelet_config"]["container_log_max_line"]
    container_log_max_size_mb = each.value["kubelet_config"]["container_log_max_size_mb"]
    cpu_cfs_quota_enabled     = each.value["kubelet_config"]["cpu_cfs_quota_enabled"]
    cpu_cfs_quota_period      = each.value["kubelet_config"]["cpu_cfs_quota_period"]
    cpu_manager_policy        = each.value["kubelet_config"]["cpu_manager_policy"]
    image_gc_high_threshold   = each.value["kubelet_config"]["image_gc_high_threshold"]
    image_gc_low_threshold    = each.value["kubelet_config"]["image_gc_low_threshold"]
    pod_max_pid               = each.value["kubelet_config"]["pod_max_pid"]
    topology_manager_policy   = each.value["kubelet_config"]["topology_manager_policy"]
  }
  tags = merge(local.common_tags, var.tags)

  lifecycle {
    ignore_changes = [
      kubelet_config,
      vnet_subnet_id
    ]
  }
}

resource "local_file" "kubeconfig" {
  depends_on = [
    azurerm_kubernetes_cluster.this
  ]
  filename = ".kubeconfig"
  content  = azurerm_kubernetes_cluster.this.kube_admin_config_raw
}


resource "azurerm_user_assigned_identity" "this" {
  location            = data.azurerm_resource_group.this.location
  name                = azurecaf_name.identity.result
  resource_group_name = data.azurerm_resource_group.this.name
  tags                = merge(local.common_tags, var.tags)
  lifecycle {
    ignore_changes = [
      tags,
      location
    ]
  }
}

resource "azurerm_role_assignment" "route" {
  scope                = var.route_table_id
  role_definition_name = "Contributor"
  principal_id         = azurerm_user_assigned_identity.this.principal_id
}

resource "azurerm_role_assignment" "private_dns" {
  scope                = module.global_constants.private_dns_zone["service"]["aks"][var.global_hyperscaler_location]["id"]
  role_definition_name = "Private DNS Zone Contributor"
  principal_id         = azurerm_user_assigned_identity.this.principal_id
}


resource "azurerm_role_assignment" "network" {
  scope                = data.azurerm_virtual_network.system_node_pool.id
  role_definition_name = "Network Contributor"
  principal_id         = azurerm_user_assigned_identity.this.principal_id
  lifecycle {
    ignore_changes = [
      scope,
    ]
  }
}
resource "azurerm_role_assignment" "des" {
  count = var.encryption == null ? 0 : 1

  scope                = data.azurerm_disk_encryption_set.des[0].id
  role_definition_name = "Reader"
  principal_id         = azurerm_user_assigned_identity.this.principal_id
  lifecycle {
    ignore_changes = [
      scope,
    ]
  }
}

resource "azurerm_role_assignment" "cr" {
  count                            = var.container_registry == null ? 0 : 1
  scope                            = data.azurerm_container_registry.cr[0].id
  role_definition_name             = "AcrPull"
  principal_id                     = azurerm_kubernetes_cluster.this.kubelet_identity[0].object_id
  skip_service_principal_aad_check = true
  lifecycle {
    ignore_changes = [
      scope,
    ]
  }
}

resource "azuread_application_password" "agic" {
  display_name   = local.enterprise_application_password_name
  application_id = data.azuread_application.agic.id
  lifecycle {
    ignore_changes = [
      application_id
    ]
  }
}

resource "azuread_application_password" "external_dns" {
  count          = var.dns_zone == null ? 0 : 1
  display_name   = local.enterprise_application_password_name
  application_id = data.azuread_application.external_dns[0].id
  lifecycle {
    ignore_changes = [
      application_id
    ]
  }
}

#####################
## Hashicorp Vault ##
#####################
resource "azuread_application_password" "hashicorp_vault" {
  count          = var.hashicorp_vault == null ? 0 : 1
  display_name   = local.enterprise_application_password_name
  application_id = data.azuread_application.hashicorp_vault[0].id
  lifecycle {
    ignore_changes = [
      application_id
    ]
  }
}

resource "azurecaf_name" "hashicorp_vault_key_vault_key" {
  count = var.hashicorp_vault == null ? 0 : 1

  resource_type = "azurerm_key_vault_key"
  prefixes      = [format("%s%s", var.global_hyperscaler, var.global_hyperscaler_location), var.materna_customer_name]
  suffixes      = [var.materna_project_number, var.global_stage, format("%02d", var.aks_instance_id)]
  clean_input   = true
}

resource "azurerm_key_vault_key" "hashicorp_vault" {
  count = var.hashicorp_vault == null ? 0 : 1

  name         = lower(azurecaf_name.hashicorp_vault_key_vault_key[0].result)
  key_vault_id = data.azurerm_key_vault.hashicorp_vault[0].id
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

resource "azurerm_role_assignment" "hashicorp_vault_kvkcu" {
  count = var.hashicorp_vault == null ? 0 : 1

  scope                = azurerm_key_vault_key.hashicorp_vault[0].resource_versionless_id
  role_definition_name = "Key Vault Crypto User"
  principal_id         = data.azuread_service_principal.hashicorp_vault[0].id
  lifecycle {
    ignore_changes = [
      principal_id,
      scope
    ]
  }
}

resource "kubernetes_secret_v1" "hashicorp_vault" {
  count = var.hashicorp_vault == null ? 0 : 1

  metadata {
    name      = "cred-vault"
    namespace = kubernetes_namespace_v1.secret[0].metadata[0].name
    labels = {
      destination-namespace = "vault"
    }
  }

  type = "Opaque"
  data = {
    AZURE_TENANT_ID     = "${var.global_tenant_id}"
    AZURE_CLIENT_ID     = "${data.azuread_service_principal.hashicorp_vault[0].application_id}"
    AZURE_CLIENT_SECRET = "${azuread_application_password.hashicorp_vault[0].value}"
  }
}


###########
### AGIC ##
###########
resource "kubernetes_namespace_v1" "agic" {
  count = var.install_agic == true ? 1 : 0
  metadata {
    name = "agic"
  }
}

resource "kubernetes_network_policy_v1" "agic_deny_all" {
  count = var.install_agic == true ? 1 : 0
  metadata {
    name      = "deny-all"
    namespace = kubernetes_namespace_v1.agic[0].metadata[0].name
  }
  spec {
    pod_selector {}
    policy_types = ["Ingress", "Egress"]
  }
}

resource "kubernetes_network_policy_v1" "agic_egress" {
  count = var.install_agic == true ? 1 : 0

  metadata {
    name      = "egress-restriction"
    namespace = kubernetes_namespace_v1.agic[0].metadata[0].name
  }

  spec {
    pod_selector {}
    egress {
      to {
        ip_block {
          cidr = "0.0.0.0/0"
        }
      }
      ports {
        port     = "443"
        protocol = "TCP"
      }
    }

    egress {
      to {
        namespace_selector {
          match_labels = {
            "kubernetes.io/metadata.name" : "kube-system"
          }
        }
        pod_selector {
          match_labels = {
            k8s-app : "kube-dns"
          }
        }
      }
      ports {
        port     = "53"
        protocol = "TCP"
      }
      ports {
        port     = "53"
        protocol = "UDP"
      }
    }

    policy_types = ["Egress"]
  }

}


resource "helm_release" "ingress_azure" {
  count = var.install_agic == true ? 1 : 0
  name  = "ingress-azure"

  repository = "https://appgwingress.blob.core.windows.net/ingress-azure-helm-package"
  chart      = "ingress-azure"
  version    = var.agic_version
  namespace  = kubernetes_namespace_v1.agic[0].metadata[0].name

  set {
    name  = "appgw.name"
    value = var.application_gateway["name"]
  }
  set {
    name  = "appgw.resourceGroup"
    value = var.application_gateway["resource_group_name"]
  }
  set {
    name  = "appgw.subscriptionId"
    value = var.application_gateway["subscription_id"]
  }
  set {
    name  = "appgw.shared"
    value = tostring(var.application_gateway["shared"])
  }
  set {
    name  = "appgw.usePrivateIP"
    value = tostring(var.application_gateway["private"])
  }
  set {
    name  = "appgw.subResourceNamePrefix"
    value = "${var.materna_project_number}-${var.global_stage}-"
  }
  set {
    name  = "armAuth.type"
    value = "servicePrincipal"
  }

  set_sensitive {
    name = "armAuth.secretJSON"
    value = base64encode(jsonencode({
      "tenantId"                       = "${var.global_tenant_id}",
      "subscriptionId"                 = "${var.global_subscription_id}",
      "clientId"                       = "${data.azuread_service_principal.agic.application_id}",
      "clientSecret"                   = "${azuread_application_password.agic.value}",
      "activeDirectoryEndpointUrl"     = "https://login.microsoftonline.com",
      "resourceManagerEndpointUrl"     = "https://management.azure.com/",
      "activeDirectoryGraphResourceId" = "https://graph.windows.net/",
      "sqlManagementEndpointUrl"       = "https://management.core.windows.net:8443/",
      "galleryEndpointUrl"             = "https://gallery.azure.com/",
      "managementEndpointUrl"          = "https://management.core.windows.net/"
    }))
  }
  set {
    name  = "rbac.enabled"
    value = "true"
  }
  set {
    name  = "verbosityLevel"
    value = "3"
  }
  set {
    name  = "kubernetes.tolerations[0].key"
    value = "CriticalAddonsOnly"
  }
  set {
    name  = "kubernetes.tolerations[0].operator"
    value = "Exists"
  }
  set {
    name  = "kubernetes.tolerations[0].effect"
    value = "NoSchedule"
  }
  set {
    name  = "kubernetes.nodeSelector.agentpool"
    value = "system"
  }

  # User 0 nötig - ansonsten Fehler " Unable to load cloud provider config '/etc/appgw/azure.json'. Error: Reading Az Context file "/etc/appgw/azure.json" failed: open /etc/appgw/azure.json: permission denied"
  # https://github.com/Azure/application-gateway-kubernetes-ingress/issues/1018
  # https://github.com/Azure/application-gateway-kubernetes-ingress/pull/1031/files
  set {
    name  = "kubernetes.securityContext.runAsUser"
    value = "0"
  }
  set {
    name  = "kubernetes.containerSecurityContext.readOnlyRootFilesystem"
    value = "true"
  }
  set {
    name  = "kubernetes.containerSecurityContext.allowPrivilegeEscalation"
    value = "false"
  }
  set {
    name  = "kubernetes.resources.requests.cpu"
    value = "50m"
  }
  set {
    name  = "kubernetes.resources.requests.memory"
    value = "128Mi"
  }
  set {
    name  = "kubernetes.resources.limits.cpu"
    value = "80m"
  }
  set {
    name  = "kubernetes.resources.limits.memory"
    value = "512Mi"
  }

  # Nötig, wenn readOnlyRootFilesystem=true, da agic versucht, Zertifikatsdateien auf /tmp abzulegen
  set {
    name  = "kubernetes.volumes.extraVolumes[0].name"
    value = "tmp"
  }
  set {
    name  = "kubernetes.volumes.extraVolumes[0].emptyDir.sizeLimit"
    value = "500Mi"
  }
  set {
    name  = "kubernetes.volumes.extraVolumeMounts[0].name"
    value = "tmp"
  }
  set {
    name  = "kubernetes.volumes.extraVolumeMounts[0].mountPath"
    value = "/tmp"
  }
}

resource "kubernetes_namespace" "nginx" {
  count = var.create_nginx == true ? 1 : 0
  metadata {
    name = "ingress-nginx"
  }
}

# https://github.com/kubernetes/ingress-nginx/issues/4061#issuecomment-596525816
resource "helm_release" "ingress_nginx" {
  count      = var.create_nginx == true ? 1 : 0
  name       = "ingress-nginx"
  repository = "https://kubernetes.github.io/ingress-nginx"
  chart      = "ingress-nginx"
  version    = var.nginx_version
  namespace  = kubernetes_namespace.nginx[0].metadata[0].name


  set {
    name  = "controller.replicaCount"
    value = "2"
  }
  set {
    name  = "rbac.create"
    value = "true"
  }
  set {
    name  = "controller.service.externalTrafficPolicy"
    value = "Local"
  }
  set {
    name  = "controller.service.annotations.service\\.beta\\.kubernetes\\.io/azure-load-balancer-health-probe-request-path"
    value = "/healthz"
  }
  set {
    name  = "controller.service.annotations.service\\.beta\\.kubernetes\\.io/azure-load-balancer-internal"
    value = "true"
  }
  set {
    name  = "controller.service.annotations.service\\.beta\\.kubernetes\\.io/azure-load-balancer-internal-subnet"
    value = data.azurerm_subnet.system_node_pool.name
  }
  set {
    name  = "controller.podSecurityContext.runAsNonRoot"
    value = "true"
  }
  set {
    name  = "controller.podSecurityContext.runAsGroup"
    value = "101"
  }
  set {
    name  = "controller.podSecurityContext.runAsUser"
    value = "101"
  }
  set {
    name  = "controller.podSecurityContext.fsGroup"
    value = "101"
  }
  set {
    name  = "controller.containerSecurityContext.runAsNonRoot"
    value = "true"
  }
  set {
    name  = "controller.containerSecurityContext.runAsGroup"
    value = "101"
  }
  set {
    name  = "controller.containerSecurityContext.runAsUser"
    value = "101"
  }
  set {
    name  = "controller.containerSecurityContext.allowPrivilegeEscalation"
    value = "false"
  }
  set {
    name  = "controller.networkPolicy.enabled"
    value = "true"
  }
  set {
    name  = "controller.tolerations[0].key"
    value = "CriticalAddonsOnly"
  }
  set {
    name  = "controller.tolerations[0].operator"
    value = "Exists"
  }
  set {
    name  = "controller.tolerations[0].effect"
    value = "NoSchedule"
  }
  set {
    name  = "controller.nodeSelector.agentpool"
    value = "system"
  }
  set {
    name  = "controller.resources.requests.cpu"
    value = "50m"
  }
  set {
    name  = "controller.resources.requests.memory"
    value = "128Mi"
  }
  set {
    name  = "controller.resources.limits.cpu"
    value = "80m"
  }
  set {
    name  = "controller.resources.limits.memory"
    value = "512Mi"
  }

}

#########################
### Breakglass Account ##
#########################
resource "kubernetes_namespace" "breakglass_account" {
  count = var.create_breakglass_account == true ? 1 : 0
  metadata {
    name = "breakglass-account"
  }
}

resource "kubernetes_service_account_v1" "breakglass_account" {
  count = var.create_breakglass_account == true ? 1 : 0

  metadata {
    name      = "aks-${azurerm_kubernetes_cluster.this.name}-breakglass"
    namespace = kubernetes_namespace.breakglass_account[0].metadata[0].name
  }
}

resource "kubernetes_cluster_role_v1" "breakglass_account" {
  count = var.create_breakglass_account == true ? 1 : 0

  metadata {
    name = "breakglass-account-role"
  }

  rule {
    api_groups = ["*"]
    resources  = ["*"]
    verbs      = ["*"]
  }

  rule {
    non_resource_urls = ["*"]
    verbs             = ["*"]
  }
}

resource "kubernetes_cluster_role_binding_v1" "breakglass_account" {
  count = var.create_breakglass_account == true ? 1 : 0

  metadata {
    name = "breakglass-account-role-binding"
  }

  role_ref {
    api_group = "rbac.authorization.k8s.io"
    kind      = "ClusterRole"
    name      = kubernetes_cluster_role_v1.breakglass_account[0].metadata[0].name
  }

  subject {
    kind      = "ServiceAccount"
    name      = kubernetes_service_account_v1.breakglass_account[0].metadata[0].name
    namespace = kubernetes_service_account_v1.breakglass_account[0].metadata[0].namespace
  }
}

resource "kubernetes_secret_v1" "breakglass_account" {
  count = var.create_breakglass_account == true ? 1 : 0
  metadata {
    name      = "breakglass-account-secret"
    namespace = kubernetes_service_account_v1.breakglass_account[0].metadata[0].namespace

    annotations = {
      "kubernetes.io/service-account.name" = kubernetes_service_account_v1.breakglass_account[0].metadata[0].name
    }
  }

  type = "kubernetes.io/service-account-token"
}

###################
### External DNS ##
###################

resource "kubernetes_namespace_v1" "secret" {
  count = var.create_secret_namespace == true ? 1 : 0
  metadata {
    name = "secret-store"
  }
}

resource "kubernetes_secret_v1" "external_dns" {
  count = var.dns_zone == null ? 0 : 1

  metadata {
    name      = "cred-ext-dns"
    namespace = kubernetes_namespace_v1.secret[0].metadata[0].name
    labels = {
      destination-namespace = "external-dns"
    }
  }

  type = "Opaque"
  data = {
    "azure.json" = jsonencode({
      "tenantId" : "${var.global_tenant_id}",
      "subscriptionId" : "${var.dns_zone["subscription_id"]}",
      "resourceGroup" : "${var.dns_zone["resource_group_name"]}",
      "aadClientId" : "${data.azuread_service_principal.external_dns[0].application_id}",
      "aadClientSecret" : "${azuread_application_password.external_dns[0].value}"
    })
  }
}
