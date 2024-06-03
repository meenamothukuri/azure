global_stage           = "dev"
materna_project_number = "gittest"
materna_cost_center    = "40b01000"
materna_customer_name  = "mat"

#### Azure Config ###
private_endpoint = {
  instance = 1
  custom_config = {
    resource_group_name = "azwe-mat-rg-pe-prd-00"
    subnet = {
      name                        = "azwe-mat-snet-pe-prd-00"
      network_name                = "azwe-mat-vnet-j2cpublic-00"
      network_resource_group_name = "azwe-mat-rg-network-prd-00"
    }
  }
}
#### Azure Config ###

#### KNE Config ###
#private_endpoint = {
#  instance = 1
#}
##### KNE Config ###

sql_server = {
  version                       = "12.0"
  admin_username                = "missadmin"
  admin_password                = "J7220-KLAD+1161P"
  minimum_tls_version           = "1.2"
  public_network_access_enabled = false
}

sql_databases = {
  private = {}
}

tags = {
  owner   = "j2cp@materna.group"
  project = "test"
}
