module "resource_group" {
  #source = "git@gitlab.prd.materna.digital:components/terraform/azure/az-rg"
  source  = "gitlab.prd.materna.work/registries/az-rg/azure"
  version = "1.0.0"


  global_subscription_id      = var.ARM_SUBSCRIPTION_ID
  global_stage                = var.global_stage
  global_hyperscaler          = var.global_hyperscaler
  global_hyperscaler_location = var.global_hyperscaler_location

  materna_customer_name  = var.materna_customer_name
  materna_project_number = var.materna_project_number
  materna_cost_center    = var.materna_cost_center

  resource_group_location = var.global_hyperscaler_location_long
  resource_group_instance = 1

  tags = var.tags
}


module "subnet" {
  #source = "git@gitlab.prd.materna.digital:components/terraform/azure/az-snet"
  source  = "gitlab.prd.materna.work/registries/az-snet/azure"
  version = "1.0.0"

  global_subscription_id      = var.ARM_SUBSCRIPTION_ID
  global_stage                = var.global_stage
  global_hyperscaler          = var.global_hyperscaler
  global_hyperscaler_location = var.global_hyperscaler_location

  materna_customer_name  = var.materna_customer_name
  materna_project_number = var.materna_project_number
  materna_cost_center    = var.materna_cost_center

  resource_group_name = var.network["resource_group_name"]
  subnet_instance     = 1
  vnet_name           = var.network["name"]
  address_prefix      = var.subnet_agw_address_prefix
}

module "public_ip" {
  #source = "git@gitlab.prd.materna.digital:components/terraform/azure/az-pip"
  source  = "gitlab.prd.materna.work/registries/az-pip/azure"
  version = "1.0.0"

  global_subscription_id      = var.ARM_SUBSCRIPTION_ID
  global_stage                = var.global_stage
  global_hyperscaler          = var.global_hyperscaler
  global_hyperscaler_location = var.global_hyperscaler_location

  materna_customer_name  = var.materna_customer_name
  materna_project_number = var.materna_project_number
  materna_cost_center    = var.materna_cost_center

  resource_group_name = module.resource_group.rg_name

  tags = var.tags
}


module "my_agw" {
  source = "../"
  providers = {
    azurerm        = azurerm,
    azurerm.common = azurerm,
    acme.prod      = acme.prod,
    acme.staging   = acme.staging,
  }

  global_subscription_id      = var.ARM_SUBSCRIPTION_ID
  global_stage                = var.global_stage
  global_hyperscaler          = var.global_hyperscaler
  global_hyperscaler_location = var.global_hyperscaler_location

  materna_customer_name  = var.materna_customer_name
  materna_project_number = var.materna_project_number
  materna_cost_center    = var.materna_cost_center

  resource_group_name = module.resource_group.rg_name
  public_ip_name      = module.public_ip.pip_name
  #agic_service_principal_name = var.agic_service_principal_name

  subnet = {
    name                        = module.subnet.snet_name
    network_name                = module.subnet.vnet_name
    network_resource_group_name = module.subnet.rg_name
  }

  ssl_certificate_config = var.ssl_certificate_config == null ? null : {
    email_address = var.ssl_certificate_config["email_address"]
    type          = var.ssl_certificate_config["type"]
    dns_zone = {
      name                       = var.ssl_certificate_config["dns_zone"]["name"]
      resource_group_name        = var.ssl_certificate_config["dns_zone"]["resource_group_name"]
      subscription_id            = var.ssl_certificate_config["dns_zone"]["subscription_id"]
      dns_service_principal_name = var.ssl_certificate_config["dns_zone"]["dns_service_principal_name"]
    }
  }

  waf_restrict_for_ips = var.waf_restrict_for_ips
  waf_custom_rules     = var.waf_custom_rules

  create_updatable_agw = var.create_updatable_agw
  backend_config       = var.backend_config

  tags = var.tags
}
