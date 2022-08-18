output "NS-records" {
  description = "DNS name for the Redis Enterprise Cluster"
  value       = google_dns_record_set.NS-record.name
}

output "A-records" {
  description = "DNS names for Redis Enterprise nodes"
  value = flatten(google_dns_record_set.NS-record.rrdatas)
}

output "cluster_dns" {
  value = "cluster.${var.subdomain}.${var.hosted_zone}"
}

output "cluster_master_dns" {
  value = "node1.cluster.${var.subdomain}.${var.hosted_zone}"
}