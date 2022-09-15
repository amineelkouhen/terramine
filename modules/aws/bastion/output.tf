output "public-ip" {
  value = aws_eip.eip.public_ip
}

output "prometheus-endpoint" {
  value = "http://${aws_eip.eip.public_ip}:9090"
}

output "grafana-endpoint" {
  value = "http://${aws_eip.eip.public_ip}:3000"
}

output "redis-insight-endpoint" {
  value = "http://${aws_eip.eip.public_ip}:8001"
}