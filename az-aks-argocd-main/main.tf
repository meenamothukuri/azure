resource "kubernetes_namespace" "argocd_manager" {
  metadata {
    name = "argocd-manager"
  }
}


resource "kubernetes_service_account_v1" "argocd_manager" {
  metadata {
    name      = "argocd-manager"
    namespace = kubernetes_namespace.argocd_manager.metadata[0].name
  }
}

resource "kubernetes_cluster_role_v1" "argocd_manager" {
  metadata {
    name = "argocd-manager-role"
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

resource "kubernetes_cluster_role_binding_v1" "argocd_manager" {
  metadata {
    name = "argocd-manager-role-binding"
  }

  role_ref {
    api_group = "rbac.authorization.k8s.io"
    kind      = "ClusterRole"
    name      = kubernetes_cluster_role_v1.argocd_manager.metadata[0].name
  }

  subject {
    kind      = "ServiceAccount"
    name      = kubernetes_service_account_v1.argocd_manager.metadata[0].name
    namespace = kubernetes_service_account_v1.argocd_manager.metadata[0].namespace
  }
}

resource "kubernetes_secret_v1" "argocd_manager" {
  metadata {
    name      = "argocd-manager-secret"
    namespace = kubernetes_service_account_v1.argocd_manager.metadata[0].namespace

    annotations = {
      "kubernetes.io/service-account.name" = kubernetes_service_account_v1.argocd_manager.metadata[0].name
    }
  }

  type = "kubernetes.io/service-account-token"
}


resource "argocd_cluster" "this" {
  server = var.aks_cluster.server
  name   = var.aks_cluster.name

  metadata {
    labels = merge(local.bootstrap, local.mapped_projects, {
      managed-by    = "argocd"
      dns_zone_name = var.dns_zone_name == null ? "" : var.dns_zone_name
    })
  }
  config {
    bearer_token = kubernetes_secret_v1.argocd_manager.data["token"]
    tls_client_config {
      ca_data     = kubernetes_secret_v1.argocd_manager.data["ca.crt"]
      server_name = var.aks_cluster.tls_server_name
    }
  }
}



