/**
output "argocd_manager" {
  value = {
    bearer_token = module.aks_argocd.bearer_token
    ca_data      = module.aks_argocd.ca_data
    aks_server   = module.aks_argocd.aks_server
  }
  sensitive = true
}
**/

output "aks" {
  value = {
    host                   = module.aks.kubeconfig.0.host
    token                  = module.aks.kubeconfig.0.password
    client_certificate     = base64decode(module.aks.kubeconfig.0.client_certificate)
    client_key             = base64decode(module.aks.kubeconfig.0.client_key)
    cluster_ca_certificate = base64decode(module.aks.kubeconfig.0.cluster_ca_certificate)
    node_resource_group    = module.aks.aks_node_resource_group
  }
  sensitive = true
}