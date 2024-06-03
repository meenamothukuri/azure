global_stage           = "dev"
materna_project_number = "gittest"
materna_cost_center    = "40b01000"
materna_customer_name  = "mat"

commands_to_execute = {
  install_iis_and_dot_net_4_8 = "powershell -ExecutionPolicy Unrestricted -command \"Install-WindowsFeature -name Web-Server -IncludeManagementTools\" && powershell -ExecutionPolicy Unrestricted -command \"Start-BitsTransfer -Source 'https://go.microsoft.com/fwlink/?linkid=2088517'  -Destination \"$Env:Temp\\Net4.8.exe\"; & \"$Env:Temp\\Net4.8.exe\" /q /norestart /log \"%WINDIR%\\Temp\\DotNET48-Install.log\"\""
}
#### Azure Config ###
subnet_address_prefix = "10.158.13.240/28"
network = {
  name                = "azwe-mat-vnet-j2cpublic-00"
  resource_group_name = "azwe-mat-rg-network-prd-00"
}

#### Azure Config ###

#### KNE Config ###
/*
subnet_address_prefix = "10.21.193.248/29"
network = {
  name                = "dlwe-mat-vnet-shared-dev-01"
  resource_group_name = "dlwe-mat-rg-network-dev-01"
}*/

#### KNE Config ###

tags = {
  owner   = "j2cp@materna.group"
  project = "test"
}
