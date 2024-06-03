module "global_constants" {
  source  = "gitlab.prd.materna.work/registries/az-global-constants/azure"
  version = "1.2.1"

  global_hyperscaler = var.global_hyperscaler

  private_dns_zone = var.private_endpoint == null ? null : var.private_endpoint["custom_private_dns_zone"]
  private_endpoint = var.private_endpoint == null ? null : var.private_endpoint["custom_config"]
}

resource "azurecaf_name" "agw" {
  resource_type = "azurerm_application_gateway"
  prefixes      = [format("%s%s", var.global_hyperscaler, var.global_hyperscaler_location), var.materna_customer_name]
  suffixes      = [var.materna_project_number, var.global_stage, format("%02d", var.application_gateway_instance)]
  clean_input   = true
}

resource "azurerm_role_assignment" "agic_rg" {
  count = var.agic_service_principal_name == null ? 0 : 1

  scope                = data.azurerm_resource_group.rg.id
  role_definition_name = "Contributor"
  principal_id         = data.azuread_service_principal.agic[0].id
}

resource "azurerm_role_assignment" "agic_network" {
  count = var.agic_service_principal_name == null || var.enable_agic_network_role_assignment == false ? 0 : 1

  scope                = data.azurerm_virtual_network.vnet_gateway.id
  role_definition_name = "Network Contributor"
  principal_id         = data.azuread_service_principal.agic[0].id
}

resource "azurerm_web_application_firewall_policy" "waf_fw_policy" {
  count               = var.sku["name"] == "WAF_v2" ? 1 : 0
  name                = local.waf_policy_name
  resource_group_name = data.azurerm_resource_group.rg.name
  location            = data.azurerm_resource_group.rg.location

  policy_settings {
    enabled                     = true
    mode                        = var.waf_enable_prevention_mode ? "Prevention" : "Detection"
    request_body_check          = var.waf_enable_request_body_check
    file_upload_limit_in_mb     = 100
    max_request_body_size_in_kb = var.waf_enable_max_request_body_size ? 128 : null
  }

  dynamic "custom_rules" {
    for_each = coalesce(merge(local.default_custom_rule, var.waf_custom_rules), tomap({}))
    content {
      enabled   = custom_rules.value.enabled
      name      = custom_rules.value.rule_name
      priority  = custom_rules.value.priority
      rule_type = custom_rules.value.rule_type

      dynamic "match_conditions" {
        for_each = custom_rules.value.match_conditions
        content {

          dynamic "match_variables" {
            for_each = match_conditions.value.match_variables
            content {
              variable_name = match_variables.value.variable_name
              selector      = match_variables.value.selector
            }
          }

          match_values       = match_conditions.value.match_values
          operator           = match_conditions.value.operator
          negation_condition = match_conditions.value.negation_condition
          transforms         = match_conditions.value.transforms
        }
      }

      action               = custom_rules.value.action
      rate_limit_duration  = custom_rules.value.rate_limit_duration
      rate_limit_threshold = custom_rules.value.rate_limit_threshold
      group_rate_limit_by  = custom_rules.value.group_rate_limit_by
    }
  }

  managed_rules {
    managed_rule_set {
      type    = "OWASP"
      version = "3.2"
      dynamic "rule_group_override" {
        for_each = var.waf_owasp_exclusions
        content {
          rule_group_name = rule_group_override.value["rule_group_name"]
          dynamic "rule" {
            for_each = toset(rule_group_override.value["rule_ids"])
            content {
              id      = rule.value
              enabled = true
              action  = "Log"
            }
          }
        }
      }
    }
  }

  tags = merge(local.common_tags, var.tags)
}

resource "azurerm_application_gateway" "this" {
  count = var.create_updatable_agw ? 0 : 1

  name                = lower(azurecaf_name.agw.result)
  resource_group_name = data.azurerm_resource_group.rg.name
  location            = data.azurerm_resource_group.rg.location

  firewall_policy_id = var.sku["name"] == "WAF_v2" ? azurerm_web_application_firewall_policy.waf_fw_policy[0].id : null
  enable_http2       = var.enable_http2

  sku {
    name     = var.sku["name"]
    tier     = var.sku["tier"]
    capacity = var.sku["capacity"]
  }

  gateway_ip_configuration {
    name      = local.gateway_ip_configuration_name
    subnet_id = data.azurerm_subnet.snet_gateway.id
  }

  frontend_port {
    name = local.frontend_port_name
    port = var.frontend_port
  }

  dynamic "frontend_port" {
    for_each = toset(var.ssl_certificate_config == null ? [] : ["1"])
    content {
      name = local.frontend_port_name_ssl
      port = 443
    }
  }

  dynamic "frontend_ip_configuration" {
    for_each = toset(var.public_ip_name == null ? [] : ["1"])
    content {
      name                 = local.frontend_ip_configuration_public_name
      public_ip_address_id = local.pip_id
    }
  }

  dynamic "frontend_ip_configuration" {
    for_each = toset(var.private_endpoint == null ? [] : ["1"])
    content {
      name                            = local.frontend_ip_configuration_private_name
      private_ip_address_allocation   = "Static"
      private_ip_address              = cidrhost(data.azurerm_subnet.snet_gateway.address_prefixes[0], 5)
      subnet_id                       = data.azurerm_subnet.snet_gateway.id
      private_link_configuration_name = local.frontend_ip_configuration_private_name
    }
  }

  dynamic "private_link_configuration" {
    for_each = toset(var.private_endpoint == null ? [] : ["1"])
    content {
      name = local.frontend_ip_configuration_private_name
      ip_configuration {
        name                          = "primary"
        subnet_id                     = data.azurerm_subnet.snet_gateway.id
        private_ip_address_allocation = "Dynamic"
        primary                       = true
      }
    }
  }

  dynamic "backend_address_pool" {
    for_each = local.backend_config
    content {
      name         = "${backend_address_pool.key}-bap"
      ip_addresses = backend_address_pool.value["ip_addresses"]
      fqdns        = backend_address_pool.value["fqdns"]
    }
  }

  dynamic "backend_http_settings" {
    for_each = local.backend_config
    content {
      name                  = "${backend_http_settings.key}-bhs"
      cookie_based_affinity = backend_http_settings.value["cookie_based_affinity"] ? "Enabled" : "Disabled"
      path                  = backend_http_settings.value["path"]
      port                  = backend_http_settings.value["port"]
      protocol              = backend_http_settings.value["port"] == 443 ? "Https" : "Http"
      request_timeout       = backend_http_settings.value["request_timeout"]
      probe_name            = "${backend_http_settings.key}-pb"
    }
  }

  dynamic "http_listener" {
    for_each = local.backend_config
    content {
      name                           = "${http_listener.key}-hl"
      frontend_ip_configuration_name = var.private_endpoint == null ? local.frontend_ip_configuration_public_name : local.frontend_ip_configuration_private_name
      frontend_port_name             = local.frontend_port_name
      protocol                       = "Http"
      host_name                      = http_listener.value["hostname"] == null ? "default.default" : http_listener.value["hostname"]
    }
  }

  dynamic "http_listener" {
    for_each = var.ssl_certificate_config == null ? {} : local.backend_config
    content {
      name                           = "${http_listener.key}-hl-ssl"
      frontend_ip_configuration_name = var.private_endpoint == null ? local.frontend_ip_configuration_public_name : local.frontend_ip_configuration_private_name
      frontend_port_name             = local.frontend_port_name_ssl
      protocol                       = "Https"
      host_name                      = http_listener.value["hostname"] == null ? "default.default" : http_listener.value["hostname"]
      ssl_certificate_name           = "${http_listener.key}-ssl-crt"
    }
  }

  dynamic "ssl_certificate" {
    for_each = var.ssl_certificate_config == null ? {} : var.ssl_certificate_config["type"] == "prod" || var.ssl_certificate_config["type"] == "staging" ? local.backend_config : {}
    content {
      name     = "${ssl_certificate.key}-ssl-crt"
      data     = var.ssl_certificate_config["type"] == "prod" ? acme_certificate.certificate_prod[ssl_certificate.key].certificate_p12 : acme_certificate.certificate_staging[ssl_certificate.key].certificate_p12
      password = var.ssl_certificate_config["type"] == "prod" ? acme_certificate.certificate_prod[ssl_certificate.key].certificate_p12_password : acme_certificate.certificate_staging[ssl_certificate.key].certificate_p12_password
    }
  }

  dynamic "redirect_configuration" {
    for_each = var.ssl_certificate_config == null ? {} : local.backend_config
    content {
      name                 = "${redirect_configuration.key}-reco"
      target_listener_name = "${redirect_configuration.key}-hl-ssl"
      redirect_type        = "Permanent"
      include_path         = true
      include_query_string = true
    }
  }


  dynamic "probe" {
    for_each = local.backend_config
    content {
      name                                      = "${probe.key}-pb"
      pick_host_name_from_backend_http_settings = false
      host                                      = probe.value["hostname"] == null ? "default.default" : probe.value["hostname"]
      interval                                  = 10 # seconds
      timeout                                   = 2
      unhealthy_threshold                       = 3
      protocol                                  = probe.value["port"] == 443 ? "Https" : "Http"
      path                                      = probe.value["health_check_path"] == null ? probe.value["path"] : probe.value["health_check_path"]
      port                                      = probe.value["port"]
      minimum_servers                           = 0
    }
  }

  dynamic "request_routing_rule" {
    for_each = local.backend_config
    content {
      name                        = "${request_routing_rule.key}-rrl"
      rule_type                   = "Basic"
      http_listener_name          = "${request_routing_rule.key}-hl"
      priority                    = request_routing_rule.value["priority"]
      backend_address_pool_name   = var.ssl_certificate_config == null ? "${request_routing_rule.key}-bap" : null
      backend_http_settings_name  = var.ssl_certificate_config == null ? "${request_routing_rule.key}-bhs" : null
      redirect_configuration_name = var.ssl_certificate_config == null ? null : "${request_routing_rule.key}-reco"
    }
  }
  dynamic "request_routing_rule" {
    for_each = var.ssl_certificate_config == null ? {} : local.backend_config
    content {
      name                       = "${request_routing_rule.key}-rrl-ssl"
      rule_type                  = "Basic"
      http_listener_name         = "${request_routing_rule.key}-hl-ssl"
      priority                   = abs((request_routing_rule.value["priority"] - 20000)) + 1
      backend_address_pool_name  = "${request_routing_rule.key}-bap"
      backend_http_settings_name = "${request_routing_rule.key}-bhs"
    }
  }
  tags = merge(local.common_tags, var.tags)

  lifecycle {
    ignore_changes = all
  }

}

# Benötigt, bis gelöst: https://github.com/hashicorp/terraform/issues/24188
# Inhalt der beiden AGW Resources immer exakt gleich - bis auf "lifecycle - ignore_changes"
resource "azurerm_application_gateway" "this_updatable" {
  count = var.create_updatable_agw ? 1 : 0

  name                = lower(azurecaf_name.agw.result)
  resource_group_name = data.azurerm_resource_group.rg.name
  location            = data.azurerm_resource_group.rg.location

  firewall_policy_id = var.sku["name"] == "WAF_v2" ? azurerm_web_application_firewall_policy.waf_fw_policy[0].id : null
  enable_http2       = var.enable_http2

  sku {
    name     = var.sku["name"]
    tier     = var.sku["tier"]
    capacity = var.sku["capacity"]
  }

  gateway_ip_configuration {
    name      = local.gateway_ip_configuration_name
    subnet_id = data.azurerm_subnet.snet_gateway.id
  }

  frontend_port {
    name = local.frontend_port_name
    port = var.frontend_port
  }

  dynamic "frontend_port" {
    for_each = toset(var.ssl_certificate_config == null ? [] : ["1"])
    content {
      name = local.frontend_port_name_ssl
      port = 443
    }
  }

  dynamic "frontend_ip_configuration" {
    for_each = toset(var.public_ip_name == null ? [] : ["1"])
    content {
      name                 = local.frontend_ip_configuration_public_name
      public_ip_address_id = local.pip_id
    }
  }

  dynamic "frontend_ip_configuration" {
    for_each = toset(var.private_endpoint == null ? [] : ["1"])
    content {
      name                            = local.frontend_ip_configuration_private_name
      private_ip_address_allocation   = "Static"
      private_ip_address              = cidrhost(data.azurerm_subnet.snet_gateway.address_prefixes[0], 5)
      subnet_id                       = data.azurerm_subnet.snet_gateway.id
      private_link_configuration_name = local.frontend_ip_configuration_private_name
    }
  }

  dynamic "private_link_configuration" {
    for_each = toset(var.private_endpoint == null ? [] : ["1"])
    content {
      name = local.frontend_ip_configuration_private_name
      ip_configuration {
        name                          = "primary"
        subnet_id                     = data.azurerm_subnet.snet_gateway.id
        private_ip_address_allocation = "Dynamic"
        primary                       = true
      }
    }
  }

  dynamic "backend_address_pool" {
    for_each = local.backend_config
    content {
      name         = "${backend_address_pool.key}-bap"
      ip_addresses = backend_address_pool.value["ip_addresses"]
      fqdns        = backend_address_pool.value["fqdns"]
    }
  }

  dynamic "backend_http_settings" {
    for_each = local.backend_config
    content {
      name                  = "${backend_http_settings.key}-bhs"
      cookie_based_affinity = backend_http_settings.value["cookie_based_affinity"] ? "Enabled" : "Disabled"
      path                  = backend_http_settings.value["path"]
      port                  = backend_http_settings.value["port"]
      protocol              = backend_http_settings.value["port"] == 443 ? "Https" : "Http"
      request_timeout       = backend_http_settings.value["request_timeout"]
      probe_name            = "${backend_http_settings.key}-pb"
    }
  }

  dynamic "http_listener" {
    for_each = local.backend_config
    content {
      name                           = "${http_listener.key}-hl"
      frontend_ip_configuration_name = var.private_endpoint == null ? local.frontend_ip_configuration_public_name : local.frontend_ip_configuration_private_name
      frontend_port_name             = local.frontend_port_name
      protocol                       = "Http"
      host_name                      = http_listener.value["hostname"] == null ? "default.default" : http_listener.value["hostname"]
    }
  }

  dynamic "http_listener" {
    for_each = var.ssl_certificate_config == null ? {} : local.backend_config
    content {
      name                           = "${http_listener.key}-hl-ssl"
      frontend_ip_configuration_name = var.private_endpoint == null ? local.frontend_ip_configuration_public_name : local.frontend_ip_configuration_private_name
      frontend_port_name             = local.frontend_port_name_ssl
      protocol                       = "Https"
      host_name                      = http_listener.value["hostname"] == null ? "default.default" : http_listener.value["hostname"]
      ssl_certificate_name           = "${http_listener.key}-ssl-crt"
    }
  }

  dynamic "ssl_certificate" {
    for_each = var.ssl_certificate_config == null ? {} : var.ssl_certificate_config["type"] == "prod" || var.ssl_certificate_config["type"] == "staging" ? local.backend_config : {}
    content {
      name     = "${ssl_certificate.key}-ssl-crt"
      data     = var.ssl_certificate_config["type"] == "prod" ? acme_certificate.certificate_prod[ssl_certificate.key].certificate_p12 : acme_certificate.certificate_staging[ssl_certificate.key].certificate_p12
      password = var.ssl_certificate_config["type"] == "prod" ? acme_certificate.certificate_prod[ssl_certificate.key].certificate_p12_password : acme_certificate.certificate_staging[ssl_certificate.key].certificate_p12_password
    }
  }

  dynamic "redirect_configuration" {
    for_each = var.ssl_certificate_config == null ? {} : local.backend_config
    content {
      name                 = "${redirect_configuration.key}-reco"
      target_listener_name = "${redirect_configuration.key}-hl-ssl"
      redirect_type        = "Permanent"
      include_path         = true
      include_query_string = true
    }
  }


  dynamic "probe" {
    for_each = local.backend_config
    content {
      name                                      = "${probe.key}-pb"
      pick_host_name_from_backend_http_settings = false
      host                                      = probe.value["hostname"] == null ? "default.default" : probe.value["hostname"]
      interval                                  = 10 # seconds
      timeout                                   = 2
      unhealthy_threshold                       = 3
      protocol                                  = probe.value["port"] == 443 ? "Https" : "Http"
      path                                      = probe.value["health_check_path"] == null ? probe.value["path"] : probe.value["health_check_path"]
      port                                      = probe.value["port"]
      minimum_servers                           = 0
    }
  }

  dynamic "request_routing_rule" {
    for_each = local.backend_config
    content {
      name                        = "${request_routing_rule.key}-rrl"
      rule_type                   = "Basic"
      http_listener_name          = "${request_routing_rule.key}-hl"
      priority                    = request_routing_rule.value["priority"]
      backend_address_pool_name   = var.ssl_certificate_config == null ? "${request_routing_rule.key}-bap" : null
      backend_http_settings_name  = var.ssl_certificate_config == null ? "${request_routing_rule.key}-bhs" : null
      redirect_configuration_name = var.ssl_certificate_config == null ? null : "${request_routing_rule.key}-reco"
    }
  }
  dynamic "request_routing_rule" {
    for_each = var.ssl_certificate_config == null ? {} : local.backend_config
    content {
      name                       = "${request_routing_rule.key}-rrl-ssl"
      rule_type                  = "Basic"
      http_listener_name         = "${request_routing_rule.key}-hl-ssl"
      priority                   = abs((request_routing_rule.value["priority"] - 20000)) + 1
      backend_address_pool_name  = "${request_routing_rule.key}-bap"
      backend_http_settings_name = "${request_routing_rule.key}-bhs"
    }
  }
  tags = merge(local.common_tags, var.tags)
}

module "private_endpoint" {
  count = var.private_endpoint == null ? 0 : 1
  providers = {
    azurerm = azurerm.common
  }
  source  = "gitlab.prd.materna.work/registries/az-pe/azure"
  version = "1.0.0"

  global_subscription_id      = var.global_subscription_id
  global_stage                = var.global_stage
  global_hyperscaler          = var.global_hyperscaler
  global_hyperscaler_location = var.global_hyperscaler_location

  materna_customer_name  = var.materna_customer_name
  materna_project_number = var.materna_project_number
  materna_cost_center    = var.materna_cost_center

  resource_group_name       = module.global_constants.private_endpoint["resource_group_name"]
  private_endpoint_instance = var.private_endpoint["instance"]

  subnet = {
    name                        = module.global_constants.private_endpoint["subnet"]["name"]
    network_name                = module.global_constants.private_endpoint["subnet"]["network_name"]
    network_resource_group_name = module.global_constants.private_endpoint["subnet"]["network_resource_group_name"]
  }

  private_dns_zone = null

  private_connection_resource_id = var.create_updatable_agw ? azurerm_application_gateway.this_updatable[0].id : azurerm_application_gateway.this[0].id
  is_manual_connection           = false
  subresource_names              = [local.frontend_ip_configuration_private_name]

  tags = var.tags
}


##############################################
#################### ACME ####################
##############################################


resource "tls_private_key" "private_key_staging" {
  count = var.ssl_certificate_config == null ? 0 : var.ssl_certificate_config["type"] == "staging" ? 1 : 0

  algorithm = "RSA"
}


resource "tls_private_key" "private_key_prod" {
  count = var.ssl_certificate_config == null ? 0 : var.ssl_certificate_config["type"] == "prod" ? 1 : 0

  algorithm = "RSA"
}

resource "acme_registration" "reg_staging" {
  provider = acme.staging

  count = var.ssl_certificate_config == null ? 0 : var.ssl_certificate_config["type"] == "staging" ? 1 : 0

  account_key_pem = tls_private_key.private_key_staging[0].private_key_pem
  email_address   = var.ssl_certificate_config["email_address"]
}

resource "acme_registration" "reg_prod" {
  provider = acme.prod

  count = var.ssl_certificate_config == null ? 0 : var.ssl_certificate_config["type"] == "prod" ? 1 : 0

  account_key_pem = tls_private_key.private_key_prod[0].private_key_pem
  email_address   = var.ssl_certificate_config["email_address"]
}

resource "random_password" "cert_staging" {
  count = var.ssl_certificate_config == null ? 0 : var.ssl_certificate_config["type"] == "staging" ? 1 : 0

  length  = 24
  special = true
}

resource "random_password" "cert_prod" {
  count = var.ssl_certificate_config == null ? 0 : var.ssl_certificate_config["type"] == "prod" ? 1 : 0

  length  = 24
  special = true
}

resource "azuread_application_password" "dns" {
  count = var.ssl_certificate_config == null ? 0 : 1

  display_name   = "agw-acme-${lower(azurecaf_name.agw.result)}"
  application_id = data.azuread_application.dns[0].id
}

resource "acme_certificate" "certificate_staging" {
  provider = acme.staging

  for_each = var.ssl_certificate_config == null || var.backend_config == null ? {} : var.ssl_certificate_config["type"] == "staging" ? var.backend_config : {}

  account_key_pem          = acme_registration.reg_staging[0].account_key_pem
  common_name              = each.value["hostname"]
  certificate_p12_password = random_password.cert_staging[0].result
  pre_check_delay          = var.ssl_certificate_config["pre_check_delay"]

  min_days_remaining = 80

  dns_challenge {
    provider = "azure"

    config = {
      AZURE_CLIENT_ID       = data.azuread_application.dns[0].client_id
      AZURE_CLIENT_SECRET   = azuread_application_password.dns[0].value
      AZURE_TENANT_ID       = data.azuread_service_principal.dns[0].application_tenant_id
      AZURE_SUBSCRIPTION_ID = var.ssl_certificate_config["dns_zone"]["subscription_id"]
      AZURE_ZONE_NAME       = var.ssl_certificate_config["dns_zone"]["name"]
      AZURE_RESOURCE_GROUP  = var.ssl_certificate_config["dns_zone"]["resource_group_name"]
      AZURE_TTL             = 60
    }
  }
}

resource "acme_certificate" "certificate_prod" {
  provider = acme.prod

  for_each = var.ssl_certificate_config == null || var.backend_config == null ? {} : var.ssl_certificate_config["type"] == "prod" ? var.backend_config : {}

  account_key_pem          = acme_registration.reg_prod[0].account_key_pem
  common_name              = each.value["hostname"]
  certificate_p12_password = random_password.cert_prod[0].result
  pre_check_delay          = var.ssl_certificate_config["pre_check_delay"]

  min_days_remaining = 80

  dns_challenge {
    provider = "azure"

    config = {
      AZURE_CLIENT_ID       = data.azuread_application.dns[0].client_id
      AZURE_CLIENT_SECRET   = azuread_application_password.dns[0].value
      AZURE_TENANT_ID       = data.azuread_service_principal.dns[0].application_tenant_id
      AZURE_SUBSCRIPTION_ID = var.ssl_certificate_config["dns_zone"]["subscription_id"]
      AZURE_ZONE_NAME       = var.ssl_certificate_config["dns_zone"]["name"]
      AZURE_RESOURCE_GROUP  = var.ssl_certificate_config["dns_zone"]["resource_group_name"]
      AZURE_TTL             = 60
    }
  }
}

