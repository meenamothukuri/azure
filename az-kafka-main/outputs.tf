output "snet_id" {
  value = data.azurerm_subnet.snet.id
}

output "snet_name" {
  value = data.azurerm_subnet.snet.name
}

output "snet_address_prefix" {
  value = data.azurerm_subnet.snet.address_prefixes[0]
}

output "vnet_id" {
  value = data.azurerm_virtual_network.vnet.id
}

output "vnet_name" {
  value = data.azurerm_virtual_network.vnet.name
}

output "rg_id" {
  value = data.azurerm_resource_group.rg.id
}

output "rg_name" {
  value = data.azurerm_resource_group.rg.name
}

output "kafka_name" {
  value = azurerm_hdinsight_kafka_cluster.this.name
}

output "kafka_id" {
  value = azurerm_hdinsight_kafka_cluster.this.id
}

output "kafka_gateway_username" {
  value = azurerm_hdinsight_kafka_cluster.this.gateway[0].username
}

output "kafka_gateway_password" {
  value     = azurerm_hdinsight_kafka_cluster.this.gateway[0].password
  sensitive = true
}

output "kafka_head_node_username" {
  value = azurerm_hdinsight_kafka_cluster.this.roles[0].head_node[0].username
}

output "kafka_head_node_password" {
  value     = azurerm_hdinsight_kafka_cluster.this.roles[0].head_node[0].password
  sensitive = true
}

output "kafka_worker_node_username" {
  value = azurerm_hdinsight_kafka_cluster.this.roles[0].worker_node[0].username
}

output "kafka_worker_node_password" {
  value     = azurerm_hdinsight_kafka_cluster.this.roles[0].worker_node[0].password
  sensitive = true
}

output "kafka_zookeeper_node_username" {
  value = azurerm_hdinsight_kafka_cluster.this.roles[0].zookeeper_node[0].username
}

output "kafka_zookeeper_node_password" {
  value     = azurerm_hdinsight_kafka_cluster.this.roles[0].zookeeper_node[0].password
  sensitive = true
}

output "st_id" {
  value = module.storage_account.st_id
}
