locals {
  projects = flatten([
    for key, value in var.projects : {
      "proj-${key}" = "${value.repository}-${value.branch}"
    }
  ])

  mapped_projects = merge(local.projects...)

  bootstrap = var.bootstrap == "none" ? {} : var.bootstrap == "stable" ? {
    bootstrap = "k8s-infra-bootstrap-main"
    } : {
    bootstrap = "k8s-infra-bootstrap-develop"
  }
}

