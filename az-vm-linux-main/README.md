## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 0.13 |
| <a name="requirement_azuread"></a> [azuread](#requirement\_azuread) | ~> 2.29 |
| <a name="requirement_azurecaf"></a> [azurecaf](#requirement\_azurecaf) | 1.2.23 |
| <a name="requirement_azurerm"></a> [azurerm](#requirement\_azurerm) | ~>3.28 |
| <a name="requirement_random"></a> [random](#requirement\_random) | ~> 3.0 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_azuread"></a> [azuread](#provider\_azuread) | ~> 2.29 |
| <a name="provider_azurerm"></a> [azurerm](#provider\_azurerm) | ~>3.28 |
| <a name="provider_random"></a> [random](#provider\_random) | ~> 3.0 |

## Modules

No modules.

## Resources

| Name | Type |
|------|------|
| [azurerm_linux_virtual_machine.this](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/linux_virtual_machine) | resource |
| [azurerm_network_interface.this](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/network_interface) | resource |
| [azurerm_role_assignment.bastion_group_read_nic](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/role_assignment) | resource |
| [azurerm_role_assignment.bastion_group_read_vm](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/role_assignment) | resource |
| [azurerm_role_assignment.bastion_user_read_nic](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/role_assignment) | resource |
| [azurerm_role_assignment.bastion_user_read_vm](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/role_assignment) | resource |
| [random_password.this](https://registry.terraform.io/providers/hashicorp/random/latest/docs/resources/password) | resource |
| [azuread_group.bastion_group](https://registry.terraform.io/providers/hashicorp/azuread/latest/docs/data-sources/group) | data source |
| [azuread_user.bastion_user](https://registry.terraform.io/providers/hashicorp/azuread/latest/docs/data-sources/user) | data source |
| [azurerm_public_ip.this](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/data-sources/public_ip) | data source |
| [azurerm_resource_group.this](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/data-sources/resource_group) | data source |
| [azurerm_subnet.this](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/data-sources/subnet) | data source |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_bastion_host_groups"></a> [bastion\_host\_groups](#input\_bastion\_host\_groups) | n/a | `list(string)` | `[]` | no |
| <a name="input_bastion_host_users"></a> [bastion\_host\_users](#input\_bastion\_host\_users) | n/a | `list(string)` | `[]` | no |
| <a name="input_global_hyperscaler"></a> [global\_hyperscaler](#input\_global\_hyperscaler) | Kennzeichen für den Hyperscaler | `string` | n/a | yes |
| <a name="input_global_stage"></a> [global\_stage](#input\_global\_stage) | Staging Umgebung | `string` | n/a | yes |
| <a name="input_global_subscription_id"></a> [global\_subscription\_id](#input\_global\_subscription\_id) | n/a | `string` | `""` | no |
| <a name="input_license_type"></a> [license\_type](#input\_license\_type) | Must be either RHEL\_BYOS, SLES\_BYOS, none | `string` | `"none"` | no |
| <a name="input_materna_cost_center"></a> [materna\_cost\_center](#input\_materna\_cost\_center) | Materna cost center | `string` | n/a | yes |
| <a name="input_materna_customer_name"></a> [materna\_customer\_name](#input\_materna\_customer\_name) | Name of the customer (max. 5 characters). | `string` | n/a | yes |
| <a name="input_materna_project_number"></a> [materna\_project\_number](#input\_materna\_project\_number) | Materna internal project nummer | `string` | n/a | yes |
| <a name="input_materna_workload"></a> [materna\_workload](#input\_materna\_workload) | Materna vm workload(min 3 Zeichen und max 7 Zeichen). | `string` | n/a | yes |
| <a name="input_public_ip"></a> [public\_ip](#input\_public\_ip) | Public ip paramaters | <pre>object({<br>    name                = string<br>    resource_group_name = string<br>  })</pre> | `null` | no |
| <a name="input_subnet"></a> [subnet](#input\_subnet) | Subnet parameters | <pre>object({<br>    name                        = string<br>    network_name                = string<br>    network_resource_group_name = string<br>  })</pre> | n/a | yes |
| <a name="input_tags"></a> [tags](#input\_tags) | Tags for the deployment | `map(any)` | n/a | yes |
| <a name="input_virtual_machine_instance"></a> [virtual\_machine\_instance](#input\_virtual\_machine\_instance) | Die Instanz-ID für die Virtuelle Maschine | `number` | `1` | no |
| <a name="input_vm_admin_password"></a> [vm\_admin\_password](#input\_vm\_admin\_password) | password für die vm | `string` | `null` | no |
| <a name="input_vm_admin_username"></a> [vm\_admin\_username](#input\_vm\_admin\_username) | username für die vm | `string` | `"matadmin"` | no |
| <a name="input_vm_os_disk"></a> [vm\_os\_disk](#input\_vm\_os\_disk) | OS-Disk parameters | <pre>object({<br>    caching              = string<br>    storage_account_type = string<br>    disk_size_gb         = string<br>  })</pre> | <pre>{<br>  "caching": "ReadWrite",<br>  "disk_size_gb": null,<br>  "storage_account_type": "Standard_LRS"<br>}</pre> | no |
| <a name="input_vm_resource_group_name"></a> [vm\_resource\_group\_name](#input\_vm\_resource\_group\_name) | Resource group für die vm | `string` | n/a | yes |
| <a name="input_vm_size"></a> [vm\_size](#input\_vm\_size) | SKU, die für diese virtuelle Maschine verwendet werden soll | `string` | `"Standard_F2"` | no |
| <a name="input_vm_source_image_reference"></a> [vm\_source\_image\_reference](#input\_vm\_source\_image\_reference) | Vm-Image Eigenschaften | <pre>object({<br>    publisher = string<br>    offer     = string<br>    sku       = string<br>    version   = string<br>  })</pre> | <pre>{<br>  "offer": "UbuntuServer",<br>  "publisher": "Canonical",<br>  "sku": "16.04-LTS",<br>  "version": "latest"<br>}</pre> | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_vm_object"></a> [vm\_object](#output\_vm\_object) | n/a |
