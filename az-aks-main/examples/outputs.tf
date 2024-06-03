output "aks_id" {
  value = module.aks.aks_id
}

output "aks_public_network_access_enabled" {
  value = module.aks.aks_public_network_access_enabled
}

output "aks_private_cluster_enabled" {
  value = module.aks.aks_private_cluster_enabled
}

output "aks_private_dns_zone_id" {
  value = module.aks.aks_private_dns_zone_id
}

output "breakglass_account_token" {
  value = module.aks.breakglass_account_token
}

output "breakglass_account_ca_data" {
  value = module.aks.breakglass_account_ca_data
}
