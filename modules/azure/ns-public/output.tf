output "NS-records" {
  description = "DNS name for the Redis Enterprise Cluster"
  value       = azurerm_dns_ns_record.NS-record.name
}

output "A-records" {
  description = "DNS names for Redis Enterprise nodes"
  value       = azurerm_dns_a_record.A-records.*.name
}

output "cluster_dns" {
  value = "cluster.${var.subdomain}.${var.hosted_zone}"
}

output "cluster_master_dns" {
  value = "node1.cluster.${var.subdomain}.${var.hosted_zone}"
}