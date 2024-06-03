locals {
  common_tags = {
    deployment    = "terraform"
    stage         = lower(var.global_stage)
    createdondate = formatdate("YYYY-MM-DD", timestamp())
    cost_center   = lower(var.materna_cost_center)
  }

  backend_address_pool_name              = "default"
  frontend_port_name                     = "default"
  frontend_port_name_ssl                 = "defaultssl"
  frontend_ip_configuration_public_name  = "defaultpublic"
  frontend_ip_configuration_private_name = "defaultprivate"
  gateway_ip_configuration_name          = "default"
  http_setting_name                      = "default"
  listener_name                          = "default"
  request_routing_rule_name              = "default"

  local_default_backend_map = {
    default = {
      ip_addresses          = null
      fqdns                 = null
      port                  = 80
      hostname              = null
      cookie_based_affinity = false
      path                  = "/"
      request_timeout       = 1
      health_check_path     = "/"
      priority              = 20000
    }
  }

  backend_config = var.backend_config == null ? local.local_default_backend_map : length(var.backend_config) == 0 ? local.local_default_backend_map : var.backend_config

  waf_policy_name = "${var.global_hyperscaler}${var.global_hyperscaler_location}-${var.materna_customer_name}-wafp-${var.materna_project_number}-${var.global_stage}-${format("%02d", var.application_gateway_instance)}"
  mds_name        = "${var.global_hyperscaler}${var.global_hyperscaler_location}-${var.materna_customer_name}-mds-${var.materna_project_number}-${var.global_stage}-${format("%02d", 1)}"

  pip_id = var.public_ip_name == null ? null : "/subscriptions/${var.global_subscription_id}/resourceGroups/${data.azurerm_resource_group.rg.name}/providers/Microsoft.Network/publicIPAddresses/${var.public_ip_name}"


  default_custom_rule = var.waf_restrict_for_ips == null ? null : length(var.waf_restrict_for_ips) == 0 ? null : {
    CR1 = {
      enabled   = true
      rule_name = "restrict-for-ips"
      priority  = 1
      rule_type = "MatchRule"
      match_conditions = {
        MC1 = {
          match_variables = {
            MV1 = {
              variable_name = "RemoteAddr"
            }
          }
          match_values       = var.waf_restrict_for_ips
          operator           = "IPMatch"
          negation_condition = true
        }
      }
      action = "Block"
    }
  }
}


