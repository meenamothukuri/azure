output "bearer_token" {
  value = kubernetes_secret_v1.argocd_manager.data["token"]
}

output "ca_data" {
  value = base64encode(kubernetes_secret_v1.argocd_manager.data["ca.crt"]) # base64decode(var.aks_cluster.ca_certificate_base64)
}

output "aks_server" {
  value = var.aks_cluster.server
}
