locals {
  common_tags = {
    deployment    = "terraform"
    stage         = lower(var.global_stage)
    createdondate = formatdate("YYYY-MM-DD", timestamp())
    cost_center   = lower(var.materna_cost_center)
  }

  disk_access_name = "${var.global_hyperscaler}${var.global_hyperscaler_location}-${var.materna_customer_name}-da-${var.materna_project_number}-${var.global_stage}-${format("%02d", var.disk_access_instance)}"
}
