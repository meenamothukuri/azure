global_stage           = "dev"
materna_project_number = "vmsstest"
materna_cost_center    = "40b01000"
materna_customer_name  = "mat"

#### Azure Config ###
subnet_address_prefix = "10.158.13.240/28"
network = {
  name                = "azwe-mat-vnet-j2cpublic-00"
  resource_group_name = "azwe-mat-rg-network-prd-00"
}
#### Azure Config ###

#### KNE Config ###

/* subnet_address_prefix = "10.21.193.240/28"
network = {
  name                = "dlwe-mat-vnet-shared-dev-01"
  resource_group_name = "dlwe-mat-rg-network-dev-01"
}
 */
#### KNE Config ###

vmss_source_image_reference = {
  publisher = "Canonical"
  offer     = "UbuntuServer"
  sku       = "16.04-LTS"
  version   = "latest"
}

auto_start = {
  timezone = "W. Europe Standard Time"
  days     = ["Monday", "Tuesday", "Wednesday", "Thursday", "Friday"]
  hours    = [17]
  minutes  = [48]
}

auto_stop = {
  timezone = "W. Europe Standard Time"
  days     = ["Saturday", "Sunday", "Monday", "Tuesday", "Wednesday", "Thursday", "Friday"]
  hours    = [17]
  minutes  = [44]
}

tags = {
  owner   = "j2cp@materna.group"
  project = "test"
}
