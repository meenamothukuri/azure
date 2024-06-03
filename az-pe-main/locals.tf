locals {
  common_tags = {
    deployment    = "terraform"
    stage         = lower(var.global_stage)
    createdondate = formatdate("YYYY-MM-DD", timestamp())
    cost_center   = lower(var.materna_cost_center)
  }

  private_dns_zones = var.private_dns_zone == null || !(var.manual_private_dns_zone_entry == null) ? [] : [{
    name                 = var.private_dns_zone["name"]
    private_dns_zone_ids = [var.private_dns_zone["id"]]
  }]
}
