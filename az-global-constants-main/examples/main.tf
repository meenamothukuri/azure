module "const" {
  source             = "../"
  global_hyperscaler = local.global_hyperscaler
  private_dns_zone   = local.private_dns_zone
  private_endpoint   = local.private_endpoint
}
