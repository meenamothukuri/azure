locals {
  common_tags = {
    deployment    = "terraform"
    stage         = lower(var.global_stage)
    createdondate = formatdate("YYYY-MM-DD", timestamp())
    cost_center   = lower(var.materna_cost_center)

  }
}
