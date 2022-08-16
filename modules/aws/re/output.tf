output "re-nodes" {
  description = "The Redis Enterprise nodes"
  value = aws_instance.node
  sensitive = true
}

output "re-public-ips" {
  description = "Public IP addresses of all Redis cluster nodes"
  value       = aws_instance.node[*].public_ip
}

output "re-private-ips" {
  description = "Private IP addresses of all Redis cluster nodes"
  value       = aws_instance.node[*].private_ip
}