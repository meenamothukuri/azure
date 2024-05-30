locals {
  global_hyperscaler = "az"
  private_dns_zone = {
    resource_group_name = "mydnsrg"
    aks = {
      id = "myid"
    }
  }
  private_endpoint = {
    resource_group_name = "myperg"
    subnet = {
      name                        = "mysnet"
      network_name                = "myvnetname"
      network_resource_group_name = "myvnetrg"
    }
  }
}
