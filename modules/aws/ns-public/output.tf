output "NS-record" {
  description = "DNS name for the Redis Enterprise Cluster"
  value       = aws_route53_record.NS-record.name
}

output "A-records" {
  description = "DNS names for Redis Enterprise nodes"
  value       = aws_route53_record.A-records.*.name
}

output "cluster_dns" {
  value = aws_route53_record.NS-record.name
}

output "cluster_master_dns" {
  value = aws_route53_record.A-records[0].name
}