output "NS-record" {
  description = "DNS name for the Redis Enterprise Cluster"
  value       = aws_route53_record.NS-record.name
}

output "A-records" {
  description = "DNS names for Redis Enterprise nodes"
  value       = aws_route53_record.A-records.*.name
}