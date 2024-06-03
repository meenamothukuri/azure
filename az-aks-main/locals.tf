locals {
  common_tags = {
    deployment    = "terraform"
    stage         = lower(var.global_stage)
    createdondate = formatdate("YYYY-MM-DD", timestamp())
    cost_center   = lower(var.materna_cost_center)
  }

  enterprise_application_password_name = "${var.global_hyperscaler}${var.global_hyperscaler_location}-${var.materna_customer_name}-ap-${var.materna_project_number}-${var.global_stage}-${format("%02d", var.aks_instance_id)}"

  cluster_admins                                         = [for group in data.azuread_group.this : group.id]
  resource_group_kubernetes_nodes_materna_project_number = var.resource_group_kubernetes_nodes_materna_project_number == null ? var.materna_project_number : var.resource_group_kubernetes_nodes_materna_project_number

  aks_kubernetes_version = try(length(var.aks_kubernetes_version), 0) > 0 ? var.aks_kubernetes_version : data.azurerm_kubernetes_service_versions.this.latest_version

  #key_management_service = var.encryption == null ? [] : [{
  #  key_vault_key_id         = data.azurerm_key_vault_key.kvk[0].id
  #  key_vault_network_access = "Private"
  #}]
}
