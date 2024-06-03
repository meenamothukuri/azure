output "kube_config" {
  value     = azurerm_kubernetes_cluster.this.kube_config_raw
  sensitive = true
}

output "kubeconfig" {
  value     = azurerm_kubernetes_cluster.this.kube_admin_config
  sensitive = true
}

output "aks_id" {
  value = azurerm_kubernetes_cluster.this.id
}

output "aks_public_network_access_enabled" {
  value = azurerm_kubernetes_cluster.this.public_network_access_enabled
}

output "aks_private_cluster_enabled" {
  value = azurerm_kubernetes_cluster.this.private_cluster_enabled
}

output "aks_private_dns_zone_id" {
  value = azurerm_kubernetes_cluster.this.private_dns_zone_id
}

output "aks_instance_id" {
  value = var.aks_instance_id
}

output "managed_identity_id" {
  value = azurerm_user_assigned_identity.this.id
}

output "managed_identity_name" {
  value = azurerm_user_assigned_identity.this.name
}

output "rg_id" {
  value = data.azurerm_resource_group.this.id
}

output "rg_name" {
  value = data.azurerm_resource_group.this.name
}

output "aks_node_resource_group" {
  value = azurerm_kubernetes_cluster.this.node_resource_group
}

output "aks_name" {
  value = azurerm_kubernetes_cluster.this.name
}

output "global_stage" {
  value = var.global_stage
}

output "breakglass_account_token" {
  value = var.create_breakglass_account ? kubernetes_secret_v1.breakglass_account[0].data["token"] : null
}

output "breakglass_account_ca_data" {
  value = var.create_breakglass_account ? base64encode(kubernetes_secret_v1.breakglass_account[0].data["ca.crt"]) : null # base64decode(var.aks_cluster.ca_certificate_base64)
}
