locals {
  common_tags = {
    deployment    = "terraform"
    stage         = lower(var.global_stage)
    createdondate = formatdate("YYYY-MM-DD", timestamp())
    cost_center   = lower(var.materna_cost_center)
  }
  domain_name = var.domain_name == null ? "${var.global_hyperscaler}${var.global_hyperscaler_location}${var.materna_customer_name}pdns${var.materna_project_number}${var.global_stage}${format("%02d", var.private_dns_zone_instance)}" : var.domain_name

}
