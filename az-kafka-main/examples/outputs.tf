output "kafka_gateway_username" {
  value = module.my_kafka.kafka_gateway_username
}

output "kafka_gateway_password" {
  value     = module.my_kafka.kafka_gateway_password
  sensitive = true
}

output "kafka_id" {
  value = module.my_kafka.kafka_id
}
output "st_id" {
  value = module.my_kafka.st_id
}
