output "A-records" {
  description = "DNS names for Redis Enterprise nodes"
  value = google_dns_record_set.A-records.*.name
}

output "cluster_dns" {
  value = "cluster.${var.subdomain}.${var.hosted_zone}"
}

output "cluster_master_dns" {
  value = "node1.cluster.${var.subdomain}.${var.hosted_zone}"
}