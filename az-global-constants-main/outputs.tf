output "private_dns_zone" {
  value = var.global_hyperscaler == "az" ? {
    resource_group_name = try(var.private_dns_zone["resource_group_name"], null)
    service = {
      aks = {
        gw = {
          name = "privatelink.germanywestcentral.azmk8s.io"
          id   = try(var.private_dns_zone["aks"]["id"], "")
        }
        we = {
          name = "privatelink.westeurope.azmk8s.io"
          id   = try(var.private_dns_zone["aks"]["id"], "")
        }
        ne = {
          name = "privatelink.northeurope.azmk8s.io"
          id   = try(var.private_dns_zone["aks"]["id"], "")
        }
      }
      container_registry = {
        name = "privatelink.azurecr.io"
        id   = null
      }
      storage_account_blob = {
        name = "privatelink.blob.core.windows.net"
        id   = null
      }
      storage_account_file = {
        name = "privatelink.file.core.windows.net"
        id   = null
      }
      key_vault = {
        name = "privatelink.vaultcore.azure.net"
        id   = null
      }
      hdinsight = {
        name = "privatelink.azurehdinsight.net"
        id   = null
      }
      sql_server = {
        name = "privatelink.database.windows.net"
        id   = null
      }
    }
    } : {
    resource_group_name = try(var.private_dns_zone["resource_group_name"], "dlwe-mat-rg-j2cppdns-dev-01")
    service = {
      aks = {
        gw = {
          name = ""
          id   = try(var.private_dns_zone["aks"]["id"], "")
        }
        we = {
          name = "dlwematpdnsj2cppdnsdev01.privatelink.westeurope.azmk8s.io"
          id   = try(var.private_dns_zone["aks"]["id"], "/subscriptions/3a56d5e4-20ea-466a-bf24-a4ba65a31de2/resourceGroups/dlwe-mat-rg-j2cppdns-dev-01/providers/Microsoft.Network/privateDnsZones/dlwematpdnsj2cppdnsdev01.privatelink.westeurope.azmk8s.io")
        }
        ne = {
          name = ""
          id   = try(var.private_dns_zone["aks"]["id"], "")
        }
      }
      container_registry = {
        name = "privatelink.azurecr.io"
        id   = "/subscriptions/3a56d5e4-20ea-466a-bf24-a4ba65a31de2/resourceGroups/dlwe-mat-rg-j2cppdns-dev-01/providers/Microsoft.Network/privateDnsZones/privatelink.azurecr.io"
      }
      storage_account_blob = {
        name = "privatelink.blob.core.windows.net"
        id   = "/subscriptions/3a56d5e4-20ea-466a-bf24-a4ba65a31de2/resourceGroups/dlwe-mat-rg-j2cppdns-dev-01/providers/Microsoft.Network/privateDnsZones/privatelink.blob.core.windows.net"
      }
      storage_account_file = {
        name = "privatelink.file.core.windows.net"
        id   = "/subscriptions/3a56d5e4-20ea-466a-bf24-a4ba65a31de2/resourceGroups/dlwe-mat-rg-j2cppdns-dev-01/providers/Microsoft.Network/privateDnsZones/privatelink.file.core.windows.net"
      }
      key_vault = {
        name = "privatelink.vaultcore.azure.net"
        id   = "/subscriptions/3a56d5e4-20ea-466a-bf24-a4ba65a31de2/resourceGroups/dlwe-mat-rg-j2cppdns-dev-01/providers/Microsoft.Network/privateDnsZones/privatelink.vaultcore.azure.net"
      }
      hdinsight = {
        name = "privatelink.azurehdinsight.net"
        id   = "/subscriptions/3a56d5e4-20ea-466a-bf24-a4ba65a31de2/resourceGroups/dlwe-mat-rg-j2cppdns-dev-01/providers/Microsoft.Network/privateDnsZones/privatelink.azurehdinsight.net"
      }
      sql_server = {
        name = "privatelink.database.windows.net"
        id   = "/subscriptions/3a56d5e4-20ea-466a-bf24-a4ba65a31de2/resourceGroups/dlwe-mat-rg-j2cppdns-dev-01/providers/Microsoft.Network/privateDnsZones/privatelink.database.windows.net"
      }
    }
  }
}

output "private_endpoint" {
  value = var.global_hyperscaler == "az" ? {
    resource_group_name = try(var.private_endpoint["resource_group_name"], "azgw-mat-rg-compe-prd-01")
    subnet = {
      name                        = try(var.private_endpoint["subnet"]["name"], "azgw-mat-snet-compe-prd-01")
      network_name                = try(var.private_endpoint["subnet"]["network_name"], "azgw-mat-vnet-lzj2cpcommon-prd-01")
      network_resource_group_name = try(var.private_endpoint["subnet"]["network_resource_group_name"], "azgw-mat-rg-lzconnect-prd")
    }
    } : {
    resource_group_name = try(var.private_endpoint["resource_group_name"], "dlwe-mat-rg-compe-dev-01")
    subnet = {
      name                        = try(var.private_endpoint["subnet"]["name"], "dlwe-mat-snet-compe-dev-01")
      network_name                = try(var.private_endpoint["subnet"]["network_name"], "dlwe-mat-vnet-shared-dev-01")
      network_resource_group_name = try(var.private_endpoint["subnet"]["network_resource_group_name"], "dlwe-mat-rg-network-dev-01")
    }
  }
}
